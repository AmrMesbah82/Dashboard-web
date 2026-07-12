part of '../../pages/why_join_edit.dart';

extension _WhyJoinEditUi on _CareersSectionEditPageState {
  Widget _itemEditWidget(int index, _ItemEdit item) {
    final iconHasError = _submitted && index == 0 && !item.icon.hasImage;
    final svgHasError = _submitted && !item.svg.hasImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
        ] else
          SizedBox(height: 12.h),

        if (index == 0) ...[
          Row(children: [
            Text('Icon', style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
            Text(' *', style: StyleText.fontSize12Weight600.copyWith(color: Colors.red)),
          ]),
          SizedBox(height: 6.h),
          _imgBox(picked: item.icon, isAdd: true, hasError: iconHasError, onPick: () async {
            final p = await _pickImage();
            if (p != null) setState(() => item.icon = p);
          }),
          if (iconHasError) ...[
            SizedBox(height: 4.h),
            Text('Icon (SVG) is required', style: StyleText.fontSize11Weight400.copyWith(color: Colors.red)),
          ],
          SizedBox(height: 14.h),
          Row(children: [
            Expanded(
              child: CustomValidatedTextFieldMaster(
                label: 'Title', hint: 'Text Here', controller: item.titleEn,
                height: 36, fillColor: Colors.white, submitted: _submitted,
                textDirection: TextDirection.ltr, textAlign: TextAlign.left,
                primaryColor: ColorPick.primary, isRequired: true,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: CustomValidatedTextFieldMaster(
                  label: 'العنوان', hint: 'أدخل النص هنا', controller: item.titleAr,
                  height: 36, fillColor: Colors.white, submitted: _submitted,
                  textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                  primaryColor: ColorPick.primary, isRequired: true,
                ),
              ),
            ),
          ]),
          SizedBox(height: 14.h),
        ],

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('SVG', style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                  Text(' *', style: StyleText.fontSize12Weight600.copyWith(color: Colors.red)),
                ]),
                SizedBox(height: 6.h),
                _imgBox(picked: item.svg, hasError: svgHasError, onPick: () async {
                  final p = await _pickImage();
                  if (p != null) setState(() => item.svg = p);
                }),
                if (svgHasError) ...[
                  SizedBox(height: 4.h),
                  Text('SVG image is required', style: StyleText.fontSize11Weight400.copyWith(color: Colors.red)),
                ],
              ],
            ),
            const Spacer(),
            // First reason is mandatory — it can never be removed.
            if (index > 0)
              GestureDetector(
                onTap: () => setState(() => _items.removeAt(index)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(color: ColorPick.red, borderRadius: BorderRadius.circular(4.r)),
                  child: Text('Remove', style: StyleText.fontSize12Weight500.copyWith(color: Colors.white)),
                ),
              ),
          ],
        ),
        SizedBox(height: 14.h),

        CustomValidatedTextFieldMaster(
          showCharCount: false, maxLength: 500,
          label: 'Description', hint: 'Text Here', controller: item.descEn,
          height: 80, maxLines: 3, fillColor: Colors.white, submitted: _submitted,
          textDirection: TextDirection.ltr, textAlign: TextAlign.left,
          primaryColor: ColorPick.primary, isRequired: true,
        ),
        SizedBox(height: 8.h),

        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomValidatedTextFieldMaster(
            showCharCount: false, maxLength: 500,
            label: 'الوصف', hint: 'أدخل النص هنا', controller: item.descAr,
            height: 80, maxLines: 3, fillColor: Colors.white, submitted: _submitted,
            textDirection: TextDirection.rtl, textAlign: TextAlign.right,
            primaryColor: ColorPick.primary, isRequired: true,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _imgBox({required _PickedImage picked, bool isAdd = false, bool hasError = false, VoidCallback? onPick}) {
    // Delegates to the single shared image-upload circle (core/custom).
    return imageUploadCircleBare(
      bytes: picked.bytes,
      url: picked.url ?? '',
      onTap: onPick ?? () {},
    );
  }

  Widget _accordion({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          GestureDetector(
            onTap: () => setState(() => _accordionOpen = !_accordionOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(color: ColorPick.primary, borderRadius: BorderRadius.circular(8.r)),
              child: Row(children: [
                Expanded(child: Text(title, style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
                Icon(_accordionOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 20.sp),
              ]),
            ),
          ),
          if (_accordionOpen) Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ],
      ),
    );
  }

  Widget _bottomButtons(CareersSectionCubit cubit) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: CareersSectionPreviewPage(sectionKey: widget.sectionKey, sectionTitle: widget.sectionTitle),
                ),
              )),
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(color: const Color(0xFF608570), borderRadius: BorderRadius.circular(6.r)),
                child: Center(child: Text('Preview', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
              ),
            ),
          ),
          SizedBox(width: 400.w),
          Expanded(
            child: GestureDetector(
              onTap: _isSaving ? null : () => _handlePublish(cubit),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44.h,
                decoration: BoxDecoration(
                  color: _isSaving ? ColorPick.primary.withValues(alpha: 0.5) : ColorPick.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: _isSaving
                      ? SizedBox(width: 18.w, height: 18.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Publish', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.h),
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, height: 44.h,
                decoration: BoxDecoration(color: const Color(0xFF797979), borderRadius: BorderRadius.circular(6.r)),
                child: Center(child: Text('Discard', style: StyleText.fontSize14Weight600.copyWith(color: Colors.white))),
              ),
            ),
          ),
          SizedBox(width: 400.w),
          Expanded(child: Container()),
        ],
      ),
    ],
  );
}
