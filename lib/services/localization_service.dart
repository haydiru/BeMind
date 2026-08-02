import 'package:flutter/material.dart';

enum AppLanguage {
  english('en', 'English', '🇺🇸'),
  indonesian('id', 'Bahasa Indonesia', '🇮🇩'),
  spanish('es', 'Español', '🇪🇸'),
  japanese('ja', '日本語', '🇯🇵'),
  chinese('zh', '中文', '🇨🇳');

  final String code;
  final String label;
  final String flag;
  const AppLanguage(this.code, this.label, this.flag);
}

class LocalizationService {
  static final Map<AppLanguage, Map<String, String>> _localizedStrings = {
    AppLanguage.english: {
      // General & Navigation
      'app_title': 'BeMind AI',
      'nav_context_vault': 'Scripts',
      'nav_generator': 'Create AI',
      'nav_teleprompter': 'Teleprompter',
      'nav_vocab_vault': 'Vocab',
      'nav_marketplace': 'Marketplace',
      'nav_settings': 'Settings',

      // Onboarding & Auth
      'slide1_title': '100% Personal Narrative',
      'slide1_sub': 'Turn your CV & voice notes into English fluency scripts.',
      'slide2_title': 'High-Speed Teleprompter',
      'slide2_sub': 'Practice speech rhythm & build real-time speaking confidence.',
      'slide3_title': 'Passive Flashcards Engine',
      'slide3_sub': 'New vocabulary automatically delivered to your lockscreen.',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'email_label': 'Email Address',
      'email_hint': 'name@example.com',
      'password_label': 'Password',
      'password_hint': 'At least 6 characters',
      'name_label': 'Full Name',
      'name_hint': 'John Doe',
      'select_goal_title': 'Select Your Primary Focus',
      'or_continue_with': 'OR CONTINUE WITH',
      'sign_in_google': 'Sign in with Google',
      'fill_all_fields': 'Please fill in all fields!',
      'login_success': 'Welcome back, {name}! 🚀',
      'register_success': 'Account created successfully! Welcome, {name}! 🎉',

      // Context Vault
      'welcome_user': 'Hello, {name} 👋',
      'primary_focus': 'Primary Focus',
      'profile_strength': 'Profile Background Strength',
      'profile_strength_desc': 'Higher score = more personalized AI scripts',
      'create_project_btn': 'Create New Project',
      'tab_direct_text': 'Direct Text',
      'tab_voice_note': 'Voice Note',
      'tab_pdf_doc': 'PDF Document',
      'tab_camera_ocr': 'Camera OCR',
      'direct_text_hint': 'Paste your CV, career notes, or bio here...',
      'save_text_context': 'Save Text Context',
      'add_narrative': 'Add Script',
      'train_teleprompter': 'Practice',
      'edit_script': 'Edit Script',
      'delete_script': 'Delete Script',

      // Generator
      'gen_step1_title': '1. Select Main Project (Parent Folder):',
      'gen_step2_title': '2. Specific Script Title (Sub-Topic):',
      'gen_step2_sub': 'Script title to be saved inside Project "{category}"',
      'gen_title_hint': 'e.g. Leadership & STAR Method Answers',
      'target_level': 'Target English Level:',
      'tone_label': 'Speaking Tone:',
      'custom_context_label': 'Additional Instructions / Custom Context:',
      'custom_context_hint': 'Add specific key points, company names, or interview questions...',
      'generate_btn': 'Synthesize AI Script',
      'open_in_teleprompter': 'Open in Teleprompter Reader',

      // Teleprompter
      'scroll_speed': 'Scroll Speed',
      'font_size': 'Font Size',
      'mirror_mode': 'Mirror Mode',
      'lofi_music': 'Lo-Fi Ambient Beats',
      'word_click_title': 'Vocabulary Lookup',
      'add_to_vault': 'Save to Vocab Vault',

      // Vocab Vault
      'vocab_vault_title': 'Vocab Vault',
      'saved_words': '{count} vocabulary words saved',
      'search_vocab_hint': 'Search vocabulary, definition, or meaning...',
      'filter_all': 'All',
      'filter_learning': 'Learning',
      'filter_review': 'Review',
      'filter_mastered': 'Mastered',
      'flashcard_mode': 'Flashcards',
      'list_mode': 'List View',
      'add_vocab_btn': 'Add Vocabulary',

      // Marketplace
      'market_title': 'AI Prompt Template Shop',
      'market_sub': 'Choose proven script structures or publish your own prompts!',
      'search_prompt_hint': 'Search prompt templates...',
      'use_template_btn': 'Use / Remix Template',
      'publish_prompt_btn': 'Publish Prompt',

      // Settings
      'settings_title': 'Settings',
      'app_language': 'App Interface Language',
      'app_language_desc': 'Change application UI language (Target learning remains English)',
      'edit_profile': 'Edit Profile',
      'change_password': 'Change Password',
      'passive_notif_title': 'Passive Lockscreen Notifications',
      'passive_notif_desc': 'Periodically display vocabulary on your phone lockscreen',
      'active_hours': 'Active Hours Range',
      'force_sync': 'Force Offline Sync',
      'logout': 'Sign Out',
    },

    AppLanguage.indonesian: {
      'app_title': 'BeMind AI',
      'nav_context_vault': 'Naskah',
      'nav_generator': 'Buat AI',
      'nav_teleprompter': 'Teleprompter',
      'nav_vocab_vault': 'Kosakata',
      'nav_marketplace': 'Marketplace',
      'nav_settings': 'Pengaturan',

      'slide1_title': '100% Narasi Personal',
      'slide1_sub': 'Ubah CV & suaramu jadi naskah kelancaran bahasa Inggris.',
      'slide2_title': 'High-Speed Teleprompter',
      'slide2_sub': 'Latih ritme bicara & tingkatkan percaya diri real-time.',
      'slide3_title': 'Passive Flashcards Engine',
      'slide3_sub': 'Kosakata baru otomatis di lockscreen HP kamu.',
      'sign_in': 'Masuk',
      'sign_up': 'Daftar',
      'email_label': 'Alamat Email',
      'email_hint': 'nama@contoh.com',
      'password_label': 'Kata Sandi',
      'password_hint': 'Minimal 6 karakter',
      'name_label': 'Nama Lengkap',
      'name_hint': 'Nama Anda',
      'select_goal_title': 'Pilih Fokus Utama Anda',
      'or_continue_with': 'ATAU MASUK DENGAN',
      'sign_in_google': 'Masuk dengan Google',
      'fill_all_fields': 'Harap isi semua kolom!',
      'login_success': 'Selamat Datang Kembali, {name}! 🚀',
      'register_success': 'Akun berhasil dibuat! Selamat datang, {name}! 🎉',

      'welcome_user': 'Halo, {name} 👋',
      'primary_focus': 'Fokus Utama',
      'profile_strength': 'Kekuatan Profil Latar Belakang',
      'profile_strength_desc': 'Skor lebih tinggi = naskah AI lebih personal',
      'create_project_btn': 'Buat Project Baru',
      'tab_direct_text': 'Teks Langsung',
      'tab_voice_note': 'Catatan Suara',
      'tab_pdf_doc': 'Dokumen PDF',
      'tab_camera_ocr': 'Kamera OCR',
      'direct_text_hint': 'Tempelkan CV, catatan karir, atau biodata Anda di sini...',
      'save_text_context': 'Simpan Konteks Teks',
      'add_narrative': 'Tambah Narasi',
      'train_teleprompter': 'Latih',
      'edit_script': 'Edit Naskah',
      'delete_script': 'Hapus Naskah',

      'gen_step1_title': '1. Pilih Project Utama (Parent Folder):',
      'gen_step2_title': '2. Judul Spesifik Naskah Narasi (Sub-Topic):',
      'gen_step2_sub': 'Judul naskah yang disimpan dalam Project "{category}"',
      'gen_title_hint': 'Contoh: Persiapan Jawaban Leadership & STAR Method',
      'target_level': 'Target Level Bahasa Inggris:',
      'tone_label': 'Gaya Bahasa / Tone:',
      'custom_context_label': 'Instruksi Tambahan / Konteks Khusus:',
      'custom_context_hint': 'Tambahkan poin kunci spesifik, nama perusahaan, atau pertanyaan wawancara...',
      'generate_btn': 'Sintesis Naskah AI',
      'open_in_teleprompter': 'Buka di Teleprompter Reader',

      'scroll_speed': 'Kecepatan Scroll',
      'font_size': 'Ukuran Font',
      'mirror_mode': 'Mode Cermin (Mirror)',
      'lofi_music': 'Musik Latar Lo-Fi',
      'word_click_title': 'Pencarian Kosakata',
      'add_to_vault': 'Simpan ke Vocab Vault',

      'vocab_vault_title': 'Vocab Vault',
      'saved_words': '{count} kosakata tersimpan',
      'search_vocab_hint': 'Cari kosakata, definisi, atau arti...',
      'filter_all': 'Semua',
      'filter_learning': 'Dipelajari',
      'filter_review': 'Diulas',
      'filter_mastered': 'Dikuasai',
      'flashcard_mode': 'Flashcard',
      'list_mode': 'Tampilan Daftar',
      'add_vocab_btn': 'Tambah Kosakata',

      'market_title': 'Toko Template Prompt AI',
      'market_sub': 'Pilih struktur naskah favorit atau publikasikan prompt milikmu!',
      'search_prompt_hint': 'Cari template prompt...',
      'use_template_btn': 'Gunakan / Remix Template',
      'publish_prompt_btn': 'Publikasikan Prompt',

      'settings_title': 'Pengaturan',
      'app_language': 'Bahasa Tampilan Aplikasi',
      'app_language_desc': 'Ubah bahasa antarmuka aplikasi (Bahasa pembelajaran tetap Inggris)',
      'edit_profile': 'Edit Profil',
      'change_password': 'Ubah Kata Sandi',
      'passive_notif_title': 'Notifikasi Pasif Lockscreen',
      'passive_notif_desc': 'Tampilkan kosakata secara berkala di layar terkunci HP',
      'active_hours': 'Rentang Jam Aktif',
      'force_sync': 'Paksa Sinkronisasi',
      'logout': 'Keluar',
    },

    AppLanguage.spanish: {
      'app_title': 'BeMind AI',
      'nav_context_vault': 'Guiones',
      'nav_generator': 'Crear AI',
      'nav_teleprompter': 'Teleprompter',
      'nav_vocab_vault': 'Vocabulario',
      'nav_marketplace': 'Mercado',
      'nav_settings': 'Ajustes',

      'welcome_user': 'Hola, {name} 👋',
      'primary_focus': 'Enfoque Principal',
      'profile_strength': 'Fuerza de Perfil',
      'create_project_btn': 'Crear Nuevo Proyecto',
      'settings_title': 'Ajustes',
      'app_language': 'Idioma de la Interfaz',
      'app_language_desc': 'Cambiar idioma de la aplicación (El aprendizaje sigue siendo en inglés)',
      'logout': 'Cerrar Sesión',
    },

    AppLanguage.japanese: {
      'app_title': 'BeMind AI',
      'nav_context_vault': 'スクリプト',
      'nav_generator': 'AI生成',
      'nav_teleprompter': 'プロンプター',
      'nav_vocab_vault': '単語帳',
      'nav_marketplace': 'マーケット',
      'nav_settings': '設定',

      'welcome_user': 'こんにちは、{name} 👋',
      'primary_focus': '主な目標',
      'profile_strength': 'プロフィール完成度',
      'create_project_btn': '新規プロジェクト',
      'settings_title': '設定',
      'app_language': 'アプリ表示言語',
      'app_language_desc': 'UI言語を変更（学習対象は英語のままです）',
      'logout': 'ログアウト',
    },

    AppLanguage.chinese: {
      'app_title': 'BeMind AI',
      'nav_context_vault': '剧本库',
      'nav_generator': 'AI生成',
      'nav_teleprompter': '提词器',
      'nav_vocab_vault': '词汇库',
      'nav_marketplace': '提示词集市',
      'nav_settings': '设置',

      'welcome_user': '你好，{name} 👋',
      'primary_focus': '核心目标',
      'profile_strength': '个人资料强度',
      'create_project_btn': '创建新项目',
      'settings_title': '设置',
      'app_language': '应用界面语言',
      'app_language_desc': '切换应用UI语言（英语学习内容保持不变）',
      'logout': '退出登录',
    },
  };

  static String tr(AppLanguage lang, String key, {Map<String, String>? args}) {
    final map = _localizedStrings[lang] ?? _localizedStrings[AppLanguage.english]!;
    String val = map[key] ?? _localizedStrings[AppLanguage.english]?[key] ?? key;
    if (args != null) {
      args.forEach((k, v) {
        val = val.replaceAll('{$k}', v);
      });
    }
    return val;
  }
}
