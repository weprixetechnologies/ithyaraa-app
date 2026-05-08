import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/coin_controller.dart';
import '../../../../core/theme/app_text_styles.dart';

class CoinsPage extends ConsumerWidget {
  const CoinsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(coinBalanceProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Ithyaraa Coins', style: AppTextStyles.headingSmall),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: balanceAsync.when(
        data: (balance) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(coinBalanceProvider.notifier).refresh();
            await ref.refresh(coinHistoryProvider(1).future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 16),
                _buildBalanceCard(context, ref, balance),
                const SizedBox(height: 24),
                Text('History', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                _buildHistoryList(ref),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Earn 1 coin for every ₹100 spent. Coins expire after 365 days. Coins are credited only after your order is delivered.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WidgetRef ref, balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.yellow.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${balance.balance} coins',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.stars, color: Colors.white, size: 48),
            ],
          ),
          if (balance.lockedBalance > 0) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.amber.shade900.withValues(alpha: 0.1)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.amber.shade900,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.amber.shade900,
                      ),
                      children: [
                        TextSpan(
                          text: '${balance.lockedBalance} coins',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' locked (available after 7 days)',
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showLockedBreakdown(context, ref),
                  child: Text(
                    'Know more',
                    style: AppTextStyles.link.copyWith(
                      color: Colors.amber.shade900,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${balance.redeemableBalance} coins available for redemption',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.amber.shade900.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: balance.redeemableBalance > 0
                ? () =>
                      _showRedeemDialog(context, ref, balance.redeemableBalance)
                : null,
            icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
            label: const Text('Redeem to Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.amber.shade900,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(WidgetRef ref) {
    // For simplicity, we only show page 1 here. Pagination can be added if needed.
    final historyAsync = ref.watch(coinHistoryProvider(1));

    return historyAsync.when(
      data: (history) => history.rows.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No history yet.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.rows.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final row = history.rows[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _buildTypeBadge(row.type),
                  title: Text(
                    row.refType == 'order'
                        ? 'Order #${row.refID}'
                        : (row.refType ?? 'Transaction'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(row.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                  ),
                  trailing: Text(
                    '${_getAmountPrefix(row.type)}${row.coins}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getAmountColor(row.type),
                    ),
                  ),
                );
              },
            ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Text('Error loading history: $err'),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;
    IconData icon;

    switch (type) {
      case 'earn':
        color = Colors.green;
        label = 'Earned';
        icon = Icons.add_circle_outline;
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case 'reversal':
        color = Colors.red;
        label = 'Reversed';
        icon = Icons.remove_circle_outline;
        break;
      case 'redeem':
        color = Colors.blue;
        label = 'Redeemed';
        icon = Icons.account_balance_wallet_outlined;
        break;
      case 'expire':
        color = Colors.grey;
        label = 'Expired';
        icon = Icons.event_busy_outlined;
        break;
      default:
        color = Colors.grey;
        label = type.toUpperCase();
        icon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getAmountPrefix(String type) {
    if (['reversal', 'redeem', 'expire'].contains(type)) return '-';
    return '+';
  }

  Color _getAmountColor(String type) {
    if (['reversal', 'redeem', 'expire'].contains(type)) return Colors.red;
    if (type == 'earn') return Colors.green;
    return Colors.black87;
  }

  void _showLockedBreakdown(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, child) {
            final lockedAsync = ref.watch(lockedCoinsProvider);
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Locked coins – unlock dates',
                              style: AppTextStyles.headingSmall,
                            ),
                            Text(
                              'Coins become redeemable 7 days after delivery',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: lockedAsync.when(
                    data: (data) => data.items.isEmpty
                        ? const Center(
                            child: Text('No locked coins at the moment.'),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(20),
                            itemCount: data.items.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final item = data.items[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order #${item.orderID ?? "—"}',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          'Unlocks on ${item.redeemableAt != null ? DateFormat('dd MMM yyyy').format(item.redeemableAt!) : "—"}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${item.coins} coins',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: Colors.amber.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, WidgetRef ref, int maxCoins) {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Redeem Coins'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Convert your Ithyaraa coins to wallet balance. 1 coin = ₹1 wallet credit.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available to Redeem:',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      '$maxCoins coins',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount to Redeem',
                  hintText: 'Enter coins',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixText: 'coins',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final coins = int.tryParse(controller.text);
                      if (coins == null || coins <= 0 || coins > maxCoins) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid amount'),
                          ),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        await ref
                            .read(coinBalanceProvider.notifier)
                            .redeemCoins(coins);
                        Navigator.pop(context);
                        _showSuccessDialog(
                          context,
                          '$coins coins converted to wallet successfully!',
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Redeem'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text('Success!', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
