import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Penting untuk cek platform
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data'; 
//import 'dart:html' as html; 

import 'expense_service.dart';
import '../models/expense.dart';

class ExportService {
  final ExpenseService _expenseService;

  ExportService(this._expenseService);

  double get _totalAll {
    return _expenseService.expenses.fold(0.0, (s, e) => s + e.amount);
  }

  // // --- Metode Export CSV (dengan Logika Web) ---
  // Future<String> exportToCsv() async {
  //   final expenses = _expenseService.expenses;
  //   if (expenses.isEmpty) {
  //     return "Tidak ada data pengeluaran untuk diekspor.";
  //   }

    // // 1. Persiapan Data CSV
    // List<List<dynamic>> rows = [
    //   ['ID', 'Judul', 'Jumlah', 'Kategori', 'Tanggal', 'Deskripsi']
    // ];
    // for (var expense in expenses) {
    //   rows.add([
    //     expense.id,
    //     expense.title,
    //     expense.amount,
    //     expense.category,
    //     expense.date.toIso8601String().split('T')[0], // Menggunakan format ISO standar
    //     expense.description,
    //   ]);
    // }
    // String csv = const ListToCsvConverter().convert(rows);
    // final filename = 'expenses_report_${DateTime.now().year}.csv';

    // 2. LOGIKA KONDISIONAL UNTUK WEB
    // if (kIsWeb) {
    //   final bytes = Uint8List.fromList(csv.codeUnits);
    //   final blob = html.Blob([bytes]);
    //   final url = html.Url.createObjectUrlFromBlob(blob);
    //   final anchor = html.document.createElement('a') as html.AnchorElement
    //     ..href = url
    //     ..style.display = 'none'
    //     ..download = filename;
    //   html.document.body!.children.add(anchor);
    //   anchor.click();
    //   html.document.body!.children.remove(anchor);
    //   html.Url.revokeObjectUrl(url);
      
    //   return "File CSV berhasil diunduh ke browser.";
    // } 
    
  //   // 3. LOGIKA MOBILE/DESKTOP (Fallback ke sistem file)
  //   else {
  //     final directory = await getApplicationDocumentsDirectory(); 
  //     final exportDirectory = Directory('${directory.path}/Exports');
      
  //     if (!await exportDirectory.exists()) {
  //         await exportDirectory.create(recursive: true);
  //     }
      
  //     final path = '${exportDirectory.path}/$filename';
  //     final file = File(path);
  //     await file.writeAsString(csv);
      
  //     return "Data berhasil diekspor dan disimpan di: $path";
  //   }
  // }

  // --- Metode Export PDF ---
  Future<String> exportToPdf() async {
    final expenses = _expenseService.expenses;
    if (expenses.isEmpty) {
      return "Tidak ada data pengeluaran untuk diekspor.";
    }

    final doc = pw.Document();
    
    // Persiapan data untuk tabel PDF
    final List<List<String>> tableData = expenses.map((e) => [
      e.title,
      'Rp ${e.amount.toStringAsFixed(0)}',
      e.category,
      // FIX: Ganti e.formattedDate dengan format eksplisit
      '${e.date.day}/${e.date.month}/${e.date.year}', 
      e.description,
    ]).toList();
    
    final headers = ['Judul', 'Jumlah', 'Kategori', 'Tanggal', 'Deskripsi'];

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Pengeluaran', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headers: headers,
                data: tableData,
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total Pengeluaran: Rp ${_totalAll.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );
    
    // Membuka dialog untuk Print/Share/Save PDF (Berfungsi baik di semua platform, termasuk Web)
    await Printing.sharePdf(
      bytes: await doc.save(), 
      filename: 'laporan_pengeluaran_${DateTime.now().year}.pdf'
    );
    
    return "Laporan PDF berhasil dibuat dan siap dibagikan/disimpan.";
  }
}