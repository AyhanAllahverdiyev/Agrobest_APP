///BUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU

import 'package:flutter/material.dart';
import 'logged.dart';

class DataTableScreen extends StatelessWidget {
  final List<dynamic> data;

  DataTableScreen({required this.data});
  LoggedPageState logged = LoggedPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 68, 54, 97),
        title: Text('Tablo'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: getColumns(),
            rows: getRows(),
          ),
        ),
      ),
    );
  }

  List<DataColumn> getColumns() {
    Set<String> allKeys = {};
    data.forEach((item) {
      Map<String, dynamic> row = item;
      allKeys.addAll(row.keys);
    });

    return allKeys
        .map((String key) => DataColumn(
              label: Text(
                key,
              ),
            ))
        .toList();
  }

  List<DataRow> getRows() {
    return data.asMap().entries.map((entry) {
      Map<String, dynamic> row = entry.value;
      List<DataCell> cells = row.values
          .map((value) => DataCell(
                Text(
                  value.toString(),
                  style: TextStyle(
                      color: logged.isSwitchOn ? Colors.white : Colors.black),
                ),
              ))
          .toList();

      return DataRow(cells: cells);
    }).toList();
  }
}
