import 'package:diseas_discover/services/classification_service.dart';
import 'package:diseas_discover/services/guidance_data_service.dart';
import 'package:diseas_discover/widgets/chat_bubble.dart';
import 'package:diseas_discover/widgets/disclaimer_card.dart';
import 'package:diseas_discover/widgets/question_option_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class GuidanceTabPage extends StatefulWidget {
  final ClassificationService classificationService;

  const GuidanceTabPage({super.key, required this.classificationService});

  @override
  State<GuidanceTabPage> createState() => _GuidanceTabPageState();
}

class _GuidanceTabPageState extends State<GuidanceTabPage> {
  final ScrollController _scrollController = ScrollController();
  String? _activeGuidanceForClass;
  List<Map<String, dynamic>> _currentChatFlowOptions = [];
  List<Map<String, dynamic>> _chatDisplayHistory = [];

  @override
  void initState() {
    super.initState();
    widget.classificationService.addListener(_handleServiceUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _buildOrUpdateGuidanceContent();
    });
  }

  @override
  void dispose() {
    widget.classificationService.removeListener(_handleServiceUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleServiceUpdate() {
    if (mounted) _buildOrUpdateGuidanceContent();
  }

  void _buildOrUpdateGuidanceContent() {
    final newClass = widget.classificationService.predictedClass;
    if (newClass != _activeGuidanceForClass) {
      setState(() {
        _chatDisplayHistory = [];
        _currentChatFlowOptions = [];
        _activeGuidanceForClass = newClass;

        if (newClass != null && !_isBenignOrUnclear(newClass)) {
          final guidanceData =
              GuidanceDataService.getGuidanceForClass(newClass);
          _chatDisplayHistory.add(
              {'type': 'bot', 'message': guidanceData['initial_greeting']});
          _currentChatFlowOptions =
              List<Map<String, dynamic>>.from(guidanceData['questions'] ?? []);
        }
      });
    } else if (mounted) {
      setState(() {}); // For other updates like loading state
    }
  }

  void _handleQuestionSelection(Map<String, dynamic> questionData) {
    if (mounted) {
      setState(() {
        _chatDisplayHistory
            .add({'type': 'user', 'message': questionData['question']});
        _chatDisplayHistory
            .add({'type': 'bot', 'message': questionData['answer']});

        if (questionData['learn_more_link'] != null) {
          _chatDisplayHistory.add({
            'type': 'bot_link',
            'message': questionData['learn_more_text'] ?? "اعرف المزيد من هنا",
            'link': questionData['learn_more_link']
          });
        }

        _currentChatFlowOptions = questionData['next_questions'] is List
            ? List<Map<String, dynamic>>.from(questionData['next_questions'])
            : [];
      });
      // Scroll to the bottom after adding new messages
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  bool _isBenignOrUnclear(String? predictedClass) {
    if (predictedClass == null) return true;
    final lower = predictedClass.toLowerCase();
    // Classes that HAVE specific guidance are NOT benign/unclear in this context.
    if (lower.contains('mel') ||
        lower.contains('bcc') ||
        lower.contains('nv')) {
      return false;
    }
    return true; // All others are considered to have no specific guidance.
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.classificationService;
    final theme = Theme.of(context);

    // Determine the current state of the page
    if (cs.isLoading && _activeGuidanceForClass == null) {
      return _buildLoadingIndicator("جاري تحميل الإرشادات...");
    }

    if (cs.error != null &&
        (_activeGuidanceForClass == null || _chatDisplayHistory.isEmpty)) {
      return _buildPlaceholder(
        icon: CupertinoIcons.xmark_seal_fill,
        title: "حدث خطأ",
        message:
            "لا يمكن عرض الإرشادات بسبب حدوث خطأ.\nقد يكون الخطأ من الخادم أو مشكلة في الشبكة.",
        isError: true,
      );
    }

    if (_activeGuidanceForClass == null ||
        _isBenignOrUnclear(_activeGuidanceForClass)) {
      return _buildPlaceholder(
        icon: cs.predictedClass == null
            ? CupertinoIcons.search_circle_fill
            : CupertinoIcons.smiley_fill,
        title: cs.predictedClass == null ? "لا توجد نتيجة" : "نتيجة آمنة",
        message: cs.predictedClass == null
            ? "يرجى إجراء تحليل أولاً لعرض الإرشادات المناسبة."
            : "النتيجة الحالية ('\u202B${cs.predictedClass}\u202C') لا تستدعي إرشادات خاصة عبر التطبيق. للحفاظ على صحة جلدك، ننصح بالفحص الدوري لدى طبيب الجلدية.",
      );
    }

    // Main chat UI
    return Scaffold(
      body: Column(
        children: [
          const DisclaimerCard(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _chatDisplayHistory.length,
              itemBuilder: (context, index) {
                final item = _chatDisplayHistory[index];
                return ChatBubble(
                  message: item['message'],
                  isUserMessage: item['type'] == 'user',
                  link: item['link'],
                  onLinkTap: item['link'] != null
                      ? () => _launchURL(item['link'])
                      : null,
                );
              },
            ),
          ),
          if (_currentChatFlowOptions.isNotEmpty)
            _buildQuestionOptions(theme)
          else if (_chatDisplayHistory.isNotEmpty)
            _buildChatEndMessage(theme)
        ],
      ),
    );
  }

  Container _buildQuestionOptions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.center,
        children: _currentChatFlowOptions
            .map((q) => QuestionOptionButton(
                text: q['question'],
                onPressed: () => _handleQuestionSelection(q)))
            .toList(),
      ),
    );
  }

  Padding _buildChatEndMessage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        "نأمل أن تكون هذه المعلومات مفيدة. تذكر دائمًا استشارة طبيبك.",
        textAlign: TextAlign.center,
        style:
            theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildPlaceholder(
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

  Widget _buildLoadingIndicator(String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoActivityIndicator(
              radius: 16, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(message,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.primary)),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    if (!await launchUrl(Uri.parse(urlString),
        mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('لا يمكن فتح الرابط: $urlString'),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }
}
