import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_dashboard_template/features/Auth/auth.dart';
import 'package:flutter_admin_dashboard_template/features/Auth/auth_state.dart'; // ✅
import 'package:flutter_admin_dashboard_template/features/users/user_not_found_page.dart';
import 'package:go_router/go_router.dart';

import 'features/dashboard/dashbord_page.dart';
import 'features/users/dummy_users.dart';
import 'features/users/user_page.dart';
import 'features/users/users_page.dart';
import 'widgets/widgets.dart';

part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// ✅ GoRouter مع redirect يضمن أن العنوان يبقى "/"
final router = GoRouter(
  debugLogDiagnostics: kDebugMode,
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: $appRoutes,
  redirect: (context, state) {
  final goingTo = state.uri.toString();

  // لو مش مسجل دخول
  if (!AuthState.isLoggedIn) {
    if (goingTo != '/login' && goingTo != '/') {
      return '/login';
    }
  } else {
    // لو مسجل دخول ومازال في صفحة login → ودّيه للداشبورد
    if (goingTo == '/' || goingTo == '/login') {
      return '/dashboard';
    }
  }

  return null; // لا تعمل أي redirect إضافي
},

);

/// --------------------
/// Home Gate Route
/// --------------------
@TypedGoRoute<HomeGateRoute>(
  path: '/',
)
class HomeGateRoute extends GoRouteData with _$HomeGateRoute {
  const HomeGateRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (!AuthState.isLoggedIn) {
      return const LoginPage(); // 🚪 لو مش مسجل دخول
    } else {
      return const DashBoardPage(); // ✅ بعد تسجيل الدخول
    }
  }
}

/// --------------------
/// Login Route
/// --------------------
@TypedGoRoute<LoginRoute>(
  path: '/login',
)
class LoginRoute extends GoRouteData with _$LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginPage();
  }
}

/// --------------------
/// Shell Route (layout)
/// --------------------
@TypedStatefulShellRoute<ShellRouteData>(
  branches: [
    TypedStatefulShellBranch(
      routes: [
        TypedGoRoute<DashboardRoute>(
          path: '/dashboard',
        ),
      ],
    ),
    TypedStatefulShellBranch(
      routes: [
        TypedGoRoute<UsersPageRoute>(
          path: '/users',
          routes: [
            TypedGoRoute<UserPageRoute>(
              path: ':userId',
            ),
          ],
        ),
      ],
    ),
  ],
)
class ShellRouteData extends StatefulShellRouteData {
  const ShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return SelectionArea(
      child: ScaffoldWithNavigation(
        navigationShell: navigationShell,
      ),
    );
  }
}

/// --------------------
/// Dashboard Route
/// --------------------
class DashboardRoute extends GoRouteData with _$DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashBoardPage();
  }
}

/// --------------------
/// Users Route
/// --------------------
class UsersPageRoute extends GoRouteData with _$UsersPageRoute {
  const UsersPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UsersPage();
  }
}

class UserPageRoute extends GoRouteData with _$UserPageRoute {
  const UserPageRoute({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final user = dummyUsers.firstWhereOrNull((e) => e.userId == userId);
    return user == null
        ? UserNotFoundPage(userId: userId)
        : UserPage(user: user);
  }
}
