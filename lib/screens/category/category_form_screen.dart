import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pencatat_keuangan/config/app_theme.dart';
import 'package:pencatat_keuangan/models/category.dart';
import 'package:pencatat_keuangan/providers/category_provider.dart';

// Available icons for category selection
const _availableIcons = <IconData>[
  Icons.restaurant,
  Icons.directions_car,
  Icons.shopping_bag,
  Icons.receipt_long,
  Icons.movie,
  Icons.medical_services,
  Icons.school,
  Icons.home,
  Icons.flight,
  Icons.sports_esports,
  Icons.pets,
  Icons.card_giftcard,
  Icons.account_balance_wallet,
  Icons.laptop_mac,
  Icons.trending_up,
  Icons.work,
  Icons.coffee,
  Icons.local_gas_station,
  Icons.phone_android,
  Icons.wifi,
  Icons.electric_bolt,
  Icons.water_drop,
  Icons.fitness_center,
  Icons.more_horiz,
];

// Available colors for category selection
const _availableColors = <int>[
  0xFFFF6B6B, // Red
  0xFF4ECDC4, // Teal
  0xFFFFBE0B, // Yellow
  0xFF845EC2, // Purple
  0xFFFF9671, // Orange
  0xFF00C9A7, // Mint
  0xFF4D8076, // Dark Teal
  0xFF2196F3, // Blue
  0xFF00C853, // Green
  0xFFE91E63, // Pink
  0xFFFF9800, // Amber
  0xFF607D8B, // Blue Grey
];

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _nameController = TextEditingController();
  String _type = 'expense';
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  bool _isEditing = false;
  Category? _editingCategory;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final category = ModalRoute.of(context)?.settings.arguments as Category?;
    if (category != null && !_isEditing) {
      _isEditing = true;
      _editingCategory = category;
      _nameController.text = category.name;
      _type = category.type;
      _selectedIconIndex = _availableIcons.indexWhere(
        (icon) => icon.codePoint == category.icon.codePoint,
      );
      if (_selectedIconIndex == -1) _selectedIconIndex = 0;
      _selectedColorIndex = _availableColors.indexOf(category.color);
      if (_selectedColorIndex == -1) _selectedColorIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama kategori tidak boleh kosong'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final category = Category(
      id: _editingCategory?.id ?? 0,
      name: name,
      icon: _availableIcons[_selectedIconIndex],
      color: _availableColors[_selectedColorIndex],
      type: _type,
    );

    bool success;
    if (_isEditing) {
      success = await ref
          .read(categoryProvider.notifier)
          .updateCategory(category);
    } else {
      success = await ref.read(categoryProvider.notifier).addCategory(category);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Kategori berhasil diperbarui'
                  : 'Kategori berhasil ditambahkan',
            ),
            backgroundColor: AppColors.income,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Gagal memperbarui kategori'
                  : 'Gagal menambah kategori',
            ),
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
          _isEditing ? 'Edit Kategori' : 'Tambah Kategori',
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
                    _availableColors[_selectedColorIndex],
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _availableIcons[_selectedIconIndex],
                  color: Color(_availableColors[_selectedColorIndex]),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Name
            _sectionLabel('NAMA KATEGORI'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: GoogleFonts.poppins(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Contoh: Makan, Gaji, Transport...',
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
            _sectionLabel('TIPE'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _typeButton('expense', 'Pengeluaran', Icons.arrow_downward),
                  _typeButton('income', 'Pemasukan', Icons.arrow_upward),
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
                children: List.generate(_availableIcons.length, (index) {
                  final isSelected = index == _selectedIconIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = index),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(_availableColors[_selectedColorIndex])
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        _availableIcons[index],
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
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
                children: List.generate(_availableColors.length, (index) {
                  final isSelected = index == _selectedColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = index),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(_availableColors[index]),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(
                                    _availableColors[index],
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
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
                    : (_isEditing ? 'Perbarui Kategori' : 'Simpan Kategori'),
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

  Widget _typeButton(String type, String label, IconData icon) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
