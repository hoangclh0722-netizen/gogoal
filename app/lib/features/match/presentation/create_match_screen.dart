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

class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({super.key});

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
  bool _saving = false;
  String? _error;
  String? _id;

  @override
  void initState() {
    super.initState();
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
    _cost.addListener(() => setState(() {}));
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _cost.dispose();
    _note.dispose();
    super.dispose();
  }

  void _pickFormat(_Format f) {
    _format = f;
    _slots = (f.players - 1).clamp(1, 4);
    if (!_titleEdited) {
      _title.text = '${Sport.fromId(_sportId).displayName} ${f.label.toLowerCase()}';
    }
  }

  void _pickSport(String id) => setState(() {
        if (id == _sportId) return;
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

  bool get _canSubmit => !_saving && _venue != null && _title.text.trim().isNotEmpty && _timeError == null;

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
    );
    if (d != null) setState(() => _start = DateTime(d.year, d.month, d.day, _start.hour, _start.minute));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
    if (t != null) setState(() => _start = DateTime(_start.year, _start.month, _start.day, t.hour, t.minute));
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

  Future<void> _submit() async {
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
    final note = _note.text.trim();
    try {
      await repo.create(
        id,
        MatchDraft(
          title: _title.text.trim(),
          sportId: _sportId,
          format: _format.id,
          playersTotal: _format.players,
          slotsNeeded: _slots,
          levelMin: _levels.start.round(),
          levelMax: _levels.end.round(),
          startAt: _start,
          endAt: _start.add(Duration(minutes: _duration)),
          venue: _venue!,
          costTotal: _costTotal,
          autoApprove: _auto,
          note: note.isEmpty ? null : note,
        ),
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
        title: const Text('Tạo kèo', style: TextStyle(fontWeight: FontWeight.w700)),
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
                _Chip(label: s.displayName, color: s.color, selected: s.id == _sportId, onTap: () => _pickSport(s.id)),
            ]),
            const _Label('Thể thức'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final f in _formats[_sportId]!)
                _Chip(
                  label: '${f.label} · ${f.players} người',
                  selected: f == _format,
                  onTap: () => setState(() => _pickFormat(f)),
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
                onMinus: _slots > 1 ? () => setState(() => _slots--) : null,
                onPlus: _slots < _format.players - 1 ? () => setState(() => _slots++) : null,
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
              for (final d in _durations)
                _Chip(
                  label: '${d % 60 == 0 ? d ~/ 60 : (d / 60).toString().replaceAll('.', ',')} giờ',
                  selected: d == _duration,
                  onTap: () => setState(() => _duration = d),
                ),
            ]),
            Text('Kết thúc lúc ${formatHm(end)}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
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
            AppButton(label: _saving ? 'Đang đăng…' : 'Đăng kèo', onPressed: _canSubmit ? _submit : null),
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
