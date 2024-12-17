part of '../pages.dart';

class TransactionDetail extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetail({Key? key, required this.transaction}) : super(key: key);
  @override
  _TransactionDetailState createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  TransactionModel get transaction => widget.transaction;

  File? imageFile;

  bool _isLoading = false;

  bool _isDone = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Transaction ID #${transaction.docId}",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        DateFormat("dd MMMM yyyy").format(transaction.createdAt),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                          "Chi tiết giao dịch",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        buildText("Tên Bác Sĩ", transaction.doctorProfile!.name),
                        const SizedBox(
                          height: 5,
                        ),
                        buildText("Thời gian",
                            "${transaction.consultationSchedule!.startAt!.format(context)} - ${transaction.consultationSchedule!.endAt!.format(context)}"),
                        const SizedBox(
                          height: 5,
                        ),
                        buildText("Số điện thoại", transaction.doctorProfile!.phoneNumber),
                        const SizedBox(
                          height: 5,
                        ),
                        buildText("Tài khoản ngân hàng", transaction.doctorProfile!.bankAccount),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Text("Tổng"),
                            ),
                            Expanded(
                              child: Text(
                                "\$${NumberFormat("#,###").format(transaction.consultationSchedule!.price)}",
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Text("trạng thái"),
                            ),
                            Expanded(
                              child: StatusText(text: transaction.status),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: transaction.status == "Waiting for Payment"
                              ? () async {
                                  final imgSource = await imgSourceDialog();

                                  if (imgSource != null) {
                                    await _pickImage(imgSource);
                                  }
                                }
                              : null,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.28,
                            width: MediaQuery.of(context).size.width * 0.56,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: transaction.paymentProof != ""
                                    ? NetworkImage(transaction.paymentProof!)
                                    : (imageFile == null ? const AssetImage('assets/images.png') : FileImage(imageFile!)) as ImageProvider<Object>,
                                fit: BoxFit.contain,
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1,
                                  offset: Offset(4, 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "* Upload payment proof",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16.0),
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const SizedBox(),
                        transaction.status == "Waiting for Payment" && !_isDone && !_isLoading
                            ? Center(
                                child: MaterialButton(
                                  minWidth: 148,
                                  height: 39,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  color: AppTheme.primaryColor,
                                  child: const Text(
                                    "Confirm Payment",
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    bool konfirmasi = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Are you sure to confirm this payment?"),
                                        content: const Text("You'll be uploading the payment proof, and the doctor will be checking it"),
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
                                      await _confirmPayment();
                                    }

                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          height: 76,
                          width: 339,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: const Color(0xffE0E0E0), borderRadius: BorderRadius.circular(20)),
                          child: const Center(
                            child: Text(
                              "Please wait for the Doctor to contact\nYou via WhatsApp. Make sure your WhatsApp\nalways on!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        MaterialButton(
                          minWidth: 148,
                          height: 39,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          color: AppTheme.darkerPrimaryColor,
                          child: const Text(
                            "Download Invoice",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await _downloadData(context, transaction);
                            setState(() {
                              _isLoading = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _downloadData(BuildContext ctx, TransactionModel data) async {
    var status = await Permission.storage.status;
    // Checking for storage permission, if not granted will be requested
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
            child: pw.Text('Invoice #${data.docId}', style: pw.Theme.of(context).header3),
          );
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headers: <String>[
                'No',
                'Name',
                'Consultation Time',
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
                <String>[
                  '1',
                  'Consultation ${data.doctorProfile!.name} Specialist ${data.doctorProfile!.specialist}',
                  '${data.consultationSchedule!.startAt!.format(ctx)} - ${data.consultationSchedule!.endAt!.format(ctx)}',
                  '\$${NumberFormat("#,###").format(data.consultationSchedule!.price)}'
                ],
              ]),
          pw.Paragraph(text: ""),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text("Transaction Status : ${data.status}"),
              ),
              pw.Expanded(
                child: pw.Text(
                  "Total : \$${NumberFormat("#,###").format(data.consultationSchedule!.price)}",
                ),
              ),
            ],
          ),
          pw.Padding(padding: const pw.EdgeInsets.all(10)),
        ],
      ),
    );

    // Get ApplicationDocumentsDirectory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = appDocDir.path;

    // Filename and path
    final file = File("$path/invoice_${data.docId}.pdf");

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

  buildText(String title, String? text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text(title),
        ),
        Expanded(
          child: Text(
            "$text",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  _confirmPayment() async {
    // Uploading image to firebase storage
    await _updateBuktiPembayaran();

    // Refresh transaction
    await Provider.of<TransactionProvider>(context, listen: false).getAllTransaction(false, transaction.createdBy!.uid);
  }

  imgSourceDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Take Picture From"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Ink(
                decoration: const ShapeDecoration(
                  color: AppTheme.primaryColor,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: const Icon(Icons.photo_camera, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ),
              Ink(
                decoration: const ShapeDecoration(
                  color: AppTheme.primaryColor,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: const Icon(Icons.photo, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            )
          ],
        );
      },
    );
  }

  _pickImage(ImageSource imgSource) async {
    final pickedImage = await ImagePicker().pickImage(source: imgSource);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      await _cropImage();
    }
    return;
  }

  _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile!.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        imageFile = File(croppedFile.path);
      });
    }
  }

  _updateBuktiPembayaran() async {
  if (imageFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please upload payment proof"),
      ),
    );
    return;
  }

  try {
    final dataAuth = FirebaseAuth.instance;
    final user = dataAuth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not authenticated. Please log in again."),
        ),
      );
      return;
    }

    // Get File Name
    String fileName = imageFile!.path.split("/").last;

    // Get Firebase Storage reference
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Payment Proof/${user.uid}/$fileName');

    // Save the image to Firebase Storage
    final dataImage = await ref.putFile(imageFile!);

    // Get the image URL from Firebase Storage
    String photoPath = await dataImage.ref.getDownloadURL();

    // Confirm Payment
    await Provider.of<TransactionProvider>(context, listen: false).confirmPayment(
      transaction.docId,
      transaction.doctorProfile!.uid,
      photoPath,
      transaction.createdBy!.uid,
    );

    if (mounted) {
      setState(() {
        _isDone = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Confirmation Complete"),
        ),
      );
      Navigator.of(context).pop(); // Pop the current screen after success
    }
  } on firebase_storage.FirebaseException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Upload failed: ${e.message}"),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: ${e.toString()}"),
      ),
    );
  }
}

}
