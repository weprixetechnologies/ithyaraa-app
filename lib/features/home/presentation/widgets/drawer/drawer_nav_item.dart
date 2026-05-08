import 'package:flutter/material.dart';

/// Navigation item model for drawer
/// 
/// Data-driven approach for drawer navigation items
class DrawerNavItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool requiresAuth;

  const DrawerNavItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.requiresAuth = false,
  });
}

/// Quick action item model
class DrawerQuickAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const DrawerQuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// Footer section item model
class DrawerFooterItem {
  final String label;
  final VoidCallback? onTap;

  const DrawerFooterItem({
    required this.label,
    this.onTap,
  });
}

/// Footer section model
class DrawerFooterSectionModel {
  final String title;
  final List<DrawerFooterItem> items;

  const DrawerFooterSectionModel({
    required this.title,
    required this.items,
  });
}
