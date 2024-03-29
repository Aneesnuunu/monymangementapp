import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class Myapps extends StatefulWidget {
  const Myapps({Key? key});

  @override
  State<Myapps> createState() => _MyAppsState();
}

class _MyAppsState extends State<Myapps> {
  final List<IconData> icons = [
    Icons.sell_outlined,
    Icons.shopping_cart_outlined,
    Icons.restaurant,
    Icons.health_and_safety,
    Icons.house_outlined,
    Icons.local_taxi_outlined,
    Icons.card_giftcard_outlined,
    Icons.phone,
    Icons.movie_creation_outlined,
  ];

  final List<String> iconNames = [
    "Bills",
    "Shopping",
    "Food",
    "Health",
    "House Rent",
    "Taxi",
    "Gift",
    "Recharge",
    "Entertainment",
  ];

  late Box<double?> expenseAmountsBox;
  late Box<double> earningsBox;
  late Box<double?> totalExpenseBox;

  double? totalExpense;

  bool _hiveInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  void _initializeHive() async {
    final appDocumentDirectory =
    await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    await _openBoxes();
    _getTotalExpense();
    setState(() {
      _hiveInitialized = true;
    });
  }

  Future<void> _openBoxes() async {
    expenseAmountsBox = await Hive.openBox<double?>('expenseAmounts');
    earningsBox = await Hive.openBox<double>('earnings');
    totalExpenseBox = await Hive.openBox<double?>('totalExpense');
  }

  void _getTotalExpense() {
    totalExpense = totalExpenseBox.get('total');
  }

  void _updateTotalExpense() {
    totalExpense = expenseAmountsBox.values
        .where((element) => element != null)
        .fold(0, (prev, curr) => prev! + curr!);
    totalExpenseBox.put('total', totalExpense);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hiveInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Icon(
              Icons.search,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.linear_scale,
              color: Colors.white,
            )
          ],
          leading: Icon(
            CupertinoIcons.line_horizontal_3_decrease,
            color: Colors.white,
          ),
          backgroundColor: Colors.greenAccent,
          title: Text(
            "MONEY MANAGEMENT",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Center(
              child: Text(
                "Categories",
                style: TextStyle(fontSize: 25, color: Colors.green),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 100, right: 100),
              child: Divider(
                color: Colors.black12,
                thickness: 5,
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: icons.length, // No need for +1 here
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                double? enteredAmount;
                                return AlertDialog(
                                  title: Text(
                                      "Enter your ${iconNames[index]} amount"),
                                  content: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Enter amount",
                                    ),
                                    onChanged: (value) {
                                      enteredAmount = double.tryParse(value);
                                    },
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (enteredAmount != null) {
                                          setState(() {
                                            expenseAmountsBox.put(
                                                index, enteredAmount);
                                            _updateTotalExpense();
                                          });
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            icons[index],
                            color: Colors.blue,
                            size: 45,
                          ),
                        ),
                        Text(iconNames[index]),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Total Expense:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${totalExpense != null ? totalExpense : "N/A"}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Earnings:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${earningsBox.isNotEmpty ? earningsBox.values.reduce((value, element) => value + element).toStringAsFixed(2) : "N/A"}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'My Money:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${(earningsBox.isNotEmpty ? earningsBox.values.reduce((value, element) => value + element) : 0.0) - (totalExpense ?? 0.0)}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                double? enteredAmount;
                return AlertDialog(
                  title: Text("Add Earnings"),
                  content: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter amount",
                    ),
                    onChanged: (value) {
                      enteredAmount = double.tryParse(value);
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (enteredAmount != null) {
                          setState(() {
                            earningsBox.add(enteredAmount!);
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
