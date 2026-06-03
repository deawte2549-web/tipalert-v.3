# 🎉 TipAlert — คู่มือ Deploy ฉบับสมบูรณ์

## ไฟล์ที่มีทั้งหมด

| ไฟล์ | หน้าที่ |
|---|---|
| `index.html` | Dashboard ของ Streamer (login แล้วเห็น) |
| `donate.html` | หน้าที่คนดู donate (แชร์ลิงก์นี้ให้คนดู) |
| `alert.html` | หน้าสำหรับใส่ใน OBS — alert เด้งขึ้นหน้าจอ |

---

## วิธี Deploy (ใช้ Netlify เหมือนเดิม)

1. ไปที่ **github.com** → repo ใหม่ชื่อ `tipalert`
2. อัพโหลดไฟล์ทั้ง 3 ไฟล์
3. ไปที่ **netlify.com** → Add project → เลือก repo → Deploy
4. ได้ URL เช่น `tipalert.netlify.app`

---

## วิธีใช้งานหลัง Deploy

### สตรีมเมอร์ทำ:
1. เปิด `tipalert.netlify.app` → login
2. ไป **"ช่องทางรับเงิน"** → เพิ่ม PromptPay / ธนาคาร
3. ไป **"Alert Widget"** → Copy URL ไปใส่ใน OBS
4. Copy ลิงก์ donate → แชร์ให้คนดู

### ใส่ Alert ใน OBS:
1. OBS → Sources → กด **+** → เลือก **Browser**
2. URL: `tipalert.netlify.app/alert.html?test=1`
3. Width: **1920** Height: **1080**
4. กด OK

### คนดู donate:
1. กด link ที่ streamer แชร์ → `tipalert.netlify.app/donate.html`
2. เลือกจำนวน → พิมข้อความ → เลือกช่องทาง
3. โอนเงิน → กด "โอนแล้ว"
4. ข้อความจะขึ้นหน้าจอ streamer พร้อมเสียงอ่าน

---

## Features ครบในตอนนี้

✅ Dashboard streamer สวยงาม
✅ เพิ่มช่องทางรับเงินได้ (PromptPay, TrueMoney, SCB/กสิกร/กรุงไทย/ฯลฯ)
✅ ตั้งขั้นต่ำ donation ได้
✅ หน้า Donate สวยงามสำหรับคนดู
✅ Alert เด้งขึ้นหน้าจอพร้อม animation
✅ TTS อ่านข้อความได้ทั้งไทยและอังกฤษ
✅ Confetti effect ตอน donate
✅ Premium plan modal

---

## วิธีหาเงินจากเว็บนี้

### 1. Fee 5% ต่อ Donation
- ทุก donation ที่ผ่านระบบ เก็บ 5%
- Streamer donate 1,000฿ → คุณได้ 50฿
- มี streamer 100 คน donate วันละ 500฿ = คุณได้ 2,500฿/วัน

### 2. Premium Plan 199฿/เดือน
- Custom alert design
- Custom sound
- ลด fee เหลือ 3%
- Analytics ละเอียด

### 3. B2B
- ขาย white-label ให้ agency จัดการ streamer หลายคน

---

## ขั้นตอนต่อไป (Backend จริง)

ตอนนี้เป็น Frontend-only
เพื่อให้ alert เด้งจริงแบบ real-time ต้องเพิ่ม:

1. **Supabase** — เก็บข้อมูล streamer และ donations
2. **Supabase Realtime** — ส่ง event จาก donate page → alert page
3. **PromptPay QR API** — generate QR จริง (ใช้ `promptpay-qr` npm package)

ถามได้เลยถ้าพร้อมทำ backend จริงๆ 🔥
