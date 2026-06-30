import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

// ============================================================
// إعدادات Firebase والتطبيق
// ============================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تفعيل الكاش المحلي لـ Firestore (مهم جداً للسرعة)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCFNad5ADOdWKfWJf6UfwaGb4s17sjcjDs",
      appId: "1:915069495500:android:80f6a8ebc128e249e77a69",
      messagingSenderId: "915069495500",
      projectId: "tarweeqa-erp",
    ),
  );
  
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const RootApp());
}

// ============================================================
// دوال مساعدة
// ============================================================
String storeIdFromPassword(String password) {
  final bytes = utf8.encode(password.trim());
  final digest = sha256.convert(bytes);
  return digest.toString().substring(0, 24);
}

String generateInvoiceNumber() {
  final now = DateTime.now();
  final day = now.day.toString().padLeft(2, '0');
  final month = now.month.toString().padLeft(2, '0');
  final year = now.year.toString().substring(2);
  final random = Random().nextInt(9999).toString().padLeft(4, '0');
  return "$day$month$year-$random";
}

String formatCurrency(double amount) {
  if (amount >= 1000000) {
    return "${(amount / 1000000).toStringAsFixed(1)}M";
  } else if (amount >= 1000) {
    return "${(amount / 1000).toStringAsFixed(1)}K";
  }
  return amount.toStringAsFixed(0);
}

// ============================================================
// الجذر مع دعم Dark Mode
// ============================================================
class RootApp extends StatefulWidget {
  const RootApp({super.key});
  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  bool darkMode = false;
  bool showSplash = true;

  @override
  void initState() {
    super.initState();
    loadTheme();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => showSplash = false);
    });
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => darkMode = prefs.getBool('darkMode') ?? false);
  }

  Future<void> setDarkMode(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', v);
    setState(() => darkMode = v);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ترويقة ERP",
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6FAFD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          primary: const Color(0xFF1565C0),
          secondary: const Color(0xFF64B5F6),
          surface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
      ),
      home: showSplash ? const CustomSplashScreen() : const MainApp(),
    );
  }
}

