import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:telekonsul/models/queue/queue.dart';

class QueueProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Queue> _listQueue = [];
  List<Queue> get listQueue => _listQueue;

  List<Queue> _listAllQueue = [];
  List<Queue> get listAllQueue => _listAllQueue;

  // Tommorow
  DateTime before = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

  // Yesterday
  DateTime after = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1, 24, 0);

  // Get queue data from doctor subCollection to show in doctor main page, limited to 7
  // And we only get the queue data that hasn't been done, and ordering it from queue number
  get7Queue(String? doctorId) async {
    _isLoading = true;
    _listQueue.clear();

    try {
      await FirebaseFirestore.instance
          .doc('doctor/$doctorId')
          .collection('queue')
          .orderBy('queue_number', descending: false)
          .limit(7)
          .get()
          .then((value) {
        if (value.docs.isEmpty) {
          _isLoading = false;
          notifyListeners();
          return;
        }

        _listQueue.addAll(value.docs.map((e) => Queue.fromJson(e.data())));

        _listQueue = _listQueue
            .where(
              (element) =>
                  element.createdAt.isBefore(before) &&
                  element.createdAt.isAfter(after),
            )
            .toList();

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

  // The exact same like above method, but this time we get all the data
  getAllQueue(String? doctorId) async {
    _isLoading = true;
    _listAllQueue.clear();

    try {
      await FirebaseFirestore.instance
          .doc('doctor/$doctorId')
          .collection('queue')
          .orderBy('queue_number', descending: false)
          .get()
          .then((value) {
        if (value.docs.isEmpty) {
          _isLoading = false;
          notifyListeners();
          return;
        }

        _listAllQueue.addAll(value.docs.map((e) => Queue.fromJson(e.data())));

        _listAllQueue = _listAllQueue
            .where(
              (element) =>
                  element.createdAt.isBefore(before) &&
                  element.createdAt.isAfter(after),
            )
            .toList();

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

  // Adding the queue data to doctor subCollection
  addQueue(String? doctorId, Map<String, dynamic> data) async {
    _isLoading = true;

    try {
      await FirebaseFirestore.instance
          .doc('doctor/$doctorId/queue/${data['doc_id']}')
          .set(data);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return;
    }
  }

  // Updating the queue_number
  updateQueueNumber({
    String? doctorId,
    String? queueId,
    int? number,
  }) async {
    _isLoading = true;

    try {
      await FirebaseFirestore.instance
          .doc('doctor/$doctorId/queue/$queueId')
          .update({
        'queue_number': number,
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return;
    }
  }
}
