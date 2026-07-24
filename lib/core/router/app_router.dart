import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/pin_screen.dart';
import '../features/auth/biometric_screen.dart';
import '../features/main/main_shell.dart';
import '../features/dashboard/home_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/cards/cards_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/accounts/accounts_screen.dart';
import '../features/bills/bills_screen.dart';
import '../features/transfer/send_money_screen.dart';
import '../features/transfer/transfer_screens.dart';
import '../data/models/account_model.dart';

final GlobalKey<NavigatorState> _rootNavKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Auth Routes
    GoRoute(
      path: '/auth/pin',
      builder: (context, state) => const PinScreen(),
    ),
    GoRoute(
      path: '/auth/biometric',
      builder: (context, state) => const BiometricScreen(),
    ),
    // Main Shell (Bottom Nav)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 2: Transactions
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionsScreen(),
            ),
          ],
        ),
        // Tab 3: Cards
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cards',
              builder: (context, state) => const CardsScreen(),
            ),
          ],
        ),
        // Tab 4: Analytics
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
        // Tab 5: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Feature Routes (Full Screen outside tabs)
    GoRoute(
      path: '/accounts',
      parentNavigatorKey: _rootNavKey,
      builder: (context, state) => const AccountsScreen(),
      routes: [
        GoRoute(
          path: 'detail',
          parentNavigatorKey: _rootNavKey,
          builder: (context, state) {
            final account = state.extra as AccountModel;
            return AccountDetailScreen(account: account);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/bills',
      parentNavigatorKey: _rootNavKey,
      builder: (context, state) => const BillsScreen(),
    ),
    GoRoute(
      path: '/transfer/send',
      parentNavigatorKey: _rootNavKey,
      builder: (context, state) => const SendMoneyScreen(),
    ),
    GoRoute(
      path: '/transfer/request',
      parentNavigatorKey: _rootNavKey,
      builder: (context, state) => const RequestMoneyScreen(),
    ),
    GoRoute(
      path: '/transfer/success',
      parentNavigatorKey: _rootNavKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return TransferSuccessScreen(extra: extra);
      },
    ),
  ],
);
