part of '../pages.dart';

class ConsultationDetail extends StatefulWidget {
  final DataDoctor dataDoctor;
  const ConsultationDetail({Key? key, required this.dataDoctor}) : super(key: key);

  @override
  _ConsultationDetailState createState() => _ConsultationDetailState();
}

class _ConsultationDetailState extends State<ConsultationDetail> {
  DataDoctor get dataDoctor => widget.dataDoctor;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Toolbar(),
              const SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 1,
                child: Stack(
                  children: [
                    Image.asset('assets/medical.png'),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            dataDoctor.doctor.profileUrl != "" ? NetworkImage(dataDoctor.doctor.profileUrl!) : null,
                        child: dataDoctor.doctor.profileUrl != ""
                            ? null
                            : const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 86,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Column(
                  children: [
                    Text(
                      "${dataDoctor.doctor.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text("${dataDoctor.doctor.specialist}"),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Available at:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Container(
                          child: dataDoctor.consultationSchedule
                              .where((element) => element.daySchedule!.intValue == DateTime.now().weekday)
                              .map(
                                (e) => Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${e.startAt!.format(context)} - ${e.endAt!.format(context)}",
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              )
                              .first,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      "Pratic Address:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ListTile(
                      leading: Image.asset('assets/hospital.png'),
                      title: Text("${dataDoctor.doctor.address}"),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const SizedBox(width: 22),
                        const Text(
                          "Price :",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        dataDoctor.consultationSchedule
                            .where((element) => element.daySchedule!.intValue == DateTime.now().weekday)
                            .map(
                              (e) => Text(
                                "\$${NumberFormat("#,###").format(e.price)}",
                              ),
                            )
                            .first,
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : MaterialButton(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                final transactionData = await _bookNow();
                                setState(() {
                                  _isLoading = false;
                                });
                                if (transactionData != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Transaction Sucessfully Created!"),
                                    ),
                                  );
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => TransactionDetail(
                                        transaction: transactionData,
                                      ),
                                    ),
                                  );
                                }
                              },
                              color: AppTheme.primaryColor,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Text("Đặt ngay"),
                              minWidth: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.06,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<TransactionModel?> _bookNow() async {
    // Get patient data, which is the user itself
    UserModel dataPatient = Provider.of<UserProvider>(context, listen: false).user!;

    // Get schedule data
    ConsultationSchedule schedule = dataDoctor.consultationSchedule
        .where((element) => element.daySchedule!.intValue == DateTime.now().weekday)
        .first;

    DateTime now = DateTime.now();

    // Assign TimeOfDay to DateTime
    DateTime startAt = DateTime(now.year, now.month, now.day, schedule.startAt!.hour, schedule.startAt!.minute);
    DateTime endAt = DateTime(now.year, now.month, now.day, schedule.endAt!.hour, schedule.endAt!.minute);

    Map<String, dynamic> dataSchedule = {
      'day_schedule': schedule.daySchedule!.toJson(),
      // Format the value to 00:00 PM, so we can get the data later as TimeOfDay
      'start_at': DateFormat("hh:mm a").format(startAt),
      'end_at': DateFormat("hh:mm a").format(endAt),
      'price': schedule.price,
    };

    Map<String, dynamic> dataTransaction = {
      'doctor_profile': dataDoctor.doctor.toJson(),
      'consultation_schedule': dataSchedule,
      'status': "Waiting for Payment",
      'payment_proof': "",
      'created_at': Timestamp.now(),
      'created_by': dataPatient.toJson(),
    };

    // Add transaction data to Firestore
    final newTransaction = await Provider.of<TransactionProvider>(context, listen: false).addTransaction(
      doctorId: dataDoctor.doctor.uid,
      dataTransaction: dataTransaction,
      dataPatient: dataPatient.toJson(),
      userUid: dataPatient.uid,
    );

    if (newTransaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
      return null;
    }

    // Get doctor queue data
    final docQueue = await FirebaseFirestore.instance.doc('doctor/${dataDoctor.doctor.uid}').collection('queue').get();

    List<Queue> listQueue = [];
    listQueue.addAll(docQueue.docs.map((e) => Queue.fromJson(e.data())));

    // Tommorow
    DateTime before = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

    // Yesterday
    DateTime after = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1, 24, 0);

    // Find today queue
    listQueue = listQueue
        .where(
          (element) => element.createdAt.isBefore(before) && element.createdAt.isAfter(after),
        )
        .toList();

    int queueNumber = 1;

    if (listQueue.isNotEmpty) {
      // Get the queue number based on data length
      queueNumber = listQueue.length + 1;
    }

    Map<String, dynamic> newTransactionData = {
      'doc_id': newTransaction.docId,
      'doctor_profile': newTransaction.doctorProfile!.toJson(),
      'consultation_schedule': dataSchedule,
      'status': newTransaction.status,
      'payment_proof': newTransaction.paymentProof,
      'created_at': Timestamp.now(),
      'created_by': newTransaction.createdBy!.toJson(),
    };

    Map<String, dynamic> dataQueue = {
      'doc_id': newTransaction.docId,
      'transaction_data': newTransactionData,
      'queue_number': queueNumber,
      'is_done': false,
      'created_at': Timestamp.now(),
    };

    // Adding the queue data to Firestore
    await Provider.of<QueueProvider>(context, listen: false).addQueue(dataDoctor.doctor.uid, dataQueue);

    // Refresh doctor list
    await Provider.of<DoctorProvider>(context, listen: false).getAllDoctor(newTransaction.createdBy!.uid);

    // Refresh Transaction
    String userId = context.read<UserProvider>().user!.uid!;
    context.read<TransactionProvider>().getAllTransaction(false, userId);

    return newTransaction;
  }
}
