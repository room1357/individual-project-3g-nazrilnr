import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/category.dart';
import '../../service/expense_service.dart';
import '../../service/statistic_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  late final StatisticsService _statisticsService;
  
  // State untuk melacak bulan yang dipilih pengguna
  int? _selectedMonth; 
  
  @override
  void initState() {
    super.initState();
    _statisticsService = StatisticsService(_expenseService);
    
    // Berlangganan (listener) untuk pembaruan data real-time
    _expenseService.addListener(_updateScreen); 
    
    // Inisialisasi bulan yang dipilih ke bulan terbaru yang tersedia
    final sortedMonths = _statisticsService.totalPerMonth.keys.toList()..sort();
    if (sortedMonths.isNotEmpty) {
        _selectedMonth = sortedMonths.last; 
    }
  }

  void _updateScreen() {
    if (mounted) {
      // Pastikan bulan yang dipilih masih ada dalam data
      final allAvailableMonths = _statisticsService.totalPerMonth.keys.toList();
      if (_selectedMonth != null && !allAvailableMonths.contains(_selectedMonth)) {
          final sorted = allAvailableMonths..sort();
          _selectedMonth = sorted.isNotEmpty ? sorted.last : null;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _expenseService.removeListener(_updateScreen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _expenseService.categories;
    final totalPerCategory = _statisticsService.totalPerCategory;
    final totalPerMonth = _statisticsService.totalPerMonth;
    final sortedMonths = totalPerMonth.keys.toList()..sort();
    final totalAllExpenses = _statisticsService.totalAll;
    
    final allAvailableMonths = _statisticsService.totalPerMonth.keys.toList()..sort();


    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Statistik Pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Grafik Pengeluaran per Kategori (Pie Chart + Legend) ---
            _buildChartCard(
              title: 'Total Pengeluaran Kategori (Semua Data)',
              child: totalPerCategory.isEmpty || totalAllExpenses == 0
                  ? const Center(child: Text("Belum ada data pengeluaran."))
                  : Column(
                      children: [
                        SizedBox(
                          height: 200, 
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _buildPieChartSections(totalPerCategory),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLegend(totalPerCategory, totalAllExpenses),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            
            // --- Grafik Pengeluaran Bulanan (Bar Chart) ---
            _buildChartCard(
              title: 'Pengeluaran Bulanan',
              child: AspectRatio(
                aspectRatio: 1.5,
                child: totalPerMonth.isEmpty
                    ? const Center(child: Text("Belum ada data pengeluaran bulanan."))
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxYForBarChart(totalPerMonth),
                          titlesData: _buildBarChartTitles(sortedMonths),
                          barGroups: _buildBarChartGroups(totalPerMonth, sortedMonths),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barTouchData: BarTouchData(enabled: false),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // --- BAGIAN RINGKASAN BULANAN (PINDAH KE BAWAH) ---
            _buildMonthlySummaryCard(allAvailableMonths),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BARU: KARTU RINGKASAN BULANAN ---
  Widget _buildMonthlySummaryCard(List<int> availableMonths) {
      
      final monthlyCategoryTotals = _selectedMonth != null
          ? _statisticsService.getTotalPerCategoryForMonth(_selectedMonth!)
          : <String, double>{};

      return _buildChartCard(
          title: 'Pengeluaran Bulan ${_getMonthName(_selectedMonth ?? 1, full: true)}',
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // 1. Pemilih Bulan (Hanya ditampilkan jika ada lebih dari 1 bulan data)
                  if (availableMonths.length > 1)
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableMonths.length,
                        itemBuilder: (context, index) {
                          final month = availableMonths[index];
                          final isSelected = month == _selectedMonth;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(_getMonthName(month, full: false)),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedMonth = month;
                                  });
                                }
                              },
                              selectedColor: Colors.blue.shade100,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.blue.shade900 : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  if (availableMonths.length > 1) const SizedBox(height: 16),

                  // 2. Daftar Kategori Pengeluaran untuk bulan ini
                  if (monthlyCategoryTotals.isEmpty)
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("Tidak ada pengeluaran di bulan ini."),
                          ),
                      )
                  else
                      ...monthlyCategoryTotals.entries.map((entry) {
                          final categoryName = entry.key;
                          final amount = entry.value;
                          return _buildMonthlyCategoryItem(categoryName, amount);
                      }).toList(),
              ],
          ),
      );
  }
  
  // WIDGET BARU: Item Daftar Kategori Bulanan
  Widget _buildMonthlyCategoryItem(String categoryName, double amount) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
              children: [
                  // Dot Warna Kategori
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getCategoryColor(categoryName),
                      ),
                  ),
                  const SizedBox(width: 10),
                  // Nama Kategori
                  Expanded(
                      child: Text(
                          categoryName,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                  ),
                  // Jumlah Pengeluaran
                  Text(
                      'Rp ${amount.toStringAsFixed(0)}', // Format uang
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
              ],
          ),
      );
  }

  // --- Metode Pembantu Lainnya ---

  Widget _buildChartCard({required String title, required Widget child}) {
    // ... (kode _buildChartCard sama seperti sebelumnya)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // WIDGET BARU: Legenda Pie Chart
  Widget _buildLegend(Map<String, double> totals, double totalAll) {
    return Wrap(
      spacing: 12, 
      runSpacing: 8, 
      children: totals.entries.map((entry) {
        final percentage = (entry.value / totalAll * 100).toStringAsFixed(1);
        return _buildLegendItem(entry.key, percentage);
      }).toList(),
    );
  }

  Widget _buildLegendItem(String categoryName, String percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getCategoryColor(categoryName),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$categoryName (${percentage}%)',
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }

  // Menyiapkan data untuk Pie Chart
  List<PieChartSectionData> _buildPieChartSections(
      Map<String, double> totalPerCategory) {
    
    final totalAllExpenses = _statisticsService.totalAll;
    
    return totalPerCategory.entries.map((entry) {
      const isTouched = false;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final percentage = (entry.value / totalAllExpenses * 100).toStringAsFixed(0);

      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  // Menyiapkan data untuk Bar Chart
  List<BarChartGroupData> _buildBarChartGroups(
      Map<int, double> totalPerMonth, List<int> sortedMonths) {
    return sortedMonths.map((month) {
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: totalPerMonth[month] ?? 0,
            color: Colors.blue,
            width: 15,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    }).toList();
  }

  // Judul sumbu untuk Bar Chart
  FlTitlesData _buildBarChartTitles(List<int> sortedMonths) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final monthName = _getMonthName(value.toInt(), full: false);
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 4,
              child: Text(monthName, style: const TextStyle(fontSize: 12)),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  // Menghitung nilai Y maksimum untuk Bar Chart
  double _getMaxYForBarChart(Map<int, double> totalPerMonth) {
    if (totalPerMonth.isEmpty) return 0;
    final max = totalPerMonth.values.reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  // Mendapatkan nama bulan dari angka (Diperbarui untuk nama panjang/pendek)
  String _getMonthName(int month, {bool full = false}) {
    switch (month) {
      case 1: return full ? 'Januari' : 'Jan';
      case 2: return full ? 'Februari' : 'Feb';
      case 3: return full ? 'Maret' : 'Mar';
      case 4: return full ? 'April' : 'Apr';
      case 5: return full ? 'Mei' : 'Mei';
      case 6: return full ? 'Juni' : 'Jun';
      case 7: return 'Jul'; case 8: return 'Agu'; case 9: return 'Sep';
      case 10: return full ? 'Oktober' : 'Okt'; case 11: return full ? 'November' : 'Nov'; case 12: return full ? 'Desember' : 'Des';
      default: return '';
    }
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan': return Colors.orange;
      case 'transportasi': return Colors.green;
      case 'utilitas': return Colors.purple;
      case 'hiburan': return Colors.pink;
      case 'pendidikan': return Colors.blue;
      default: return Colors.grey;
    }
  }
}