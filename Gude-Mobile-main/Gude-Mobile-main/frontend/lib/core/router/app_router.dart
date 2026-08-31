// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gude_app/features/wallet/presentation/screens/transact_screen.dart';
import 'package:gude_app/features/onboarding/feature_onboarding_page.dart';
// Auth
import 'package:gude_app/features/auth/presentation/splash_page.dart';
import 'package:gude_app/features/auth/presentation/onboarding_page.dart';
import 'package:gude_app/features/auth/presentation/login_page.dart';
import 'package:gude_app/features/auth/presentation/signup_page.dart';
import 'package:gude_app/features/auth/presentation/forgot_password_page.dart';
import 'package:gude_app/features/auth/presentation/skills_selection_page.dart';
import 'package:gude_app/features/auth/presentation/student_verification_page.dart';
import 'package:gude_app/features/messaging/presentation/unified_chat_page.dart';

// Buyer onboarding — import each page from its own dedicated file.
// Hide ALL onboarding pages from buyer_onboarding_welcome_page.dart so there
// are no duplicate-symbol conflicts.
import 'package:gude_app/features/auth/presentation/buyer_onboarding_welcome_page.dart'
    hide
        BuyerTypePage,
        BuyerInterestsPage,
        BuyerProfileSetupPage,
        BuyerOnboardingCompletePage;

// Marketplace
import 'package:gude_app/features/marketplace/presentation/marketplace_page.dart';
import 'package:gude_app/features/marketplace/presentation/listing_detail_page.dart';
import 'package:gude_app/features/marketplace/presentation/create_listing_page.dart';
import 'package:gude_app/features/marketplace/presentation/hire_student_page.dart';
import 'package:gude_app/features/marketplace/presentation/job_dashboard_page.dart';

// Notifications & Wishlist
import 'package:gude_app/features/marketplace/presentation/notifications_page.dart'
    hide WishlistPage;
import 'package:gude_app/features/marketplace/presentation/wishlist_page.dart'
    hide NotificationsPage;

// Wallet
import 'package:gude_app/features/wallet/presentation/wallet_page.dart';
import 'package:gude_app/features/wallet/presentation/wallet_pockets_page.dart';
import 'package:gude_app/features/wallet/presentation/budget_planner_page.dart';
import 'package:gude_app/features/wallet/presentation/savings_goals_page.dart';
import 'package:gude_app/features/wallet/presentation/screens/send_money_screen.dart'
    hide ReceivedMoneyScreen;
import 'package:gude_app/features/wallet/presentation/screens/withdraw_screen.dart';
import 'package:gude_app/features/wallet/presentation/screens/received_money_screen.dart';
import 'package:gude_app/features/wallet/presentation/screens/transactions_screen.dart';

// Other features
import 'package:gude_app/features/stability/presentation/stability_page.dart';
import 'package:gude_app/features/stability/presentation/weekly_checkin_page.dart';
import 'package:gude_app/features/support_hub/presentation/support_page.dart';
import 'package:gude_app/features/home/presentation/home_page.dart';
import 'package:gude_app/features/profile/presentation/profile_page.dart';
import 'package:gude_app/features/community/presentation/community_chat_page.dart';
import 'package:gude_app/features/community/presentation/notice_board_page.dart';

// ── NEW: Coach, Rewards, Challenges, Notifications ──────────────────────────
import 'package:gude_app/features/coach/presentation/coach_onboarding_page.dart';
import 'package:gude_app/features/coach/presentation/coach_chat_page.dart';
import 'package:gude_app/features/rewards/presentation/rewards_page.dart';
import 'package:gude_app/features/challenges/presentation/challenges_page.dart';
import 'package:gude_app/features/notifications/presentation/notifications_page.dart'
    hide NotificationsPage; // keep marketplace one under /notifications
// We alias the new one:
import 'package:gude_app/features/notifications/presentation/notifications_page.dart'
    as nudge_notif;

// ── Buyer Features ─────────────────────────────────────────────────
import 'package:gude_app/features/buyer/presentation/buyer_messages_page.dart'
    hide BuyerNavShell;
import 'package:gude_app/features/buyer/presentation/buyer_profile_page.dart';

// Institution
import 'package:gude_app/features/institution/presentation/institution_marketplace_page.dart';
import 'package:gude_app/features/institution/presentation/institution_profile_page.dart';

