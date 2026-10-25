import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp, GeoPoint } from 'firebase-admin/firestore';
import ngeohash from 'ngeohash';

process.env.FIRESTORE_EMULATOR_HOST ??= '127.0.0.1:8080';
initializeApp({ projectId: 'demo-gogoal' });
const db = getFirestore();

const venues = [
  { id: 'v-tao-dan', name: 'Sân bóng Tao Đàn', address: 'Công viên Tao Đàn', district: 'q1', lat: 10.7733, lng: 106.6925, sportIds: ['football'] },
  { id: 'v-rach-mieu', name: 'Nhà thi đấu Rạch Miễu', address: 'Rạch Miễu', district: 'phu-nhuan', lat: 10.7981, lng: 106.6844, sportIds: ['badminton', 'basketball'] },
  { id: 'v-q3-cl', name: 'CLB Cầu lông Nam Kỳ', address: 'Nam Kỳ Khởi Nghĩa', district: 'q3', lat: 10.7826, lng: 106.6850, sportIds: ['badminton'] },
  { id: 'v-q7-pk', name: 'Sân Pickleball Phú Mỹ Hưng', address: 'Nguyễn Lương Bằng', district: 'q7', lat: 10.7289, lng: 106.7194, sportIds: ['pickleball', 'tennis'] },
  { id: 'v-q10-bb', name: 'Sân bóng rổ Quận 10', address: 'Sư Vạn Hạnh', district: 'q10', lat: 10.7712, lng: 106.6679, sportIds: ['basketball'] },
  { id: 'v-bt-fb', name: 'Sân bóng Bình Thạnh 7', address: 'Phan Văn Trị', district: 'binh-thanh', lat: 10.8118, lng: 106.6957, sportIds: ['football'] },
  { id: 'v-tb-tn', name: 'Sân Tennis Tân Bình', address: 'Hoàng Văn Thụ', district: 'tan-binh', lat: 10.7996, lng: 106.6563, sportIds: ['tennis', 'pickleball'] },
  { id: 'v-gv-fb', name: 'Sân bóng Gò Vấp', address: 'Quang Trung', district: 'go-vap', lat: 10.8386, lng: 106.6652, sportIds: ['football'] },
  { id: 'v-td-bd', name: 'Nhà thi đấu Thủ Đức', address: 'Võ Văn Ngân', district: 'thu-duc', lat: 10.8509, lng: 106.7716, sportIds: ['badminton', 'basketball', 'football'] },
];
const vById = Object.fromEntries(venues.map(v => [v.id, v]));

const hostsRaw = [
  { id: 'u-minh', displayName: 'Minh', district: 'binh-thanh', ratingSum: 188, ratingCount: 40, noShows: 0, lateLeaves: 1, lateCancels: 0 },
  { id: 'u-lan', displayName: 'Lan', district: 'q3', ratingSum: 92, ratingCount: 20, noShows: 0, lateLeaves: 0, lateCancels: 0 },
  { id: 'u-tuan', displayName: 'Tuấn', district: 'q10', ratingSum: 147, ratingCount: 30, noShows: 1, lateLeaves: 0, lateCancels: 0 },
  { id: 'u-huong', displayName: 'Hương', district: 'q7', ratingSum: 44, ratingCount: 10, noShows: 0, lateLeaves: 0, lateCancels: 1 },
  { id: 'u-khoa', displayName: 'Khoa', district: 'thu-duc', ratingSum: 22, ratingCount: 5, noShows: 0, lateLeaves: 0, lateCancels: 0 },
  { id: 'u-nga', displayName: 'Nga', district: 'tan-binh', ratingSum: 0, ratingCount: 0, noShows: 0, lateLeaves: 0, lateCancels: 0 },
];
const reputation = u => {
  const raw = (u.ratingSum + 5 * 4.0) / (u.ratingCount + 5) - 0.3 * u.noShows - 0.1 * u.lateLeaves - 0.2 * u.lateCancels;
  return Math.round(Math.min(5, Math.max(1, raw)) * 10) / 10;
};
const hosts = hostsRaw.map(u => ({ ...u, rep: reputation(u) }));
const hById = Object.fromEntries(hosts.map(h => [h.id, h]));

