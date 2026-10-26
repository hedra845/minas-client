import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/theme/theme_provider.dart';
import 'package:minas_client/widgets/app_bar.dart';
import 'package:minas_client/widgets/float_action_b.dart';
import 'package:minas_client/widgets/custom_bottom_navigation.dart';
import 'package:minas_client/models/transaction_model.dart';
import 'package:minas_client/services/transactions_service.dart';
import 'package:minas_client/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  // API related state
  final TransactionsService _transactionsService = TransactionsService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadTransactions();
  }

  Future<void> _checkAuthenticationAndLoadTransactions() async {
    // Check if user has a valid token
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'authentication_required'.tr();
        _isLoading = false;
      });
      return;
    }
    _loadTransactions();
  }

  Future<void> _loadTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _transactions.clear();
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await _transactionsService.getTransactions();

      setState(() {
        _transactions = response.transactions;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      // Handle authentication errors - redirect to login
      if (e.toString().contains('Session expired') ||
          e.toString().contains('Access denied') ||
          e.toString().contains('No authentication token')) {
        _handleAuthenticationError();
      }
    }
  }

  void _handleAuthenticationError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('session_expired'.tr()),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'login_button'.tr(),
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale;
    final isRTL = locale.languageCode == 'ar';
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: MinasAppBar(isDarkMode: isDarkMode, themeProvider: themeProvider),
      body: RefreshIndicator(
        onRefresh: () => _loadTransactions(isRefresh: true),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isRTL ? 'كل المعاملات' : 'All Transactions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 5),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/plus-circle-outline.svg',
                    color: isDarkMode ? AppColors.white : AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/form_deposit');
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _loadTransactions(isRefresh: true),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),

            Expanded(
              child:
                  _isLoading && _transactions.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _transactions.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_transactions_found'.tr(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          return TransactionCard(
                            transaction: _transactions[index],
                            locale: locale,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            BottomNavigationHelper.navigateToPage(context, index);
          }
        },
      ),
      floatingActionButton: GradientFABE(),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Locale locale;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = locale.languageCode == 'ar';

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/Vector.svg',
                  color: theme.colorScheme.outline,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isRTL ? transaction.localizedType : transaction.type,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: transaction.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: transaction.statusColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRTL
                            ? transaction.localizedStatus
                            : transaction.status,
                        style: TextStyle(
                          color: transaction.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: app_colors.divider_color),
            Row(
              children: [
                Text(
                  isRTL ? 'الكمية:' : 'Amount:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(transaction.formattedAmount),
                const Spacer(),
                Text(
                  transaction.transactionId,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  isRTL ? 'طريقة الدفع:' : 'Payment Method:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  transaction.paymentMethod?.name.getLocalizedName(
                        isRTL ? 'ar' : 'en',
                      ) ??
                      (isRTL ? 'غير محدد' : 'Not specified'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  isRTL ? 'التاريخ:' : 'Date:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(transaction.formattedDate),
                const Spacer(),
                Text(
                  isRTL ? 'الوقت:' : 'Time:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(transaction.formattedTime),
              ],
            ),
            if (transaction.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    isRTL ? 'الوصف:' : 'Description:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      transaction.description,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (transaction.hasAttachment) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      final url = transaction.attachmentUrl;
                      if (url.isNotEmpty) {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                    icon: const Icon(Icons.attachment, size: 16),
                    label: Text(
                      isRTL ? 'عرض المرفق' : 'View Attachment',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
