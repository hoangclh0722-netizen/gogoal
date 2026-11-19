import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/district.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/application/auth_providers.dart';
import '../../profile/application/profile_providers.dart';
import '../../sport/domain/sport.dart';
import '../../sport/presentation/sport_style.dart';
import '../application/match_providers.dart';
import '../domain/entities/match.dart';

typedef _Format = ({String id, String label, int players});

const _racket = <_Format>[
  (id: 'singles', label: 'Đánh đơn', players: 2),
  (id: 'doubles', label: 'Đánh đôi', players: 4),
];

const _formats = <String, List<_Format>>{
  'football': [
    (id: '5v5', label: 'Sân 5', players: 10),
    (id: '7v7', label: 'Sân 7', players: 14),
    (id: '11v11', label: 'Sân 11', players: 22),
  ],
  'basketball': [
    (id: '3v3', label: '3x3', players: 6),
    (id: '5v5', label: '5x5', players: 10),
  ],
  'badminton': _racket,
  'pickleball': _racket,
  'tennis': _racket,
};

const _durations = [60, 90, 120, 180];

enum _Deadline { twoHours, evening, custom, none }

/// Tạo kèo mới, hoặc sửa kèo [initial] khi chủ kèo bấm "Sửa".
class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({super.key, this.initial});

  final Match? initial;

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  final _title = TextEditingController();
  final _cost = TextEditingController();
  final _note = TextEditingController();
  late String _sportId;
  late _Format _format;
  late int _slots;
  late DateTime _start;
  int _duration = 120;
  VenueOption? _venue;
  RangeValues _levels = const RangeValues(1, 4);
  bool _auto = false;
  bool _titleEdited = false;
  late int _slotsMin;
  bool _minEdited = false;
  _Deadline _deadlineMode = _Deadline.none;
  DateTime? _customDeadline;
  bool _saving = false;
  String? _error;
  String? _id;

  bool get _editing => widget.initial != null;

  // Đã nhận bao nhiêu người thì không giảm số chỗ xuống dưới mức đó
  int get _minSlots => max(1, widget.initial?.slotsFilled ?? 0);

  List<_Format> get _formatOptions {
    final list = _formats[_sportId]!;
    return list.contains(_format) ? list : [_format, ...list];
  }

  @override
  void initState() {
    super.initState();
    _cost.addListener(() => setState(() {}));
    _title.addListener(() => setState(() {}));
    final m = widget.initial;
    if (m != null) {
      _sportId = m.sportId;
      _format = _formats[m.sportId]!.firstWhere(
        (f) => f.id == m.format && f.players == m.playersTotal,
        orElse: () => (id: m.format, label: formatLabel(m.format), players: m.playersTotal),
      );
      _slots = m.slotsNeeded;
      _slotsMin = m.slotsMin;
      _minEdited = true;
      final d = m.joinDeadline;
      _deadlineMode = d == null
          ? _Deadline.none
          : d == m.startAt.subtract(const Duration(hours: 2))
              ? _Deadline.twoHours
              : d == _eveningBefore(m.startAt)
                  ? _Deadline.evening
                  : _Deadline.custom;
      _customDeadline = d;
      _title.text = m.title;
      _titleEdited = true;
      _start = m.startAt;
      _duration = m.endAt.difference(m.startAt).inMinutes;
      _venue = VenueOption(id: m.venue.id, venue: m.venue, geo: m.geo);
      _levels = RangeValues(m.levelMin.toDouble(), m.levelMax.toDouble());
      if (m.costTotal > 0) _cost.text = NumberFormat.decimalPattern('vi').format(m.costTotal);
      _auto = m.autoApprove;
      _note.text = m.note ?? '';
      return;
    }
    _sportId = 'football';
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, now.day, now.hour + 2);
    _pickFormat(_formats[_sportId]!.first);
    // Hồ sơ có thể chưa tải xong lúc mở màn, chọn sẵn môn đầu tiên khi có
    ref.listenManual(myProfileProvider, (prev, next) {
      final sports = next.value?.sports.keys;
      if (prev?.value != null || sports == null || sports.isEmpty) return;
      _pickSport(Sport.all.map((s) => s.id).firstWhere(sports.contains, orElse: () => _sportId));
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _title.dispose();
    _cost.dispose();
    _note.dispose();
    super.dispose();
  }

  static DateTime _eveningBefore(DateTime start) => DateTime(start.year, start.month, start.day - 1, 20);

  void _setSlots(int v) {
    _slots = v;
    _slotsMin = _minEdited ? min(_slotsMin, v) : v;
  }

  void _pickFormat(_Format f) {
    _format = f;
    _setSlots(_editing ? _slots.clamp(_minSlots, f.players - 1) : (f.players - 1).clamp(1, 4));
    if (!_titleEdited) {
      _title.text = '${Sport.fromId(_sportId).displayName} ${f.label.toLowerCase()}';
    }
  }

  void _pickSport(String id) => setState(() {
        if (id == _sportId || _editing) return;
        _sportId = id;
        _venue = null;
        _pickFormat(_formats[id]!.first);
      });

  int get _costTotal => int.tryParse(_cost.text.replaceAll('.', '')) ?? 0;

  String? get _timeError {
    final now = DateTime.now();
    if (_start.isBefore(now.add(const Duration(minutes: 30)))) return 'Giờ bắt đầu phải sau bây giờ ít nhất 30 phút';
    if (_start.isAfter(now.add(const Duration(days: 30)))) return 'Chỉ tạo kèo trong vòng 30 ngày tới';
    return null;
  }

  bool get _deadlineRequired => _start.isAfter(DateTime.now().add(const Duration(hours: 6)));

  DateTime? get _deadline => switch (_deadlineMode) {
        _Deadline.twoHours => _start.subtract(const Duration(hours: 2)),
        _Deadline.evening => _eveningBefore(_start),
        _Deadline.custom => _customDeadline,
        _Deadline.none => null,
      };

  String? get _deadlineError {
    final d = _deadline;
    if (d == null) return _deadlineRequired ? 'Kèo đá sau 6 giờ nữa cần đặt hạn chốt người' : null;
    if (d.isAfter(_start.subtract(const Duration(minutes: 30)))) return 'Hạn chốt phải trước giờ đá ít nhất 30 phút';
    // Sửa kèo đã qua hạn mà giữ nguyên hạn cũ thì vẫn lưu được
    if (!d.isAfter(DateTime.now()) && d != widget.initial?.joinDeadline) return 'Hạn chốt đã qua, chọn hạn khác';
    return null;
  }

  // Đổi giờ đá mà kèo cần hạn chốt thì tự chọn hạn hợp lý nhất
  void _fixDeadline() {
    if (_deadlineMode != _Deadline.none || !_deadlineRequired) return;
    _deadlineMode = _eveningBefore(_start).isAfter(DateTime.now()) ? _Deadline.evening : _Deadline.twoHours;
  }

  bool get _canSubmit =>
      !_saving && _venue != null && _title.text.trim().isNotEmpty && _timeError == null && _deadlineError == null;

  Future<void> _pickCustomDeadline() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initial = _customDeadline ?? _start.subtract(const Duration(hours: 2));
    final d = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      firstDate: today,
      lastDate: _start,
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (t == null) return;
    setState(() {
      _customDeadline = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      _deadlineMode = _Deadline.custom;
    });
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
    );
    if (d != null) {
      setState(() {
        _start = DateTime(d.year, d.month, d.day, _start.hour, _start.minute);
        _fixDeadline();
      });
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
    if (t != null) {
      setState(() {
        _start = DateTime(_start.year, _start.month, _start.day, t.hour, t.minute);
        _fixDeadline();
      });
    }
  }

  Future<void> _pickVenue() async {
    final sport = Sport.fromId(_sportId);
    final v = await showModalBottomSheet<VenueOption>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _VenueSheet(sport: sport, selected: _venue?.id),
    );
    if (v != null) setState(() => _venue = v);
  }

  MatchDraft get _draft {
    final note = _note.text.trim();
    return MatchDraft(
      title: _title.text.trim(),
      sportId: _sportId,
      format: _format.id,
      playersTotal: _format.players,
      slotsNeeded: _slots,
      slotsMin: _slotsMin,
      joinDeadline: _deadline,
      levelMin: _levels.start.round(),
      levelMax: _levels.end.round(),
      startAt: _start,
      endAt: _start.add(Duration(minutes: _duration)),
      venue: _venue!,
      costTotal: _costTotal,
      autoApprove: _auto,
      note: note.isEmpty ? null : note,
    );
  }

  Future<void> _submit() => _editing ? _save() : _create();

  Future<void> _save() async {
    final m = widget.initial!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(matchRepositoryProvider).update(m.id, _draft, slotsFilled: m.slotsFilled);
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) setState(() => _error = 'Không lưu được thay đổi, thử lại');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _create() async {
    final user = ref.read(authStateProvider).value;
    setState(() {
      _saving = true;
      _error = null;
    });
    final profile = await ref.read(myProfileProvider.future);
    if (user == null || profile == null) {
      if (mounted) setState(() => _saving = false);
      return;
    }
    final repo = ref.read(matchRepositoryProvider);
    final id = _id ??= repo.newId();
    try {
      await repo.create(
        id,
        _draft,
        hostId: user.uid,
        // Chưa có đánh giá thì lấy mức khởi điểm 4.0 như BR11
        host: Host(displayName: profile.displayName, rep: profile.reputation ?? 4.0, avatarUrl: profile.avatarUrl),
      );
      if (mounted) context.pushReplacement(Routes.match(id));
    } catch (_) {
      if (mounted) setState(() => _error = 'Không đăng được kèo, thử lại');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final end = _start.add(Duration(minutes: _duration));
    final timeError = _timeError;
    final perPerson = (_costTotal / _format.players / 1000).ceil() * 1000;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_editing ? 'Sửa kèo' : 'Tạo kèo', style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(title: 'Môn & thể thức', children: [
            const _Label('Môn'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final s in Sport.all)
                if (!_editing || s.id == _sportId)
                  _Chip(label: s.displayName, color: s.color, selected: s.id == _sportId, onTap: () => _pickSport(s.id)),
            ]),
            if (_editing)
              const Text('Không đổi môn khi sửa kèo', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            const _Label('Thể thức'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final f in _formatOptions)
                _Chip(
                  label: '${f.label} · ${f.players} người',
                  selected: f == _format,
                  onTap: () {
                    if (f.players - 1 < _minSlots) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã nhận $_minSlots người, không đổi sang ${f.label.toLowerCase()} được')));
                      return;
                    }
                    setState(() => _pickFormat(f));
                  },
                ),
            ]),
            const _Label('Tên kèo'),
            TextField(
              controller: _title,
              maxLength: 60,
              onChanged: (_) => _titleEdited = true,
              decoration: const InputDecoration(counterText: ''),
            ),
          ]),
          _Section(title: 'Số người', children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Cần tuyển thêm', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('Tổng ${_format.players} người, tính cả bạn',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ]),
              ),
              _Stepper(
                value: _slots,
                onMinus: _slots > _minSlots ? () => setState(() => _setSlots(_slots - 1)) : null,
                onPlus: _slots < _format.players - 1 ? () => setState(() => _setSlots(_slots + 1)) : null,
              ),
            ]),
            Row(children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Cần ít nhất', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('Đủ số này mới đá được', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                ]),
              ),
              _Stepper(
                value: _slotsMin,
                onMinus: _slotsMin > 1
                    ? () => setState(() {
                          _slotsMin--;
                          _minEdited = true;
                        })
                    : null,
                onPlus: _slotsMin < _slots
                    ? () => setState(() {
                          _slotsMin++;
                          _minEdited = true;
                        })
                    : null,
              ),
            ]),
          ]),
          _Section(title: 'Thời gian', children: [
            Row(children: [
              Expanded(child: _Field(icon: Icons.calendar_today_outlined, text: formatDate(_start), onTap: _pickDate)),
              const SizedBox(width: 10),
              SizedBox(
                width: 120,
                child: _Field(icon: Icons.schedule, text: formatHm(_start), onTap: _pickTime, error: timeError != null),
              ),
            ]),
            if (timeError != null)
              Text(timeError, style: const TextStyle(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.w500)),
            const _Label('Thời lượng'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final d in ({..._durations, _duration}.toList()..sort()))
                _Chip(
                  label: '${d % 60 == 0 ? d ~/ 60 : (d / 60).toString().replaceAll('.', ',')} giờ',
                  selected: d == _duration,
                  onTap: () => setState(() => _duration = d),
                ),
            ]),
            Text('Kết thúc lúc ${formatHm(end)}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            const _Label('Hạn chốt người'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (mode, label) in [
                (_Deadline.twoHours, '2 giờ trước'),
                (_Deadline.evening, 'Tối hôm trước'),
                (_Deadline.custom, 'Tự chọn'),
                if (!_deadlineRequired || _deadlineMode == _Deadline.none) (_Deadline.none, 'Không đặt'),
              ])
                _Chip(
                  label: label,
                  selected: mode == _deadlineMode,
                  onTap: mode == _Deadline.custom
                      ? _pickCustomDeadline
                      : () => setState(() => _deadlineMode = mode),
                ),
            ]),
            if (_deadlineError case final e?)
              Text(e, style: const TextStyle(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.w500))
            else if (_deadline case final d?)
              Text('Chốt lúc ${formatHm(d)} ${formatDate(d)} · nên đặt trước hạn hủy sân miễn phí',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted))
            else
              const Text('Nhận người tới giờ đá', style: TextStyle(fontSize: 13, color: AppColors.muted)),
          ]),
          _Section(title: 'Sân', children: [
            _VenueTile(venue: _venue, onTap: _pickVenue),
          ]),
          _Section(title: 'Trình độ', children: [
            Text(formatLevelRange(_levels.start.round(), _levels.end.round()),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            RangeSlider(
              values: _levels,
              min: 1,
              max: 4,
              divisions: 3,
              onChanged: (v) => setState(() => _levels = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final l in skillLevels)
                  Text(l, style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500)),
              ],
            ),
          ]),
          _Section(title: 'Chi phí', children: [
            const _Label('Tổng tiền sân'),
            TextField(
              controller: _cost,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _MoneyFormatter()],
              decoration: const InputDecoration(hintText: '0 nếu miễn phí', suffixText: 'đ'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                  text: _costTotal == 0 ? 'Miễn phí' : '≈ ${formatMoney(perPerson)}/người',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (_costTotal > 0) TextSpan(text: '  chia đều ${_format.players} người'),
              ]), style: const TextStyle(fontSize: 13, color: AppColors.primaryDark)),
            ),
          ]),
          _Section(title: 'Khác', children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Tự động nhận người', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(_auto ? 'Đang bật: ai đủ điều kiện là vào luôn' : 'Đang tắt: bạn duyệt từng yêu cầu',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ]),
              ),
              Switch(value: _auto, onChanged: (v) => setState(() => _auto = v)),
            ]),
            const _Label('Ghi chú'),
            TextField(
              controller: _note,
              maxLength: 500,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Ví dụ: mang áo màu tối, có nước uống'),
            ),
          ]),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
              ),
            AppButton(
                label: _saving ? 'Đang lưu…' : (_editing ? 'Lưu thay đổi' : 'Đăng kèo'), onPressed: _canSubmit ? _submit : null),
          ],
        ),
      ),
    );
  }
}

