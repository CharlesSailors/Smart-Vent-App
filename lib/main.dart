import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'sizes_helpers.dart';
import 'icons.dart';

final info = NetworkInfo();
String ssid = "";
String bssid = "";

void main(List<String> arguments) async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adventage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirstPage(title: 'FirstPage'),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key, required this.title});

  final String title;

  @override
  State<FirstPage> createState() => _FirstState();
}

class _FirstState extends State<FirstPage> {
  final String title = 'Adventage';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomPaint(
        painter: BluePainter(),
        child: Column(children: [
          Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                    child: Column(
                  children: [
                    SizedBox(
                      height: displayHeight(context) * 0.10,
                    ),

                    // Implement the stroke
                    Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFF0D47A1),
                                      Color(0xFF1976D2),
                                      Color(0xFF42A5F5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Adventage',
                                style: TextStyle(
                                  fontSize: displayWidth(context) * 0.13,
                                  letterSpacing: 5,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ],
                )),
              ),
              SizedBox(
                height: displayHeight(context) * 0.20,
              ),
              Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color(0xFF0D47A1),
                                Color(0xFF0D47A1),
                                Color(0xFF0D47A1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ConnectPage(title: 'ConnectPage');
                          }));
                        },
                        child: const Text('Connect'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.05,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF0D47A1),
                              Color(0xFF0D47A1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const GroupPage(title: 'Vents');
                        }));
                      },
                      child: const Text('Group 1'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class NewPage extends StatelessWidget {
  const NewPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}

class ConnectPage extends StatefulWidget {
  const ConnectPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ConnectPage> createState() => _ConnectingState();
}

class _ConnectingState extends State<ConnectPage> {
  final provisioner = Provisioner.espTouch();
  bool connected = false;
  String ssid = 'ssid'; //updates automatically
  String bssid = '???'; //updates automatically
  String msg1 = 'Using Wi-Fi: ';
  String msg2 = '';
  String password = '????????'; //Only input needed for connection
  String ip = '';
  @override
  void initState() {
    super.initState();
  }

  Future<void> _incrementCounter() async {
    PermissionWithService locationPermission = Permission.locationWhenInUse;

    var permissionStatus = await locationPermission.status;
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await locationPermission.request();

      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await locationPermission.request();
      }
    }

    if (permissionStatus == PermissionStatus.granted) {
      bool isLocationServiceOn =
          await locationPermission.serviceStatus.isEnabled;
      if (isLocationServiceOn) {
        final info = NetworkInfo();
        ssid = await info.getWifiName() as String;
        bssid = await info.getWifiBSSID() as String;
        setState(() {
          msg2 = "Sending Wi-Fi Details: $password";
        });
        await provisioner.start(ProvisioningRequest.fromStrings(
            ssid: ssid.split('"')[1], bssid: bssid, password: password));
      } else {
        print('Location Service is not enabled');
      }
    }

    await Future.delayed(const Duration(seconds: 20));
    provisioner.stop();
    if (connected == false) {
      setState(() {
        msg2 = "Please Re-enter Wi-Fi Password:";
      });
    } else {
      setState(() {
        msg2 = "Wi-Fi Connected";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(BackArrow3.image),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: CustomPaint(
        painter: BluePainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                    child: Column(
                  children: [
                    Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFF0D47A1),
                                      Color(0xFF1976D2),
                                      Color(0xFF42A5F5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                msg1 + ssid,
                                style: TextStyle(
                                  fontSize: displayWidth(context) * 0.05,
                                  letterSpacing: 5,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ],
                )),
              ),
              Container(
                child: Container(
                  alignment: Alignment(0, -0.2),
                  child: SizedBox(
                    width: 200,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          label: const Center(
                              child: Text(
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  'Enter Password')),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      validator: (String? value) {
                        return (value != null && value.contains('@'))
                            ? 'Do not use the @ character.'
                            : null;
                      },
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color(0xFF0D47A1),
                                Color(0xFF0D47A1),
                                Color(0xFF0D47A1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text(
                                    'ssid: $ssid \nbssid: $bssid \npassword: $password'),
                              );
                            },
                          );
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupPage extends StatelessWidget {
  const GroupPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(BackArrow3.image),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: CustomPaint(
        painter: BluePainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF0D47A1),
                              Color(0xFF0D47A1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return VentPage(title: 'Vent 1');
                        }));
                      },
                      child: const Text('Vent 1'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VentPage extends StatefulWidget {
  VentPage({Key? key, required this.title}) : super(key: key);
  final String title;
  late String temp1;
  @override
  _VentPageState createState() => _VentPageState();
}

class _VentPageState extends State<VentPage> {
  final String title = 'Vent Page';
  String current = '0';
  String desired = '81.00';
  late String temp1 = '';
  bool openstatus = false; //checks vent open/close status
  late IOWebSocketChannel channel;
  bool connected = false; //boolean value to track if WebSocket is connected
  int count = 0;
  static DateTime now = DateTime.parse("2023-05-02 12:21:04Z"); //
  static late DateFormat formatter = DateFormat('MM-dd-yyyy HH-mm'); //
  late String formatted = formatter.format(now); //
  late int filtration = 3;
  String update = 'Great';
  int temp = 0;
  late String image = 'assets/yellow.jpg';

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);

  void handleTimeout() {
    sendcmd('temp');
  }

  @override
  void initState() {
    openstatus = false; //initially closed and will update when connected
    connected = false; //initially connection status is "NO" so its FALSE

    Future.delayed(Duration.zero, () async {
      channelconnect(); //connect to WebSocket with NodeMCU
    });
    sendcmd('quality'); //checks quality
    super.initState();
  }

  channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://172.20.10.3:81"); //channel IP : Port
      channel.stream.listen(
        (message) {
          print(message);
          setState(() {
            if (message == "connected") {
              connected = true; //message is "connected" from NodeMCU
            } else if (message == "open:success") {
              openstatus = true;
              now = DateTime.now();
              formatted = formatter.format(now);
            } else if (message == "close:success") {
              openstatus = false;
              now = DateTime.now();
              formatted = formatter.format(now);
            } else if (message == "pingback") {
              setState(() {
                now = DateTime.now();
                formatted = formatter.format(now);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                  'Device responded successfully.',
                  textAlign: TextAlign.center,
                )),
              );
            } else if (message == "quality:1") {
              image = "assets/red.jpg";
              print("Quality $message");
              filtration = 1;
              update = 'Poor';
            } else if (message == "quality:2") {
              print("Quality $message");
              image = "assets/yellow.jpg";
              filtration = 2;
              update = 'Average';
            } else if (message == "quality:3") {
              print("Quality $message");
              image = "assets/green.jpg";
              filtration = 3;
              update = 'Great';
            } else if (message == 'ack') {
              //change desired
            } else {
              print('This is temp $temp');
              var temporary = message.split(':');
              print(temporary[0]);
              print(temporary[1]);
              current = temporary[0];
              desired = temporary[1];
            }
          });
        },
        onDone: () {
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
      print('Catch STATEMENT');
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      if (openstatus == false &&
          cmd != "open" &&
          cmd != "close" &&
          cmd != "ping" &&
          cmd != "quality" &&
          cmd != 'temp' &&
          cmd != cmd.startsWith('desired:')) {
        print("Send the valid command");
      } else {
        channel.sink.add(cmd); //sending Command to NodeMCU
      }
    } else {
      channelconnect();
      print("Connection Failed. ELSE");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(BackArrow3.image),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: CustomPaint(
        painter: BluePainter(),
        child: Center(
          child: Stack(
            children: <Widget>[
              Stack(children: [
                Stack(
                  children: [
                    Positioned(
                      left: displayWidth(context) * 0.15,
                      top: displayHeight(context) * 0.14,
                      child: Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Color(0xFF0D47A1),
                                        Color(0xFF1976D2),
                                        Color(0xFF42A5F5),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.all(16),
                                  child: (formatted == '')
                                      ? Text(
                                          style: TextStyle(color: Colors.white),
                                          "Date")
                                      : Text(
                                          style: TextStyle(color: Colors.white),
                                          formatted)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    Positioned(
                      right: displayWidth(context) * 0.15,
                      top: displayHeight(context) * 0.1,
                      child: Stack(
                        children: [
                          Image(
                              image: AssetImage(image),
                              width: displayWidth(context) * 0.25,
                              height: displayHeight(context) * 0.14),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
              Positioned(
                right: displayWidth(context) * 0.42,
                top: displayHeight(context) * 0.4,
                child: Container(
                  alignment: Alignment(0, -0.15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF0D47A1),
                                  Color(0xFF0D47A1),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            sendcmd("temp");

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SetPage(
                                      current: current,
                                      desired: desired,
                                      temp1: temp1),
                                ));
                          },
                          child: const Text('Set'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.05,
              ),
              Positioned(
                right: displayWidth(context) * 0.416,
                top: displayHeight(context) * 0.6,
                child: Container(
                  alignment: Alignment(0, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF0D47A1),
                                  Color(0xFF0D47A1),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            sendcmd("ping");
                            sendcmd("quality");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                'Device has been pinged.',
                                textAlign: TextAlign.center,
                              )),
                            );
                          },
                          child: const Text('Ping'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.05,
              ),
              Positioned(
                right: displayWidth(context) * 0.13,
                top: displayHeight(context) * 0.9,
                child: Container(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFF0D47A1),
                                      Color(0xFF1976D2),
                                      Color(0xFF42A5F5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: connected
                                  ? Text(
                                      "Vent Connected",
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.05,
                                        letterSpacing: 5,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    )
                                  : Text(
                                      "Vent Disconnected",
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.05,
                                        letterSpacing: 5,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.05,
              ),
              Positioned(
                right: displayWidth(context) * 0.34,
                top: displayHeight(context) * 0.5,
                child: Container(
                  alignment: Alignment(0, 0.15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF0D47A1),
                                  Color(0xFF0D47A1),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            if (openstatus) {
                              //Sends close command to vent and checks quality
                              sendcmd("close");
                              sendcmd('quality');
                              openstatus = false;
                            } else {
                              //Sends open command to vent and checks quality
                              sendcmd("open");
                              sendcmd('quality');
                              openstatus = true;
                            }
                            setState(() {});
                          },
                          //displays current option for vent
                          child: openstatus
                              ? Text("Close Vent")
                              : Text("Open Vent"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.05,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SetPage extends StatelessWidget {
  SetPage(
      {Key? key,
      required this.current,
      required this.desired,
      required this.temp1})
      : super(key: key);
  String temp1;
  String current;
  String desired;
  final String title = 'Set Vent';
  final myController = TextEditingController();

  bool openstatus = false;
  late IOWebSocketChannel channel;
  bool connected = false; //boolean value to track if WebSocket is connected
  int count = 0;
  static DateTime now = DateTime.parse("2023-02-19 12:21:04Z"); //
  static late DateFormat formatter = DateFormat('MM-dd-yyyy HH-mm'); //
  late String formatted = formatter.format(now); //
  late int filtration = 3;
  int temp = 0;
  late String image = '';

//attempts to connnect to websocket
  channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://172.20.10.3:81"); //channel IP : Port
      channel.stream.listen(
        (message) {
          print(message);
          if (message == "connected") {
            connected = true; //message is "connected" from NodeMCU
          }
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
      print('Catch STATEMENT');
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      //only runs if websokcet is connected
      if (false //openstatus == false &&
          //cmd != "open" &&
          //cmd != "close" &&
          //cmd != "ping" &&
          //cmd != "quality" &&
          //cmd != 'temp' &&
          //cmd.isEmpty != true
          ) {
        print("Send the valid command");
      } else {
        channel.sink.add(cmd); //sending Command to NodeMCU
      }
    } else {
      channelconnect(); //reconnects if connection was not successful
      print("Connection Failed. ELSE");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(BackArrow3.image),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: CustomPaint(
        painter: BluePainter(),
        child: Center(
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment(0, -0.2),
                child: SizedBox(
                  width: 200,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        //border: //UnderlineInputBorder(),
                        label: Center(
                            child: Text(
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          'Enter Desired Temp',
                        )),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    validator: (String? value) {
                      return (value != null && value.contains('@'))
                          ? 'Do not use the @ character.'
                          : null;
                    },
                    onChanged: (value) {
                      desired = value;
                    },
                  ),
                ),

                //),
              ),
              const SizedBox(height: 30),
              Stack(children: <Widget>[
                Positioned(
                  top: 435,
                  right: 125,
                  width: 120,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      alignment: Alignment(displayWidth(context) * 0.5,
                          displayHeight(context) * 0.5),
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF0D47A1),
                                  Color(0xFF0D47A1),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16.0),
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              String temporary = '$desired';
                              print(temporary);
                              sendcmd(temporary);
                              (context as Element).markNeedsBuild();
                            },
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              Stack(children: <Widget>[
                Positioned(
                  top: 520,
                  right: 50,
                  width: 110,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF1976D2),
                                  Color(0xFF42A5F5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            style: TextStyle(fontSize: 15, color: Colors.white),
                            'Desired: $desired',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              Stack(children: <Widget>[
                Positioned(
                  top: 520,
                  left: 60,
                  width: 100,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          //left: displayWidth(context) * 0.4,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF1976D2),
                                  Color(0xFF42A5F5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            style: TextStyle(fontSize: 15, color: Colors.white),
                            'Current: $current',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

//Custom Background
class BluePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    //background here
    final width = size.width;
    final height = size.height;
    Paint paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = Color.fromARGB(255, 100, 154, 209);
    canvas.drawPath(mainBackground, paint);

    Path darkArrow = Path();
    darkArrow.moveTo(0, height);
    darkArrow.lineTo(width * 0.75, height * 0.5);
    darkArrow.lineTo(0, 0);
    darkArrow.lineTo(width * 0.25, 0);
    darkArrow.lineTo(width, height * 0.5);
    //darkArrow.lineTo(width, height * 0.65);
    darkArrow.lineTo(width * 0.25, height);
    darkArrow.close();
    paint.color = Color.fromARGB(255, 18, 8, 146);
    canvas.drawPath(darkArrow, paint);

    Path midArrow = Path();
    midArrow.moveTo(0, height * 0.85);
    midArrow.lineTo(width * 0.5, height * 0.5);
    midArrow.lineTo(0, height * 0.15);
    midArrow.lineTo(0, 0);
    midArrow.lineTo(width * 0.75, height * 0.5);
    midArrow.lineTo(0, 0);
    midArrow.close();
    paint.color = Color.fromARGB(255, 1, 142, 185);
    canvas.drawPath(midArrow, paint);

    Path lightArrow = Path();
    lightArrow.moveTo(0, height * 0.69);
    lightArrow.lineTo(width * 0.27, height * 0.5);
    lightArrow.lineTo(0, height * 0.31);
    lightArrow.lineTo(0, height * 0.15);
    lightArrow.lineTo(width * 0.5, height * 0.5);
    lightArrow.lineTo(0, height * 0.85);
    lightArrow.close();
    paint.color = Color.fromARGB(255, 61, 194, 228);
    canvas.drawPath(lightArrow, paint);

    Path topRightTriangle = Path();
    topRightTriangle.moveTo(width, 0);
    topRightTriangle.lineTo(width, height * 0.5);
    topRightTriangle.lineTo(width * 0.25, 0);
    topRightTriangle.close();
    paint.color = Color.fromARGB(255, 255, 255, 255);
    canvas.drawPath(topRightTriangle, paint);

    Path bottomRightTriangle = Path();
    bottomRightTriangle.moveTo(width, height);
    bottomRightTriangle.lineTo(width, height * 0.5);
    bottomRightTriangle.lineTo(width * 0.25, height);
    bottomRightTriangle.close();
    paint.color = Color.fromARGB(255, 255, 255, 255);
    canvas.drawPath(bottomRightTriangle, paint);

    Path midTriangle = Path();
    midTriangle.moveTo(0, height * 0.69);
    midTriangle.lineTo(width * 0.27, height * 0.5);
    midTriangle.lineTo(0, height * 0.31);
    midTriangle.close();
    paint.color = Color.fromARGB(255, 255, 255, 255);
    canvas.drawPath(midTriangle, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    //applies background at all times
    return oldDelegate != this;
  }
}
