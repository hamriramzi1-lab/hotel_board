import 'dart0:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() => {
        'number': number,
        'type': type,
        'price': price,
        'status': status.name,
        'pairedWith': pairedWith,
      };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        number: json['number'],
        type: json['type'],
        price: (json['price'] as num).toDouble(),
        status: RoomStatus.values.byName(json['status']),
        pairedWith: json['pairedWith'],
      );
}

class RoomTransaction {
  final String id;
  final String roomInfo;
  final double amount;
  final DateTime date;

  RoomTransaction({
    required this.id,
    required this.roomInfo,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomInfo': roomInfo,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory RoomTransaction.fromJson(Map<String, dynamic> json) => RoomTransaction(
        id: json['id'],
        roomInfo: json['roomInfo'],
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
      );
}

class HotelHomeScreen extends StatefulWidget {
  const HotelHomeScreen({super.key});

  @override
  State<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> {
  List<Room> rooms = [];
  List<RoomTransaction> transactions = [];

  Room? selectedGLForCouple;
  bool isCoupleMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- SAUVEGARDE ET CHARGEMENT (SharedPreferences) ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final String? roomsJson = prefs.getString('hotel_rooms_data');
    if (roomsJson != null) {
      final List<dynamic> decoded = jsonDecode(roomsJson);
      rooms = decoded.map((item) => Room.fromJson(item)).toList();
    } else {
      _initDefaultRooms();
    }

    final String? txJson = prefs.getString('hotel_tx_data');
    if (txJson != null) {
      final List<dynamic> decoded = jsonDecode(txJson);
      transactions = decoded.map((item) => RoomTransaction.fromJson(item)).toList();
    }

    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String roomsEncoded = jsonEncode(rooms.map((r) => r.toJson()).toList());
    final String txEncoded = jsonEncode(transactions.map((t) => t.toJson()).toList());

    await prefs.setString('hotel_rooms_data', roomsEncoded);
    await prefs.setString('hotel_tx_data', txEncoded);
  }

  void _initDefaultRooms() {
    rooms = [
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
    _saveData();
  }

  // --- CALCULS RECETTES ---
  double get _recetteDuJour {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _recetteCumulTotal => transactions.fold(0.0, (sum, t) => sum + t.amount);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique des recettes',
            onPressed: _showHistoryDialog,
          )
        ],
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
                    const Text('Recette du Jour :', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${_recetteDuJour.toStringAsFixed(0)} DA',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Cumulé :', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${_recetteCumulTotal.toStringAsFixed(0)} DA',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isCoupleMode)
            Container(
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Couple : GL ${selectedGLForCouple?.number} sélectionné. Choisissez une chambre LD.',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isCoupleMode = false;
                        selectedGLForCouple = null;
                      });
                    },
                    child: const Text('Annuler', style: TextStyle(color: Colors.red)),
                  )
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
                const Text('🔴 Chambres Occupées (Appui long pour annuler)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: roomList.length,
      itemBuilder: (context, index) {
        final room = roomList[index];
        final isSelectedForCouple = selectedGLForCouple?.number == room.number;

        return InkWell(
          onTap: () => _handleRoomTap(room),
          onLongPress: sectionStatus == RoomStatus.occupee ? () => _confirmCancelDialog(room) : null,
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

            // On ajoute la transaction uniquement pour la chambre GL (5000 DA)
            transactions.add(RoomTransaction(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              roomInfo: 'Couple (Ch ${glRoom.number} / Ch ${room.number})',
              amount: glRoom.price,
              date: DateTime.now(),
            ));

            isCoupleMode = false;
            selectedGLForCouple = null;
          }
        } else {
          room.status = RoomStatus.occupee;
          transactions.add(RoomTransaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            roomInfo: 'Chambre ${room.number}',
            amount: room.price,
            date: DateTime.now(),
          ));
        }
      } else if (room.status == RoomStatus.occupee) {
        // Envoi vers chambre sale INDIVIDUELLEMENT
        room.status = RoomStatus.sale;
        if (room.pairedWith != null) {
          // Si liée à un couple, on rompt le lien sur l'autre chambre qui reste occupée
          try {
            final pairedRoom = rooms.firstWhere((r) => r.number == room.pairedWith);
            pairedRoom.pairedWith = null;
          } catch (_) {}
          room.pairedWith = null;
        }
      } else if (room.status == RoomStatus.sale) {
        // De sale à libre par chambre unique
        room.status = RoomStatus.libre;
      }
    });
    _saveData();
  }

  // Dialogue d'annulation de réservation
  void _confirmCancelDialog(Room room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Annuler réservation Ch ${room.number}'),
        content: const Text('Voulez-vous annuler cette réservation ? La chambre repassera en libre et le paiement sera retiré.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Non')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _cancelReservation(room);
              Navigator.pop(ctx);
            },
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _cancelReservation(Room room) {
    setState(() {
      // Retirer la transaction associée
      transactions.removeWhere((t) => t.roomInfo.contains(room.number));

      if (room.pairedWith != null) {
        try {
          final pairedRoom = rooms.firstWhere((r) => r.number == room.pairedWith);
          pairedRoom.status = RoomStatus.libre;
          pairedRoom.pairedWith = null;
        } catch (_) {}
      }

      room.status = RoomStatus.libre;
      room.pairedWith = null;
    });
    _saveData();
  }

  // Historique des recettes
  void _showHistoryDialog() {
    Map<String, List<RoomTransaction>> grouped = {};
    for (var tx in transactions) {
      String dateKey = "${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}";
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📜 Historique des Recettes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: grouped.isEmpty
                    ? const Center(child: Text('Aucune recette enregistrée'))
                    : ListView(
                        children: grouped.entries.map((entry) {
                          double totalJour = entry.value.fold(0.0, (sum, item) => sum + item.amount);
                          return ExpansionTile(
                            title: Text('Date : ${entry.key}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Total : ${totalJour.toStringAsFixed(0)} DA', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                            children: entry.value.map((tx) {
                              return ListTile(
                                title: Text(tx.roomInfo),
                                subtitle: Text('${tx.date.hour}h${tx.date.minute.toString().padLeft(2, '0')}'),
                                trailing: Text('${tx.amount.toStringAsFixed(0)} DA', style: const TextStyle(fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
