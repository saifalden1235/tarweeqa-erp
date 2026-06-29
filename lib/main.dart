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
  runApp(const MyApp());
}

// ============================================================
// تحويل كلمة السر إلى معرف متجر (storeId) ثابت ومتطابق على كل الأجهزة
// ============================================================
String storeIdFromPassword(String password) {
  final bytes = utf8.encode(password.trim());
  final digest = sha256.convert(bytes);
  return digest.toString().substring(0, 24);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ترويقة ERP",
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// الصفحة الرئيسية: الأقسام
// ============================================================
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

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeName = prefs.getString('empName') ?? "موظف";
      dollarRate = prefs.getDouble('dollarRate') ?? 15000.0;
      storePassword = prefs.getString('storePassword');
      storeId = (storePassword != null && storePassword!.isNotEmpty)
          ? storeIdFromPassword(storePassword!)
          : null;
    });
  }

  Future<void> saveSettings({String? newPassword}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('empName', employeeName);
    await prefs.setDouble('dollarRate', dollarRate);
    if (newPassword != null) {
      await prefs.setString('storePassword', newPassword);
    }
  }

  void showSettings() {
    final nameCtrl = TextEditingController(text: employeeName);
    final rateCtrl = TextEditingController(text: dollarRate.toStringAsFixed(0));
    final passCtrl = TextEditingController(text: storePassword ?? "");
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("الإعدادات"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "اسم الموظف الحالي"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: rateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "سعر الدولار (ل.س)"),
              ),
              const Divider(height: 24),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("ربط المتجر", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "أي شخص يدخل نفس كلمة السر سيشارك نفس بيانات المتجر (الأقسام والمنتجات والفواتير)",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "كلمة سر المتجر",
                  hintText: "اتركها فاضية لإلغاء الربط",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                employeeName = nameCtrl.text.trim().isEmpty ? "موظف" : nameCtrl.text.trim();
                dollarRate = double.tryParse(rateCtrl.text) ?? 15000.0;
                final newPass = passCtrl.text.trim();
                storePassword = newPass.isEmpty ? null : newPass;
                storeId = storePassword != null ? storeIdFromPassword(storePassword!) : null;
              });
              saveSettings(newPassword: passCtrl.text.trim());
              Navigator.pop(c);
            },
            child: const Text("حفظ"),
          ),
        ],
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
                    .add({'name': ctrl.text.trim()});
                Navigator.pop(c);
              }
            },
            child: const Text("إضافة"),
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
          IconButton(icon: const Icon(Icons.settings), onPressed: showSettings),
        ],
      ),
      body: storeId == null
          ? notLinkedView()
          : Column(
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
                _NavRow(
                  empName: employeeName,
                  storeId: storeId!,
                  currentDollar: dollarRate,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('stores')
                        .doc(storeId)
                        .collection('groups')
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
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => ProductsPage(
                                    storeId: storeId!,
                                    groupId: doc.id,
                                    groupName: doc['name'],
                                    empName: employeeName,
                                    currentDollar: dollarRate,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  doc['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1565C0),
                                  ),
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
                  builder: (c) => NewInvoicePage(
                    storeId: storeId,
                    empName: empName,
                    currentDollar: currentDollar,
                  ),
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
                MaterialPageRoute(builder: (c) => InvoicesPage(storeId: storeId, debtOnly: false)),
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
                MaterialPageRoute(builder: (c) => InvoicesPage(storeId: storeId, debtOnly: true)),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
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
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  String unit = "عدد"; // عدد أو كيلو

  CollectionReference get productsRef => FirebaseFirestore.instance
      .collection('stores')
      .doc(widget.storeId)
      .collection('groups')
      .doc(widget.groupId)
      .collection('products');

  void addProduct() async {
    if (nameCtrl.text.isNotEmpty) {
      await productsRef.add({
        'name': nameCtrl.text.trim(),
        'qty': double.tryParse(qtyCtrl.text) ?? 0,
        'unit': unit,
        'priceUSD': double.tryParse(priceCtrl.text) ?? 0.0,
        'addedBy': widget.empName,
        'date': DateTime.now().toString().substring(0, 10),
      });
      nameCtrl.clear();
      qtyCtrl.clear();
      priceCtrl.clear();
      Navigator.pop(context);
    }
  }

  void deleteProduct(String docId) async {
    await productsRef.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              unit = "عدد";
              showDialog(
                context: context,
                builder: (c) => StatefulBuilder(
                  builder: (c, setD) => AlertDialog(
                    title: const Text("إضافة منتج"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: "اسم المنتج"),
                        ),
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
                              items: const [
                                DropdownMenuItem(value: "عدد", child: Text("عدد")),
                                DropdownMenuItem(value: "كيلو", child: Text("كيلو")),
                              ],
                              onChanged: (v) => setD(() => unit = v ?? "عدد"),
                            ),
                          ],
                        ),
                        TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "سعر البيع للوحدة (\$)"),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c), child: const Text("إلغاء")),
                      ElevatedButton(onPressed: addProduct, child: const Text("حفظ")),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data!.docs;
          if (products.isEmpty) {
            return const Center(child: Text("لا توجد منتجات في هذا القسم", style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              final qty = (p['qty'] ?? 0).toDouble();
              final pUnit = (p.data() as Map<String, dynamic>)['unit'] ?? "عدد";
              final price = (p['priceUSD'] ?? 0.0).toDouble();
              final priceLira = price * widget.currentDollar;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(p['name'] ?? "منتج",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text("الكمية: ${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 2)} $pUnit",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => deleteProduct(p.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("💲 ${NumberFormat("#,##0.##").format(price)} \$ / $pUnit", style: const TextStyle(fontSize: 15)),
                      Text("🇸🇾 ${NumberFormat("#,##0").format(priceLira)} ل.س / $pUnit", style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
  CartItem({
    required this.productId,
    required this.groupId,
    required this.name,
    required this.unit,
    required this.priceUSD,
    required this.qty,
  });
  double get totalUSD => priceUSD * qty;
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

  void addToCart(QueryDocumentSnapshot p, String groupId) {
    final data = p.data() as Map<String, dynamic>;
    final existing = cart.where((c) => c.productId == p.id).toList();
    if (existing.isNotEmpty) {
      setState(() => existing.first.qty += 1);
      return;
    }
    setState(() {
      cart.add(CartItem(
        productId: p.id,
        groupId: groupId,
        name: data['name'] ?? "منتج",
        unit: data['unit'] ?? "عدد",
        priceUSD: (data['priceUSD'] ?? 0.0).toDouble(),
        qty: 1,
      ));
    });
  }

  void pickProducts() async {
    final groupsSnap = await FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.storeId)
        .collection('groups')
        .get();

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
                            label: Text(g['name']),
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
                                  final price = (p['priceUSD'] ?? 0.0).toDouble();
                                  return ListTile(
                                    title: Text(p['name'] ?? ""),
                                    subtitle: Text("${NumberFormat("#,##0.##").format(price)} \$"),
                                    trailing: const Icon(Icons.add_circle, color: Color(0xFF2196F3)),
                                    onTap: () {
                                      addToCart(p, selectedGroupId!);
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      "${NumberFormat("#,##0.##").format(item.priceUSD)} \$ / ${item.unit}",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    item.qty -= 1;
                                    if (item.qty <= 0) cart.removeAt(i);
                                  });
                                },
                              ),
                              Text(item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 2)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setState(() => item.qty += 1),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  "${NumberFormat("#,##0.##").format(item.totalUSD)} \$",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                                ),
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
              color: Colors.white,
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
// صفحة الدفع: تحديد المدفوع والمتبقي وحفظ الفاتورة
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
                        Text(
                          "${NumberFormat("#,##0").format(widget.totalUSD * widget.currentDollar)} ل.س",
                          style: const TextStyle(color: Colors.grey),
                        ),
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
              decoration: const InputDecoration(
                labelText: "المبلغ الذي دفعه الزبون (\$)",
                border: OutlineInputBorder(),
              ),
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
                            "متبقي: ${NumberFormat("#,##0.##").format(remaining)} \$ — ستُسجَّل هذه الفاتورة في قسم الدين",
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: customerNameCtrl,
                    decoration: const InputDecoration(
                      labelText: "اسم الزبون *",
                      border: OutlineInputBorder(),
                    ),
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
class InvoicesPage extends StatelessWidget {
  final String storeId;
  final bool debtOnly;
  const InvoicesPage({super.key, required this.storeId, required this.debtOnly});

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('invoices')
        .orderBy('createdAt', descending: true);
    if (debtOnly) {
      query = query.where('isDebt', isEqualTo: true);
    }

    return Scaffold(
      appBar: AppBar(title: Text(debtOnly ? "قسم الدين" : "الفواتير")),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final invoices = snapshot.data!.docs;
          if (invoices.isEmpty) {
            return Center(
              child: Text(debtOnly ? "لا توجد فواتير دين" : "لا توجد فواتير", style: const TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: invoices.length,
            itemBuilder: (c, i) {
              final inv = invoices[i].data() as Map<String, dynamic>;
              final isDebt = inv['isDebt'] == true;
              final items = (inv['items'] as List<dynamic>? ?? []);
              return Card(
                color: isDebt ? Colors.red[50] : Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${NumberFormat("#,##0.##").format(inv['totalUSD'] ?? 0)} \$",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDebt ? Colors.red[800] : const Color(0xFF1565C0),
                        ),
                      ),
                      if (isDebt)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                          child: const Text("دين", style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    "البائع: ${inv['employeeName'] ?? ''} • ${inv['dateStr'] ?? ''}"
                    "${isDebt ? '\nالزبون: ${inv['customerName'] ?? ''} — متبقي: ${NumberFormat("#,##0.##").format(inv['remainingUSD'] ?? 0)} \$' : ''}",
                    style: TextStyle(color: isDebt ? Colors.red[700] : Colors.grey[600]),
                  ),
                  children: items.map((it) {
                    final m = it as Map<String, dynamic>;
                    return ListTile(
                      dense: true,
                      title: Text(m['name'] ?? ''),
                      trailing: Text(
                        "${m['qty']} ${m['unit'] ?? ''} × ${NumberFormat("#,##0.##").format(m['priceUSD'] ?? 0)}\$ = ${NumberFormat("#,##0.##").format(m['totalUSD'] ?? 0)}\$",
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
