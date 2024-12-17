part of '../pages.dart';

class BottomNavigationBarDoctor extends StatefulWidget {
  const BottomNavigationBarDoctor({Key? key}) : super(key: key);

  @override
  _BottomNavigationBarDoctorState createState() => _BottomNavigationBarDoctorState();
}

class _BottomNavigationBarDoctorState extends State {
  int _selectedIndex = 1;

  final _buildScreens = [
    const ListDoctorTransaction(),
    const MainPageDoctor(),
    const DoctorProfile(),
  ];

  @override
  void initState() {
    Future.microtask(() {
      String doctorId = context.read<DoctorProvider>().doctor!.uid!;
      context.read<TransactionProvider>().getAllTransaction(true, doctorId);
      context.read<QueueProvider>().get7Queue(doctorId);
      context.read<PatientProvider>().get7Patient(doctorId);
    });
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreens[_selectedIndex],
      bottomNavigationBar: SnakeNavigationBar.color(
        behaviour: SnakeBarBehaviour.floating,
        currentIndex: _selectedIndex,
        elevation: 4,
        padding: const EdgeInsets.all(12),
        snakeViewColor: AppTheme.primaryColor,
        selectedItemColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        snakeShape: SnakeShape.circle,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_rounded),
            label: 'Transaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_accessibility_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
