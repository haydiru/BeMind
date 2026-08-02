# 🧠 BeMind — AI-Native Personalized English Fluency Builder

<p align="center">
  <img src="assets/icon/app_logo.png" alt="BeMind Logo" width="120" style="border-radius: 24px;" />
</p>

**BeMind** adalah aplikasi mobile pelancar bahasa Inggris (*English Fluency Builder*) berbasis **AI-Native** yang menggabungkan *Multi-Modal Personalization Engine*, *Narrator Teleprompter Reading Engine*, *Interactive Vocabulary Extraction*, *Crowdsourced Prompt Template Marketplace* ("Canva for Prompts"), dan *On-Device Passive Lockscreen Notification*.

---

## 📌 Masalah Utama & Solusi

- **Masalah:** Banyak pengguna kesulitan lancar berbicara dan menghafal kosakata bahasa Inggris karena materi pembelajaran konvensional terlalu umum, kaku, dan tidak relevan dengan kehidupan pribadi atau karir mereka.
- **Solusi BeMind:** Mengubah latar belakang pribadi pengguna (CV/Resume, rekaman suara cerita, dokumen PDF, atau foto catatan) menjadi **naskah narasi bahasa Inggris yang 100% personal dan kontekstual**. Naskah tersebut kemudian dilatih melalui mode **Teleprompter** berkecepatan tinggi (60–300 WPM) dan diperkuat dengan pengulangan pasif di *lockscreen*.

---

## 📱 Ringkasan 7 Halaman Utama & Fitur Aplikasi

Aplikasi BeMind terdiri dari 7 halaman utama yang saling terintegrasi:

| No | Halaman | Deskripsi Fitur Utama |
| :--- | :--- | :--- |
| 1 | **Onboarding & Auth** (`/onboarding`) | Carousel ilustrasi fitur, pemilih fokus belajar (*Job Interview, IELTS, Pitching, Conversation*), serta form Login & Registrasi terintegrasi Supabase Auth. |
| 2 | **Personal Context Vault** (`/context-vault`) | Pusat pengelolaan data pribadi pengguna dengan 4 modul input: Direct Text, Voice Note Extractor (Whisper API), PDF Document Uploader, dan Camera OCR Scanner. |
| 3 | **AI Narrative Generator** (`/generate-essay`) | Generator narasi AI dengan pemilih Project Utama (Parent Folder), judul sub-topik spesifik, slider *Target English Level* (A2–C2), pilihan *Tone*, Speech-To-Text voice prompt, dan pratinjau naskah rilis. |
| 4 | **Teleprompter Reader** (`/teleprompter`) | Engine pembaca layar penuh berkecepatan 60–120 FPS (60–300 WPM), slider kecepatan & font, mirror text mode (rig kaca prompter), pemutar lagu latar (*Lo-Fi & Ambient Beats*), serta interaksi ketuk kata asing untuk popup fonetik & terjemahan. |
| 5 | **Personal Vocabulary Vault** (`/vocab-vault`) | Bank kosakata hasil ekstraksi dari teleprompter. Dilengkapi audio Text-To-Speech (TTS), filter status penguasaan (*Learning, Review, Mastered*), pencarian instan, dan mode *Flashcard Flip*. |
| 6 | **Prompt Marketplace** (`/marketplace`) | Pusat komunitas ("Canva for Prompts") untuk mencari, membagikan, dan meng-remix template prompt AI ciptaan pengguna lain beserta sampel outputnya. |
| 7 | **Settings & Notifications** (`/settings`) | Manajemen profil akun, ubah password, toggle notifikasi kosakata pasif di lockscreen, kustomisasi interval jadwal & jam aktif notifikasi, serta sinkronisasi data offline. |

---

## 🛠️ Arsitektur Teknis & Teknologi

- **Framework Core:** [Flutter 3.x](https://flutter.dev/) (Dart 3.x) — Menjamin animasi GUI teleprompter super mulus di 60–120 FPS.
- **State Management:** Provider Architecture (`AppProvider`).
- **Backend & Cloud Services:**
  - **Supabase Auth:** Autentikasi email/password & manajemen sesi terenkripsi.
  - **Supabase PostgreSQL Database:** Tabel `profiles`, `user_contexts`, `generated_essays`, `vocabularies`, dan `prompt_templates`.
  - **Row Level Security (RLS):** Menjamin keamanan isolasi data antar pengguna.
- **AI Synthesizer Engine:** Vercel Edge Proxy / OpenRouter / DeepSeek / Gemini 1.5 Flash API dengan fallback pipeline.
- **Multi-Modal Extractors:**
  - Speech-To-Text Continuous Engine (`speech_to_text`).
  - Document Text Reader (`pdf_text` / `file_picker`).
  - Text Recognition OCR (`google_mlkit_text_recognition`).
- **Android Native Optimizations:**
  - **Super-Light Release APK (~34.2 MB):** Native C++ symbol stripping pada `libflutter.so`.
  - **Android Adaptive Icons (`mipmap-anydpi-v26`):** Logo aplikasi 100% bulat sempurna di launcher Android 8.0+ (MIUI, HyperOS, Stock, Samsung).

---

## 📋 Agent Task Management Protocol (3-Board System)

Untuk menjaga kualitas pengembangan aplikasi yang terukur, akurat, dan hemat *context window*, alur pekerjaan AI diatur melalui 3 file Task Board di repositori:

1. 📄 **[`01_TASKS_TODO.md`](file:///d:/Website/BeMind/01_TASKS_TODO.md)**: Daftar task yang belum dikerjakan, diurutkan secara bertahap (**Phase 1 Frontend (max 1 page/task)** -> **Phase 2 Backend** -> **Phase 3 Database** -> **Phase 4 Release**).
2. 🔄 **[`02_TASKS_IN_PROGRESS.md`](file:///d:/Website/BeMind/02_TASKS_IN_PROGRESS.md)**: Memuat **hanya 1 task aktif** yang sedang dikerjakan secara detail.
3. ✅ **[`03_TASKS_DONE.md`](file:///d:/Website/BeMind/03_TASKS_DONE.md)**: Log dokumentasi task yang telah selesai dikerjakan, diuji, dan di-commit ke Git.

```
[01_TASKS_TODO.md]  ──(Ambil 1 Task)──>  [02_TASKS_IN_PROGRESS.md]  ──(Selesai & Test)──>  [03_TASKS_DONE.md]
```

---

## 💻 Panduan Jalankan & Kompilasi Project

### 1. Prasyarat Sistem
- Flutter SDK (v3.22.0 atau lebih baru)
- Android SDK / Android Studio (untuk build Android)
- JDK 17+

### 2. Install Dependensi
```bash
flutter pub get
```

### 3. Jalankan Aplikasi di Mode Dev
```bash
flutter run
```

### 4. Kompilasi APK Release Hemat (~34.2 MB)
```bash
flutter build apk --release --split-per-abi
```
File APK rilis ARM64 akan dihasilkan di:  
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

## 📄 Lisensi & Hak Cipta
© 2026 **BeMind App Team**. Hak cipta dilindungi undang-undang.
