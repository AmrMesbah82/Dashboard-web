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
import 'package:web_app_admin/model/blog_model.dart';
import 'blog_repo.dart';

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
    print('🔵 [BlogRepo] fetchAllPosts()');
    try {
      final snap = await _col.orderBy('createdAt', descending: true).get();
      // Filter out draft documents (those ending with _draft)
      final posts = snap.docs
          .where((d) => !d.id.endsWith('_draft'))
          .map((d) => BlogPostModel.fromMap(d.id, _sanitize(d.data())))
          .toList();
      print('🟢 [BlogRepo] fetchAllPosts() → ${posts.length} posts');
      return posts;
    } catch (e) {
      print('🔴 [BlogRepo] fetchAllPosts() ERROR: $e');
      return [];
    }
  }

  @override
  Future<BlogPostModel> fetchPost(String id) async {
    print('🔵 [BlogRepo] fetchPost($id)');
    try {
      final snap = await _col.doc(id).get();
      if (!snap.exists || snap.data() == null) return BlogPostModel.empty();
      return BlogPostModel.fromMap(snap.id, _sanitize(snap.data()!));
    } catch (e) {
      print('🔴 [BlogRepo] fetchPost() ERROR: $e');
      return BlogPostModel.empty();
    }
  }

  @override
  Future<BlogPostModel?> fetchPostById(String id) async {
    print('🔵 [BlogRepo] fetchPostById($id)');
    try {
      final snap = await _col.doc(id).get();
      if (!snap.exists || snap.data() == null) return null;
      return BlogPostModel.fromMap(snap.id, _sanitize(snap.data()!));
    } catch (e) {
      print('🔴 [BlogRepo] fetchPostById() ERROR: $e');
      return null;
    }
  }

  @override
  Future<String> createPost(BlogPostModel post) async {
    print('🔵 [BlogRepo] createPost()');
    try {
      final ref = await _col.add({
        ...post.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('🟢 [BlogRepo] createPost() → id=${ref.id}');
      return ref.id;
    } catch (e) {
      print('🔴 [BlogRepo] createPost() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePost(BlogPostModel post) async {
    print('🔵 [BlogRepo] updatePost(${post.id})');
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
      print('🟢 [BlogRepo] updatePost() done');
    } catch (e) {
      print('🔴 [BlogRepo] updatePost() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePost(String id) async {
    print('🔵 [BlogRepo] deletePost($id)');
    try {
      await _col.doc(id).delete();
      // Also delete any draft for this post
      final draftRef = _col.doc('${id}_draft');
      final draftSnap = await draftRef.get();
      if (draftSnap.exists) {
        await draftRef.delete();
        print('🟢 [BlogRepo] deletePost() → also deleted draft');
      }
      print('🟢 [BlogRepo] deletePost() done');
    } catch (e) {
      print('🔴 [BlogRepo] deletePost() ERROR: $e');
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
    print('🟡 [BlogRepo] fetchDraft($postId)');
    try {
      final snap = await _col.doc('${postId}_draft').get();
      if (snap.exists && snap.data() != null) {
        print('🟢 [BlogRepo] fetchDraft() → draft found');
        return BlogPostModel.fromMap(postId, _sanitize(snap.data()!));
      }
      print('🟡 [BlogRepo] fetchDraft() → no draft exists');
      return null;
    } catch (e) {
      print('🔴 [BlogRepo] fetchDraft() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveDraft(BlogPostModel post) async {
    final draftId = '${post.id}_draft';
    print('🟡 [BlogRepo] saveDraft() draftId=$draftId status=${post.status}');
    try {
      await _col.doc(draftId).set({
        ...post.toMap(),
        'originalPostId': post.id,
        'createdAt': post.createdAt != null
            ? Timestamp.fromDate(post.createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('🟢 [BlogRepo] saveDraft() done');
    } catch (e) {
      print('🔴 [BlogRepo] saveDraft() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteDraft(String postId) async {
    print('🟡 [BlogRepo] deleteDraft($postId)');
    try {
      final ref = _col.doc('${postId}_draft');
      final snap = await ref.get();
      if (snap.exists) {
        await ref.delete();
        print('🟢 [BlogRepo] deleteDraft() → deleted');
      } else {
        print('🟡 [BlogRepo] deleteDraft() → no draft to delete');
      }
    } catch (e) {
      print('🔴 [BlogRepo] deleteDraft() ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> promoteDraft(String postId) async {
    print('🟡 [BlogRepo] promoteDraft($postId)');
    try {
      final draft = await fetchDraft(postId);
      if (draft == null) {
        print('🟡 [BlogRepo] promoteDraft() → no draft to promote');
        return;
      }
      final publishedModel = draft.copyWith(status: 'published');
      await updatePost(publishedModel);
      await deleteDraft(postId);
      print('🟢 [BlogRepo] promoteDraft() → DONE');
    } catch (e) {
      print('🔴 [BlogRepo] promoteDraft() ERROR: $e');
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  ASSETS
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<String> uploadImage({required Uint8List bytes, required String storagePath}) async {
    print('🔵 [BlogRepo] uploadImage() path=$storagePath');
    try {
      final ref  = _storage.ref().child(storagePath);
      final mime = _detectMime(bytes);
      final task = await ref.putData(bytes, SettableMetadata(contentType: mime));
      final url  = await task.ref.getDownloadURL();
      print('🟢 [BlogRepo] uploadImage() → $url');
      return url;
    } catch (e) {
      print('🔴 [BlogRepo] uploadImage() ERROR: $e');
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