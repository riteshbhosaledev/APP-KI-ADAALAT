import 'package:flutter/material.dart';

class CauseListScreen extends StatefulWidget {
  const CauseListScreen({super.key});

  @override
  State<CauseListScreen> createState() => _CauseListScreenState();
}

class _CauseListScreenState extends State<CauseListScreen> {
  String _selectedDate = 'Today';
  final List<String> _dateOptions = ['Today', 'Tomorrow', 'This Week'];

  // Mock data for today's cause list
  final List<Map<String, dynamic>> _todaysCases = [
    {
      'itemNo': 1,
      'title': 'Kumar vs. Bank of India',
      'type': 'Recovery Suit',
      'time': '10:00 AM',
      'status': 'Completed',
      'lawyer': 'Adv. R.K. Sharma',
      'duration': '25 min',
      'courtroom': 'Court 1',
    },
    {
      'itemNo': 2,
      'title': 'Verma vs. State of UP',
      'type': 'Writ Petition',
      'time': '10:30 AM',
      'status': 'Completed',
      'lawyer': 'Adv. S.P. Singh',
      'duration': '18 min',
      'courtroom': 'Court 1',
    },
    {
      'itemNo': 15,
      'title': 'Sharma vs. State of UP',
      'type': 'Bail Application',
      'time': '11:30 AM',
      'status': 'Running',
      'lawyer': 'Adv. Rajesh Kumar',
      'duration': '12 min',
      'courtroom': 'Court 1',
    },
    {
      'itemNo': 16,
      'title': 'Patel vs. Municipal Corporation',
      'type': 'PIL',
      'time': '12:00 PM',
      'status': 'Waiting',
      'lawyer': 'Adv. Meera Patel',
      'duration': 'Est. 20 min',
      'courtroom': 'Court 1',
    },
    {
      'itemNo': 17,
      'title': 'Singh vs. Employer Ltd',
      'type': 'Service Matter',
      'time': '12:30 PM',
      'status': 'Waiting',
      'lawyer': 'Adv. Vikram Singh',
      'duration': 'Est. 15 min',
      'courtroom': 'Court 1',
    },
    {
      'itemNo': 18,
      'title': 'ABC Company vs. Director',
      'type': 'Corporate Dispute',
      'time': '1:00 PM',
      'status': 'Waiting',
      'lawyer': 'Adv. Anita Gupta',
      'duration': 'Est. 30 min',
      'courtroom': 'Court 1',
    },
    {
      'itemNo': 19,
      'title': 'Gupta vs. Insurance Co',
      'type': 'Motor Accident',
      'time': '2:00 PM',
      'status': 'Waiting',
      'lawyer': 'Adv. Rohit Gupta',
      'duration': 'Est. 25 min',
      'courtroom': 'Court 1',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cause List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_todaysCases.length} Cases',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildSummaryCards(),
          Expanded(child: _buildCasesList()),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFF1E3A8A), size: 20),
          const SizedBox(width: 12),
          const Text(
            'Select Date:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _dateOptions.map((date) {
                  final isSelected = _selectedDate == date;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[700] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue[700]!
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final completed = _todaysCases
        .where((c) => c['status'] == 'Completed')
        .length;
    final running = _todaysCases.where((c) => c['status'] == 'Running').length;
    final waiting = _todaysCases.where((c) => c['status'] == 'Waiting').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Completed',
              completed.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Running',
              running.toString(),
              Icons.play_circle,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Waiting',
              waiting.toString(),
              Icons.access_time,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCasesList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                const Text(
                  'TODAY\'S SCHEDULE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  DateTime.now().toString().split(' ')[0],
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todaysCases.length,
              itemBuilder: (context, index) {
                return _buildCaseItem(
                  _todaysCases[index],
                  index == _todaysCases.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseItem(Map<String, dynamic> caseData, bool isLast) {
    Color statusColor;
    Color bgColor;
    IconData statusIcon;

    switch (caseData['status']) {
      case 'Completed':
        statusColor = Colors.green[700]!;
        bgColor = Colors.green[50]!;
        statusIcon = Icons.check_circle;
        break;
      case 'Running':
        statusColor = Colors.blue[700]!;
        bgColor = Colors.blue[50]!;
        statusIcon = Icons.play_circle;
        break;
      default:
        statusColor = Colors.grey[600]!;
        bgColor = Colors.grey[50]!;
        statusIcon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: caseData['status'] == 'Running' ? Colors.blue[25] : null,
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Item Number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${caseData['itemNo']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Case Details
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      caseData['type'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caseData['lawyer'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Time and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    caseData['time'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          caseData['status'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    caseData['duration'],
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),

          // Additional Info for Running Case
          if (caseData['status'] == 'Running') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Currently in progress - Live control available',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to live control
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening live control...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'CONTROL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
