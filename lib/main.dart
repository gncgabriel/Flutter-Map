import 'dart:convert';
import 'dart:io';

import 'pageCampus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './record.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estou na PUC?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position _currentPosition;
  int _dialogued = 0;

  void _showDialog(String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Olá"),
            content: new Text(title),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text("Close"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("PUC Minas Localização"),
        ),
        drawer: new Drawer(
            child: ListView(children: <Widget>[
          new Container(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
            ),
          ),
          new Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: ListTile(
              title: new Text("Ver todos os campus"),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new CampusPage()));
              },
            ),
          )
        ])),
        body: _home());
  }

  Widget _home() {
    _getCurrentLocation();
    GoogleMapController myAppController;
    //${_currentPosition.latitude} ${_currentPosition.longitude}
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            compassEnabled: true,
            initialCameraPosition: CameraPosition(
              target:
                  LatLng(_currentPosition.latitude, _currentPosition.longitude),
              zoom: 10.0,
            ),
            onMapCreated: (controller) {
              setState(() {
                myAppController = controller;
              });
            },
          ),
        ],
      ),
    );
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        try {
          if (_currentPosition.latitude != position.latitude &&
              _currentPosition.longitude != position.longitude) {
            verifyLocations();
            _currentPosition = position;
          }
        } catch (e) {
          verifyLocations();
          _currentPosition = position;
        }
      });
    });
  }

  verifyLocations() async {
    QuerySnapshot qs =
        await Firestore.instance.collection('campus').getDocuments();
    int aux = 0;
    String response = null;
    for (var i = 0; i < qs.documents.length; i++) {
      response = await constructLocations(qs.documents[i]);
      if (response != null) {
        aux++;
      }
    }

    print(aux);

    if (aux == 1 ) {
      if (_dialogued != 1) {
        print("Chamou o dialogo");
        _showDialog(response);
        _dialogued = 1;
      }
    } else {
      response = null;
      _dialogued = 0;
    }
  }

  constructLocations(DocumentSnapshot doc) async {
    var lat1, lon1, lat2, lon2;
    lat1 = _currentPosition.latitude;
    lon1 = _currentPosition.longitude;
    final record = Record.fromSnapshot(doc);
    String adress = record.rua + " " + record.numero;
    List<Placemark> a = await Geolocator().placemarkFromAddress(adress);
    lat2 = a[0].position.latitude;
    lon2 = a[0].position.longitude;
    String url =
        "https://us-central1-striking-port-278814.cloudfunctions.net/distance_calculation?lat1=" +
            lat1.toString() +
            "&lon1=" +
            lon1.toString() +
            "&lat2=" +
            lat2.toString() +
            "&lon2=" +
            lon2.toString();

    var httpClient = new HttpClient();
    double result = 0;

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var data = await response.transform(utf8.decoder).join();
        result = double.parse(data);
        print(record.nome);
        print(result);
        if (result <= 100) {
          return "Bem vindo à PUC Minas unidade " + record.nome;
        }
        return null;
      }
    } catch (exception) {}
  }
}
