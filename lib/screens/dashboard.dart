import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/fetchLedger.dart';
import '../constants/constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Map<String, dynamic>>> _ledgerFuture;

  @override
  void initState() {
    super.initState();
    _ledgerFuture = LedgerService().fetchLedgerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          "Golden Rice, Casa Bella",
          style: AppTextStyles.titleLarge(context).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'lib/assets/logoR.png',
              height: 40,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ledgerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ledgerData = snapshot.data ?? [];
          if (ledgerData.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          // Process and sort data
          final processedData = _processLedgerData(ledgerData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RevenueChart(data: processedData),
                const SizedBox(height: 24),
                QuickStats(data: processedData),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _processLedgerData(List<Map<String, dynamic>> data) {
    // Sort by date
    data.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

    // Get last 7 days of data
    return data.reversed.take(7).toList().reversed.toList();
  }
}

class RevenueChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const RevenueChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxRevenue(),
                  barGroups: _createBarGroups(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _bottomTitles,
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _leftTitles,
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxRevenue() {
    final maxSales = data.map((e) => e['totalSales'] as num).reduce((a, b) => a > b ? a : b);
    return (maxSales * 1.2).toDouble(); // Add 20% padding to the top
  }

  List<BarChartGroupData> _createBarGroups() {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: (entry.value['totalSales'] as num).toDouble(),
            color: Colors.pinkAccent,
            width: 60,
            borderRadius: BorderRadius.circular(30),
          ),
        ],
      );
    }).toList();
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    if (value >= data.length) return const SizedBox.shrink();

    final date = DateTime.parse(data[value.toInt()]['date']);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        DateFormat('MMM d').format(date),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    return Text(
      '₹${NumberFormat.compact().format(value)}',
      style: const TextStyle(fontSize: 12),
    );
  }
}

class QuickStats extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const QuickStats({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final highestSale = _getHighestSale();
    final totalRevenue = _calculateTotalRevenue();
    final averageRevenue = _calculateAverageRevenue();

    return Column(
      children: [
        _buildStatCard(
          'Highest Daily Sale',
          '₹${NumberFormat('#,##,###').format(highestSale['totalSales'])}',
          'on ${DateFormat('MMM d').format(DateTime.parse(highestSale['date']))}',
          Icons.trending_up,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'Total Revenue (7 days)',
          '₹${NumberFormat('#,##,###').format(totalRevenue)}',
          'Avg: ₹${NumberFormat('#,##,###').format(averageRevenue)}/day',
          Icons.assessment,
        ),
      ],
    );
  }

  Map<String, dynamic> _getHighestSale() {
    return data.reduce((curr, next) =>
    (curr['totalSales'] as num) > (next['totalSales'] as num) ? curr : next
    );
  }

  double _calculateTotalRevenue() {
    return data.fold(0.0, (sum, item) => sum + (item['totalSales'] as num));
  }

  double _calculateAverageRevenue() {
    final total = _calculateTotalRevenue();
    return total / data.length;
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}