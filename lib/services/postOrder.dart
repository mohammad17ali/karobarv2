import 'dart:convert';
import 'package:http/http.dart' as http;
import '../assets/keys.dart';


class OrderService {
  static const String _baseUrl = "https://api.airtable.com/v0/appWaAdFLtWA1IAZM/Orders";
  static const String _apiKey = Keys.airtableAPIkey;

  static Future<void> postOrders(List<Map<String, dynamic>> cartList, String userId, String outletId, int orderNum) async {
    try {
      List<Map<String, dynamic>> records = cartList.map((item) {
        return {
          "fields": {
            "OrderID": "ord${item['id']}_${DateTime.now().millisecondsSinceEpoch}",
            "OrderNum": orderNum,
            "User_ID": userId,
            "Outlet_ID": outletId,
            "Product_ID": item['Product_ID'],
            "ItemName": item['name'],
            "Quantity": item['quantity'],
            "Amount": item['quantity'] * item['price'],
            "Status": "Active",
          }
        };
      }).toList();

      final Map<String, dynamic> body = {
        "records": records,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Orders posted successfully!");
      } else {
        print("Failed to post orders: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error posting orders: $e");
    }
  }
}


