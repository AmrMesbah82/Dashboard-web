// ******************* FILE INFO *******************
// File Name: blog_cubit.dart
// Description: Cubit for Blog CMS.
//              Dual-document architecture per post:
//              - createPost/updatePost with status='published' → writes published doc, deletes draft
//              - createPost/updatePost with status='draft' → writes draft doc only
//              - discardDraft() → deletes draft doc
// Created by: Amr Mesbah
// Last Update: 20/04/2026
// UPDATED: Per-post dual-document draft system ✅

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/blog_model.dart';
import '../../domain/repo/blog_repo.dart';
import 'blog_state.dart';

// Import repo — adjust path to match your project structure

class BlogCubit extends Cubit<BlogState> {
  final BlogRepository _repo;

  BlogCubit(this._repo) : super(BlogInitial());

  List<BlogPostModel> _posts = [];
  List<BlogPostModel> get posts => _posts;

  // ══════════════════════════════════════════════════════════════════════════
  //  LOAD
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> load() async {
    print('🔵 [BlogCubit] load()');
    emit(BlogLoading());
    try {
      _posts = await _repo.fetchAllPosts();
      print('🟢 [BlogCubit] load() → ${_posts.length} posts');
      emit(BlogLoaded(_posts));
    } catch (e) {
      print('🔴 [BlogCubit] load() ERROR: $e');
      emit(BlogError(e.toString()));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CREATE POST — routes to published or draft
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> createPost({
    required BlogPostModel post,
    Uint8List? imageBytes,
  }) async {
    print('🔵 [BlogCubit] createPost() status=${post.status}');
    try {
      String imageUrl = post.imageUrl;

      // Upload image if provided
      if (imageBytes != null) {
        final path = 'blog_images/${DateTime.now().millisecondsSinceEpoch}.svg';
        imageUrl = await _repo.uploadImage(bytes: imageBytes, storagePath: path);
        print('🟢 [BlogCubit] createPost() → image uploaded: $imageUrl');
      }

      final postWithImage = post.copyWith(imageUrl: imageUrl);

      switch (post.status) {
      // ── PUBLISH: create the published doc directly ──────────────────
        case 'published':
          print('🟡 [BlogCubit] createPost → creating as published');
          final newId = await _repo.createPost(postWithImage);
          final saved = postWithImage.copyWith(id: newId);
          print('🟢 [BlogCubit] createPost: ✅ published id=$newId');
          emit(BlogSaved(saved));
          break;

      // ── DRAFT: create the published doc as draft ────────────────────
      // For new posts, we create the doc with status='draft' directly
      // (no separate _draft doc needed since there's no published version)
        case 'draft':
        default:
          print('🟡 [BlogCubit] createPost → creating as draft');
          final newId = await _repo.createPost(postWithImage);
          final saved = postWithImage.copyWith(id: newId);
          print('🟢 [BlogCubit] createPost: ✅ draft id=$newId');
          emit(BlogDraftSaved(saved));
          break;
      }
    } catch (e) {
      print('🔴 [BlogCubit] createPost() ERROR: $e');
      emit(BlogError(e.toString()));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UPDATE POST — routes to published or draft
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> updatePost({
    required BlogPostModel post,
    Uint8List? imageBytes,
  }) async {
    print('🔵 [BlogCubit] updatePost() id=${post.id} status=${post.status}');
    try {
      String imageUrl = post.imageUrl;

      // Upload image if provided
      if (imageBytes != null) {
        final path = 'blog_images/${post.id}_${DateTime.now().millisecondsSinceEpoch}.svg';
        imageUrl = await _repo.uploadImage(bytes: imageBytes, storagePath: path);
        print('🟢 [BlogCubit] updatePost() → image uploaded: $imageUrl');
      }

      final postWithImage = post.copyWith(imageUrl: imageUrl);

      switch (post.status) {
      // ── PUBLISH: update the published doc, delete any draft ──────────
        case 'published':
          print('🟡 [BlogCubit] updatePost → publishing to live doc');
          await _repo.updatePost(postWithImage);
          // Clean up any existing draft for this post
          await _repo.deleteDraft(post.id);
          print('🟢 [BlogCubit] updatePost: ✅ published + draft cleaned');
          emit(BlogSaved(postWithImage));
          break;

      // ── DRAFT: save to draft doc only, do NOT touch published ────────
        case 'draft':
        default:
          print('🟡 [BlogCubit] updatePost → saving draft only');
          // Check if this post already exists as published
          final existingPublished = await _repo.fetchPostById(post.id);
          if (existingPublished != null && existingPublished.status == 'published') {
            // Published version exists — save edits as a separate draft doc
            await _repo.saveDraft(postWithImage);
            print('🟢 [BlogCubit] updatePost: ✅ draft saved (published stays live)');
          } else {
            // No published version — just update the doc directly with draft status
            await _repo.updatePost(postWithImage);
            print('🟢 [BlogCubit] updatePost: ✅ draft updated directly');
          }
          emit(BlogDraftSaved(postWithImage));
          break;
      }
    } catch (e) {
      print('🔴 [BlogCubit] updatePost() ERROR: $e');
      emit(BlogError(e.toString()));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DISCARD DRAFT — deletes the draft doc (published stays untouched)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> discardDraft(String postId) async {
    print('🟡 [BlogCubit] discardDraft() postId=$postId');
    try {
      await _repo.deleteDraft(postId);
      print('🟢 [BlogCubit] discardDraft: ✅ DONE');
      emit(BlogDraftDeleted());
    } catch (e) {
      print('🔴 [BlogCubit] discardDraft: ERROR $e');
      emit(BlogError(e.toString()));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FETCH POST WITH DRAFT-FIRST STRATEGY
  // ══════════════════════════════════════════════════════════════════════════
  /// Loads a post for editing — checks for draft first, falls back to published.
  /// Returns the model and whether it came from a draft.
  Future<({BlogPostModel post, bool isFromDraft})> fetchForEdit(String postId) async {
    print('🔵 [BlogCubit] fetchForEdit() postId=$postId');
    try {
      // 1️⃣ Check if a draft exists
      final draft = await _repo.fetchDraft(postId);
      if (draft != null) {
        print('🟢 [BlogCubit] fetchForEdit: draft found');
        return (post: draft, isFromDraft: true);
      }

      // 2️⃣ No draft — load published
      print('🟡 [BlogCubit] fetchForEdit: no draft — loading published');
      final published = await _repo.fetchPost(postId);
      return (post: published, isFromDraft: false);
    } catch (e) {
      print('🔴 [BlogCubit] fetchForEdit() ERROR: $e');
      rethrow;
    }
  }

  // ── Delete post ───────────────────────────────────────────────────────────
  Future<void> deletePost(String id) async {
    print('🔵 [BlogCubit] deletePost() id=$id');
    try {
      await _repo.deletePost(id);
      print('🟢 [BlogCubit] deletePost: ✅ DONE');
      await load(); // Refresh list
    } catch (e) {
      print('🔴 [BlogCubit] deletePost() ERROR: $e');
      emit(BlogError(e.toString()));
    }
  }
}