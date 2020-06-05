import 'pageCampus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("PUC Minas - Localização"),
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
    //${_currentPosition.latitude} ${_currentPosition.longitude}
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            compassEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
              
            )
          ),
          
        ],
      ),
    );
  }

  _getCurrentLocation(){
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position){
      setState(() {
        _currentPosition = position;
      });
    });
  }
}
