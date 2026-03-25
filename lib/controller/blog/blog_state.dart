// ******************* FILE INFO *******************
// File Name: blog_state.dart
// Created by: Amr Mesbah

import 'package:web_app_admin/model/blog_model.dart';

abstract class BlogState {}

class BlogInitial   extends BlogState {}
class BlogLoading   extends BlogState {}
class BlogLoaded    extends BlogState {
  final List<BlogPostModel> posts;
  BlogLoaded(this.posts);
}
class BlogPostSaved   extends BlogState { final BlogPostModel post; BlogPostSaved(this.post); }
class BlogPostDeleted extends BlogState {}
class BlogError       extends BlogState { final String message; BlogError(this.message); }