// ******************* FILE INFO *******************
// File Name: home_cubit.dart
// Description: BLoC Cubit for Home CMS.
//              Dual-document architecture:
//              - load() checks for draft first, falls back to published
//              - save(publishStatus: 'published') → writes published doc, deletes draft
//              - save(publishStatus: 'draft')     → writes draft doc only
//              - save(publishStatus: 'scheduled')  → writes draft doc with schedule date
//              - discardDraft() → deletes draft doc
// Created by: Amr Mesbah
// Last Update: 20/04/2026
// UPDATED: Dual-document draft system ✅

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/home_model.dart';
import '../../domain/base_repository/home_repo.dart';
import 'home_state.dart';



class HomeCmsCubit extends Cubit<HomeCmsState> {
  HomeCmsCubit({required HomeRepository repository})
      : _repo = repository,
        super(HomeCmsInitial());

  final HomeRepository _repo;
  final _storage = GetStorage();

  HomePageModel _model = HomePageModel.defaultModel;
  HomePageModel get current => _model;

  /// Whether the currently loaded data came from a draft document.
  bool _isFromDraft = false;
  bool get isFromDraft => _isFromDraft;

  static final _rng = Random();
  static String _uid() {
    final ts   = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rand = _rng.nextInt(0xFFFFFF).toRadixString(36).padLeft(5, '0');
    return '${ts}_$rand';
  }

  void _applyFontsToStorage(BrandingModel branding) {
    final engFont = branding.englishFont.isEmpty ? 'Cairo' : branding.englishFont;
    final arFont  = branding.arabicFont.isEmpty  ? 'Cairo' : branding.arabicFont;
    _storage.write('font',         engFont);
    _storage.write('font_arabic',  arFont);
  }

  // ── Merge defaults ────────────────────────────────────────────────────────
  HomePageModel _mergeDefaults(HomePageModel loaded) {
    final defaults = HomePageModel.defaultModel.navButtons;

    final seen = <String>{};
    final deduped = loaded.navButtons.where((b) {
      if (seen.contains(b.id)) return false;
      seen.add(b.id);
      return true;
    }).toList();

    final existingRoutes = deduped.map((b) => b.route).toSet();
    final missing = defaults
        .where((d) => !existingRoutes.contains(d.route))
        .toList();

    final merged = [...deduped, ...missing];
    return loaded.copyWith(
      navButtons: merged,
      footerColumns: _normalizeFooterIds(loaded.footerColumns),
    );
  }

