import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:telekonsul/models/transaction/transaction_model.dart';
import 'package:telekonsul/provider/patient_provider.dart';

class TransactionProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<TransactionModel> _listTransaction = [];
  List<TransactionModel> get listTransaction => _listTransaction;

  TransactionModel? _transaction;
  TransactionModel? get transaksi => _transaction;

  PatientProvider? _patientProvider;
  PatientProvider? get patientProvider => _patientProvider;

  // For updating the value of PatientProvider, we use it on main.dart for ChangeNotifierProxyProvider
  set updatePatientProvider(PatientProvider value) {
    _patientProvider = value;
    notifyListeners();
  }

  // Take all transaction data inside the subCollection of Doctor or Patient
  // We need the uid of the user to get into the subCollection
  getAllTransaction(bool isDokter, String? uid) async {
    String role = isDokter ? 'doctor' : 'users';
    _isLoading = true;
    _listTransaction.clear();

    try {
      await FirebaseFirestore.instance.doc('$role/$uid').collection('transaction').get().then((value) {
        if (value.docs.isEmpty) {
          _isLoading = false;
          notifyListeners();
          return;
        }

        _listTransaction.addAll(value.docs.map((e) => TransactionModel.fromJson(e.data())));
        _isLoading = false;
        notifyListeners();
        return;
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return;
    }
  }

  // Adding transaction data and patient data to subCollection of Doctor and Users
  Future<TransactionModel?> addTransaction({
    String? doctorId,
    required Map<String, dynamic> dataTransaction,
    required Map<String, dynamic> dataPatient,
    String? userUid,
  }) async {
    _isLoading = true;
    _transaction = null;

    // Adding transaction data to subCollection of Doctor, we need to have the doctor id to access the transaction subCollection
    await FirebaseFirestore.instance
        .doc('doctor/$doctorId')
        .collection('transaction')
        .add(dataTransaction)
        .then((value) async {
      // Then we updating the document with the document id
      await value.update({
        'doc_id': value.id,
      });

      // Getting the document data
      final data = await value.get();

      // Assign the data value as Transaction
      _transaction = TransactionModel.fromJson(data.data()!);

      // Add doc_id to dataTransaction because we need it to make sure every transaction with the same data have the same documentID
      // So it will be easier if there's a change in one of those document, we can also change the other document because it has the same documentID
      dataTransaction['doc_id'] = value.id;
    });

    // Here's we setting the data to users subCollection, we need it so the users can get their history Transaction later on
    // Also it will more neat
    await FirebaseFirestore.instance
        .doc('users/$userUid/transaction/${dataTransaction['doc_id']}')
        .set(dataTransaction);

    // The PatientProvider already been passed through update method (set)
    // So we can use it, to adding the Patient to Doctor subCollection
    await _patientProvider!.addPatient(doctorId, dataPatient);

    _isLoading = true;
    notifyListeners();

    return _transaction;
  }

  // Here's why we need all the transaction have the same documentID
  // So we can change all of them, because we already know the documentID are the same
  // The image is already uploaded to Firebase Storage, so all we need is the imgUrl
  // And we change the status to Waiting for Confirmation, the users will wait for Doctor to confirm their payment
  confirmPayment(String? docId, String? doctorId, String imgUrl, String? userUid) async {
    _isLoading = true;

    await FirebaseFirestore.instance.doc('users/$userUid/transaction/$docId').update({
      'payment_proof': imgUrl,
      'status': "Waiting for Confirmation",
    });

    await FirebaseFirestore.instance.doc('doctor/$doctorId/transaction/$docId').update({
      'payment_proof': imgUrl,
      'status': "Waiting for Confirmation",
    });

    await FirebaseFirestore.instance.doc('doctor/$doctorId/queue/$docId').update({
      'payment_proof': imgUrl,
      'status': "Waiting for Confirmation",
    });

    _isLoading = false;
    notifyListeners();
    return;
  }

  // For updating the status of the transaction either Success or Fail
  updateStatus(String? docId, String? userId, String? status, String? doctorId) async {
    _isLoading = true;

    await FirebaseFirestore.instance.doc('users/$userId/transaction/$docId').update({
      'status': status,
    });

    await FirebaseFirestore.instance.doc('doctor/$doctorId/transaction/$docId').update({
      'status': status,
    });

    await FirebaseFirestore.instance.doc('doctor/$doctorId/queue/$docId').update({
      'status': status,
    });

    _isLoading = false;
    notifyListeners();
    return;
  }
}
