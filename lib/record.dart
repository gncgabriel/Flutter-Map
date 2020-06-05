import 'package:cloud_firestore/cloud_firestore.dart';
class Record {
  final String nome;
  final String rua;
  final String numero;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, String nomeDoc, {this.reference})
      : assert(map['Rua'] != null),
        assert(map['Numero'] != null),
        assert(nomeDoc != null),
        rua = map['Rua'],
        numero = map['Numero'],
        nome = nomeDoc;

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, snapshot.documentID,
            reference: snapshot.reference);

  @override
  String toString() => "Record<$nome,$rua,$numero>";
}
