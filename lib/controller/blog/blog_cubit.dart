  // ******************* FILE INFO *******************
  // File Name: blog_cubit.dart
  // Created by: Amr Mesbah

  import 'dart:typed_data';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:web_app_admin/model/blog_model.dart';
  import 'package:web_app_admin/repo/blog/blog_repo.dart';
  import 'package:web_app_admin/repo/blog/blog_repo_impl.dart';
  import 'blog_state.dart';

  class BlogCubit extends Cubit<BlogState> {
    BlogCubit({BlogRepository? repo})
        : _repo = repo ?? BlogRepositoryImpl(),
          super(BlogInitial());

    final BlogRepository _repo;
    List<BlogPostModel> _posts = [];
    List<BlogPostModel> get posts => _posts;

    // ── Load all ──────────────────────────────────────────────────────────────
    Future<void> load() async {
      print('🟡 [BlogCubit] load()');
      emit(BlogLoading());
      try {
        _posts = await _repo.fetchAllPosts();
        emit(BlogLoaded(_posts));
      } catch (e) {
        emit(BlogError(e.toString()));
      }
    }

    // ── Create ────────────────────────────────────────────────────────────────
    Future<void> createPost({
      required BlogPostModel post,
      Uint8List?             imageBytes,
    }) async {
      print('🟡 [BlogCubit] createPost()');
      emit(BlogLoading());
      try {
        BlogPostModel toSave = post;
        // Upload image first if provided
        if (imageBytes != null) {
          final tempId = 'blog_${DateTime.now().microsecondsSinceEpoch}';
          final url    = await _repo.uploadImage(
              bytes: imageBytes, storagePath: 'blog_cms/$tempId/cover');
          toSave = toSave.copyWith(imageUrl: url);
        }
        final newId = await _repo.createPost(toSave);
        toSave = toSave.copyWith(id: newId);
        _posts = [toSave, ..._posts];
        emit(BlogPostSaved(toSave));
      } catch (e) {
        emit(BlogError(e.toString()));
      }
    }

    // ── Update ────────────────────────────────────────────────────────────────
    Future<void> updatePost({
      required BlogPostModel post,
      Uint8List?             imageBytes,
    }) async {
      print('🟡 [BlogCubit] updatePost(${post.id})');
      emit(BlogLoading());
      try {
        BlogPostModel toSave = post;
        if (imageBytes != null) {
          final url = await _repo.uploadImage(
              bytes: imageBytes, storagePath: 'blog_cms/${post.id}/cover');
          toSave = toSave.copyWith(imageUrl: url);
        }
        await _repo.updatePost(toSave);
        _posts = _posts.map((p) => p.id == toSave.id ? toSave : p).toList();
        emit(BlogPostSaved(toSave));
      } catch (e) {
        emit(BlogError(e.toString()));
      }
    }

    // ── Delete ────────────────────────────────────────────────────────────────
    Future<void> deletePost(String id) async {
      print('🟡 [BlogCubit] deletePost($id)');
      emit(BlogLoading());
      try {
        await _repo.deletePost(id);
        _posts = _posts.where((p) => p.id != id).toList();
        emit(BlogPostDeleted());
        emit(BlogLoaded(_posts));
      } catch (e) {
        emit(BlogError(e.toString()));
      }
    }
  }