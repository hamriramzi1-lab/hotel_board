import 'package:flutter/material.dart';

void main() {
  runApp(const HotelBoardApp());
}

class HotelBoardApp extends StatelessWidget {
  const HotelBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Board',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HotelHomeScreen(),
    );
  }
}

class HotelHomeScreen extends StatefulWidget {
  const HotelHomeScreen({super.key});

  @override
  State<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> {
  // Liste des chambres d'exemple
  final List<Map<String, dynamic>> _rooms = [
    {'number': '101', 'type': 'GL', 'status': 'Libre', 'price': 3000},
    {'number': '102', 'type': 'LD', 'status': 'Occupée', 'price': 4500},
    {'number': '103', 'type': 'GL', 'status': 'Sale', 'price': 3000},
    {'number': '104', 'type': 'LD', 'status': 'Libre', 'price': 4500},
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Libre':
        return Colors.green;
      case 'Occupée':
        return Colors.red;
      case 'Sale':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Hôtel 🏨'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _rooms.length,
          itemBuilder: (context, index) {
            final room = _rooms[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(room['status']),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chambre ${room['number']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text('Type : ${room['type']}'),
                    Text('${room['price']} DZD / nuit'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(room['status']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room['status'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
