import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- SAUVEGARDE ET CHARGEMENT ---
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                const Text('🟢 Chambres Libres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSubSection('Grand Lit (GL) & Suites', libresGL, Colors.green.shade100),
                const SizedBox(height: 8),
                _buildSubSection('Lit Double (LD)', libresLD, Colors.teal.shade100),
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

  Widget _buildSubSection(String title, List<Room> roomList, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.7))),
        const SizedBox(height: 4),
        _buildRoomGrid(roomList, cardColor, RoomStatus.libre),
      ],
    );
  }

  Widget _buildRoomGrid(List<Room> roomList, Color cardColor, RoomStatus sectionStatus) {
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

        return InkWell(
          onTap: () => _handleRoomTap(room),
          onLongPress: sectionStatus == RoomStatus.occupee ? () => _confirmCancelDialog(room) : null,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Center(
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
          ),
        );
      },
    );
  }

  // Clic sur une chambre
  void _handleRoomTap(Room room) {
    if (room.status == RoomStatus.libre) {
      _showRentalTypeDialog(room);
    } else if (room.status == RoomStatus.occupee) {
      // Passer en chambre sale individuellement
      setState(() {
        room.status = RoomStatus.sale;
        if (room.pairedWith != null) {
          try {
            final paired = rooms.firstWhere((r) => r.number == room.pairedWith);
            paired.pairedWith = null;
          } catch (_) {}
          room.pairedWith = null;
        }
      });
      _saveData();
    } else if (room.status == RoomStatus.sale) {
      // Nettoyée -> Libre
      setState(() {
        room.status = RoomStatus.libre;
      });
      _saveData();
    }
  }

  // Dialogue de choix : Unique ou Couple
  void _showRentalTypeDialog(Room room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Location Chambre ${room.number}'),
        content: const Text('Souhaitez-vous louer cette chambre en mode Unique ou Couple ?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _rentSingle(room);
            },
            child: const Text('Unique'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _showCouplePairingDialog(room);
            },
            child: const Text('Couple (2 chambres)'),
          ),
        ],
      ),
    );
  }

  // Location unique
  void _rentSingle(Room room) {
    setState(() {
      room.status = RoomStatus.occupee;
      transactions.add(RoomTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomInfo: 'Chambre ${room.number}',
        amount: room.price,
        date: DateTime.now(),
      ));
    });
    _saveData();
  }

  // Dialogue d'association pour le mode Couple (Sélection obligatoire)
  void _showCouplePairingDialog(Room firstRoom) {
    // Si la 1ère chambre est GL ou Suite, on cherche une chambre LD libre.
    // Si la 1ère est LD, on cherche une GL ou Suite libre.
    final targetTypeIsLD = (firstRoom.type == 'GL' || firstRoom.type == 'Suite');
    final availablePairRooms = rooms
        .where((r) =>
            r.status == RoomStatus.libre &&
            r.number != firstRoom.number &&
            (targetTypeIsLD ? r.type == 'LD' : (r.type == 'GL' || r.type == 'Suite')))
        .toList();

    if (availablePairRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible : Aucune chambre ${targetTypeIsLD ? 'LD' : 'GL/Suite'} libre à associer !'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Couple : Associer Ch ${firstRoom.number} à...'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availablePairRooms.length,
            itemBuilder: (context, index) {
              final secondRoom = availablePairRooms[index];
              return ListTile(
                title: Text('Chambre ${secondRoom.number} (${secondRoom.type})'),
                subtitle: Text('${secondRoom.price.toStringAsFixed(0)} DA (Offerte en Couple)'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  _rentCouple(firstRoom, secondRoom);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          )
        ],
      ),
    );
  }

  // Valider la location Couple
  void _rentCouple(Room room1, Room room2) {
    setState(() {
      room1.status = RoomStatus.occupee;
      room1.pairedWith = room2.number;

      room2.status = RoomStatus.occupee;
      room2.pairedWith = room1.number;

      // Déterminer la chambre GL / Suite à facturer
      Room billedRoom = (room1.type == 'GL' || room1.type == 'Suite') ? room1 : room2;

      transactions.add(RoomTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomInfo: 'Couple (Ch ${room1.number} / Ch ${room2.number})',
        amount: billedRoom.price, // Seule la GL est facturée
        date: DateTime.now(),
      ));
    });
    _saveData();
  }

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
