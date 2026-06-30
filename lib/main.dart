import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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
  runApp(const RootApp());
}

String storeIdFromPassword(String password) {
  final bytes = utf8.encode(password.trim());
  final digest = sha256.convert(bytes);
  return digest.toString().substring(0, 24);
}

double toUSD(double amount, String currency, double dollarRate) {
  switch (currency) {
    case "ليرة قديمة":
      return amount / dollarRate;
    case "ليرة جديدة":
      return (amount * 100) / dollarRate;
    default:
      return amount;
  }
}

Map<String, double> priceInAllCurrencies(double usd, double dollarRate) {
  final liraOld = usd * dollarRate;
  final liraNew = liraOld / 100;
  return {"usd": usd, "liraOld": liraOld, "liraNew": liraNew};
}

// ============================================================
// Root App مع دعم Dark Mode
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
    Future.delayed(const Duration(milliseconds: 1800), () {
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
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF64B5F6),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
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
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: showSplash
          ? SplashScreen()
          : HomePage(darkMode: darkMode, onToggleDark: setDarkMode),
    );
  }
}

// ============================================================
// شاشة البداية (Splash) - بالكود فقط بدون صور خارجية
// ============================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
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
            colors: [Color(0xFF1565C0), Color(0xFF64B5F6)],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 18,
                  alignment: WrapAlignment.center,
                  children: const [
                    Text("🧀", style: TextStyle(fontSize: 34)),
                    Text("🥛", style: TextStyle(fontSize: 34)),
                    Text("🌰", style: TextStyle(fontSize: 34)),
                    Text("🥤", style: TextStyle(fontSize: 34)),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: const Text(
                    "ترويقة",
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF1565C0)),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("مواد غذائية وبهارات", style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// الصفحة الرئيسية: الأقسام
// ============================================================
class HomePage extends StatefulWidget {
  final bool darkMode;
  final Future<void> Function(bool) onToggleDark;
  const HomePage({super.key, required this.darkMode, required this.onToggleDark});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String employeeName = "موظف";
  String? storePassword;
  String? storeId;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeName = prefs.getString('empName') ?? "موظف";
      storePassword = prefs.getString('storePassword');
      storeId = (storePassword != null && storePassword!.isNotEmpty)
          ? storeIdFromPassword(storePassword!)
          : null;
    });
    if (storeId != null) {
      await registerEmployee();
    }
  }

  Future<void> registerEmployee() async {
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

  Future<void> ensureStoreDoc() async {
    if (storeId == null) return;
    final ref = FirebaseFirestore.instance.collection('stores').doc(storeId);
    final snap = await ref.get();
    if (!snap.exists || !(snap.data()?.containsKey('dollarRate') ?? false)) {
      await ref.set({'dollarRate': 15000.0}, SetOptions(merge: true));
    }
  }

  Future<void> saveSettings({String? newPassword, required String name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('empName', name);
    if (newPassword != null) {
      await prefs.setString('storePassword', newPassword);
    }
  }

  void logActivity(String storeId, String text) {
    FirebaseFirestore.instance.collection('stores').doc(storeId).collection('activity_log').add({
      'text': text,
      'time': FieldValue.serverTimestamp(),
      'by': employeeName,
    });
  }

  void showSettings() {
    final nameCtrl = TextEditingController(text: employeeName);
    final passCtrl = TextEditingController(text: storePassword ?? "");
    bool obscure = true;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text("الإعدادات"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "اسم الموظف الحالي"),
                  onSubmitted: (v) async {
                    employeeName = v.trim().isEmpty ? "موظف" : v.trim();
                    await saveSettings(name: employeeName);
                    await registerEmployee();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),
                if (storeId != null) DollarRateField(storeId: storeId!),
                const Divider(height: 28),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text("ربط المتجر", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "أي شخص يدخل نفس كلمة السر سيشارك نفس بيانات المتجر",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passCtrl,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: "كلمة سر المتجر",
                    hintText: "اتركها فاضية لإلغاء الربط",
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setD(() => obscure = !obscure),
                    ),
                  ),
                ),
                if (passCtrl.text.trim().isNotEmpty && passCtrl.text.trim().length < 4)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      "⚠️ كلمة السر قصيرة، يُفضل كلمة أقوى لحماية بياناتك",
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                const SizedBox(height: 16),
                if (storeId != null) LinkedEmployeesList(storeId: storeId!, currentName: employeeName),
                const SizedBox(height: 16),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("الوضع الليلي"),
                  value: widget.darkMode,
                  onChanged: (v) => widget.onToggleDark(v),
                ),
                if (storeId != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.link_off, color: Colors.red),
                      label: const Text("إلغاء الربط بالمتجر", style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (c2) => AlertDialog(
                            title: const Text("تأكيد"),
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
                          if (mounted) Navigator.pop(c);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () async {
                final newPass = passCtrl.text.trim();
                final oldPass = storePassword ?? "";
                final passwordChanged = newPass != oldPass;

                Future<void> applyChanges() async {
                  employeeName = nameCtrl.text.trim().isEmpty ? "موظف" : nameCtrl.text.trim();
                  storePassword = newPass.isEmpty ? null : newPass;
                  storeId = storePassword != null ? storeIdFromPassword(storePassword!) : null;
                  await saveSettings(newPassword: newPass, name: employeeName);
                  if (storeId != null) {
                    await ensureStoreDoc();
                    await registerEmployee();
                  }
                  setState(() {});
                  if (mounted) Navigator.pop(c);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ تم الحفظ والربط بنجاح"), backgroundColor: Colors.green),
                    );
                  }
                }

                if (passwordChanged && oldPass.isNotEmpty) {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c2) => AlertDialog(
                      title: const Text("تأكيد"),
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

  void addGroupDialog() {
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
                    .add({'name': ctrl.text.trim(), 'color': Colors.blue.value, 'order': DateTime.now().millisecondsSinceEpoch});
                Navigator.pop(c);
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  void editGroupDialog(String groupId, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("تعديل اسم القسم"),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: "اسم القسم")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .collection('groups')
                    .doc(groupId)
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

  void deleteGroupConfirm(String groupId, String name) {
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
              final productsSnap = await FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('groups')
                  .doc(groupId)
                  .collection('products')
                  .get();
              for (final p in productsSnap.docs) {
                await p.reference.delete();
              }
              await FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('groups')
                  .doc(groupId)
                  .delete();
              if (mounted) Navigator.pop(c);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget notLinkedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, size: 64, color: Colors.blue[200]),
            const SizedBox(height: 16),
            const Text(
              "لم يتم ربط التطبيق بمتجر بعد",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "اذهب إلى الإعدادات وأدخل كلمة سر المتجر لعرض الأقسام والمنتجات",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: showSettings,
              icon: const Icon(Icons.settings),
              label: const Text("فتح الإعدادات"),
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
        title: const Text("ترويقة - الأقسام"),
        actions: [
          if (storeId != null)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => ActivityLogPage(storeId: storeId!)),
              ),
            ),
          IconButton(icon: const Icon(Icons.settings), onPressed: showSettings),
        ],
      ),
      body: storeId == null
          ? notLinkedView()
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('stores').doc(storeId).snapshots(),
              builder: (context, storeSnap) {
                final dollarRate = (storeSnap.data?.data() as Map<String, dynamic>?)?['dollarRate']?.toDouble() ?? 15000.0;
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFE3F2FD),
                      child: Center(
                        child: Text(
                          "الموظف: $employeeName | الدولار: ${NumberFormat("#,##0").format(dollarRate)} ل.س",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                        ),
                      ),
                    ),
                    _NavRow(empName: employeeName, storeId: storeId!, currentDollar: dollarRate),
                    DashboardBar(storeId: storeId!),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('stores')
                            .doc(storeId)
                            .collection('groups')
                            .orderBy('order', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final groups = snapshot.data!.docs;
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: groups.length + 1,
                            itemBuilder: (context, index) {
                              if (index == groups.length) {
                                return GestureDetector(
                                  onTap: addGroupDialog,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.add, size: 48, color: Colors.grey),
                                    ),
                                  ),
                                );
                              }
                              final doc = groups[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final colorVal = data['color'] as int? ?? const Color(0xFFE3F2FD).value;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) => ProductsPage(
                                        storeId: storeId!,
                                        groupId: doc.id,
                                        groupName: data['name'] ?? '',
                                        empName: employeeName,
                                        currentDollar: dollarRate,
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () => showModalBottomSheet(
                                  context: context,
                                  builder: (c) => SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.edit),
                                          title: const Text("تعديل الاسم"),
                                          onTap: () {
                                            Navigator.pop(c);
                                            editGroupDialog(doc.id, data['name'] ?? '');
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete, color: Colors.red),
                                          title: const Text("حذف القسم", style: TextStyle(color: Colors.red)),
                                          onTap: () {
                                            Navigator.pop(c);
                                            deleteGroupConfirm(doc.id, data['name'] ?? '');
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(colorVal).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Color(colorVal).withOpacity(0.4)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            data['name'] ?? '',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(colorVal).withOpacity(1).computeLuminance() > 0.7
                                                  ? Colors.black87
                                                  : const Color(0xFF1565C0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        left: 6,
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('stores')
                                              .doc(storeId)
                                              .collection('groups')
                                              .doc(doc.id)
                                              .collection('products')
                                              .snapshots(),
                                          builder: (context, pSnap) {
                                            final count = pSnap.data?.docs.length ?? 0;
                                            final lowStock = pSnap.data?.docs.any((p) =>
                                                    ((p.data() as Map<String, dynamic>)['qty'] ?? 0).toDouble() <= 3) ??
                                                false;
                                            return Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.8),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text("$count منتج", style: const TextStyle(fontSize: 10)),
                                                ),
                                                if (lowStock)
                                                  const Padding(
                                                    padding: EdgeInsets.only(right: 4),
                                                    child: Icon(Icons.error, color: Colors.red, size: 14),
                                                  ),
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
                );
              },
            ),
    );
  }
}

