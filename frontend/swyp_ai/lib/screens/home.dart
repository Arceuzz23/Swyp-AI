import 'package:flutter/material.dart';
import 'package:swyp_ai/features/router.dart';
import 'package:swyp_ai/widgets/card.dart';
import '../utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    AppLogger.debug('HomeScreen initialized');
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      AppLogger.info('Loading home screen data');
      AppLogger.logApi('/home/feed', request: 'GET');
      // Data loading logic
      AppLogger.debug('Home data loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load home data', e, stackTrace);
    }
  }

  void _handleRefresh() {
    AppLogger.info('Refreshing home screen');
    _loadHomeData();
  }

  void _handleItemSelection(String itemId) {
    AppLogger.debug('Item selected: $itemId');
    try {
      // Item selection logic
      AppLogger.logApi('/items/$itemId', request: 'GET');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to process item selection', e, stackTrace);
    }
  }

  void _handleLogout() async {
    try {
      AppLogger.info('User logging out');
      await ref.read(authProvider.notifier).logout();
      ref.read(authStateProvider.notifier).clearAuthState();

      if (mounted) {
        context.go(AppRoutes.login.path);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to logout', e, stackTrace);
    }
  }

  @override
  void dispose() {
    AppLogger.debug('HomeScreen disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: CardWidget(
          quote: "When life gives you lemon, squeeze it on someone's facer",
        ),
      ),
    );
  }
}
