import 'dart:async';
import 'dart:math';

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
  Map<String, String> playerInfo = {
    "image": "",
    "nickname": "",
  };
  String? code;
  int image = Random().nextInt(1) > 0.5
      ? Random().nextInt(0xf8ff - 0xe000 + 1) + 0xe000
      : Random().nextInt(0xf08b9 - 0xf0000 + 1) + 0xf0000;

  @override
  void initState() {
    super.initState();
    socket = widget.socket;
    playerInfo['image'] = "$image";
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
    socket.emit('online', {
      "nickname":
          playerInfo['nickname'] == "" ? "unknown" : playerInfo['nickname'],
      "image": playerInfo['image']
    });
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
        title: const Text('Host'),
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
    socket.emit('host', {
      "nickname":
          playerInfo['nickname'] == "" ? "unknown" : playerInfo['nickname'],
      "image": playerInfo['image'],
    });
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
      title: const Text('Join'),
      content: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "enter the code",
        ),
        onChanged: (value) {
          code = value;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (code?.length != 4) return;
            socket.emit('join', {
              'playerInfo': {
                "nickname": playerInfo['nickname'] == ""
                    ? "unknown"
                    : playerInfo['nickname'],
                "image": playerInfo['image'],
              },
              'code': code,
            });
          },
          child: const Text("Join"),
        ),
      ],
    ));
    setFoundSocketEvent();
  }

  void changeIcon() {
    const emojiRange1 = 0xf8ff - 0xe000 + 1;
    const emojiRange2 = 0xf08b9 - 0xf0000 + 1;
    setState(() {
      image = Random().nextInt(emojiRange1 + emojiRange2) < emojiRange1
          ? Random().nextInt(emojiRange1) + 0xe000
          : Random().nextInt(emojiRange2) + 0xf0000;
      playerInfo['image'] = "$image";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "4mok",
            style: TextStyle(
              fontSize: 60,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: changeIcon,
                icon: const Icon(Icons.change_circle_outlined),
                iconSize: 32,
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                clipBehavior: Clip.hardEdge,
                child: Icon(
                  IconData(image, fontFamily: 'MaterialIcons'),
                  size: 50,
                ),
              ),
              const SizedBox(
                width: 48,
                height: 48,
              )
            ],
          ),
          Container(
            width: 216,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                counterText: "",
                hintText: "nickname",
              ),
              maxLength: 10,
              style: const TextStyle(
                fontSize: 20,
                decoration: TextDecoration.underline,
              ),
              onChanged: (value) {
                setState(() {
                  playerInfo["nickname"] = value;
                });
              },
            ),
          ),
          const SizedBox(
            height: 26,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 216,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => handleConnectOnline(context),
                  child: const Text(
                    "Online",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(
                width: 34,
              ),
              Container(
                width: 216,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => showAlert(
                    AlertDialog(
                      content: Column(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () => onHost(context),
                            child: const Text("Host"),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              onJoin(context);
                            },
                            child: const Text("Join"),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  ),
                  child: const Text(
                    "With friend",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
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
