import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/screens/auth/auth_screen.dart';
import 'package:stillnote/screens/dashboard/dashboard_screen.dart';
import 'package:stillnote/screens/error_page.dart';
import 'package:stillnote/screens/note/note_screen.dart';
import 'package:stillnote/screens/notebook/notebook_screen.dart';
import 'package:stillnote/screens/profile/profile_screen.dart';
import 'package:stillnote/utils/x_functions.dart';

class XRouter {
  const XRouter._();
  static final router = GoRouter(
    initialLocation: '/dashboard/home',
    redirect: (context, state) {
      if (state.uri.pathSegments.first == 'dashboard' &&
          !XFuns.isAuthenticated(context)) {
        return '/auth/login';
      }
      if (state.uri.pathSegments.first == 'auth' &&
          XFuns.isAuthenticated(context)) {
        return '/dashboard/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/:page',
        builder: (context, state) {
          final page = state.pathParameters['page'] ?? '';
          final pageList = ['login', 'register', 'forgot-password'];
          if (pageList.contains(page)) {
            return AuthScreen(page);
          } else {
            return const ErrorPage();
          }
        },
      ),
      GoRoute(
        path: '/dashboard/:page',
        builder: (context, state) {
          final title = state.pathParameters['page'] ?? '';
          final pathList = ['home', 'search', 'notebooks', 'starred'];
          if (title.isNotEmpty && pathList.contains(title)) {
            return const DashboardScreen();
          } else {
            return const ErrorPage();
          }
        },
      ),
      GoRoute(
        path: '/notebook/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (id.isNotEmpty) {
            return NotebookScreen(id);
          } else {
            return const ErrorPage();
          }
        },
      ),
      GoRoute(
        path: '/note/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (id.isNotEmpty) {
            return NoteScreen(id);
          } else {
            return const ErrorPage();
          }
        },
      ),
      GoRoute(
        path: '/profile/:username',
        builder: (context, state) {
          final username = state.pathParameters['username'] ?? '';
          if (username.isNotEmpty) {
            return ProfileScreen(username);
          } else {
            return const ErrorPage();
          }
        },
      ),
    ],
  );

  static RouterDelegate get routerDel => router.routerDelegate;

  static Uri get currentUri => router.routeInformationProvider.value.uri;
}
