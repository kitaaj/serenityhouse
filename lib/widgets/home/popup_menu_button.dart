import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_support/enums/menu_action.dart';
import 'package:mental_health_support/helpers/screen_routes.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_bloc.dart';
import 'package:mental_health_support/services/auth/bloc/authBloc/auth_event.dart';
import 'package:mental_health_support/utilities/dialogs/logout_dialog.dart';

class CustomPopupMenuButton extends StatefulWidget {
  const CustomPopupMenuButton({super.key});

  @override
  State<CustomPopupMenuButton> createState() => _CustomPopupMenuButtonState();
}

class _CustomPopupMenuButtonState extends State<CustomPopupMenuButton> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuAction>(
      tooltip: 'More options', // Tooltip for accessibility
      onSelected: (value) async {
        switch (value) {
          case MenuAction.logout:
            final shouldLogout = await showLogoutDialog(context);
            if (shouldLogout) {
              if (!context.mounted) return;
              context.read<AuthBloc>().add(const AuthEventLogOut());
            }
            break;

          case MenuAction.deleteAccount:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account deletion is not yet implemented.'),
              ),
            );
            break;

          case MenuAction.emergency:
            // Navigate to the EmergencyScreen
            Navigator.of(context).pushNamed(emergencyScreenRoute);

            break;
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<MenuAction>(
            value: MenuAction.logout,
            child: const Text('Log out'),
          ),
          PopupMenuItem<MenuAction>(
            value: MenuAction.deleteAccount,
            child: const Text('Delete account'),
          ),
          PopupMenuItem<MenuAction>(
            value: MenuAction.emergency,
            child: const Text('Emergency help'),
          ),
        ];
      },
    );
  }
}
