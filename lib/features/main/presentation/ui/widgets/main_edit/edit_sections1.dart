// ******************* FILE INFO *******************
// Part of: main_edit.dart
// Contains: _accordion, _logoAndBrandingSection, _navSection,
//           _buildNavItemRow, _bottomActions, _footerSection, _gap

part of '../../pages/main_edit.dart';

extension _HomeEditSections1 on _MainEditPageState {
  Widget _gap() => SizedBox(height: 10.h);

  // ─── Bottom buttons ────────────────────────────────────────────────────────
  Widget _bottomActions(HomeCmsCubit cubit) {
    final bool canPublish = _isFormValid;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => navigateTo(context, MainPreviewPage()),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFF608570),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text('Preview',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
        SizedBox(width: 300.w),
        Expanded(
          child: AbsorbPointer(
            absorbing: !canPublish,
            child: Opacity(
              opacity: canPublish ? 1.0 : 0.6,
              child: GestureDetector(
                onTap: () {
                  if (!canPublish) {
                    setState(() => _submitted = true);
                    return;
                  }
                  showPublishConfirmDialog(
                    title: 'EDITING HOMEPAGE DETAILS',
                    subtitle:
                        'Do you want to save the changes made to this HOMEPAGE?',
                    context: context,
                    onConfirm: () => _save(cubit, publishStatus: 'published'),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: canPublish
                        ? ColorPick.primary
                        : ColorPick.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      'Publish',
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: Colors.white
                            .withValues(alpha: canPublish ? 1.0 : 0.55),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Accordion ─────────────────────────────────────────────────────────────
  Widget _accordion({
    required String key,
    required String title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open[key] = !isOpen),
            child: Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: ColorPick.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white))),
                Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 25.sp),
              ]),
            ),
          ),
          if (isOpen)
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
        ],
      ),
    );
  }

  // ── Logo & Branding ────────────────────────────────────────────────────────
  Widget _logoAndBrandingSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 15.h),
      _sectionLabel('Logo'),
      SizedBox(height: 6.h),
      _imgBox(
        picked: _logoPicked,
        placeholderAsset: 'assets/home_control/image.svg',
        pickIconAsset: 'assets/control/camera.svg',
        onPick: () async {
          final p = await _pickImage();
          if (p != null) setState(() => _logoPicked = p);
        },
      ),
      if (_submitted && _logoPicked.isEmpty)
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            'Logo SVG image is required',
            style:
                StyleText.fontSize12Weight400.copyWith(color: ColorPick.red),
          ),
        ),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _primaryColor,
            label: 'Primary Color',
            hintText: '#008037',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(
            controller: _secondaryColor,
            label: 'Secondary',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _bgColor,
            label: 'Background',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        Expanded(child: _ColorPickerField(
            controller: _headerFooterColor,
            label: 'Header and Footer',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: _ColorPickerField(
            controller: _mainWidgetColor,
            label: 'Main Widget Color',
            hintText: '#D9D9D9',
            onColorChanged: () => setState(() {}))),
        SizedBox(width: 16.w),
        const Expanded(child: SizedBox()),
      ]),
      SizedBox(height: 14.h),
      Row(children: [
        Expanded(child: CustomDropdown<String>(
          label: 'English Font',
          hint: 'Select font',
          value: _engFont,
          items: _kFonts
              .map((m) => DropdownItem<String>(
                  value: m['key']!, label: m['value']!))
              .toList(),
          onChanged: (val) => setState(() => _engFont = val),
        )),
        SizedBox(width: 16.w),
        Expanded(child: CustomDropdown<String>(
          label: 'Arabic Font',
          hint: 'Select font',
          value: _arFont,
          items: _kFonts
              .map((m) => DropdownItem<String>(
                  value: m['key']!, label: m['value']!))
              .toList(),
          onChanged: (val) => setState(() => _arFont = val),
        )),
      ]),
    ],
  );

  // ─── Navigation Items section ───────────────────────────────────────────────
  Widget _navSection() {
    final isOpen = _open['navBtn'] ?? true;
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open['navBtn'] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(children: [
              Expanded(
                  child: Text('Navigation Items',
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: Colors.white))),
              Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 25.sp),
            ]),
          ),
        ),
        if (isOpen)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _navBtns.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final btn = _navBtns.removeAt(oldIndex);
                final route = _navRoutes.removeAt(oldIndex);
                final status = _navStatus.removeAt(oldIndex);
                _navBtns.insert(newIndex, btn);
                _navRoutes.insert(newIndex, route);
                _navStatus.insert(newIndex, status);
              });
            },
            itemBuilder: (context, i) =>
                _buildNavItemRow(key: ValueKey('nav_$i'), index: i),
          ),
      ]),
    );
  }

  Widget _buildNavItemRow({required Key key, required int index}) {
    final nameEnCtrl = _navBtns[index]['nameEn']!;
    final nameArCtrl = _navBtns[index]['nameAr']!;

    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 27.h),
                child: ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.h, right: 8.w),
                    child: Icon(Icons.menu_rounded,
                        size: 20.sp, color: AppColors.secondaryText),
                  ),
                ),
              ),
              Expanded(
                child: CustomTextField(
                  label: 'Title',
                  // Status switch pinned to the END of the first field so it
                  // always lines up regardless of screen width.
                  labelTrailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Status ',
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.text)),
                      FlutterSwitch(
                        width: 35.sp,
                        height: 20.sp,
                        padding: 3.sp,
                        borderRadius: 20.sp,
                        toggleSize: 16.sp,
                        activeColor: ColorPick.primary,
                        inactiveColor: Colors.grey.withValues(alpha: .16),
                        value: _navStatus[index],
                        onToggle: (val) {
                          setState(() => _navStatus[index] = val);
                        },
                      ),
                    ],
                  ),
                  required: true,
                  fillColor: Colors.white,
                  hint: 'Home',
                  controller: nameEnCtrl,
                  height: 36,
                  submitted: _submitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomTextField(
                    label: 'عنصر التنقل',
                    required: true,
                    fillColor: Colors.white,
                    hint: 'الرئيسية',
                    controller: nameArCtrl,
                    height: 36,
                    submitted: _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Footer ─────────────────────────────────────────────────────────────────
  Widget _footerSection(HomeCmsCubit cubit) => _accordion(
    key: 'footer',
    title: 'Footer',
    children: [
      ...List.generate(
          _footerColumns.length, (i) => _buildFooterColumn(i)),
      GestureDetector(
        onTap: () => setState(() => _footerColumns.add(_newFooterColumn())),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
              color: const Color(0xFF797979),
              borderRadius: BorderRadius.circular(4.r)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, size: 14.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text('Column',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: Colors.white)),
          ]),
        ),
      ),
    ],
  );
}
