# 🔄 AGENT TASK BOARD 2: IN PROGRESS (TASK SEDANG DIKERJAKAN)

> **Aturan Alur Kerja Agent (Workflow Rules):**
> 1. Hanya ada **1 TASK AKTIF** di dalam file ini dalam satu waktu untuk mencegah kebingungan konteks.
> 2. Task ini diambil secara berurutan dari `01_TASKS_TODO.md` atau ditambahkan langsung berdasarkan permintaan pengguna.
> 3. Dokumen ini memuat Rencana Pelaksanaan (*Implementation Plan*), kriteria verifikasi, dan progress detail pengerjaan.
> 4. Setelah task selesai dikerjakan dan diverifikasi (melalui `flutter analyze` / build test), **pindahkan task ini ke file `03_TASKS_DONE.md`**.

---

## ⚡ CURRENT ACTIVE TASK

### 📌 TASK BE-03: Passive Notification Engine & Background Scheduler (`lib/services/notification_service.dart`)
- **Status:** 🟡 **IN PROGRESS**
- **Tanggal Mulai:** 2026-08-02
- **Penanggung Jawab:** Agent Antigravity

#### 📝 Deskripsi Task:
Verifikasi dan penyempurnaan `NotificationService` untuk pengiriman notifikasi pasif kosakata di lockscreen (pemilih acak berbasis prioritas status `Learning`/`Review`, inisialisasi Android channel `bemind_passive_learning`, dan request permission Android 13+).

#### 🎯 Sub-Steps & Progress Checklist:
- [x] Memverifikasi inisialisasi `FlutterLocalNotificationsPlugin`.
- [x] Memverifikasi permintaan izin `Permission.notification.request()`.
- [x] Memverifikasi filter prioritas kata `masteryStatus == learning || review`.
- [x] Memverifikasi format judul dan isi `BigTextStyleInformation` notifikasi pasif.
- [x] Jalankan `flutter analyze` untuk verifikasi tanpa error.

#### 🛠️ Target Files Modified:
- [lib/services/notification_service.dart](file:///d:/Website/BeMind/lib/services/notification_service.dart)
- [01_TASKS_TODO.md](file:///d:/Website/BeMind/01_TASKS_TODO.md)
- [02_TASKS_IN_PROGRESS.md](file:///d:/Website/BeMind/02_TASKS_IN_PROGRESS.md)
- [03_TASKS_DONE.md](file:///d:/Website/BeMind/03_TASKS_DONE.md)
