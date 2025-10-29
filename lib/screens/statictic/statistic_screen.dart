import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _statisticsService = StatisticsService(_expenseService);

    // Dengarkan perubahan data dari kedua service
    _expenseService.addListener(_updateScreen);
    _statistics_serviceAddListenerSafely();

    // Inisialisasi bulan terpilih
    _initSelectedMonth();
  }

  // helper untuk menambahkan listener pada statistics service safely
  void _statistics_serviceAddListenerSafely() {
    try {
      _statistics_service_addListener();
    } catch (_) {
      // fallback: try direct call (rare)
      _statisticsService.addListener(_updateScreen);
    }
  }

  void _statistics_service_addListener() {
    _statisticsService.addListener(_updateScreen);
  }

  void _initSelectedMonth() {
    final sortedMonths = _statisticsService.totalPerMonth.keys.toList()..sort();
    if (sortedMonths.isNotEmpty) {
      _selectedMonth = sortedMonths.last;
    }
  }

  void _updateScreen() {
    if (!mounted) return;

    // Refresh layar dan pastikan _selectedMonth valid
    setState(() {
      final sortedMonths = _statisticsService.totalPerMonth.keys.toList()..sort();
      if (sortedMonths.isNotEmpty) {
        // jika belum ada selected month, pilih bulan terakhir
        if (_selectedMonth == null) {
          _selectedMonth = sortedMonths.last;
        } else {
          // jika selected month hilang dari daftar (mis. data berubah) pilih bulan terakhir
          if (!sortedMonths.contains(_selectedMonth)) {
            _selectedMonth = sortedMonths.last;
          }
        }
      } else {
        // jika tidak ada bulan tersedia, reset
        _selectedMonth = null;
      }
    });
  }

  @override
  void dispose() {
    _expenseService.removeListener(_updateScreen);
    try {
      _statisticsService.removeListener(_updateScreen);
    } catch (_) {}
    super.dispose();
  }

  // ===================== Helper UI ======================

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.green;
      case 'utilitas':
        return Colors.purple;
      case 'hiburan':
        return Colors.pink;
      case 'pendidikan':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMonthlySummaryCard(List<int> availableMonths) {
    final monthlyCategoryTotals = _selectedMonth != null
        ? _statisticsService.getTotalPerCategoryForMonth(_selectedMonth!)
        : <String, double>{};

    return _buildChartCard(
      title:
          'Pengeluaran Bulan ${_getMonthName(_selectedMonth ?? 1, full: true)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        color:
                            isSelected ? Colors.blue.shade900 : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (availableMonths.length > 1) const SizedBox(height: 16),
          if (monthlyCategoryTotals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Tidak ada pengeluaran di bulan ini."),
              ),
            )
          else
            ...monthlyCategoryTotals.entries.map((entry) {
              return _buildMonthlyCategoryItem(entry.key, entry.value);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildMonthlyCategoryItem(String categoryName, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getCategoryColor(categoryName),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              categoryName,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Text(
            'Rp ${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

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
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ===================== Legend (was missing) ======================

  Widget _buildLegend(Map<String, double> totals, double totalAll) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: totals.entries.map((entry) {
        final percentage = totalAll == 0 ? '0.0' : (entry.value / totalAll * 100).toStringAsFixed(1);
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

  // ===================== Chart Helpers ======================

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, double> totalPerCategory) {
    final totalAllExpenses = _statisticsService.totalAll;
    if (totalPerCategory.isEmpty || totalAllExpenses == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: '0%',
          radius: 50,
          titleStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ];
    }
    return totalPerCategory.entries.map((entry) {
      final percentage = (entry.value / totalAllExpenses * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '$percentage%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

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

  double _getMaxYForBarChart(Map<int, double> totalPerMonth) {
    if (totalPerMonth.isEmpty) return 0;
    final max = totalPerMonth.values.reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  String _getMonthName(int month, {bool full = false}) {
    const monthsFull = [
      '',
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
      'Desember'
    ];
    const monthsShort = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return full ? monthsFull[month] : monthsShort[month];
  }

  // ===================== BUILD ======================

  @override
  Widget build(BuildContext context) {
    final totalPerCategory = _statisticsService.totalPerCategory;
    final totalPerMonth = _statistics_service_totalPerMonthSafe();
    final sortedMonths = totalPerMonth.keys.toList()..sort();
    final totalAllExpenses = _statistics_service_totalAllSafe();
    final allAvailableMonths = totalPerMonth.keys.toList()..sort();

    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMonthlySummaryCard(allAvailableMonths),
            const SizedBox(height: 20),
            _buildChartCard(
              title: 'Total Pengeluaran per Kategori',
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
            _buildChartCard(
              title: 'Pengeluaran Bulanan',
              child: AspectRatio(
                aspectRatio: 1.5,
                child: totalPerMonth.isEmpty
                    ? const Center(
                        child: Text("Belum ada data pengeluaran bulanan."))
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxYForBarChart(totalPerMonth),
                          titlesData: _buildBarChartTitles(sortedMonths),
                          barGroups:
                              _buildBarChartGroups(totalPerMonth, sortedMonths),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Safe accessors to avoid rare null-timing issues
  Map<int, double> _statistics_service_totalPerMonthSafe() {
    try {
      return _statisticsService.totalPerMonth;
    } catch (_) {
      return <int, double>{};
    }
  }

  double _statistics_service_totalAllSafe() {
    try {
      return _statisticsService.totalAll;
    } catch (_) {
      return 0.0;
    }
  }
}
