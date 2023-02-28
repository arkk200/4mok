import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Socket socket;

  Future<void> initSocket() async {
    try {
      socket = io('http://121.174.55.140:8080', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      socket.connect();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  @override
  void dispose() {
    super.dispose();
    socket.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen.fromMain(socket: socket),
    );
  }
}
