// ******************* FILE INFO *******************
// Part of: blog_edit.dart
// Contains: _postInfoContent, _buttonContent, _descriptionContent,
//           _blockWidget, _actionButtons, _accordion, _addChip, _labelStyle

part of '../../pages/blog_services/blog_edit.dart';

extension _BlogEditSections on _BlogCreateEditPageState {
  // ── Post Info ─────────────────────────────────────────────────────────────────
  Widget _postInfoContent() {
    final bool imageError =
        _submitted && _imageBytes == null && _existingImageUrl.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── SVG image picker ──────────────────────────────────────────────────
        Stack(
          alignment: AlignmentGeometry.bottomRight,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 60.w, height: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: imageError
                      ? Border.all(color: ColorPick.red, width: 1.5)
                      : null,
                ),
                child: _imageBytes != null
                    ? ClipOval(
                  child: SizedBox(
                    width: 60.w, height: 60.w,
                    child: Center(
                      child: SvgPicture.memory(_imageBytes!,
                          width: 30.w, height: 30.w, fit: BoxFit.scaleDown),
                    ),
                  ),
                )
                    : _existingImageUrl.isNotEmpty
                    ? ClipOval(
                  child: SizedBox(
                    width: 60.w, height: 60.w,
                    child: Center(
                      child: _XhrCircleImage(url: _existingImageUrl, size: 30.w),
                    ),
                  ),
                )
                    : Center(
                  child: CustomSvg(
                    assetPath: "assets/control/image.svg",
                    width: 30.w, height: 30.h, fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 25.w, height: 25.h,
                  decoration: BoxDecoration(
                    color: ColorPick.primary, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: CustomSvg(assetPath: "assets/control/camera.svg",
                        width: 10.w, height: 10.h, fit: BoxFit.scaleDown),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Question ──────────────────────────────────────────────────────────
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Question', style: _labelStyle()),
          Text('سؤال',    style: _labelStyle()),
        ]),
        SizedBox(height: 6.h),
        Row(children: [
          Expanded(
            child: CustomTextField(
              controller: _questionEnCtrl,
              hint: 'Text Here', isRequired: true, submitted: _submitted,
              fillColor: Colors.white, primaryColor: ColorPick.primary,
              textDirection: TextDirection.ltr, height: 40,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomTextField(
              controller: _questionArCtrl,
              hint: 'أكتب هنا', submitted: _submitted, fillColor: Colors.white,
              isRequired: true, primaryColor: ColorPick.primary,
              textDirection: TextDirection.rtl, textAlign: TextAlign.right, height: 40,
            ),
          ),
        ]),

        // ── Short description ─────────────────────────────────────────────────
        Text('Short Description', style: _labelStyle()),
        SizedBox(height: 6.h),
        CustomTextField(
          controller: _shortDescEnCtrl, hint: 'Text Here', fillColor: Colors.white,
          submitted: _submitted, maxLength: 150, showCharCount: true,
          isRequired: true, primaryColor: ColorPick.primary,
          textDirection: TextDirection.ltr, maxLines: 4, height: 100,
        ),
        Align(alignment: Alignment.centerRight,
            child: Text('وصف مختصر', style: _labelStyle())),
        SizedBox(height: 6.h),
        CustomTextField(
          controller: _shortDescArCtrl, hint: 'أكتب هنا', fillColor: Colors.white,
          isRequired: true, submitted: _submitted, maxLength: 150, showCharCount: true,
          primaryColor: ColorPick.primary, textDirection: TextDirection.rtl,
          textAlign: TextAlign.right, maxLines: 4, height: 100,
        ),
      ],
    );
  }

