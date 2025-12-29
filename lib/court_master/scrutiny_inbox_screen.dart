import 'package:flutter/material.dart';

class ScrutinyInboxScreen extends StatefulWidget {
  const ScrutinyInboxScreen({super.key});

  @override
  State<ScrutinyInboxScreen> createState() => _ScrutinyInboxScreenState();
}

class _ScrutinyInboxScreenState extends State<ScrutinyInboxScreen> {
  // Mock data for scrutiny inbox
  List<Map<String, dynamic>> _scrutinyInbox = [
    {
      'id': 'CRL-2024-009',
      'title': 'Patel vs. State',
      'type': 'Bail Application',
      'petitioner': 'Ramesh Patel',
      'filedTime': '09:45 AM',
      'status': 'Under Scrutiny',
      'lawyer': 'Adv. Suresh Patel',
      'documents': ['Petition', 'Affidavit', 'Vakalatnama'],
      'priority': 'High',
    },
    {
      'id': 'WP-2024-012',
      'title': 'Tech Corp vs. Municipal Corp',
      'type': 'Writ Petition',
      'petitioner': 'Tech Corporation Ltd',
      'filedTime': '10:15 AM',
      'status': 'Under Scrutiny',
      'lawyer': 'Adv. Priya Sharma',
      'documents': ['Petition', 'Company Registration', 'Board Resolution'],
      'priority': 'Medium',
    },
    {
      'id': 'CA-2024-008',
      'title': 'Singh vs. Insurance Co',
      'type': 'Civil Appeal',
      'petitioner': 'Vikram Singh',
      'filedTime': '10:30 AM',
      'status': 'Under Scrutiny',
      'lawyer': 'Adv. Amit Kumar',
      'documents': ['Appeal Memo', 'Lower Court Order', 'Evidence'],
      'priority': 'Low',
    },
    {
      'id': 'CRL-2024-010',
      'title': 'Kumar vs. State of Delhi',
      'type': 'Anticipatory Bail',
      'petitioner': 'Rajesh Kumar',
      'filedTime': '11:00 AM',
      'status': 'Under Scrutiny',
      'lawyer': 'Adv. Meera Gupta',
      'documents': ['Petition', 'Surety Bond', 'Character Certificate'],
      'priority': 'High',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'High Priority',
    'Medium Priority',
    'Low Priority',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCases = _getFilteredCases();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Scrutiny Inbox',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange[700],
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
              '${filteredCases.length} Cases',
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
          _buildFilterTabs(),
          Expanded(
            child: filteredCases.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCases.length,
                    itemBuilder: (context, index) {
                      return _buildScrutinyCard(filteredCases[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange[700] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.orange[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  filter,
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
    );
  }

  Widget _buildScrutinyCard(Map<String, dynamic> caseData) {
    Color priorityColor = _getPriorityColor(caseData['priority']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    caseData['priority'].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${caseData['type']} • ${caseData['id']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Case Details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Petitioner',
                        caseData['petitioner'],
                        Icons.person,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Lawyer',
                        caseData['lawyer'],
                        Icons.gavel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailItem(
                  'Filed Time',
                  caseData['filedTime'],
                  Icons.access_time,
                ),
                const SizedBox(height: 16),

                // Documents
                const Text(
                  'Documents Submitted:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (caseData['documents'] as List<String>).map((doc) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        doc,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRejectDialog(caseData),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('REJECT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[700],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.red[200]!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showPreviewDialog(caseData),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('PREVIEW'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[700],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.blue[200]!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveCase(caseData['id']),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('APPROVE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[50],
                          foregroundColor: Colors.green[700],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No cases for scrutiny',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All cases have been processed',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredCases() {
    if (_selectedFilter == 'All') return _scrutinyInbox;

    final priority = _selectedFilter.split(
      ' ',
    )[0]; // Extract "High", "Medium", "Low"
    return _scrutinyInbox.where((c) => c['priority'] == priority).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _approveCase(String caseId) {
    setState(() {
      _scrutinyInbox.removeWhere((c) => c['id'] == caseId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Case $caseId approved and registered'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> caseData) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Case'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Case: ${caseData['title']}'),
            const SizedBox(height: 16),
            const Text('Reason for rejection:'),
            const SizedBox(height: 8),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _rejectCase(caseData['id'], commentController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(Map<String, dynamic> caseData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Case Preview: ${caseData['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${caseData['title']}'),
              const SizedBox(height: 8),
              Text('Type: ${caseData['type']}'),
              const SizedBox(height: 8),
              Text('Petitioner: ${caseData['petitioner']}'),
              const SizedBox(height: 8),
              Text('Lawyer: ${caseData['lawyer']}'),
              const SizedBox(height: 16),
              const Text(
                'Documents:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...((caseData['documents'] as List<String>).map(
                (doc) => Text('• $doc'),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _rejectCase(String caseId, String reason) {
    setState(() {
      _scrutinyInbox.removeWhere((c) => c['id'] == caseId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.white),
            const SizedBox(width: 8),
            Text('Case $caseId rejected: $reason'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
