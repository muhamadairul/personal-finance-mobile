import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pencatat_keuangan/config/app_theme.dart';
import 'package:pencatat_keuangan/models/wallet.dart';
import 'package:pencatat_keuangan/providers/wallet_provider.dart';

const _walletIcons = <IconData>[
  Icons.account_balance_wallet,
  Icons.account_balance,
  Icons.credit_card,
  Icons.savings,
  Icons.payment,
  Icons.money,
  Icons.currency_exchange,
  Icons.smartphone,
  Icons.store,
  Icons.business_center,
  Icons.diamond,
  Icons.attach_money,
];

const _walletColors = <int>[
  0xFF2196F3,
  0xFF4CAF50,
  0xFFFF9800,
  0xFF9C27B0,
  0xFFE91E63,
  0xFF00BCD4,
  0xFF795548,
  0xFF607D8B,
  0xFFFF5722,
  0xFF3F51B5,
  0xFF009688,
  0xFFFFC107,
];

class WalletFormScreen extends ConsumerStatefulWidget {
  const WalletFormScreen({super.key});

  @override
  ConsumerState<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends ConsumerState<WalletFormScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  String _type = 'cash';
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  bool _isEditing = false;
  Wallet? _editingWallet;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallet = ModalRoute.of(context)?.settings.arguments as Wallet?;
    if (wallet != null && !_isEditing) {
      _isEditing = true;
      _editingWallet = wallet;
      _nameController.text = wallet.name;
      _balanceController.text = wallet.balance.toStringAsFixed(0);
      _type = wallet.type;
      _selectedIconIndex = _walletIcons.indexWhere(
        (icon) => icon.codePoint == wallet.icon,
      );
      if (_selectedIconIndex == -1) _selectedIconIndex = 0;
      _selectedColorIndex = _walletColors.indexOf(wallet.color);
      if (_selectedColorIndex == -1) _selectedColorIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dompet tidak boleh kosong'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final balance =
        double.tryParse(_balanceController.text.replaceAll('.', '')) ?? 0;

    setState(() => _isSaving = true);

    final wallet = Wallet(
      id: _editingWallet?.id ?? 0,
      name: name,
      type: _type,
      balance: balance,
      icon: _walletIcons[_selectedIconIndex].codePoint,
      color: _walletColors[_selectedColorIndex],
    );

    try {
      if (_isEditing) {
        await ref.read(walletProvider.notifier).updateWallet(wallet);
      } else {
        await ref.read(walletProvider.notifier).addWallet(wallet);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Dompet berhasil diperbarui'
                  : 'Dompet berhasil ditambahkan',
            ),
            backgroundColor: AppColors.income,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan dompet'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Dompet' : 'Tambah Dompet',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(
                    _walletColors[_selectedColorIndex],
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _walletIcons[_selectedIconIndex],
                  color: Color(_walletColors[_selectedColorIndex]),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Name
            _sectionLabel('NAMA DOMPET'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: GoogleFonts.poppins(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Contoh: Tunai, BCA, OVO...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Balance
            _sectionLabel('SALDO AWAL'),
            const SizedBox(height: 8),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 15),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Type
            _sectionLabel('TIPE DOMPET'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _typeBtn('cash', 'Tunai', Icons.money),
                  _typeBtn('bank', 'Bank', Icons.account_balance),
                  _typeBtn('ewallet', 'E-Wallet', Icons.smartphone),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            _sectionLabel('PILIH IKON'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_walletIcons.length, (i) {
                  final sel = i == _selectedIconIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = i),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: sel
                            ? Color(_walletColors[_selectedColorIndex])
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: sel
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        _walletIcons[i],
                        color: sel ? Colors.white : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Color
            _sectionLabel('PILIH WARNA'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_walletColors.length, (i) {
                  final sel = i == _selectedColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = i),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(_walletColors[i]),
                        shape: BoxShape.circle,
                        border: sel
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: Color(
                                    _walletColors[i],
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: sel
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _isSaving
                    ? 'Menyimpan...'
                    : (_isEditing ? 'Perbarui Dompet' : 'Simpan Dompet'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _typeBtn(String type, String label, IconData icon) {
    final sel = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? AppColors.primary.withValues(alpha: 0.1) : null,
            borderRadius: BorderRadius.circular(14),
            border: sel
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: sel ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
