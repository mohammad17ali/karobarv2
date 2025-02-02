import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/constants.dart';
import '../services/fetchLedger.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key}) {
    _ledgerFuture = LedgerService().fetchLedgerData();
  }

  late final Future<List<Map<String, dynamic>>> _ledgerFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "The Zaika Restaurant",
          style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.catNotSelectedBG,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _ledgerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final ledgerData = snapshot.data ?? [];

              return Row(
                children: [
                  // Left panel - Stats and Quick Actions
                  Expanded(
                    flex: isPortrait ? 4 : 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: LedgerBarChart(ledgerData: ledgerData),
                          ),
                          _buildStatsGrid(context),
                          const SizedBox(height: 20),
                          _buildQuickActions(context),
                        ],
                      ),
                    ),
                  ),
                  // Right panel - Charts and Orders
                  Expanded(
                    flex: isPortrait ? 5 : 4,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildOrderStatusChart(context),
                          const SizedBox(height: 20),
                          _buildRecentOrders(context),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      const StatsData("Today's Revenue", "₹12,450", Icons.currency_rupee, AppColors.primary),
      const StatsData("Total Orders", "24", Icons.receipt_long, AppColors.success),
      const StatsData("Avg. Order Value", "₹520", Icons.assessment, AppColors.warning),
      const StatsData("Pending Orders", "3", Icons.pending_actions, AppColors.error),
    ];

    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth > 600 ? 2 : 1,
          childAspectRatio: 1.4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) => StatCard(data: stats[index]),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      ActionData(
        "New Order",
        Icons.add_circle,
            () => _handleNewOrder(context),
      ),
      ActionData(
        "Live Orders",
        Icons.live_tv,
            () => _handleLiveOrders(context),
      ),
      ActionData(
        "Inventory",
        Icons.inventory,
            () => _handleInventory(context),
      ),
      ActionData(
        "Reports",
        Icons.analytics,
            () => _handleReports(context),
      ),
    ];

    return Column(
      children: actions.map((action) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ActionButton(data: action),
      )).toList(),
    );
  }

  // Navigation handlers
  void _handleNewOrder(BuildContext context) => Navigator.pushNamed(context, '/new-order');
  void _handleLiveOrders(BuildContext context) => Navigator.pushNamed(context, '/live-orders');
  void _handleInventory(BuildContext context) => Navigator.pushNamed(context, '/inventory');
  void _handleReports(BuildContext context) => Navigator.pushNamed(context, '/reports');

  Widget _buildOrderStatusChart(BuildContext context) {
    const data = [
      OrderStatus('Preparing', 5, AppColors.warning),
      OrderStatus('Ready', 3, AppColors.success),
      OrderStatus('Served', 16, AppColors.primary),
    ];

    return Container(
      decoration: AppDecorations.mainContainer(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Status", style: AppTextStyles.cardTitle),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: data.map((status) => PieChartSectionData(
                  value: status.count.toDouble(),
                  title: '${status.status}\n${status.count}',
                  color: status.color,
                  radius: 100,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: status.color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                )).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(data),
        ],
      ),
    );
  }

  Widget _buildChartLegend(List<OrderStatus> data) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: data.map((status) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(status.status),
        ],
      )).toList(),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: Stream.value(const [
        Order("#1234", "12:30 PM", "2 Masala Dosa, 1 Coffee", "₹240", "Preparing"),
        Order("#1233", "12:15 PM", "1 Biryani, 2 Coke", "₹380", "Ready"),
        Order("#1232", "11:45 AM", "3 Paneer Tikka", "₹450", "Served"),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Recent Orders", style: AppTextStyles.cardTitle),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/all-orders'),
                      child: const Text("View All"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) => OrderTile(
                    order: snapshot.data![index],
                    onTap: () => _handleOrderTap(context, snapshot.data![index]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleOrderTap(BuildContext context, Order order) {
    Navigator.pushNamed(
      context,
      '/order-details',
      arguments: order,
    );
  }
}

// Data Models
class StatsData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatsData(this.label, this.value, this.icon, this.color);
}

class ActionData {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ActionData(this.label, this.icon, this.onPressed);
}

class OrderStatus {
  final String status;
  final int count;
  final Color color;

  const OrderStatus(this.status, this.count, this.color);
}

class Order {
  final String id;
  final String time;
  final String items;
  final String total;
  final String status;

  const Order(this.id, this.time, this.items, this.total, this.status);
}

// Reusable Widget Components
class StatCard extends StatelessWidget {
  final StatsData data;

  const StatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.mainContainer(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, color: data.color, size: 32),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primaryDark,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyTextDark.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final ActionData data;

  const ActionButton({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(data.icon, size: 20),
      label: Text(data.label, style: AppTextStyles.buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: data.onPressed,
    );
  }
}

class OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderTile({
    super.key,
    required this.order,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Preparing':
        return AppColors.warning;
      case 'Ready':
        return AppColors.success;
      case 'Served':
        return AppColors.primary;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${order.id} • ${order.time}",
                    style: AppTextStyles.bodyTextDark.copyWith(
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    order.items,
                    style: AppTextStyles.bodyTextDark.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(order.total, style: AppTextStyles.priceText),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LedgerBarChart extends StatefulWidget {
  final List<Map<String, dynamic>> ledgerData;

  const LedgerBarChart({
    super.key,
    required this.ledgerData,
  });

  @override
  State<LedgerBarChart> createState() => _LedgerBarChartState();
}

class _LedgerBarChartState extends State<LedgerBarChart> {
  int touchedIndex = -1;

  List<Map<String, dynamic>> get processedData {
    try {
      final validData = widget.ledgerData.where((entry) =>
      entry['date'] != null && entry['totalSales'] != null).toList();
      validData.sort((a, b) => _parseDate(a['date']).compareTo(_parseDate(b['date'])));
      return validData.reversed.take(7).toList().reversed.toList();
    } catch (e) {
      return [];
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (processedData.isEmpty) {
      return const Center(child: Text("No revenue data available"));
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Revenue Overview',
              style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Last 7 Days',
              style: AppTextStyles.bodyTextDark.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppColors.primaryDark,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final totalSales = processedData[groupIndex]['totalSales'];
                        return BarTooltipItem(
                          '₹${NumberFormat('#,##,##0').format(totalSales)}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: DateFormat('MMM d').format(
                                _parseDate(processedData[groupIndex]['date']),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      setState(() {
                        touchedIndex = response?.spot?.touchedBarGroupIndex ?? -1;
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => _bottomTitleWidget(value),
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) => _leftTitleWidget(value),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                  barGroups: processedData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final totalSales = entry.value['totalSales'] as num;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: totalSales.toDouble(),
                          color: _getBarColor(index),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegendIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitleWidget(double value) {
    final index = value.toInt();
    if (index >= processedData.length) return const SizedBox.shrink();

    return Transform.rotate(
      angle: -0.5,
      child: Text(
        DateFormat('MMM d').format(DateTime.parse(processedData[index]['date'])),
        style: AppTextStyles.bodyTextDark.copyWith(fontSize: 12),
      ),
    );
  }

  Widget _leftTitleWidget(double value) {
    return Text(
      '₹${NumberFormat.compact().format(value)}',
      style: AppTextStyles.bodyTextDark.copyWith(fontSize: 12),
    );
  }

  Color _getBarColor(int index) {
    return touchedIndex == index
        ? AppColors.primary
        : AppColors.primaryLight;
  }

  Widget _buildLegendIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(AppColors.primaryLight, 'Daily Revenue'),
        const SizedBox(width: 16),
        _buildLegendItem(AppColors.primary, 'Selected Day'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodyTextDark.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}