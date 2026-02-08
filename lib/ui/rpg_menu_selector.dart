import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/custom_menu_item.dart';
import '../core/menu_data.dart';

class RpgMenuSelector extends StatefulWidget {
  const RpgMenuSelector({
    super.key,
    required this.selectedIds,
    required this.onSelectionChanged,
    this.onToggleSfx,
    this.recent3 = const [],
    this.backgroundAssetPath = 'assets/joker背景虚化.jpg',
    this.customItems = const [],
    this.requestedCategory,
    this.categoryRequestId = 0,
  });

  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final VoidCallback? onToggleSfx;
  final List<String> recent3;
  final String backgroundAssetPath;
  final List<CustomMenuItem> customItems;
  final String? requestedCategory;
  final int categoryRequestId;

  @override
  State<RpgMenuSelector> createState() => _RpgMenuSelectorState();
}

class _RpgMenuSelectorState extends State<RpgMenuSelector> {
  String _activeCategory = MenuCategory.fastFood;
  MenuItem? _hoveredItem;

  @override
  void didUpdateWidget(covariant RpgMenuSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final requested = widget.requestedCategory;
    if (requested != null &&
        widget.categoryRequestId != oldWidget.categoryRequestId &&
        requested != _activeCategory) {
      setState(() => _activeCategory = requested);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categories = [
      MenuCategory.fastFood,
      MenuCategory.noodles,
      MenuCategory.rice,
      MenuCategory.healthy,
      MenuCategory.random,
      MenuCategory.custom,
    ];

    final customMenuItems = widget.customItems.map((e) {
      final id = 'custom_${e.category}_${e.name.hashCode}';
      return MenuItem(
        id: id,
        name: e.name,
        description: e.description,
        category: e.category,
      );
    }).toList();

    final currentItems = <MenuItem>[...kPresetMenu, ...customMenuItems]
        .where((item) => item.category == _activeCategory)
        .toList();

    // Calculate repeated counts for penalty visualization
    final repeatedCounts = <String, int>{};
    for (final c in widget.recent3) {
      repeatedCounts[c] = (repeatedCounts[c] ?? 0) + 1;
    }

    final displayItem = _hoveredItem;

    return Stack(
      children: [
        // Full-bleed background artwork (cover)
        Positioned.fill(
          child: Opacity(
            opacity: 0.32,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Image.asset(
                widget.backgroundAssetPath,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading asset ${widget.backgroundAssetPath}: $error');
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),

        // Readability overlay (darkens list area)
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.18),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        Column(
          children: [
            // Category Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isActive = cat == _activeCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _activeCategory = cat),
                  child: Transform(
                        transform: Matrix4.skewX(-0.2),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? scheme.primary : Colors.transparent,
                            border: Border.all(
                              color: isActive
                                  ? scheme.primary
                                  : scheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isActive ? scheme.onPrimary : scheme.onSurface,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),

            // Item List + hover description overlay
            Expanded(
              child: MouseRegion(
                onExit: (_) => setState(() => _hoveredItem = null),
                child: Builder(
                  builder: (context) {
                    const overlayHeight = 104.0;
                    final showOverlay = displayItem != null;

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              border:
                                  Border.all(color: scheme.outline.withOpacity(0.3)),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                bottom: showOverlay ? overlayHeight + 12 : 0,
                              ),
                              itemCount: currentItems.length,
                              itemBuilder: (context, index) {
                                final item = currentItems[index];
                                final isSelected =
                                    widget.selectedIds.contains(item.name);
                                final isFocused = _hoveredItem == item;

                                final repeatCount =
                                    repeatedCounts[item.name] ?? 0;
                                final isPenalized = repeatCount >= 2;

                                return MouseRegion(
                                  hitTestBehavior: HitTestBehavior.opaque,
                                  onEnter: (_) =>
                                      setState(() => _hoveredItem = item),
                                  child: InkWell(
                                    onTap: () {
                                      final newSelection =
                                          Set<String>.from(widget.selectedIds);
                                      if (isSelected) {
                                        newSelection.remove(item.name);
                                      } else {
                                        newSelection.add(item.name);
                                      }
                                      widget.onToggleSfx?.call();
                                      widget.onSelectionChanged(newSelection);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      color: isSelected
                                          ? scheme.primary.withOpacity(0.2)
                                          : (_hoveredItem == item
                                              ? Colors.white.withOpacity(0.05)
                                              : Colors.transparent),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            child: isFocused
                                                ? Icon(
                                                    Icons.play_arrow,
                                                    size: 16,
                                                    color: scheme.secondary,
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                          Icon(
                                            isSelected
                                                ? Icons.check_box
                                                : Icons
                                                    .check_box_outline_blank,
                                            color: isSelected
                                                ? scheme.primary
                                                : scheme.onSurface
                                                    .withOpacity(0.5),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: TextStyle(
                                                color: isPenalized
                                                    ? scheme.onSurface
                                                        .withOpacity(0.5)
                                                    : (isSelected
                                                        ? scheme.primary
                                                        : scheme.onSurface),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.1,
                                                decoration: isPenalized
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          if (isPenalized)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: Text(
                                                'WEAK',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  color: scheme.onSurface
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                          if (isSelected)
                                            const Text(
                                              'EQUIPPED',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            ignoring: !showOverlay,
                            child: AnimatedOpacity(
                              opacity: showOverlay ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 120),
                              child: Container(
                                height: overlayHeight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border(
                                    left: BorderSide(
                                      color: scheme.secondary,
                                      width: 4,
                                    ),
                                    bottom: BorderSide(
                                      color: scheme.secondary,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayItem?.name ?? 'INFO',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: scheme.secondary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      displayItem?.description ??
                                          'Hover an item to view its details...',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: scheme.onSurface,
                                        fontSize: 14,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
