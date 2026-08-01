Import 'package:flutter/material.dart';

void main() {
  runApp(const HotelApp());
}

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Hôtel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HotelHomeScreen(),
    );
  }
}

enum RoomStatus { libre, occupee, sale }

class Room {
  final String number;
  final String type;
  final double price;
  RoomStatus status;
  String? pairedWith;

  Room({
    required this.number,
    required this.type,
    required this.price,
    this.status = RoomStatus.libre,
    this.pairedWith,
  });
}

class HotelHomeScreen extends StatefulWidget {
  const HotelHomeScreen({super.key});

  @override
  State<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> {
  final List<Room> rooms = [
    Room(number: '102', type: 'Suite', price: 7000),
    Room(number: '103', type: 'GL', price: 5000),
    Room(number: '104', type: 'GL', price: 5000),
    Room(number: '108', type: 'GL', price: 5000),
    Room(number: '109', type: 'GL', price: 5000),
    Room(number: '112', type: 'GL', price: 5000),
    Room(number: '115', type: 'GL', price: 5000),
    Room(number: '118', type: 'GL', price: 5000),
    Room(number: '119', type: 'GL', price: 5000),
    Room(number: '120', type: 'GL', price: 5000),
    Room(number: '105', type: 'LD', price: 5000),
    Room(number: '106', type: 'LD', price: 5000),
    Room(number: '107', type: 'LD', price: 5000),
    Room(number: '110', type: 'LD', price: 5000),
    Room(number: '111', type: 'LD', price: 5000),
    Room(number: '113', type: 'LD', price: 5000),
    Room(number: '114', type: 'LD', price: 5000),
    Room(number: '116', type: 'LD', price: 5000),
    Room(number: '117', type: 'LD', price: 5000),
  ];

  double totalRecette = 0.0;
  Room? selectedGLForCouple;
  bool isCoupleMode = false;

  @override
  Widget build(BuildContext context) {
    final libresGL = rooms.where((r) => r.status == RoomStatus.libre && (r.type == 'GL' || r.type == 'Suite')).toList();
    final libresLD = rooms.where((r) => r.status == RoomStatus.libre && r.type == 'LD').toList();
    final occupees = rooms.where((r) => r.status == RoomStatus.occupee).toList();
    final sales = rooms.where((r) => r.status == RoomStatus.sale).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de Réception'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Recette (Cumul) :', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(
                      '${totalRecette.toStringAsFixed(0)} DA',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                if (isCoupleMode)
                  Chip(
                    avatar: const Icon(Icons.add_circle, color: Colors.white),
                    label: Text('Couple: GL ${selectedGLForCouple?.number} + LD ?'),
                    backgroundColor: Colors.orange,
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    onDeleted: () {
                      setState(() {
                        isCoupleMode = false;
                        selectedGLForCouple = null;
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                const Text('🟢 Chambres Libres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSubSection('Grand Lit (GL) & Suites', libresGL, Colors.green.shade100, isGL: true),
                const SizedBox(height: 8),
                _buildSubSection('Lit Double (LD)', libresLD, Colors.teal.shade100, isGL: false),
                const Divider(height: 32, thickness: 2),
                const Text('🔴 Chambres Occupées', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildRoomGrid(occupees, Colors.red.shade100, RoomStatus.occupee),
                const Divider(height: 32, thickness: 2),
                const Text('🧹 Chambres Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildRoomGrid(sales, Colors.orange.shade100, RoomStatus.sale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, List<Room> roomList, Color cardColor, {required bool isGL}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.7))),
        const SizedBox(height: 4),
        _buildRoomGrid(roomList, cardColor, RoomStatus.libre, isGLSection: isGL),
      ],
    );
  }

  Widget _buildRoomGrid(List<Room> roomList, Color cardColor, RoomStatus sectionStatus, {bool isGLSection = false}) {
    if (roomList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Aucune chambre', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: roomList.length,
      itemBuilder: (context, index) {
        final room = roomList[index];
        final isSelectedForCouple = selectedGLForCouple?.number == room.number;

        return InkWell(
          onTap: () => _handleRoomTap(room),
          child: Container(
            decoration: BoxDecoration(
              color: isSelectedForCouple ? Colors.orange.shade200 : cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelectedForCouple ? Colors.orange : Colors.black12,
                width: isSelectedForCouple ? 3 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ch ${room.number}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text('${room.price.toStringAsFixed(0)} DA', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      if (room.pairedWith != null)
                        Text('↳ Linked: ${room.pairedWith}', style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (sectionStatus == RoomStatus.libre && isGLSection && !isCoupleMode)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.orange, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          isCoupleMode = true;
                          selectedGLForCouple = room;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleRoomTap(Room room) {
    setState(() {
      if (room.status == RoomStatus.libre) {
        if (isCoupleMode) {
          if (room.type == 'LD' && selectedGLForCouple != null) {
            final glRoom = selectedGLForCouple!;
            glRoom.status = RoomStatus.occupee;
            glRoom.pairedWith = room.number;

            room.status = RoomStatus.occupee;
            room.pairedWith = glRoom.number;

            totalRecette += glRoom.price;

            isCoupleMode = false;
            selectedGLForCouple = null;
          }
        } else {
          room.status = RoomStatus.occupee;
          totalRecette += room.price;
        }
      } else if (room.status == RoomStatus.occupee) {
        room.status = RoomStatus.sale;
        if (room.pairedWith != null) {
          final pairedRoom = rooms.firstWhere((r) => r.number == room.pairedWith);
          pairedRoom.status = RoomStatus.sale;
          pairedRoom.pairedWith = null;
          room.pairedWith = null;
        }
      } else if (room.status == RoomStatus.sale) {
        room.status = RoomStatus.libre;
      }
    });
