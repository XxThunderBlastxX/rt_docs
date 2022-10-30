import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (routes) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (routes) => const MaterialPage(child: HomeScreen()),
});
