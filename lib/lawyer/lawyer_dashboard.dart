import 'package:flutter/material.dart';
import 'dart:async';

// --- Entry Point ---

// --- App Configuration ---
class NyaayDrishtiLawyerApp extends StatelessWidget {
  const NyaayDrishtiLawyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyaay-Drishti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Navy Blue Theme
        primaryColor: const Color(0xFF1E3A8A), // Navy Blue
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Light Grey/White
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFDC2626), // Red for alerts
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E3A8A), // Navy Text
          elevation: 1,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// --- Models ---
class CaseModel {
  final String id;
  final String title;
  final String type;
  final String status; // 'Active', 'Listed', 'Defective', 'Under Scrutiny'
  final int? itemNo;
  final int? currentItem;
  final String? courtroom;
  final String nextHearing;
  final int defects;

  CaseModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.itemNo,
    this.currentItem,
    this.courtroom,
    required this.nextHearing,
    this.defects = 0,
  });
}

// --- Mock Data ---
final List<CaseModel> mockCases = [
  CaseModel(
    id: 'NY-2024-001',
    title: 'Sharma vs. State',
    type: 'Bail App',
    status: 'Active',
    itemNo: 15,
    currentItem: 2,
    courtroom: '4',
    nextHearing: 'Today',
    defects: 0,
  ),
  CaseModel(
    id: 'NY-2024-002',
    title: 'Verma Industries vs. ROC',
    type: 'Corporate',
    status: 'Defective',
    nextHearing: 'Pending',
    defects: 1,
  ),
  CaseModel(
    id: 'NY-2024-003',
    title: 'Singh vs. Singh',
    type: 'Civil Writ',
    status: 'Listed',
    itemNo: 45,
    courtroom: '2',
    nextHearing: 'Tomorrow',
    defects: 0,
  ),
  CaseModel(
    id: 'NY-2024-004',
    title: 'Tech Corp vs. State',
    type: 'IPR',
    status: 'Under Scrutiny',
    nextHearing: 'TBD',
    defects: 0,
  ),
];

