// ******************* FILE INFO *******************
// File Name: home_cubit.dart
// Description: BLoC Cubit for Home CMS.
// Created by: Amr Mesbah
// FIXED: load() now calls _mergeDefaults() which ensures navButtons always
//        contains all 5 default routes, filling in any missing ones from
//        HomePageModel.defaultModel without overwriting existing saved items.
// FIXED: _mergeDefaults() now PRESERVES Firestore order instead of rebuilding
//        from defaultModel order — fixes reorder not persisting after save.
// ADDED: reorderNavButtons() — reorders navButtons list and emits live update
// ADDED: toggleNavButtonStatus() — toggles a nav button's status field
// FIXED: updateSocialLink() now accepts visibility param ✅
// ADDED: _applyFontsToStorage() — writes selected fonts to GetStorage so
//        AppTextStyles picks them up immediately after load/save ✅

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'package:web_app_admin/controller/home_state.dart';
import 'package:web_app_admin/model/home_model.dart';
import 'package:web_app_admin/repo/repo.dart';

class HomeCmsCubit extends Cubit<HomeCmsState> {
  HomeCmsCubit({required HomeRepository repository})
      : _repo = repository,
        super(HomeCmsInitial());

  final HomeRepository _repo;
  final _storage = GetStorage();

  HomePageModel _model = HomePageModel.defaultModel;

  HomePageModel get current => _model;

  static final _rng = Random();
  static String _uid() {
    final ts   = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rand = _rng.nextInt(0xFFFFFF).toRadixString(36).padLeft(5, '0');
    return '${ts}_$rand';
  }

  // ✅ writes branding fonts to GetStorage so AppTextStyles reads them
  void _applyFontsToStorage(BrandingModel branding) {
    final engFont = branding.englishFont.isEmpty ? 'Cairo' : branding.englishFont;
    final arFont  = branding.arabicFont.isEmpty  ? 'Cairo' : branding.arabicFont;
    _storage.write('font',         engFont);
    _storage.write('font_arabic',  arFont);
    print('✅ [HomeCubit] _applyFontsToStorage() '
        'font=$engFont font_arabic=$arFont');
  }

