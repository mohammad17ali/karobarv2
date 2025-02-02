import 'dart:convert';
import 'package:http/http.dart' as http;
import '../assets/keys.dart';


class LedgerService {
  static const String _baseUrl =
      "https://api.airtable.com/v0/appWaAdFLtWA1IAZM/Ledger";
  static const String _apiToken = Keys.airtableAPIkey;

  Future<List<Map<String, dynamic>>> fetchLedgerData() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {"Authorization": "Bearer $_apiToken"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List records = data['records'];

        return records.map((record) {
          final fields = record['fields'];
          return {
            "dayNum": fields['dayNum'],
            "date": fields['Date'],
            "totalSales": fields['TotalSales'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load ledger data');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }
}
