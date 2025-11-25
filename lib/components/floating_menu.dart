import 'package:flutter/material.dart';

class FloatingMenu extends StatelessWidget {
  const FloatingMenu({super.key, required this.currentRoute});

  final String currentRoute;

  static const _items = <_MenuItem>[
    _MenuItem(route: '/', icon: Icons.calendar_month_outlined, label: 'Agenda'),
    _MenuItem(route: '/clients', icon: Icons.groups_outlined, label: 'Clientes'),
    _MenuItem(route: '/services', icon: Icons.design_services_outlined, label: 'Serviços'),
    _MenuItem(route: '/history', icon: Icons.history_outlined, label: 'Histórico'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(32),
              color: theme.colorScheme.surfaceVariant,
              shadowColor: theme.shadowColor.withOpacity(0.18),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: _items.map((item) {
                    final selected = item.route == currentRoute;
                    return Expanded(
                      child: _MenuButton(
                        item: item,
                        selected: selected,
                        onTap: selected
                            ? null
                            : () => _onSelect(context, item.route),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSelect(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }
}

class _MenuItem {
  const _MenuItem({required this.route, required this.icon, required this.label});

  final String route;
  final IconData icon;
  final String label;
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.item, required this.selected, required this.onTap});

  final _MenuItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;
    final background = selected ? theme.colorScheme.primary : Colors.transparent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: foreground),
              const SizedBox(height: 6),
              Text(
                item.label,
                style: theme.textTheme.labelMedium?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
