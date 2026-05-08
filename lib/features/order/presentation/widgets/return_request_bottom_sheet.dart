import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/bunny_cdn_service.dart';
import '../../domain/entities/order_item.dart';
import '../providers/order_providers.dart';

/// Bottom sheet for submitting a return request for an order item
class ReturnRequestBottomSheet extends ConsumerStatefulWidget {
  final OrderItemEntity item;
  final VoidCallback onSuccess;

  const ReturnRequestBottomSheet({
    super.key,
    required this.item,
    required this.onSuccess,
  });

  @override
  ConsumerState<ReturnRequestBottomSheet> createState() => _ReturnRequestBottomSheetState();
}

class _ReturnRequestBottomSheetState extends ConsumerState<ReturnRequestBottomSheet> {
  final List<String> _reasons = [
    "Size mismatch",
    "Defective product",
    "Wrong item delivered",
    "Quality not as expected",
    "Changed my mind",
  ];

  String? _selectedReason;
  final TextEditingController _commentsController = TextEditingController();
  String _returnType = 'replacement'; // 'replacement' or 'refund'
  
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  String _loadingMessage = '';

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for return')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _loadingMessage = 'Uploading photos...';
    });

    try {
      // 1. Upload photos to BunnyCDN if any
      final List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final bunnyService = BunnyCdnService();
        for (var i = 0; i < _selectedImages.length; i++) {
          setState(() {
            _loadingMessage = 'Uploading photo ${i + 1} of ${_selectedImages.length}...';
          });
          final url = await bunnyService.uploadImage(File(_selectedImages[i].path));
          imageUrls.add(url);
        }
      }

      setState(() {
        _loadingMessage = 'Submitting request...';
      });

      // 2. Submit return request to backend
      final returnUseCase = ref.read(returnOrderUseCaseProvider);
      await returnUseCase(
        orderID: widget.item.orderID,
        orderItemID: widget.item.orderItemID,
        returnType: _returnType,
        returnReason: _selectedReason!,
        returnComments: _commentsController.text.isNotEmpty ? _commentsController.text : null,
        returnPhotos: imageUrls.isNotEmpty ? imageUrls : null,
      );

      if (!mounted) return;

      // 3. Handle success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return request submitted successfully')),
      );
      widget.onSuccess();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _loadingMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text('Return Item', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            Text(
              widget.item.productName,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            // Reason Dropdown
            Text('Reason for Return', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              hint: const Text('Select a reason'),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items: _reasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Comments
            Text('Comments / Remarks (Optional)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us more about the issue...',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Photos
            Text('Upload Photos (Optional)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return InkWell(
                      onTap: _pickImages,
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(_selectedImages[index].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Return Type
            Text('What would you like?', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _returnType = 'replacement'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _returnType == 'replacement' ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _returnType == 'replacement' ? Colors.blue : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Replacement',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _returnType == 'replacement' ? Colors.blue.shade700 : Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            'Receive a fresh piece',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _returnType = 'refund'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _returnType == 'refund' ? Colors.red.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _returnType == 'refund' ? Colors.red : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Return & Refund',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _returnType == 'refund' ? Colors.red.shade700 : Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            'Get your money back',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(_loadingMessage),
                        ],
                      )
                    : const Text('Submit Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
