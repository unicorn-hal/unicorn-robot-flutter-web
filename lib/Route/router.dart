import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';
import 'package:unicorn_robot_flutter_web/View/home_view.dart';
import 'package:unicorn_robot_flutter_web/View/login_view.dart';
import 'routes.dart';
part 'router.g.dart';

/// NavigatorKey
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouterProvider
final routerProvider = Provider(
  (ref) => GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    routes: $appRoutes,
  ),
);

//////////////////////////////  Root  //////////////////////////////
@TypedGoRoute<RootRoute>(
  path: Routes.root,
)
class RootRoute extends GoRouteData {
  const RootRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginView();
}

@TypedGoRoute<LoginRoute>(
  path: Routes.login,
)
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginView();
}

@TypedGoRoute<HomeRoute>(
  path: Routes.home,
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeView();
}
