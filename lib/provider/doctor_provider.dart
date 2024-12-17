import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:telekonsul/models/queue/queue.dart';
import 'package:telekonsul/models/doctor/doctor.dart';
import 'package:telekonsul/models/consultation_schedule/consultation_schedule.dart';

class DoctorProvider with ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingSpecialist = true;
  bool get isLoadingSpecialist => _isLoadingSpecialist;
  set setLoadingSpecialist(bool value) => _isLoadingSpecialist = value;

  Doctor? _doctor;
  Doctor? get doctor => _doctor;
  set setDoctor(Doctor? doctor) {
    _doctor = doctor;
    notifyListeners();
  }

  List<DataDoctor> _listDoctor = [];
  List<DataDoctor> get listDoctor => _listDoctor;

  List<DataDoctor> _listSpecialistDoctor = [];
  List<DataDoctor> get listSpecialistDoctor => _listSpecialistDoctor;

  // Get the Doctor data, that available for today
  // This doctor data will be shown at user main page
  getAllDoctor(String? userUid) async {
    _isLoading = true;
    _listDoctor.clear();

    // Getting the data from doctor collection
    final dataDoctor = await FirebaseFirestore.instance.collection('doctor').get();

    // if it empty, it will be returned with no value
    if (dataDoctor.docs.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // if not, then it will be assigned to doctorList adding all the Data
    // DoctorData need doctor, consultationSchedule and isBooked (to check whether the user already book this user or not)
    _listDoctor.addAll(
      dataDoctor.docs.map(
        (e) => DataDoctor()
          ..doctor = Doctor.fromJson(e.data())
          ..consultationSchedule = []
          ..isBooked = false,
      ),
    );

    // After the data assigned, next we need to get consultation schedule from every doctor subCollection
    // Using Future.forEach to make the loop async
    await Future.forEach<DataDoctor>(_listDoctor, (element) async {
      // Getting the consultation schedule data, with Doctor uid from element
      final dataJadwal = await FirebaseFirestore.instance
          .doc('doctor/${element.doctor.uid}')
          .collection('consultation_schedule')
          .get();

      // if it empty, any user can't book this doctor yet, and obviously no one has booked yet
      if (dataJadwal.docs.isEmpty) {
        element.consultationSchedule.addAll([]);
        element.isBooked = false;
        return;
      }

      // If not we update the consultation schedule element
      element.consultationSchedule.addAll(dataJadwal.docs.map((e) => ConsultationSchedule.fromJson(e.data())));

      // And checking whether the user already book this doctor or not, with the method that I already made in this class too
      element.isBooked = await checkIfBooked(element.doctor.uid, userUid);
    });

    // Get the doctor where, the consultation schedule are today, based on day intValue
    // Monday is (1) .... Sunday (7)
    _listDoctor = _listDoctor
        .where((element) =>
            element.consultationSchedule.any((element) => element.daySchedule!.intValue == DateTime.now().weekday))
        .toList();

    // We only show 7 data in user mainPage
    // So it will load faster, and the UI will be neat,
    // They can see more in listDoctorSpecialist
    if (_listDoctor.length > 7) {
      _listDoctor.removeRange(8, _listDoctor.length);
    }
    _isLoading = false;
    notifyListeners();
    return;
  }

  // The process are the same like getAllDoctor, the different are just in here we only get the doctor with some specialist, not all the doctor
  // using .where('specialist', isEqualTo: specialist)
  getDoctorSpecialist(String specialist, String? userUid) async {
    _isLoadingSpecialist = true;
    _listSpecialistDoctor.clear();

    final dataDoctor =
        await FirebaseFirestore.instance.collection('doctor').where('specialist', isEqualTo: specialist).get();

    if (dataDoctor.docs.isEmpty) {
      _isLoadingSpecialist = false;
      notifyListeners();
      return;
    }

    _listSpecialistDoctor.addAll(
      dataDoctor.docs.map(
        (e) => DataDoctor()
          ..doctor = Doctor.fromJson(e.data())
          ..consultationSchedule = []
          ..isBooked = false,
      ),
    );

    await Future.forEach<DataDoctor>(_listSpecialistDoctor, (element) async {
      final dataJadwal = await FirebaseFirestore.instance
          .doc('doctor/${element.doctor.uid}')
          .collection('consultation_schedule')
          .get();

      if (dataJadwal.docs.isEmpty) {
        element.consultationSchedule.addAll([]);
        element.isBooked = false;
        return;
      }

      element.consultationSchedule.addAll(dataJadwal.docs.map((e) => ConsultationSchedule.fromJson(e.data())));

      element.isBooked = await checkIfBooked(element.doctor.uid, userUid);
    });
    _listSpecialistDoctor = _listSpecialistDoctor
        .where((element) =>
            element.consultationSchedule.any((element) => element.daySchedule!.intValue == DateTime.now().weekday))
        .toList();
    _isLoadingSpecialist = false;
    notifyListeners();
    return;
  }

  // Updating the doctor data, if the doctor change their profile
  updateDoctor(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.doc('doctor/$uid').update(data);
    notifyListeners();
    return;
  }

  // This the method to check wheter the doctor already been booked by the user or not
  // So we need to get the queue data from doctor subCollection
  // And then checking it if the transaction data are match with user uid
  // Before we checking that, we also need to check if the queue hasn't done yet and the queue are for today only
  checkIfBooked(String? doctorId, String? userUid) async {
    bool isBooked = false;

    final dataQueueDoctor = await FirebaseFirestore.instance
        .doc('doctor/$doctorId')
        .collection('queue')
        .where('is_done', isEqualTo: false)
        .get();

    if (dataQueueDoctor.docs.isEmpty) {
      return isBooked;
    }

    List<Queue> dataQueue = [];
    dataQueue.addAll(dataQueueDoctor.docs.map((e) => Queue.fromJson(e.data())));

    // Tommorow
    DateTime before = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

    // Yesterday
    DateTime after = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1, 24, 0);

    // Checking for today queue
    dataQueue = dataQueue
        .where(
          (element) => element.createdAt.isBefore(before) && element.createdAt.isAfter(after),
        )
        .toList();

    // Checking if the transaction are created by the user or not, which mean the user already book the doctor if it created by him and hasn't done yet
    isBooked = dataQueue.any((element) => element.transactionData!.createdBy!.uid == userUid);

    return isBooked;
  }
}
