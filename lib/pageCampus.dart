import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './record.dart';

class CampusPage extends StatefulWidget {
  @override
  _CampusPageState createState() => new _CampusPageState();
}

class _CampusPageState extends State<CampusPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Campus"),
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        onPressed: () {
          showDialogAddCampus(context);
        },
      ),
    );
  }

  addDocs() {
    Firestore.instance
        .collection("campus")
        .document("Teste")
        .setData({"Rua": "A", "Numero": "7"});
  }

  removeCampus(String nome) {
    Firestore.instance.collection("campus").document(nome).delete();
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('campus').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Dismissible(
      key: ValueKey(record.rua),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey))),
        child: ListTile(
          title: Text(record.nome),
          subtitle: Text(record.rua + " " + record.numero.toString()),
          onTap: () => print(record),
        ),
      ),
      background: Container(
        color: Colors.red.withOpacity(0.6),
      ),
      onDismissed: (direction) {
        removeCampus(record.nome);
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Campus Removido"),
        ));
      },
    );
  }

  void showDialogAddCampus(BuildContext context) {
    final nomeCampus =  TextEditingController();
    final ruaCampus = TextEditingController();
    final numeroCampus = TextEditingController();

    adicionarCampus(){
       Firestore.instance
        .collection("campus")
        .document(nomeCampus.text)
        .setData({"Rua": ruaCampus.text, "Numero": numeroCampus.text+""});
      Navigator.of(context).pop();
    }

    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        width: 300.0,
        height: 320.0,
        child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: ListView(
              children: <Widget>[
                new TextFormField(
                  controller: nomeCampus,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      labelText: "Campus", hintText: "Nome do Campus"),
                ),
                new TextFormField(
                  controller: ruaCampus,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      labelText: "Rua", hintText: "Rua do Campus"),
                ),
                new TextFormField(
                  controller: numeroCampus,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                      labelText: "Número", hintText: "Número da rua"),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: ListBody(
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: () {
                          adicionarCampus();
                        },
                        child: Text(
                          'Adicionar',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      RaisedButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }
}