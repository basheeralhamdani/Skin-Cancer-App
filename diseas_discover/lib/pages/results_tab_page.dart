// lib/pages/results_tab_page.dart
import 'package:diseas_discover/services/classification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diseas_discover/theme/app_colors.dart';

class ResultsTabPage extends StatefulWidget {
  final ClassificationService classificationService;
  final VoidCallback onNavigateToGuidance;
  final VoidCallback onNavigateToLogin;
  final VoidCallback onNavigateToRegister;

  const ResultsTabPage({
    super.key,
    required this.classificationService,
    required this.onNavigateToGuidance,
    required this.onNavigateToLogin,
    required this.onNavigateToRegister,
  });

  @override
  State<ResultsTabPage> createState() => _ResultsTabPageState();
}

class _ResultsTabPageState extends State<ResultsTabPage> {
  bool _isCurrentlySaving = false;

  @override
  void initState() {
    super.initState();
    widget.classificationService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.classificationService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  // --- 1. UPDATED HELPER METHODS TO BE SMARTER ---

  /// Determines if a class is considered potentially harmful.
  bool _isConsideredHarmful(String? predictedClass) {
    if (predictedClass == null) return false;
    final lower = predictedClass.toLowerCase();
    // List of classes that should show a warning.
    List<String> harmfulClasses = [
      'mel',
      'bcc'
    ]; // Example: Melanoma, Basal Cell Carcinoma
    return harmfulClasses.any((h) => lower.contains(h));
  }

  /// Determines if a class has specific guidance (is not benign or unclear).
  /// This is used to decide whether to show the "View Guidance" button.
  bool _hasSpecificGuidance(String? predictedClass) {
    if (predictedClass == null) return false;
    // For now, this is the same as being harmful, but could be different in the future.
    return _isConsideredHarmful(predictedClass);
  }

  // ... (The rest of the methods like _promptToLoginOrRegisterAndSave, _handleSaveResult remain the same)
  // --- For brevity, I am not re-pasting the unchanged methods ---
  Future<void> _promptToLoginOrRegisterAndSave() async {
    final theme = Theme.of(context);
    final action = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("حفظ نتيجة التحليل", style: theme.textTheme.titleLarge),
          content: Text(
            "لحفظ هذه النتيجة والاطلاع عليها لاحقًا، يرجى تسجيل الدخول أو إنشاء حساب جديد.",
            style: theme.textTheme.bodyMedium,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text("لاحقًا"),
              onPressed: () => Navigator.of(context).pop('cancel'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  child: const Text("تسجيل الدخول"),
                  onPressed: () => Navigator.of(context).pop('login'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  child: const Text("إنشاء حساب"),
                  onPressed: () => Navigator.of(context).pop('register'),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (action == 'login') {
      widget.onNavigateToLogin();
    } else if (action == 'register') {
      widget.onNavigateToRegister();
    }
  }

  Future<void> _handleSaveResult() async {
    if (widget.classificationService.latestClassificationData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("لا توجد نتيجة حالية لحفظها."),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      _promptToLoginOrRegisterAndSave();
    } else {
      if (!mounted) return;
      setState(() => _isCurrentlySaving = true);

      bool success =
          await widget.classificationService.saveLatestResultToFirestore();

      if (!mounted) return;
      setState(() => _isCurrentlySaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "تم حفظ النتيجة بنجاح!"
              : (widget.classificationService.error ?? "فشل حفظ النتيجة.")),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.classificationService;
    final isLoadingClassification = cs.isLoading && !_isCurrentlySaving;
    final hasContent = !isLoadingClassification &&
        (cs.predictedClass != null || cs.error != null);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: isLoadingClassification
              ? _buildLoadingIndicator("جاري الحصول على النتائج...")
              : hasContent
                  ? _buildResultsContent()
                  : _buildPlaceholderResults(),
        ),
      ),
    );
  }

  // --- 2. THE BUILD METHOD NOW USES THE NEW HELPER ---
  Widget _buildResultsContent() {
    final cs = widget.classificationService;
    final predictedClass = cs.predictedClass;
    final error = cs.error;
    final confidence = cs.confidence;
    final isSaved = cs.lastResultId != null;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null && predictedClass == null)
            _buildErrorDisplay(error, "حدث خطأ اثناء التحليل")
          else if (predictedClass != null) ...[
            _buildPredictionResult(predictedClass,
                confidence), // This will now show the correct icon
            const SizedBox(height: 24),
            if (!isSaved) _buildSaveButton() else _buildSavedConfirmation(),
            // Only show guidance button if there is specific guidance
            if (_hasSpecificGuidance(predictedClass)) ...[
              const SizedBox(height: 16),
              _buildGuidanceButton(),
            ]
          ]
        ],
      ),
    );
  }

  // --- 3. UPDATED PREDICTION RESULT WIDGET ---
  Widget _buildPredictionResult(String predictedClass, double? confidence) {
    final theme = Theme.of(context);
    final bool isHarmful = _isConsideredHarmful(predictedClass);

    // This is the core logic change:
    final Color resultColor =
        isHarmful ? theme.colorScheme.error : AppColors.success;
    final IconData resultIcon = isHarmful
        ? CupertinoIcons.exclamationmark_triangle_fill
        : CupertinoIcons.checkmark_seal_fill;

    return Card(
      elevation: 4,
      shadowColor: resultColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // The icon is now correctly chosen based on the logic
            Icon(resultIcon, size: 50, color: resultColor),
            const SizedBox(height: 16),
            Text('نتيجة التحليل', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              predictedClass,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: resultColor, // Text color also reflects the result
                fontWeight: FontWeight.bold,
              ),
            ),
            if (confidence != null) ...[
              const SizedBox(height: 16),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('مستوى الثقة: ', style: theme.textTheme.bodyLarge),
                  Text(
                    '${(confidence * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: resultColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- All other build helpers (_buildSaveButton, _buildGuidanceButton, etc.) remain the same ---
  Widget _buildSaveButton() {
    if (_isCurrentlySaving) {
      return _buildLoadingIndicator("جاري الحفظ...");
    }
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    return ElevatedButton.icon(
      icon: Icon(isLoggedIn
          ? CupertinoIcons.floppy_disk
          : CupertinoIcons.person_add_solid),
      label: Text(isLoggedIn ? "حفظ النتيجة" : "حفظ النتيجة (يتطلب تسجيل)"),
      onPressed: _handleSaveResult,
    );
  }

  Widget _buildGuidanceButton() {
    return ElevatedButton.icon(
      icon: const Icon(CupertinoIcons.question_circle),
      label: const Text("عرض الإرشادات والنصائح"),
      onPressed: _isCurrentlySaving ? null : widget.onNavigateToGuidance,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textSecondary,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildSavedConfirmation() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.check_mark_circled_solid,
              color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            "تم حفظ هذه النتيجة",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(String message) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoActivityIndicator(
            radius: 16, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(message,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.primary)),
      ],
    );
  }

  Widget _buildErrorDisplay(String errorMessage, String title) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.error.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.error.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(CupertinoIcons.xmark_octagon_fill,
                size: 44, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: theme.colorScheme.error)),
            const SizedBox(height: 10),
            Text(errorMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderResults() {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.doc_text_search,
            size: 70, color: theme.iconTheme.color?.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text("لم يتم إجراء تحليل بعد",
            style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "اختر صورة من علامة التبويب 'تحليل' ثم اضغط على 'بدء التحليل' لعرض النتائج هنا.",
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
