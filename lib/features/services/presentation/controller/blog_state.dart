// ******************* FILE INFO *******************
// File Name: blog_state.dart
// Description: States for BlogCubit.
//              Supports dual-document architecture (published + draft per post).
// Created by: Amr Mesbah
// Last Update: 20/04/2026
// UPDATED: Added BlogDraftSaved and BlogDraftDeleted states ✅


import '../../data/models/blog_model.dart';

abstract class BlogState {}

class BlogInitial extends BlogState {}

class BlogLoading extends BlogState {}

class BlogLoaded extends BlogState {
  final List<BlogPostModel> posts;
  BlogLoaded(this.posts);
}
class BlogPostDeleted extends BlogState {}

/// Published/created successfully.
class BlogSaved extends BlogState {
  final BlogPostModel post;
  BlogSaved(this.post);
}

/// Draft saved successfully — published doc was NOT touched.
class BlogDraftSaved extends BlogState {
  final BlogPostModel post;
  BlogDraftSaved(this.post);
}

/// Draft deleted (e.g. user chose Discard while editing a draft).
class BlogDraftDeleted extends BlogState {}

class BlogError extends BlogState {
  final String message;
  BlogError(this.message);
}