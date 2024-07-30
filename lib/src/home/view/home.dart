import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/home/cubit/home_cubit.dart';
import 'package:game_launcher/src/shared/progress_widget/view/progress_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_repository/progress_repository.dart';
import 'package:side_navigation/side_navigation.dart';

class HomePage extends StatelessWidget {
  final Widget child;
  const HomePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        progressRepository: context.read<ProgressRepository>(),
      ),
      child: _HomePageContent(child: child),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  final Widget child;

  const _HomePageContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Game Launcher"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/background.jpg",
            filterQuality: FilterQuality.high,
            fit: BoxFit.fitWidth,
          ),
          Row(
            children: [
              // TODO look for better way than updating whole sidebar on footer data changes
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) => SideNavigationBar(
                  // TODO light mode looks a little bit strange (as if sth above items)
                  selectedIndex: getIndexFromRoute(context),
                  items: const [
                    SideNavigationBarItem(
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                    ),
                    SideNavigationBarItem(
                      icon: Icons.games,
                      label: 'Library',
                    ),
                    SideNavigationBarItem(
                      icon: Icons.person,
                      label: 'Developers',
                    ),
                    SideNavigationBarItem(
                      icon: Icons.settings,
                      label: 'Settings',
                    ),
                  ],
                  // Footer that displays progress from ProgressProvider
                  // TODO
                  footer: state.hasCurrentProgress
                      ? SideNavigationBarFooter(
                          label: ProgressWidget(
                            descriptionStyle:
                                Theme.of(context).textTheme.bodyMedium,
                            internalDescriptionStyle:
                                Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : null,
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        context.go("/dashboard");
                      case 1:
                        context.go("/games");
                      case 2:
                        context.go("/developers");
                      case 3:
                        context.go("/settings");
                    }
                  },
                  theme: SideNavigationBarTheme(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    itemTheme: SideNavigationBarItemTheme(
                      selectedItemColor: Theme.of(context).colorScheme.primary,
                      unselectedItemColor:
                          Theme.of(context).colorScheme.onBackground,
                    ),
                    togglerTheme: SideNavigationBarTogglerTheme(
                      expandIconColor: Theme.of(context).iconTheme.color,
                      shrinkIconColor: Theme.of(context).iconTheme.color,
                    ),
                    dividerTheme: const SideNavigationBarDividerTheme(
                      showFooterDivider: false,
                      showHeaderDivider: false,
                      showMainDivider: false,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: child,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  int getIndexFromRoute(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    if (currentRoute.startsWith("/games")) {
      return 1;
    } else if (currentRoute.startsWith("/developers")) {
      return 2;
    } else if (currentRoute.startsWith("/settings")) {
      return 3;
    } else {
      return 0;
    }
  }
}
