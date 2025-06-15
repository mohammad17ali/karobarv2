import 'package:flutter/material.dart';
import 'home.dart';
import '../services/fetchLedger.dart';
import '../components/sidebar.dart';
import '../constants/constants.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  final LedgerService _ledgerService = LedgerService();
  late Future<List<Map<String, dynamic>>> _ledgerData;
  int _toggleIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadLedgerData();
  }

  void _loadLedgerData() {
    _ledgerData = _ledgerService.fetchLedgerData();
  }

  void _handleToggle(int index) {
    setState(() {
      _toggleIndex = index;
      if (_toggleIndex == 0) {
        Navigator.pop(
            context
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Sidebar(
          //   cartItems: const [],
          //   onOrderSuccess: () {},
          // ),
          Expanded(child: _buildLedgerContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    title: Text(
      "Golden Rice, Casa Bella",
      style: AppTextStyles.titleLarge(context),
    ),
    backgroundColor: AppColors.primary,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 30.0),
        child: _buildToggleButtons(),
      ),
    ],
  );

  Widget _buildToggleButtons() => ToggleButtons(
    isSelected: [_toggleIndex == 0, _toggleIndex == 1],
    onPressed: _handleToggle,
    borderRadius: BorderRadius.circular(16.0),
    selectedBorderColor: Colors.white12,
    borderColor: Colors.white12,
    selectedColor: AppColors.white,
    fillColor: AppColors.primaryLight,
    color: AppColors.primaryLight.withOpacity(0.7),
    constraints: const BoxConstraints(
      minWidth: 100.0,
      minHeight: 40.0,
    ),
    children: const [
      Text('Menu', style: TextStyle(fontSize: 14)),
      Text('Dashboard', style: TextStyle(fontSize: 14)),
    ],
  );

  Widget _buildLedgerContent() => FutureBuilder<List<Map<String, dynamic>>>(
    future: _ledgerData,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(
          child: Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: AppColors.error),
          ),
        );
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(
          child: Text(
            'No ledger data available.',
            style: AppTextStyles.bodyTextDark(context),
          ),
        );
      }

      return _buildLedgerTable(snapshot.data!);
    },
  );

  Widget _buildLedgerTable(List<Map<String, dynamic>> ledgerData) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Container(
        decoration: AppDecorations.mainContainer(context),
        child: DataTable(
          columnSpacing: 20.0,
          columns: _buildTableColumns(),
          rows: _buildTableRows(ledgerData),
        ),
      ),
    ),
  );

  List<DataColumn> _buildTableColumns() => const [
    DataColumn(
      label: Text(
        'Date',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.primaryDark,
        ),
      ),
    ),
    DataColumn(
      label: Text(
        'Total Sales (₹)',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.primaryDark,
        ),
      ),
    ),
  ];

  List<DataRow> _buildTableRows(List<Map<String, dynamic>> ledgerData) =>
      ledgerData.map((entry) {
        return DataRow(
          cells: [
            DataCell(Text(
              entry['date'],
              style: AppTextStyles.bodyTextDark(context),
            )),
            DataCell(Text(
              entry['totalSales'].toString(),
              style: AppTextStyles.bodyTextDark(context),
            )),
          ],
        );
      }).toList();
}