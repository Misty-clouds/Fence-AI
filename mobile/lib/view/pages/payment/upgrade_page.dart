import 'package:flutter/material.dart';
import 'package:fence_ai/constants/styles/color.dart';
import 'package:fence_ai/constants/styles/text_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class UpgradePage extends StatefulWidget {
  const UpgradePage({super.key});

  @override
  State<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  bool _isProcessing = false;
  String? _selectedPlan;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'monthly',
      'name': 'Monthly Premium',
      'price': 5000,
      'currency': 'NGN',
      'period': 'month',
      'features': [
        'Unlimited land research prompts',
        'Unlimited AI chat conversations',
        'Advanced analytics & insights',
        'Priority support',
        'Export reports & data',
      ],
    },
    {
      'id': 'yearly',
      'name': 'Yearly Premium',
      'price': 50000,
      'currency': 'NGN',
      'period': 'year',
      'savings': '17% savings',
      'features': [
        'Everything in Monthly',
        'Save 17% with annual billing',
        'Early access to new features',
        'Dedicated account manager',
        'Custom integrations',
      ],
    },
  ];

  Future<void> _initiatePayment() async {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a plan'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final plan = _plans.firstWhere((p) => p['id'] == _selectedPlan);
      
      // Call your Next.js server to initialize InterSwitch payment
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/payments/interswitch/initialize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': plan['price'],
          'serviceId': 'fence_ai_${plan['id']}',
          'customerEmail': 'user@example.com', // TODO: Get from auth
          'customerName': 'User Name', // TODO: Get from auth
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final checkoutUrl = data['data']['checkoutUrl'] as String;
          final formFields = data['data']['formFields'] as Map<String, dynamic>;
          
          // Create HTML form and submit to InterSwitch
          await _submitToInterSwitch(checkoutUrl, formFields);
        } else {
          throw Exception(data['error'] ?? 'Payment initialization failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _submitToInterSwitch(String checkoutUrl, Map<String, dynamic> formFields) async {
    // Build query string from form fields
    final queryParams = formFields.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    final fullUrl = '$checkoutUrl?$queryParams';
    
    final uri = Uri.parse(fullUrl);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not launch payment URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text1),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upgrade to Premium',
          style: AppTextStyles.titleSmall(color: AppColors.text1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary1,
                            AppColors.primary1.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unlock Full Potential',
                            style: AppTextStyles.titleLarge(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Get unlimited access to all premium features and take your land research to the next level.',
                            style: AppTextStyles.regularText(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'Choose Your Plan',
                      style: AppTextStyles.titleSmall(color: AppColors.text1),
                    ),
                    const SizedBox(height: 16),
                    
                    ..._plans.map((plan) => _buildPlanCard(plan)).toList(),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary1,
                    foregroundColor: AppColors.text3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_open, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Continue to Payment',
                              style: AppTextStyles.titleSmall(color: AppColors.text3),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == plan['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary2 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary1 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary1.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['name'],
                        style: AppTextStyles.titleSmall(color: AppColors.text1),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '₦${(plan['price'] as int).toStringAsFixed(0)}',
                            style: AppTextStyles.titleLarge(color: AppColors.primary1)
                                .copyWith(fontSize: 28),
                          ),
                          Text(
                            '/${plan['period']}',
                            style: AppTextStyles.regularText(color: AppColors.text2),
                          ),
                        ],
                      ),
                      if (plan['savings'] != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary1.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            plan['savings'],
                            style: AppTextStyles.regularText(color: AppColors.primary1)
                                .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary1 : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary1 : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...((plan['features'] as List<String>).map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.primary1,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTextStyles.regularText(color: AppColors.text1)
                            .copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }
}
