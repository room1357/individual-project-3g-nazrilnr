import 'package:flutter/material.dart';
import '../../service/expense_service.dart'; // Digunakan untuk mendapatkan data dari service
import '../../service/export_service.dart'; // Service yang menangani logika ekspor file

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  // Inisialisasi ExportService instance
  late final ExportService _exportService;
  String _message = '';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi ExportService, dengan dependency ExpenseService
    _exportService = ExportService(ExpenseService());
  }

  // Menangani proses ekspor data
  Future<void> _exportData(Function exportFunction) async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
      _message = 'Mengekspor data... Tunggu sebentar.';
    });

    try {
      // Memanggil fungsi ekspor (CSV atau PDF) dari service
      final result = await exportFunction();
      setState(() {
        _message = result;
      });
    } catch (e) {
      setState(() {
        _message = 'Gagal melakukan ekspor: Terjadi kesalahan. $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Ekspor Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih format laporan:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tombol Ekspor CSV
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // Menonaktifkan tombol saat sedang mengekspor
                      onPressed: _isExporting ? null : () => _exportData(_exportService.exportToCsv),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _isExporting && _message.contains('CSV') ? 'Mengekspor CSV...' : 'Ekspor ke CSV', 
                        style: const TextStyle(fontSize: 16)
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tombol Ekspor PDF
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // Menonaktifkan tombol saat sedang mengekspor
                      onPressed: _isExporting ? null : () => _exportData(_exportService.exportToPdf),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(
                        _isExporting && _message.contains('PDF') ? 'Mengekspor PDF...' : 'Ekspor ke PDF', 
                        style: const TextStyle(fontSize: 16)
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 4,
                      ),
                    ),
                  ),
                  // Pesan status ekspor
                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          _message, 
                          textAlign: TextAlign.center, 
                          style: TextStyle(
                            // Warna pesan disesuaikan dengan keberhasilan atau kegagalan
                            color: _message.contains('Gagal') ? Colors.red.shade700 : Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}