class _MoneyFormatter extends TextInputFormatter {
  final _fmt = NumberFormat.decimalPattern('vi');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final text = _fmt.format(int.parse(newValue.text.substring(0, newValue.text.length.clamp(0, 9))));
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted));
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap, this.color});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected && color == null ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? accent : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (color != null) ...[CircleAvatar(radius: 4, backgroundColor: color), const SizedBox(width: 6)],
          Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected && color == null ? AppColors.primaryDark : AppColors.ink,
              )),
        ]),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onMinus, required this.onPlus});

  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        IconButton(onPressed: onMinus, icon: const Icon(Icons.remove), color: AppColors.primaryDark),
        SizedBox(
          width: 28,
          child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ),
        IconButton(onPressed: onPlus, icon: const Icon(Icons.add), color: AppColors.primaryDark),
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.icon, required this.text, required this.onTap, this.error = false});

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: error ? AppColors.danger : AppColors.border, width: error ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 15)),
        ]),
      ),
    );
  }
}

class _VenueTile extends StatelessWidget {
  const _VenueTile({required this.venue, required this.onTap});

  final VenueOption? venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = venue?.venue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.place_outlined, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: v == null
                ? const Text('Chọn sân', style: TextStyle(fontSize: 15, color: AppColors.muted))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('${v.address} · ${districtName(v.district)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  ]),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ]),
      ),
    );
  }
}

class _VenueSheet extends ConsumerWidget {
  const _VenueSheet({required this.sport, required this.selected});

  final Sport sport;
  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venues = ref.watch(venuesProvider(sport.id));
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Chọn sân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text('Các sân có môn ${sport.displayName}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              ]),
            ),
            Flexible(
              child: venues.when(
                loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Không tải được danh sách sân'),
                    TextButton(onPressed: () => ref.invalidate(venuesProvider(sport.id)), child: const Text('Thử lại')),
                  ]),
                ),
                data: (list) => list.isEmpty
                    ? const Padding(padding: EdgeInsets.all(24), child: Text('Chưa có sân nào cho môn này'))
                    : ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                        children: [
                          for (final v in list)
                            ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                              tileColor: v.id == selected ? AppColors.primarySoft : null,
                              leading: const Icon(Icons.place_outlined),
                              title: Text(v.venue.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${v.venue.address} · ${districtName(v.venue.district)}'),
                              trailing: v.id == selected ? const Icon(Icons.check, color: AppColors.primaryDark) : null,
                              onTap: () => Navigator.of(context).pop(v),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
