part of '../pages.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Size size;
  double height = 0;
  double width = 0;

  UserModel? currentUser;

  @override
  void initState() {
    Future.microtask(() {
      setState(() {
        currentUser = context.read<UserProvider>().user!;
        size = MediaQuery.of(context).size;
        height = size.height;
        width = size.width;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Xin Chào, ${currentUser?.name ?? 'Loading...'}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileUser(),
                        ),
                      );
                    },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey,
                        backgroundImage: currentUser?.profileUrl != "" && currentUser?.profileUrl != null
                            ? NetworkImage(currentUser?.profileUrl ?? 'https://i.pravatar.cc/50')
                            : null,
                        child: currentUser?.profileUrl != "" && currentUser?.profileUrl != null
                            ? null
                            : const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                Image.asset("assets/homepage.png"),
                const SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text(
                      "Lịch bác sĩ hôm nay",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Consumer<DoctorProvider>(
                  builder: (context, value, child) {
                    if (value.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (value.listDoctor.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("không có bác sĩ khả dụng hôm nay"),
                      );
                    }

                    return SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: value.listDoctor.length,
                        itemBuilder: (context, index) {
                          final item = value.listDoctor[index];
                          final itemKonsultasi = item.consultationSchedule
                              .where((element) => element.daySchedule!.intValue == DateTime.now().weekday)
                              .first;

                          return _doctorCard(item, itemKonsultasi, context);
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text(
                      "Bác sĩ chuyên khoa",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.start,
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  height: 140,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDoctorSpecialist(
                          specialist: "General practitioners",
                          imgAsset: 'assets/general_practitioners.png',
                        ),
                        _buildDoctorSpecialist(
                          specialist: "Surgeon",
                          imgAsset: 'assets/surgeon.png',
                        ),
                        _buildDoctorSpecialist(
                          specialist: "Nha Sĩ",
                          imgAsset: 'assets/dentist.png',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4.0,
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListDiagnosisUser(),
                        ),
                      );
                    },
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(Icons.receipt, color: Colors.white),
                    ),
                    title: const Text("Chẩn Đoán của bạn"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _doctorCard(DataDoctor item, ConsultationSchedule itemKonsultasi, BuildContext context) {
    return Container(
      height: 146,
      margin: const EdgeInsets.only(bottom: 10, right: 8),
      child: Card(
        elevation: 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 8,
            ),
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey,
              backgroundImage: item.doctor.profileUrl != "" ? NetworkImage(item.doctor.profileUrl!) : null,
              child: item.doctor.profileUrl != ""
                  ? null
                  : const Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
            ),
            Container(
              margin: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${item.doctor.name}"),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${item.doctor.specialist}",
                    style:
                        const TextStyle(color: AppTheme.darkerPrimaryColor, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "\$${NumberFormat("#,###").format(itemKonsultasi.price)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 11,
                  ),
                  item.doctor.isBusy!
                      ? Container(
                          height: 25,
                          width: 121,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppTheme.warningColor,
                          ),
                          child: const Center(
                            child: Text(
                              "Đang làm việc",
                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                            ),
                          ),
                        )
                      : item.isBooked
                          ? Container(
                              height: 25,
                              width: 121,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppTheme.dangerColor,
                              ),
                              child: const Center(
                                child: Text(
                                  "đã đặt",
                                  style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                              ),
                            )
                          : Container(
                              height: 25,
                              width: 121,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppTheme.primaryColor,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ConsultationDetail(
                                        dataDoctor: item,
                                      ),
                                    ),
                                  );
                                },
                                child: const Center(
                                  child: Text(
                                    "đặt",
                                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildDoctorSpecialist({required String specialist, required String imgAsset}) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 115,
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ListDoctorSpecialist(specialist: specialist),
            ));
          },
          child: Column(
            children: [
              Image.asset(
                imgAsset,
                height: 73,
                width: 68,
              ),
              Text(
                specialist,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
