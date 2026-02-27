import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pencatat_keuangan/config/app_theme.dart';
import 'package:pencatat_keuangan/services/api_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.poppins(
            fontSize: 20,
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
            // Management Section
            _sectionTitle('PENGELOLAAN'),
            const SizedBox(height: 12),
            _settingsTile(
              icon: Icons.category_outlined,
              color: const Color(0xFF845EC2),
              title: 'Kelola Kategori',
              subtitle: 'Atur kategori pemasukan & pengeluaran',
              onTap: () => Navigator.pushNamed(context, '/categories'),
            ),
            _settingsTile(
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF00C9A7),
              title: 'Kelola Dompet',
              subtitle: 'Atur dompet dan metode pembayaran',
              onTap: () => Navigator.pushNamed(context, '/wallets'),
            ),
            const SizedBox(height: 24),

            // Data Section
            _sectionTitle('DATA'),
            const SizedBox(height: 12),
            _settingsTile(
              icon: Icons.file_download_outlined,
              color: const Color(0xFF2196F3),
              title: 'Ekspor Data',
              subtitle: 'Unduh data transaksi Anda',
              onTap: () => _showExportSheet(context, ref),
            ),
            const SizedBox(height: 24),

            // About Section
            _sectionTitle('TENTANG'),
            const SizedBox(height: 12),
            _settingsTile(
              icon: Icons.info_outline,
              color: const Color(0xFF4ECDC4),
              title: 'Tentang Aplikasi',
              subtitle: 'Versi dan informasi aplikasi',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Pencatat Keuangan',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Pencatat Keuangan',
              ),
            ),
            _settingsTile(
              icon: Icons.privacy_tip_outlined,
              color: const Color(0xFF607D8B),
              title: 'Kebijakan Privasi',
              subtitle: 'Baca kebijakan privasi kami',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kebijakan Privasi akan tersedia segera'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
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

  Widget _settingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showExportSheet(BuildContext context, WidgetRef ref) {
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ekspor Data',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Month & Year selectors
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          isExpanded: true,
                          items: List.generate(12, (i) {
                            final months = [
                              'Januari',
                              'Februari',
                              'Maret',
                              'April',
                              'Mei',
                              'Juni',
                              'Juli',
                              'Agustus',
                              'September',
                              'Oktober',
                              'November',
                              'Desember',
                            ];
                            return DropdownMenuItem(
                              value: i + 1,
                              child: Text(
                                months[i],
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            );
                          }),
                          onChanged: (v) =>
                              setSheetState(() => selectedMonth = v!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedYear,
                        items: List.generate(5, (i) {
                          final year = DateTime.now().year - i;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(
                              '$year',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          );
                        }),
                        onChanged: (v) =>
                            setSheetState(() => selectedYear = v!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.table_chart,
                    color: Colors.green,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Excel',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Format spreadsheet (.xlsx)',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _downloadExport(
                    context,
                    ref,
                    'xlsx',
                    selectedMonth,
                    selectedYear,
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
                title: Text(
                  'PDF',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Format dokumen (.pdf)',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _downloadExport(
                    context,
                    ref,
                    'pdf',
                    selectedMonth,
                    selectedYear,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadExport(
    BuildContext context,
    WidgetRef ref,
    String type,
    int month,
    int year,
  ) async {
    try {
      // Ask user to pick save location first
      final fileName = 'transaksi_${year}_$month.$type';
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan file $type',
        fileName: fileName,
        type: type == 'xlsx' ? FileType.any : FileType.custom,
        allowedExtensions: type == 'xlsx' ? null : [type],
      );

      if (savePath == null) {
        // User cancelled
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ekspor dibatalkan'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mengunduh file $type...'),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      final apiService = ref.read(_apiServiceProvider);
      final endpoint = type == 'xlsx' ? '/export/excel' : '/export/pdf';

      final response = await apiService.getBytes(
        endpoint,
        queryParameters: {'month': month, 'year': year},
      );

      // Write directly to user-chosen path
      final file = File(savePath);
      await file.writeAsBytes(response.data!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File $fileName berhasil disimpan!'),
            backgroundColor: AppColors.income,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh file $type'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }
}

// Simple provider to access ApiService in ConsumerWidget
final _apiServiceProvider = Provider((ref) => ApiService());
