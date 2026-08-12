import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_radius.dart';
import '../../app/theme/aurum_shadows.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';

enum AurumButtonVariant { primary, secondary, text }

class AurumButton extends StatelessWidget {
  const AurumButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.variant = AurumButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AurumButtonVariant variant;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final foreground = switch (variant) {
      AurumButtonVariant.primary => AurumColors.ink,
      AurumButtonVariant.secondary || AurumButtonVariant.text => AurumColors.textPrimary,
    };
    final background = switch (variant) {
      AurumButtonVariant.primary => AurumColors.gold,
      AurumButtonVariant.secondary => AurumColors.surfaceElevated,
      AurumButtonVariant.text => Colors.transparent,
    };

    final child = SizedBox(
      height: 48,
      child: Material(
        color: background,
        borderRadius: AurumRadius.control,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: AurumRadius.control,
          child: Container(
            alignment: Alignment.center,
            decoration: variant == AurumButtonVariant.secondary
                ? BoxDecoration(
                    border: Border.all(color: AurumColors.border),
                    borderRadius: AurumRadius.control,
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.md),
            child: isLoading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                : Row(
                    mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (icon != null) ...<Widget>[
                        Icon(icon, size: 18, color: foreground),
                        const SizedBox(width: AurumSpacing.xs),
                      ],
                      Text(
                        label,
                        style: AurumTypography.label.copyWith(color: foreground),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
    return Semantics(button: true, enabled: enabled, label: label, child: expand ? child : IntrinsicWidth(child: child));
  }
}

class AurumCard extends StatelessWidget {
  const AurumCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AurumSpacing.md),
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AurumColors.card,
        borderRadius: AurumRadius.card,
        border: Border.all(color: borderColor ?? AurumColors.border),
        boxShadow: AurumShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AurumRadius.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: AurumRadius.card,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AurumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AurumAppBar({
    required this.title,
    super.key,
    this.leading,
    this.actions = const <Widget>[],
    this.bottom,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AurumColors.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      titleSpacing: leading == null ? AurumSpacing.lg : 0,
      title: Text(title, style: AurumTypography.h2),
      actions: actions,
      bottom: bottom,
    );
  }
}

class AurumBrand extends StatelessWidget {
  const AurumBrand({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      'AURUM',
      style: TextStyle(
        color: AurumColors.goldSoft,
        fontFamily: 'serif',
        fontSize: compact ? 16 : 28,
        fontWeight: FontWeight.w700,
        letterSpacing: compact ? 4.2 : 7,
      ),
    );
  }
}

class AurumBottomNav extends StatelessWidget {
  const AurumBottomNav({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.show_chart_rounded, label: 'Watch'),
    (icon: Icons.bar_chart_rounded, label: 'Markets'),
    (icon: Icons.swap_horiz_rounded, label: 'TRADE'),
    (icon: Icons.work_outline_rounded, label: 'Portfolio'),
    (icon: Icons.grid_view_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: AurumColors.ink,
          border: Border(top: BorderSide(color: AurumColors.border)),
        ),
        child: Row(
          children: List<Widget>.generate(_items.length, (int index) {
            final item = _items[index];
            final selected = currentIndex == index;
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: item.label,
                child: InkWell(
                  onTap: () => onDestinationSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 3,
                        width: selected ? 22 : 0,
                        decoration: const BoxDecoration(
                          color: AurumColors.gold,
                          borderRadius: AurumRadius.pill,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Icon(
                        item.icon,
                        size: 20,
                        color: selected ? AurumColors.gold : AurumColors.textTertiary,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AurumTypography.caption.copyWith(
                          color: selected ? AurumColors.goldSoft : AurumColors.textTertiary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AurumTypography.h3),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: AurumSpacing.xxs),
                Text(subtitle!, style: AurumTypography.caption),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
          ),
      ],
    );
  }
}

class AurumSearchField extends StatelessWidget {
  const AurumSearchField({
    required this.controller,
    required this.onChanged,
    super.key,
    this.hintText = 'Search assets',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: AurumTypography.body.copyWith(color: AurumColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded, color: AurumColors.textTertiary),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded, color: AurumColors.textTertiary),
              ),
      ),
    );
  }
}

class AurumFilterChip extends StatelessWidget {
  const AurumFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: selected,
      labelStyle: AurumTypography.label.copyWith(
        color: selected ? AurumColors.goldSoft : AurumColors.textSecondary,
      ),
      backgroundColor: AurumColors.surface,
      selectedColor: AurumColors.surfaceElevated,
      side: BorderSide(color: selected ? AurumColors.gold : AurumColors.border),
      shape: const RoundedRectangleBorder(borderRadius: AurumRadius.pill),
    );
  }
}
