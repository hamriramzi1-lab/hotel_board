import 'dart:async';
import 'package:flutter/material.dart';

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
  double priceCharged; // Stocke la somme exacte encaissée (0 DA si LD en couple)

  Room({
    required this.number,
    required this.type,
    required this.price,
    this.status = RoomStatus.libre,
    this.pairedWith,
    this.priceCharged = 0.0,
  });
}

class DailyHistory {
  final String date;
  final double amount;

  DailyHistory({required this.date, required this.amount});
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
  List<DailyHistory> historyList = [];

  Room? selectedGLForCouple;
  bool isCoupleMode = false;

  Timer? _midnightTimer;
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Clôture automatique des comptes à minuit
    _midnightTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.day != _currentDate.day) {
        setState(() {
          final formattedDate = "${_currentDate.day}/${_currentDate.month}/${_currentDate.year}";
          historyList.insert(0, DailyHistory(date: formattedDate, amount: totalRecette));
          _currentDate = now;
          totalRecette = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.history, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Historique des Recettes'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: historyList.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Aucune journée archivée pour le moment.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final item = historyList[index];
                    return ListTile(
                      leading: const Icon(Icons.calendar_today, size: 20),
                      title: Text('Date : ${item.date}'),
                      trailing: Text(
                        '${item.amount.toStringAsFixed(0)} DA',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = "${_currentDate.day}/${_currentDate.month}/${_currentDate.year}";
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
                    Text('📅 Date : $dateStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const SizedBox(height: 2),
                    const Text('Total Recette (Cumul) :', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(
                      '${totalRecette.toStringAsFixed(0)} DA',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.blueAccent),
                      onPressed: _showHistoryDialog,
                      tooltip: 'Voir Historique',
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

        // Détermine le texte du tarif à afficher sur la carte
        String displayPrice = '${room.price.toStringAsFixed(0)} DA';
        if (room.status == RoomStatus.occupee) {
          displayPrice = '${room.priceCharged.toStringAsFixed(0)} DA';
        }

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
                      Text(
                        displayPrice,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: room.status == RoomStatus.occupee && room.priceCharged == 0.0 ? FontWeight.bold : FontWeight.normal,
                          color: room.status == RoomStatus.occupee && room.priceCharged == 0.0 ? Colors.blue.shade900 : Colors.black87,
                        ),
                      ),
                      if (room.pairedWith != null)
                        Text(
                          '↳ Linked: ${room.pairedWith}',
                          style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
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
    // 1. SI LE MODE COUPLE EST EN COURS
    if (isCoupleMode) {
      if (selectedGLForCouple == null) return;

      // Clic sur la même chambre GL pour annuler la sélection couple
      if (room.number == selectedGLForCouple!.number) {
        setState(() {
          isCoupleMode = false;
          selectedGLForCouple = null;
        });
        return;
      }

      // Clic sur une chambre LD qui est LIBRE
      if (room.status == RoomStatus.libre && room.type == 'LD') {
        setState(() {
          final gl = selectedGLForCouple!;

          // Enregistrement de la GL (facturée)
          gl.status = RoomStatus.occupee;
          gl.pairedWith = room.number;
          gl.priceCharged = gl.price; // 5000 DA ou 7000 DA

          // Enregistrement de la LD (non facturée)
          room.status = RoomStatus.occupee;
          room.pairedWith = gl.number;
          room.priceCharged = 0.0; // STRICTEMENT 0 DA

          // Ajout unique de la somme au total global
          totalRecette += gl.priceCharged;

          // Réinitialisation de l'état
          isCoupleMode = false;
          selectedGLForCouple = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une chambre LD LIBRE (section verte en bas).'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // 2. GESTION CLASSIQUE DE LA CHAMBRE
    if (room.status == RoomStatus.libre) {
      // Réservation simple
      setState(() {
        room.status = RoomStatus.occupee;
        room.priceCharged = room.price;
        totalRecette += room.priceCharged;
      });
    } else if (room.status == RoomStatus.occupee) {
      // Menu au clic sur une chambre occupée
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.cleaning_services, color: Colors.orange),
                  title: const Text('Départ client (Mettre en chambre Sale)'),
                  subtitle: const Text('Seule cette chambre passe en sale.'),
                  onTap: () {
                    Navigator.pop(context);
                    _checkoutSingleRoom(room);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Annuler la réservation'),
                  subtitle: Text('Rembourse ${room.priceCharged.toStringAsFixed(0)} DA et remet la chambre en libre.'),
                  onTap: () {
                    Navigator.pop(context);
                    _cancelReservation(room);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else if (room.status == RoomStatus.sale) {
      // Remise en libre après ménage
      setState(() {
        room.status = RoomStatus.libre;
      });
    }
  }

  // Libère uniquement la chambre sélectionnée (passage en sale)
  void _checkoutSingleRoom(Room room) {
    setState(() {
      room.status = RoomStatus.sale;

      // Rompt le lien avec l'autre chambre sans la basculer en sale
      if (room.pairedWith != null) {
        final pairedIndex = rooms.indexWhere((r) => r.number == room.pairedWith);
        if (pairedIndex != -1) {
          rooms[pairedIndex].pairedWith = null;
        }
        room.pairedWith = null;
      }
    });
  }

  // Annule la réservation et déduit exactement le montant encaissé
  void _cancelReservation(Room room) {
    setState(() {
      totalRecette -= room.priceCharged;
      if (totalRecette < 0) totalRecette = 0.0;

      room.status = RoomStatus.libre;
      room.priceCharged = 0.0;

      if (room.pairedWith != null) {
        final pairedIndex = rooms.indexWhere((r) => r.number == room.pairedWith);
        if (pairedIndex != -1) {
          rooms[pairedIndex].pairedWith = null;
        }
        room.pairedWith = null;
      }
    });
  }
}
