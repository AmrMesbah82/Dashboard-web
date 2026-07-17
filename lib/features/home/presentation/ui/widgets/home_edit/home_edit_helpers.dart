part of '../../pages/home_edit.dart';

extension _HomeEditHelpers on _HomeEditPageMasterState {
  void _onFieldChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<_PickedImage?> _pickImage() async {
    final completer = Completer<_PickedImage?>();
    bool completed = false;
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = '.svg,image/svg+xml';
    void complete(_PickedImage? val) {
      if (!completed) {
        completed = true;
        completer.complete(val);
      }
    }

    input.addEventListener(
      'change',
      (web.Event _) {
        final files = input.files;
        if (files == null || files.length == 0) {
          complete(null);
          return;
        }
        final file = files.item(0)!;
        if (!file.name.toLowerCase().endsWith('.svg') &&
            file.type != 'image/svg+xml') {
          complete(null);
          if (mounted) {
            showConfirmDialog(
              context: context,
              title: 'Invalid File',
              subtitle: 'Only SVG files are allowed',
              confirmLabel: 'OK',
              cancelLabel: '',
              onConfirm: () {},
              iconWidget: Container(
                width: 60.r,
                height: 60.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 36.r,
                ),
              ),
            );
          }
          return;
        }
        final reader = web.FileReader();
        reader.addEventListener(
          'loadend',
          (web.Event _) {
            final result = reader.result;
            if (result != null) {
              try {
                complete(
                  _PickedImage(
                    bytes: Uint8List.view((result as JSArrayBuffer).toDart),
                  ),
                );
              } catch (_) {
                complete(null);
              }
            } else {
              complete(null);
            }
          }.toJS,
        );
        reader.addEventListener(
          'error',
          ((web.Event _) => complete(null)).toJS,
        );
        reader.readAsArrayBuffer(file);
      }.toJS,
    );
    input.click();
    Future.delayed(const Duration(minutes: 5), () => complete(null));
    return completer.future;
  }

  void _seedFromModel(HomePageModel d, {bool isFromDraft = false}) {
    final modelHash = Object.hashAll([
      d.title.en,
      d.title.ar,
      ...d.navButtons.map((b) => b.name.en + b.route + b.status.toString()),
      ...d.sections.map(
        (s) => s.imageUrl + s.iconUrl + s.visibility.toString(),
      ),
      d.scheduledPublishDate?.toIso8601String() ?? '',
    ]);
    if (_seededModelHash == modelHash) return;
    _seededModelHash = modelHash;
    _isEditingDraft = isFromDraft;

    _titleEn.text = d.title.en;
    _titleAr.text = d.title.ar;
    _shortDescEn.text = d.shortDescription.en;
    _shortDescAr.text = d.shortDescription.ar;

    for (final nb in _navBtns) nb.dispose();
    _navBtns.clear();
    for (final btn in d.navButtons) {
      final item = _NavBtnItem();
      item.nameEn.text = btn.name.en;
      item.nameAr.text = btn.name.ar;
      item.route = btn.route.isEmpty ? null : btn.route;
      item.status = btn.status;
      _navBtns.add(item);
    }

    for (var i = 0; i < _sections.length && i < d.sections.length; i++) {
      _sections[i].descEn.text = d.sections[i].description.en;
      _sections[i].descAr.text = d.sections[i].description.ar;
      _sections[i].image = d.sections[i].imageUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].imageUrl)
          : const _PickedImage();
      _sections[i].icon = d.sections[i].iconUrl.isNotEmpty
          ? _PickedImage(url: d.sections[i].iconUrl)
          : const _PickedImage();
      _sections[i].visibility = d.sections[i].visibility;
    }

    // NOTE: footer/social/branding are seeded & edited on the MAIN page.

    _publishDate = d.scheduledPublishDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  Future<void> _save(
    HomeCmsCubit cubit, {
    String publishStatus = 'published',
    DateTime? scheduledPublishDate,
  }) async {
    if (publishStatus == 'published') {
      setState(() => _submitted = true);
      if (!_isFormValid) return;
    }

    setState(() => _isSaving = true);
    try {
      cubit.updateTitle(en: _titleEn.text, ar: _titleAr.text);
      cubit.updateShortDescription(
        en: _shortDescEn.text,
        ar: _shortDescAr.text,
      );

      while (cubit.current.navButtons.length > _navBtns.length)
        cubit.removeNavButton(cubit.current.navButtons.last.id);
      while (cubit.current.navButtons.length < _navBtns.length)
        cubit.addNavButton();
      for (var i = 0; i < _navBtns.length; i++) {
        if (i < cubit.current.navButtons.length) {
          final id = cubit.current.navButtons[i].id;
          cubit.updateNavButtonName(
            id,
            en: _navBtns[i].nameEn.text,
            ar: _navBtns[i].nameAr.text,
          );
          cubit.updateNavButtonRoute(id, _navBtns[i].route ?? '');
          if (cubit.current.navButtons[i].status != _navBtns[i].status)
            cubit.toggleNavButtonStatus(id);
        }
      }

      for (var i = 0; i < _sections.length; i++) {
        cubit.updateSectionDescription(
          i,
          en: _sections[i].descEn.text,
          ar: _sections[i].descAr.text,
        );
        cubit.updateSectionVisibility(i, _sections[i].visibility);
        if (_sections[i].image.bytes != null)
          await cubit.uploadSectionImage(i, _sections[i].image.bytes!);
        if (_sections[i].icon.bytes != null)
          await cubit.uploadSectionIcon(i, _sections[i].icon.bytes!);
      }

      // NOTE: footer/social/branding are saved from the MAIN page (MainCmsCubit).

      String finalStatus = publishStatus;
      DateTime? finalScheduleDate = scheduledPublishDate;

      if (publishStatus == 'published' &&
          _publishDate != null &&
          _publishDate!.isAfter(DateTime.now())) {
        finalStatus = 'scheduled';
        finalScheduleDate = _publishDate;
      }

      await cubit.save(
        publishStatus: finalStatus,
        scheduledPublishDate: finalScheduleDate,
      );
    } catch (e, st) {
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
