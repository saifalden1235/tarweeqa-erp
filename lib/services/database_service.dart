import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // دالة حفظ الفاتورة (من الكود السابق في main.dart)
  Future<void> saveInvoiceSecurly(String storeId, Map<String, dynamic> invoice) async {
    try {
      await _db.runTransaction((transaction) async {
        final invRef = _db.collection('stores').doc(storeId).collection('invoices').doc();
        transaction.set(invRef, {
          ...invoice,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'finalized',
        });
      });
    } catch (e) {
      Get.snackbar("خطأ", "فشلت عملية الحفظ: $e");
    }
  }

  // دالة طلب الحذف
  Future<void> requestDelete(String storeId, String invoiceId, String empName) async {
    await _db.collection('stores').doc(storeId).collection('invoices').doc(invoiceId).update({
      'status': 'pending_delete',
      'requestedBy': empName,
    });
    Get.snackbar("تم", "تم إرسال طلب حذف الفاتورة للمراجعة");
  }
}