  /// Ensures every footer column and label has a unique, non-empty id.
  /// Old documents stored labels without ids ('' after fromMap), which made
  /// id-based updates hit multiple labels at once → duplicated label text.
  List<FooterColumnModel> _normalizeFooterIds(List<FooterColumnModel> columns) {
    final colIds = <String>{};
    return columns.map((c) {
      var colId = c.id;
      if (colId.isEmpty || colIds.contains(colId)) colId = 'fc_${_uid()}';
      colIds.add(colId);

      final lblIds = <String>{};
      final labels = c.labels.map((l) {
        var lblId = l.id;
        if (lblId.isEmpty || lblIds.contains(lblId)) lblId = 'fl_${_uid()}';
        lblIds.add(lblId);
        return lblId == l.id ? l : l.copyWith(id: lblId);
      }).toList();

      return c.copyWith(id: colId, labels: labels);
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LOAD — draft-first strategy
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> load() async {
    emit(HomeCmsLoading());
    try {
      // 1️⃣ Check if a draft exists
      final draft = await _repo.fetchDraft();
      if (draft != null) {
        final result = _mergeDefaults(draft);
        _model       = result;
        _isFromDraft = true;
        _applyFontsToStorage(_model.branding);
        emit(HomeCmsLoaded(_model, isFromDraft: true));
        return;
      }

      // 2️⃣ No draft — load published
      final fetched = await _repo.fetchHomePageFresh();
      final result = _mergeDefaults(fetched);
      _model       = result;
      _isFromDraft = false;
      _applyFontsToStorage(_model.branding);
      emit(HomeCmsLoaded(_model, isFromDraft: false));
    } catch (e, st) {
      emit(HomeCmsError('Failed to load home page: $e'));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVE — routes to published or draft based on publishStatus
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> save({
    String publishStatus = 'published',
    DateTime? scheduledPublishDate,
  }) async {


    emit(HomeCmsSaving(_model));

    try {
      switch (publishStatus) {
      // ── PUBLISH: save to published doc, delete draft ────────────────
        case 'published':
          final saving = _model.copyWith(
            publishStatus: 'published',
            clearScheduledPublishDate: true,
            lastUpdatedAt: DateTime.now(),
          );
          await _repo.saveHomePage(saving);
          // Clean up any existing draft
          await _repo.deleteDraft();
          _isFromDraft = false;

          // Re-fetch to get server timestamp
          final persisted = await _repo.fetchHomePageFresh();
          _model = _mergeDefaults(persisted);
          _applyFontsToStorage(_model.branding);
          emit(HomeCmsSaved(_model));
          break;

      // ── DRAFT: save to draft doc only, do NOT touch published ───────
        case 'draft':
          final saving = _model.copyWith(
            publishStatus: 'draft',
            clearScheduledPublishDate: true,
            lastUpdatedAt: DateTime.now(),
          );
          await _repo.saveDraft(saving);
          _isFromDraft = true;
          _model = saving;
          emit(HomeCmsDraftSaved(_model));
          break;

      // ── SCHEDULED: save to draft doc with schedule date ─────────────
        case 'scheduled':
          final saving = _model.copyWith(
            publishStatus: 'scheduled',
            scheduledPublishDate: scheduledPublishDate,
            lastUpdatedAt: DateTime.now(),
          );
          await _repo.saveDraft(saving);
          _isFromDraft = true;
          _model = saving;
          emit(HomeCmsDraftSaved(_model));
          break;

        default:
          final saving = _model.copyWith(
            publishStatus: publishStatus,
            lastUpdatedAt: DateTime.now(),
          );
          await _repo.saveDraft(saving);
          _isFromDraft = true;
          _model = saving;
          emit(HomeCmsDraftSaved(_model));
      }
    } catch (e, st) {
      emit(HomeCmsError('Failed to save: $e', _model));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DISCARD DRAFT — deletes the draft doc (published stays untouched)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> discardDraft() async {
    try {
      await _repo.deleteDraft();
      _isFromDraft = false;
      emit(HomeCmsDraftDeleted());
    } catch (e) {
      emit(HomeCmsError('Failed to discard draft: $e', _model));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FIELD UPDATE METHODS (unchanged API)
  // ══════════════════════════════════════════════════════════════════════════

  void updateScheduledPublishDate(DateTime? date) {
    if (date == null) {
      _model = _model.copyWith(clearScheduledPublishDate: true);
    } else {
      _model = _model.copyWith(scheduledPublishDate: date);
    }
  }

  void updateTitle({required String en, required String ar}) {
    _model = _model.copyWith(title: BiText(en: en, ar: ar));
  }

  void updateShortDescription({required String en, required String ar}) {
    _model = _model.copyWith(shortDescription: BiText(en: en, ar: ar));
  }

  // ── Nav Buttons ───────────────────────────────────────────────────────────
  void addNavButton() {
    final updated = List<NavButtonModel>.from(_model.navButtons)
      ..add(NavButtonModel(id: _uid()));
    _model = _model.copyWith(navButtons: updated);
  }

  void removeNavButton(String id) {
    _model = _model.copyWith(
      navButtons: _model.navButtons.where((b) => b.id != id).toList(),
    );
  }

  void reorderNavButtons(int oldIndex, int newIndex) {
    final list = List<NavButtonModel>.from(_model.navButtons);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(navButtons: list);
    emit(HomeCmsLoaded(_model, isFromDraft: _isFromDraft));
  }

  void reorderNavButtonsSilent(int oldIndex, int newIndex) {
    final list = List<NavButtonModel>.from(_model.navButtons);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(navButtons: list);
  }

  void updateNavButtonName(String id,
      {required String en, required String ar}) {
    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) => b.id == id ? b.copyWith(name: BiText(en: en, ar: ar)) : b)
          .toList(),
    );
  }

  void updateNavButtonRoute(String id, String route) {
    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) => b.id == id ? b.copyWith(route: route) : b)
          .toList(),
    );
  }

  void toggleNavButtonStatus(String id) {
    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) => b.id == id ? b.copyWith(status: !b.status) : b)
          .toList(),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────
  void updateSectionTextBoxColor(int index, String color) {
    _updateSection(index, (s) => s.copyWith(textBoxColor: color));
  }

  void updateSectionDescription(int index,
      {required String en, required String ar}) {
    _updateSection(index, (s) => s.copyWith(description: BiText(en: en, ar: ar)));
  }

  void updateSectionVisibility(int index, bool visibility) {
    _updateSection(index, (s) => s.copyWith(visibility: visibility));
  }

  Future<void> uploadSectionImage(int index, Uint8List bytes) async {
    final path = 'home_cms/sections/$index/image_${_uid()}.jpg';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      _updateSection(index, (s) => s.copyWith(imageUrl: url));
    } catch (e, st) {
      emit(HomeCmsError('Section image upload failed: $e', _model));
    }
  }

  Future<void> uploadSectionIcon(int index, Uint8List bytes) async {
    final path = 'home_cms/sections/$index/icon_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      _updateSection(index, (s) => s.copyWith(iconUrl: url));
    } catch (e, st) {
      emit(HomeCmsError('Section icon upload failed: $e', _model));
    }
  }

  void _updateSection(int index, SectionCardModel Function(SectionCardModel) updater) {
    final sections = List<SectionCardModel>.from(_model.sections);
    while (sections.length <= index) {
      // ✅ Assign the fixed slot position when padding new section cards.
      final slot = sections.length;
      sections.add(SectionCardModel(
        position: slot < kSectionPositions.length ? kSectionPositions[slot] : 'left',
      ));
    }
    sections[index] = updater(sections[index]);
    _model = _model.copyWith(sections: sections);
  }

