// ******************* FILE INFO *******************
// Part of: main_edit.dart
// Contains: _buildFooterColumn, _buildLabelRow, _linksSection, _linkItem

part of '../../pages/main_edit.dart';

extension _HomeEditSections2 on _HomeEditPageState {
  // ─── Footer Column ──────────────────────────────────────────────────────────
  Widget _buildFooterColumn(int colIndex) {
    final col              = _footerColumns[colIndex];
    final labels           = col['labels'] as List<Map<String, dynamic>>;
    final navDropdownItems = _buildNavDropdownItems();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 15.h),
      if (colIndex > 0) SizedBox(height: 12.h),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${colIndex + 1}${_ord(colIndex + 1)} Column',
              style: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.text)),
          _removeBtn(
            label: 'Remove',
            onTap: () => setState(() {
              final removed = _footerColumns.removeAt(colIndex);
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _disposeColumn(removed));
            }),
          ),
        ],
      ),
      SizedBox(height: 8.h),

      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: CustomDropdownFormFieldInvMaster(
              label: 'Group Title',
              hint: Text('Select navigation item',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText)),
              selectedValue: col['route'] as String?,
              items: navDropdownItems,
              widthIcon: 18,
              heightIcon: 18,
              dropdownColor: Colors.white,
              height: 36,
              onChanged: (val) {
                setState(() {
                  col['route'] = val;
                  if (val != null && val.isNotEmpty) {
                    final idx = _navRoutes.indexOf(val);
                    if (idx != -1) {
                      (col['titleEn'] as TextEditingController).text =
                          _navBtns[idx]['nameEn']!.text;
                      (col['titleAr'] as TextEditingController).text =
                          _navBtns[idx]['nameAr']!.text;
                    }
                  } else {
                    (col['titleEn'] as TextEditingController).clear();
                    (col['titleAr'] as TextEditingController).clear();
                  }
                });
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 1,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('عنوان المجموعة',
                          style: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.secondaryText)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 36.h,
                    child: TextFormField(
                      controller: col['titleAr'] as TextEditingController,
                      readOnly: true,
                      textAlign: TextAlign.right,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: 'الاسم بالعربي',
                        hintStyle: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                                const BorderSide(color: Colors.transparent)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                                BorderSide(color: ColorPick.primary, width: 1)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                            borderSide:
                                const BorderSide(color: Colors.transparent)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.h),

      ...List.generate(labels.length, (li) => _buildLabelRow(colIndex, li)),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: _addLabelBtn(
            onTap: () => setState(() => labels.add(_newLabelRow()))),
      ),
    ]);
  }

  // ─── Label Row ──────────────────────────────────────────────────────────────
  Widget _buildLabelRow(int colIndex, int labelIndex) {
    final labels =
        _footerColumns[colIndex]['labels'] as List<Map<String, dynamic>>;
    final label = labels[labelIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: AlignmentGeometry.topRight,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomDropdownFormFieldInvMaster(
                          label: 'Navigate To',
                          hint: Text('Select destination',
                              style: StyleText.fontSize12Weight400
                                  .copyWith(color: AppColors.secondaryText)),
                          selectedValue: label['route'] as String?,
                          items: _kLabelDestinations,
                          dropdownColor: Colors.white,
                          widthIcon: 18,
                          heightIcon: 18,
                          height: 36,
                          onChanged: (val) =>
                              setState(() => label['route'] = val),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 0.sp),
                Expanded(child: Container()),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        final removed = labels.removeAt(labelIndex);
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _disposeLabel(removed));
                      }),
                      child: Container(
                        width: 16.w,
                        height: 16.h,
                        decoration: const BoxDecoration(
                            color: ColorPick.red, shape: BoxShape.circle),
                        child: Icon(Icons.remove,
                            color: Colors.white, size: 16.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Label',
                hint: 'Text Here',
                isRequired: true,
                controller: label['en'] as TextEditingController,
                height: 36,
                submitted: _submitted,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                fillColor: Colors.white,
                primaryColor: _resolvedPrimaryColor,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: CustomValidatedTextFieldMaster(
                  label: 'التسمية',
                  isRequired: true,
                  fillColor: Colors.white,
                  hint: 'أدخل النص هنا',
                  controller: label['ar'] as TextEditingController,
                  height: 36,
                  submitted: _submitted,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  primaryColor: _resolvedPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Social Links Section ───────────────────────────────────────────────────
  Widget _linksSection() => _accordion(
        key: 'links',
        title: 'Links',
        children: [
          ...List.generate((_links.length / 2).ceil(), (rowIndex) {
            final left  = rowIndex * 2;
            final right = left + 1;
            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _linkItem(left)),
                  SizedBox(width: 16.w),
                  right < _links.length
                      ? Expanded(child: _linkItem(right))
                      : const Expanded(child: SizedBox()),
                ],
              ),
            );
          }),
          SizedBox(height: 4.h),
          GestureDetector(
            onTap: () => setState(() => _links.add(_LinkItem())),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                  color: const Color(0xFF797979),
                  borderRadius: BorderRadius.circular(4.r)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add, size: 14.sp, color: Colors.white),
                SizedBox(width: 4.w),
                Text('Link',
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: Colors.white)),
              ]),
            ),
          ),
        ],
      );

  // ─── Link Item ──────────────────────────────────────────────────────────────
  Widget _linkItem(int i) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Icon'),
              GestureDetector(
                onTap: () => setState(() {
                  final removed = _links.removeAt(i);
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => removed.dispose());
                }),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: ColorPick.red,
                      borderRadius: BorderRadius.circular(4.r)),
                  child: Text('Remove',
                      style: StyleText.fontSize11Weight400
                          .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _imgBox(
                picked: _links[i].icon,
                placeholderAsset: 'assets/control/edit_icon_pick.svg',
                pickIconAsset: 'assets/control/edit_icon_pick.svg',
                onPick: () async {
                  final p = await _pickImage();
                  if (p != null) setState(() => _links[i].icon = p);
                },
              ),
              if (_submitted && _links[i].icon.isEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    'SVG icon required',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: ColorPick.red),
                  ),
                ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 8.h),
          Stack(
            alignment: AlignmentGeometry.topRight,
            children: [
              CustomValidatedTextFieldMaster(
                label: 'Insert Link',
                isRequired: true,
                fillColor: Colors.white,
                hint: 'Insert Links',
                controller: _links[i].text,
                height: 36,
                submitted: _submitted,
                primaryColor: _resolvedPrimaryColor,
              ),
              Positioned(
                top: -0.5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Visibility',
                        style: StyleText.fontSize10Weight500
                            .copyWith(color: AppColors.text)),
                    SizedBox(width: 6.w),
                    FlutterSwitch(
                      width: 38.sp,
                      height: 18.sp,
                      padding: 3.sp,
                      borderRadius: 17.sp,
                      toggleSize: 16.sp,
                      activeColor: ColorPick.primary,
                      inactiveColor: Colors.grey.withOpacity(.16),
                      value: _links[i].visibility,
                      onToggle: (val) =>
                          setState(() => _links[i].visibility = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
}
