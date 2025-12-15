
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/config/diamond_config.dart';
import 'package:clubroyale/core/config/club_royale_theme.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/wallet/services/user_tier_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:go_router/go_router.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _isLoading = false;
  int _amount = 0;
  
  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {
        _amount = int.tryParse(_amountController.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
     _recipientController.dispose();
     _amountController.dispose();
     _messageController.dispose();
     super.dispose();
  }

  Future<void> _submitTransfer() async {
    final diamondService = ref.read(diamondServiceProvider);
    
    // Basic User Validation
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) return;
    
    // Check Tier Permissions
    final userTier = await ref.read(userTierServiceProvider).watchUserTier(currentUser.uid).first;
    
    if (!mounted) return;
    
    if (!userTier.canTransfer) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your tier does not allow P2P transfers. Upgrade to Verified!'))
        );

      return;
    }

    // Basic Form Validation
    if (_recipientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a recipient User ID')));
      return;
    }
    
    if (_amount < DiamondConfig.minTransferAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum transfer is ${DiamondConfig.minTransferAmount} diamonds')));
      return;
    }

    if (_amount > DiamondConfig.maxTransferAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum transfer is ${DiamondConfig.maxTransferAmount} diamonds')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Execute Transfer via Cloud Function
      await diamondService.transferDiamonds(
        _recipientController.text.trim(),
        _amount,
        message: _messageController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer successful! 💎')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Transfer failed: ${e.toString().replaceAll('Exception:', '')}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current user context
    final currentUser = ref.watch(authServiceProvider).currentUser;
    if (currentUser == null) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.black, // Dark theme
      appBar: AppBar(
        title: const Text('Transfer Diamonds'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                 color: Colors.blue.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                   Icon(Icons.info_outline, color: Colors.blue),
                   SizedBox(width: 12),
                   Expanded(child: Text(
                     'Transfers have a 5% fee which is burnt to reduce inflation. Verified Tier required.',
                     style: TextStyle(color: Colors.white70),
                   )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recipient Input
            TextField(
              controller: _recipientController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Recipient User ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: ClubRoyaleTheme.gold),
              ),
            ),
            const SizedBox(height: 16),
            
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.diamond, color: Colors.cyan),
                suffixText: '💎',
              ),
            ),
             const SizedBox(height: 16),
            
            // Message Input (Optional)
            TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Message (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message, color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Calculation Breakdown
            if (_amount > 0) ...[
               _buildBreakdownRow('Amount', '$_amount', false),
               const SizedBox(height: 8),
               _buildBreakdownRow('Fee (5%)', '-${(_amount * DiamondConfig.transferFeePercent).ceil()}', true),
               const Divider(color: Colors.white24, height: 24),
               _buildBreakdownRow(
                 'Recipient Receives', 
                 '${_amount - (_amount * DiamondConfig.transferFeePercent).ceil()}', 
                 false,
                 isTotal: true
               ),
            ],
            
            const Spacer(),
            
            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading || _amount <= 0 ? null : _submitTransfer,
                style: ElevatedButton.styleFrom(
                   backgroundColor: ClubRoyaleTheme.gold,
                   disabledBackgroundColor: Colors.grey.shade800,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Confirm Transfer', 
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBreakdownRow(String label, String value, bool isFee, {bool isTotal = false}) {
     return Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Text(label, style: TextStyle(
           color: isTotal ? Colors.white : Colors.white60,
           fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
           fontSize: isTotal ? 18 : 14,
         )),
         Row(
           children: [
             Text(value, style: TextStyle(
               color: isFee ? Colors.redAccent : (isTotal ? Colors.greenAccent : Colors.white),
               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
               fontSize: isTotal ? 18 : 14,
             )),
             const SizedBox(width: 4),
             const Icon(Icons.diamond, size: 14, color: Colors.cyan),
           ],
         ),
       ],
     );
  }
}
