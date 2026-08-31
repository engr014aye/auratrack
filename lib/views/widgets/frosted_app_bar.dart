import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final double blurAmount;
  final double height;
  final Color? backgroundColor;
  final bool showBottomBorder;
  final bool centerTitle;

  const FrostedAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.blurAmount = 20.0,
    this.height = kToolbarHeight,
    this.backgroundColor,
    this.showBottomBorder = true,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBg = isDark
        ? const Color(0xCC0F1117)
        : const Color(0xCCF8FAFC);

    final borderColor = isDark
        ? const Color(0x22FFFFFF)
        : const Color(0x1E000000);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          height: height + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBg,
            border: showBottomBorder
                ? Border(bottom: BorderSide(color: borderColor, width: 0.8))
                : null,
          ),
          child: NavigationToolbar(
            leading: leading,
            middle: title != null
                ? DefaultTextStyle(
                    style: theme.appBarTheme.titleTextStyle ??
                        theme.textTheme.titleLarge!,
                    child: title!,
                  )
                : null,
            trailing: actions != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  )
                : null,
            centerMiddle: centerTitle,
          ),
        ),
      ),
    );
  }
}
