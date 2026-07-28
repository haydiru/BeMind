import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';
import 'pages/onboarding_auth_page.dart';
import 'pages/context_vault_page.dart';
import 'pages/generate_essay_page.dart';
import 'pages/teleprompter_page.dart';
import 'pages/vocab_vault_page.dart';
import 'pages/marketplace_page.dart';
import 'pages/settings_page.dart';
import 'services/notification_service.dart';
import 'services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize Local Notifications Service
  await NotificationService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final provider = AppProvider();
        
        // Auto Restore Auth Session if Supabase already has an active session
        final session = Supabase.instance.client.auth.currentSession;
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (session != null && currentUser != null) {
          final userName = currentUser.userMetadata?['name'] ??
              currentUser.userMetadata?['full_name'] ??
              currentUser.email?.split('@').first ??
              'User';
          final targetGoal = currentUser.userMetadata?['target_goal'] ?? 'Job Interview Prep';
          
          provider.loginWithProfile(
            id: currentUser.id,
            name: userName,
            email: currentUser.email ?? '',
            targetGoal: targetGoal,
          );
        }

        // Listen for Auth Changes (Login/Logout/OAuth)
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
          final AuthChangeEvent event = data.event;
          final Session? sess = data.session;
          if (event == AuthChangeEvent.signedIn && sess?.user != null) {
            final u = sess!.user;
            final name = u.userMetadata?['name'] ?? u.email?.split('@').first ?? 'User';
            final goal = u.userMetadata?['target_goal'] ?? 'Job Interview Prep';
            provider.loginWithProfile(
              id: u.id,
              name: name,
              email: u.email ?? '',
              targetGoal: goal,
            );
          } else if (event == AuthChangeEvent.signedOut && provider.isLoggedIn) {
            provider.logout();
          }
        });

        return provider;
      },
      child: const BeMindApp(),
    ),
  );
}

class BeMindApp extends StatelessWidget {
  const BeMindApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeMind — AI-Native English Fluency Builder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreenShell(),
    );
  }
}

class MainScreenShell extends StatelessWidget {
  const MainScreenShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // If logged out, render Onboarding & Auth Page
    if (!provider.isLoggedIn) {
      return const OnboardingAuthPage();
    }

    // Array of the 6 main application pages
    final List<Widget> pages = const [
      ContextVaultPage(),   // Page 0: Context Vault
      GenerateEssayPage(),  // Page 1: AI Generator
      TeleprompterPage(),   // Page 2: Teleprompter Reader
      VocabVaultPage(),     // Page 3: Vocabulary Vault
      MarketplacePage(),    // Page 4: Community Marketplace
      SettingsPage(),       // Page 5: Settings & Lockscreen Simulator
    ];

    return Scaffold(
      body: IndexedStack(
        index: provider.currentPageIndex.clamp(0, pages.length - 1),
        children: pages,
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
