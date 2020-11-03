import 'package:flutter/material.dart';
import 'package:new_bos_app/common/global.dart';
import 'package:new_bos_app/model/discounts.dart';
import 'package:new_bos_app/model/shops.dart';
import 'package:new_bos_app/services/accountService.dart';

class DiscountPage extends StatefulWidget {
  final String code;
  DiscountPage({@required this.code});
  @override
  _DiscountPageState createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  Future _discounts;

  String format(String date) {
    String dateFormat;
    DateTime data = DateTime.parse(date);
    dateFormat = '${data.day} ${months[data.month - 1]} ${data.year}';
    return dateFormat;
  }

  @override
  void initState() {
    super.initState();
    _discounts = fetchClientDiscounts(widget.code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Vos coupons'),
        ),
        body: FutureBuilder(
            future: _discounts,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                List<Discount> discounts = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: ListView.builder(
                    itemCount: discounts.length,
                    itemBuilder: (context, index) {
                      Shop shop = discounts[index].shop;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: InkWell(
                          onTap: () {
                            /*  Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShowCommand(
                                          commands[index]['code'],
                                        )));  */
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22.0, vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Boutique ${shop.name}'),
                                  SizedBox(height: 5.0),
                                  Text(
                                      'Montant: ${discounts[index].amount} Frs CFA'),
                                  SizedBox(height: 5.0),
                                  Text(discounts[index].deadDate == null
                                      ? 'Date d\'expiration: Aucune'
                                      : 'Date d\'expiration: ${format(discounts[index].deadDate)}'),
                                  SizedBox(height: 5.0),
                                  discounts[index].reason.length > 20
                                      ? Text(
                                          'Motif: ${discounts[index].reason.substring(0, 20)}...')
                                      : Text(
                                          'Motif: ${discounts[index].reason}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            }));
  }
}
