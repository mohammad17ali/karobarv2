// fetchOrders.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../assets/keys.dart'; // Ensure this path is correct for your project

class FetchOrders {
  static const String apiUrl =
      "https://api.airtable.com/v0/appWaAdFLtWA1IAZM/Orders?sort[0][field]=OrderNum&sort[0][direction]=asc";

  static const String apiKey = Keys.airtableAPIkey;

  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    Map<int, Map<String, dynamic>> aggregatedOrders = {}; // To store unique orders

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        for (var record in data['records']) {
          final fields = record['fields'];
          final String airtableRecordId = record['id'];

          int orderNum = fields['OrderNum'] ?? 1;
          double amount = (fields['Amount'] ?? 0).toDouble();
          String status = fields['Status'] ?? 'Active';
          String itemName = fields['ItemName'] ?? 'Unknown';

          if (aggregatedOrders.containsKey(orderNum)) {
            aggregatedOrders[orderNum]!['Amount'] += amount;
            aggregatedOrders[orderNum]!['ItemNames'].add(itemName);
            (aggregatedOrders[orderNum]!['AirtableRecordIds'] as List<String>).add(airtableRecordId);
          } else {
            aggregatedOrders[orderNum] = {
              'OrderNum': orderNum,
              'Amount': amount,
              'Status': status,
              'OrderID': fields['OrderID'] ?? 'user123',
              'ItemNames': [itemName],
              'AirtableRecordIds': [airtableRecordId],
            };
          }
        }
      } else {
        print('Error fetching orders - Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Network or parsing error fetching orders: $e');
    }

    return aggregatedOrders.values.toList();
  }
}
