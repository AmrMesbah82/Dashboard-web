// ******************* FILE INFO *******************
// File Name: contact_repo_impl.dart
// Created by: Amr Mesbah

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/repo/contact_us/contact_us_repo.dart';

class ContactRepoImpl implements ContactRepo {
  final _col = FirebaseFirestore.instance.collection('contact_submissions');

  // ── Submit (public website) ────────────────────────────────────────────────

  @override
  Future<void> submitContact(ContactSubmission submission) async {
    final doc = _col.doc();
    await doc.set(submission.copyWith(id: doc.id).toMap());
  }

  // ── Fetch all (admin) ──────────────────────────────────────────────────────

  @override
  Future<List<ContactSubmission>> fetchAll() async {
    final snap = await _col
        .orderBy('submissionDate', descending: true)
        .get();
    return snap.docs
        .map((d) => ContactSubmission.fromMap(d.id, d.data()))
        .toList();
  }

  // ── Update (admin: status / note) ─────────────────────────────────────────

  @override
  Future<void> updateSubmission(ContactSubmission submission) async {
    await _col.doc(submission.id).update({
      'status': submission.status,
      'note':   submission.note,
    });
  }
}