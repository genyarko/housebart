import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/constants/api_routes.dart';
import 'explore_page.dart';
import 'my_barters_page.dart';
import 'messages_page.dart';
import 'profile_page.dart';

/// Main page with bottom navigation
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  final List<GlobalKey<State>> _pageKeys = [
    GlobalKey<State>(),
    GlobalKey<State>(),
    GlobalKey<State>(),
    GlobalKey<State>(),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ExplorePage(key: _pageKeys[0]),
      MyBartersPage(key: _pageKeys[1]),
      MessagesPage(key: _pageKeys[2]),
      ProfilePage(key: _pageKeys[3]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _previousIndex = _currentIndex;
              _currentIndex = index;
            });

            // Notify the explore page to refresh when returning to it
            if (index == 0 && _previousIndex != 0) {
              final explorePageState = _pageKeys[0].currentState;
              if (explorePageState != null) {
                try {
                  // Call refreshData method if it exists
                  (explorePageState as dynamic).refreshData();
                } catch (e) {
                  // Silently ignore if method doesn't exist
                }
              }
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.swap_horiz_outlined),
              selectedIcon: Icon(Icons.swap_horiz),
              label: 'My Barters',
            ),
            NavigationDestination(
              icon: Icon(Icons.message_outlined),
              selectedIcon: Icon(Icons.message),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
