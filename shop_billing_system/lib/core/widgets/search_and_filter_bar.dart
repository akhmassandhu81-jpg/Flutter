import 'package:flutter/material.dart';

class SearchAndFilterBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final Widget? filterWidget;
  final List<Widget>? extraActions;

  const SearchAndFilterBar({
    super.key,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    this.filterWidget,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                ),
              ),
              if (filterWidget != null || extraActions != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (filterWidget != null) Expanded(child: filterWidget!),
                    if (extraActions != null) ...extraActions!,
                  ],
                ),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                ),
              ),
            ),
            if (filterWidget != null) ...[
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: filterWidget!,
              ),
            ],
            if (extraActions != null) ...[
              const SizedBox(width: 12),
              ...extraActions!,
            ],
          ],
        );
      },
    );
  }
}
