part of '../../pages/about_us_edit.dart';

extension _AboutEditBuilders on _AboutEditPageMasterState {
  // ═════════════════════════════════════════════════════════════════════════
  // FORM
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Row(
          children: [
            Text(
              'Editing About Us',
              style: StyleText.fontSize45Weight600.copyWith(
                color: ColorPick.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // ── Navigation Label ──
        _accordion(
          title: 'Navigation Label',
          isOpen: _navigationLabelOpen,
          onToggle: () =>
              setState(() => _navigationLabelOpen = !_navigationLabelOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _navigationLabelSection(),
          ),
        ),

        SizedBox(height: 15.h),

        // ── Headings ──
        _accordion(
          title: 'Headings',
          isOpen: _headingsOpen,
          onToggle: () => setState(() => _headingsOpen = !_headingsOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _headingsSection(),
          ),
        ),

        SizedBox(height: 15.h),

        // ── Vision ──
        _accordion(
          title: 'Vision',
          isOpen: _visionOpen,
          onToggle: () => setState(() => _visionOpen = !_visionOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _sectionEditor(
              iconBytes: _visionIconBytes,
              svgBytes: _visionSvgBytes,
              iconUrl: _visionIconUrl,
              svgUrl: _visionSvgUrl,
              onPickIcon: () async {
                final b = await _pickImageIcon();
                if (b != null) setState(() => _visionIconBytes = b);
              },
              onPickSvg: () async {
                final b = await _pickSvgFile();
                if (b != null) setState(() => _visionSvgBytes = b);
              },
              subEnCtrl: _visionSubEnCtrl,
              subArCtrl: _visionSubArCtrl,
              descEnCtrl: _visionDescEnCtrl,
              descArCtrl: _visionDescArCtrl,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // ── Mission ──
        _accordion(
          title: 'Mission',
          isOpen: _missionOpen,
          onToggle: () => setState(() => _missionOpen = !_missionOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _sectionEditor(
              iconBytes: _missionIconBytes,
              svgBytes: _missionSvgBytes,
              iconUrl: _missionIconUrl,
              svgUrl: _missionSvgUrl,
              onPickIcon: () async {
                final b = await _pickImageIcon();
                if (b != null) setState(() => _missionIconBytes = b);
              },
              onPickSvg: () async {
                final b = await _pickSvgFile();
                if (b != null) setState(() => _missionSvgBytes = b);
              },
              subEnCtrl: _missionSubEnCtrl,
              subArCtrl: _missionSubArCtrl,
              descEnCtrl: _missionDescEnCtrl,
              descArCtrl: _missionDescArCtrl,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // ── Values ──
        _accordion(
          title: 'Values',
          isOpen: _valuesOpen,
          onToggle: () => setState(() => _valuesOpen = !_valuesOpen),
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: _valuesSection(),
          ),
        ),
        SizedBox(height: 16.h),

        _actionButtons(),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────
  Widget _accordion({
    required String title,
    required bool isOpen,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: StyleText.fontSize16Weight400
                        .copyWith(color: Colors.white)),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen) child,
      ],
    );
  }

  // ── Headings section ───────────────────────────────────────────────────────
  Widget _headingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _fieldLabel('Title'),
            Spacer(),
            _fieldLabelAr("العنوان"),
          ],
        ),
        SizedBox(height: 8.h),
        _bilingualRow(
          enCtrl: _titleEnCtrl,
          arCtrl: _titleArCtrl,
          enHint: 'Text Here',
          arHint: 'أدخل النص هنا',
        ),
      ],
    );
  }

  // ── Navigation Label section ───────────────────────────────────────────────
  Widget _navigationLabelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageUploadCircle(
          label: 'Icon',
          bytes: _navIconBytes,
          url: _navIconUrl,
          onTap: () async {
            final b = await _pickImageIcon();
            if (b != null) setState(() => _navIconBytes = b);
          },
          isSvg: false,
          showError:
              _submitted && _navIconBytes == null && _navIconUrl.isEmpty,
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            _fieldLabel('Title'),
            Spacer(),
            _fieldLabelAr("العنوان"),
          ],
        ),
        SizedBox(height: 8.h),
        _bilingualRow(
          enCtrl: _navTitleEnCtrl,
          arCtrl: _navTitleArCtrl,
          enHint: 'Text Here',
          arHint: 'أدخل النص هنا',
        ),
      ],
    );
  }

  // ── Vision / Mission section editor ───────────────────────────────────────
  Widget _sectionEditor({
    required Uint8List? iconBytes,
    required Uint8List? svgBytes,
    required String iconUrl,
    required String svgUrl,
    required VoidCallback onPickIcon,
    required VoidCallback onPickSvg,
    required TextEditingController subEnCtrl,
    required TextEditingController subArCtrl,
    required TextEditingController descEnCtrl,
    required TextEditingController descArCtrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _imageUploadCircle(
              label: 'Icon',
              bytes: iconBytes,
              url: iconUrl,
              onTap: onPickIcon,
              isSvg: false,
              showError: _submitted && iconBytes == null && iconUrl.isEmpty,
            ),
            SizedBox(width: 24.w),
            _imageUploadCircle(
              label: 'SVG',
              bytes: svgBytes,
              url: svgUrl,
              onTap: onPickSvg,
              isSvg: true,
              showError: _submitted && svgBytes == null && svgUrl.isEmpty,
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: subEnCtrl,
          fillColor: Colors.white,
          height: 100,
          maxLines: 4,
          maxLength: 10000,
          showCharCount: false,
          submitted: _submitted,
          isRequired: true,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          primaryColor: ColorPick.primary,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          fillColor: Colors.white,
          controller: subArCtrl,
          height: 100,
          maxLines: 4,
          maxLength: 10000,
          showCharCount: false,
          submitted: _submitted,
          isRequired: true,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          primaryColor: ColorPick.primary,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        _fieldLabel('Description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint: 'Text Here',
          controller: descEnCtrl,
          fillColor: Colors.white,
          height: 100,
          maxLines: 4,
          maxLength: 500,
          showCharCount: false,
          submitted: _submitted,
          isRequired: true,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          primaryColor: ColorPick.primary,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        _fieldLabelAr('الوصف'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint: 'أدخل النص هنا',
          controller: descArCtrl,
          height: 100,
          fillColor: Colors.white,
          maxLines: 4,
          maxLength: 500,
          showCharCount: false,
          submitted: _submitted,
          isRequired: true,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          primaryColor: ColorPick.primary,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALUES SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _valuesSection() {
    if (_valueItems.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 20.h),
          Center(
            child: Text(
              'No values added. Click "Add Point" to create one.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 20.h),
          _addValueButton(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_valueItems.length, (index) {
          final v = _valueItems[index];
          final bool isMain = index == 0;
          return _valueItemWidget(v, isMain: isMain);
        }),
        SizedBox(height: 16.h),
        _addValueButton(),
      ],
    );
  }

  Widget _addValueButton() {
    return GestureDetector(
      onTap: _addValueItem,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF555555),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              'Add Point',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueItemWidget(_ValueItem v, {required bool isMain}) {
    final String itemLabel = isMain ? 'Main Icon' : 'Icon';
    final bool showIconError =
        _submitted && v.iconBytes == null && v.iconUrl.isEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: itemLabel,
                bytes: v.iconBytes,
                url: v.iconUrl,
                isSvg: false,
                showError: showIconError,
                onTap: () async {
                  final b = await _pickImageIcon();
                  if (b != null) setState(() => v.iconBytes = b);
                },
              ),
              GestureDetector(
                onTap: () => _removeValueItem(v.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _fieldLabel('Title'),
              Spacer(),
              _fieldLabelAr("العنوان"),
            ],
          ),
          SizedBox(height: 8.h),
          _bilingualRow(
            enCtrl: v.titleEnCtrl,
            arCtrl: v.titleArCtrl,
            enHint: 'Text Here',
            arHint: 'أدخل النص هنا',
          ),
          SizedBox(height: 16.h),
          _fieldLabel('Short Description'),
          SizedBox(height: 8.h),
          CustomValidatedTextFieldMaster(
            hint: 'Text Here',
            controller: v.shortDescEnCtrl,
            height: 100,
            fillColor: Colors.white,
            maxLines: 4,
            maxLength: 10000,
            showCharCount: false,
            submitted: _submitted,
            isRequired: true,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            primaryColor: ColorPick.primary,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 16.h),
          _fieldLabelAr('وصف مختصر'),
          SizedBox(height: 4.h),
          CustomValidatedTextFieldMaster(
            hint: 'أدخل النص هنا',
            controller: v.shortDescArCtrl,
            fillColor: Colors.white,
            height: 100,
            maxLines: 4,
            maxLength: 10000,
            showCharCount: false,
            submitted: _submitted,
            isRequired: true,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            primaryColor: ColorPick.primary,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _actionButtons() {
    final bool formValid = _isFormValid;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Preview',
                color: formValid
                    ? const Color(0xFF608570)
                    : const Color(0xFF608570).withOpacity(0.4),
                onTap: formValid ? _onPreview : null,
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(
              child: _btn(
                label: 'Publish',
                color: formValid
                    ? ColorPick.primary
                    : ColorPick.primary.withOpacity(0.4),
                onTap: formValid ? () => _showPublishConfirmDialog() : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _btn(
                label: 'Discard',
                color: const Color(0xFF797979),
                onTap: () {
                  showConfirmDialog(
                    context: context,
                    title: 'Discard Changes',
                    subtitle:
                        'Are you sure you want to discard all changes?',
                    confirmLabel: 'Discard',
                    cancelLabel: 'Cancel',
                    onConfirm: () => Navigator.of(context).pop(),
                  );
                },
              ),
            ),
            SizedBox(width: 300.w),
            Expanded(
              child: _btn(
                label: 'Save For Later',
                color: formValid
                    ? Colors.grey.shade600
                    : Colors.grey.shade600.withOpacity(0.4),
                onTap: formValid ? () => _showSaveDraftDialog() : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPublishConfirmDialog() {
    setState(() => _submitted = true);

    if (!_validateFields()) {
      _showValidationError();
      return;
    }

    showPublishConfirmDialog(
      context: context,
      title: 'EDITING ABOUT US DETAILS',
      subtitle: 'Do you want to save the changes made to this About Us?',
      confirmLabel: 'Publish',
      onConfirm: () => _save('published'),
    );
  }

  void _showSaveDraftDialog() {
    setState(() => _submitted = true);

    if (!_validateFields()) {
      _showValidationError();
      return;
    }

    showPublishConfirmDialog(
      context: context,
      title: 'SAVE AS DRAFT',
      subtitle: 'Do you want to save this page as a draft?',
      confirmLabel: 'Save Draft',
      onConfirm: () => _save('draft'),
    );
  }
}