  // ── Merge defaults ────────────────────────────────────────────────────────
  // FIXED: preserves Firestore order — only appends truly missing routes at end
  HomePageModel _mergeDefaults(HomePageModel loaded) {
    final defaults = HomePageModel.defaultModel.navButtons;

    // STEP 1: Deduplicate by id — keep first occurrence only
    final seen = <String>{};
    final deduped = loaded.navButtons.where((b) {
      if (seen.contains(b.id)) {
        print('⚠️  [HomeCubit] _mergeDefaults: removing duplicate id=${b.id}');
        return false;
      }
      seen.add(b.id);
      return true;
    }).toList();

    // STEP 2: Append only routes that are completely missing from Firestore
    // ✅ Do NOT rebuild from defaults order — keep loaded order as-is
    final existingRoutes = deduped.map((b) => b.route).toSet();
    final missing = defaults
        .where((d) => !existingRoutes.contains(d.route))
        .toList();

    if (missing.isNotEmpty) {
      for (final m in missing) {
        print('   + inserting missing navButton: '
            'en=${m.name.en} route=${m.route}');
      }
    }

    // ✅ Preserve Firestore order — missing items appended at end only
    final merged = [...deduped, ...missing];

    print('✅ [HomeCubit] _mergeDefaults() — result: ${merged.length} items');
    for (var i = 0; i < merged.length; i++) {
      print('   navButtons[$i] → '
          'en=${merged[i].name.en} '
          'route=${merged[i].route} '
          'status=${merged[i].status}');
    }

    return loaded.copyWith(navButtons: merged);
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    print('🔵 [HomeCubit] load() called');
    emit(HomeCmsLoading());
    try {
      print('🔵 [HomeCubit] load() → fetching fresh from server...');
      final fetched = await _repo.fetchHomePageFresh();
      print('🟢 [HomeCubit] load() SUCCESS');
      print('   title.en               = ${fetched.title.en}');
      print('   navButtons.length      = ${fetched.navButtons.length}');
      print('   sections.length        = ${fetched.sections.length}');
      print('   branding.logoUrl       = ${fetched.branding.logoUrl}');

      final result = _mergeDefaults(fetched);
      print('   navButtons after merge = ${result.navButtons.length}');
      for (var i = 0; i < result.navButtons.length; i++) {
        print('   navButtons[$i] → '
            'en=${result.navButtons[i].name.en} | '
            'route=${result.navButtons[i].route} | '
            'status=${result.navButtons[i].status}');
      }

      for (var i = 0; i < result.socialLinks.length; i++) {
        print('   socialLinks[$i] → '
            'id=${result.socialLinks[i].id} '
            'visibility=${result.socialLinks[i].visibility} '
            'url=${result.socialLinks[i].url}');
      }

      _model = result;
      _applyFontsToStorage(_model.branding);
      emit(HomeCmsLoaded(_model));
    } catch (e, st) {
      print('🔴 [HomeCubit] load() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Failed to load home page: $e'));
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> save({String publishStatus = 'published'}) async {
    print('🔵 [HomeCubit] save() called — publishStatus=$publishStatus');
    print('   _model.navButtons.length = ${_model.navButtons.length}');
    for (var i = 0; i < _model.navButtons.length; i++) {
      print('   BEFORE SAVE navButtons[$i] → '
          'id=${_model.navButtons[i].id} '
          'en=${_model.navButtons[i].name.en} '
          'route=${_model.navButtons[i].route} '
          'status=${_model.navButtons[i].status}');
    }
    for (var i = 0; i < _model.socialLinks.length; i++) {
      print('   BEFORE SAVE socialLinks[$i] → '
          'id=${_model.socialLinks[i].id} '
          'visibility=${_model.socialLinks[i].visibility}');
    }

    emit(HomeCmsSaving(_model));

    try {
      final saving = _model.copyWith(publishStatus: publishStatus);

      print('🔵 [HomeCubit] save() → calling _repo.saveHomePage()...');
      await _repo.saveHomePage(saving);
      print('🟢 [HomeCubit] save() → saveHomePage() DONE');

      print('🔵 [HomeCubit] save() → calling _repo.fetchHomePageFresh()...');
      final fetched = await _repo.fetchHomePageFresh();
      print('🟢 [HomeCubit] save() → fetchHomePageFresh() DONE');

      final persisted = _mergeDefaults(fetched);
      print('   persisted.navButtons.length = ${persisted.navButtons.length}');
      for (var i = 0; i < persisted.navButtons.length; i++) {
        print('   AFTER SAVE navButtons[$i] → '
            'id=${persisted.navButtons[i].id} '
            'en=${persisted.navButtons[i].name.en} '
            'route=${persisted.navButtons[i].route} '
            'status=${persisted.navButtons[i].status}');
      }
      for (var i = 0; i < persisted.socialLinks.length; i++) {
        print('   AFTER SAVE socialLinks[$i] → '
            'id=${persisted.socialLinks[i].id} '
            'visibility=${persisted.socialLinks[i].visibility}');
      }

      _model = persisted;
      _applyFontsToStorage(_model.branding);
      emit(HomeCmsSaved(_model));
      print('🟢 [HomeCubit] save() → emitted HomeCmsSaved');

    } catch (e, st) {
      print('🔴 [HomeCubit] save() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Failed to save: $e', _model));
    }
  }

  // ── Headings ──────────────────────────────────────────────────────────────

  void updateTitle({required String en, required String ar}) {
    print('🔵 [HomeCubit] updateTitle() en="$en" ar="$ar"');
    _model = _model.copyWith(title: BiText(en: en, ar: ar));
  }

  void updateShortDescription({required String en, required String ar}) {
    print('🔵 [HomeCubit] updateShortDescription() en="$en"');
    _model = _model.copyWith(shortDescription: BiText(en: en, ar: ar));
  }

