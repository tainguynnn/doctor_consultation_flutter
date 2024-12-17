part of '../pages.dart';

class ListDoctorQueue extends StatefulWidget {
  const ListDoctorQueue({Key? key}) : super(key: key);
  @override
  _ListDoctorQueueState createState() => _ListDoctorQueueState();
}

class _ListDoctorQueueState extends State<ListDoctorQueue> {
  bool _isLoading = false;

  @override
  void initState() {
    Provider.of<QueueProvider>(context, listen: false).getAllQueue(
      Provider.of<DoctorProvider>(context, listen: false).doctor!.uid,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<QueueProvider>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (value.listAllQueue.isEmpty) {
            return const Center(
              child: Text("There's no queue today"),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const Toolbar(),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Danh sách hàng chờ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : MaterialButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              await _downloadData(value.listAllQueue);

                              setState(() {
                                _isLoading = false;
                              });
                            },
                            child: const Text("Download List"),
                            color: AppTheme.primaryColor,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: value.listAllQueue.length,
                    itemBuilder: (context, index) {
                      final item = value.listAllQueue[index];

                      return _queueCard(item);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _downloadData(List<Queue> data) async {
    var status = await Permission.storage.status;

    // Checking if storage permission are granted, if not then request the permission
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat:
            PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            child: pw.Text('Queue Report', style: pw.Theme.of(context).header3),
          );
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headers: <String>[
                'No',
                'Name',
                'Phone Number',
                'Queue Number',
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#FFF'),
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(AppTheme.primaryInt),
              ),
              headerAlignment: pw.Alignment.centerLeft,
              data: <List<String>>[
                for (int i = 0; i < data.length; i++)
                  <String>[
                    '${i + 1}',
                    '${data[i].transactionData!.createdBy!.name}',
                    '${data[i].transactionData!.createdBy!.phoneNumber}',
                    '${data[i].queueNumber}',
                  ],
              ]),
          pw.Paragraph(text: ""),
          pw.Paragraph(
              text: "Total Queue : ${data.length}",
              textAlign: pw.TextAlign.right),
          pw.Padding(padding: const pw.EdgeInsets.all(10)),
        ],
      ),
    );

    // Get ApplicationDocumentsDirectory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = appDocDir.path;

    // File name and path
    final file = File("$path/queue_report_${DateTime.now().toString()}.pdf");

    // Saving file as pdf
    await file.writeAsBytes(await pdf.save()).whenComplete(
          () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Downloaded at ${file.path}"),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: "Open",
                onPressed: () async => await OpenFile.open(file.path),
              ),
            ),
          ),
        );
  }

  _queueCard(Queue item) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditQueue(queue: item),
            ));
          },
          leading: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey,
            backgroundImage: item.transactionData!.createdBy!.profileUrl != ""
                ? NetworkImage(item.transactionData!.createdBy!.profileUrl!)
                : null,
            child: item.transactionData!.createdBy!.profileUrl != ""
                ? null
                : const Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${item.transactionData!.createdBy!.name}"),
            ],
          ),
          isThreeLine: true,
          subtitle: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    Text(
                        "Số điện thoại : ${item.transactionData!.createdBy!.phoneNumber}"),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        "${item.transactionData!.consultationSchedule!.startAt!.format(context)} - ${item.transactionData!.consultationSchedule!.endAt!.format(context)}",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppTheme.darkerPrimaryColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        DateFormat("EEE, dd MMMM yyyy").format(item.createdAt),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    MaterialButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConsultationPage(
                              queue: item,
                            ),
                          ),
                        );
                      },
                      color: AppTheme.primaryColor,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text("Bắt đầu tư vấn"),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "${item.queueNumber}",
                    style: const TextStyle(
                      fontSize: 28,
                      color: AppTheme.darkerPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
