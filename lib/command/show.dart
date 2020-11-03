import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_bos_app/common/ENDPOINT.dart';
import 'package:new_bos_app/common/global.dart' as globals;
import 'package:new_bos_app/custom/loading.dart';
import 'package:new_bos_app/services/appService.dart';
import 'package:progress_dialog/progress_dialog.dart';

var payment, livraison;

String dateValue;
DateTime dateToStoreValue;

filterServices(List services) {
  //initialisation
  for (var i = 0; i < services.length; i++) {
    if (services[i]['service_type']['name'] == 'Paiement') {
      payment = services[i];
    }
    if (services[i]['service_type']['name'] == 'Livraison') {
      livraison = services[i];
    }
  }

  // Recherche du plus important
  for (var i = 0; i < services.length; i++) {
    if (services[i]['service_type']['name'] == 'Paiement') {
      if (int.parse(services[i]['importance']) <
          int.parse(payment['importance'])) {
        payment = services[i];
      }
    }
    if (services[i]['service_type']['name'] == 'Livraison') {
      if (int.parse(services[i]['importance']) <
          int.parse(livraison['importance'])) {
        livraison = services[i];
      }
    }
  }
}

class ShowCommand extends StatefulWidget {
  final String code;
  ShowCommand(this.code);
  @override
  _ShowCommandState createState() => _ShowCommandState();
}

