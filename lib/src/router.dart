import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/dashboard/view/dashboard_screen.dart';
import 'package:game_launcher/src/game/add/view/add_screen.dart';
import 'package:game_launcher/src/game/details/view/details_screen.dart';
import 'package:game_launcher/src/game/library/view/library_screen.dart';
import 'package:game_launcher/src/home/view/home.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_repository/settings_repository.dart';

final router = GoRouter(
  initialLocation: '/dashboard',
  // TODO I think this is called every time
  redirect: (context, state) async {
    // TODO first start redirection (perhaps default firstStart and redirect to dashboard)
    // retrieve settings from context and based on that redirect
    final settingsRepo = context.read<SettingsRepository>();
    /*if ((await settingsRepo.appSettings.first).isFirstStart) {
      return '/first-start';
    }*/
    return null;
  },
  routes: [
    ShellRoute(
      /*path: '/',
      name: 'Home',*/
      builder: (context, state, child) => HomePage(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'Dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/games',
          name: 'Games',
          builder: (context, state) => const LibraryScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'GameNew',
              builder: (context, state) => AddScreen(
                archiveFilePath: (state.extra
                    as Map<String, dynamic>)['archivePath'] as String,
              ),
            ),
            GoRoute(
              path: ':gameId',
              name: 'GameDetails',
              builder: (context, state) => DetailsScreen(
                gameId: int.parse(state.pathParameters['gameId'] ?? ""),
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'GameEdit',
                  builder: (context, state) => placeholder,
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/developers',
          name: 'Developers',
          builder: (context, state) => placeholder,
        ),
        GoRoute(
          path: '/settings',
          name: 'Settings',
          builder: (context, state) => placeholder,
        ),
      ],
    ),
    GoRoute(
      path: '/first-start',
      name: 'FirstStart',
      builder: (context, state) => placeholder,
    ),
  ],
);

const Widget placeholder = Center(
  child: Text('PLACEHOLDER'),
);
