import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Product tabs widget
class ProductTabs extends StatefulWidget {
  final String? tab1;
  final String? tab2;

  const ProductTabs({
    super.key,
    this.tab1,
    this.tab2,
  });

  @override
  State<ProductTabs> createState() => _ProductTabsState();
}

class _ProductTabsState extends State<ProductTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabCount = (widget.tab1 != null ? 1 : 0) + (widget.tab2 != null ? 1 : 0);
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tab1 == null && widget.tab2 == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE91E63),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFFE91E63),
          tabs: [
            if (widget.tab1 != null) const Tab(text: 'Tab 1'),
            if (widget.tab2 != null) const Tab(text: 'Tab 2'),
          ],
        ),
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabController,
            children: [
              if (widget.tab1 != null)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.tab1!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              if (widget.tab2 != null)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.tab2!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
