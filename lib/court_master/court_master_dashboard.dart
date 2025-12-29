import 'package:flutter/material.dart';
import 'dart:async';

class CourtMasterDashboard extends StatefulWidget {
  const CourtMasterDashboard({super.key});

  @override
  State<CourtMasterDashboard> createState() => _CourtMasterDashboardState();
}

class _CourtMasterDashboardState extends State<CourtMasterDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  Timer? _clockTimer;
  Timer? _caseTimer;
  String _currentTime = '';
  int _caseTimeRemaining = 900; // 15 minutes in seconds
  bool _isTimerRunning = true;
  String _courtStatus = 'Running'; // Running, Delayed, Closed
  bool _showRippleEffect = false;

  // Mock data for current case
  Map<String, dynamic> _currentCase = {
    'itemNo': 15,
    'title': 'Sharma vs. State of UP',
    'type': 'Bail Application',
    'lawyer': 'Adv. Rajesh Kumar',
    'startTime': '11:30 AM',
    'estimatedEnd': '11:45 AM',
  };

  // Mock data for scrutiny inbox
  final List<Map<String, dynamic>> _scrutinyInbox = [
    {
      'id': 'CRL-2024-009',
      'title': 'Patel vs. State',
      'type': 'Bail Application',
      'petitioner': 'Ramesh Patel',
      'filedTime': '09:45 AM',
      'status': 'Under Scrutiny',
      'lawyer': 'Adv. Suresh Patel',
    },
    {
      'id': 'WP-2024-012',
      'title': 'Tech Corp vs. Municipal Corp',
      'type': 'Writ Petition',
      'petitioner': 'Tech Corporation Ltd',
      'filedTime': '10:15 AM',
      'status': 'Under Scrutiny',
      'lawyer': 'Adv. Priya Sharma',
    },
    {
      'id': 'CA-2024-008',
      'title': 'Singh vs. Insurance Co',
      'type': 'Civil Appeal',
      'petitioner': 'Vikram Singh',
      'filedTime': '10:30 AM',
      'status': 'Under Scrutiny',
      'lawyer': 'Adv. Amit Kumar',
    },
  ];

  // Mock data for today's cause list
  List<Map<String, dynamic>> _todaysCases = [
    {
      'itemNo': 1,
      'title': 'Kumar vs. Bank',
      'type': 'Recovery',
      'time': '10:00 AM',
      'status': 'Completed',
      'lawyer': 'Adv. R.K. Sharma',
    },
    {
      'itemNo': 2,
      'title': 'Verma vs. State',
      'type': 'Writ Petition',
      'time': '10:30 AM',
      'status': 'Completed',
      'lawyer': 'Adv. S.P. Singh',
    },
    {
      'itemNo': 15,
      'title': 'Sharma vs. State of UP',
      'type': 'Bail Application',
      'time': '11:30 AM',
      'status': 'Running',
      'lawyer': 'Adv. Rajesh Kumar',
    },
    {
      'itemNo': 16,
      'title': 'Patel vs. Municipal Corp',
      'type': 'PIL',
      'time': '12:00 PM',
      'status': 'Waiting',
      'lawyer': 'Adv. Meera Patel',
    },
    {
      'itemNo': 17,
      'title': 'Singh vs. Employer',
      'type': 'Service Matter',
      'time': '12:30 PM',
      'status': 'Waiting',
      'lawyer': 'Adv. Vikram Singh',
    },
    {
      'itemNo': 18,
      'title': 'Company vs. Director',
      'type': 'Corporate',
      'time': '1:00 PM',
      'status': 'Waiting',
      'lawyer': 'Adv. Anita Gupta',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startClock();
    _startCaseTimer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  void _startClock() {
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _startCaseTimer() {
    _caseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerRunning && _caseTimeRemaining > 0) {
        setState(() {
          _caseTimeRemaining--;
        });
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _clockTimer?.cancel();
    _caseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildControlRoomHeader(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Live Control Board - Most Important Feature
                    _buildLiveControlBoard(),
                    const SizedBox(height: 20),

                    // Scrutiny Inbox and Daily Overview Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildScrutinyInbox()),
                        const SizedBox(width: 20),
                        Expanded(child: _buildDailyCauseListOverview()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Notifications and Alerts
                    _buildNotificationsPanel(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlRoomHeader() {
    Color statusColor = _courtStatus == 'Running'
        ? Colors.green
        : _courtStatus == 'Delayed'
        ? Colors.red
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF2563EB)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.control_camera,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Court Control Room',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Master Dashboard',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currentTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Court $_courtStatus',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Cases Today', '${_todaysCases.length}', Icons.today),
          _buildStatItem(
            'Completed',
            '${_todaysCases.where((c) => c['status'] == 'Completed').length}',
            Icons.check_circle,
          ),
          _buildStatItem(
            'Pending Scrutiny',
            '${_scrutinyInbox.length}',
            Icons.pending_actions,
          ),
          _buildStatItem(
            'Waiting',
            '${_todaysCases.where((c) => c['status'] == 'Waiting').length}',
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLiveControlBoard() {
    final minutes = _caseTimeRemaining ~/ 60;
    final seconds = _caseTimeRemaining % 60;
    final isOvertime = _caseTimeRemaining < 300; // Red when less than 5 minutes

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isTimerRunning ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isOvertime
                    ? [Colors.red[700]!, Colors.red[500]!]
                    : [const Color(0xFF1E3A8A), const Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isOvertime ? Colors.red : const Color(0xFF1E3A8A))
                      .withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isTimerRunning
                              ? Icons.play_circle_filled
                              : Icons.pause_circle_filled,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LIVE CONTROL BOARD',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Item #${_currentCase['itemNo']} - ${_currentCase['title']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${_currentCase['type']} • ${_currentCase['lawyer']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isOvertime ? Colors.white : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOvertime ? 'OVERTIME' : 'RUNNING',
                          style: TextStyle(
                            color: isOvertime ? Colors.red : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer and Controls
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Timer Display
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isOvertime
                              ? Colors.red
                              : const Color(0xFF1E3A8A),
                          height: 1,
                        ),
                      ),
                      Text(
                        isOvertime ? 'OVERTIME' : 'TIME REMAINING',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isOvertime ? Colors.red : Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Control Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _extendTime,
                              icon: const Icon(Icons.add_alarm, size: 18),
                              label: const Text('EXTEND +15m'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _passOverCase,
                              icon: const Icon(Icons.skip_next, size: 18),
                              label: const Text('PASS OVER'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _startNextCase,
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('NEXT CASE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _toggleTimer,
                              icon: Icon(
                                _isTimerRunning
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 18,
                              ),
                              label: Text(_isTimerRunning ? 'PAUSE' : 'RESUME'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isTimerRunning
                                    ? Colors.red
                                    : Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrutinyInbox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.inbox, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'SCRUTINY INBOX',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_scrutinyInbox.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(_scrutinyInbox.length, (index) {
            final caseItem = _scrutinyInbox[index];
            return _buildScrutinyItem(
              caseItem,
              index == _scrutinyInbox.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrutinyItem(Map<String, dynamic> caseData, bool isLast) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseData['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${caseData['type']} • ${caseData['id']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    Text(
                      'Filed: ${caseData['filedTime']} • ${caseData['lawyer']}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectCase(caseData['id']),
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('REJECT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.red[200]!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveCase(caseData['id']),
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('APPROVE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[50],
                    foregroundColor: Colors.green[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.green[200]!),
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

  Widget _buildDailyCauseListOverview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'TODAY\'S CAUSE LIST',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  DateTime.now().toString().split(' ')[0],
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            child: ListView.builder(
              itemCount: _todaysCases.length,
              itemBuilder: (context, index) {
                final caseItem = _todaysCases[index];
                return _buildCauseListItem(
                  caseItem,
                  index == _todaysCases.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCauseListItem(Map<String, dynamic> caseData, bool isLast) {
    Color statusColor;
    Color bgColor;

    switch (caseData['status']) {
      case 'Completed':
        statusColor = Colors.green[700]!;
        bgColor = Colors.green[50]!;
        break;
      case 'Running':
        statusColor = Colors.blue[700]!;
        bgColor = Colors.blue[50]!;
        break;
      default:
        statusColor = Colors.grey[600]!;
        bgColor = Colors.grey[50]!;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: caseData['status'] == 'Running' ? Colors.blue[50] : null,
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Center(
              child: Text(
                '${caseData['itemNo']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseData['title'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  '${caseData['type']} • ${caseData['lawyer']}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                caseData['time'],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  caseData['status'].toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Colors.red[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'LIVE ALERTS & NOTIFICATIONS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (_showRippleEffect)
                  AnimatedBuilder(
                    animation: _rippleAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(
                            alpha: 1.0 - _rippleAnimation.value,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildNotificationItem(
                  'Court Running On Time',
                  'All cases proceeding as scheduled',
                  Icons.check_circle,
                  Colors.green,
                  '2 min ago',
                ),
                const SizedBox(height: 12),
                _buildNotificationItem(
                  '3 Lawyers Waiting',
                  'Items 16, 17, 18 - Lawyers present in court',
                  Icons.people,
                  Colors.blue,
                  '5 min ago',
                ),
                const SizedBox(height: 12),
                _buildNotificationItem(
                  'New Filing Received',
                  'CRL-2024-009 submitted for scrutiny',
                  Icons.file_upload,
                  Colors.orange,
                  '8 min ago',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // Control Actions
  void _extendTime() {
    setState(() {
      _caseTimeRemaining += 900; // Add 15 minutes
      _courtStatus = 'Delayed';
      _showRippleEffect = true;
    });

    _rippleController.forward().then((_) {
      _rippleController.reset();
      setState(() {
        _showRippleEffect = false;
      });
    });

    _showDelayBanner();
    _updateUpcomingCases(15); // Delay all upcoming cases by 15 minutes
  }

  void _passOverCase() {
    setState(() {
      // Move current case to end of list
      final currentCase = _todaysCases.firstWhere(
        (c) => c['status'] == 'Running',
      );
      currentCase['status'] = 'Pass Over';
      _todaysCases.removeWhere((c) => c['status'] == 'Running');
      _todaysCases.add(currentCase);

      // Start next case
      _startNextCase();
    });
  }

  void _startNextCase() {
    setState(() {
      // Mark current as completed
      final runningIndex = _todaysCases.indexWhere(
        (c) => c['status'] == 'Running',
      );
      if (runningIndex != -1) {
        _todaysCases[runningIndex]['status'] = 'Completed';
      }

      // Start next waiting case
      final nextIndex = _todaysCases.indexWhere(
        (c) => c['status'] == 'Waiting',
      );
      if (nextIndex != -1) {
        _todaysCases[nextIndex]['status'] = 'Running';
        _currentCase = _todaysCases[nextIndex];
        _caseTimeRemaining = 900; // Reset to 15 minutes
        _isTimerRunning = true;
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
  }

  void _rejectCase(String caseId) {
    setState(() {
      _scrutinyInbox.removeWhere((c) => c['id'] == caseId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Case $caseId rejected and marked defective'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _approveCase(String caseId) {
    setState(() {
      _scrutinyInbox.removeWhere((c) => c['id'] == caseId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Case $caseId approved and registered'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDelayBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.access_time, color: Colors.white),
            SizedBox(width: 8),
            Text('Court delayed by 15 minutes - All upcoming cases shifted'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _updateUpcomingCases(int delayMinutes) {
    // This would update the estimated times for all upcoming cases
    // For demo purposes, we'll just show the effect
    setState(() {
      for (var caseItem in _todaysCases) {
        if (caseItem['status'] == 'Waiting') {
          // Update estimated times (simplified for demo)
          caseItem['delayed'] = true;
        }
      }
    });
  }
}
