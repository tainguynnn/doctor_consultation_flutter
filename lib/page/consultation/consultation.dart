part of '../pages.dart';

class ConsultationPage extends StatefulWidget {
  final Queue queue;

  const ConsultationPage({Key? key, required this.queue}) : super(key: key);
  @override
  _ConsultationPageState createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  Queue get queue => widget.queue;

  bool _isLoading = false;

  bool _isDone = false;

  Doctor? currentDoctor;

  final TextEditingController _txtDiagnosis = TextEditingController();

  @override
  void initState() {
    currentDoctor = Provider.of<DoctorProvider>(context, listen: false).doctor;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Toolbar(),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Transaction ID #${queue.transactionData!.docId}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    DateFormat("dd MMMM yyyy").format(queue.transactionData!.createdAt),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text("\$${NumberFormat("#,###").format(queue.transactionData!.consultationSchedule!.price)}"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "${queue.transactionData!.consultationSchedule!.startAt!.format(context)} - ${queue.transactionData!.consultationSchedule!.endAt!.format(context)}",
                ),
              ),
              const SizedBox(height: 56),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey,
                      backgroundImage: queue.transactionData!.createdBy!.profileUrl != ""
                          ? NetworkImage(queue.transactionData!.createdBy!.profileUrl!)
                          : null,
                      child: queue.transactionData!.createdBy!.profileUrl != ""
                          ? null
                          : const Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 86,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Họ Và Tên : ${queue.transactionData!.createdBy!.name}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Email : ${queue.transactionData!.createdBy!.email}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Số Điện Thoại : ${queue.transactionData!.createdBy!.phoneNumber}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Địa Chỉ : ${queue.transactionData!.createdBy!.address}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : queue.isDone! || _isDone
                            ? MaterialButton(
                                minWidth: 148,
                                height: 39,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                color: AppTheme.darkerPrimaryColor,
                                child: const Text(
                                  "Consultation has ended",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                              )
                            : currentDoctor!.isBusy!
                                ? MaterialButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    color: AppTheme.dangerColor,
                                    child: const Text(
                                      "Finish Consultation",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      await _finish(context);
                                      setState(() {
                                        _isLoading = false;
                                        _isDone = true;
                                      });
                                    },
                                  )
                                : MaterialButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    color: AppTheme.primaryColor,
                                    child: const Text(
                                      "Start Consultation",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      await _startConsulting();
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    },
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

  _startConsulting() async {
    bool konfirmasi = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure want to start?"),
        content: const Text("You will be directed to WhatsApp, to start consulting with patient"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    if (konfirmasi) {
      // WhatsApp deeplink, for redirecting to WhatsApp
      String _url = "https://zalo.me/${queue.transactionData!.createdBy!.phoneNumber}";

      await canLaunchUrlString(_url)
          ? await launchUrlString(
              _url,
              mode: LaunchMode.externalApplication,
            )
          : throw 'Could not launch $_url';

      Doctor newData = currentDoctor!;
      newData.isBusy = true;

      // Change the doctor value to busy, so everyone can't book this doctor right now, until consultation is finish
      Provider.of<DoctorProvider>(context, listen: false).setDoctor = newData;
      await FirebaseFirestore.instance.doc('doctor/${newData.uid}').update({'is_busy': true});
    }
  }

  _finish(BuildContext context) async {
    bool konfirmasi = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure want to finish this consultation?"),
        content: const Text("When the consultation is done, you'll asked to report patient diagnosis"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    if (konfirmasi) {
      Doctor newData = currentDoctor!;
      newData.isBusy = false;

      // Change the doctor value to not busy, so everyone can book this doctor now
      Provider.of<DoctorProvider>(context, listen: false).setDoctor = newData;
      await FirebaseFirestore.instance.doc('doctor/${newData.uid}').update({'is_busy': false});

      // Update queue data to done,
      await FirebaseFirestore.instance.doc('doctor/${currentDoctor!.uid}/queue/${queue.docId}').update({
        'is_done': true,
      });

      // Show dialog for doctor input the diagnosis
      String? diagnosis = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Diagnosis Patient"),
          content: TextField(
            controller: _txtDiagnosis,
            decoration: const InputDecoration(hintText: "Diagnosis Patient"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_txtDiagnosis.text),
              child: const Text("Done"),
            ),
          ],
        ),
      );

      DateTime now = DateTime.now();

      // Assign TimeOfDay to DateTime
      DateTime startAt = DateTime(
          now.year,
          now.month,
          now.day,
          queue.transactionData!.consultationSchedule!.startAt!.hour,
          queue.transactionData!.consultationSchedule!.startAt!.minute);
      DateTime endAt = DateTime(now.year, now.month, now.day, queue.transactionData!.consultationSchedule!.endAt!.hour,
          queue.transactionData!.consultationSchedule!.endAt!.minute);

      Map<String, dynamic> dataSchedule = {
        'day_schedule': queue.transactionData!.consultationSchedule!.daySchedule!.toJson(),
        // Format the value to 00:00 PM, so we can get the data later as TimeOfDay
        'start_at': DateFormat("hh:mm a").format(startAt),
        'end_at': DateFormat("hh:mm a").format(endAt),
        'price': queue.transactionData!.consultationSchedule!.price,
      };

      Map<String, dynamic> transactionData = {
        'doc_id': queue.transactionData!.docId,
        'doctor_profile': queue.transactionData!.doctorProfile!.toJson(),
        'consultation_schedule': dataSchedule,
        'status': queue.transactionData!.status,
        'proof_payment': queue.transactionData!.paymentProof,
        'created_at': Timestamp.fromDate(queue.transactionData!.createdAt),
        'created_by': queue.transactionData!.createdBy!.toJson(),
      };

      Map<String, dynamic> queueData = {
        'doc_id': queue.docId,
        'transaction_data': transactionData,
        'queue_number': queue.queueNumber,
        'is_done': false,
        'created_at': Timestamp.fromDate(queue.createdAt),
      };

      Map<String, dynamic> data = {
        'queue_data': queueData,
        // If diagnosis is null, "" will be assigned
        'diagnosis': diagnosis ?? "",
        'created_at': Timestamp.now(),
      };

      // Add diagnosis to user subCollection
      await Provider.of<DiagnosisProvider>(context, listen: false)
          .addDiagnosis(data, queue.transactionData!.createdBy!.uid);

      // Refresh queue data
      await Provider.of<QueueProvider>(context, listen: false).get7Queue(queue.transactionData!.doctorProfile!.uid);
      await Provider.of<QueueProvider>(context, listen: false).getAllQueue(queue.transactionData!.doctorProfile!.uid);
    }
  }
}
