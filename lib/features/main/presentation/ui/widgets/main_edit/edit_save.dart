// ******************* FILE INFO *******************
// Part of: main_edit.dart
// Contains: _seedFromModel, _save
// SPLIT: Main data (branding/footer/social) comes from MainCmsCubit
//        (MainPageModel / mainPage collection). Nav buttons belong to HOME
//        and are read/written through HomeCmsCubit.

part of '../../pages/main_edit.dart';

extension _HomeEditSave on _MainEditPageState {
  // ─────────────────────────────────────────────────────────────────────────
  //  SEED FROM MODEL — main data (branding/footer/social) + home nav buttons
  // ─────────────────────────────────────────────────────────────────────────
  void _seedFromModel(MainPageModel d, HomePageModel h) {
    final modelHash = Object.hashAll([
      ...h.navButtons.map((b) => b.id + b.name.en + b.route),
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

    // ── Nav buttons (HOME data) ─────────────────────────────────────────────
    while (_navBtns.length > h.navButtons.length) {
      final removed = _navBtns.removeLast();
      removed['nameEn']!.dispose();
      removed['nameAr']!.dispose();
      _navRoutes.removeLast();
      _navStatus.removeLast();
    }
    while (_navBtns.length < h.navButtons.length) {
      _navBtns.add({
        'nameEn': TextEditingController(),
        'nameAr': TextEditingController(),
      });
      _navRoutes.add(null);
      _navStatus.add(true);
    }
    for (var i = 0; i < h.navButtons.length; i++) {
      _navBtns[i]['nameEn']!.text = h.navButtons[i].name.en;
      _navBtns[i]['nameAr']!.text = h.navButtons[i].name.ar;
      _navRoutes[i] =
          h.navButtons[i].route.isEmpty ? null : h.navButtons[i].route;
      _navStatus[i] = h.navButtons[i].status;
    }

    // ── Footer columns (MAIN data) ──────────────────────────────────────────
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

    // ── Social links (MAIN data) ────────────────────────────────────────────
    while (_links.length > d.socialLinks.length) _links.removeLast().dispose();
    while (_links.length < d.socialLinks.length) _links.add(_LinkItem());
    for (var i = 0; i < d.socialLinks.length; i++) {
      _links[i].text.text = d.socialLinks[i].url;
      _links[i].icon = d.socialLinks[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.socialLinks[i].iconUrl)
          : const _PickedImage();
      _links[i].visibility = d.socialLinks[i].visibility;
    }

    // ── Branding (MAIN data) ────────────────────────────────────────────────
    _primaryColor.text = d.branding.primaryColor;
    _secondaryColor.text = d.branding.secondaryColor;
    _bgColor.text = d.branding.backgroundColor.isNotEmpty
        ? d.branding.backgroundColor
        : '#D9D9D9';
    _headerFooterColor.text = d.branding.headerFooterColor.isNotEmpty
        ? d.branding.headerFooterColor
        : '#D9D9D9';
    _mainWidgetColor.text = d.branding.mainWidgetColor.isNotEmpty
        ? d.branding.mainWidgetColor
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
  //  Nav buttons → HomeCmsCubit (home doc). Everything else → MainCmsCubit.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _save(MainCmsCubit cubit,
      {String publishStatus = 'published'}) async {
    try {
      // ── Nav buttons — belong to HOME ──────────────────────────────────────
      final homeCubit = context.read<HomeCmsCubit>();

      final snapshot = List<NavButtonModel>.from(homeCubit.current.navButtons);
      final routeToId = {for (final b in snapshot) b.route: b.id};

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute = _navRoutes[i] ?? '';
        if (localRoute.isEmpty) continue;
        final currentIndex = homeCubit.current.navButtons
            .indexWhere((b) => b.route == localRoute);
        if (currentIndex != -1 && currentIndex != i) {
          homeCubit.reorderNavButtonsSilent(currentIndex, i);
        }
      }

      for (var i = 0; i < _navBtns.length; i++) {
        final localRoute = _navRoutes[i] ?? '';
        final id = routeToId[localRoute];
        if (id == null) continue;

        homeCubit.updateNavButtonName(id,
            en: _navBtns[i]['nameEn']!.text,
            ar: _navBtns[i]['nameAr']!.text);
        homeCubit.updateNavButtonRoute(id, localRoute);

        final modelStatus = homeCubit.current.navButtons
            .firstWhere((b) => b.id == id,
                orElse: () => NavButtonModel(id: id))
            .status;
        if (modelStatus != _navStatus[i]) {
          homeCubit.toggleNavButtonStatus(id);
        }
      }

      // ── Footer columns — MAIN ─────────────────────────────────────────────
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

      // ── Social links — MAIN ───────────────────────────────────────────────
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

      // ── Branding / Logo — MAIN ────────────────────────────────────────────
      if (_logoPicked.bytes != null) {
        await cubit.uploadLogo(_logoPicked.bytes!);
      }
      cubit.updatePrimaryColor(_primaryColor.text);
      cubit.updateSecondaryColor(_secondaryColor.text);
      cubit.updateBackgroundColor(_bgColor.text);
      cubit.updateHeaderFooterColor(_headerFooterColor.text);
      cubit.updateMainWidgetColor(_mainWidgetColor.text);
      cubit.updateEnglishFont(_engFont ?? 'Cairo');
      cubit.updateArabicFont(_arFont ?? 'Cairo');

      // Save main data to the MAIN doc.
      await cubit.save(publishStatus: publishStatus);

      // Nav buttons live in the HOME doc, but publishing Main must NOT
      // upload the rest of the home content. Only when Main is PUBLISHED,
      // write the Nav_Buttons_* keys alone (partial merge write).
      if (publishStatus == 'published') {
        await homeCubit.saveNavButtonsOnly();
      }
    } catch (e) {
      // Errors surface via MainCmsError state
    }
  }
}
