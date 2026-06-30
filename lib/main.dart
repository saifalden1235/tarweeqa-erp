import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

const kPrimary = Color(0xFF1565C0);
const kPrimaryLight = Color(0xFF2196F3);
const kBg = Color(0xFFF0F4FF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCFNad5ADOdWKfWJf6UfwaGb4s17sjcjDs",
      appId: "1:915069495500:android:80f6a8ebc128e249e77a69",
      messagingSenderId: "915069495500",
      projectId: "tarweeqa-erp",
    ),
  );
  runApp(const MyApp());
}

String storeIdFromPassword(String password) {
  final bytes = utf8.encode(password.trim());
  final digest = sha256.convert(bytes);
  return digest.toString().substring(0, 24);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  void toggleTheme(bool dark) =>
      setState(() => _themeMode = dark ? ThemeMode.dark : ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ترويقة ERP",
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryLight,
          primary: kPrimaryLight,
          secondary: const Color(0xFF64B5F6),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryLight,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E2E),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6)));
    _scale = Tween<double>(begin: 0.7, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    });
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
            colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🧀", style: TextStyle(fontSize: 36)),
                      SizedBox(width: 12),
                      Text("🥛", style: TextStyle(fontSize: 36)),
                      SizedBox(width: 12),
                      Text("🫙", style: TextStyle(fontSize: 36)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Text(
                      "تَرْوِيقَة",
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "أجبان وألبان • مواد غذائية وبهارات",
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🫒", style: TextStyle(fontSize: 36)),
                      SizedBox(width: 12),
                      Text("🥚", style: TextStyle(fontSize: 36)),
                      SizedBox(width: 12),
                      Text("🌿", style: TextStyle(fontSize: 36)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String employeeName = "موظف";
  double dollarRate = 15000.0;
  String? storePassword;
  String? storeId;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeName = prefs.getString('empName') ?? "موظف";
      dollarRate = prefs.getDouble('dollarRate') ?? 15000.0;
      storePassword = prefs.getString('storePassword');
      storeId = (storePassword != null && storePassword!.isNotEmpty)
          ? storeIdFromPassword(storePassword!)
          : null;
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          employeeName: employeeName,
          dollarRate: dollarRate,
          storePassword: storePassword,
          storeId: storeId,
          darkMode: _darkMode,
          onSave: (name, rate, pass, dark) async {
            final prefs = await SharedPreferences.getInstance();
            setState(() {
              employeeName = name;
              dollarRate = rate;
              _darkMode = dark;
              storePassword = pass.isEmpty ? null : pass;
              storeId = storePassword != null ? storeIdFromPassword(storePassword!) : null;
            });
            await prefs.setString('empName', name);
            await prefs.setDouble('dollarRate', rate);
            await prefs.setBool('darkMode', dark);
            if (pass.isEmpty) {
              await prefs.remove('storePassword');
            } else {
              await prefs.setString('storePassword', pass);
            }
            MyApp.of(context)?.toggleTheme(dark);
          },
        ),
      ),
    );
  }

  void _addGroupDialog() {
    final ctrl = TextEditingController();
    Color selectedColor = const Color(0xFFE3F2FD);
    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFFFF9C4),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFEBEE),
      const Color(0xFFF3E5F5),
      const Color(0xFFE0F2F1),
    ];
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text("قسم جديد"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(labelText: "اسم القسم"),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("اختر لون القسم:", style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colors.map((color) => GestureDetector(
                  onTap: () => setD(() => selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color ? Colors.blue : Colors.grey.shade300,
                        width: selectedColor == color ? 3 : 1,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () async {
                if (ctrl.text.isNotEmpty && storeId != null) {
                  await FirebaseFirestore.instance
                      .collection('stores').doc(storeId).collection('groups')
                      .add({
                    'name': ctrl.text.trim(),
                    'color': selectedColor.value,
                    'order': DateTime.now().millisecondsSinceEpoch,
                  });
                  Navigator.pop(c);
                }
              },
              child: const Text("إضافة"),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupOptions(QueryDocumentSnapshot doc) {
    final nameCtrl = TextEditingController(text: doc['name']);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: kPrimaryLight),
              title: const Text("تعديل اسم القسم"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("تعديل القسم"),
                    content: TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "الاسم الجديد"),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
                      ElevatedButton(
                        onPressed: () async {
                          await doc.reference.update({'name': nameCtrl.text.trim()});
                          Navigator.pop(context);
                        },
                        child: const Text("حفظ"),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("حذف القسم", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("تأكيد الحذف"),
                    content: Text("هل تريد حذف قسم '${doc['name']}' وكل منتجاته؟"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          await doc.reference.delete();
                          Navigator.pop(context);
                        },
                        child: const Text("حذف"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("تَرْوِيقَة",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            const Text("| الأقسام", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings),
        ],
      ),
      body: storeId == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.link_off, size: 80, color: Colors.blue[200]),
                    const SizedBox(height: 16),
                    const Text("لم يتم ربط التطبيق بمتجر بعد",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text("اذهب إلى الإعدادات وأدخل كلمة سر المتجر",
                        style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings),
                      label: const Text("فتح الإعدادات"),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('stores').doc(storeId).snapshots(),
                  builder: (context, snap) {
                    double rate = dollarRate;
                    if (snap.hasData && snap.data!.exists) {
                      final data = snap.data!.data() as Map<String, dynamic>?;
                      if (data != null && data['dollarRate'] != null) {
                        rate = (data['dollarRate'] as num).toDouble();
                        if (rate != dollarRate) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() => dollarRate = rate);
                            SharedPreferences.getInstance().then((p) => p.setDouble('dollarRate', rate));
                          });
                        }
                      }
                    }
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: const Color(0xFFE3F2FD),
                      child: Text(
                        "👤 $employeeName   |   💵 ${NumberFormat("#,##0").format(rate)} ل.س",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                _NavRow(empName: employeeName, storeId: storeId!, currentDollar: dollarRate),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('stores').doc(storeId).collection('groups')
                        .orderBy('order').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final groups = snapshot.data!.docs;
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: groups.length + 1,
                        itemBuilder: (context, index) {
                          if (index == groups.length) {
                            return GestureDetector(
                              onTap: _addGroupDialog,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_circle_outline, size: 40, color: Colors.grey),
                                      SizedBox(height: 6),
                                      Text("قسم جديد", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          final doc = groups[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final color = data['color'] != null
                              ? Color(data['color'] as int)
                              : const Color(0xFFE3F2FD);
                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ProductsPage(
                                storeId: storeId!,
                                groupId: doc.id,
                                groupName: doc['name'],
                                empName: employeeName,
                                currentDollar: dollarRate,
                              ),
                            )),
                            onLongPress: () => _showGroupOptions(doc),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(doc['name'],
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kPrimary),
                                        textAlign: TextAlign.center),
                                  ),
                                  Positioned(
                                    top: 8, left: 8,
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('stores').doc(storeId)
                                          .collection('groups').doc(doc.id)
                                          .collection('products').snapshots(),
                                      builder: (_, snap) {
                                        final count = snap.hasData ? snap.data!.docs.length : 0;
                                        bool hasLow = false;
                                        if (snap.hasData) {
                                          for (var p in snap.data!.docs) {
                                            if ((p['qty'] ?? 0).toDouble() <= 3) { hasLow = true; break; }
                                          }
                                        }
                                        return Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: kPrimary.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text("$count منتج",
                                                  style: const TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.bold)),
                                            ),
                                            if (hasLow) ...[
                                              const SizedBox(width: 4),
                                              const CircleAvatar(radius: 5, backgroundColor: Colors.red),
                                            ]
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String empName, storeId;
  final double currentDollar;
  const _NavRow({required this.empName, required this.storeId, required this.currentDollar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          Expanded(child: _NavBtn(icon: Icons.point_of_sale, label: "فاتورة جديدة", color: kPrimaryLight,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => NewInvoicePage(storeId: storeId, empName: empName, currentDollar: currentDollar))))),
          const SizedBox(width: 8),
          Expanded(child: _NavBtn(icon: Icons.receipt_long, label: "الفواتير", color: const Color(0xFF2E7D32),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => InvoicesPage(storeId: storeId, debtOnly: false))))),
          const SizedBox(width: 8),
          Expanded(child: _NavBtn(icon: Icons.warning_amber_rounded, label: "الدين", color: Colors.red[700]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => InvoicesPage(storeId: storeId, debtOnly: true))))),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final String employeeName;
  final double dollarRate;
  final String? storePassword, storeId;
  final bool darkMode;
  final Function(String, double, String, bool) onSave;

  const SettingsPage({
    super.key,
    required this.employeeName,
    required this.dollarRate,
    required this.storePassword,
    required this.storeId,
    required this.darkMode,
    required this.onSave,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController nameCtrl, rateCtrl, passCtrl;
  bool _obscure = true, _darkMode = false, _connected = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.employeeName);
    rateCtrl = TextEditingController(text: widget.dollarRate.toStringAsFixed(0));
    passCtrl = TextEditingController(text: widget.storePassword ?? "");
    _darkMode = widget.darkMode;
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      await FirebaseFirestore.instance.collection('_ping').doc('ping').get()
          .timeout(const Duration(seconds: 3));
      if (mounted) setState(() => _connected = true);
    } catch (_) {
      if (mounted) setState(() => _connected = false);
    }
  }

  bool _isWeak(String p) => p.isNotEmpty && p.length < 6;

  void _autoSave() {
    final name = nameCtrl.text.trim().isEmpty ? "موظف" : nameCtrl.text.trim();
    final rate = double.tryParse(rateCtrl.text) ?? 15000.0;
    SharedPreferences.getInstance().then((p) {
      p.setString('empName', name);
      p.setDouble('dollarRate', rate);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم الحفظ التلقائي"), duration: Duration(seconds: 1)),
    );
  }

  void _save() {
    final oldPass = widget.storePassword ?? "";
    final newPass = passCtrl.text.trim();
    if (oldPass.isNotEmpty && newPass.isNotEmpty && oldPass != newPass) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("تحذير: تغيير كلمة السر"),
          content: const Text("تغيير كلمة السر سيفصلك عن المتجر الحالي. هل تريد المتابعة؟"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () { Navigator.pop(context); _doSave(); },
              child: const Text("متابعة"),
            ),
          ],
        ),
      );
    } else {
      _doSave();
    }
  }

  void _doSave() {
    final name = nameCtrl.text.trim().isEmpty ? "موظف" : nameCtrl.text.trim();
    final rate = double.tryParse(rateCtrl.text) ?? 15000.0;
    final pass = passCtrl.text.trim();
    widget.onSave(name, rate, pass, _darkMode);
    if (pass.isNotEmpty) {
      final sid = storeIdFromPassword(pass);
      FirebaseFirestore.instance.collection('stores').doc(sid)
          .set({'dollarRate': rate}, SetOptions(merge: true));
      FirebaseFirestore.instance.collection('stores').doc(sid)
          .collection('employees').doc(name)
          .set({'name': name, 'lastSeen': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تم الحفظ والربط بنجاح"), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  Future<void> _exportBackup() async {
    try {
      final sid = widget.storeId!;
      final Map<String, dynamic> backup = {};
      final groups = await FirebaseFirestore.instance
          .collection('stores').doc(sid).collection('groups').get();
      final groupsData = [];
      for (var g in groups.docs) {
        final products = await FirebaseFirestore.instance
            .collection('stores').doc(sid).collection('groups').doc(g.id).collection('products').get();
        groupsData.add({'id': g.id, 'name': g['name'], 'products': products.docs.map((p) => p.data()).toList()});
      }
      backup['groups'] = groupsData;
      final invoices = await FirebaseFirestore.instance
          .collection('stores').doc(sid).collection('invoices').get();
      backup['invoices'] = invoices.docs.map((i) => i.data()).toList();
      final json = jsonEncode(backup);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tarweeqa_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], text: 'نسخة احتياطية - ترويقة ERP');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("الإعدادات"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section("معلومات الموظف"),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "اسم الموظف"),
                    onSubmitted: (_) => _autoSave(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "سعر الدولار (ل.س)"),
                    onSubmitted: (_) => _autoSave(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section("ربط المتجر"),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 6, backgroundColor: _connected ? Colors.green : Colors.red),
                      const SizedBox(width: 8),
                      Text(_connected ? "متصل بـ Firestore" : "غير متصل",
                          style: TextStyle(color: _connected ? Colors.green : Colors.red, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("أي شخص يدخل نفس كلمة السر سيشارك نفس بيانات المتجر",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passCtrl,
                    obscureText: _obscure,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: "كلمة سر المتجر",
                      hintText: "اتركها فاضية لإلغاء الربط",
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      errorText: _isWeak(passCtrl.text) ? "كلمة السر ضعيفة (أقل من 6 أحرف)" : null,
                    ),
                  ),
                  if (widget.storeId != null) ...[
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('stores').doc(widget.storeId)
                          .collection('employees').orderBy('lastSeen', descending: true).snapshots(),
                      builder: (_, snap) {
                        if (!snap.hasData || snap.data!.docs.isEmpty) return const SizedBox();
                        final emps = snap.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people, size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text("الموظفون المرتبطون (${emps.length})",
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...emps.map((e) {
                              final data = e.data() as Map<String, dynamic>;
                              final lastSeen = data['lastSeen'] as Timestamp?;
                              String timeStr = "غير معروف";
                              if (lastSeen != null) {
                                final diff = DateTime.now().difference(lastSeen.toDate());
                                if (diff.inMinutes < 1) timeStr = "الآن";
                                else if (diff.inHours < 1) timeStr = "منذ ${diff.inMinutes} د";
                                else if (diff.inDays < 1) timeStr = "منذ ${diff.inHours} س";
                                else timeStr = "منذ ${diff.inDays} يوم";
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 10, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Text(data['name'] ?? "موظف",
                                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("تأكيد إلغاء الربط"),
                            content: const Text("هل تريد فصل هذا الجهاز عن المتجر الحالي؟"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () { passCtrl.text = ""; Navigator.pop(context); _doSave(); },
                                child: const Text("إلغاء الربط"),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.link_off),
                      label: const Text("إلغاء الربط بالمتجر"),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section("المظهر"),
          Card(
            child: SwitchListTile(
              title: const Text("الوضع الليلي 🌙"),
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
          ),
          if (widget.storeId != null) ...[
            const SizedBox(height: 16),
            _section("النسخ الاحتياطي (اختياري)"),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("تصدير كل بيانات المتجر كملف JSON وإرساله عبر واتساب أو حفظه",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _exportBackup,
                      icon: const Icon(Icons.download),
                      label: const Text("تصدير نسخة احتياطية"),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isWeak(passCtrl.text) ? null : _save,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text("حفظ الإعدادات", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kPrimary)),
      );
}

class ProductsPage extends StatefulWidget {
  final String storeId, groupId, groupName, empName;
  final double currentDollar;
  const ProductsPage({
    super.key,
    required this.storeId,
    required this.groupId,
    required this.groupName,
    required this.empName,
    required this.currentDollar,
  });
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _search = "", _sortBy = "name";

  CollectionReference get _ref => FirebaseFirestore.instance
      .collection('stores').doc(widget.storeId)
      .collection('groups').doc(widget.groupId)
      .collection('products');

  double _toUSD(double val, String currency) {
    if (currency == "دولار") return val;
    if (currency == "ل.س قديمة") return widget.currentDollar > 0 ? val / widget.currentDollar : 0;
    return widget.currentDollar > 0 ? (val * 100) / widget.currentDollar : 0;
  }

  void _productDialog({QueryDocumentSnapshot? existing}) {
    final data = existing?.data() as Map<String, dynamic>?;
    final nameCtrl = TextEditingController(text: data?['name'] ?? "");
    final qtyCtrl = TextEditingController(text: (data?['qty'] ?? "").toString());
    final priceCtrl = TextEditingController(text: data != null ? (data['priceUSD'] ?? 0).toStringAsFixed(2) : "");
    String unit = data?['unit'] ?? "عدد";
    String currency = "دولار";

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text(existing == null ? "إضافة منتج" : "تعديل المنتج"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "اسم المنتج")),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "الكمية"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: unit,
                      items: ["عدد", "كيلو", "غرام"]
                          .map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setD(() => unit = v ?? "عدد"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "السعر"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: currency,
                      items: ["دولار", "ل.س قديمة", "ل.س جديدة"]
                          .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setD(() => currency = v ?? "دولار"),
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
                if (nameCtrl.text.isNotEmpty) {
                  final priceUSD = _toUSD(double.tryParse(priceCtrl.text) ?? 0, currency);
                  final d = {
                    'name': nameCtrl.text.trim(),
                    'qty': double.tryParse(qtyCtrl.text) ?? 0,
                    'unit': unit,
                    'priceUSD': priceUSD,
                    'addedBy': widget.empName,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  if (existing == null) {
                    await _ref.add(d);
                  } else {
                    await existing.reference.update(d);
                  }
                  Navigator.pop(c);
                }
              },
              child: Text(existing == null ? "إضافة" : "حفظ التعديل"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(widget.groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: "name", child: Text("ترتيب أبجدي")),
              const PopupMenuItem(value: "qty", child: Text("حسب الكمية")),
            ],
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _productDialog()),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "بحث في المنتجات...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _ref.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var products = snapshot.data!.docs
                    .where((p) => (p['name'] ?? "").toString().toLowerCase().contains(_search.toLowerCase()))
                    .toList();
                products.sort((a, b) => _sortBy == "qty"
                    ? (b['qty'] ?? 0).compareTo(a['qty'] ?? 0)
                    : (a['name'] ?? "").compareTo(b['name'] ?? ""));
                if (products.isEmpty) {
                  return const Center(child: Text("لا توجد منتجات", style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    final data = p.data() as Map<String, dynamic>;
                    final qty = (data['qty'] ?? 0).toDouble();
                    final unit = data['unit'] ?? "عدد";
                    final priceUSD = (data['priceUSD'] ?? 0.0).toDouble();
                    final priceLiraOld = priceUSD * widget.currentDollar;
                    final priceLiraNew = priceLiraOld / 100;
                    final isLow = qty <= 3;
                    final updatedAt = data['updatedAt'] as Timestamp?;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isLow ? Colors.red[50] : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(data['name'] ?? "",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                if (isLow) const Icon(Icons.warning_amber, color: Colors.red, size: 18),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: kPrimaryLight, size: 20),
                                  onPressed: () => _productDialog(existing: p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("حذف المنتج"),
                                        content: Text("هل تريد حذف '${data['name']}'؟"),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text("حذف"),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) await p.reference.delete();
                                  },
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isLow ? Colors.red[100] : const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "الكمية: ${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 2)} $unit${isLow ? " ⚠️ نفاد قريب" : ""}",
                                style: TextStyle(color: isLow ? Colors.red : kPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("💵 ${NumberFormat("#,##0.##").format(priceUSD)} \$", style: const TextStyle(fontSize: 14)),
                            Text("ل.س قديمة: ${NumberFormat("#,##0").format(priceLiraOld)}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            Text("ل.س جديدة: ${NumberFormat("#,##0.##").format(priceLiraNew)}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            if (updatedAt != null)
                              Text(
                                "آخر تحديث: ${DateFormat('yyyy/MM/dd HH:mm').format(updatedAt.toDate())}",
                                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String productId, groupId, name, unit;
  final double priceUSD;
  double qty;
  String qtyType;
  double? directPriceUSD;

  CartItem({
    required this.productId,
    required this.groupId,
    required this.name,
    required this.unit,
    required this.priceUSD,
    required this.qty,
    this.qtyType = "عدد",
    this.directPriceUSD,
  });

  double get totalUSD {
    if (qtyType == "سعر_مباشر" && directPriceUSD != null) return directPriceUSD!;
    if (qtyType == "غرام") return priceUSD * (qty / 1000);
    return priceUSD * qty;
  }
}

class NewInvoicePage extends StatefulWidget {
  final String storeId, empName;
  final double currentDollar;
  const NewInvoicePage({super.key, required this.storeId, required this.empName, required this.currentDollar});
  @override
  State<NewInvoicePage> createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage> {
  final List<CartItem> cart = [];

  double get totalUSD => cart.fold(0.0, (s, i) => s + i.totalUSD);
  double get totalLiraOld => totalUSD * widget.currentDollar;
  double get totalLiraNew => totalLiraOld / 100;

  double _toUSD(double val, String currency) {
    if (currency == "دولار") return val;
    if (currency == "ل.س قديمة") return widget.currentDollar > 0 ? val / widget.currentDollar : 0;
    return widget.currentDollar > 0 ? (val * 100) / widget.currentDollar : 0;
  }

  void _editQtyDialog(CartItem item) {
    String qtyType = item.qtyType;
    final qtyCtrl = TextEditingController(text: item.qty.toStringAsFixed(0));
    final priceCtrl = TextEditingController(text: item.directPriceUSD?.toStringAsFixed(2) ?? "");
    String currency = "دولار";

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text("تحديد كمية: ${item.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                children: ["عدد", "كيلو", "غرام", "سعر مباشر"].map((t) {
                  final val = t == "سعر مباشر" ? "سعر_مباشر" : t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: qtyType == val,
                    onSelected: (_) => setD(() => qtyType = val),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              if (qtyType != "سعر_مباشر")
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "الكمية (${qtyType == "غرام" ? "غرام" : qtyType == "كيلو" ? "كيلو" : "عدد"})"),
                )
              else
                Column(
                  children: [
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "السعر"),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: currency,
                      isExpanded: true,
                      items: ["دولار", "ل.س قديمة", "ل.س جديدة"]
                          .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setD(() => currency = v ?? "دولار"),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  item.qtyType = qtyType;
                  if (qtyType == "سعر_مباشر") {
                    item.directPriceUSD = _toUSD(double.tryParse(priceCtrl.text) ?? 0, currency);
                    item.qty = 1;
                  } else {
                    item.qty = double.tryParse(qtyCtrl.text) ?? 1;
                    item.directPriceUSD = null;
                  }
                });
                Navigator.pop(c);
              },
              child: const Text("تأكيد"),
            ),
          ],
        ),
      ),
    );
  }

  void _pickProducts() async {
    final groupsSnap = await FirebaseFirestore.instance
        .collection('stores').doc(widget.storeId).collection('groups').get();
    if (!mounted) return;
    String? selectedGroupId = groupsSnap.docs.isNotEmpty ? groupsSnap.docs.first.id : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (c, scrollCtrl) => Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text("اختر المنتجات", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: groupsSnap.docs.map((g) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(g['name']),
                        selected: g.id == selectedGroupId,
                        onSelected: (_) => setSheet(() => selectedGroupId = g.id),
                      ),
                    )).toList(),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: selectedGroupId == null
                      ? const Center(child: Text("لا توجد أقسام"))
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('stores').doc(widget.storeId)
                              .collection('groups').doc(selectedGroupId)
                              .collection('products').snapshots(),
                          builder: (context, snap) {
                            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                            final products = snap.data!.docs;
                            if (products.isEmpty) return const Center(child: Text("لا توجد منتجات"));
                            return ListView.builder(
                              controller: scrollCtrl,
                              itemCount: products.length,
                              itemBuilder: (c, i) {
                                final p = products[i];
                                final price = (p['priceUSD'] ?? 0.0).toDouble();
                                return ListTile(
                                  title: Text(p['name'] ?? ""),
                                  subtitle: Text("${NumberFormat("#,##0.##").format(price)} \$"),
                                  trailing: const Icon(Icons.add_circle, color: kPrimaryLight),
                                  onTap: () {
                                    setState(() {
                                      final ex = cart.where((c) => c.productId == p.id).toList();
                                      if (ex.isNotEmpty) {
                                        ex.first.qty += 1;
                                      } else {
                                        cart.add(CartItem(
                                          productId: p.id,
                                          groupId: selectedGroupId!,
                                          name: p['name'] ?? "",
                                          unit: p['unit'] ?? "عدد",
                                          priceUSD: price,
                                          qty: 1,
                                        ));
                                      }
                                    });
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("فاتورة جديدة"),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.blue[200]),
                        const SizedBox(height: 12),
                        const Text("لم تتم إضافة منتجات بعد", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.length,
                    itemBuilder: (c, i) {
                      final item = cart[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    GestureDetector(
                                      onTap: () => _editQtyDialog(item),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: kPrimaryLight.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item.qtyType == "سعر_مباشر"
                                              ? "سعر: ${NumberFormat("#,##0.##").format(item.totalUSD)} \$  ✏️"
                                              : "${item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 2)} ${item.qtyType}  ✏️",
                                          style: const TextStyle(fontSize: 12, color: kPrimaryLight),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.qtyType != "سعر_مباشر") ...[
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => setState(() {
                                    item.qty -= 1;
                                    if (item.qty <= 0) cart.removeAt(i);
                                  }),
                                ),
                                Text(item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 2)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => setState(() => item.qty += 1),
                                ),
                              ],
                              Text(
                                "${NumberFormat("#,##0.##").format(item.totalUSD)} \$",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimary),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                onPressed: () => setState(() => cart.removeAt(i)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("الإجمالي:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${NumberFormat("#,##0.##").format(totalUSD)} \$",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimary, fontSize: 15)),
                        Text("ل.س ق: ${NumberFormat("#,##0").format(totalLiraOld)}",
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        Text("ل.س ج: ${NumberFormat("#,##0.##").format(totalLiraNew)}",
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickProducts,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("إضافة منتج"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (cart.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("أضف منتجات أولاً"), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => PaymentPage(
                              storeId: widget.storeId,
                              empName: widget.empName,
                              currentDollar: widget.currentDollar,
                              cart: cart,
                              totalUSD: totalUSD,
                            ),
                          ));
                        },
                        icon: const Icon(Icons.payments),
                        label: const Text("الدفع"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final String storeId, empName;
  final double currentDollar, totalUSD;
  final List<CartItem> cart;
  const PaymentPage({
    super.key,
    required this.storeId,
    required this.empName,
    required this.currentDollar,
    required this.cart,
    required this.totalUSD,
  });
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final paidCtrl = TextEditingController();
  final customerCtrl = TextEditingController();
  String paidCurrency = "دولار";
  bool saving = false;

  @override
  void initState() {
    super.initState();
    paidCtrl.text = widget.totalUSD.toStringAsFixed(2);
  }

  double _toUSD(double val, String currency) {
    if (currency == "دولار") return val;
    if (currency == "ل.س قديمة") return widget.currentDollar > 0 ? val / widget.currentDollar : 0;
    return widget.currentDollar > 0 ? (val * 100) / widget.currentDollar : 0;
  }

  double get paidUSD => _toUSD(double.tryParse(paidCtrl.text) ?? 0, paidCurrency);
  double get remaining => (widget.totalUSD - paidUSD).clamp(0, double.infinity);
  bool get isDebt => remaining > 0.0001;

  Future<void> _save() async {
    if (isDebt && customerCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب إدخال اسم الزبون عند وجود متبقي"), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => saving = true);

    final itemsData = widget.cart.map((c) => {
      'productId': c.productId,
      'groupId': c.groupId,
      'name': c.name,
      'unit': c.qtyType,
      'priceUSD': c.priceUSD,
      'qty': c.qty,
      'totalUSD': c.totalUSD,
    }).toList();

    await FirebaseFirestore.instance
        .collection('stores').doc(widget.storeId).collection('invoices').add({
      'items': itemsData,
      'totalUSD': widget.totalUSD,
      'paidUSD': paidUSD,
      'remainingUSD': isDebt ? remaining : 0.0,
      'isDebt': isDebt,
      'isPaid': !isDebt,
      'customerName': isDebt ? customerCtrl.text.trim() : null,
      'employeeName': widget.empName,
      'dollarRateAtSale': widget.currentDollar,
      'createdAt': FieldValue.serverTimestamp(),
      'dateStr': DateTime.now().toString().substring(0, 16),
    });

    for (final c in widget.cart) {
      if (c.qtyType != "سعر_مباشر") {
        double deduct = c.qtyType == "غرام" ? c.qty / 1000 : c.qty;
        await FirebaseFirestore.instance
            .collection('stores').doc(widget.storeId)
            .collection('groups').doc(c.groupId)
            .collection('products').doc(c.productId)
            .update({'qty': FieldValue.increment(-deduct)});
      }
    }

    if (!mounted) return;
    setState(() => saving = false);
    Navigator.popUntil(context, (route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDebt ? "تم حفظ الفاتورة في قسم الدين" : "✅ تم حفظ الفاتورة بنجاح"),
        backgroundColor: isDebt ? Colors.orange : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("الدفع"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("إجمالي الفاتورة"),
                        Text("${NumberFormat("#,##0.##").format(widget.totalUSD)} \$",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("ل.س قديمة:"),
                        Text(NumberFormat("#,##0").format(widget.totalUSD * widget.currentDollar)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("ل.س جديدة:"),
                        Text(NumberFormat("#,##0.##").format(widget.totalUSD * widget.currentDollar / 100)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: paidCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: "المبلغ المدفوع", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: paidCurrency,
                  items: ["دولار", "ل.س قديمة", "ل.س جديدة"]
                      .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => paidCurrency = v ?? "دولار"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isDebt) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Text(
                  "متبقي: ${NumberFormat("#,##0.##").format(remaining)} \$ — ستُسجَّل في الدين",
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customerCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: "اسم الزبون *", border: OutlineInputBorder()),
              ),
              if (customerCtrl.text.trim().isNotEmpty)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('stores').doc(widget.storeId)
                      .collection('invoices').where('isPaid', isEqualTo: false).snapshots(),
                  builder: (_, snap) {
                    if (!snap.hasData) return const SizedBox();
                    final existing = snap.data!.docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return (data['customerName'] ?? "").toString().toLowerCase() ==
                          customerCtrl.text.trim().toLowerCase();
                    }).toList();
                    if (existing.isEmpty) return const SizedBox();
                    final totalDebt = existing.fold<double>(
                        0, (s, d) => s + ((d.data() as Map<String, dynamic>)['remainingUSD'] ?? 0));
                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        "⚠️ ${customerCtrl.text} عنده دين سابق: ${NumberFormat("#,##0.##").format(totalDebt)} \$",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: saving ? null : _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("حفظ الفاتورة", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class InvoicesPage extends StatefulWidget {
  final String storeId;
  final bool debtOnly;
  const InvoicesPage({super.key, required this.storeId, required this.debtOnly});
  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  String _search = "";

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('stores').doc(widget.storeId).collection('invoices')
        .orderBy('createdAt', descending: true);
    if (widget.debtOnly) {
      query = query.where('isPaid', isEqualTo: false);
    } else {
      query = query.where('isPaid', isEqualTo: true);
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(widget.debtOnly ? "قسم الدين" : "الفواتير"),
      ),
      body: Column(
        children: [
          if (widget.debtOnly)
            StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) return const SizedBox();
                final total = snap.data!.docs.fold<double>(
                    0, (s, d) => s + ((d.data() as Map<String, dynamic>)['remainingUSD'] ?? 0));
                return Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text("إجمالي الديون: ${NumberFormat("#,##0.##").format(total)} \$",
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.debtOnly ? "بحث باسم الزبون..." : "بحث في الفواتير...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var invoices = snapshot.data!.docs.where((d) {
                  if (_search.isEmpty) return true;
                  final data = d.data() as Map<String, dynamic>;
                  final customer = (data['customerName'] ?? "").toString().toLowerCase();
                  final emp = (data['employeeName'] ?? "").toString().toLowerCase();
                  return customer.contains(_search.toLowerCase()) || emp.contains(_search.toLowerCase());
                }).toList();

                if (invoices.isEmpty) {
                  return Center(
                    child: Text(widget.debtOnly ? "لا توجد ديون" : "لا توجد فواتير",
                        style: const TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: invoices.length,
                  itemBuilder: (c, i) {
                    final inv = invoices[i];
                    final data = inv.data() as Map<String, dynamic>;
                    final items = (data['items'] as List<dynamic>? ?? []);
                    return Card(
                      color: widget.debtOnly ? Colors.red[50] : null,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${NumberFormat("#,##0.##").format(data['totalUSD'] ?? 0)} \$",
                              style: TextStyle(fontWeight: FontWeight.bold,
                                  color: widget.debtOnly ? Colors.red[800] : kPrimary),
                            ),
                            if (widget.debtOnly)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                                icon: const Icon(Icons.payment, size: 14),
                                label: const Text("تسديد", style: TextStyle(fontSize: 12)),
                                onPressed: () => _payDebtDialog(inv, data),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          "البائع: ${data['employeeName'] ?? ''} • ${data['dateStr'] ?? ''}"
                          "${widget.debtOnly ? '\nالزبون: ${data['customerName'] ?? ''} — متبقي: ${NumberFormat("#,##0.##").format(data['remainingUSD'] ?? 0)} \$' : ''}",
                          style: TextStyle(color: widget.debtOnly ? Colors.red[700] : Colors.grey[600], fontSize: 12),
                        ),
                        children: [
                          ...items.map((it) {
                            final m = it as Map<String, dynamic>;
                            return ListTile(
                              dense: true,
                              title: Text(m['name'] ?? ''),
                              trailing: Text(
                                "${m['qty']} ${m['unit'] ?? ''} = ${NumberFormat("#,##0.##").format(m['totalUSD'] ?? 0)}\$",
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.share, size: 16),
                                  label: const Text("مشاركة", style: TextStyle(fontSize: 12)),
                                  onPressed: () => _shareInvoice(data, items),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                                  label: const Text("حذف", style: TextStyle(color: Colors.red, fontSize: 12)),
                                  onPressed: () => _deleteInvoice(inv),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _payDebtDialog(QueryDocumentSnapshot inv, Map<String, dynamic> data) {
    final ctrl = TextEditingController();
    String currency = "دولار";
    final currentDollar = (data['dollarRateAtSale'] ?? 15000.0).toDouble();

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text("تسديد دين: ${data['customerName'] ?? ''}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("المتبقي: ${NumberFormat("#,##0.##").format(data['remainingUSD'] ?? 0)} \$"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "المبلغ المدفوع"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: currency,
                    items: ["دولار", "ل.س قديمة", "ل.س جديدة"]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setD(() => currency = v ?? "دولار"),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () async {
                double paid = double.tryParse(ctrl.text) ?? 0;
                double paidUSD;
                if (currency == "دولار") paidUSD = paid;
                else if (currency == "ل.س قديمة") paidUSD = currentDollar > 0 ? paid / currentDollar : 0;
                else paidUSD = currentDollar > 0 ? (paid * 100) / currentDollar : 0;

                final remaining = ((data['remainingUSD'] ?? 0) - paidUSD).clamp(0.0, double.infinity);
                final isPaid = remaining < 0.001;

                await inv.reference.update({
                  'paidUSD': (data['paidUSD'] ?? 0) + paidUSD,
                  'remainingUSD': remaining,
                  'isPaid': isPaid,
                  'isDebt': !isPaid,
                });

                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isPaid
                        ? "✅ تم تسديد الدين كامل — انتقلت للفواتير"
                        : "تم تسجيل الدفعة، متبقي: ${NumberFormat("#,##0.##").format(remaining)} \$"),
                    backgroundColor: isPaid ? Colors.green : Colors.orange,
                  ),
                );
              },
              child: const Text("تأكيد التسديد"),
            ),
          ],
        ),
      ),
    );
  }

  void _shareInvoice(Map<String, dynamic> data, List<dynamic> items) {
    final sb = StringBuffer();
    sb.writeln("🧾 فاتورة ترويقة");
    sb.writeln("━━━━━━━━━━━━━━━━");
    sb.writeln("📅 ${data['dateStr'] ?? ''}");
    sb.writeln("👤 البائع: ${data['employeeName'] ?? ''}");
    if (data['customerName'] != null) sb.writeln("🛒 الزبون: ${data['customerName']}");
    sb.writeln("━━━━━━━━━━━━━━━━");
    for (final it in items) {
      final m = it as Map<String, dynamic>;
      sb.writeln("• ${m['name']} — ${m['qty']} ${m['unit'] ?? ''} = ${NumberFormat("#,##0.##").format(m['totalUSD'] ?? 0)} \$");
    }
    sb.writeln("━━━━━━━━━━━━━━━━");
    sb.writeln("💵 الإجمالي: ${NumberFormat("#,##0.##").format(data['totalUSD'] ?? 0)} \$");
    sb.writeln("✅ المدفوع: ${NumberFormat("#,##0.##").format(data['paidUSD'] ?? 0)} \$");
    if ((data['remainingUSD'] ?? 0) > 0) {
      sb.writeln("⚠️ المتبقي: ${NumberFormat("#,##0.##").format(data['remainingUSD'])} \$");
    }
    Share.share(sb.toString(), subject: "فاتورة ترويقة");
  }

  void _deleteInvoice(QueryDocumentSnapshot inv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("حذف الفاتورة"),
        content: const Text("هل تريد حذف هذه الفاتورة نهائياً؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await inv.reference.delete();
              Navigator.pop(context);
            },
            child: const Text("حذف"),
          ),
        ],
      ),
    );
  }
}
