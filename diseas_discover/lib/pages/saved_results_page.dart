import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:diseas_discover/theme/app_colors.dart'; // --- IMPORT YOUR COLORS ---

class SavedResultsPage extends StatefulWidget {
  const SavedResultsPage({super.key});

  @override
  State<SavedResultsPage> createState() => _SavedResultsPageState();
}

class _SavedResultsPageState extends State<SavedResultsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot>? _resultsStream;

  @override
  void initState() {
    super.initState();
    _setupResultsStream();
  }

  void _setupResultsStream() {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _resultsStream = _firestore
            .collection('analysis_results')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots();
      });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('yyyy-MM-dd – hh:mm a').format(timestamp.toDate());
  }

  // --- HELPER TO DETERMINE COLOR BASED ON CLASS ---
  Color _getColorForClass(String? className) {
    if (className == null) return AppColors.textSecondary;
    String lower = className.toLowerCase();
    // Example: Use error color for more serious conditions
    if (lower.contains('mel') || lower.contains('bcc')) return AppColors.error;
    // Use success color for benign conditions
    if (lower.contains('nv')) return AppColors.success;
    // Default to a neutral color
    return AppColors.textPrimary;
  }

  IconData _getIconForClass(String? className) {
    if (className == null) return CupertinoIcons.question_circle;
    String lower = className.toLowerCase();
    if (lower.contains('mel')) return CupertinoIcons.shield_lefthalf_fill;
    if (lower.contains('bcc'))
      return CupertinoIcons.exclamationmark_shield_fill;
    if (lower.contains('nv')) return CupertinoIcons.checkmark_seal_fill;
    return CupertinoIcons.doc_text_fill;
  }

  Future<void> _deleteResult(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content:
            const Text("هل أنت متأكد من أنك تريد حذف هذه النتيجة بشكل دائم؟"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("إلغاء")),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("حذف", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('analysis_results').doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("تم حذف النتيجة."),
                backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("فشل حذف النتيجة: $e"),
                backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      // Fallback screen, though it shouldn't be reached with proper auth guards.
      return Scaffold(
        appBar: AppBar(title: const Text("نتائجي المحفوظة")),
        body: _buildEmptyState(
          icon: CupertinoIcons.lock_fill,
          title: "الوصول مقيد",
          message: "يرجى تسجيل الدخول لعرض نتائجك المحفوظة.",
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("نتائجي المحفوظة"),
        // The back button is automatically added by Navigator, but this is explicit.
        leading: const BackButton(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _resultsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return _buildEmptyState(
              icon: CupertinoIcons.xmark_octagon_fill,
              title: "حدث خطأ",
              message: "لا يمكن تحميل النتائج. يرجى المحاولة مرة أخرى لاحقًا.",
              isError: true,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 15));
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(
              icon: CupertinoIcons.doc_on_doc_fill,
              title: "لا توجد نتائج محفوظة",
              message: "سيتم عرض النتائج التي تقوم بحفظها هنا.",
            );
          }

          // --- STYLED LIST VIEW ---
          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              final data = document.data()! as Map<String, dynamic>;
              final resultColor = _getColorForClass(data['predictedClass']);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: resultColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: resultColor.withOpacity(0.1),
                    child: Icon(_getIconForClass(data['predictedClass']),
                        color: resultColor, size: 26),
                  ),
                  title: Text(
                    data['predictedClass'] ?? 'غير معروف',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: resultColor),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'الثقة: ${(data['confidence'] != null ? (data['confidence'] * 100).toStringAsFixed(1) : 'N/A')}%',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(data['timestamp'] as Timestamp?),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(CupertinoIcons.delete,
                        color: AppColors.textSecondary.withOpacity(0.7)),
                    onPressed: () => _deleteResult(document.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- HELPER FOR EMPTY/ERROR STATES ---
  Widget _buildEmptyState(
      {required IconData icon,
      required String title,
      required String message,
      bool isError = false}) {
    final theme = Theme.of(context);
    final color = isError
        ? theme.colorScheme.error
        : theme.iconTheme.color?.withOpacity(0.6);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: color),
            const SizedBox(height: 16),
            Text(title,
                style: theme.textTheme.titleLarge?.copyWith(color: color),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
