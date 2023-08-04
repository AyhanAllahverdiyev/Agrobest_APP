import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/logged.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataTableScreen extends StatefulWidget {
  final List<dynamic> data;

  DataTableScreen({required this.data});

  @override
  _DataTableScreenState createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  bool isSwitchOn = false; // Local variable to hold the isSwitchOn value

  @override
  void initState() {
    super.initState();
    loadSwitchState();
  }

  void loadSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isSwitchOn = prefs.getBool('isSwitchOn') ?? false;
    });
  }

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
    widget.data.forEach((item) {
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
    return widget.data.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> row = entry.value;
      List<DataCell> cells = row.values
          .map((value) => DataCell(
                Text(
                  value.toString(),
                  style: TextStyle(
                      color: isSwitchOn ? Colors.white : Colors.black),
                ),
              ))
          .toList();
      if (isSwitchOn == false) {
        Color? color = index % 2 == 0 ? Colors.white : Colors.grey.shade300;
        return DataRow(
            cells: cells, color: MaterialStateProperty.all<Color>(color));
      } else {
        Color? color = index % 2 == 0
            ? Color.fromARGB(255, 52, 52, 53)
            : const Color.fromARGB(255, 37, 37, 37);
        return DataRow(
            cells: cells, color: MaterialStateProperty.all<Color>(color));
      }
    }).toList();
  }
}
