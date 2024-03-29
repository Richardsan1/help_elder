// ignore_for_file: invalid_return_type_for_catch_error, library_private_types_in_public_api
// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
   int typeLogin = 0;
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passController = TextEditingController();
    
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text("Invalid Email or Password"),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(225, 235, 249, 255),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Faça login como cuidador/responsável de alguém',
                        style: TextStyle(
                          fontSize: 15,
                        )),
                  ],
                ),
              ),
              SizedBox(
                width: 350,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  controller: emailController,
                ),
              ),
              SizedBox(
                width: 350,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                  ),
                  controller: passController,
                ),
              ),
               SizedBox(
                width: 350,
                child: DropdownButton(
                  value: typeLogin,
                  onChanged: (int? value) {
                    setState(() => typeLogin = value!);
                  },
                  underline: Container(
                    height: 1,
                    color: Colors.black38,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Cuidador'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Responsável'),
                    ),
                  ], 

                ),
              ),
              SizedBox(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        style: (ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        )),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold
                          )),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          auth.signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passController.text)
                          .then((x) => {
                            if (typeLogin == 0){
                              prefs.setInt("typeAccount", 0),
                      
                              Navigator.of(context).pop(),
                              Navigator.pushNamed(context, '/home', arguments: {
                                "typeAccount": 0,
                              }),
                            }
                            else{
                              prefs.setInt("typeAccount", 1),
                              Navigator.of(context).pop(),
                              Navigator.pushNamed(context, '/home', arguments: {
                                "typeAccount": 1,
                              }),
                            }
                          })
                          .catchError((e) => {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    alert)
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      child: const Text('Esqueceu a Senha?',
                          style: TextStyle(fontSize: 15)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/esqueci_senha');
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Não tem uma conta?'),
                  TextButton(
                    child: const Text('Cadastre-se'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadResp');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}