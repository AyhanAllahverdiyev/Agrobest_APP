import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/tableData.dart';
import '../utils/generic.dart';

const baseUrl = "http://10.0.2.2:5238/api/Values";

Future<void> getData(BuildContext context) async {
  await showInputSQL(context);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? query = prefs.getString('query');
  if (query != null) {
    print('queryqueryqueryqueryqueryqueryquery');
    print(query);
    Map<String, dynamic> requestBody = {'query': query};

    http.Response response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      deleteSingleValueFromShared('query');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DataTableScreen(data: data),
        ),
      );
    } else if (response.statusCode == 500) {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
          });

          return AlertDialog(
            title: Text("HATA"),
            content: Text("Hatalı yada boş sorgu girdiniz",
                style: TextStyle(fontSize: 20)),
            icon: Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteSingleValueFromShared('query');
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  } else {
    print('NULL QUERRY');
  }
}

void showDataTable(BuildContext context, List<dynamic> data) {
  List<DataColumn> getColumns() {
    Set<String> allKeys = {};
    data.forEach((item) {
      Map<String, dynamic> row = item;
      allKeys.addAll(row.keys);
    });

    return allKeys.map((String key) => DataColumn(label: Text(key))).toList();
  }

  List<DataRow> getRows() {
    return data.map((dynamic item) {
      Map<String, dynamic> row = item;
      List<DataCell> cells =
          row.values.map((value) => DataCell(Text(value.toString()))).toList();
      return DataRow(cells: cells);
    }).toList();
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("TABLO"),
      content: SizedBox(
        width: double.maxFinite,
        height: 800,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: getColumns(),
              rows: getRows(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            deleteSingleValueFromShared('query');
          },
          child: Text("OK"),
        ),
      ],
    ),
  );
}
