import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// 1. DATA MODELS
// ---------------------------------------------------------------------------
enum OutcomeType { disposed, adjourned, notReached }

class CaseData {
  final String caseNumber;
  final String title;
  final String stage;

  CaseData({
    required this.caseNumber,
    required this.title,
    required this.stage,
  });
}

// ---------------------------------------------------------------------------
// 2. OUTCOME RECORDER SCREEN
// ---------------------------------------------------------------------------
class OutcomeRecorderScreen extends StatefulWidget {
  const OutcomeRecorderScreen({super.key});

  @override
  State<OutcomeRecorderScreen> createState() => _OutcomeRecorderScreenState();
}

class _OutcomeRecorderScreenState extends State<OutcomeRecorderScreen> {
  // Mock Current Case
  final CaseData currentCase = CaseData(
    caseNumber: 'SLP(C) 1234/2024',
    title: 'Union of India vs. Respondent 01',
    stage: 'Final Hearing',
  );

  bool _isProcessing = false;

  // --- ACTIONS ---
  void _handleDisposed() {
    _showConfirmationDialog(
      title: "Confirm Disposal",
      content: "Are you sure you want to mark this case as DISPOSED?",
      confirmBtnText: "Dispose Case",
      confirmColor: Colors.green,
      onConfirm: () {
        _simulateBackendSave("Case Disposed Successfully");
      },
    );
  }

  void _handleNotReached() {
    _showConfirmationDialog(
      title: "Mark Not Reached",
      content: "This will move the case to the spillover list for tomorrow.",
      confirmBtnText: "Confirm Spillover",
      confirmColor: Colors.orange,
      onConfirm: () {
        _simulateBackendSave("Marked as Not Reached");
      },
    );
  }

  void _handleAdjourned() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AdjournmentSheet(
        caseNumber: currentCase.caseNumber,
        onSave: (date, reason) {
          Navigator.pop(context); // Close sheet
          _simulateBackendSave(
            "Adjourned to ${DateFormat('dd MMM').format(date)} ($reason)",
          );
        },
      ),
    );
  }

  void _simulateBackendSave(String successMessage) async {
    setState(() => _isProcessing = true);
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(successMessage),
            ],
          ),
          backgroundColor: const Color(0xFF1E3A8A), // Court Master blue theme
          behavior: SnackBarBehavior.floating,
        ),
      );
      // In a real app, you would navigate back or load the next case here
    }
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmBtnText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(
              confirmBtnText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Court Master background
      appBar: AppBar(
        title: const Text(
          "Outcome Recorder",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A), // Court Master blue
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isProcessing
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCaseHeader(),
                  const SizedBox(height: 40),
                  const Text(
                    "Select Outcome",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A), // Court Master blue
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 1. DISPOSED
                  _buildOutcomeCard(
                    title: "Disposed",
                    subtitle: "Final judgment delivered or case dismissed.",
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onTap: _handleDisposed,
                  ),
                  const SizedBox(height: 20),
                  // 2. ADJOURNED
                  _buildOutcomeCard(
                    title: "Adjourned",
                    subtitle: "Hearing incomplete. Set next date.",
                    icon: Icons.calendar_today,
                    color: const Color(0xFF1E3A8A), // Court Master blue
                    onTap: _handleAdjourned,
                  ),
                  const SizedBox(height: 20),
                  // 3. NOT REACHED
                  _buildOutcomeCard(
                    title: "Not Reached",
                    subtitle: "Time elapsed. Carry forward to next day.",
                    icon: Icons.timer_off_outlined,
                    color: Colors.orangeAccent,
                    onTap: _handleNotReached,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCaseHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        border: const Border(
          left: BorderSide(
            color: Color(0xFF1E3A8A), // Court Master blue
            width: 6,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CURRENT MATTER",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A), // Court Master blue
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentCase.stage,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentCase.caseNumber,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A), // Court Master blue
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentCase.title,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. ADJOURNMENT BOTTOM SHEET
// ---------------------------------------------------------------------------
class AdjournmentSheet extends StatefulWidget {
  final String caseNumber;
  final Function(DateTime date, String reason) onSave;

  const AdjournmentSheet({
    super.key,
    required this.caseNumber,
    required this.onSave,
  });

  @override
  State<AdjournmentSheet> createState() => _AdjournmentSheetState();
}

class _AdjournmentSheetState extends State<AdjournmentSheet> {
  DateTime? _selectedDate;
  String? _selectedReason;

  final List<String> _reasons = [
    "Counter Affidavit",
    "Rejoinder",
    "Evidence",
    "Arguments",
    "Personal Difficulty",
    "Settlement Talks",
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A), // Court Master blue
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Adjourn Matter",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A), // Court Master blue
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          // 1. DATE PICKER
          const Text(
            "Next Hearing Date",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A), // Court Master blue
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFF1E3A8A)),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate == null
                        ? "Select Date"
                        : DateFormat(
                            'EEEE, d MMMM yyyy',
                          ).format(_selectedDate!),
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate == null
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 2. REASON SELECTOR
          const Text(
            "Reason for Adjournment",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A), // Court Master blue
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _reasons.map((reason) {
              final bool isSelected = _selectedReason == reason;
              return ChoiceChip(
                label: Text(reason),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedReason = selected ? reason : null);
                },
                selectedColor: const Color(0xFF1E3A8A), // Court Master blue
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          // 3. SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedDate != null && _selectedReason != null)
                  ? () => widget.onSave(_selectedDate!, _selectedReason!)
                  : null, // Disabled until valid
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A), // Court Master blue
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Confirm Adjournment",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