// [sportId, format, title, venue, phút từ bây giờ, levelMin, levelMax, playersTotal, slotsNeeded, slotsFilled, costTotal, approvalMode, host, status]
const specs = [
  ['football', '7v7', 'Đá bóng sân 7', 'v-tao-dan', 90, 3, 4, 14, 3, 0, 840000, 'manual', 'u-minh', 'active'],
  ['badminton', 'doubles', 'Cầu lông đôi nam nữ', 'v-q3-cl', 150, 2, 2, 4, 2, 0, 180000, 'auto', 'u-lan', 'active'],
  ['basketball', '3x3', 'Bóng rổ 3x3', 'v-q10-bb', 240, 1, 2, 6, 3, 3, 180000, 'manual', 'u-tuan', 'active'],
  ['pickleball', 'doubles', 'Pickleball đôi giao lưu', 'v-q7-pk', 120, 1, 2, 4, 2, 1, 240000, 'auto', 'u-huong', 'active'],
  ['football', '5v5', 'Đá bóng 5 người', 'v-bt-fb', 300, 2, 3, 10, 4, 1, 600000, 'manual', 'u-minh', 'active'],
  ['tennis', 'singles', 'Tennis đánh đơn', 'v-tb-tn', 420, 3, 4, 2, 1, 0, 200000, 'manual', 'u-nga', 'active'],
  ['badminton', 'doubles', 'Cầu lông tối thứ Tư', 'v-rach-mieu', 1500, 2, 3, 4, 1, 0, 160000, 'auto', 'u-lan', 'active'],
  ['football', '5v5', 'Bóng đá sáng chủ nhật', 'v-gv-fb', 1700, 1, 2, 10, 5, 2, 500000, 'manual', 'u-khoa', 'active'],
  ['basketball', '5v5', 'Bóng rổ giao hữu', 'v-td-bd', 1800, 2, 3, 10, 4, 0, 400000, 'manual', 'u-tuan', 'active'],
  ['pickleball', 'doubles', 'Pickleball cho người mới', 'v-q7-pk', 2000, 1, 1, 4, 3, 0, 160000, 'auto', 'u-huong', 'active'],
  ['badminton', 'doubles', 'Cầu lông trình khá', 'v-td-bd', 2900, 3, 4, 4, 2, 0, 240000, 'manual', 'u-khoa', 'active'],
  ['tennis', 'doubles', 'Tennis đôi cuối tuần', 'v-tb-tn', 3200, 2, 3, 4, 2, 0, 400000, 'manual', 'u-nga', 'active'],
  ['football', '7v7', 'Đá bóng sân 7 tối thứ Bảy', 'v-bt-fb', 3400, 2, 4, 14, 4, 0, 980000, 'manual', 'u-minh', 'active'],
  ['basketball', '3x3', 'Bóng rổ 3x3 buổi chiều', 'v-q10-bb', 3600, 1, 3, 6, 2, 0, 120000, 'auto', 'u-tuan', 'active'],
  ['badminton', 'doubles', 'Cầu lông đôi hỗn hợp', 'v-q3-cl', 4300, 1, 2, 4, 2, 1, 200000, 'auto', 'u-lan', 'active'],
  ['football', '5v5', 'Bóng đá mini thứ Hai', 'v-tao-dan', 5600, 2, 3, 10, 3, 0, 700000, 'manual', 'u-minh', 'active'],
  ['pickleball', 'doubles', 'Pickleball đôi sáng sớm', 'v-q7-pk', 6900, 2, 3, 4, 2, 0, 200000, 'manual', 'u-huong', 'active'],
  ['badminton', 'doubles', 'Cầu lông đầy đủ người', 'v-rach-mieu', 200, 2, 3, 4, 2, 2, 160000, 'auto', 'u-lan', 'active'],
  ['football', '5v5', 'Kèo đã bị huỷ', 'v-gv-fb', 500, 2, 3, 10, 4, 1, 500000, 'manual', 'u-khoa', 'cancelled'],
  ['tennis', 'singles', 'Kèo bị ẩn (vi phạm)', 'v-tb-tn', 600, 1, 4, 2, 1, 0, 100000, 'manual', 'u-nga', 'hidden'],
];

const now = Date.now();
const roundHalfHour = ms => Math.ceil(ms / 1800000) * 1800000;
const batch = db.batch();
const created = Timestamp.now();

for (const v of venues) {
  batch.set(db.doc(`venues/${v.id}`), {
    name: v.name, address: v.address, district: v.district, sportIds: v.sportIds,
    geo: { geohash: ngeohash.encode(v.lat, v.lng, 9), geopoint: new GeoPoint(v.lat, v.lng) },
    createdAt: created,
  });
}
for (const h of hosts) {
  batch.set(db.doc(`users/${h.id}`), {
    displayName: h.displayName, avatarUrl: null, district: h.district, bio: null,
    sports: {}, role: 'user', banned: false, profileCompleted: true,
    stats: { ratingSum: h.ratingSum, ratingCount: h.ratingCount, matchesPlayed: h.ratingCount, noShows: h.noShows, lateLeaves: h.lateLeaves, lateCancels: h.lateCancels },
    tagCounts: {}, createdAt: created, updatedAt: created,
  });
}

specs.forEach(([sportId, format, title, venueId, mins, lMin, lMax, total, needed, filled, costTotal, approvalMode, hostId, status], i) => {
  const v = vById[venueId], h = hById[hostId];
  const start = roundHalfHour(now + mins * 60000);
  const levels = [];
  for (let l = lMin; l <= lMax; l++) levels.push(l);
  batch.set(db.doc(`matches/m-${String(i + 1).padStart(2, '0')}`), {
    hostId, host: { displayName: h.displayName, avatarUrl: null, rep: h.rep },
    title, sportId, format, playersTotal: total, slotsNeeded: needed, slotsFilled: filled, isFull: filled >= needed,
    levelMin: lMin, levelMax: lMax, levels,
    startAt: Timestamp.fromMillis(start), endAt: Timestamp.fromMillis(start + 2 * 3600000),
    venue: { venueId: v.id, name: v.name, address: v.address, district: v.district },
    geo: { geohash: ngeohash.encode(v.lat, v.lng, 9), geopoint: new GeoPoint(v.lat, v.lng) },
    district: v.district,
    costTotal, costPerPerson: Math.ceil(costTotal / total / 1000) * 1000,
    approvalMode, minReputation: null, note: null,
    status, cancelReason: status === 'cancelled' ? 'Chủ kèo bận đột xuất' : null,
    attendanceTakenAt: null, createdAt: created, updatedAt: created,
  });
});

await batch.commit();
console.log(`Đã seed ${venues.length} sân, ${hosts.length} chủ kèo, ${specs.length} kèo.`);
