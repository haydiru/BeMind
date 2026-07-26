import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static const String url = 'https://vuttrtiqscjviedfwodd.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ1dHRydGlxc2NqdmllZGZ3b2RkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ5MjQ0MzEsImV4cCI6MjEwMDUwMDQzMX0.NTvxDP6ZJydfX2_75fueq92_W92T71CxAp2_KnChu-c';
  
  // Production Backend API (Vercel Serverless 24/7 Cloud API)
  static String get backendBaseUrl => 'https://be-mind.vercel.app/api';
}

