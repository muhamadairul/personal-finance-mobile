import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pencatat_keuangan/config/app_theme.dart';
import 'package:pencatat_keuangan/providers/subscription_provider.dart';
import 'package:pencatat_keuangan/screens/subscription/qris_payment_screen.dart';
import 'package:pencatat_keuangan/screens/subscription/va_payment_screen.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final String planId;

  const PaymentMethodScreen({required this.planId, super.key});

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = false;

  SubscriptionPlan? get _selectedPlan {
    final plans = ref.read(subscriptionProvider).plans;
    try {
      return plans.firstWhere((p) => p.id == widget.planId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleQris() async {
    setState(() => _isLoading = true);
    final data =
        await ref.read(subscriptionProvider.notifier).payQris(widget.planId);
    setState(() => _isLoading = false);

    if (data != null && mounted) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => QrisPaymentScreen(paymentData: data),
        ),
      );
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _handleVa(String bankCode) async {
    setState(() => _isLoading = true);
    final data = await ref
        .read(subscriptionProvider.notifier)
        .payVa(widget.planId, bankCode);
    setState(() => _isLoading = false);

    if (data != null && mounted) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => VaPaymentScreen(paymentData: data),
        ),
      );
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _handleEwallet(String channelCode) async {
    setState(() => _isLoading = true);
    final data = await ref
        .read(subscriptionProvider.notifier)
        .payEwallet(widget.planId, channelCode);
    setState(() => _isLoading = false);

    if (data != null && mounted) {
      // E-Wallet: for now show a snackbar with instructions
      // Deep link handling can be enhanced later
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pembayaran $channelCode telah dibuat. Cek notifikasi di aplikasi $channelCode Anda.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _selectedPlan;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Pilih Pembayaran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan summary card
                if (plan != null) _buildPlanSummary(plan),
                const SizedBox(height: 28),

                // QRIS
                _buildSectionTitle('QRIS'),
                const SizedBox(height: 10),
                _buildPaymentOption(
                  icon: Icons.qr_code_2,
                  title: 'Scan QRIS',
                  subtitle:
                      'Bayar dengan semua e-wallet & m-banking',
                  color: const Color(0xFF6C5CE7),
                  onTap: _handleQris,
                ),

                const SizedBox(height: 24),

                // Virtual Account
                _buildSectionTitle('Virtual Account'),
                const SizedBox(height: 10),
                ...[
                  ('BCA', 'Bank BCA', const Color(0xFF003B82)),
                  ('BNI', 'Bank BNI', const Color(0xFFF26522)),
                  ('BRI', 'Bank BRI', const Color(0xFF00529C)),
                  ('MANDIRI', 'Bank Mandiri', const Color(0xFF003066)),
                  ('PERMATA', 'Bank Permata', const Color(0xFF009B3A)),
                ].map((bank) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildPaymentOption(
                        icon: Icons.account_balance,
                        title: bank.$2,
                        subtitle: 'Transfer via ${bank.$2}',
                        color: bank.$3,
                        onTap: () => _handleVa(bank.$1),
                      ),
                    )),

                const SizedBox(height: 24),

                // E-Wallet
                _buildSectionTitle('E-Wallet'),
                const SizedBox(height: 10),
                ...[
                  ('OVO', 'OVO', const Color(0xFF4C3494)),
                  ('DANA', 'DANA', const Color(0xFF108EE9)),
                  ('SHOPEEPAY', 'ShopeePay', const Color(0xFFEE4D2D)),
                  ('LINKAJA', 'LinkAja', const Color(0xFFE42313)),
                ].map((ew) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildPaymentOption(
                        icon: Icons.account_balance_wallet,
                        title: ew.$2,
                        subtitle: 'Bayar dengan ${ew.$2}',
                        color: ew.$3,
                        onTap: () => _handleEwallet(ew.$1),
                      ),
                    )),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Membuat pembayaran...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanSummary(SubscriptionPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paket ${plan.name}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  plan.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(plan.price),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
