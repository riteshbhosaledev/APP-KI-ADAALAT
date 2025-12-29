import 'package:flutter/material.dart';
import 'models/case_model.dart';

class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({super.key});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _selectedTab = 0;
  String _searchQuery = '';

  // Mock data for cases
  final List<CaseModel> _allCases = [
    CaseModel(
      id: 'CRL-2024-008',
      title: 'Sharma vs. State of UP',
      type: 'Bail Application',
      status: 'Listed',
      itemNo: 15,
      currentItem: 2,
      courtroom: '4',
      nextHearing: 'Today',
      judge: 'Hon\'ble Justice R.K. Rao',
      filedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    CaseModel(
      id: 'CIV-2024-005',
      title: 'Verma Industries vs. ROC',
      type: 'Corporate Writ',
      status: 'Defective',
      nextHearing: 'Pending',
      judge: 'Hon\'ble Justice S.K. Singh',
      filedDate: DateTime.now().subtract(const Duration(days: 12)),
      defects: 2,
    ),
    CaseModel(
      id: 'PIL-2024-001',
      title: 'Singh vs. State Pollution Board',
      type: 'PIL',
      status: 'Under Scrutiny',
      nextHearing: 'TBD',
      judge: 'Hon\'ble Justice M.P. Gupta',
      filedDate: DateTime.now().subtract(const Duration(days: 8)),
    ),
    CaseModel(
      id: 'CRL-2024-009',
      title: 'Kumar vs. State of UP',
      type: 'Anticipatory Bail',
      status: 'Listed',
      itemNo: 23,
      courtroom: '2',
      nextHearing: 'Tomorrow',
      judge: 'Hon\'ble Justice A.K. Mishra',
      filedDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<CaseModel> get _filteredCases {
    List<CaseModel> filtered = _allCases;

    // Filter by tab
    switch (_selectedTab) {
      case 1: // Active
        filtered = filtered.where((c) => c.status == 'Listed').toList();
        break;
      case 2: // Defective
        filtered = filtered.where((c) => c.status == 'Defective').toList();
        break;
      case 3: // Under Scrutiny
        filtered = filtered.where((c) => c.status == 'Under Scrutiny').toList();
        break;
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (c) =>
                c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.type.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(child: _buildCasesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Cases',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage all your cases',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_allCases.length} Cases',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search cases by title, ID, or type...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['All', 'Active', 'Defective', 'Under Scrutiny'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF1E3A8A)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCasesList() {
    final cases = _filteredCases;

    if (cases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No cases found'
                  : 'No cases in this category',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: cases.length,
      itemBuilder: (context, index) => _buildCaseCard(cases[index]),
    );
  }

  Widget _buildCaseCard(CaseModel caseData) {
    Color statusColor;
    Color statusBg;

    switch (caseData.status) {
      case 'Listed':
        statusColor = Colors.green[700]!;
        statusBg = Colors.green[50]!;
        break;
      case 'Defective':
        statusColor = Colors.red[700]!;
        statusBg = Colors.red[50]!;
        break;
      case 'Under Scrutiny':
        statusColor = Colors.orange[700]!;
        statusBg = Colors.orange[50]!;
        break;
      default:
        statusColor = Colors.blue[700]!;
        statusBg = Colors.blue[50]!;
    }

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
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
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
                            caseData.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${caseData.type} • ${caseData.id}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
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
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        caseData.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Case details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Filed',
                        _formatDate(caseData.filedDate),
                        Icons.calendar_today,
                      ),
                    ),
                    if (caseData.judge != null)
                      Expanded(
                        child: _buildDetailItem(
                          'Judge',
                          caseData.judge!.split(' ').last,
                          Icons.gavel,
                        ),
                      ),
                  ],
                ),

                if (caseData.courtroom != null || caseData.itemNo != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (caseData.courtroom != null)
                        Expanded(
                          child: _buildDetailItem(
                            'Courtroom',
                            caseData.courtroom!,
                            Icons.meeting_room,
                          ),
                        ),
                      if (caseData.itemNo != null)
                        Expanded(
                          child: _buildDetailItem(
                            'Item No.',
                            '${caseData.itemNo}',
                            Icons.numbers,
                          ),
                        ),
                    ],
                  ),
                ],

                if (caseData.defects > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${caseData.defects} defect${caseData.defects > 1 ? 's' : ''} to cure',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewCaseDetails(caseData),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('VIEW DETAILS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (caseData.status == 'Listed' && caseData.itemNo != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _trackCase(caseData),
                      icon: const Icon(Icons.track_changes, size: 18),
                      label: const Text('TRACK LIVE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else if (caseData.status == 'Defective')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _cureDefects(caseData),
                      icon: const Icon(Icons.build, size: 18),
                      label: const Text('CURE DEFECTS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewCaseDetails(CaseModel caseData) {
    // Navigate to case details screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(caseData.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Case ID: ${caseData.id}'),
            Text('Type: ${caseData.type}'),
            Text('Status: ${caseData.status}'),
            if (caseData.judge != null) Text('Judge: ${caseData.judge}'),
            Text('Next Hearing: ${caseData.nextHearing}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _trackCase(CaseModel caseData) {
    // Navigate to case tracker
    Navigator.pop(context); // Go back to dashboard first
  }

  void _cureDefects(CaseModel caseData) {
    // Navigate to defects curing screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cure Defects'),
        content: Text(
          'Case ${caseData.id} has ${caseData.defects} defect${caseData.defects > 1 ? 's' : ''} that need to be addressed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('LATER'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('START CURING'),
          ),
        ],
      ),
    );
  }
}
