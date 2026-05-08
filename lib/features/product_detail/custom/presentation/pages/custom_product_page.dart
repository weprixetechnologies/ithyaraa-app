import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/widgets/back_button_widget.dart';

/// Custom product page (placeholder)
/// Currently, only variable products use full PDP logic. Other product types are implemented as placeholders and will be expanded later.
class CustomProductPage extends StatelessWidget {
  final String productName;

  const CustomProductPage({
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
        title: const Text('Custom Product'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Custom Product Page',
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
