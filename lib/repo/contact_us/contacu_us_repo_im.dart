// ******************* FILE INFO *******************
// File Name: contact_us_cms_repo_impl.dart
// Created by: Claude Assistant

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:web_app_admin/model/contact_model_location.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/repo/contact_us/contact_us_location.dart';

class ContactUsCmsRepoImpl implements ContactUsCmsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _collectionName = 'contact_us_cms';
  static const String _docId = 'main';

  @override
  Future<ContactUsCmsModel> load() async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(_docId)
          .get();

      if (!doc.exists || doc.data() == null) {
        // Return default empty model
        return _defaultModel();
      }

      return ContactUsCmsModel.fromJson(doc.data()!);
    } catch (e) {
      print('❌ ContactUsCmsRepo.load error: $e');
      rethrow;
    }
  }

  @override
  Future<void> save({
    required ContactUsCmsModel model,
    Map<String, Uint8List>? imageUploads,
  }) async {
    try {
      // ✅ Step 1: Upload images and get download URLs
      Map<String, String> uploadedUrls = {};
      if (imageUploads != null && imageUploads.isNotEmpty) {
        uploadedUrls = await _uploadImages(imageUploads);
      }

      // ✅ Step 2: Update model with new URLs
      final updatedModel = _updateModelWithUrls(model, uploadedUrls);

      // ✅ Step 3: Save model to Firestore with updated URLs
      await _firestore
          .collection(_collectionName)
          .doc(_docId)
          .set(updatedModel.toJson(), SetOptions(merge: true));

      print('✅ ContactUsCmsRepo.save: saved successfully');
    } catch (e) {
      print('❌ ContactUsCmsRepo.save error: $e');
      rethrow;
    }
  }

  // ── Upload images and return URLs ─────────────────────────────────────────

  Future<Map<String, String>> _uploadImages(Map<String, Uint8List> uploads) async {
    final Map<String, String> urls = {};

    for (final entry in uploads.entries) {
      final path = entry.key;
      final bytes = entry.value;

      try {
        // Determine content type based on file signature
        final contentType = _detectContentType(bytes);

        final ref = _storage.ref().child(path);
        final metadata = SettableMetadata(contentType: contentType);

        // Upload the file
        await ref.putData(bytes, metadata);

        // ✅ Get the download URL
        final downloadUrl = await ref.getDownloadURL();

        urls[path] = downloadUrl;
        print('✅ Uploaded: $path → $downloadUrl');
      } catch (e) {
        print('❌ Failed to upload $path: $e');
        // Continue with other uploads even if one fails
      }
    }

    return urls;
  }

  // ── Update model with new URLs ────────────────────────────────────────────

  ContactUsCmsModel _updateModelWithUrls(
      ContactUsCmsModel model,
      Map<String, String> uploadedUrls,
      ) {
    // Update social icons
    final updatedSocialIcons = model.socialIcons.map((icon) {
      final iconPath = 'contact_cms/social_icons/${icon.id}/icon';
      if (uploadedUrls.containsKey(iconPath)) {
        return icon.copyWith(iconUrl: uploadedUrls[iconPath]!);
      }
      return icon;
    }).toList();

    // Update office locations
    final updatedOfficeLocations = model.officeLocations.map((location) {
      final iconPath = 'contact_cms/office_locations/${location.id}/icon';
      if (uploadedUrls.containsKey(iconPath)) {
        return location.copyWith(iconUrl: uploadedUrls[iconPath]!);
      }
      return location;
    }).toList();

    // Update confirm message SVG
    String confirmSvgUrl = model.confirmMessage.svgUrl;
    final svgPath = 'contact_cms/confirm_message/svg';
    if (uploadedUrls.containsKey(svgPath)) {
      confirmSvgUrl = uploadedUrls[svgPath]!;
    }

    // Return updated model
    return ContactUsCmsModel(
      publishStatus: model.publishStatus,
      subDescription: model.subDescription,
      email: model.email,
      socialIcons: updatedSocialIcons,
      officeLocations: updatedOfficeLocations,
      confirmMessage: ContactConfirmMessage(
        svgUrl: confirmSvgUrl,
        title: model.confirmMessage.title,
        description: model.confirmMessage.description,
      ),
    );
  }

  // ── Detect content type ───────────────────────────────────────────────────

  String _detectContentType(Uint8List bytes) {
    if (bytes.length < 4) return 'application/octet-stream';

    // Check for PNG signature
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }

    // Check for JPEG signature
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // Check for WebP signature
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }

    // Check for SVG (text-based, starts with < or whitespace then <)
    final header = String.fromCharCodes(
        bytes.sublist(0, bytes.length > 100 ? 100 : bytes.length));
    if (header.trim().startsWith('<svg') || header.trim().startsWith('<?xml')) {
      return 'image/svg+xml';
    }

    return 'application/octet-stream';
  }

  // ── Default model ─────────────────────────────────────────────────────────

  ContactUsCmsModel _defaultModel() {
    return ContactUsCmsModel(
      publishStatus: 'draft',
      subDescription: ContactBilingualText(
        en: 'Achieve Your Goals Efficiently And Without Disruption Through Seamless, Uninterrupted Workflows',
        ar: 'حقق أهدافك بكفاءة ودون انقطاع من خلال سير عمل سلس ومتواصل',
      ),
      email: 'info@bayanatz.com',
      socialIcons: [
        ContactSocialIcon(
          id: 'social_1',
          iconUrl: '',
          link: '',
        ),
        ContactSocialIcon(
          id: 'social_2',
          iconUrl: '',
          link: '',
        ),
        ContactSocialIcon(
          id: 'social_3',
          iconUrl: '',
          link: '',
        ),
        ContactSocialIcon(
          id: 'social_4',
          iconUrl: '',
          link: '',
        ),
      ],
      officeLocations: [
        ContactOfficeLocation(
          id: 'office_1',
          iconUrl: '',
          locationName: ContactBilingualText(en: 'Egypt', ar: 'مصر'),
          text1: ContactBilingualText(en: 'Location Details', ar: 'تفاصيل الموقع'),
          text2: ContactBilingualText(en: '', ar: ''),
        ),
      ],
      confirmMessage: ContactConfirmMessage(
        svgUrl: '',
        title: ContactBilingualText(
          en: "WE'VE RECEIVED YOUR MESSAGE — AND WE'RE ON IT!",
          ar: 'لقد استلمنا رسالتك - ونحن نعمل عليها!',
        ),
        description: ContactBilingualText(
          en: "Thanks For Getting In Touch — Your Message Is On Its Way To Our Team. We're Already Reviewing It And Will Connect With You Soon To Keep The Conversation Going.",
          ar: 'شكرا لك على التواصل - رسالتك في طريقها إلى فريقنا. نحن نراجعها بالفعل وسنتواصل معك قريبا لمواصلة المحادثة.',
        ),
      ),
    );
  }
}