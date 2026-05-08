import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/widgets/back_button_widget.dart';

/// Combo product page (placeholder)
/// Currently, only variable products use full PDP logic. Other product types are implemented as placeholders and will be expanded later.
class ComboProductPage extends StatelessWidget {
  final String productName;

  const ComboProductPage({
    super.key,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButtonWidget(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Combo Product'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Combo Product Page',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              productName,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
