// ******************* FILE INFO *******************
// File Name: blog_repo.dart
// Created by: Amr Mesbah

import 'dart:typed_data';
import 'package:web_app_admin/model/blog_model.dart';

abstract class BlogRepository {
  Future<List<BlogPostModel>> fetchAllPosts();
  Future<BlogPostModel>       fetchPost(String id);
  Future<String>              createPost(BlogPostModel post);   // returns new doc ID
  Future<void>                updatePost(BlogPostModel post);
  Future<void>                deletePost(String id);
  Future<String>              uploadImage({required Uint8List bytes, required String storagePath});
  Stream<List<BlogPostModel>> watchAllPosts();
}