  // ── Header Items ──────────────────────────────────────────────────────────
  void updateHeaderItemTitle(String id, {required String en, required String ar}) {
    _model = _model.copyWith(
      headerItems: _model.headerItems
          .map((h) => h.id == id ? h.copyWith(title: BiText(en: en, ar: ar)) : h)
          .toList(),
    );
  }

  void toggleHeaderItemStatus(String id) {
    _model = _model.copyWith(
      headerItems: _model.headerItems
          .map((h) => h.id == id ? h.copyWith(status: !h.status) : h)
          .toList(),
    );
  }

  void reorderHeaderItems(int oldIndex, int newIndex) {
    final list = List<HeaderItemModel>.from(_model.headerItems);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(headerItems: list);
  }

  // ── Footer Columns ────────────────────────────────────────────────────────
  void addFooterColumn() {
    final updated = List<FooterColumnModel>.from(_model.footerColumns)
      ..add(FooterColumnModel(id: _uid()));
    _model = _model.copyWith(footerColumns: updated);
  }

  void removeFooterColumn(String id) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.where((c) => c.id != id).toList(),
    );
  }

  void updateFooterColumnTitle(String colId, {required String en, required String ar}) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns
          .map((c) => c.id == colId ? c.copyWith(title: BiText(en: en, ar: ar)) : c)
          .toList(),
    );
  }

  void updateFooterColumnRoute(String colId, String route) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns
          .map((c) => c.id == colId ? c.copyWith(route: route) : c)
          .toList(),
    );
  }

  void addFooterLabel(String colId) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(labels: [...c.labels, FooterLabelModel(id: _uid())]);
      }).toList(),
    );
  }

  void removeFooterLabel(String colId, String labelId) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(labels: c.labels.where((l) => l.id != labelId).toList());
      }).toList(),
    );
  }

  void updateFooterLabel(String colId, String labelId,
      {required String en, required String ar}) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
          labels: c.labels
              .map((l) => l.id == labelId ? l.copyWith(label: BiText(en: en, ar: ar)) : l)
              .toList(),
        );
      }).toList(),
    );
  }

  void updateFooterLabelRoute(String colId, String labelId, String route) {
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
          labels: c.labels
              .map((l) => l.id == labelId ? l.copyWith(route: route) : l)
              .toList(),
        );
      }).toList(),
    );
  }

  // ── Social Links ──────────────────────────────────────────────────────────
  void addSocialLink() {
    _model = _model.copyWith(
      socialLinks: [..._model.socialLinks, SocialLinkModel(id: 'sl_${_uid()}')],
    );
  }

  void removeSocialLink(String id) {
    _model = _model.copyWith(
      socialLinks: _model.socialLinks.where((s) => s.id != id).toList(),
    );
  }

  void updateSocialLink(String id, {required String url, bool? visibility}) {
    _model = _model.copyWith(
      socialLinks: _model.socialLinks
          .map((s) => s.id == id
          ? s.copyWith(url: url, visibility: visibility ?? s.visibility)
          : s)
          .toList(),
    );
  }

  Future<void> uploadSocialLinkIcon(String id, Uint8List bytes) async {
    final path = 'home_cms/social_icons/${id}_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      _model = _model.copyWith(
        socialLinks: _model.socialLinks
            .map((s) => s.id == id ? s.copyWith(iconUrl: url) : s)
            .toList(),
      );
    } catch (e, st) {
      emit(HomeCmsError('Social icon upload failed: $e', _model));
    }
  }

  // ── Branding / Logo ───────────────────────────────────────────────────────
  Future<void> uploadLogo(Uint8List bytes) async {
    final path = 'home_cms/branding/logo_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      _model = _model.copyWith(branding: _model.branding.copyWith(logoUrl: url));
    } catch (e, st) {
      emit(HomeCmsError('Logo upload failed: $e', _model));
    }
  }

  void updatePrimaryColor(String hex) {
    _model = _model.copyWith(branding: _model.branding.copyWith(primaryColor: hex));
  }

  void updateSecondaryColor(String hex) {
    _model = _model.copyWith(branding: _model.branding.copyWith(secondaryColor: hex));
  }

  void updateBackgroundColor(String hex) {
    _model = _model.copyWith(branding: _model.branding.copyWith(backgroundColor: hex));
  }

  void updateHeaderFooterColor(String hex) {
    _model = _model.copyWith(branding: _model.branding.copyWith(headerFooterColor: hex));
  }

  void updateMainWidgetColor(String hex) {
    _model = _model.copyWith(branding: _model.branding.copyWith(mainWidgetColor: hex));
  }

  void updateEnglishFont(String font) {
    _model = _model.copyWith(branding: _model.branding.copyWith(englishFont: font));
  }

  void updateArabicFont(String font) {
    _model = _model.copyWith(branding: _model.branding.copyWith(arabicFont: font));
  }
}