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
  // Gunakan instance ExpenseService untuk data
  final ExpenseService _expenseService = ExpenseService();
  // Gunakan instance StatisticsService untuk perhitungan
  late final StatisticsService _statisticsService;
  
  @override
  void initState() {
    super.initState();
    // Inisialisasi StatisticsService dengan ExpenseService
    _statisticsService = StatisticsService(_expenseService);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _expenseService.categories;
    // Persiapan data untuk grafik
    final totalPerCategory = _statisticsService.totalPerCategory;
    final totalPerMonth = _statisticsService.totalPerMonth;
    final sortedMonths = totalPerMonth.keys.toList()..sort();

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
            // Grafik Pengeluaran per Kategori (Pie Chart)
            _buildChartCard(
              title: 'Pengeluaran per Kategori',
              child: SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _buildPieChartSections(totalPerCategory, categories),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Grafik Pengeluaran Bulanan (Bar Chart)
            _buildChartCard(
              title: 'Pengeluaran Bulanan',
              child: AspectRatio(
                aspectRatio: 1.5,
                child: BarChart(
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
          ],
        ),
      ),
    );
  }

  // --- Metode Pembantu ---

  Widget _buildChartCard({required String title, required Widget child}) {
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

  // Menyiapkan data untuk Pie Chart
  List<PieChartSectionData> _buildPieChartSections(
      Map<String, double> totalPerCategory, List<Category> categories) {
    if (totalPerCategory.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: '0%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
      ];
    }
    return totalPerCategory.entries.map((entry) {
      final category = categories.firstWhere((c) => c.name == entry.key);
      final isTouched = false;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
        color: _getCategoryColor(category.name),
        value: entry.value,
        title: '${(entry.value / _statisticsService.totalAll * 100).toStringAsFixed(0)}%',
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
            final monthName = _getMonthName(value.toInt());
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

  // Mendapatkan nama bulan dari angka
  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan'; case 2: return 'Feb'; case 3: return 'Mar';
      case 4: return 'Apr'; case 5: return 'Mei'; case 6: return 'Jun';
      case 7: return 'Jul'; case 8: return 'Agu'; case 9: return 'Sep';
      case 10: return 'Okt'; case 11: return 'Nov'; case 12: return 'Des';
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