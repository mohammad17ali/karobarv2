// update_orders.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../assets/keys.dart';

class UpdateOrders {
  // Airtable API URL for the 'Orders' table
  // Ensure this matches the base ID and table name used for fetching
  static const String _apiUrl = "https://api.airtable.com/v0/appWaAdFLtWA1IAZM/Orders";
  static const String _apiKey = Keys.airtableAPIkey;

  static Future<bool> updateOrderStatus(List<String> airtableRecordIds, String newStatus) async {
    if (airtableRecordIds.isEmpty) {
      print('No Airtable record IDs provided for status update.');
      return true; // Nothing to update, consider it a success
    }

    final List<Map<String, dynamic>> recordsToUpdate = [];
    for (String id in airtableRecordIds) {
      recordsToUpdate.add({
        "id": id, // The Airtable record ID
        "fields": {
          "Status": newStatus, // The field to update
        },
      });
    }

    try {
      final response = await http.patch(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "records": recordsToUpdate,
        }),
      );

      if (response.statusCode == 200) {
        // Successfully updated
        return true;
      } else {
        // Log error for debugging
        print('Failed to update order status. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  static Future<bool> addItemsToOrder(int orderNum, List<Map<String, dynamic>> newItems) async {
    if (newItems.isEmpty) {
      return true; // Nothing to add
    }

    final List<Map<String, dynamic>> recordsToCreate = [];
    for (var item in newItems) {

      recordsToCreate.add({
        "fields": {
          "OrderNum": orderNum,
          "ItemName": item['name'],
          "Amount": (item['price'] * (item['quantity'] ?? 1)).toDouble(),
          "Status": "Active",
          "OrderID": "user_id_placeholder",
        },
      });
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "records": recordsToCreate,
        }),
      );

      if (response.statusCode == 200) {
        // Successfully created records
        return true;
      } else {
        print('Failed to add items to order. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding items to order: $e');
      return false;
    }
  }

  static Future<bool> cancelOrder(List<String> airtableRecordIds) async {
    return await updateOrderStatus(airtableRecordIds, 'Cancelled');
  }

  static Future<bool> completeOrder(List<String> airtableRecordIds) async {
    return await updateOrderStatus(airtableRecordIds, 'Completed');
  }
}
