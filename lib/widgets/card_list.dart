import 'package:flutter/material.dart';

class CardList extends StatefulWidget {
  final List<String> titles;
  final List<int> numbers;

  const CardList({Key? key,
    required this.numbers,
    required this.titles
  }) : super(key: key);

  @override
  _CardListState createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _populateItems();
  }

  void _populateItems() {
    _items = widget.numbers.map((number) {
      return {
        "title": "a",
        "number": number,
        "description": "This is the card with number $number."
      };
    }).toList();

    // Sort the items based on the 'number' field in descending order
    _items.sort((a, b) => b['number'].compareTo(a['number']));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['title'], style: TextStyle(
                    fontSize: 17,
                    letterSpacing: 1,
                  ),),
                  Text(
                    "${item['number']}",
                    style: TextStyle(
                        color: _getColorForNumber(item['number']),
                        fontSize: 20,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item['description'],
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorForNumber(int number) {
    if (number < 3) {
      return Colors.yellow;
    } else if (number < 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}