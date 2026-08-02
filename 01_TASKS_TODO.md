# 📋 AGENT TASK BOARD 1: TODO TASKS (DAFTAR TASK BELUM DIKERJAKAN)

> **Aturan Alur Kerja Agent (Workflow Rules):**
> 1. Task dalam dokumen ini adalah daftar pekerjaan yang **belum dikerjakan**.
> 2. Setiap task dikelompokkan secara bertahap (**Phase-Based**): **Frontend (UI/UX) -> Backend & Services -> Database & Persistence -> Optimization & Release**.
> 3. **Batasan Konteks:** Setiap task Frontend maksimal hanya mencakup **1 Halaman (Page)**. Jika suatu halaman memiliki fitur yang sangat banyak, task dipecah menjadi **Part 1** dan **Part 2** agar konteks LLM/Agent tetap ringan dan hasil 100% akurat.
> 4. Saat hendak menggerjakan suatu task, **pindahkan task tersebut dari file ini (`01_TASKS_TODO.md`) ke file `02_TASKS_IN_PROGRESS.md`**.

---

## 🎨 PHASE 1: FRONTEND UI/UX (Halaman per Halaman)

### 📌 TASK FE-01: Page 1 — Onboarding & Auth Screen UI (`lib/pages/onboarding_auth_page.dart`)
- [ ] **Deskripsi:** Antarmuka pengenalan aplikasi (Onboarding Carousel) dan autentikasi pengguna (Login & Registrasi).
- [ ] **Komponen Visual & Layout:**
  - Onboarding slideshow interaktif (3 kartu ilustrasi fitur utama: AI Custom Narrative, Teleprompter Practice, Lockscreen Vocabulary).
  - Form Tab switcher (Masuk vs Daftar).
  - Kartu pemilih fokus belajar utama (*Job Interview, IELTS/TOEFL, Business Pitching, Casual Conversation*).
- [ ] **Fitur & Kontrol Detail:**
  - Input field Email & Password dengan *toggle show/hide password*.
  - Validation feedback (email format check, password minimal 6 karakter).
  - Tombol Social Auth UI (*Sign in with Google*, *Sign in with Apple*).
  - Loading spinner state & error snackbar notification.
