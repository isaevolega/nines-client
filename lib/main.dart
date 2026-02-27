import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/websocket_service.dart';
import 'providers/game_provider.dart';
import 'screens/lobby/lobby_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WebSocketService>(
          create: (_) => WebSocketService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider<GameProvider>(
          create: (context) => GameProvider(
            context.read<WebSocketService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Девятка',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        home: const LobbyScreen(),
      ),
    );
  }
}