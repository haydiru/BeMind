import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
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
      theme: AppTheme.darkTheme,
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

    // Array of the 7 main application pages
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
