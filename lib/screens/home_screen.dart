import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/helpers/nav_cubit.dart';
import 'package:mental_health_support/screens/chat_list_view.dart';
import 'package:mental_health_support/screens/journal_screen.dart';
import 'package:mental_health_support/screens/mood_tracker_screen.dart';
import 'package:mental_health_support/widgets/home/popup_menu_button.dart';
import 'package:mental_health_support/widgets/home/refresh_icon.dart';
import 'package:mental_health_support/widgets/moods/breathing_exercise.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Widget> _pages = [
    const ChatListView(),
    const MoodScreen(),
    JournalScreen(),
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize PageController
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose PageController to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavCubit, int>(
      builder: (context, currentIndex) {
        // Ensure PageView scrolls to the correct page when NavCubit updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients &&
              _pageController.page?.round() != currentIndex) {
            _pageController.jumpToPage(currentIndex);
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Text(getTitleForIndex(currentIndex)),
            actions:
                [
              // Existing chat screen actions
              if (currentIndex == 0) ...[
                RefreshIcon(),
                const CustomPopupMenuButton(),
              ],
              // Add breathing exercise icon for mood screen
              if (currentIndex == 1)
                IconButton(
                  icon: const Icon(Icons.self_improvement),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BreathingExerciseScreen(),
                    ),
                  ),
                ),
            ],
          ),
          body: PageView(
            physics: const BouncingScrollPhysics(), // Add bounce effect
            controller: _pageController, // Use the PageController
            onPageChanged: (index) {
              context.read<NavCubit>().updateIndex(
                index,
              ); // Sync NavCubit with PageView
            },
            children: _pages,
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.all(
                TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              indicatorColor: Theme.of(context).colorScheme.primary.withAlpha(
                76,
              ), // Adjust transparency using withAlpha
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (int index) {
                context.read<NavCubit>().updateIndex(index); // Update NavCubit
                _pageController.jumpToPage(
                  index,
                ); // Scroll PageView to the selected page
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.chat), label: 'Chats'),
                NavigationDestination(icon: Icon(Icons.mood), label: 'Moods'),
                NavigationDestination(
                  icon: Icon(Icons.view_list),
                  label: 'Journals',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Chats';
      case 1:
        return 'Moods';
      case 2:
        return 'Journals';
      default:
        return '';
    }
  }
}
