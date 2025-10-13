// import 'package:flutter/material.dart' hide DateUtils;
// import '../../models/expense.dart';
// import '../../service/expense_service.dart';
// import '../../utils/currency_utils.dart';
// import '../../utils/date_utils.dart';
// import '../screens/advenced_expense/add_expense_screen.dart'; 


// class ExpenseListScreen extends StatefulWidget {
//   const ExpenseListScreen({super.key});

//   @override
//   State<ExpenseListScreen> createState() => _ExpenseListScreenState();
// }

// class _ExpenseListScreenState extends State<ExpenseListScreen> {
//   Future<void>? _dataFuture;

//   @override
//   void initState() {
//     super.initState();
//     _dataFuture = _loadInitialData(); // Mulai memuat data
//   }

//   Future<void> _loadInitialData() async {
//     // Memanggil loadInitialData untuk memastikan data dimuat
//     await ExpenseService().loadInitialData();
//     setState(() {}); // Rebuild setelah data dimuat
//   }

//   // Helper untuk menghitung total
//   double _calculateTotal(List<Expense> expenses) {
//     return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
//   }

//   // Method untuk mendapatkan warna berdasarkan kategori (dipindahkan ke sini)
//   Color _getCategoryColor(String category) {
//     switch (category.toLowerCase()) {
//       case 'makanan': return Colors.orange;
//       case 'transportasi': return Colors.green;
//       case 'utilitas': return Colors.purple;
//       case 'hiburan': return Colors.pink;
//       case 'pendidikan': return Colors.blue;
//       default: return Colors.grey;
//     }
//   }

//   // Method untuk mendapatkan icon berdasarkan kategori
//   IconData _getCategoryIcon(String category) {
//     switch (category.toLowerCase()) {
//       case 'makanan': return Icons.restaurant;
//       case 'transportasi': return Icons.directions_car;
//       case 'utilitas': return Icons.home;
//       case 'hiburan': return Icons.movie;
//       case 'pendidikan': return Icons.school;
//       default: return Icons.attach_money;
//     }
//   }
  
//   // Method untuk menampilkan detail (dipindahkan dari code lama)
//   void _showExpenseDetails(BuildContext context, Expense expense) {
//      showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Jumlah: ${CurrencyUtils.formatCurrency(expense.amount)}'),
//             const SizedBox(height: 8),
//             Text('Kategori: ${expense.category}'),
//             const SizedBox(height: 8),
//             Text('Tanggal: ${DateUtils.formatDate(expense.date)}'),
//             const SizedBox(height: 8),
//             Text('Deskripsi: ${expense.description}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Tutup'),
//           ),
//         ],
//       ),
//     );
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100, // Warna latar belakang konsisten
//       appBar: AppBar(
//         title: const Text(
//           'Daftar Pengeluaran',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.blue,
//       ),
//       body: FutureBuilder<void>(
//         future: _dataFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
//           }

//           // Ambil data pengeluaran yang sudah difilter berdasarkan user
//           final expenses = ExpenseService().expenses;
//           final totalAmount = _calculateTotal(expenses);

//           return Column(
//             children: [
//               // Header dengan total pengeluaran
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border(
//                     bottom: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       blurRadius: 5,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Total Pengeluaran',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.blue.shade600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       CurrencyUtils.formatCurrency(totalAmount),
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // ListView untuk menampilkan daftar pengeluaran
//               Expanded(
//                 child: expenses.isEmpty
//                     ? const Center(child: Text("Belum ada pengeluaran yang dicatat."))
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: expenses.length,
//                         itemBuilder: (context, index) {
//                           final expense = expenses[index];
//                           return _buildExpenseListItem(context, expense);
//                         },
//                       ),
//               ),
//             ],
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
//           );
//           _loadInitialData(); // Muat ulang data setelah menambahkan
//         },
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   // Widget helper untuk membuat item daftar pengeluaran (Gaya konsisten)
//   Widget _buildExpenseListItem(BuildContext context, Expense expense) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: CircleAvatar(
//           backgroundColor: _getCategoryColor(expense.category),
//           child: Icon(
//             _getCategoryIcon(expense.category),
//             color: Colors.white,
//             size: 20,
//           ),
//         ),
//         title: Text(
//           expense.title,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         subtitle: Text(
//           '${expense.category} • ${DateUtils.formatDate(expense.date)}',
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontSize: 13,
//           ),
//         ),
//         trailing: Text(
//           expense.formattedAmount, // Menggunakan formattedAmount dari model
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Colors.red[600],
//           ),
//         ),
//         onTap: () {
//           _showExpenseDetails(context, expense);
//         },
//       ),
//     );
//   }
// }