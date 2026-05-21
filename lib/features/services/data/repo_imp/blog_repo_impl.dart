// ******************* FILE INFO *******************
// File Name: blog_repo_impl.dart
// Description: Firebase implementation of BlogRepository.
//              Dual-document architecture per post:
//              - Published → `blog_posts/{id}`
//              - Draft     → `blog_posts/{id}_draft`
// Created by: Amr Mesbah
// Last Update: 20/04/2026
// UPDATED: Per-post dual-document draft system ✅

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repo/blog_repo.dart';
import '../models/blog_model.dart';

class BlogRepositoryImpl implements BlogRepository {
  BlogRepositoryImpl({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage   = storage   ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage   _storage;

  static const String _collection = 'blog_posts';

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  // ═════════════════════════════════════════════════════════════════════════
  //  PUBLISHED DOCUMENTS
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<List<BlogPostModel>> fetchAllPosts() async {
    try {
      final snap = await _col.orderBy('createdAt', descending: true).get();
      // Filter out draft documents (those ending with _draft)
      final posts = snap.docs
          .where((d) => !d.id.endsWith('_draft'))
          .map((d) => BlogPostModel.fromMap(d.id, _sanitize(d.data())))
          .toList();
      return posts;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<BlogPostModel> fetchPost(String id) async {
    try {
      final snap = await _col.doc(id).get();
      if (!snap.exists || snap.data() == null) return BlogPostModel.empty();
      return BlogPostModel.fromMap(snap.id, _sanitize(snap.data()!));
    } catch (e) {
      return BlogPostModel.empty();
    }
  }

  @override
  Future<BlogPostModel?> fetchPostById(String id) async {
    try {
      final snap = await _col.doc(id).get();
      if (!snap.exists || snap.data() == null) return null;
      return BlogPostModel.fromMap(snap.id, _sanitize(snap.data()!));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> createPost(BlogPostModel post) async {
    try {
      final ref = await _col.add({
        ...post.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePost(BlogPostModel post) async {
    try {
      final docRef = _col.doc(post.id);
      await docRef.update({
        'status': post.status,
        'imageUrl': post.imageUrl,
        'question.en': post.question.en,
        'question.ar': post.question.ar,
        'shortDescription.en': post.shortDescription.en,
        'shortDescription.ar': post.shortDescription.ar,
        'buttonLabel.en': post.buttonLabel.en,
        'buttonLabel.ar': post.buttonLabel.ar,
        'descriptionTitle.en': post.descriptionTitle.en,
        'descriptionTitle.ar': post.descriptionTitle.ar,
        'blocks': post.blocks.map((b) => {
          'id': b.id,
          'type': b.type.toString().split('.').last,
          'content': {
            'en': b.content.en,
            'ar': b.content.ar,
          },
        }).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      await _col.doc(id).delete();
      // Also delete any draft for this post
      final draftRef = _col.doc('${id}_draft');
      final draftSnap = await draftRef.get();
      if (draftSnap.exists) {
        await draftRef.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<BlogPostModel>> watchAllPosts() {
    return _col.orderBy('createdAt', descending: true).snapshots().map((snap) =>
        snap.docs
            .where((d) => !d.id.endsWith('_draft'))
            .map((d) => BlogPostModel.fromMap(d.id, _sanitize(d.data())))
            .toList());
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  PER-POST DRAFT DOCUMENTS
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<BlogPostModel?> fetchDraft(String postId) async {
    try {
      final snap = await _col.doc('${postId}_draft').get();
      if (snap.exists && snap.data() != null) {
        return BlogPostModel.fromMap(postId, _sanitize(snap.data()!));
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveDraft(BlogPostModel post) async {
    final draftId = '${post.id}_draft';
    try {
      await _col.doc(draftId).set({
        ...post.toMap(),
        'originalPostId': post.id,
        'createdAt': post.createdAt != null
            ? Timestamp.fromDate(post.createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDraft(String postId) async {
    try {
      final ref = _col.doc('${postId}_draft');
      final snap = await ref.get();
      if (snap.exists) {
        await ref.delete();
      } else {
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> promoteDraft(String postId) async {
    try {
      final draft = await fetchDraft(postId);
      if (draft == null) {
        return;
      }
      final publishedModel = draft.copyWith(status: 'published');
      await updatePost(publishedModel);
      await deleteDraft(postId);
    } catch (e) {
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  ASSETS
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<String> uploadImage({required Uint8List bytes, required String storagePath}) async {
    try {
      final ref  = _storage.ref().child(storagePath);
      final mime = _detectMime(bytes);
      final task = await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url  = await task.ref.getDownloadURL();
      return url;
    } catch (e) {
      rethrow;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _sanitize(Map<String, dynamic> d) {
    final copy = Map<String, dynamic>.from(d);
    copy.remove('updatedAt');
    return copy;
  }

  String _detectMime(Uint8List b) {
    if (b.length < 4) return 'application/octet-stream';
    if (b[0] == 0x89 && b[1] == 0x50) return 'image/png';
    if (b[0] == 0xFF && b[1] == 0xD8) return 'image/jpeg';
    if (b[0] == 0x47 && b[1] == 0x49) return 'image/gif';
    if (b[0] == 0x52 && b[1] == 0x49 && b.length >= 12 &&
        b[8] == 0x57 && b[9] == 0x45) return 'image/webp';
    if (b[0] == 0x3C) return 'image/svg+xml';
    return 'image/jpeg';
  }
}