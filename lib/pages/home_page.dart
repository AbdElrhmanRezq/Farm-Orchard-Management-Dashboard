import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../componenets/custom_orchard_tile.dart';
import '../models/orchard.dart';

class HomePage extends StatefulWidget {
  static const String id = "home-page";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  TextEditingController searchController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder(
        future: _getDBData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Orchard> orchards = snapshot.data as List<Orchard>;
            return Row(
              children: [
                Container(
                  width: width * 0.2,
                  color: Color.fromARGB(255, 67, 66, 93),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: height * 0.15,
                      ),
                      Icon(
                        Icons.person,
                        size: height * 0.2,
                      ),
                      Center(
                          child: Text(
                        username?.toUpperCase() as String,
                        style: TextStyle(fontSize: width * 0.025),
                      )),
                      SizedBox(height: height * 0.05),
                      const ListTile(
                          leading: Icon(Icons.home), title: Text("Home")),
                      const ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text("Notifications"),
                      ),
                      const ListTile(
                        leading: Icon(Icons.travel_explore),
                        title: Text("Explore"),
                      ),
                      const ListTile(
                        leading: Icon(Icons.chat),
                        title: Text("Chat"),
                      ),
                      ListTile(
                        leading: const Icon(Icons.search),
                        title: TextField(
                          controller: searchController,
                          cursorColor: Colors.black,
                          decoration: const InputDecoration(
                            hintText: "Search",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool("logged", false);
                          Navigator.of(context)
                              .pushReplacementNamed('login-page');
                        },
                        child: const ListTile(
                          leading: Icon(Icons.logout),
                          title: Text("Logout"),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: width * 0.8,
                  height: height,
                  color: Color.fromARGB(255, 227, 227, 244),
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text(
                          "Orchards",
                          style: TextStyle(
                              fontSize: 30,
                              color: Color.fromARGB(255, 67, 66, 93)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: height * 0.3,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: false,
                            itemCount: orchards.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomOrchardTile(
                                crob: orchards[index].crob,
                                feddans: orchards[index].feddans,
                                mm: orchards[index].mm,
                                pestState: orchards[index].pestState,
                                orchardID: index,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          } else {
            return Container(
                color: Color.fromARGB(255, 227, 227, 244),
                child: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }

  Future<List<Orchard>> _getDBData() async {
    List<Orchard> orchards = [];
    final conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'farm_orchard_management_dashboard',
        username: 'postgres',
        password: '12345678',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int u_id = int.parse(prefs.getString("user") as String);

    final result =
        await conn.execute('SELECT * FROM orchards where u_id = $u_id');
    for (int i = 0; i < result.length; i++) {
      int id = result[i][0] as int;
      String crob = result[i][1] as String;
      int feddans = result[i][2] as int;
      int mm = result[i][3] as int;
      String pestState = result[0][4] as String;
      orchards.add(Orchard(
          id: id, crob: crob, feddans: feddans, mm: mm, pestState: pestState));
    }
    conn.close();
    if (mounted) {
      setState(() {
        username = prefs.getString("username");
      });
    }

    return orchards;
  }
}
