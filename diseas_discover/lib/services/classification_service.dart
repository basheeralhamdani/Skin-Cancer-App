// lib/services/classification_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class ClassificationService extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _baseApiUrl =
      "https://basheeralhamdani-skin-cancer-app.hf.space";

  File? _mediaFile;
  String? _predictedClass;
  double? _confidence;
  bool _isLoading = false;
  String? _error;
  String? _lastResultId;

  Map<String, dynamic>? _latestClassificationData;
  Map<String, dynamic>? get latestClassificationData =>
      _latestClassificationData;

  File? get mediaFile => _mediaFile;
  String? get predictedClass => _predictedClass;
  double? get confidence => _confidence;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get mediaFileName =>
      _mediaFile != null ? p.basename(_mediaFile!.path) : null;
  String? get lastResultId => _lastResultId;

  // Private helper to process the selected image and reset state
  Future<void> _processPickedFile(XFile? pickedFile) async {
    if (pickedFile != null) {
      _mediaFile = File(pickedFile.path);
      // Reset previous results when a new image is selected
      _error = null;
      _predictedClass = null;
      _confidence = null;
      _latestClassificationData = null;
      _lastResultId = null;
    } else {
      // User cancelled the picker, do nothing.
    }
  }

  // --- MODIFIED & NEW METHODS START HERE ---

  // MODIFIED: Old 'pickImage' is now specifically for the gallery
  Future<void> pickImageFromGallery() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      await _processPickedFile(image);
    } catch (e) {
      _error = "Failed to pick image from gallery: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NEW: Method to take a photo with the camera
  Future<void> pickImageFromCamera() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      await _processPickedFile(photo);
    } catch (e) {
      _error = "Failed to take photo with camera: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MODIFIED & NEW METHODS END HERE ---

  Future<void> classifySelectedMedia() async {
    if (_mediaFile == null) {
      _error = "Please select an image first to analyze.";
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    _predictedClass = null;
    _confidence = null;
    _latestClassificationData = null;
    _lastResultId = null;
    notifyListeners();

    final File fileToClassify = _mediaFile!;
    final predictUrl = Uri.parse('$_baseApiUrl/predict');

    try {
      final request = http.MultipartRequest('POST', predictUrl);
      request.files
          .add(await http.MultipartFile.fromPath('file', fileToClassify.path));
      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('predicted_class') &&
            data.containsKey('confidence')) {
          _predictedClass = data['predicted_class'];
          _confidence = (data['confidence'] as num).toDouble();
          _latestClassificationData = {
            'predictedClass': _predictedClass,
            'confidence': _confidence,
            'timestamp': FieldValue.serverTimestamp(),
            'imageFileName': p.basename(fileToClassify.path),
          };
        } else if (data.containsKey('error')) {
          _error = "Server Error: ${data['error']}";
        } else {
          _error = "Prediction not found in server response.";
        }
      } else {
        String serverErrorMsg =
            "Failed to classify (Status: ${response.statusCode})";
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['error'] != null)
            serverErrorMsg = "Server Error: ${errorJson['error']}";
          else if (errorJson['detail'] != null)
            serverErrorMsg =
                "Server Error: ${errorJson['detail'] is List ? errorJson['detail'][0]['msg'] : errorJson['detail']}";
        } catch (_) {}
        _error = serverErrorMsg;
      }
    } catch (e) {
      _error = "An error occurred: ${e.toString()}";
      print("ClassificationService classifySelectedMedia Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveLatestResultToFirestore() async {
    // ... (This method remains unchanged) ...
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _error = "User not logged in. Cannot save result.";
      print("ClassificationService: Save failed - User not logged in.");
      return false;
    }
    if (_latestClassificationData == null) {
      _error = "No classification data available to save.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic> dataToSave = {
        ..._latestClassificationData!,
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
      };
      DocumentReference docRef =
          await _firestore.collection('analysis_results').add(dataToSave);
      _lastResultId = docRef.id;
      print(
          "ClassificationService: Result saved to Firestore with ID: ${docRef.id}");
      return true;
    } catch (e) {
      _error = "Failed to save result: ${e.toString()}";
      print("ClassificationService: Error saving to Firestore: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... (Other methods like logout, clear, etc. remain unchanged) ...
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _clearAllStates();
    } catch (e) {
      print("ClassificationService: Error signing out: $e");
      rethrow;
    }
  }

  void clearCurrentSelectionAndResults() {
    _mediaFile = null;
    _predictedClass = null;
    _confidence = null;
    _error = null;
    _latestClassificationData = null;
    _lastResultId = null;
    notifyListeners();
  }

  void _clearAllStates() {
    _mediaFile = null;
    _predictedClass = null;
    _confidence = null;
    _error = null;
    _isLoading = false;
    _latestClassificationData = null;
    _lastResultId = null;
  }
}
