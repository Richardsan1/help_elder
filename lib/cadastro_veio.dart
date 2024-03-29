// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cpf_cnpj_validator/cpf_validator.dart';
final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore db = FirebaseFirestore.instance;

// var prefs;

class CadastroVeio extends StatelessWidget {
  const CadastroVeio({Key? key}) : super(key: key);

  Future<String> getIdFromResponsavel(String cpf) async {
    final responsavel =
        await db.collection('responsavel').where('cpf', isEqualTo: cpf).get();
    return responsavel.docs[0].id;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController cpfController = TextEditingController();
    // SharedPreferences.getInstance().then((value) => prefs = value);

    AlertDialog alert = AlertDialog(
      title: const Text("Erro"),
      content: const Text("Algum erro ocorreu"),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
            width: 500,
            height: 1000,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 300,
                      child: Column(children: const [
                        SizedBox(
                          height: 80,
                        ),
                        Text(
                          'Cadastro de idoso',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text('Cadastre um idoso em nossa plataforma'),
                        SizedBox(
                          height: 30,
                        ),
                      ])),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                      ),
                      controller: nomeController,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'CPF',
                      ),
                      controller: cpfController,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      style: (ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      )),
                      child: const Text('Cadastrar'),
                      onPressed: () async {
                        if (nomeController.text.isNotEmpty &&
                            cpfController.text.isNotEmpty) {
                          // if (CPFValidator.isValid(cpfController.text) && CPFValidator.isValid(respController.text)) {
                          db.collection("idoso").add({
                            "nome": nomeController.text,
                            "cpf": cpfController.text,
                            "idFunc": auth.currentUser!.uid,
                            "responsaveis": []
                          }).whenComplete(() => {
                            // prefs.setBool("reload", true),
                            Navigator.pop(context),
                            // Navigator.pushNamed(context, '/home')
                          });
                        } else {
                          print("FALHA");
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            )),
        backgroundColor: const Color.fromARGB(225, 235, 249, 255),
      ),
    );
  }
}
