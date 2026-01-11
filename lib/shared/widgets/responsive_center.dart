import 'package:flutter/material.dart';

/// A widget that centers its child and constrains its maximum width for responsive layouts.
///
/// This widget is designed to prevent content from being too stretched on wide screens
/// (desktop/web) while maintaining full width on mobile devices.
///
/// Features:
/// - On mobile: Uses full available width
/// - On desktop/web: Limits content to [maxWidth] and centers it
/// - Optional padding around the content
///
/// Example usage:
/// ```dart
/// ResponsiveCenter(
///   maxWidth: 1200,
///   padding: EdgeInsets.all(16),
///   child: YourContent(),
/// )
/// ```
class ResponsiveCenter extends StatelessWidget {
  /// Creates a responsive center widget.
  ///
  /// The [child] parameter is required.
  /// The [maxWidth] defaults to 1000 pixels.
  /// The [padding] is optional and defaults to zero.
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 1000,
    this.padding,
  });

  /// The widget to be centered and constrained.
  final Widget child;

  /// Maximum width of the content. Defaults to 1000 pixels.
  final double maxWidth;

  /// Optional padding around the child widget.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// A responsive center widget with built-in scrolling support.
///
/// This is a convenience widget that combines [ResponsiveCenter] with
/// [SingleChildScrollView] for pages that need scrollable content.
///
/// Features:
/// - All features of [ResponsiveCenter]
/// - Built-in vertical scrolling
/// - Optional scroll physics customization
/// - Optional scroll controller
///
/// Example usage:
/// ```dart
/// ResponsiveCenterScrollView(
///   maxWidth: 1200,
///   padding: EdgeInsets.all(16),
///   child: Column(
///     children: [
///       // Your scrollable content
///     ],
///   ),
/// )
/// ```
class ResponsiveCenterScrollView extends StatelessWidget {
  /// Creates a responsive center scroll view.
  ///
  /// The [child] parameter is required.
  /// The [maxWidth] defaults to 1000 pixels.
  /// The [padding] is optional and defaults to zero.
  const ResponsiveCenterScrollView({
    super.key,
    required this.child,
    this.maxWidth = 1000,
    this.padding,
    this.physics,
    this.controller,
  });

  /// The widget to be centered, constrained, and made scrollable.
  final Widget child;

  /// Maximum width of the content. Defaults to 1000 pixels.
  final double maxWidth;

  /// Optional padding around the child widget.
  final EdgeInsetsGeometry? padding;

  /// The scroll physics to use for the scroll view.
  final ScrollPhysics? physics;

  /// An optional controller for the scroll view.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics,
      controller: controller,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
