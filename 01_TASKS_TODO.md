# 📋 AGENT TASK BOARD 1: TODO TASKS (DAFTAR TASK BELUM DIKERJAKAN)

> **Aturan Alur Kerja Agent (Workflow Rules):**
> 1. Task dalam dokumen ini adalah daftar pekerjaan yang **belum dikerjakan**.
> 2. Setiap task dikelompokkan secara bertahap (**Phase-Based**): **Frontend (UI/UX) -> Backend & Services -> Database & Persistence -> Optimization & Release**.
> 3. **Batasan Konteks:** Setiap task Frontend maksimal hanya mencakup **1 Halaman (Page)**. Jika suatu halaman memiliki fitur yang sangat banyak, task dipecah menjadi **Part 1** dan **Part 2** agar konteks LLM/Agent tetap ringan dan hasil 100% akurat.
> 4. Saat hendak menggerjakan suatu task, **pindahkan task tersebut dari file ini (`01_TASKS_TODO.md`) ke file `02_TASKS_IN_PROGRESS.md`**.

---

## 🎨 PHASE 1: FRONTEND UI/UX (Halaman per Halaman)
*(Seluruh 7 Halaman Utama Frontend UI/UX Telah Selesai 100%)*

---

## ⚙️ PHASE 2: BACKEND & SERVICES
*(Seluruh Backend Services Telah Selesai 100%)*

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
