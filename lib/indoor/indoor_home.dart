import 'package:flutter/material.dart';
import 'package:jkuat_navigation/indoor/src/elb.dart';
import 'package:jkuat_navigation/indoor/src/nclb.dart';

import 'src/spa.dart';

class IndoorHomePage extends StatefulWidget {
  const IndoorHomePage({Key? key}) : super(key: key);

  @override
  State<IndoorHomePage> createState() => _IndoorHomePageState();
}

class _IndoorHomePageState extends State<IndoorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Navigate Indoor",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: () {
              // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>SPA(), (route) => false)
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => SPA()));
            },
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const ListTile(
                leading: Icon(
                  Icons.place,
                  color: Colors.green,
                  size: 30,
                ),
                title: Text('Swimming Pool Annex'),
                subtitle: Text('SPA'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Elb()));
            },
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const ListTile(
                leading: Icon(
                  Icons.place,
                  color: Colors.green,
                  size: 30,
                ),
                title: Text('Engineering Laboratory Building'),
                subtitle: Text('ELB'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Nclb()));
            },
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const ListTile(
                leading: Icon(
                  Icons.place,
                  color: Colors.green,
                  size: 30,
                ),
                title: Text('New Common Laboratory Building'),
                subtitle: Text('NCLB'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
