part of '../pages.dart';

class ListDoctorTransaction extends StatefulWidget {
  const ListDoctorTransaction({Key? key}) : super(key: key);
  @override
  _ListDoctorTransactionState createState() => _ListDoctorTransactionState();
}

class _ListDoctorTransactionState extends State<ListDoctorTransaction> {
  bool _isLoading = false;

  int success = 0;
  int failed = 0;
  int pending = 0;

  double earning = 0.0;

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  final List<TransactionModel> _searchResult = [];
  List<TransactionModel> successList = [];

  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (value.listTransaction.isEmpty) {
              return const Center(
                child: Text("You never done any transaction"),
              );
            }

            earning = 0;

            // Get total of success transaction
            success = value.listTransaction.where((element) => element.status == 'Success').length;

            // Get total of failed transaction
            failed = value.listTransaction.where((element) => element.status == 'Failed').length;

            // Get total of pending transaction
            pending = value.listTransaction.where((element) => element.status == 'Waiting for Payment' || element.status == 'Waiting for Confirmation').length;

            // Get all success transaction
            successList = value.listTransaction.where((element) => element.status == 'Success').toList();

            // Calculating earning from success transaction
            successList.map((e) => earning += e.consultationSchedule!.price!).toSet();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Danh sách giao dịch",
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

                                await _downloadData(
                                  value.listTransaction,
                                  success,
                                  failed,
                                  pending,
                                  earning,
                                );

                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              color: AppTheme.primaryColor,
                              textColor: Colors.white,
                              child: const Text("Download List"),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildRichText(
                                  status: "Hoàn Tất",
                                  textColor: AppTheme.secondaryColor,
                                  total: success,
                                ),
                                const SizedBox(height: 4),
                                buildRichText(
                                  status: "Thất Bại",
                                  textColor: AppTheme.dangerColor,
                                  total: failed,
                                ),
                                const SizedBox(height: 4),
                                buildRichText(
                                  status: "Đang chờ",
                                  textColor: AppTheme.darkerPrimaryColor,
                                  total: pending,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text("Doanh thu"),
                                const SizedBox(height: 8),
                                Text(
                                  "\$${NumberFormat("#,###").format(earning)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {},
                      ),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              _focusNode.unfocus();
                              _searchResult.clear();
                              _isEmpty = false;
                            });
                          }),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      hintText: "Search transaction by status",
                    ),
                    onChanged: (query) {
                      if (query.isEmpty || query == "") {
                        setState(() {
                          _searchResult.clear();
                          _isEmpty = false;
                        });
                        return;
                      }

                      _searchResult.clear();

                      for (var element in value.listTransaction) {
                        if (element.status!.contains(query)) {
                          setState(() {
                            _searchResult.add(element);
                            _isEmpty = false;
                            return;
                          });
                        }
                      }

                      if (_searchResult.isEmpty) {
                        setState(() {
                          _isEmpty = true;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _isEmpty
                      ? const Center(
                          child: Text("Search result is empty"),
                        )
                      : Expanded(
                          child: _searchResult.isNotEmpty && _controller.text.isNotEmpty
                              ? ListView.builder(
                                  itemBuilder: (context, index) {
                                    final item = _searchResult.toSet().toList()[index];

                                    return _transactionCard(item);
                                  },
                                  itemCount: _searchResult.toSet().length,
                                  shrinkWrap: true,
                                )
                              : ListView.builder(
                                  itemCount: value.listTransaction.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final item = value.listTransaction[index];

                                    return _transactionCard(item);
                                  },
                                ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _transactionCard(TransactionModel item) {
    return Card(
      elevation: 4,
      child: InkWell(
        splashColor: AppTheme.primaryColor.withAlpha(30),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DoctorTransactionDetail(transaction: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Transaction ID #${item.docId}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      DateFormat("dd MMMM yyyy").format(item.createdAt),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tổng : ",
                  ),
                  Text(
                    "\$${NumberFormat("#,###").format(item.consultationSchedule!.price)}",
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trạng Thái : ",
                  ),
                  StatusText(text: item.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildRichText({String? status, Color? textColor, int? total}) {
    return RichText(
      text: TextSpan(children: [
        const TextSpan(
          text: "Transaction ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: " $status ",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        TextSpan(
          text: " : $total",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ]),
    );
  }

  _downloadData(
    List<TransactionModel> data,
    int success,
    int failed,
    int pending,
    double earning,
  ) async {
    var status = await Permission.storage.status;
    // Checking if storage permission are granted, if not then request the permission
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
            child: pw.Text('Transaction Report', style: pw.Theme.of(context).header3),
          );
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headers: <String>[
                'No',
                'Transaction ID',
                'Sub Total',
                'Status',
                'Created at',
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
                    '${data[i].docId}',
                    '\$${data[i].consultationSchedule!.price}',
                    '${data[i].status}',
                    (DateFormat("dd MMMM yyyy").format(data[i].createdAt)),
                  ],
              ]),
          pw.Paragraph(text: ""),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text("Total Transaction : ${data.length}"),
            pw.Text("Earning : \$${NumberFormat("#,###").format(earning)},-"),
          ]),
          pw.Paragraph(
            text: "Transaction Success : $success",
            textAlign: pw.TextAlign.right,
          ),
          pw.Paragraph(
            text: "Transaction Failed : $failed",
            textAlign: pw.TextAlign.right,
          ),
          pw.Paragraph(
            text: "Transaction Pending : $pending",
            textAlign: pw.TextAlign.right,
          ),
          pw.Padding(padding: const pw.EdgeInsets.all(10)),
        ],
      ),
    );

    // Get ApplicationDocumentsDirectory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = appDocDir.path;

    // File name and path
    final file = File("$path/doctor_transaction_report_${DateTime.now().toString()}.pdf");

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