  // ── Nav Buttons ───────────────────────────────────────────────────────────

  void addNavButton() {
    print('🔵 [HomeCubit] addNavButton()');
    final updated = List<NavButtonModel>.from(_model.navButtons)
      ..add(NavButtonModel(id: _uid()));
    _model = _model.copyWith(navButtons: updated);
  }

  void removeNavButton(String id) {
    print('🔵 [HomeCubit] removeNavButton() id=$id');
    _model = _model.copyWith(
      navButtons: _model.navButtons.where((b) => b.id != id).toList(),
    );
  }

  /// ✅ ADDED: reorders navButtons list and emits live update so navbar rebuilds
  void reorderNavButtons(int oldIndex, int newIndex) {
    print('🔵 [HomeCubit] reorderNavButtons() $oldIndex → $newIndex');
    final list = List<NavButtonModel>.from(_model.navButtons);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(navButtons: list);
    emit(HomeCmsLoaded(_model)); // live navbar rebuild immediately
    print('🟢 [HomeCubit] reorderNavButtons() done — new order:');
    for (var i = 0; i < _model.navButtons.length; i++) {
      print('   [$i] en=${_model.navButtons[i].name.en} '
          'route=${_model.navButtons[i].route}');
    }
  }

  void updateNavButtonName(String id,
      {required String en, required String ar}) {
    print('🔵 [HomeCubit] updateNavButtonName() id=$id en="$en"');
    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) =>
      b.id == id ? b.copyWith(name: BiText(en: en, ar: ar)) : b)
          .toList(),
    );
  }

  void updateNavButtonRoute(String id, String route) {
    print('🔵 [HomeCubit] updateNavButtonRoute() id=$id route="$route"');
    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) => b.id == id ? b.copyWith(route: route) : b)
          .toList(),
    );
  }

  void toggleNavButtonStatus(String id) {
    final before = _model.navButtons
        .where((b) => b.id == id)
        .map((b) => b.status)
        .firstOrNull;
    print('🔵 [HomeCubit] toggleNavButtonStatus() '
        'id=$id before=$before → ${!(before ?? true)}');

    _model = _model.copyWith(
      navButtons: _model.navButtons
          .map((b) => b.id == id ? b.copyWith(status: !b.status) : b)
          .toList(),
    );

    final after = _model.navButtons
        .where((b) => b.id == id)
        .map((b) => b.status)
        .firstOrNull;
    print('🟢 [HomeCubit] toggleNavButtonStatus() id=$id after=$after ✅');
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  void updateSectionTextBoxColor(int index, String color) {
    print('🔵 [HomeCubit] updateSectionTextBoxColor() index=$index color=$color');
    _updateSection(index, (s) => s.copyWith(textBoxColor: color));
  }

  void updateSectionDescription(int index,
      {required String en, required String ar}) {
    print('🔵 [HomeCubit] updateSectionDescription() index=$index en="$en"');
    _updateSection(
        index, (s) => s.copyWith(description: BiText(en: en, ar: ar)));
  }

  Future<void> uploadSectionImage(int index, Uint8List bytes) async {
    print('🔵 [HomeCubit] uploadSectionImage() '
        'index=$index bytes=${bytes.length}');
    final path = 'home_cms/sections/$index/image_${_uid()}.jpg';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadSectionImage() SUCCESS → url=$url');
      _updateSection(index, (s) => s.copyWith(imageUrl: url));
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadSectionImage() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Section image upload failed: $e', _model));
    }
  }

  Future<void> uploadSectionIcon(int index, Uint8List bytes) async {
    print('🔵 [HomeCubit] uploadSectionIcon() '
        'index=$index bytes=${bytes.length}');
    final path = 'home_cms/sections/$index/icon_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadSectionIcon() SUCCESS → url=$url');
      _updateSection(index, (s) => s.copyWith(iconUrl: url));
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadSectionIcon() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Section icon upload failed: $e', _model));
    }
  }

  void _updateSection(
      int index, SectionCardModel Function(SectionCardModel) updater) {
    final sections = List<SectionCardModel>.from(_model.sections);
    while (sections.length <= index) {
      sections.add(const SectionCardModel());
    }
    sections[index] = updater(sections[index]);
    _model = _model.copyWith(sections: sections);
  }

  // ── Header Items ──────────────────────────────────────────────────────────

  void updateHeaderItemTitle(String id,
      {required String en, required String ar}) {
    print('🔵 [HomeCubit] updateHeaderItemTitle() id=$id en="$en"');
    _model = _model.copyWith(
      headerItems: _model.headerItems
          .map((h) =>
      h.id == id ? h.copyWith(title: BiText(en: en, ar: ar)) : h)
          .toList(),
    );
  }

  void toggleHeaderItemStatus(String id) {
    print('🔵 [HomeCubit] toggleHeaderItemStatus() id=$id');
    _model = _model.copyWith(
      headerItems: _model.headerItems
          .map((h) => h.id == id ? h.copyWith(status: !h.status) : h)
          .toList(),
    );
  }

  void reorderHeaderItems(int oldIndex, int newIndex) {
    print('🔵 [HomeCubit] reorderHeaderItems() $oldIndex → $newIndex');
    final list = List<HeaderItemModel>.from(_model.headerItems);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(headerItems: list);
  }

  // ── Footer Columns ────────────────────────────────────────────────────────

  void addFooterColumn() {
    print('🔵 [HomeCubit] addFooterColumn()');
    final updated = List<FooterColumnModel>.from(_model.footerColumns)
      ..add(FooterColumnModel(id: _uid()));
    _model = _model.copyWith(footerColumns: updated);
  }

  void removeFooterColumn(String id) {
    print('🔵 [HomeCubit] removeFooterColumn() id=$id');
    _model = _model.copyWith(
      footerColumns:
      _model.footerColumns.where((c) => c.id != id).toList(),
    );
  }

  void updateFooterColumnTitle(String colId,
      {required String en, required String ar}) {
    print('🔵 [HomeCubit] updateFooterColumnTitle() colId=$colId en="$en"');
    _model = _model.copyWith(
      footerColumns: _model.footerColumns
          .map((c) =>
      c.id == colId ? c.copyWith(title: BiText(en: en, ar: ar)) : c)
          .toList(),
    );
  }

  void updateFooterColumnRoute(String colId, String route) {
    print('🔵 [HomeCubit] updateFooterColumnRoute() '
        'colId=$colId route="$route"');
    _model = _model.copyWith(
      footerColumns: _model.footerColumns
          .map((c) => c.id == colId ? c.copyWith(route: route) : c)
          .toList(),
    );
  }

  void addFooterLabel(String colId) {
    print('🔵 [HomeCubit] addFooterLabel() colId=$colId');
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
            labels: [...c.labels, FooterLabelModel(id: _uid())]);
      }).toList(),
    );
  }

  void removeFooterLabel(String colId, String labelId) {
    print('🔵 [HomeCubit] removeFooterLabel() '
        'colId=$colId labelId=$labelId');
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
            labels: c.labels.where((l) => l.id != labelId).toList());
      }).toList(),
    );
  }

  void updateFooterLabel(String colId, String labelId,
      {required String en, required String ar}) {
    print('🔵 [HomeCubit] updateFooterLabel() '
        'colId=$colId labelId=$labelId en="$en"');
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
          labels: c.labels
              .map((l) => l.id == labelId
              ? l.copyWith(label: BiText(en: en, ar: ar))
              : l)
              .toList(),
        );
      }).toList(),
    );
  }

  void updateFooterLabelRoute(
      String colId, String labelId, String route) {
    print('🔵 [HomeCubit] updateFooterLabelRoute() '
        'colId=$colId labelId=$labelId route="$route"');
    _model = _model.copyWith(
      footerColumns: _model.footerColumns.map((c) {
        if (c.id != colId) return c;
        return c.copyWith(
          labels: c.labels
              .map((l) =>
          l.id == labelId ? l.copyWith(route: route) : l)
              .toList(),
        );
      }).toList(),
    );
  }

  // ── Social Links ──────────────────────────────────────────────────────────

  void addSocialLink() {
    final id = 'sl_${_uid()}';
    print('🔵 [HomeCubit] addSocialLink() id=$id');
    _model = _model.copyWith(
      socialLinks: [..._model.socialLinks, SocialLinkModel(id: id)],
    );
  }

  void removeSocialLink(String id) {
    print('🔵 [HomeCubit] removeSocialLink() id=$id');
    _model = _model.copyWith(
      socialLinks:
      _model.socialLinks.where((s) => s.id != id).toList(),
    );
  }

  // ✅ FIXED: accepts visibility param and persists it to model
  void updateSocialLink(String id, {required String url, bool? visibility}) {
    print('🔵 [HomeCubit] updateSocialLink() '
        'id=$id url="$url" visibility=$visibility');
    _model = _model.copyWith(
      socialLinks: _model.socialLinks
          .map((s) => s.id == id
          ? s.copyWith(
        url:        url,
        visibility: visibility ?? s.visibility,
      )
          : s)
          .toList(),
    );
  }

  Future<void> uploadSocialLinkIcon(String id, Uint8List bytes) async {
    print('🔵 [HomeCubit] uploadSocialLinkIcon() '
        'id=$id bytes=${bytes.length}');
    final path = 'home_cms/social_icons/${id}_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadSocialLinkIcon() SUCCESS → url=$url');
      _model = _model.copyWith(
        socialLinks: _model.socialLinks
            .map((s) => s.id == id ? s.copyWith(iconUrl: url) : s)
            .toList(),
      );
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadSocialLinkIcon() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Social icon upload failed: $e', _model));
    }
  }

  // ── Branding / Logo ───────────────────────────────────────────────────────

  Future<void> uploadLogo(Uint8List bytes) async {
    print('🔵 [HomeCubit] uploadLogo() bytes=${bytes.length}');
    final path = 'home_cms/branding/logo_${_uid()}.png';
    try {
      final url = await _repo.uploadImage(bytes: bytes, storagePath: path);
      print('🟢 [HomeCubit] uploadLogo() SUCCESS → url=$url');
      _model =
          _model.copyWith(branding: _model.branding.copyWith(logoUrl: url));
    } catch (e, st) {
      print('🔴 [HomeCubit] uploadLogo() ERROR: $e');
      print('   StackTrace: $st');
      emit(HomeCmsError('Logo upload failed: $e', _model));
    }
  }

  void updatePrimaryColor(String hex) {
    print('🔵 [HomeCubit] updatePrimaryColor() hex=$hex');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(primaryColor: hex));
  }

  void updateSecondaryColor(String hex) {
    print('🔵 [HomeCubit] updateSecondaryColor() hex=$hex');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(secondaryColor: hex));
  }

  void updateBackgroundColor(String hex) {
    print('🔵 [HomeCubit] updateBackgroundColor() hex=$hex');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(backgroundColor: hex));
  }

  void updateHeaderFooterColor(String hex) {
    print('🔵 [HomeCubit] updateHeaderFooterColor() hex=$hex');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(headerFooterColor: hex));
  }

  void updateEnglishFont(String font) {
    print('🔵 [HomeCubit] updateEnglishFont() font=$font');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(englishFont: font));
  }
  void reorderNavButtonsSilent(int oldIndex, int newIndex) {
    print('🔵 [HomeCubit] reorderNavButtonsSilent() $oldIndex → $newIndex');
    final list = List<NavButtonModel>.from(_model.navButtons);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _model = _model.copyWith(navButtons: list);
    // ✅ No emit — prevents _seedFromModel() from firing mid-save
  }

  void updateArabicFont(String font) {
    print('🔵 [HomeCubit] updateArabicFont() font=$font');
    _model = _model.copyWith(
        branding: _model.branding.copyWith(arabicFont: font));
  }
}