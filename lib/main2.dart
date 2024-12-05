import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'schedule_page.dart';
import 'firebase_options.dart';
import 'CountdownPage.dart';
import 'CountdownProvider.dart';
import 'more_options_page.dart';
import 'history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CountdownProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: SmartSocketApp(),
    ),
  );
}

class SmartSocketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SmartSocketHome(),
    );
  }
}

class SmartSocketHome extends StatefulWidget {
  @override
  _SmartSocketHomeState createState() => _SmartSocketHomeState();
}

class _SmartSocketHomeState extends State<SmartSocketHome> {
  List<bool> _switches = [false, false, false]; // Mặc định là tắt

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Smart Socket'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.flash_on,
                          color: (_switches[i]) ? Colors.yellow : Colors.grey,
                        ),
                        iconSize: 80.0,
                        onPressed: () {
                          setState(() {
                            _switches[i] = !_switches[i];
                          });

                          Provider.of<HistoryProvider>(context, listen: false)
                              .addEvent('Thiết bị $i đã ${_switches[i] ? 'bật' : 'tắt'}');
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.schedule, size: 40.0),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SchedulePage()),
                              );
                            },
                          ),
                          SizedBox(height: 5),
                          Text('Lập lịch'),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Switch(
                              value: _switches[0],
                              onChanged: (bool value) {
                                setState(() {
                                  _switches[0] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.timer, size: 40.0),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CountdownPage()),
                              );
                            },
                          ),
                          SizedBox(height: 5),
                          Text('Đếm ngược'),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Switch(
                              value: _switches[1],
                              onChanged: (bool value) {
                                setState(() {
                                  _switches[1] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.apps, size: 40.0),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MoreOptionsPage()),
                              );
                            },
                          ),
                          SizedBox(height: 5),
                          Text('Nhiều hơn'),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Switch(
                              value: _switches[2],
                              onChanged: (bool value) {
                                setState(() {
                                  _switches[2] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
