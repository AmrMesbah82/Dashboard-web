// ******************* FILE INFO *******************
// Part of: main_edit.dart
// Contains: _seedFromModel, _save

part of '../../pages/main_edit.dart';

extension _HomeEditSave on _HomeEditPageState {
  // ─────────────────────────────────────────────────────────────────────────
  //  SEED FROM MODEL
  // ─────────────────────────────────────────────────────────────────────────
  void _seedFromModel(HomePageModel d) {
    final modelHash = Object.hashAll([
      d.title.en,
      d.title.ar,
      ...d.sections.map((s) => s.imageUrl + s.iconUrl),
      ...d.socialLinks.map((s) => s.iconUrl),
      d.branding.logoUrl,
    ]);

    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;

    // Remove all listeners before seeding
    for (final m in _navBtns) {
      m['nameEn']!.removeListener(_onFieldChanged);
      m['nameAr']!.removeListener(_onFieldChanged);
    }
    for (final col in _footerColumns) {
      (col['titleEn'] as TextEditingController).removeListener(_onFieldChanged);
      (col['titleAr'] as TextEditingController).removeListener(_onFieldChanged);
      for (final label in col['labels'] as List<Map<String, dynamic>>) {
        (label['en'] as TextEditingController).removeListener(_onFieldChanged);
        (label['ar'] as TextEditingController).removeListener(_onFieldChanged);
      }
    }
    for (final link in _links) {
      link.text.removeListener(_onFieldChanged);
    }

    // ── Nav buttons ─────────────────────────────────────────────────────────
    while (_navBtns.length > d.navButtons.length) {
      final removed = _navBtns.removeLast();
      removed['nameEn']!.dispose();
      removed['nameAr']!.dispose();
      _navRoutes.removeLast();
      _navStatus.removeLast();
    }
    while (_navBtns.length < d.navButtons.length) {
      _navBtns.add({
        'nameEn': TextEditingController(),
        'nameAr': TextEditingController(),
      });
      _navRoutes.add(null);
      _navStatus.add(true);
    }
    for (var i = 0; i < d.navButtons.length; i++) {
      _navBtns[i]['nameEn']!.text = d.navButtons[i].name.en;
      _navBtns[i]['nameAr']!.text = d.navButtons[i].name.ar;
      _navRoutes[i] =
          d.navButtons[i].route.isEmpty ? null : d.navButtons[i].route;
      _navStatus[i] = d.navButtons[i].status;
    }

    // ── Sections ─────────────────────────────────────────────────────────────
    for (var i = 0; i < _sections.length && i < d.sections.length; i++) {
      _sections[i]['textBox']!.text = d.sections[i].textBoxColor;
      _sections[i]['description']!.text = d.sections[i].description.en;
      _sections[i]['descriptionAr']!.text = d.sections[i].description.ar;
      _sectionImages[i]['image'] = d.sections[i].imageUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].imageUrl)
          : const _PickedImage();
      _sectionImages[i]['icon'] = d.sections[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].iconUrl)
          : const _PickedImage();
    }

    // ── Footer columns ───────────────────────────────────────────────────────
    while (_footerColumns.length > d.footerColumns.length) {
      final removed = _footerColumns.removeLast();
      _disposeColumn(removed);
    }
    while (_footerColumns.length < d.footerColumns.length) {
      _footerColumns.add(_newFooterColumn());
    }
    for (var i = 0; i < d.footerColumns.length; i++) {
      (_footerColumns[i]['titleEn'] as TextEditingController).text =
          d.footerColumns[i].title.en;
      (_footerColumns[i]['titleAr'] as TextEditingController).text =
          d.footerColumns[i].title.ar;
      _footerColumns[i]['route'] =
          d.footerColumns[i].route.isEmpty ? null : d.footerColumns[i].route;

      final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
      while (labels.length > d.footerColumns[i].labels.length) {
        _disposeLabel(labels.removeLast());
      }
      while (labels.length < d.footerColumns[i].labels.length) {
        labels.add(_newLabelRow());
      }
      for (var li = 0; li < d.footerColumns[i].labels.length; li++) {
        (labels[li]['en'] as TextEditingController).text =
            d.footerColumns[i].labels[li].label.en;
        (labels[li]['ar'] as TextEditingController).text =
            d.footerColumns[i].labels[li].label.ar;
        labels[li]['route'] = d.footerColumns[i].labels[li].route.isEmpty
            ? null
            : d.footerColumns[i].labels[li].route;
      }
    }

    // ── Social links ─────────────────────────────────────────────────────────
    while (_links.length > d.socialLinks.length) _links.removeLast().dispose();
    while (_links.length < d.socialLinks.length) _links.add(_LinkItem());
    for (var i = 0; i < d.socialLinks.length; i++) {
      _links[i].text.text = d.socialLinks[i].url;
      _links[i].icon = d.socialLinks[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.socialLinks[i].iconUrl)
          : const _PickedImage();
      _links[i].visibility = d.socialLinks[i].visibility;
    }

    // ── Branding ─────────────────────────────────────────────────────────────
    _primaryColor.text = d.branding.primaryColor;
    _secondaryColor.text = d.branding.secondaryColor;
    _bgColor.text = d.branding.backgroundColor.isNotEmpty
        ? d.branding.backgroundColor
        : '#D9D9D9';
    _headerFooterColor.text = d.branding.headerFooterColor.isNotEmpty
        ? d.branding.headerFooterColor
        : '#D9D9D9';
    _engFont = d.branding.englishFont.isEmpty ? 'Cairo' : d.branding.englishFont;
    _arFont = d.branding.arabicFont.isEmpty ? 'Cairo' : d.branding.arabicFont;
    _logoPicked = d.branding.logoUrl.isNotEmpty
        ? _PickedImage(url: d.branding.logoUrl)
        : const _PickedImage();

    // Re-attach listeners
    for (final m in _navBtns) {
      m['nameEn']!.addListener(_onFieldChanged);
      m['nameAr']!.addListener(_onFieldChanged);
    }
    for (final col in _footerColumns) {
      (col['titleEn'] as TextEditingController).addListener(_onFieldChanged);
      (col['titleAr'] as TextEditingController).addListener(_onFieldChanged);
      for (final label in col['labels'] as List<Map<String, dynamic>>) {
        (label['en'] as TextEditingController).addListener(_onFieldChanged);
        (label['ar'] as TextEditingController).addListener(_onFieldChanged);
      }
    }
    for (final link in _links) {
      link.text.addListener(_onFieldChanged);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SAVE / PUBLISH
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _save(HomeCmsCubit cubit,
      {String publishStatus = 'published'}) async {
    try {
      final snapshot = List<NavButtonModel>.from(cubit.current.navButtons);
      final routeToId = {for (final b in snapshot) b.route: b.id};

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute = _navRoutes[i] ?? '';
        if (localRoute.isEmpty) continue;
        final currentIndex = cubit.current.navButtons
            .indexWhere((b) => b.route == localRoute);
        if (currentIndex != -1 && currentIndex != i) {
          cubit.reorderNavButtonsSilent(currentIndex, i);
        }
      }

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute = _navRoutes[i] ?? '';
        final id = routeToId[localRoute];
        if (id == null) continue;

        cubit.updateNavButtonName(id,
            en: _navBtns[i]['nameEn']!.text,
            ar: _navBtns[i]['nameAr']!.text);
        cubit.updateNavButtonRoute(id, localRoute);

        final modelStatus = cubit.current.navButtons
            .firstWhere((b) => b.id == id,
                orElse: () => NavButtonModel(id: id))
            .status;
        if (modelStatus != _navStatus[i]) {
          cubit.toggleNavButtonStatus(id);
        }
      }

      for (var i = 0; i < _sections.length; i++) {
        cubit.updateSectionTextBoxColor(i, _sections[i]['textBox']!.text);
        cubit.updateSectionDescription(i,
            en: _sections[i]['description']!.text,
            ar: _sections[i]['descriptionAr']!.text);
        final img = _sectionImages[i]['image']!;
        final icon = _sectionImages[i]['icon']!;
        if (img.bytes != null) await cubit.uploadSectionImage(i, img.bytes!);
        if (icon.bytes != null) await cubit.uploadSectionIcon(i, icon.bytes!);
      }

      while (cubit.current.footerColumns.length < _footerColumns.length) {
        cubit.addFooterColumn();
      }
      while (cubit.current.footerColumns.length > _footerColumns.length) {
        cubit.removeFooterColumn(cubit.current.footerColumns.last.id);
      }
      for (var i = 0; i < _footerColumns.length; i++) {
        final colId = cubit.current.footerColumns[i].id;
        cubit.updateFooterColumnTitle(colId,
            en: (_footerColumns[i]['titleEn'] as TextEditingController).text,
            ar: (_footerColumns[i]['titleAr'] as TextEditingController).text);
        cubit.updateFooterColumnRoute(
            colId, _footerColumns[i]['route'] as String? ?? '');

        final labels = _footerColumns[i]['labels'] as List<Map<String, dynamic>>;
        while (cubit.current.footerColumns[i].labels.length < labels.length) {
          cubit.addFooterLabel(colId);
        }
        while (cubit.current.footerColumns[i].labels.length > labels.length) {
          cubit.removeFooterLabel(
              colId, cubit.current.footerColumns[i].labels.last.id);
        }
        for (var li = 0; li < labels.length; li++) {
          final lblId = cubit.current.footerColumns[i].labels[li].id;
          final lblRoute = (labels[li]['route'] as String?) ?? '';
          cubit.updateFooterLabel(colId, lblId,
              en: (labels[li]['en'] as TextEditingController).text,
              ar: (labels[li]['ar'] as TextEditingController).text);
          cubit.updateFooterLabelRoute(colId, lblId, lblRoute);
        }
      }

      while (cubit.current.socialLinks.length < _links.length) {
        cubit.addSocialLink();
      }
      while (cubit.current.socialLinks.length > _links.length) {
        cubit.removeSocialLink(cubit.current.socialLinks.last.id);
      }
      for (var i = 0; i < _links.length; i++) {
        final id = cubit.current.socialLinks[i].id;
        cubit.updateSocialLink(id,
            url: _links[i].text.text, visibility: _links[i].visibility);
        if (_links[i].icon.bytes != null) {
          await cubit.uploadSocialLinkIcon(id, _links[i].icon.bytes!);
        }
      }

      if (_logoPicked.bytes != null) {
        await cubit.uploadLogo(_logoPicked.bytes!);
      }
      cubit.updatePrimaryColor(_primaryColor.text);
      cubit.updateSecondaryColor(_secondaryColor.text);
      cubit.updateBackgroundColor(_bgColor.text);
      cubit.updateHeaderFooterColor(_headerFooterColor.text);
      cubit.updateEnglishFont(_engFont ?? 'Cairo');
      cubit.updateArabicFont(_arFont ?? 'Cairo');

      await cubit.save(publishStatus: publishStatus);
    } catch (e, st) {
      // Errors surface via HomeCmsError state
    }
  }
}
