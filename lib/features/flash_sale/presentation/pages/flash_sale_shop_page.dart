import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithyaraaapp/features/shop/presentation/widgets/product_card/product_card.dart';
import 'package:ithyaraaapp/features/product_detail/variable/presentation/pages/variable_product_detail_page.dart';
import 'package:ithyaraaapp/features/product_detail/custom/presentation/pages/custom_product_pdp.dart';
import 'package:ithyaraaapp/features/product_detail/makecombo/presentation/pages/make_combo_product_pdp.dart';
import 'package:ithyaraaapp/features/product_detail/combo/presentation/pages/combo_product_pdp.dart';
import '../providers/flash_sale_provider.dart';

class FlashSaleShopPage extends ConsumerStatefulWidget {
  const FlashSaleShopPage({super.key});

  @override
  ConsumerState<FlashSaleShopPage> createState() => _FlashSaleShopPageState();
}

class _FlashSaleShopPageState extends ConsumerState<FlashSaleShopPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final state = ref.read(flashSaleControllerProvider);
      if (state.flashSaleEndTime != null) {
        final now = DateTime.now();
        final diff = state.flashSaleEndTime!.difference(now);
        if (mounted) {
          setState(() {
            _timeLeft = diff.isNegative ? Duration.zero : diff;
          });
        }
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(flashSaleControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "Ends Soon";
    final days = duration.inDays;
    final hours = (duration.inHours % 24).toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    if (days > 0) return "${days}d ${hours}h ${minutes}m ${seconds}s";
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashSaleControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Flash Sale', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(flashSaleControllerProvider.notifier).loadProducts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Flash Sale Header with Countdown
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade800, Colors.red.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DEAL OF THE DAY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Grab them before they are gone!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Text(
                          'ENDS IN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDuration(_timeLeft),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (state.isLoading && state.products.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && state.products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = state.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          final type = product.type?.toLowerCase() ?? 'variable';
                          final productID = product.productID;

                          if (type == 'customproduct' || type == 'custom') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CustomProductPDP(product: product)),
                            );
                          } else if (type == 'makecombo') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MakeComboProductPDP(productID: productID)),
                            );
                          } else if (type == 'combo') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ComboProductPDP(productID: productID)),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VariableProductDetailPage(productID: productID)),
                            );
                          }
                        },
                      );
                    },
                    childCount: state.products.length,
                  ),
                ),
              ),

            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
