import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/screens/game_screen.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MainScreen extends StatefulWidget {
  final Socket socket;
  const MainScreen.fromMain({super.key, required this.socket});
  const MainScreen.fromGameScreen({super.key, required this.socket});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final Socket socket;
  Map<String, String> playerInfo = {};
  String? code;

  @override
  void initState() {
    super.initState();
    socket = widget.socket;
  }

  void setFoundSocketEvent() {
    socket.once('found', (data) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                GameScreen.fromMainScreen(
              socket: socket,
              roomId: data['roomId'],
              firstOrder: data['firstOrder'],
              playersInfo: data['playersInfo'],
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
      debugPrint("Player founded!");
    });
  }

  void handleConnectOnline(context) {
    showAlert(AlertDialog(
      title: const Text("Looking for a game partner..."),
      actions: [
        TextButton(
          onPressed: () {
            socket.emit('onlineCancel', {'code': code});
            debugPrint('onlineCancel');
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
      ],
    ));
    socket.emit('online', playerInfo);
    setFoundSocketEvent();
  }

  Future<dynamic> getCode() async {
    final completer = Completer();
    socket.once('code', (data) {
      code = data;
      completer.complete(code);
    });
    return completer.future;
  }

  void onHost(context) {
    showAlert(
      AlertDialog(
        title: const Text('host'),
        content: FutureBuilder(
          future: getCode(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              code = snapshot.data;
              return Text(snapshot.data!);
            } else {
              return const Text("...");
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              socket.emit('hostCancel', {'code': code});
              debugPrint('hostCancel');
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
    socket.emit('host', playerInfo);
    setFoundSocketEvent();
  }

  void onJoin(context) {
    socket.once('notFound', (_) {
      Navigator.pop(context);
      showAlert(AlertDialog(
        title: const Text('Host not found'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ok"),
          ),
        ],
      ));
    });
    showAlert(AlertDialog(
      title: const Text('join'),
      actions: [
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "enter the code",
          ),
          onChanged: (value) {
            code = value;
          },
        ),
        TextButton(
          onPressed: () {
            if (code?.length != 4) return;
            socket.emit('join', {
              'playerInfo': playerInfo,
              'code': code,
            });
          },
          child: const Text("join"),
        ),
      ],
    ));
    setFoundSocketEvent();
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
            onPressed: () => handleConnectOnline(context),
            child: const Text("online"),
          ),
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                onPressed: () => onHost(context),
                child: const Text("host"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  onJoin(context);
                },
                child: const Text("join"),
              ),
            ],
          )
        ],
      ),
    );
  }

  void showAlert(alertWidget) {
    showDialog(
      context: context,
      builder: (context) => alertWidget,
      barrierDismissible: false,
    );
  }
}
