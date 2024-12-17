import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:telekonsul/models/user/user.dart';

class PatientProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<UserModel> _patient = [];
  List<UserModel> get patient => _patient;

  final List<UserModel> _listAllPatient = [];
  List<UserModel> get listAllPatient => _listAllPatient;

  // Adding the patient data to the doctor subCollection, with the same id as the users
  // So it will be easier to check whether the document already existed or not, to prevent redudance
  addPatient(String? uid, Map<String, dynamic> data) async {
    final dataPatient = await FirebaseFirestore.instance
        .doc('doctor/$uid/patient/${data['doc_id']}')
        .get();

    if (dataPatient.exists) {
      return;
    }

    await FirebaseFirestore.instance
        .doc('doctor/$uid/patient/${data['doc_id']}')
        .set(data);
  }

  // Get all the patient from doctor subCollection, it's limited to 7
  // We showing this at doctor main page, so we don't need all the data
  // The doctor can see all the data at list patient page
  get7Patient(String uid) async {
    _isLoading = true;
    _patient.clear();
    FirebaseFirestore.instance
        .doc('doctor/$uid')
        .collection('patient')
        .limit(7)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _patient.addAll(value.docs.map((e) => UserModel.fromJson(e.data())));
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  // Get all the patient data from doctor subCollection
  getAllPatient(String? uid) async {
    _isLoading = true;
    _listAllPatient.clear();
    FirebaseFirestore.instance
        .doc('doctor/$uid')
        .collection('patient')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _listAllPatient
          .addAll(value.docs.map((e) => UserModel.fromJson(e.data())));
      _isLoading = false;
      notifyListeners();
      return;
    });
  }
}
