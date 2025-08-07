import 'dart:io';
import 'package:diseas_discover/services/classification_service.dart';
import 'package:diseas_discover/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AnalysisTabPage extends StatefulWidget {
  final ClassificationService classificationService;

  const AnalysisTabPage({super.key, required this.classificationService});

  @override
  State<AnalysisTabPage> createState() => _AnalysisTabPageState();
}

class _AnalysisTabPageState extends State<AnalysisTabPage> {
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the analysis process is running.
    // We check if it's loading AND if a file has been selected for analysis.
    final bool isAnalyzing = widget.classificationService.isLoading &&
        widget.classificationService.mediaFile != null;

    return Scaffold(
      // --- 1. THE MAIN FIX: CONDITIONAL BODY ---
      // If `isAnalyzing` is true, show the loading view.
      // Otherwise, show the main content view.
      body: isAnalyzing ? _buildLoadingView() : _buildMainContent(),
    );
  }

  /// A dedicated widget to show when the analysis is in progress.
  /// This will be centered on the screen.
  Widget _buildLoadingView() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
              radius: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            "جاري التحليل، يرجى الانتظار...",
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  /// The main content widget for selecting and previewing an image.
  Widget _buildMainContent() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final mediaFile = widget.classificationService.mediaFile;
    // For disabling buttons, we use the general isLoading state.
    final isLoading = widget.classificationService.isLoading;
    final mediaFileName = widget.classificationService.mediaFileName;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(CupertinoIcons.camera_viewfinder,
                  size: 60, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'تحليل صور الجلد',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ارفق صورة واضحة للآفة الجلدية ليتم تحليلها',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (mediaFile != null) ...[
                _buildMediaPreview(context, mediaFile),
                const SizedBox(height: 12),
                if (mediaFileName != null)
                  Text(
                    mediaFileName,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 24),
              ] else ...[
                _buildImagePlaceholder(context),
                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                          CupertinoIcons.photo_fill_on_rectangle_fill),
                      label: const Text('اختر صورة'),
                      onPressed: isLoading
                          ? null
                          : () => _showImageSourceActionSheet(context),
                    ),
                  ),
                  if (mediaFile != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(CupertinoIcons.clear_thick_circled),
                        label: const Text('مسح'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(
                              color: theme.colorScheme.error, width: 1.5),
                          elevation: 0,
                        ),
                        onPressed: isLoading
                            ? null
                            : widget.classificationService
                                .clearCurrentSelectionAndResults,
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 20),
              if (mediaFile != null)
                ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.rocket_fill),
                  label: const Text('بدء التحليل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                  ),
                  onPressed: isLoading
                      ? null
                      : widget.classificationService.classifySelectedMedia,
                ),
              // --- 2. REMOVED THE OLD LOADING INDICATOR FROM THE BOTTOM ---
              // The old "if (isLoading)" block that was here has been removed.
            ],
          ),
        ),
      ),
    );
  }

  // --- Other helper methods (_showImageSourceActionSheet, _buildMediaPreview, etc.) remain unchanged ---
  void _showImageSourceActionSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(CupertinoIcons.photo_camera_solid,
                    color: theme.colorScheme.primary),
                title: Text('التقط صورة بالكاميرا',
                    style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.classificationService.pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(CupertinoIcons.photo_on_rectangle,
                    color: theme.colorScheme.primary),
                title: Text('اختر من معرض الصور',
                    style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.classificationService.pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.photo_on_rectangle,
              size: 50,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              "لم يتم اختيار صورة",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(BuildContext context, File mediaFile) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: Image.file(
            mediaFile,
            key: ValueKey(mediaFile.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.error.withOpacity(0.1),
                child: Center(
                    child: Icon(Icons.broken_image,
                        size: 50, color: AppColors.error.withOpacity(0.5))),
              );
            },
          ),
        ),
      ),
    );
  }
}
