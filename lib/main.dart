import 'dart:io';

import 'package:flutter/material.dart';
import 'package:udp/udp.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UDP ESP8266',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UdpPage(),
    );
  }
}

class UdpPage extends StatefulWidget {
  @override
  _UdpPageState createState() => _UdpPageState();
}

class _UdpPageState extends State<UdpPage> {
  String receivedMessage = 'Aguardando resposta do ESP8266...';
  final String esp8266Ip = '192.168.4.1';  // O IP do ESP8266 no modo AP ou da sua rede
  final int esp8266Port = 4210;            // Porta UDP do servidor ESP8266
  final int localPort = 4211;              // Porta UDP local do cliente Flutter

  UDP? udpSender;

  @override
  void initState() {
    super.initState();
    initializeUdp();
  }

  Future<void> initializeUdp() async {
    // Vincular o cliente UDP a uma porta local
    udpSender = await UDP.bind(Endpoint.any(port: Port(localPort)));

    // Receber pacotes de forma contínua
    listenForUdpMessages();
  }

  Future<void> listenForUdpMessages() async {
    if (udpSender != null) {
      await udpSender!.asStream().listen((datagram) {
        if (datagram != null) {
          var messageReceived = utf8.decode(datagram.data);
          setState(() {
            receivedMessage = "Resposta do ESP8266: $messageReceived";
          });
        }
      });
    }
  }

  Future<void> sendUdpRequest(String command) async {
    if (udpSender != null) {
      var data = utf8.encode(command);

      // Enviar o pacote para o ESP8266
      await udpSender!.send(data, Endpoint.unicast(InternetAddress(esp8266Ip), port: Port(esp8266Port)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter UDP ESP8266'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                sendUdpRequest("REQUEST_DATA");  // Enviar o comando "REQUEST_DATA" ao ESP8266
              },
              child: Text('Solicitar Temperatura e Umidade'),
            ),
            SizedBox(height: 20),
            Text(receivedMessage, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    udpSender?.close();
    super.dispose();
  }
}
