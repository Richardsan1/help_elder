// ignore_for_file: library_private_types_in_public_api, avoid_function_literals_in_foreach_calls, prefer_typing_uninitialized_variables

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_elder/list_medicines.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore db = FirebaseFirestore.instance;
List<Widget> data = [];
int avoidLoop = 0;
List<Widget> veio = [];
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }
  
  int page = 0;

  Future<void> setOlderAdd() async{
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getInt('typeAccount') == 0) {
      veio = [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, "/cadVeio");
          },
          icon: const Icon(Icons.add),
        ),
      ];
    } else {
      veio = [
        IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController cpfController =
                        TextEditingController();
                    return AlertDialog(
                      title: const Text("Adicionar Idoso"),
                      content: TextField(
                        decoration: const InputDecoration(
                          hintText: "Digite o CPF do idoso",
                        ),
                        controller: cpfController,
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancelar')),
                        TextButton(
                            onPressed: (() {
                              db
                                  .collection('idoso')
                                  .where("cpf", isEqualTo: cpfController.text)
                                  .get()
                                  .then((value) => {
                                        value.docs.forEach((element) {
                                          db.doc('idoso/${element.id}').update({
                                            'responsaveis':
                                                FieldValue.arrayUnion(
                                                    [auth.currentUser!.uid])
                                          });
                                        })
                                      });
                              avoidLoop = 0;
                              Navigator.pop(context);
                            }),
                            child: const Text('Adicionar'))
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.add)),
      ];
    }
  }
  
  @override
  Widget build(BuildContext context) {
    print(data);
    print(veio);
    if (avoidLoop == 0) {
      getContacts(context).then((_) => {
      setOlderAdd(),
      setState(() {
        print("refreshing");
        avoidLoop = 1;
      })});
    } 
    // else if (prefs.getBool('reload') == true){
    //     setState(() {
    //       prefs.setBool('reload', false);
    //       print('reload');
    //     });
    //   }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Help Elder"),
          actions: veio,
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.blue,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.comment),
              label: "Chat",
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_information),
              label: "Remédios",
            ),
          ],
          onDestinationSelected: (int index) {
            setState(() {
              page = index;
            });
          },
        ),
        body: Center(
          child: page == 0
              ? Flex(
                  direction: Axis.vertical,
                  verticalDirection: VerticalDirection.down,
                  children: [...data],
                )
              : const OlderList(),
        ),
      ),
    );
  }
}

Widget topic(String name, String uid, BuildContext context,
    {String photo =
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg'}) {
  return Flexible(
    child: Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Color(0xFFD9D9D9),
          width: 2.0,
        ))),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 10.0,
                right: 10.0,
              ),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: Image.network(photo).image,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: 10,
                right: 10,
              ),
              child: InkWell(
                child: Text(name),
                onTap: () {
                  Navigator.pushNamed(context, '/chat',
                      arguments: {"receiver": uid});
                },
              ),
            ),
          ],
        )),
  );
}

Future<void> getContacts(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> uids = [];
  if (prefs.getInt("typeAccount") == 0) {
    await db.collection('idoso').where("idFunc", isEqualTo: auth.currentUser!.uid).get()
        .then((value) => {
          print(value.docs),
              value.docs.forEach((older) {
                if (older.data()['idResp'] != null){
                  if (uids.any((element) => element == older.data()['idResp'])) {}
                  else{
                    uids.add(older.data()['idResp']);
                    db.doc('responsavel/${older.data()['idResp']}').get()
                    .then((value) => {
                      print("encontrei: ${value.data()}"),
                      data.add(topic(value.data()!['email'], older.data()['idResp'], context)),
                    });
                  }
                }
              })
            });
  } else {
    print('entrou');
    await db.collection('idoso').where("responsaveis", arrayContains: auth.currentUser!.uid).get()
    .then((value) => {
      print(auth.currentUser!.uid),
      value.docs.forEach((older) {
        if(older.data()['idFunc'] != null){
          db.doc('funcionario/${older.data()['idFunc']}').get()
          .then((value) => {
            data.add(topic(value.data()!['email'], older.data()['idFunc'], context)),
            print(value.data())
          });
        }
      })
    });
  }
}