// --- Main Screen (Scaffold & Nav) ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Views for bottom nav
  final List<Widget> _views = [
    const DashboardView(),
    const PlaceholderView(title: "Daily Cause List"),
    const PlaceholderView(title: "My Filings Archive"),
    const PlaceholderView(title: "Lawyer Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A. The AppBar
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Text(
              'RK',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        title: const Text(
          'Nyaay-Drishti',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
        ),
        actions: [
          // SOS / Help
          IconButton(
            icon: const Icon(Icons.support_agent_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          // Notification Bell
          const NotificationBell(),
          const SizedBox(width: 8),
        ],
      ),
      body: _views[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Cause List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: 'My Filings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- Dashboard View ---
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic: Find today's hearing
    final liveCase = mockCases.firstWhere(
      (c) => c.nextHearing == 'Today',
      orElse: () => mockCases[0], // Fallback for demo
    );

    final hasDefects = mockCases.any((c) => c.status == 'Defective');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // B. The "Live Passenger" Ticket
          if (liveCase.nextHearing == 'Today') ...[
            LiveHearingTicket(caseData: liveCase),
            const SizedBox(height: 24),
          ],

          // C. The "Action Center"
          const SectionHeader(title: "Action Center"),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              // Button 1: Instant Filing
              _buildActionCard(
                context,
                title: 'Instant Filing',
                subtitle: 'New Petition',
                icon: Icons.upload_file,
                isPrimary: true,
                onTap: () {
                  // Navigate to file picker
                },
              ),
              // Button 2: Cure Defects (Conditional)
              if (hasDefects)
                _buildActionCard(
                  context,
                  title: 'Cure Defects',
                  subtitle: '1 Scrutiny Error',
                  icon: Icons.warning_amber_rounded,
                  isPrimary: false,
                  isAlert: true,
                  onTap: () {
                    // Navigate to scrutiny comments
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),

          // D. "My Filings" List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(title: "Recent Activity"),
              TextButton(
                onPressed: () {},
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockCases.length,
            itemBuilder: (context, index) {
              final item = mockCases[index];
              return CaseListCard(caseData: item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
    bool isAlert = false,
    required VoidCallback onTap,
  }) {
    final bgColor = isPrimary ? Theme.of(context).primaryColor : Colors.white;
    final textColor = isPrimary
        ? Colors.white
        : (isAlert ? Colors.red[700] : Colors.black87);
    final borderColor = isAlert ? Colors.red : Colors.transparent;

    return Material(
      color: bgColor,
      elevation: isPrimary ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: isAlert ? 2 : 0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withOpacity(0.1)
                      : (isAlert ? Colors.red[50] : Colors.grey[100]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : textColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isPrimary
                      ? Colors.blue[100]
                      : (isAlert ? Colors.red[300] : Colors.grey),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget: Live Hearing Ticket ---
class LiveHearingTicket extends StatefulWidget {
  final CaseModel caseData;
  const LiveHearingTicket({super.key, required this.caseData});

  @override
  State<LiveHearingTicket> createState() => _LiveHearingTicketState();
}

class _LiveHearingTicketState extends State<LiveHearingTicket> {
  bool _isRippling = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate delayed ripple effect from "Court Master"
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() => _isRippling = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _isRippling = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate wait time (Mock)
    final waitTime =
        ((widget.caseData.itemNo ?? 0) - (widget.caseData.currentItem ?? 0)) *
        10;
    final hours = waitTime ~/ 60;
    final minutes = waitTime % 60;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Blue Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.caseData.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'COURTROOM ${widget.caseData.courtroom}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.caseData.type,
                          style: TextStyle(
                            color: Colors.blue[100],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Decorative icon
                Icon(
                  Icons.gavel,
                  color: Colors.white.withOpacity(0.2),
                  size: 32,
                ),
              ],
            ),
          ),

          // Middle & Bottom Rows (Ticket Body)
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.caseData.itemNo}',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                height: 1,
                              ),
                            ),
                            const Text(
                              'YOUR ITEM #',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '#${widget.caseData.currentItem}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              'RUNNING NOW',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // The Calculation / Ripple Area
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isRippling ? Colors.red[50] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isRippling
                              ? Colors.red.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isRippling ? 'DELAY UPDATE' : 'EST. WAIT TIME',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _isRippling
                                      ? Colors.red
                                      : Colors.blue[800],
                                ),
                              ),
                              Text(
                                '~ ${hours > 0 ? '$hours hr ' : ''}$minutes mins',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isRippling
                                      ? Colors.red[900]
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.access_time_filled,
                            color: _isRippling
                                ? Colors.red
                                : Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Dashed Line decoration (simulated)
              Positioned(
                top: 0,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(
                    20,
                    (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(height: 2, color: Colors.grey[200]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Widget: Case List Card ---
class CaseListCard extends StatelessWidget {
  final CaseModel caseData;
  const CaseListCard({super.key, required this.caseData});

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusText;
    String statusLabel = caseData.status;

    switch (caseData.status) {
      case 'Listed':
        statusBg = Colors.green[50]!;
        statusText = Colors.green[700]!;
        break;
      case 'Under Scrutiny':
        statusBg = Colors.orange[50]!;
        statusText = Colors.orange[800]!;
        break;
      case 'Defective':
        statusBg = Colors.red[50]!;
        statusText = Colors.red[700]!;
        break;
      default:
        statusBg = Colors.blue[50]!;
        statusText = Colors.blue[700]!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.article_outlined, color: Colors.grey),
        ),
        title: Text(
          caseData.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${caseData.type} • ${caseData.id}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusLabel.toUpperCase(),
                style: TextStyle(
                  color: statusText,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (caseData.nextHearing != 'Pending' &&
                caseData.nextHearing != 'TBD')
              Text(
                'Next: ${caseData.nextHearing}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Widget: Notification Bell ---
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        Positioned(
          top: 10,
          right: 10,
          child: FadeTransition(
            opacity: _controller,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Helpers ---
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: Colors.grey[500],
      ),
    );
  }
}

class PlaceholderView extends StatelessWidget {
  final String title;
  const PlaceholderView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