// حقل سعر الدولار المتزامن لحظياً
class DollarRateField extends StatefulWidget {
  final String storeId;
  const DollarRateField({super.key, required this.storeId});
  @override
  State<DollarRateField> createState() => _DollarRateFieldState();
}

class _DollarRateFieldState extends State<DollarRateField> {
  final ctrl = TextEditingController();
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('stores').doc(widget.storeId).snapshots(),
      builder: (context, snap) {
        final rate = (snap.data?.data() as Map<String, dynamic>?)?['dollarRate']?.toDouble() ?? 15000.0;
        if (!initialized) {
          ctrl.text = rate.toStringAsFixed(0);
          initialized = true;
        }
        return TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "سعر الدولار (ل.س) - مشترك بين الجميع"),
          onSubmitted: (v) async {
            final newRate = double.tryParse(v);
            if (newRate != null) {
              await FirebaseFirestore.instance.collection('stores').doc(widget.storeId).set(
                {'dollarRate': newRate},
                SetOptions(merge: true),
              );
            }
          },
        );
      },
    );
  }
}

// قائمة الموظفين المرتبطين بلون أخضر
class LinkedEmployeesList extends StatelessWidget {
  final String storeId;
  final String currentName;
  const LinkedEmployeesList({super.key, required this.storeId, required this.currentName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('stores').doc(storeId).collection('employees').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();
        final docs = snap.data!.docs.where((d) => d.id != currentName).toList();
        docs.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("الموظفون المرتبطون (${docs.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (docs.isEmpty)
              const Text("لا يوجد موظفون آخرون مرتبطون حالياً", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ...docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              final ts = data['lastActive'] as Timestamp?;
              String lastActiveText = "";
              if (ts != null) {
                final diff = DateTime.now().difference(ts.toDate());
                if (diff.inMinutes < 1) {
                  lastActiveText = "الآن";
                } else if (diff.inMinutes < 60) {
                  lastActiveText = "منذ ${diff.inMinutes} دقيقة";
                } else if (diff.inHours < 24) {
                  lastActiveText = "منذ ${diff.inHours} ساعة";
                } else {
                  lastActiveText = "منذ ${diff.inDays} يوم";
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(data['name'] ?? '', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(lastActiveText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// شريط Dashboard تحليلي
class DashboardBar extends StatelessWidget {
  final String storeId;
  const DashboardBar({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('stores').doc(storeId).collection('groups').snapshots(),
      builder: (context, groupsSnap) {
        if (!groupsSnap.hasData) return const SizedBox();
        return FutureBuilder<List<QuerySnapshot>>(
          future: Future.wait(groupsSnap.data!.docs
              .map((g) => g.reference.collection('products').get())
              .toList()),
          builder: (context, futureSnap) {
            if (!futureSnap.hasData) return const SizedBox(height: 0);
            double totalValue = 0;
            int totalProducts = 0;
            int lowStock = 0;
            for (final qs in futureSnap.data!) {
              for (final p in qs.docs) {
                final d = p.data() as Map<String, dynamic>;
                final qty = (d['qty'] ?? 0).toDouble();
                final price = (d['priceUSD'] ?? 0).toDouble();
                totalValue += qty * price;
                totalProducts++;
                if (qty <= 3) lowStock++;
              }
            }
            return Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _dashStat("القيمة الإجمالية", "${NumberFormat("#,##0").format(totalValue)}\$"),
                  _dashStat("المنتجات", "$totalProducts"),
                  _dashStat("منخفضة الكمية", "$lowStock", color: lowStock > 0 ? Colors.red : Colors.green),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _dashStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color ?? const Color(0xFF1565C0))),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

// سجل النشاط / التحذيرات المركزية
class ActivityLogPage extends StatelessWidget {
  final String storeId;
  const ActivityLogPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الإشعارات والتحذيرات")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .collection('activity_log')
            .orderBy('time', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("لا توجد إشعارات حالياً", style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (c, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final ts = d['time'] as Timestamp?;
              String timeText = "";
              if (ts != null) {
                final diff = DateTime.now().difference(ts.toDate());
                timeText = diff.inMinutes < 1
                    ? "الآن"
                    : diff.inMinutes < 60
                        ? "منذ ${diff.inMinutes} دقيقة"
                        : diff.inHours < 24
                            ? "منذ ${diff.inHours} ساعة"
                            : "منذ ${diff.inDays} يوم";
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Color(0xFF1565C0)),
                  title: Text(d['text'] ?? ''),
                  subtitle: Text("${d['by'] ?? ''} • $timeText"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// شريط تنقل سريع لفاتورة جديدة / قسم الفواتير / قسم الدين
class _NavRow extends StatelessWidget {
  final String empName;
  final String storeId;
  final double currentDollar;
  const _NavRow({required this.empName, required this.storeId, required this.currentDollar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: _NavButton(
              icon: Icons.point_of_sale,
              label: "فاتورة جديدة",
              color: const Color(0xFF2196F3),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => NewInvoicePage(storeId: storeId, empName: empName, currentDollar: currentDollar),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _NavButton(
              icon: Icons.receipt_long,
              label: "الفواتير",
              color: const Color(0xFF4CAF50),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => InvoicesPage(storeId: storeId, debtOnly: false, currentDollar: currentDollar)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _NavButton(
              icon: Icons.warning_amber_rounded,
              label: "الدين",
              color: const Color(0xFFE53935),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => InvoicesPage(storeId: storeId, debtOnly: true, currentDollar: currentDollar)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// صفحة المنتجات داخل قسم معين
// ============================================================
class ProductsPage extends StatefulWidget {
  final String storeId;
  final String groupId;
  final String groupName;
  final String empName;
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
  final searchCtrl = TextEditingController();
  String searchText = "";
  String sortMode = "name"; // name أو qty

  CollectionReference get productsRef => FirebaseFirestore.instance
      .collection('stores')
      .doc(widget.storeId)
      .collection('groups')
      .doc(widget.groupId)
      .collection('products');

  void logActivity(String text) {
    FirebaseFirestore.instance.collection('stores').doc(widget.storeId).collection('activity_log').add({
      'text': text,
      'time': FieldValue.serverTimestamp(),
      'by': widget.empName,
    });
  }

  void openProductDialog({DocumentSnapshot? existing}) {
    final isEdit = existing != null;
    final data = isEdit ? existing!.data() as Map<String, dynamic> : {};
    final nameCtrl = TextEditingController(text: isEdit ? data['name'] : "");
    final qtyCtrl = TextEditingController(text: isEdit ? (data['qty']?.toString() ?? "") : "");
    final gramCtrl = TextEditingController();
    final priceCtrl = TextEditingController(
        text: isEdit ? (data['priceUSD']?.toString() ?? "") : "");
    String unit = isEdit ? (data['unit'] ?? "عدد") : "عدد";
    String currency = "دولار";

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text(isEdit ? "تعديل المنتج" : "إضافة منتج"),
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
                        decoration: InputDecoration(labelText: unit == "كيلو" ? "الكمية (كيلو)" : "الكمية"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: unit,
                      items: const [
                        DropdownMenuItem(value: "عدد", child: Text("عدد")),
                        DropdownMenuItem(value: "كيلو", child: Text("كيلو")),
                        DropdownMenuItem(value: "غرام", child: Text("غرام")),
                      ],
                      onChanged: (v) => setD(() => unit = v ?? "عدد"),
                    ),
                  ],
                ),
                if (unit == "كيلو")
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                      controller: gramCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "+ غرام إضافية (اختياري)"),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "السعر للوحدة"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: currency,
                      items: const [
                        DropdownMenuItem(value: "دولار", child: Text("دولار")),
                        DropdownMenuItem(value: "ليرة قديمة", child: Text("ليرة قديمة")),
                        DropdownMenuItem(value: "ليرة جديدة", child: Text("ليرة جديدة")),
                      ],
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
                if (nameCtrl.text.trim().isEmpty) return;
                double qty = double.tryParse(qtyCtrl.text) ?? 0;
                if (unit == "كيلو" && gramCtrl.text.trim().isNotEmpty) {
                  final g = double.tryParse(gramCtrl.text) ?? 0;
                  qty += g / 1000;
                }
                final enteredPrice = double.tryParse(priceCtrl.text) ?? 0.0;
                final priceUSD = toUSD(enteredPrice, currency, widget.currentDollar);

                final payload = {
                  'name': nameCtrl.text.trim(),
                  'qty': qty,
                  'unit': unit,
                  'priceUSD': priceUSD,
                  'addedBy': widget.empName,
                  'date': DateTime.now().toString().substring(0, 16),
                };

                if (isEdit) {
                  await productsRef.doc(existing!.id).update(payload);
                  logActivity("تم تعديل منتج: ${nameCtrl.text.trim()}");
                } else {
                  await productsRef.add(payload);
                  logActivity("تم إضافة منتج جديد: ${nameCtrl.text.trim()}");
                }
                if (mounted) Navigator.pop(c);
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  void deleteProduct(String docId, String name) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("حذف المنتج"),
        content: Text("هل تريد حذف \"$name\"؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await productsRef.doc(docId).delete();
              if (mounted) Navigator.pop(c);
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
        title: Text(widget.groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => sortMode = v),
            icon: const Icon(Icons.sort),
            itemBuilder: (c) => const [
              PopupMenuItem(value: "name", child: Text("ترتيب أبجدي")),
              PopupMenuItem(value: "qty", child: Text("ترتيب حسب الكمية")),
            ],
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: () => openProductDialog()),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: searchCtrl,
              onChanged: (v) => setState(() => searchText = v.trim()),
              decoration: InputDecoration(
                hintText: "بحث عن منتج...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var products = snapshot.data!.docs;

                if (searchText.isNotEmpty) {
                  products = products
                      .where((p) => ((p.data() as Map<String, dynamic>)['name'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(searchText.toLowerCase()))
                      .toList();
                }

                final sorted = [...products];
                if (sortMode == "name") {
                  sorted.sort((a, b) => ((a.data() as Map<String, dynamic>)['name'] ?? '')
                      .toString()
                      .compareTo(((b.data() as Map<String, dynamic>)['name'] ?? '').toString()));
                } else {
                  sorted.sort((a, b) => ((a.data() as Map<String, dynamic>)['qty'] ?? 0)
                      .compareTo((b.data() as Map<String, dynamic>)['qty'] ?? 0));
                }

                if (sorted.isEmpty) {
                  return const Center(child: Text("لا توجد منتجات", style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final p = sorted[index];
                    final data = p.data() as Map<String, dynamic>;
                    final qty = (data['qty'] ?? 0).toDouble();
                    final pUnit = data['unit'] ?? "عدد";
                    final priceUSD = (data['priceUSD'] ?? 0.0).toDouble();
                    final prices = priceInAllCurrencies(priceUSD, widget.currentDollar);
                    final lowStock = qty <= 3;

                    return Card(
                      color: lowStock ? Colors.red[50] : null,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => openProductDialog(existing: p),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(data['name'] ?? "منتج",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: lowStock ? Colors.red[100] : const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "الكمية: ${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 2)} $pUnit",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: lowStock ? Colors.red[800] : const Color(0xFF1565C0)),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => deleteProduct(p.id, data['name'] ?? ''),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text("💲 ${NumberFormat("#,##0.##").format(prices['usd'])} \$ / $pUnit",
                                  style: const TextStyle(fontSize: 14)),
                              Text("ل.س قديمة: ${NumberFormat("#,##0").format(prices['liraOld'])} / $pUnit",
                                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              Text("ل.س جديدة: ${NumberFormat("#,##0.##").format(prices['liraNew'])} / $pUnit",
                                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              if (data['date'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text("آخر تحديث: ${data['date']}",
                                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ),
                            ],
                          ),
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

// ============================================================
// صفحة فاتورة جديدة (بيع)
// ============================================================
class CartItem {
  final String productId;
  final String groupId;
  final String name;
  final String unit;
  final double priceUSD;
  double qty;
  double? directPriceUSD; // لو البيع كان بسعر مباشر بدل الكمية
  CartItem({
    required this.productId,
    required this.groupId,
    required this.name,
    required this.unit,
    required this.priceUSD,
    required this.qty,
    this.directPriceUSD,
  });
  double get totalUSD => directPriceUSD ?? (priceUSD * qty);
}

class NewInvoicePage extends StatefulWidget {
  final String storeId;
  final String empName;
  final double currentDollar;
  const NewInvoicePage({super.key, required this.storeId, required this.empName, required this.currentDollar});

  @override
  State<NewInvoicePage> createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage> {
  final List<CartItem> cart = [];

  double get totalUSD => cart.fold(0.0, (s, i) => s + i.totalUSD);
  double get totalLira => totalUSD * widget.currentDollar;

  void openSellModeDialog(QueryDocumentSnapshot p, String groupId) {
    final data = p.data() as Map<String, dynamic>;
    final unit = data['unit'] ?? "عدد";
    final priceUSD = (data['priceUSD'] ?? 0.0).toDouble();
    String mode = unit == "عدد" ? "عدد" : "كيلو وغرام";
    final qtyCtrl = TextEditingController();
    final kgCtrl = TextEditingController();
    final gramCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String currency = "دولار";

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text(data['name'] ?? "منتج"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 6,
                  children: [
                    ChoiceChip(label: const Text("عدد"), selected: mode == "عدد", onSelected: (_) => setD(() => mode = "عدد")),
                    ChoiceChip(
                        label: const Text("كيلو وغرام"),
                        selected: mode == "كيلو وغرام",
                        onSelected: (_) => setD(() => mode = "كيلو وغرام")),
                    ChoiceChip(
                        label: const Text("سعر مباشر"),
                        selected: mode == "سعر مباشر",
                        onSelected: (_) => setD(() => mode = "سعر مباشر")),
                  ],
                ),
                const SizedBox(height: 12),
                if (mode == "عدد")
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "العدد"),
                  ),
                if (mode == "كيلو وغرام")
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: kgCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "كيلو"))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: TextField(
                              controller: gramCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "غرام"))),
                    ],
                  ),
                if (mode == "سعر مباشر")
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "المبلغ الذي دفعه الزبون"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: currency,
                        items: const [
                          DropdownMenuItem(value: "دولار", child: Text("دولار")),
                          DropdownMenuItem(value: "ليرة قديمة", child: Text("ليرة قديمة")),
                          DropdownMenuItem(value: "ليرة جديدة", child: Text("ليرة جديدة")),
                        ],
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
              onPressed: () {
                double qty = 0;
                double? directUSD;
                if (mode == "عدد") {
                  qty = double.tryParse(qtyCtrl.text) ?? 0;
                } else if (mode == "كيلو وغرام") {
                  final kg = double.tryParse(kgCtrl.text) ?? 0;
                  final g = double.tryParse(gramCtrl.text) ?? 0;
                  qty = kg + (g / 1000);
                } else {
                  final entered = double.tryParse(priceCtrl.text) ?? 0;
                  directUSD = toUSD(entered, currency, widget.currentDollar);
                  qty = priceUSD > 0 ? directUSD / priceUSD : 0;
                }
                if (qty <= 0 && directUSD == null) {
                  Navigator.pop(c);
                  return;
                }
                setState(() {
                  cart.add(CartItem(
                    productId: p.id,
                    groupId: groupId,
                    name: data['name'] ?? "منتج",
                    unit: unit,
                    priceUSD: priceUSD,
                    qty: qty,
                    directPriceUSD: directUSD,
                  ));
                });
                Navigator.pop(c);
              },
              child: const Text("إضافة"),
            ),
          ],
        ),
      ),
    );
  }

  void pickProducts() async {
    final groupsSnap = await FirebaseFirestore.instance.collection('stores').doc(widget.storeId).collection('groups').get();
    if (!mounted) return;
    String? selectedGroupId = groupsSnap.docs.isNotEmpty ? groupsSnap.docs.first.id : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) {
          return DraggableScrollableSheet(
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
                      children: groupsSnap.docs.map((g) {
                        final isSel = g.id == selectedGroupId;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text((g.data() as Map<String, dynamic>)['name'] ?? ''),
                            selected: isSel,
                            onSelected: (_) => setSheet(() => selectedGroupId = g.id),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: selectedGroupId == null
                        ? const Center(child: Text("لا توجد أقسام"))
                        : StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('stores')
                                .doc(widget.storeId)
                                .collection('groups')
                                .doc(selectedGroupId)
                                .collection('products')
                                .snapshots(),
                            builder: (context, snap) {
                              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                              final products = snap.data!.docs;
                              if (products.isEmpty) {
                                return const Center(child: Text("لا توجد منتجات", style: TextStyle(color: Colors.grey)));
                              }
                              return ListView.builder(
                                controller: scrollCtrl,
                                itemCount: products.length,
                                itemBuilder: (c, i) {
                                  final p = products[i];
                                  final data = p.data() as Map<String, dynamic>;
                                  final price = (data['priceUSD'] ?? 0.0).toDouble();
                                  return ListTile(
                                    title: Text(data['name'] ?? ""),
                                    subtitle: Text("${NumberFormat("#,##0.##").format(price)} \$"),
                                    trailing: const Icon(Icons.add_circle, color: Color(0xFF2196F3)),
                                    onTap: () {
                                      Navigator.pop(c);
                                      openSellModeDialog(p, selectedGroupId!);
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
          );
        },
      ),
    );
  }

  void editCartItem(int index) {
    final item = cart[index];
    final qtyCtrl = TextEditingController(text: item.qty.toString());
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("تعديل ${item.name}"),
        content: TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "الكمية"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(qtyCtrl.text);
              if (v != null) {
                setState(() {
                  item.qty = v;
                  item.directPriceUSD = null;
                });
              }
              Navigator.pop(c);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void goToPayment() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أضف منتجات أولاً"), backgroundColor: Colors.orange),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => PaymentPage(
          storeId: widget.storeId,
          empName: widget.empName,
          currentDollar: widget.currentDollar,
          cart: cart,
          totalUSD: totalUSD,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("فاتورة جديدة")),
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
                        child: ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "${item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 2)} ${item.unit} — ${NumberFormat("#,##0.##").format(item.totalUSD)} \$"),
                          onTap: () => editCartItem(i),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => setState(() => cart.removeAt(i)),
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
                    const Text("الإجمالي:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      "${NumberFormat("#,##0.##").format(totalUSD)} \$  =  ${NumberFormat("#,##0").format(totalLira)} ل.س",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1565C0)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pickProducts,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("إضافة منتج"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: goToPayment,
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

// ============================================================
// صفحة الدفع
// ============================================================
class PaymentPage extends StatefulWidget {
  final String storeId;
  final String empName;
  final double currentDollar;
  final List<CartItem> cart;
  final double totalUSD;
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
  final customerNameCtrl = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    paidCtrl.text = widget.totalUSD.toStringAsFixed(2);
  }

  double get paid => double.tryParse(paidCtrl.text) ?? 0.0;
  double get remaining => (widget.totalUSD - paid).clamp(0, double.infinity);
  bool get isDebt => remaining > 0.0001;

  void logActivity(String text) {
    FirebaseFirestore.instance.collection('stores').doc(widget.storeId).collection('activity_log').add({
      'text': text,
      'time': FieldValue.serverTimestamp(),
      'by': widget.empName,
    });
  }

  Future<void> saveInvoice() async {
    if (isDebt && customerNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب إدخال اسم الزبون عند وجود مبلغ متبقي"), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => saving = true);

    final itemsData = widget.cart
        .map((c) => {
              'productId': c.productId,
              'groupId': c.groupId,
              'name': c.name,
              'unit': c.unit,
              'priceUSD': c.priceUSD,
              'qty': c.qty,
              'totalUSD': c.totalUSD,
            })
        .toList();

    await FirebaseFirestore.instance.collection('stores').doc(widget.storeId).collection('invoices').add({
      'items': itemsData,
      'totalUSD': widget.totalUSD,
      'paidUSD': paid,
      'remainingUSD': isDebt ? remaining : 0.0,
      'isDebt': isDebt,
      'customerName': isDebt ? customerNameCtrl.text.trim() : null,
      'employeeName': widget.empName,
      'dollarRateAtSale': widget.currentDollar,
      'createdAt': FieldValue.serverTimestamp(),
      'dateStr': DateTime.now().toString().substring(0, 16),
    });

    for (final c in widget.cart) {
      final ref = FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .collection('groups')
          .doc(c.groupId)
          .collection('products')
          .doc(c.productId);
      await ref.update({'qty': FieldValue.increment(-c.qty)});
    }

    logActivity(isDebt
        ? "فاتورة جديدة بدين (${NumberFormat("#,##0.##").format(widget.totalUSD)}\$) للزبون ${customerNameCtrl.text.trim()}"
        : "فاتورة بيع جديدة بقيمة ${NumberFormat("#,##0.##").format(widget.totalUSD)}\$");

    if (!mounted) return;
    setState(() => saving = false);

    Navigator.popUntil(context, (route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDebt ? "تم حفظ الفاتورة في قسم الدين" : "تم حفظ الفاتورة بنجاح"),
        backgroundColor: isDebt ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الدفع")),
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
                        const Text("بالليرة السورية"),
                        Text("${NumberFormat("#,##0").format(widget.totalUSD * widget.currentDollar)} ل.س",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paidCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: "المبلغ الذي دفعه الزبون (\$)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            if (isDebt)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "متبقي: ${NumberFormat("#,##0.##").format(remaining)} \$ — ستُسجَّل في قسم الدين",
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: customerNameCtrl,
                    decoration: const InputDecoration(labelText: "اسم الزبون *", border: OutlineInputBorder()),
                  ),
                ],
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: saving ? null : saveInvoice,
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

// ============================================================
// صفحة الفواتير / الدين
// ============================================================
class InvoicesPage extends StatefulWidget {
  final String storeId;
  final bool debtOnly;
  final double currentDollar;
  const InvoicesPage({super.key, required this.storeId, required this.debtOnly, required this.currentDollar});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final searchCtrl = TextEditingController();
  String searchText = "";
  String dateFilter = "الكل";

  void logActivity(String text) {
    FirebaseFirestore.instance.collection('stores').doc(widget.storeId).collection('activity_log').add({
      'text': text,
      'time': FieldValue.serverTimestamp(),
      'by': '',
    });
  }

  void addPaymentDialog(DocumentSnapshot inv) {
    final data = inv.data() as Map<String, dynamic>;
    final remaining = (data['remainingUSD'] ?? 0.0).toDouble();
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("إضافة دفعة"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("المتبقي حالياً: ${NumberFormat("#,##0.##").format(remaining)} \$"),
            const SizedBox(height: 10),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "المبلغ المدفوع الآن (\$)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount <= 0) return;
              final newRemaining = (remaining - amount).clamp(0, double.infinity);
              final newPaid = (data['paidUSD'] ?? 0.0).toDouble() + amount;
              final stillDebt = newRemaining > 0.0001;
              await inv.reference.update({
                'remainingUSD': newRemaining,
                'paidUSD': newPaid,
                'isDebt': stillDebt,
              });
              logActivity("تم تسديد دفعة ${NumberFormat("#,##0.##").format(amount)}\$ من فاتورة ${data['customerName'] ?? ''}");
              if (mounted) Navigator.pop(c);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void deleteInvoice(DocumentSnapshot inv) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("حذف الفاتورة"),
        content: const Text("هل أنت متأكد من حذف هذه الفاتورة؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await inv.reference.delete();
              if (mounted) Navigator.pop(c);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  bool passesDateFilter(Timestamp? ts) {
    if (ts == null || dateFilter == "الكل") return true;
    final date = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (dateFilter == "اليوم") return diff.inHours < 24 && date.day == now.day;
    if (dateFilter == "الأسبوع") return diff.inDays <= 7;
    if (dateFilter == "الشهر") return diff.inDays <= 30;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.storeId)
        .collection('invoices')
        .orderBy('createdAt', descending: true);
    if (widget.debtOnly) {
      query = query.where('isDebt', isEqualTo: true);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.debtOnly ? "قسم الدين" : "الفواتير")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: searchCtrl,
              onChanged: (v) => setState(() => searchText = v.trim()),
              decoration: InputDecoration(
                hintText: "بحث باسم الزبون...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ["الكل", "اليوم", "الأسبوع", "الشهر"].map((f) {
                  final sel = dateFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(label: Text(f), selected: sel, onSelected: (_) => setState(() => dateFilter = f)),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var invoices = snapshot.data!.docs;

                invoices = invoices.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final ts = data['createdAt'] as Timestamp?;
                  if (!passesDateFilter(ts)) return false;
                  if (searchText.isNotEmpty) {
                    final customer = (data['customerName'] ?? '').toString().toLowerCase();
                    return customer.contains(searchText.toLowerCase());
                  }
                  return true;
                }).toList();

                double totalDebt = 0;
                if (widget.debtOnly) {
                  for (final d in invoices) {
                    totalDebt += ((d.data() as Map<String, dynamic>)['remainingUSD'] ?? 0).toDouble();
                  }
                }

                if (invoices.isEmpty) {
                  return Center(
                    child: Text(widget.debtOnly ? "لا توجد فواتير دين" : "لا توجد فواتير",
                        style: const TextStyle(color: Colors.grey)),
                  );
                }

                return Column(
                  children: [
                    if (widget.debtOnly)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "إجمالي الديون: ${NumberFormat("#,##0.##").format(totalDebt)} \$",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[800]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: invoices.length,
                        itemBuilder: (c, i) {
                          final invDoc = invoices[i];
                          final inv = invDoc.data() as Map<String, dynamic>;
                          final isDebt = inv['isDebt'] == true;
                          final items = (inv['items'] as List<dynamic>? ?? []);
                          final ts = inv['createdAt'] as Timestamp?;
                          final isOldDebt = isDebt && ts != null && DateTime.now().difference(ts.toDate()).inDays >= 7;

                          return Card(
                            color: isDebt ? Colors.red[50] : null,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ExpansionTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${NumberFormat("#,##0.##").format(inv['totalUSD'] ?? 0)} \$",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDebt ? Colors.red[800] : const Color(0xFF1565C0)),
                                  ),
                                  Row(
                                    children: [
                                      if (isOldDebt)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 6),
                                          child: Icon(Icons.access_time_filled, color: Colors.orange, size: 18),
                                        ),
                                      if (isDebt)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration:
                                              BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                                          child: const Text("دين", style: TextStyle(color: Colors.white, fontSize: 11)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                "البائع: ${inv['employeeName'] ?? ''} • ${inv['dateStr'] ?? ''}"
                                "${isDebt ? '\nالزبون: ${inv['customerName'] ?? ''} — متبقي: ${NumberFormat("#,##0.##").format(inv['remainingUSD'] ?? 0)} \$' : ''}"
                                "${isOldDebt ? '\n⚠️ دين قديم (أكثر من أسبوع)' : ''}",
                                style: TextStyle(color: isDebt ? Colors.red[700] : Colors.grey[600]),
                              ),
                              children: [
                                ...items.map((it) {
                                  final m = it as Map<String, dynamic>;
                                  return ListTile(
                                    dense: true,
                                    title: Text(m['name'] ?? ''),
                                    trailing: Text(
                                      "${(m['qty'] ?? 0).toString()} ${m['unit'] ?? ''} = ${NumberFormat("#,##0.##").format(m['totalUSD'] ?? 0)}\$",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      if (isDebt)
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            icon: const Icon(Icons.attach_money, size: 18),
                                            label: const Text("إضافة دفعة"),
                                            onPressed: () => addPaymentDialog(invDoc),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                          label: const Text("حذف", style: TextStyle(color: Colors.red)),
                                          onPressed: () => deleteInvoice(invDoc),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
