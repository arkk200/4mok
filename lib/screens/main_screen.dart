import 'package:flutter/material.dart';
import 'package:frontend/screens/game_screen.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MainScreen extends StatefulWidget {
  final Socket socket;
  const MainScreen.fromMain({super.key, required this.socket});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final Socket socket;
  Map<String, String> playerInfo = {};

  @override
  void initState() {
    super.initState();
    socket = widget.socket;
  }

  void onConnectOnline(context) {
    if (socket.id == null) return;
    socket.emit('online', playerInfo);
    socket.on('found', (data) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen.fromMainScreen(
            socket: socket,
            roomId: data['roomId'],
            firstOrder: data['firstOrder'],
            playersId: [
              data['playersId'][0],
              data['playersId'][1],
            ],
          ),
        ),
      );
      debugPrint("Player founded!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "nickname",
            ),
            onChanged: (value) {
              setState(() {
                playerInfo["nickname"] = value;
              });
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () => onConnectOnline(context),
            child: const Text("online"),
          )
        ],
      ),
    );
  }
}