- [ ] **Target File:** [onboarding_auth_page.dart](file:///d:/Website/BeMind/lib/pages/onboarding_auth_page.dart)

---

### 📌 TASK FE-02: Page 2 — Personal Context Vault UI (Part 1: Header & Direct Text) (`lib/pages/context_vault_page.dart`)
- [ ] **Deskripsi:** Bagian atas dan tab pertama dari halaman pengelola data latar belakang pribadi pengguna.
- [ ] **Komponen Visual & Layout:**
  - Header bar dengan nama user, avatar initial, dan target goal badge.
  - Kartu performa "Profile Background Strength" dengan skor persentase kelengkapan profil (*Profile Completeness*).
  - TabBar 4 metode input (Teks, Suara, PDF, OCR Camera Scan).
- [ ] **Fitur & Kontrol Detail:**
  - Tab 1 Direct Text Input: Textarea besar untuk copy-paste CV, catatan karir, atau biodata pribadi.
  - Auto-draft save indicator dan penghitung jumlah karakter.
  - Tombol "Simpan Konteks Teks".
- [ ] **Target File:** [context_vault_page.dart](file:///d:/Website/BeMind/lib/pages/context_vault_page.dart)

---

### 📌 TASK FE-03: Page 2 — Personal Context Vault UI (Part 2: Multi-Modal Extractors) (`lib/pages/context_vault_page.dart`)
- [ ] **Deskripsi:** Tab 2, 3, dan 4 untuk ekstraksi multi-modal (Voice, PDF, OCR Scanner).
- [ ] **Komponen Visual & Layout:**
  - Tab 2 Voice Note: Tombol rekam suara Hold/Tap-to-Record, visualisasi gelombang suara (*waveform bar simulation*), dan pemutar ulang audio.
  - Tab 3 PDF Uploader: Kontainer drag-and-drop file picker dengan pratinjau teks hasil ekstraksi dokumen CV/resume.
  - Tab 4 Camera OCR: Viewfinder kamera dengan framing overlay dan dialog hasil pembacaan teks fisik.
- [ ] **Fitur & Kontrol Detail:**
  - Integrasi UI state rekam suara (Recording, Processing, Playback).
  - Opsi hapus/unggah ulang file PDF dan foto OCR.
  - List kartu histori konteks yang telah diunggah sebelumnya.
- [ ] **Target File:** [context_vault_page.dart](file:///d:/Website/BeMind/lib/pages/context_vault_page.dart)

---

### 📌 TASK FE-04: Page 3 — AI Narrative Generator UI (Part 1: Setup & Parameter) (`lib/pages/generate_essay_page.dart`)
- [ ] **Deskripsi:** Form langkah 1 pengaturan kategori project dan parameter generasi AI.
- [ ] **Komponen Visual & Layout:**
  - Seksi 1: Pemilih Project Utama / Parent Folder (`ChoiceChip` dengan ikon folder bersih tanpa checkmark overlap).
  - Seksi 2: Form input Judul Spesifik Sub-Topik Naskah Narasi dengan teks pembimbing.
  - Card Slider penyesuaian *Target English Level* (`A2`, `B1`, `B2`, `C1`, `C2`).
  - Chip selector *Gaya Bahasa / Tone* (`Professional`, `Conversational`, `Academic`).
- [ ] **Fitur & Kontrol Detail:**
  - Validasi form sebelum memicu pembentukan narasi.
  - Banner peringatan jika belum memilih project utama atau judul sub-topik masih kosong.
- [ ] **Target File:** [generate_essay_page.dart](file:///d:/Website/BeMind/lib/pages/generate_essay_page.dart)

---

### 📌 TASK FE-05: Page 3 — AI Narrative Generator UI (Part 2: Context Input & Output Preview) (`lib/pages/generate_essay_page.dart`)
- [ ] **Deskripsi:** Seksi input konteks tambahan, pemicu AI Synthesizer, dan pratinjau hasil naskah.
- [ ] **Komponen Visual & Layout:**
  - Textarea instruksi khusus / bahan latihan tambahan.
  - Modul Speech-to-Text voice prompt dengan tombol rekam, transkripsi langsung secara *real-time*, dan toggle bahasa (`en_US` / `id_ID`).
  - Modul lampiran dokumen/file.
  - Banner indikator jika menggunakan *Marketplace Prompt Template*.
  - Pratinjau hasil naskah dengan statistik jumlah kata dan perkiraan durasi membaca teleprompter.
- [ ] **Fitur & Kontrol Detail:**
  - Overlay loading animasi skeleton saat generasi AI berlangsung.
  - Tombol aksi: "Salin Teks", "Simpan ke Project", dan "Latih di Teleprompter".
- [ ] **Target File:** [generate_essay_page.dart](file:///d:/Website/BeMind/lib/pages/generate_essay_page.dart)

---

### 📌 TASK FE-06: Page 4 — Teleprompter Reader UI (`lib/pages/teleprompter_page.dart`)
- [ ] **Deskripsi:** Halaman mode layar penuh pembaca teleprompter interaktif dengan auto-scroll dan penyesuaian kecepatan.
- [ ] **Komponen Visual & Layout:**
  - Fullscreen high-contrast reader canvas dengan pilihan warna latar (Dark/Light/Green Prompter).
  - Floating 3D Control Bar di bagian bawah (Play/Pause, Reset, Slider Kecepatan WPM).
  - Drawer / Modal pemilih naskah latihan antar project.
- [ ] **Fitur & Kontrol Detail:**
  - Engine auto-scrolling 60–120 FPS berkecepatan 60–300 WPM.
  - Slider ukuran font teks & toggle perataan teks (Kiri / Tengah).
  - Toggle *Mirror Text Mode* untuk penggunaan pada rig kaca teleprompter fisik.
  - Pemutar audio latar (*Lo-Fi Beats & Ambient Ambiance*) dengan kontrol volume.
  - Interactive Word Click Popup: Mengetuk kata asing langsung menghentikan scroll sementara dan menampilkan fonetik & arti kata.
- [ ] **Target File:** [teleprompter_page.dart](file:///d:/Website/BeMind/lib/pages/teleprompter_page.dart)

---

### 📌 TASK FE-07: Page 5 — Personal Vocabulary Vault UI (`lib/pages/vocab_vault_page.dart`)
- [ ] **Deskripsi:** Halaman pengelola bank kosakata hasil ekstraksi dari latihan teleprompter.
- [ ] **Komponen Visual & Layout:**
  - Header bar dengan pencarian kosakata instan.
  - Filter chips status penguasaan (*Semua, Learning, Review, Mastered*).
  - Kartu daftar kosakata: Menampilkan Kata, Fonetik, Definisi Bahasa Inggris, Contoh Kalimat Konteks, dan Arti Bahasa Indonesia.
- [ ] **Fitur & Kontrol Detail:**
  - Tombol audio Text-To-Speech (TTS) untuk mendengarkan pengucapan kata.
  - Mode *Flashcard Flip* interaktif untuk pengujian ingatan mandiri.
  - Dialog tambah kosakata baru secara manual dengan fitur auto-fill AI.
  - Aksi usap (*Swipe-to-delete*) untuk menghapus kata dari vault.
- [ ] **Target File:** [vocab_vault_page.dart](file:///d:/Website/BeMind/lib/pages/vocab_vault_page.dart)

---

### 📌 TASK FE-08: Page 6 — Community Prompt Marketplace UI ("Canva for Prompts") (`lib/pages/marketplace_page.dart`)
- [ ] **Deskripsi:** Pusat berbagi dan remix template prompt AI dari komunitas.
- [ ] **Komponen Visual & Layout:**
  - Banner promosi *Template of the Week*.
  - Bilah pencarian template dan filter kategori (*Job Interview, IELTS, Business Pitch, Conversation*).
  - Kartu template prompt: Menampilkan nama pembuat, rating, jumlah kali di-remix, dan deskripsi.
- [ ] **Fitur & Kontrol Detail:**
  - Tombol **"Gunakan / Remix Template"**: Otomatis membawa template ke `GenerateEssayPage` dan menginjeksi data konteks pengguna.
  - Modal form **"Publikasikan Prompt Baru"** bagi creator untuk mengunggah template ciptaan sendiri.
- [ ] **Target File:** [marketplace_page.dart](file:///d:/Website/BeMind/lib/pages/marketplace_page.dart)

---

### 📌 TASK FE-09: Page 7 — Settings & Notification Manager UI (`lib/pages/settings_page.dart`)
- [ ] **Deskripsi:** Halaman pengaturan akun, kustomisasi notifikasi pasif, dan pemeliharaan data.
- [ ] **Komponen Visual & Layout:**
  - Kartu profil user dengan indikator persentase kelengkapan akun.
  - Opsi Pengaturan Akun, Notifikasi, dan Sinkronisasi Data.
- [ ] **Fitur & Kontrol Detail:**
  - Dialog Edit Nama & Target Utama.
  - Dialog Ubah Kata Sandi (Password).
  - Toggle Notifikasi Kosakata Pasif di Lockscreen.
  - Pemilih frekuensi notifikasi (3x sehari, 5x sehari, Setiap jam).
  - Time Picker jam aktif notifikasi (misal: 08:00 - 21:00).
  - Tombol Paksa Sinkronisasi Data ke Supabase.
  - Tombol Logout.
- [ ] **Target File:** [settings_page.dart](file:///d:/Website/BeMind/lib/pages/settings_page.dart)

---

## ⚙️ PHASE 2: BACKEND & SERVICES

### 📌 TASK BE-01: Supabase Authentication Service & Session Control (`lib/services/`)
- [ ] **Deskripsi:** Layanan autentikasi pengguna dan penanganan sesi terhubung ke Supabase Auth.
- [ ] **Fitur Detail:**
  - Handler Login, Register, Logout, dan Reset Password.
  - Pemulihan sesi otomatis saat aplikasi dibuka kembali.
  - Pemicu pembuat baris profil otomatis pada tabel `profiles` saat user mendaftar.
- [ ] **Target File:** [supabase_config.dart](file:///d:/Website/BeMind/lib/services/supabase_config.dart) & [app_provider.dart](file:///d:/Website/BeMind/lib/providers/app_provider.dart)

---

### 📌 TASK BE-02: AI Narrative Generation Engine & LLM Pipeline (`lib/services/api_service.dart`)
- [ ] **Deskripsi:** Pipeline panggilan API AI untuk meracik narasi personal berdasarkan data pengguna.
- [ ] **Fitur Detail:**
  - Kombinasi konteks pengguna + struktur kategori + prompt template marketplace.
  - Provider fallback multi-LLM (Gemini 1.5 Flash / OpenRouter / Vercel Edge proxy).
  - Parsing JSON/Markdown jawaban AI dan penanganan kegagalan koneksi (*retry policy*).
- [ ] **Target File:** [api_service.dart](file:///d:/Website/BeMind/lib/services/api_service.dart)

---

### 📌 TASK BE-03: Passive Notification Engine & Background Scheduler (`lib/services/notification_service.dart`)
- [ ] **Deskripsi:** Layanan notifikasi lokal di latar belakang untuk pembelajaran pasif kosakata di lockscreen.
- [ ] **Fitur Detail:**
  - Konfigurasi `flutter_local_notifications` untuk Android & iOS.
  - Pemicu berkala mengambil kata acak dari database kosakata pengguna.
  - Enforce batasan jam aktif (misal hanya memunculkan notifikasi antara 08:00 - 21:00).
- [ ] **Target File:** [notification_service.dart](file:///d:/Website/BeMind/lib/services/notification_service.dart)

---

## 🗄️ PHASE 3: DATABASE & PERSISTENCE

### 📌 TASK DB-01: Supabase PostgreSQL Database Schemas & RLS Security (`backend/supabase/`)
- [ ] **Deskripsi:** Definisi tabel PostgreSQL dan aturan keamanan Row Level Security (RLS) pada Supabase.
- [ ] **Fitur Detail:**
  - Schema tabel `profiles`, `user_contexts`, `generated_essays`, `vocabularies`, dan `prompt_templates`.
  - Aturan RLS memastikan user hanya bisa membaca/menulis datanya sendiri.
  - Indeks B-Tree pada kolom `user_id`, `category`, dan `mastery_status` untuk performa query cepat.
- [ ] **Target Directory:** `backend/supabase/`

---

### 📌 TASK DB-02: Local Offline Persistence & Synchronization (`lib/providers/app_provider.dart`)
- [ ] **Deskripsi:** Penyimpanan data lokal pada perangkat untuk akses instan tanpa internet dan sinkronisasi ke cloud.
- [ ] **Fitur Detail:**
  - Penyimpanan cache lokal untuk naskah, kosakata, konteks, dan pengaturan.
  - Strategi *Offline-First*: Membaca data lokal terlebih dahulu, lalu menyinkronkan perubahan ke Supabase saat terhubung internet.
- [ ] **Target File:** [app_provider.dart](file:///d:/Website/BeMind/lib/providers/app_provider.dart)

---

## 🚀 PHASE 4: OPTIMIZATION, TESTING & RELEASE

### 📌 TASK OPT-01: Multi-Arch Release Build Pipeline & ProGuard
- [ ] **Deskripsi:** Pembuatan biner rilis terpisah untuk setiap arsitektur HP Android (`arm64-v8a`, `armeabi-v7a`, `x86_64`).
- [ ] **Fitur Detail:**
  - Skrip kompilasi `flutter build apk --release --split-per-abi`.
  - Verifikasi ukuran APK rilis tetap hemat (~34 MB).
- [ ] **Target Command:** `flutter build apk --release --split-per-abi`