// ============================================================
// شاشة البداية (Splash Screen) - بتصميم مخصص من صورتك
// ============================================================
class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});
  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _scale = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.8, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.6, 1.0, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // رسومات زخرفية (محاكاة للمنتجات في الصورة)
            Positioned(
              top: 60,
              left: 20,
              child: ScaleTransition(
                scale: _scale,
                child: const Icon(Icons.local_drink, size: 70, color: Color(0xFF1976D2)),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: ScaleTransition(
                scale: _scale,
                child: const Icon(Icons.egg, size: 60, color: Color(0xFFF5B041)),
              ),
            ),
            Positioned(
              bottom: 120,
              left: 20,
              child: ScaleTransition(
                scale: _scale,
                child: const Icon(Icons.local_florist, size: 65, color: Color(0xFF2E7D32)),
              ),
            ),
            Positioned(
              bottom: 140,
              right: 20,
              child: ScaleTransition(
                scale: _scale,
                child: const Icon(Icons.icecream, size: 55, color: Color(0xFFF39C12)),
              ),
            ),
            Positioned(
              top: 180,
              left: 40,
              child: ScaleTransition(
                scale: _scale,
                child: const Icon(Icons.park, size: 50, color: Color(0xFFF1C40F)),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 40,
              child: ScaleTransition(
                scale: _scale,
                child: const Icon(Icons.breakfast_dining, size: 50, color: Color(0xFFE67E22)),
              ),
            ),

            // الشعار المركزي
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                    border: Border.all(color: const Color(0xFF1976D2), width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "ترويقة",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1976D2),
                          fontFamily: 'Arial',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "أجبان وألبان",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "مواد غذائية وبهارات",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// التطبيق الرئيسي - الصفحات والتنقل
// ============================================================
class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  String employeeName = "موظف";
  String? storePassword;
  String? storeId;
  double dollarRate = 15000.0;
  
  // مخازن البيانات
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _lowStockProducts = [];
  List<Map<String, dynamic>> _employees = [];
  int _unreadNotifications = 0;
  List<Map<String, dynamic>> _notifications = [];
  double _totalInventoryValue = 0;
  int _totalProductsCount = 0;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _listenToActivities();
    _listenToLowStock();
    _listenToEmployees();
    _listenToNotifications();
    _loadInventoryStats();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeName = prefs.getString('empName') ?? "موظف";
      storePassword = prefs.getString('storePassword');
      storeId = (storePassword != null && storePassword!.isNotEmpty)
          ? storeIdFromPassword(storePassword!)
          : null;
    });
    if (storeId != null) {
      await _ensureStoreDoc();
      await _registerEmployee();
    }
  }

  Future<void> _ensureStoreDoc() async {
    if (storeId == null) return;
    final ref = FirebaseFirestore.instance.collection('stores').doc(storeId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({'dollarRate': 15000.0, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      final data = snap.data();
      if (data != null && data.containsKey('dollarRate')) {
        setState(() => dollarRate = (data['dollarRate'] as num).toDouble());
      }
    }
  }

  Future<void> _registerEmployee() async {
    if (storeId == null) return;
    await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('employees')
        .doc(employeeName)
        .set({
      'name': employeeName,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _listenToActivities() {
    if (storeId == null) return;
    FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('activity_log')
        .orderBy('time', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _recentActivities = snapshot.docs.map((doc) => doc.data()).toList();
      });
    });
  }

  void _listenToLowStock() {
    if (storeId == null) return;
    FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('groups')
        .snapshots()
        .listen((groupsSnapshot) {
      for (final groupDoc in groupsSnapshot.docs) {
        FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .collection('groups')
            .doc(groupDoc.id)
            .collection('products')
            .where('quantity', isLessThanOrEqualTo: 5)
            .where('quantity', isGreaterThan: 0)
            .snapshots()
            .listen((productsSnapshot) {
          setState(() {
            _lowStockProducts = productsSnapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              data['groupId'] = groupDoc.id;
              return data;
            }).toList();
          });
        });
      }
    });
  }

  void _listenToEmployees() {
    if (storeId == null) return;
    FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('employees')
        .orderBy('lastActive', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _employees = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    });
  }

  void _listenToNotifications() {
    if (storeId == null) return;
    FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _notifications = snapshot.docs.map((doc) => doc.data()).toList();
        _unreadNotifications = _notifications.where((n) => n['read'] == false).length;
      });
    });
  }

  Future<void> _loadInventoryStats() async {
    if (storeId == null) return;
    double totalValue = 0;
    int totalCount = 0;
    
    final groupsSnap = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('groups')
        .get();
    
    for (final groupDoc in groupsSnap.docs) {
      final productsSnap = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('groups')
          .doc(groupDoc.id)
          .collection('products')
          .get();
      
      totalCount += productsSnap.docs.length;
      for (final p in productsSnap.docs) {
        final data = p.data();
        totalValue += ((data['quantity'] as num?)?.toDouble() ?? 0) * ((data['price'] as num?)?.toDouble() ?? 0);
      }
    }
    
    setState(() {
      _totalInventoryValue = totalValue;
      _totalProductsCount = totalCount;
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showNotification(String title, String message, {Color color = Colors.blue, String type = 'info'}) {
    if (storeId == null) return;
    FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('notifications')
        .add({
      'title': title,
      'message': message,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _markNotificationsAsRead() {
    if (storeId == null) return;
    for (final n in _notifications.where((n) => n['read'] == false)) {
      FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('notifications')
          .doc(n['id'] ?? '')
          .update({'read': true});
    }
  }

  // ============================================================
  // الصفحة 1: Dashboard
  // ============================================================
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("مرحباً $employeeName 👋", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(DateFormat('yyyy/MM/dd - HH:mm').format(DateTime.now()), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text("اليوم", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard("المبيعات", "0 \$", Icons.monetization_on, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("الديون", "0 \$", Icons.credit_card, Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard("المنتجات", "${_totalProductsCount}", Icons.inventory_2, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("القيمة", "${formatCurrency(_totalInventoryValue)} \$", Icons.attach_money, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),

          if (_lowStockProducts.isNotEmpty) ...[
            const Text("⚠️ تنبيهات المخزون", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 12),
            ..._lowStockProducts.map((product) => Card(
              color: Colors.red.withOpacity(0.1),
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text("${product['name']} - باقي ${product['quantity']} فقط", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("الوحدة: ${product['unit'] ?? 'كيلو'}"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {},
                  child: const Text("تزويد", style: TextStyle(color: Colors.white)),
                ),
              ),
            )).toList(),
            const SizedBox(height: 24),
          ],

          const Text("آخر العمليات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_recentActivities.isEmpty)
            const Center(child: Text("لا توجد عمليات حديثة", style: TextStyle(color: Colors.grey)))
          else
            ..._recentActivities.map((activity) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: activity['type'] == 'sale' 
                  ? const Icon(Icons.shopping_cart, color: Colors.green)
                  : activity['type'] == 'payment'
                  ? const Icon(Icons.money, color: Colors.green)
                  : const Icon(Icons.info, color: Colors.blue),
                title: Text(activity['text'] ?? 'عملية جديدة'),
                subtitle: Text("بواسطة ${activity['by'] ?? 'غير معروف'} • ${activity['time'] != null ? DateFormat('HH:mm').format((activity['time'] as Timestamp).toDate()) : 'الآن'}"),
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الصفحة 2: الأقسام (مع Drag & Drop و بحث)
  // ============================================================
  String _groupsSearchQuery = "";
  List<Map<String, dynamic>> _groups = [];
  bool _isLoadingGroups = true;

  Widget _buildGroupsView() {
    if (storeId == null) return _notLinkedView();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.category, color: Colors.blue),
              const SizedBox(width: 10),
              const Text("الأقسام", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              FloatingActionButton(
                mini: true,
                onPressed: _showAddGroupDialog,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "ابحث عن قسم...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: _groupsSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _groupsSearchQuery = "");
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _groupsSearchQuery = v.trim().toLowerCase()),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stores')
                .doc(storeId)
                .collection('groups')
                .orderBy('order')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final groups = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              }).toList();
              
              _groups = groups;
              _isLoadingGroups = false;
              
              final filtered = groups.where((g) => (g['name'] as String).toLowerCase().contains(_groupsSearchQuery)).toList();
              
              if (filtered.isEmpty) {
                return const Center(child: Text("لا توجد أقسام"));
              }
              return ReorderableListView(
                padding: const EdgeInsets.all(16),
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = filtered.removeAt(oldIndex);
                  filtered.insert(newIndex, item);
                  // تحديث الترتيب في Firebase
                  for (int i = 0; i < filtered.length; i++) {
                    FirebaseFirestore.instance
                        .collection('stores')
                        .doc(storeId)
                        .collection('groups')
                        .doc(filtered[i]['id'])
                        .update({'order': i});
                  }
                },
                children: filtered.map((data) {
                  return ReorderableDragStartListener(
                    key: Key(data['id']),
                    index: filtered.indexOf(data),
                    child: _buildGroupCard(data['id'], data),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(String id, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        // فتح منتجات هذا القسم
        _showProductsView(id, data['name'] ?? 'قسم');
      },
      onLongPress: () {
        _showGroupActionsDialog(id, data);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Color(data['color'] ?? Colors.blue.value),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.category, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? "قسم",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        "عدد المنتجات: ${data['productCount'] ?? 0}",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.drag_handle, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGroupActionsDialog(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("خيارات القسم: ${data['name']}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              _showEditGroupDialog(id, data['name']);
            },
            child: const Text("تعديل الاسم"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(c);
              _showDeleteGroupDialog(id, data['name']);
            },
            child: const Text("حذف"),
          ),
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
        ],
      ),
    );
  }

  void _showAddGroupDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("قسم جديد"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "اسم القسم (مثال: ألبان، مكسرات)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty && storeId != null) {
                await FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .collection('groups')
                    .add({
                      'name': ctrl.text.trim(),
                      'color': _randomColor(),
                      'order': DateTime.now().millisecondsSinceEpoch,
                      'productCount': 0,
                    });
                Navigator.pop(c);
                _showNotification("تم الإضافة", "تم إنشاء قسم جديد بنجاح", color: Colors.green);
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  int _randomColor() {
    final colors = [0xFF1976D2, 0xFF388E3C, 0xFFF57C00, 0xFF8E24AA, 0xFF00838F, 0xFFC62828, 0xFF4CAF50, 0xFFFFA000];
    return colors[Random().nextInt(colors.length)];
  }

  void _showEditGroupDialog(String id, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("تعديل اسم القسم"),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: "اسم القسم الجديد")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty && storeId != null) {
                await FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .collection('groups')
                    .doc(id)
                    .update({'name': ctrl.text.trim()});
                Navigator.pop(c);
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("حذف القسم"),
        content: Text("هل أنت متأكد من حذف قسم \"$name\"؟ سيتم حذف كل منتجاته أيضاً."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (storeId == null) return;
              final productsSnap = await FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('groups')
                  .doc(id)
                  .collection('products')
                  .get();
              
              final batch = FirebaseFirestore.instance.batch();
              for (final p in productsSnap.docs) {
                batch.delete(p.reference);
              }
              batch.delete(FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('groups')
                  .doc(id));
              await batch.commit();
              
              if (mounted) Navigator.pop(c);
              _showNotification("تم الحذف", "تم حذف القسم وجميع منتجاته", color: Colors.red);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // عرض منتجات القسم
  // ============================================================
  void _showProductsView(String groupId, String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsPage(
          storeId: storeId!,
          groupId: groupId,
          groupName: groupName,
          employeeName: employeeName,
          dollarRate: dollarRate,
          onActivity: _showNotification,
        ),
      ),
    );
  }

  // ============================================================
  // الصفحة 3: الفواتير
  // ============================================================
  String _invoicesSearchQuery = "";
  String _invoicesFilter = "all"; // all, today, week, month

  Widget _buildInvoicesView() {
    if (storeId == null) return _notLinkedView();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.receipt, color: Colors.blue),
              const SizedBox(width: 10),
              const Text("الفواتير", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              FloatingActionButton(
                mini: true,
                onPressed: () {
                  _showNewInvoiceDialog();
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "ابحث عن فاتورة...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) => setState(() => _invoicesSearchQuery = v.trim().toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _invoicesFilter,
                items: const [
                  DropdownMenuItem(value: "all", child: Text("الكل")),
                  DropdownMenuItem(value: "today", child: Text("اليوم")),
                  DropdownMenuItem(value: "week", child: Text("الأسبوع")),
                  DropdownMenuItem(value: "month", child: Text("الشهر")),
                ],
                onChanged: (v) => setState(() => _invoicesFilter = v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stores')
                .doc(storeId)
                .collection('invoices')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              var invoices = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['customer'] ?? '').toLowerCase();
                final number = (data['number'] ?? '').toLowerCase();
                final createdAt = data['createdAt'] as Timestamp?;
                
                // فلترة البحث
                if (!name.contains(_invoicesSearchQuery) && !number.contains(_invoicesSearchQuery)) return false;
                
                // فلترة التاريخ
                if (_invoicesFilter != "all" && createdAt != null) {
                  final date = createdAt.toDate();
                  final now = DateTime.now();
                  if (_invoicesFilter == "today") {
                    return DateFormat('yyyyMMdd').format(date) == DateFormat('yyyyMMdd').format(now);
                  } else if (_invoicesFilter == "week") {
                    final weekStart = now.subtract(Duration(days: now.weekday - 1));
                    return date.isAfter(weekStart);
                  } else if (_invoicesFilter == "month") {
                    return date.month == now.month && date.year == now.year;
                  }
                }
                return true;
              }).toList();
              
              if (invoices.isEmpty) {
                return const Center(child: Text("لا توجد فواتير مطابقة"));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final doc = invoices[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildInvoiceCard(doc.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(String id, Map<String, dynamic> data) {
    final total = (data['total'] as num?)?.toDouble() ?? 0;
    final paid = (data['paid'] as num?)?.toDouble() ?? 0;
    final remaining = total - paid;
    final status = data['status'] ?? 'pending';
    final isPaid = status == 'paid';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showEditInvoiceDialog(id, data);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isPaid ? Icons.check_circle : Icons.pending, 
                           color: isPaid ? Colors.green : Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        "فاتورة #${data['number'] ?? id.substring(0, 8)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPaid ? "مدفوعة" : "دين",
                      style: TextStyle(
                        color: isPaid ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("العميل: ${data['customer'] ?? 'غير محدد'}", style: TextStyle(color: Colors.grey[700])),
              Text("البائع: ${data['seller'] ?? 'غير محدد'}", style: TextStyle(color: Colors.grey[700])),
              if (data['createdAt'] != null)
                Text("التاريخ: ${DateFormat('yyyy/MM/dd HH:mm').format((data['createdAt'] as Timestamp).toDate())}", 
                     style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("الإجمالي", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("$total \$", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("المدفوع", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("$paid \$", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("الباقي", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("$remaining \$", style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: remaining > 0 ? Colors.red : Colors.green
                      )),
                    ],
                  ),
                ],
              ),
              if (!isPaid && remaining > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showPaymentDialog(id, data, remaining);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("تسديد الدين", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showEditInvoiceDialog(id, data);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("تعديل", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // إنشاء فاتورة جديدة
  // ============================================================
  void _showNewInvoiceDialog() {
    final customerCtrl = TextEditingController();
    List<Map<String, dynamic>> cart = [];
    double total = 0;
    String currency = "USD";
    
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text("فاتورة جديدة"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: customerCtrl,
                    decoration: const InputDecoration(labelText: "اسم العميل"),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("العملة: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: currency,
                        items: const [
                          DropdownMenuItem(value: "USD", child: Text("دولار")),
                          DropdownMenuItem(value: "LBP", child: Text("ليرة لبنانية")),
                        ],
                        onChanged: (v) => setD(() => currency = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("المنتجات:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddProductToCartDialog(cart, () {
                          setD(() {
                            total = cart.fold(0, (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as num)));
                          });
                        });
                      },
                      child: const Text("+ إضافة منتج"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...cart.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item['name'] ?? 'منتج'),
                        subtitle: Text("${item['quantity']} ${item['unit']} × ${item['price']} $currency"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () {
                                _showEditCartItemDialog(item, index, cart, () {
                                  setD(() {
                                    total = cart.fold(0, (sum, i) => sum + ((i['price'] as num) * (i['quantity'] as num)));
                                  });
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                              onPressed: () {
                                setD(() {
                                  cart.removeAt(index);
                                  total = cart.fold(0, (sum, i) => sum + ((i['price'] as num) * (i['quantity'] as num)));
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("الإجمالي:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("$total $currency", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () async {
                if (storeId == null) return;
                if (cart.isEmpty) {
                  _showNotification("خطأ", "يجب إضافة منتجات للفاتورة", color: Colors.red);
                  return;
                }
                
                final invoiceNumber = generateInvoiceNumber();
                final invoiceData = {
                  'number': invoiceNumber,
                  'customer': customerCtrl.text.trim().isEmpty ? "غير محدد" : customerCtrl.text.trim(),
                  'seller': employeeName,
                  'total': total,
                  'paid': 0,
                  'remaining': total,
                  'status': 'debt',
                  'items': cart,
                  'currency': currency,
                  'createdAt': FieldValue.serverTimestamp(),
                };
                
                await FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .collection('invoices')
                    .add(invoiceData);
                
                // تنقيص المخزون
                for (final item in cart) {
                  await _deductStock(item['productId'], item['quantity']);
                }
                
                // تسجيل النشاط
                await FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .collection('activity_log')
                    .add({
                  'text': "فاتورة جديدة #$invoiceNumber للعميل ${customerCtrl.text.trim()} بقيمة $total $currency",
                  'time': FieldValue.serverTimestamp(),
                  'by': employeeName,
                  'type': 'sale',
                });
                
                _showNotification("تم الإنشاء", "فاتورة #$invoiceNumber تم إنشاؤها بنجاح", color: Colors.green);
                Navigator.pop(c);
              },
              child: const Text("إنشاء الفاتورة"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductToCartDialog(List<Map<String, dynamic>> cart, VoidCallback onUpdate) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: "1");
    String unit = "كيلو";
    String saleMethod = "quantity";
    double customPrice = 0;
    
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text("إضافة منتج للفاتورة"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "اسم المنتج")),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: saleMethod,
                  items: const [
                    DropdownMenuItem(value: "quantity", child: Text("بيع بالكمية (كيلو/غرام)")),
                    DropdownMenuItem(value: "custom", child: Text("بيع بسعر مباشر")),
                  ],
                  onChanged: (v) => setD(() => saleMethod = v!),
                  decoration: const InputDecoration(labelText: "طريقة البيع"),
                ),
                const SizedBox(height: 8),
                if (saleMethod == "quantity") ...[
                  TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "الكمية")),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: unit,
                    items: const [
                      DropdownMenuItem(value: "كيلو", child: Text("كيلو")),
                      DropdownMenuItem(value: "غرام", child: Text("غرام")),
                      DropdownMenuItem(value: "قطعة", child: Text("قطعة")),
                    ],
                    onChanged: (v) => setD(() => unit = v!),
                    decoration: const InputDecoration(labelText: "الوحدة"),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "السعر ($)")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1;
                
                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("الرجاء إدخال اسم وسعر صحيح")));
                  return;
                }
                
                cart.add({
                  'name': name,
                  'price': price,
                  'quantity': qty,
                  'unit': unit,
                  'method': saleMethod,
                });
                onUpdate();
                Navigator.pop(c);
              },
              child: const Text("إضافة"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCartItemDialog(Map<String, dynamic> item, int index, List<Map<String, dynamic>> cart, VoidCallback onUpdate) {
    final priceCtrl = TextEditingController(text: item['price'].toString());
    final qtyCtrl = TextEditingController(text: item['quantity'].toString());
    String unit = item['unit'] ?? 'كيلو';
    
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text("تعديل: ${item['name']}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "السعر الجديد")),
                const SizedBox(height: 8),
                TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "الكمية الجديدة")),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: unit,
                  items: const [
                    DropdownMenuItem(value: "كيلو", child: Text("كيلو")),
                    DropdownMenuItem(value: "غرام", child: Text("غرام")),
                    DropdownMenuItem(value: "قطعة", child: Text("قطعة")),
                  ],
                  onChanged: (v) => setD(() => unit = v!),
                  decoration: const InputDecoration(labelText: "الوحدة"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () {
                final price = double.tryParse(priceCtrl.text.trim()) ?? item['price'];
                final qty = double.tryParse(qtyCtrl.text.trim()) ?? item['quantity'];
                
                cart[index] = {
                  ...item,
                  'price': price,
                  'quantity': qty,
                  'unit': unit,
                };
                onUpdate();
                Navigator.pop(c);
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deductStock(String productId, double quantity) async {
    if (storeId == null) return;
    // البحث عن المنتج في جميع الأقسام
    final groupsSnap = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('groups')
        .get();
    
    for (final groupDoc in groupsSnap.docs) {
      final productRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('groups')
          .doc(groupDoc.id)
          .collection('products')
          .doc(productId);
      
      final snap = await productRef.get();
      if (snap.exists) {
        final currentQty = (snap.data()?['quantity'] as num?)?.toDouble() ?? 0;
        await productRef.update({'quantity': currentQty - quantity});
        return;
      }
    }
  }

  // ============================================================
  // تعديل فاتورة موجودة
  // ============================================================
  void _showEditInvoiceDialog(String id, Map<String, dynamic> data) {
    final customerCtrl = TextEditingController(text: data['customer'] ?? '');
    List<Map<String, dynamic>> items = List.from(data['items'] ?? []);
    double total = items.fold(0, (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as num)));
    double paid = (data['paid'] as num?)?.toDouble() ?? 0;
    
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text("تعديل فاتورة #${data['number']}"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: customerCtrl, decoration: const InputDecoration(labelText: "اسم العميل")),
                  const SizedBox(height: 12),
                  const Text("المنتجات:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        title: Text(item['name'] ?? 'منتج'),
                        subtitle: Text("${item['quantity']} ${item['unit']} × ${item['price']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setD(() {
                              items.removeAt(index);
                              total = items.fold(0, (sum, i) => sum + ((i['price'] as num) * (i['quantity'] as num)));
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _showAddProductToCartDialog(items, () {
                          setD(() {
                            total = items.fold(0, (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as num)));
                          });
                        });
                      },
                      child: const Text("+ إضافة منتج"),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("الإجمالي الجديد:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("$total \$", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  if (total > paid)
                    Text("⚠️ الإجمالي أكبر من المدفوع ($paid \$). سيصبح ديناً.", 
                         style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () async {
                if (storeId == null) return;
                final newRemaining = total - paid;
                final status = newRemaining <= 0 ? 'paid' : 'debt';
                
                // تحديث الفاتورة
                await FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .collection('invoices')
                    .doc(id)
                    .update({
                  'customer': customerCtrl.text.trim().isEmpty ? "غير محدد" : customerCtrl.text.trim(),
                  'items': items,
                  'total': total,
                  'remaining': newRemaining,
                  'status': status,
                });
                
                // تحديث المخزون (تنقيص/إرجاع)
                final oldItems = data['items'] as List? ?? [];
                for (final oldItem in oldItems) {
                  await _deductStock(oldItem['productId'], -oldItem['quantity']); // إرجاع
                }
                for (final newItem in items) {
                  await _deductStock(newItem['productId'], newItem['quantity']); // خصم جديد
                }
                
                Navigator.pop(c);
                _showNotification("تم التعديل", "تم تحديث الفاتورة بنجاح", color: Colors.green);
              },
              child: const Text("حفظ التعديلات"),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // تسديد الدين
  // ============================================================
  void _showPaymentDialog(String invoiceId, Map<String, dynamic> data, double remaining) {
    final amountCtrl = TextEditingController(text: remaining.toString());
    
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("تسديد الدين"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("المتبقي: $remaining \$", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "المبلغ المدفوع"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text.trim());
              if (amount == null || amount <= 0) {
                _showNotification("خطأ", "أدخل مبلغ صحيح", color: Colors.red);
                return;
              }
              
              if (amount > remaining) {
                _showNotification("خطأ", "المبلغ المدفوع أكبر من المتبقي ($remaining \$)", color: Colors.red);
                return;
              }
              
              if (storeId == null) return;
              final newRemaining = remaining - amount;
              final isPaid = newRemaining <= 0;
              
              await FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('invoices')
                  .doc(invoiceId)
                  .update({
                'paid': FieldValue.increment(amount),
                'remaining': newRemaining,
                'status': isPaid ? 'paid' : 'debt',
                if (isPaid) 'paidAt': FieldValue.serverTimestamp(),
              });
              
              // تسجيل النشاط
              await FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('activity_log')
                  .add({
                'text': "تسديد دين بقيمة $amount \$ للفاتورة #${data['number']}",
                'time': FieldValue.serverTimestamp(),
                'by': employeeName,
                'type': 'payment',
              });
              
              _showNotification("تم التسديد", "تم تسجيل المبلغ بنجاح", color: Colors.green);
              Navigator.pop(c);
            },
            child: const Text("تسديد", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // الصفحة 4: الإعدادات (المطورة بالكامل)
  // ============================================================
  bool _isUpdating = false;
  final TextEditingController _dollarCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  Widget _buildSettingsView() {
    _dollarCtrl.text = dollarRate.toString();
    _nameCtrl.text = employeeName;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("الإعدادات", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(_isConnected ? Icons.wifi : Icons.wifi_off, 
                         size: 14, color: _isConnected ? Colors.green : Colors.red),
                    const SizedBox(width: 6),
                    Text(_isConnected ? "متصل" : "غير متصل", 
                         style: TextStyle(fontSize: 12, color: _isConnected ? Colors.green : Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // المتجر
          _buildSettingsCard("المتجر", [
            _buildSettingTile("كلمة سر المتجر", storePassword ?? "غير محدد", Icons.lock, () {
              _showPasswordChangeDialog();
            }),
            _buildSettingTile("عدد الموظفين", "${_employees.length}", Icons.people, null),
            if (_employees.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("الموظفون المتصلون:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    ..._employees.map((e) {
                      final lastActive = e['lastActive'] as Timestamp?;
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.person, color: Colors.green, size: 20),
                        title: Text(e['name'] ?? 'موظف', style: const TextStyle(fontSize: 14)),
                        subtitle: Text(
                          lastActive != null 
                            ? "آخر نشاط: ${DateFormat('yyyy/MM/dd HH:mm').format(lastActive.toDate())}"
                            : "غير متصل",
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            _buildSettingTile("سعر الدولار", "$dollarRate ل.س", Icons.attach_money, () {
              _showDollarRateDialog();
            }),
          ]),
          
          const SizedBox(height: 16),
          
          // الموظف
          _buildSettingsCard("الموظف", [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text("اسم الموظف"),
              subtitle: Text(employeeName, style: TextStyle(color: Colors.grey[600])),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "تعديل الاسم",
                  suffixIcon: Icon(Icons.save, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (v) async {
                  final name = v.trim();
                  if (name.isNotEmpty && name != employeeName) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('empName', name);
                    setState(() => employeeName = name);
                    if (storeId != null) await _registerEmployee();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ تم حفظ الاسم")));
                  }
                },
              ),
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // عام
          _buildSettingsCard("عام", [
            SwitchListTile(
              title: const Text("الوضع الليلي"),
              value: (context as Element).findAncestorWidgetOfExactType<RootApp>()?.darkMode ?? false,
              onChanged: (v) {
                (context as Element).findAncestorStateOfType<_RootAppState>()?.setDarkMode(v);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text("حول التطبيق"),
              subtitle: const Text("ترويقة ERP - الإصدار 1.0.0"),
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 20),
          if (storeId != null)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.link_off),
                label: const Text("إلغاء الربط بالمتجر", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c2) => AlertDialog(
                      title: const Text("تأكيد إلغاء الربط"),
                      content: const Text("هل أنت متأكد من إلغاء الربط بالمتجر؟ ستحتاج كلمة السر للرجوع مجدداً."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c2, false), child: const Text("إلغاء")),
                        ElevatedButton(onPressed: () => Navigator.pop(c2, true), child: const Text("تأكيد")),
                      ],
                    ),
                  );
                  if (ok == true) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('storePassword');
                    setState(() {
                      storePassword = null;
                      storeId = null;
                    });
                    _showNotification("تم الإلغاء", "تم إلغاء الربط بنجاح", color: Colors.orange);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String label, String value, IconData icon, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      subtitle: Text(value, style: TextStyle(color: Colors.grey[600])),
      onTap: onTap,
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
    );
  }

  // ============================================================
  // إعدادات - تغيير كلمة السر
  // ============================================================
  void _showPasswordChangeDialog() {
    final ctrl = TextEditingController(text: storePassword ?? "");
    bool obscure = true;
    
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text("تغيير كلمة سر المتجر"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ctrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: "كلمة السر الجديدة",
                  hintText: "اتركها فاضية لإلغاء الربط",
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setD(() => obscure = !obscure),
                  ),
                ),
              ),
              if (ctrl.text.trim().isNotEmpty && ctrl.text.trim().length < 4)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "⚠️ كلمة السر ضعيفة، يُفضل كلمة أقوى (4 أحرف على الأقل)",
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () async {
                final newPass = ctrl.text.trim();
                final oldPass = storePassword ?? "";
                final passwordChanged = newPass != oldPass;
                
                Future<void> applyChanges() async {
                  storePassword = newPass.isEmpty ? null : newPass;
                  storeId = storePassword != null ? storeIdFromPassword(storePassword!) : null;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('storePassword', newPass);
                  if (storeId != null) {
                    await _ensureStoreDoc();
                    await _registerEmployee();
                  }
                  setState(() {});
                  Navigator.pop(c);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ تم الحفظ")));
                }
                
                if (passwordChanged && oldPass.isNotEmpty) {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c2) => AlertDialog(
                      title: const Text("تأكيد تغيير كلمة السر"),
                      content: const Text("تغيير كلمة السر سيفصلك عن المتجر الحالي ويربطك بمتجر جديد. متابعة؟"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c2, false), child: const Text("إلغاء")),
                        ElevatedButton(onPressed: () => Navigator.pop(c2, true), child: const Text("تأكيد")),
                      ],
                    ),
                  );
                  if (ok == true) await applyChanges();
                } else {
                  await applyChanges();
                }
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // إعدادات - تغيير سعر الدولار (يتزامن لحظياً)
  // ============================================================
  void _showDollarRateDialog() {
    final ctrl = TextEditingController(text: dollarRate.toString());
    
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("تغيير سعر الدولار"),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "سعر الدولار بالليرة"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              final rate = double.tryParse(ctrl.text.trim());
              if (rate == null || rate <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("أدخل سعراً صحيحاً")));
                return;
              }
              if (storeId != null) {
                await FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .update({'dollarRate': rate});
                setState(() => dollarRate = rate);
                // تحديث لجميع الموظفين عبر Stream
              }
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ تم تحديث السعر إلى $rate")));
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // شاشة عدم الربط
  // ============================================================
  Widget _notLinkedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, size: 80, color: Colors.blue[200]),
            const SizedBox(height: 20),
            const Text(
              "لم يتم ربط التطبيق بمتجر بعد",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "أدخل كلمة السر في الإعدادات للبدء",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              onPressed: () {
                setState(() => _selectedIndex = 3);
              },
              label: const Text("فتح الإعدادات"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الـ Build الرئيسي
  // ============================================================
  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("ترويقة ERP"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                setState(() => _selectedIndex = 3);
              },
            ),
          ],
        ),
        body: _notLinkedView(),
      );
    }

    final pages = [
      _buildDashboard(),
      _buildGroupsView(),
      _buildInvoicesView(),
      _buildSettingsView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ترويقة ERP"),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  _showNotificationsDialog();
                  _markNotificationsAsRead();
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "الأقسام"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "الفواتير"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }

  // ============================================================
  // نافذة الإشعارات
  // ============================================================
  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("الإشعارات"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _notifications.isEmpty
              ? const Center(child: Text("لا توجد إشعارات"))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    final isRead = n['read'] == true;
                    return ListTile(
                      leading: Icon(
                        n['type'] == 'sale' ? Icons.shopping_cart :
                        n['type'] == 'payment' ? Icons.money :
                        n['type'] == 'warning' ? Icons.warning : Icons.info,
                        color: n['type'] == 'sale' ? Colors.green :
                               n['type'] == 'payment' ? Colors.blue :
                               n['type'] == 'warning' ? Colors.orange : Colors.grey,
                      ),
                      title: Text(n['title'] ?? 'إشعار', style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(n['message'] ?? ''),
                      tileColor: isRead ? null : Colors.blue.withOpacity(0.05),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إغلاق")),
        ],
      ),
    );
  }
}

// ============================================================
// صفحة منتجات القسم (ProductsPage)
// ============================================================
class ProductsPage extends StatefulWidget {
  final String storeId;
  final String groupId;
  final String groupName;
  final String employeeName;
  final double dollarRate;
  final Function(String, String, {Color color, String type}) onActivity;

  const ProductsPage({
    super.key,
    required this.storeId,
    required this.groupId,
    required this.groupName,
    required this.employeeName,
    required this.dollarRate,
    required this.onActivity,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";
  String _sortBy = "name"; // name, quantity, price, date
  bool _sortAscending = true;

  void _logActivity(String text) {
    FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.storeId)
        .collection('activity_log')
        .add({
      'text': text,
      'time': FieldValue.serverTimestamp(),
      'by': widget.employeeName,
      'type': 'product',
    });
    widget.onActivity("نشاط منتج", text, color: Colors.blue, type: 'info');
  }

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    String unit = "كيلو";
    String currency = "USD";

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text("إضافة منتج جديد"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "اسم المنتج")),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "السعر")),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: currency,
                      items: const [
                        DropdownMenuItem(value: "USD", child: Text("\$")),
                        DropdownMenuItem(value: "LBP", child: Text("ل.ل")),
                      ],
                      onChanged: (v) => setD(() => currency = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: quantityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "الكمية")),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: unit,
                      items: const [
                        DropdownMenuItem(value: "كيلو", child: Text("كيلو")),
                        DropdownMenuItem(value: "غرام", child: Text("غرام")),
                        DropdownMenuItem(value: "قطعة", child: Text("قطعة")),
                      ],
                      onChanged: (v) => setD(() => unit = v!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final priceInput = double.tryParse(priceCtrl.text.trim()) ?? 0;
                final quantity = double.tryParse(quantityCtrl.text.trim()) ?? 0;

                if (name.isEmpty || priceInput <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("اسم المنتج والسعر مطلوبان")));
                  return;
                }

                // تحويل السعر إلى دولار
                final priceInUSD = currency == "USD" ? priceInput : priceInput / widget.dollarRate;

                await FirebaseFirestore.instance
                    .collection('stores')
                    .doc(widget.storeId)
                    .collection('groups')
                    .doc(widget.groupId)
                    .collection('products')
                    .add({
                  'name': name,
                  'priceUSD': priceInUSD,
                  'priceLBP': priceInUSD * widget.dollarRate,
                  'quantity': quantity,
                  'unit': unit,
                  'currency': currency,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                // تحديث عدد المنتجات في القسم
                final groupRef = FirebaseFirestore.instance
                    .collection('stores')
                    .doc(widget.storeId)
                    .collection('groups')
                    .doc(widget.groupId);
                final snap = await groupRef.get();
                final currentCount = (snap.data()?['productCount'] as int?) ?? 0;
                await groupRef.update({'productCount': currentCount + 1});

                _logActivity("أضاف منتج: $name");
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ تم إضافة $name")));
              },
              child: const Text("إضافة"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(String id, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    final priceCtrl = TextEditingController(text: data['priceUSD'].toString());
    final quantityCtrl = TextEditingController(text: data['quantity'].toString());
    String unit = data['unit'] ?? 'كيلو';

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text("تعديل المنتج"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "اسم المنتج")),
                const SizedBox(height: 8),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "السعر (\$)")),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: quantityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "الكمية")),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: unit,
                      items: const [
                        DropdownMenuItem(value: "كيلو", child: Text("كيلو")),
                        DropdownMenuItem(value: "غرام", child: Text("غرام")),
                        DropdownMenuItem(value: "قطعة", child: Text("قطعة")),
                      ],
                      onChanged: (v) => setD(() => unit = v!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                final quantity = double.tryParse(quantityCtrl.text.trim()) ?? 0;

                await FirebaseFirestore.instance
                    .collection('stores')
                    .doc(widget.storeId)
                    .collection('groups')
                    .doc(widget.groupId)
                    .collection('products')
                    .doc(id)
                    .update({
                  'name': name,
                  'priceUSD': price,
                  'priceLBP': price * widget.dollarRate,
                  'quantity': quantity,
                  'unit': unit,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                _logActivity("عدل منتج: $name");
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ تم تعديل $name")));
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteProductDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("حذف المنتج"),
        content: Text("هل أنت متأكد من حذف \"$name\"؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('stores')
                  .doc(widget.storeId)
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('products')
                  .doc(id)
                  .delete();
              
              // تحديث عدد المنتجات
              final groupRef = FirebaseFirestore.instance
                  .collection('stores')
                  .doc(widget.storeId)
                  .collection('groups')
                  .doc(widget.groupId);
              final snap = await groupRef.get();
              final currentCount = (snap.data()?['productCount'] as int?) ?? 0;
              await groupRef.update({'productCount': currentCount - 1});
              
              _logActivity("حذف منتج: $name");
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🗑️ تم حذف $name")));
            },
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text("ترتيب المنتجات"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text("بالاسم (أبجدي)"),
                        leading: Radio(value: "name", groupValue: _sortBy, onChanged: (v) {
                          setState(() => _sortBy = v as String);
                          Navigator.pop(c);
                        }),
                      ),
                      ListTile(
                        title: const Text("بالكمية"),
                        leading: Radio(value: "quantity", groupValue: _sortBy, onChanged: (v) {
                          setState(() => _sortBy = v as String);
                          Navigator.pop(c);
                        }),
                      ),
                      ListTile(
                        title: const Text("بالسعر"),
                        leading: Radio(value: "price", groupValue: _sortBy, onChanged: (v) {
                          setState(() => _sortBy = v as String);
                          Navigator.pop(c);
                        }),
                      ),
                      ListTile(
                        title: const Text("تاريخ الإضافة"),
                        leading: Radio(value: "date", groupValue: _sortBy, onChanged: (v) {
                          setState(() => _sortBy = v as String);
                          Navigator.pop(c);
                        }),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() => _sortAscending = !_sortAscending);
                        Navigator.pop(c);
                      },
                      child: Text(_sortAscending ? "ترتيب تصاعدي" : "ترتيب تنازلي"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "ابحث عن منتج...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchCtrl.clear();
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stores')
                  .doc(widget.storeId)
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var products = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();
                
                // الترتيب
                products.sort((a, b) {
                  final da = a.data() as Map<String, dynamic>;
                  final db = b.data() as Map<String, dynamic>;
                  int cmp = 0;
                  switch (_sortBy) {
                    case "name":
                      cmp = (da['name'] ?? '').compareTo(db['name'] ?? '');
                      break;
                    case "quantity":
                      cmp = ((da['quantity'] as num?)?.toDouble() ?? 0).compareTo((db['quantity'] as num?)?.toDouble() ?? 0);
                      break;
                    case "price":
                      cmp = ((da['priceUSD'] as num?)?.toDouble() ?? 0).compareTo((db['priceUSD'] as num?)?.toDouble() ?? 0);
                      break;
                    case "date":
                      final t1 = (da['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                      final t2 = (db['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                      cmp = t1.compareTo(t2);
                      break;
                  }
                  return _sortAscending ? cmp : -cmp;
                });
                
                if (products.isEmpty) {
                  return const Center(child: Text("لا توجد منتجات"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final doc = products[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildProductCard(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(String id, Map<String, dynamic> data) {
    final name = data['name'] ?? 'منتج';
    final priceUSD = (data['priceUSD'] as num?)?.toDouble() ?? 0;
    final priceLBP = (data['priceLBP'] as num?)?.toDouble() ?? 0;
    final quantity = (data['quantity'] as num?)?.toDouble() ?? 0;
    final unit = data['unit'] ?? 'كيلو';
    final updatedAt = data['updatedAt'] as Timestamp?;
    final createdAt = data['createdAt'] as Timestamp?;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showEditProductDialog(id, data);
        },
        onLongPress: () {
          _showDeleteProductDialog(id, name);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: quantity <= 5 ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  quantity <= 5 ? Icons.warning : Icons.inventory_2,
                  color: quantity <= 5 ? Colors.red : Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (quantity <= 5)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("ناقص", style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                      ],
                    ),
                    Text("السعر: \$${priceUSD.toStringAsFixed(2)} / $priceLBP ل.ل", style: TextStyle(color: Colors.grey[600])),
                    Text("المخزون: $quantity $unit", style: TextStyle(
                      color: quantity <= 5 ? Colors.red : Colors.grey[700],
                      fontWeight: quantity <= 5 ? FontWeight.bold : FontWeight.normal,
                    )),
                    if (updatedAt != null)
                      Text("آخر تحديث: ${DateFormat('yyyy/MM/dd HH:mm').format(updatedAt.toDate())}", 
                           style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