class _ShowCommandState extends State<ShowCommand>
    with TickerProviderStateMixin {
  List<Tab> _tabs = List<Tab>();
  TabController _tabController;
  bool isLoading = false;
  Map data, command, shop, admin;
  List services = [];
  List products = [];
  Iterable values;
  bool userMark;
  ProgressDialog progress;

  format(DateTime date) {
    dateToStoreValue = date;
    setState(() {
      dateValue = '${date.day} ${globals.months[date.month - 1]} ${date.year}';
    });
  }

  _fetchDataServices() async {
    setState(() {
      isLoading = true;
    });
    String token = await globals.getUserToken();
    final response = await http.get('$endPoint/command/${widget.code}/services',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      data = json.decode(response.body);
      if (data['success']) {
        services = data['data']['services'];
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print(response.statusCode);
      throw Exception('Impossible de recuperer le service ${widget.code}');
    }
  }

  _fetchData() async {
    setState(() {
      isLoading = true;
    });
    String token = await globals.getUserToken();
    final response = await http.get('$endPoint/commands/${widget.code}/show',
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      data = json.decode(response.body);
      if (data['success']) {
        command = data['data'];
        shop = data['data']['shop'];
        admin = data['data']['admin'];
        products = data['data']['products'];
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print(response.statusCode);
      throw Exception('Impossible de recuperer le service ${widget.code}');
    }
  }

  @override
  void initState() {
    print(widget.code);
    _fetchData();
    _fetchDataServices();
    _tabs = getTabs();
    _tabController = getTabController();
    super.initState();
    progress = loadingWidget(context);
    format(DateTime.now().add(Duration(hours: 24)));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Tab> getTabs() {
    _tabs.clear();
    _tabs = [
      Tab(
        text: 'Details',
      ),
      Tab(text: 'infos boutique'),
      Tab(text: 'Produits')
    ];
    return _tabs;
  }

  TabController getTabController() {
    return TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Commande ${widget.code}",
          style: TextStyle(color: Colors.black),
        )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          labelColor: Colors.black,
          tabs: _tabs,
          controller: _tabController,
        ),
      ),
      body: isLoading
          ? Center(
              child: globals.loader(),
            )
          : TabBarView(
              controller: _tabController,
              children: <Widget>[
                DetailsPage(
                  details: command,
                  services: services,
                ),
                ShopPageDetails(
                  shop: shop,
                  command: command,
                  admin: admin,
                ),
                ProductPage(
                  products: products,
                  command: command,
                )
              ],
            ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final details, services;
  DetailsPage({@required this.details, this.services});
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  formatDateToString(DateTime dateData) {
    return '${dateData.day} ${globals.months[dateData.month - 1]} ${dateData.year}';
  }

  @override
  Widget build(BuildContext context) {
    Map command = widget.details;
    String statut = '';
    if (command != null) {
      filterServices(widget.services);
      statut = command['already_delivered'] == '0'
          ? 'En Attente'
          : command['already_delivered'] == '1'
              ? 'Validee'
              : command['already_delivered'] == '2' ? 'En route' : 'Cloturee';
    }

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: command == null
            ? Center(
                child: Text('Commande impossible a afficher'),
              )
            : ListView(
                children: <Widget>[
                  new Text('Details'),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              'Identifiant de la commande: ${command['code']}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text(
                              'Date de la commande: ${formatDateToString(DateTime.parse(command['command_date']))}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text(
                              'Montant de la commande: ${command['amount']} Frs CFA'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text('Statut de la commande: $statut'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  new Text('Livraison'),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              'Type de livraison: ${livraison == null ? 'Non renseigne' : livraison['service']['name'] ?? 'Non renseigne'}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text(
                              'Adresse de livraison: ${command['client']['address']} ${command['client']['town']}-${command['client']['country']}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text(
                              'Date de livraison: ${command['delivered_date'] != null ? formatDateToString(DateTime.parse(command['delivered_date'])) : 'Non renseigne'}'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  new Text('Paiement'),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              'Type de paiement: ${payment == null ? 'Non renseigne' : payment['service']['name'] ?? 'Non Renseigne'}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text(
                              'Date de paiement: ${command['payment_date'] != null ? formatDateToString(DateTime.parse(command['payment_date'])) : 'Non renseigne'}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ShopPageDetails extends StatefulWidget {
  final Map shop, admin, command;
  ShopPageDetails(
      {@required this.shop, @required this.admin, @required this.command});
  @override
  _ShopPageDetailsState createState() => _ShopPageDetailsState();
}

class _ShopPageDetailsState extends State<ShopPageDetails> {
  @override
  Widget build(BuildContext context) {
    Map shop = widget.shop, admin = widget.admin;
    return shop == null
        ? Center(
            child: Text('Commande impossible a afficher'),
          )
        : Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  new Text('Informations relatives a la boutique'),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Container(
                              width: 150.0,
                              height: 150.0,
                              child: Image.network(
                                  globals.imagePath(shop['photo'])),
                            ),
                          ),
                          Text('Nom : ${shop['name']}'),
                          shop['description'] == null
                              ? SizedBox(
                                  height: 0.0,
                                )
                              : Row(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 3.0,
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                54.0,
                                        child: Text(
                                          'Description: ${shop['description']}',
                                        )),
                                  ],
                                ),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text('Note: ${double.parse(shop['rate'])}'),
                        ],
                      ),
                    ),
                  ),
                  new Text('Informations relatives a l\'administrateur'),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Nom : ${admin['name']}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text('Email : ${admin['email']}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text('Tel : ${admin['phone']}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text('Adresse : ${admin['address']}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Text('Note: ${double.parse(admin['note'])}'),
                          SizedBox(
                            height: 3.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                color: Color(0xff3ee65d),
                                elevation: 10.0,
                                onPressed: () => launchWhatsApp(
                                    phone: '${admin['phone']}',
                                    message:
                                        "Bonjour M./Mme. ${admin['name']}. J'aimerais echanger avec vous concernant ma commande ${widget.command['code']}. Ma question est "),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'img/whatsapp.png',
                                      width: 30.0,
                                      height: 30.0,
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text('WhatsApp',
                                        style: TextStyle(color: Colors.white))
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              RaisedButton(
                                color: Colors.white,
                                elevation: 10.0,
                                onPressed: () =>
                                    launchPhoneCall(phone: '${admin['phone']}'),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.phone),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text('Contacter')
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class ProductPage extends StatefulWidget {
  final products;
  final command;
  ProductPage({@required this.products, @required this.command});
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<DataRow> _getRows(List dataFull) {
    List<Map> data = dataFull.cast<Map>();
    List<DataRow> rows = [];
    for (var i = 0; i < data.length; i++) {
      if (!(dataFull[i] is String)) {
        DataRow row = DataRow(cells: [
          DataCell(Text(data[i]['name'].length < 10
              ? data[i]['name']
              : '${data[i]['name'].substring(0, 10)}...')),
          DataCell(Center(
              child: Text(
                  '${data[i]['amount'] == null || data[i]['amount'] == 0 ? 0 : data[i]['amount']}'))),
          DataCell(Center(child: Text('${data[i]['quantity']}'))),
          DataCell(Center(
            child: Text((data[i]['amount'] == null || data[i]['amount'] == 0
                    ? 0
                    : data[i]['amount'] * data[i]['quantity'])
                .toString()),
          ))
        ]);
        rows.add(row);
      }
    }
    DataRow row = DataRow(cells: [
      DataCell(Text('Frais de\nlivraison')),
      DataCell(Center(
          child: Text(
              '${livraison == null ? 'ND' : livraison['service']['name'].length > 7 ? livraison['service']['name'].substring(0, 7) + '...' : livraison['service']['name'] ?? '-'}'))),
      DataCell(Center(child: Text('-'))),
      DataCell(
        Center(
            child: Text(
                '${livraison == null ? 'ND' : livraison['service']['price'] ?? 0}')),
      )
    ]);
    DataRow row2 = DataRow(cells: [
      DataCell(Text('Frais de\npaiement')),
      DataCell(Center(
          child: Text(
              '${payment == null ? '-' : payment['service']['name'].length > 7 ? payment['service']['name'].substring(0, 7) + '...' : payment['service']['name'] ?? '-'}'))),
      DataCell(Center(child: Text('-'))),
      DataCell(
        Center(
            child: Text(
                '${payment == null ? 'ND' : payment['service']['price'] ?? 0}')),
      )
    ]);
    rows.add(row);
    rows.add(row2);
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    var products = widget.products;
    return products == null
        ? Center(
            child: Text('Impossible d\'afficher les produits'),
          )
        : ListView(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                      columnSpacing: 1.0,
                      sortAscending: true,
                      columns: [
                        DataColumn(label: Center(child: Text('Produit'))),
                        DataColumn(label: Center(child: Text('Prix Unitaire'))),
                        DataColumn(
                            label: Center(child: Text('Qte')), numeric: true),
                        DataColumn(
                            label: Center(child: Text('Prix total')),
                            numeric: true)
                      ],
                      rows: products == null ? [] : _getRows(products))),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'Total de la commande: ${widget.command['amount']} Frs CFA',
                    style: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          );
  }
}