  // ── Button ────────────────────────────────────────────────────────────────────
  Widget _buttonContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Label',  style: _labelStyle()),
        Text('تسمية', style: _labelStyle()),
      ]),
      SizedBox(height: 6.h),
      Row(children: [
        Expanded(
          child: CustomTextField(
            controller: _btnLabelEnCtrl, hint: 'Text Here', fillColor: Colors.white,
            submitted: _submitted, isRequired: true, primaryColor: ColorPick.primary,
            textDirection: TextDirection.ltr, height: 40,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomTextField(
            controller: _btnLabelArCtrl, fillColor: Colors.white, hint: 'أكتب هنا',
            submitted: _submitted, primaryColor: ColorPick.primary, isRequired: true,
            textDirection: TextDirection.rtl, textAlign: TextAlign.right, height: 40,
          ),
        ),
      ]),
    ]);
  }

  // ── Description ───────────────────────────────────────────────────────────────
  Widget _descriptionContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Title',    style: _labelStyle()),
        Text('العنوان', style: _labelStyle()),
      ]),
      SizedBox(height: 6.h),
      Row(children: [
        Expanded(
          child: CustomTextField(
            controller: _descTitleEnCtrl, hint: 'Text Here', isRequired: true,
            submitted: _submitted, primaryColor: ColorPick.primary,
            fillColor: Colors.white, textDirection: TextDirection.ltr, height: 40,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomTextField(
            controller: _descTitleArCtrl, hint: 'أكتب هنا', submitted: _submitted,
            fillColor: Colors.white, isRequired: true, primaryColor: ColorPick.primary,
            textDirection: TextDirection.rtl, textAlign: TextAlign.right, height: 40,
          ),
        ),
      ]),

      ..._blocks.asMap().entries.map((e) => _blockWidget(idx: e.key, blk: e.value)),

      Wrap(spacing: 10.w, runSpacing: 8.h, children: [
        _addChip('+ Bullet Point', () => _addBlock(BlogBlockType.bulletPoint)),
        _addChip('+ Paragraph',    () => _addBlock(BlogBlockType.paragraph)),
        _addChip('+ Numbering',    () => _addBlock(BlogBlockType.numbering)),
      ]),
    ]);
  }

  // ── Block widget ──────────────────────────────────────────────────────────────
  Widget _blockWidget({required int idx, required Map<String, dynamic> blk}) {
    final type   = blk['type'] as BlogBlockType;
    final enCtrl = blk['enCtrl'] as TextEditingController;
    final arCtrl = blk['arCtrl'] as TextEditingController;
    final int    enMaxLines = type == BlogBlockType.paragraph ? 20 : 6;
    final double enHeight   = type == BlogBlockType.paragraph ? 180 : 90;
    final String prefix = switch (type) {
      BlogBlockType.numbering   => '${idx + 1}.',
      BlogBlockType.bulletPoint => '•',
      BlogBlockType.paragraph   => '',
    };
    final String typeLabel = switch (type) {
      BlogBlockType.numbering   => 'Numbering',
      BlogBlockType.bulletPoint => 'Bullet Point',
      BlogBlockType.paragraph   => 'Paragraph',
    };

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (prefix.isNotEmpty)
            Text('$prefix  ',
                style: StyleText.fontSize13Weight500
                    .copyWith(color: AppColors.text, fontWeight: FontWeight.w600)),
          Text('$typeLabel *',
              style: StyleText.fontSize12Weight500.copyWith(color: Colors.black)),
          const Spacer(),
          GestureDetector(
            onTap: () => _removeBlock(idx),
            child: Icon(Icons.close, size: 18.sp, color: ColorPick.red),
          ),
        ]),
        SizedBox(height: 6.h),
        CustomTextField(
          controller: enCtrl, fillColor: Colors.white, hint: 'Text Here',
          submitted: _submitted, isRequired: true, maxLength: 10000,
          primaryColor: ColorPick.primary, textDirection: TextDirection.ltr,
          maxLines: enMaxLines, height: enHeight,
        ),
        SizedBox(height: 8.h),
        Align(alignment: Alignment.centerRight,
            child: Text('بالعربية *', style: _labelStyle())),
        SizedBox(height: 4.h),
        CustomTextField(
          controller: arCtrl, fillColor: Colors.white, hint: 'أكتب هنا',
          isRequired: true, submitted: _submitted, primaryColor: ColorPick.primary,
          maxLength: 10000, textDirection: TextDirection.rtl,
          textAlign: TextAlign.right, maxLines: enMaxLines, height: enHeight,
        ),
      ]),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────────
  Widget _actionButtons() {
    return Column(children: [
      Row(children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _preview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF608570),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Preview',
                  style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
            ),
          ),
        ),
        SizedBox(width: 300.w),
        Expanded(
          child: Tooltip(
            message: _isPublishEnabled
                ? ''
                : 'Fill in all required fields and add an SVG image to publish',
            child: SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: _isPublishEnabled ? _publish : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPick.primary,
                  disabledBackgroundColor: AppColors.secondaryText,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Publish',
                    style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _discard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF797979),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Discard',
                  style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
            ),
          ),
        ),
        SizedBox(width: 300.w),
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _saveForLater,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF525252),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Save For Later',
                  style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ]),
    ]);
  }

  // ── Accordion ─────────────────────────────────────────────────────────────────
  Widget _accordion({
    required String       key,
    required String       title,
    required List<Widget> children,
  }) {
    final isOpen = _open[key] ?? true;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _open[key] = !isOpen),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
                color: ColorPick.primary, borderRadius: BorderRadius.circular(6.r)),
            child: Row(children: [
              Expanded(child: Text(title,
                  style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
              Icon(
                isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 20.sp,
              ),
            ]),
          ),
        ),
        if (isOpen)
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ]),
    );
  }

  Widget _addChip(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
          color: const Color(0xff797979), borderRadius: BorderRadius.circular(4.r)),
      child: Text(label,
          style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
    ),
  );

  TextStyle _labelStyle() =>
      StyleText.fontSize12Weight600.copyWith(color: AppColors.text);
}
