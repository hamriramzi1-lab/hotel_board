import 'package:flutter/material.dart';

void main() {
  runApp(const HotelBoardApp());
}

class HotelBoardApp extends StatelessWidget {
  const HotelBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tableau d\'hôtel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class Room {
  final String number;
  final String type; // GL (Grand Lit) ou LD (Lits Disjoints)
  String status; // Libre, Occupée, Sale
  double price;
  String? notes;

  Room({
    required this.number,
    required this.type,
    this.status = 'Libre',
    required this.price,
    this.notes,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Liste initiale des chambres de l'hôtel
  final List<Room> rooms = [
    Room(number: '101', type: 'GL', status: 'Libre', price: 4000),
    Room(number: '102', type: 'LD', status: 'Occupée', price: 4500),
    Room(number: '103', type: 'GL', status: 'Sale', price: 4000),
    Room(number: '201', type: 'GL', status: 'Libre', price: 5000),
    Room(number: '202', type: 'LD', status: 'Occupée', price: 5500),
  ];

  double get totalRevenue {
    return rooms
        .where((r) => r.status == 'Occupée')
        .fold(0, (sum, item) => sum + item.price);
  }

  Color getStatusColor(String status) {
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

  void _showEditDialog(Room room) {
    final noteController = TextEditingController(text: room.notes);
    String selectedStatus = room.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulWidget(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Chambre ${room.number} (${room.type})'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: ['Libre', 'Occupée', 'Sale'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setDialogState(() {
                        selectedStatus = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Observations',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      room.status = selectedStatus;
                      room.notes = noteController.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Hôtel'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // En-tête : Chiffre d'affaires
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recette du jour :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalRevenue.toStringAsFixed(0)} DZD',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // Liste des chambres
          Expanded(
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getStatusColor(room.status),
                      child: Text(
                        room.type,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text('Chambre ${room.number}'),
                    subtitle: Text(
                      'Statut : ${room.status}\nTarif : ${room.price.toStringAsFixed(0)} DZD'
                      '${room.notes != null && room.notes!.isNotEmpty ? "\nNote : ${room.notes}" : ""}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(room),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
