import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presale/presentation/controllers/presale_controller.dart';
import '../../../presale/presentation/widgets/presale_product_card.dart';
import '../../../presale/presentation/pages/presale_pdp_page.dart';
import '../../../../core/widgets/app_heading.dart';

class HomePresaleSection extends ConsumerWidget {
  const HomePresaleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presaleControllerProvider);

    if (state.products.isEmpty && !state.isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeading(text: 'PRE-BOOKING PRODUCTS', textAlign: TextAlign.start),
              SizedBox(height: 4),
              Text(
                'Get early access to our latest collections',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 420, // Sufficient height for card + countdown
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: state.products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = state.products[index];
              return PresaleProductCard(
                product: product,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PresalePDPPage(productID: product.productID),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
