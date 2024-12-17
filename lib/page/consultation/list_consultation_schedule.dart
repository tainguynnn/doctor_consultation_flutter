part of '../pages.dart';

class ListConsultationSchedule extends StatefulWidget {
  const ListConsultationSchedule({Key? key}) : super(key: key);

  @override
  _ListConsultationScheduleState createState() => _ListConsultationScheduleState();
}

class _ListConsultationScheduleState extends State<ListConsultationSchedule> {
  bool _isLoading = false;

  @override
  void initState() {
    Provider.of<ConsultationScheduleProvider>(context, listen: false)
        .getListConsultationSchedule(Provider.of<DoctorProvider>(context, listen: false).doctor!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ConsultationScheduleProvider>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (value.listConsultationSchedule.isEmpty) {
            return const Center(
              child: Text("Your consultation schedule is empty, start to create one"),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: [
              const Toolbar(),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Lịch tư vấn",
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

                            await _downloadData(context, value.listConsultationSchedule);

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
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: value.listConsultationSchedule.length,
                  itemBuilder: (context, index) {
                    final item = value.listConsultationSchedule[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ConsultationScheduleDetail(
                                  schedule: item,
                                ),
                              ),
                            );
                          },
                          leading: const Icon(Icons.schedule, color: AppTheme.primaryColor),
                          title: Text("${item.daySchedule!.day}"),
                          isThreeLine: true,
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Time : ${item.startAt!.format(context)} - ${item.endAt!.format(context)}",
                              ),
                              Text(
                                "Price: \$${NumberFormat("#,###").format(item.price)}",
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.navigate_next),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  _downloadData(BuildContext ctx, List<ConsultationSchedule> data) async {
    var status = await Permission.storage.status;
    // Checking if storage permission granted, if not request one
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            child: pw.Text('Consultation Schedule Report', style: pw.Theme.of(context).header3),
          );
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headers: <String>[
                'No',
                'Day',
                'Time',
                'Price',
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
                    '${data[i].daySchedule!.day}',
                    '${data[i].startAt!.format(ctx)} - ${data[i].endAt!.format(ctx)}',
                    '\$${NumberFormat("#,###").format(data[i].price)}',
                  ],
              ]),
          pw.Paragraph(text: ""),
          pw.Paragraph(text: "Total Consultation Schedule : ${data.length}", textAlign: pw.TextAlign.right),
          pw.Padding(padding: const pw.EdgeInsets.all(10)),
        ],
      ),
    );

    // Get ApplicationDocumentsDirectory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = appDocDir.path;

    // Filename and path
    final file = File("$path/consultation_schedule_report${DateTime.now().toString()}.pdf");

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
}
