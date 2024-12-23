part of '../pages.dart';

class AddConsultationSchedule extends StatefulWidget {
  const AddConsultationSchedule({Key? key}) : super(key: key);

  @override
  _AddConsultationScheduleState createState() =>
      _AddConsultationScheduleState();
}

class _AddConsultationScheduleState extends State<AddConsultationSchedule> {
  final List<DaySchedule> _day = [
    DaySchedule(
      'Thứ hai',
      1,
    ),
    DaySchedule(
      'Thứ ba',
      2,
    ),
    DaySchedule(
      'Thứ tư',
      3,
    ),
    DaySchedule(
      'Thứ năm',
      4,
    ),
    DaySchedule(
      'Thứ sáu',
      5,
    ),
    DaySchedule(
      'Thứ bảy',
      6,
    ),
    DaySchedule(
      'Chủ nhật',
      7,
    ),
  ];

  DaySchedule? _selectedDay;

  TimeOfDay? _startTime;
  late TimeOfDay _endTime;

  final TextEditingController _txtPrice = TextEditingController();
  final FocusNode _fnPrice = FocusNode();

  bool _isLoading = false;

  _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      if (pickedTime.hour == 23 && pickedTime.minute >= 29) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng chọn thời gian tư vấn trước 23:59"),
            duration: Duration(seconds: 7),
            dismissDirection: DismissDirection.horizontal,
          ),
        );
        return;
      }
      setState(() {
        _startTime = pickedTime;
        pickedTime.minute >= 30
            ? _endTime = pickedTime.replacing(
                hour: pickedTime.hour + 1,
                minute: pickedTime.minute - 30,
              )
            : _endTime = pickedTime.replacing(
                hour: pickedTime.hour,
                minute: pickedTime.minute + 30,
              );
      });
    }
  }

  @override
  void initState() {
    _selectedDay = _day.firstWhere((element) => element.intValue == 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Toolbar(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: const Center(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Thêm lịch tư vấn",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.darkerPrimaryColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 18.0),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text("Chọn ngày"),
                                const SizedBox(height: 4.0),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: DropdownButton<DaySchedule>(
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      value: _selectedDay,
                                      items: generateItems(_day),
                                      onChanged: (item) {
                                        setState(() {
                                          _selectedDay = item;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12.0),
                                const Text("thời gian"),
                                const SizedBox(height: 4.0),
                                MaterialButton(
                                  color: AppTheme.secondaryColor,
                                  textColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  onPressed: () async =>
                                      await _selectTime(context),
                                  child: _startTime != null
                                      ? Text(
                                          "${_startTime!.format(context)} - ${_endTime.format(context)}")
                                      : const Text("chọn thời gian"),
                                ),
                                const SizedBox(height: 12.0),
                                const Text("giá"),
                                const SizedBox(height: 4.0),
                                TextFormField(
                                  focusNode: _fnPrice,
                                  controller: _txtPrice,
                                  maxLength: 16,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    NumericTextFormatter(),
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    filled: true,
                                    counterText: "",
                                    fillColor: Colors.white,
                                    hintText: 'giá',
                                    errorStyle: const TextStyle(
                                      color: Colors.amber,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'hãy điền mọi trường';
                                    }

                                    return null;
                                  },
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                                const SizedBox(height: 22.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          )
                                        : MaterialButton(
                                            onPressed: () async {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              await _addJadwal();
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            },
                                            child: const Text("Thêm"),
                                            color:
                                                AppTheme.lighterSecondaryColor,
                                            textColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DropdownMenuItem<DaySchedule>> generateItems(List<DaySchedule> days) {
    List<DropdownMenuItem<DaySchedule>> items = [];
    for (var day in days) {
      items.add(
        DropdownMenuItem(
          child: Text("${day.day}"),
          value: day,
        ),
      );
    }
    return items;
  }

  _addJadwal() async {
    NumberFormat format = NumberFormat();

    if (_startTime == null || _txtPrice.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("hãy điền giá trị"),
        ),
      );
      return;
    }

    DateTime now = DateTime.now();

    // Assign TimeOfDay to DateTime
    DateTime startAt = DateTime(
        now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);

    DateTime endAt =
        DateTime(now.year, now.month, now.day, _endTime.hour, _endTime.minute);

    Map<String, dynamic> data = {
      'day_schedule': _selectedDay!.toJson(),
      // Format the value to 00:00 PM, so we can get the data later as TimeOfDay
      'start_at': DateFormat("hh:mm a").format(startAt),
      'end_at': DateFormat("hh:mm a").format(endAt),
      // Parse the price, removing , (coma)
      'price': format.parse(_txtPrice.text),
    };

    await Provider.of<ConsultationScheduleProvider>(context, listen: false)
        .addConsultationSchedule(
      data,
      Provider.of<DoctorProvider>(context, listen: false).doctor!.uid,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Success adding new constulation schedule"),
      ),
    );

    Navigator.of(context).pop();
  }
}