// Shared Shells
import 'package:gude_app/shared/widgets/bottom_nav_shell.dart';
import 'package:gude_app/shared/widgets/institution_nav_shell.dart';
import 'package:gude_app/shared/widgets/buyer_nav_shell.dart'
    hide BuyerMessagesPage;

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ── Auth & onboarding ──────────────────────────────────────────
      GoRoute(path: '/splash', builder: (c, s) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),
      GoRoute(
        path: '/onboarding-features',
        builder: (_, __) => const FeatureOnboardingPage(),
      ),
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/signup', builder: (c, s) => const SignupPage()),
      GoRoute(
          path: '/forgot-password',
          builder: (c, s) => const ForgotPasswordPage()),
      GoRoute(path: '/skills', builder: (c, s) => const SkillsSelectionPage()),
      GoRoute(
          path: '/verify-student',
          builder: (c, s) => const StudentVerificationPage()),

      // ── Buyer onboarding flow ──────────────────────────────────────
      GoRoute(
          path: '/buyer-onboarding/welcome',
          builder: (c, s) => const BuyerOnboardingWelcomePage()),

      // ── NEW: Coach onboarding flow ───────────────────────────────────
      GoRoute(
          path: '/coach/onboarding',
          builder: (c, s) => const CoachOnboardingPage()),

      // ── NEW: Coach chat ──────────────────────────────────────────────
      GoRoute(path: '/coach/chat', builder: (c, s) => const CoachChatPage()),

      // ── NEW: Rewards (Gude Vitality) ─────────────────────────────────
      GoRoute(path: '/rewards', builder: (c, s) => const RewardsPage()),

      // ── NEW: Challenges ──────────────────────────────────────────────
      GoRoute(path: '/challenges', builder: (c, s) => const ChallengesPage()),

      // ── NEW: Nudge Notifications (AI nudges) ─────────────────────────
      GoRoute(
          path: '/nudges',
          builder: (c, s) => const nudge_notif.NotificationsPage()),

      // ── Marketplace sub-screens (outside shells) ───────────────────
      GoRoute(
          path: '/marketplace/create',
          builder: (c, s) => CreateListingPage(
              initialTab: s.uri.queryParameters['type'] == 'service' ? 1 : 0)),
      GoRoute(
          path: '/marketplace/jobs',
          builder: (c, s) => const JobDashboardPage()),
      GoRoute(
        path: '/marketplace/listing',
        builder: (c, s) {
          final listing = s.extra as Map<String, String>? ??
              {
                'name': 'Student',
                'title': 'Service',
                'university': 'UCT',
                'price': 'R150/hr',
                'rating': '4.9',
                'jobs': '10',
              };
          return ListingDetailPage(listing: listing);
        },
      ),
      GoRoute(
        path: '/marketplace/hire',
        builder: (c, s) {
          final listing = s.extra as Map<String, String>? ??
              {
                'name': 'Student',
                'title': 'Service',
                'university': 'UCT',
                'price': 'R150/hr',
                'rating': '4.9',
                'jobs': '10',
              };
          return HireStudentPage(listing: listing);
        },
      ),

      // ── Notifications & wishlist ───────────────────────────────────
      GoRoute(
          path: '/notifications', builder: (c, s) => const NotificationsPage()),
      GoRoute(path: '/wishlist', builder: (c, s) => const WishlistPage()),

      // ── Notice Board ───────────────────────────────────────────────
      GoRoute(
          path: '/notice-board', builder: (c, s) => const NoticeBoardPage()),
      GoRoute(path: '/noticeboard', builder: (c, s) => const NoticeBoardPage()),

      // ── Community Chat ─────────────────────────────────────────────
      GoRoute(path: '/community', builder: (c, s) => const ChatsChatPage()),

      // ── Wallet sub-screens (outside shell) ─────────────────────────
      GoRoute(
          path: '/wallet/budget', builder: (c, s) => const BudgetPlannerPage()),
      GoRoute(
          path: '/wallet/savings', builder: (c, s) => const SavingsGoalsPage()),
      GoRoute(
          path: '/wallet/send', builder: (_, __) => const SendMoneyScreen()),
      GoRoute(
          path: '/wallet/withdraw', builder: (_, __) => const WithdrawScreen()),
      GoRoute(
          path: '/wallet/received',
          builder: (_, __) => const ReceivedMoneyScreen()),
      GoRoute(
          path: '/wallet/transactions',
          builder: (_, __) => const TransactionsScreen()),
      GoRoute(
        path: '/wallet/pockets',
        builder: (_, s) =>
            WalletPocketsPage(initialIndex: (s.extra as Map?)?['index'] ?? 0),
      ),

      GoRoute(
        path: '/wallet/transact',
        builder: (_, __) => const TransactScreen(),
      ),

      // ── Stability ─────────────────────────────────────────────────
      GoRoute(
          path: '/stability/checkin',
          builder: (c, s) => const WeeklyCheckinPage()),

      // ── Student Shell ──────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomePage()),
          GoRoute(
              path: '/marketplace', builder: (c, s) => const MarketplacePage()),
          GoRoute(path: '/wallet', builder: (c, s) => const WalletPage()),
          GoRoute(
              path: '/messages', builder: (c, s) => const UnifiedChatPage()),
          GoRoute(path: '/chats', builder: (c, s) => const ChatsChatPage()),
          GoRoute(path: '/support', builder: (c, s) => const SupportPage()),
          GoRoute(path: '/stability', builder: (c, s) => const StabilityPage()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
        ],
      ),

      // ── Institution Shell (3 tabs: Marketplace, Jobs, Profile) ─────
      ShellRoute(
        builder: (context, state, child) => InstitutionNavShell(child: child),
        routes: [
          GoRoute(
              path: '/institution/browse',
              builder: (c, s) => const MarketplacePage()),
          GoRoute(
              path: '/institution/marketplace',
              builder: (c, s) => const InstitutionMarketplacePage()),
          GoRoute(
              path: '/institution/profile',
              builder: (c, s) => const InstitutionProfilePage()),
        ],
      ),

      // ── Buyer Shell ────────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => BuyerNavShell(child: child),
        routes: [
          GoRoute(
              path: '/buyer/marketplace',
              builder: (c, s) => const MarketplacePage(isBuyer: true)),
          GoRoute(
              path: '/buyer/messages',
              builder: (c, s) => const BuyerMessagesPage()),
          GoRoute(
              path: '/buyer/profile',
              builder: (c, s) => const BuyerProfilePage()),
        ],
      ),
    ],
  );
}
