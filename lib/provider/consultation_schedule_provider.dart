import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:telekonsul/models/consultation_schedule/consultation_schedule.dart';

class ConsultationScheduleProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<ConsultationSchedule> _listConsultationSchedule = [];
  List<ConsultationSchedule> get listConsultationSchedule =>
      _listConsultationSchedule;

  // Get all the consultation schedule from doctor subCollection
  getListConsultationSchedule(String? doctorId) async {
    _isLoading = true;
    _listConsultationSchedule.clear();
    await FirebaseFirestore.instance
        .doc('doctor/$doctorId')
        .collection('consultation_schedule')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _listConsultationSchedule.addAll(
          value.docs.map((e) => ConsultationSchedule.fromJson(e.data())));
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  // Adding the consultation schedule data to doctor subCollection
  addConsultationSchedule(
    Map<String, dynamic> data,
    String? doctorId,
  ) async {
    await FirebaseFirestore.instance
        .doc("doctor/$doctorId")
        .collection('consultation_schedule')
        .add(data)
        .then((value) async {
      await value.update({
        'doc_id': value.id,
      });
      return;
    });
  }

  // Updating doctor consultation schedule data
  updateConsultationSchedule(
    String? docId,
    Map<String, dynamic> data,
    String? doctorId,
  ) async {
    await FirebaseFirestore.instance
        .doc('doctor/$doctorId/consultation_schedule/$docId')
        .update(data);
    return;
  }

  // Deleting doctor consultation schedule data
  deleteConsultationSchedule(
    String? docId,
    String? doctorId,
  ) async {
    await FirebaseFirestore.instance
        .doc('doctor/$doctorId/consultation_schedule/$docId')
        .delete();
    return;
  }
}
