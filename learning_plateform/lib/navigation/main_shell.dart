import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/features/bookmarks/bookmarks_screen.dart';
import 'package:learning_plateform/features/home/home_screen.dart';
import 'package:learning_plateform/features/profile/profile_screen.dart';
import 'package:learning_plateform/features/progress/progress_screen.dart';
import 'package:learning_plateform/features/subjects/subjects_screen.dart';
import 'package:learning_plateform/providers/home_provider.dart';

/// Main navigation shell.  Holds all tab pages in an [IndexedStack] so that
/// each tab's scroll position and state is preserved when switching tabs.
/// The [AppBottomNavBar] is rendered inside each individual screen so that
/// it is always visible regardless of which page is active — but to avoid
/// visual duplication, each page renders the nav bar at the bottom of its
/// own Scaffold.  The shell itself has no Scaffold.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _pages = [
    HomeScreen(),
    SubjectsScreen(),
    ProgressScreen(),
    BookmarksScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);
    return IndexedStack(
      index: index,
      children: _pages,
    );
  }
}
