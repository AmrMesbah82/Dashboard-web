part of '../../pages/contact_us_edit.dart';

extension _ContactUsEditUi on _ContactUsCmsEditPageState {
  // ── Form ──────────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editing Contact Us Details',
          style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
            fontSize:   36.sp,
            color:      ColorPick.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 24.h),

        _accordion(
          title:    'Info',
          isOpen:   _infoOpen,
          onToggle: () => setState(() => _infoOpen = !_infoOpen),
          child:    _infoSection(),
        ),

        _accordion(
          title:    'Office Locations',
          isOpen:   _officesOpen,
          onToggle: () => setState(() => _officesOpen = !_officesOpen),
          child:    _officeLocationsSection(),
        ),
        SizedBox(height: 16.h),

        _accordion(
          title:    'Confirm Message',
          isOpen:   _confirmOpen,
          onToggle: () => setState(() => _confirmOpen = !_confirmOpen),
          child:    _confirmMessageSection(),
        ),
        SizedBox(height: 32.h),

        _actionButtons(),
        SizedBox(height: 48.h),
      ],
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────

  Widget _accordion({
    required String   title,
    required bool     isOpen,
    required VoidCallback onToggle,
    required Widget   child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorPick.primary,
              borderRadius: isOpen
                  ? BorderRadius.circular(8)
                  : BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   16.sp,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size:  22.sp,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(12.r)),
            ),
            child:   child,
          ),
      ],
    );
  }

  // ── Info Section ──────────────────────────────────────────────────────────

  Widget _infoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        _fieldLabel('Sub description'),
        SizedBox(height: 8.h),
        CustomValidatedTextFieldMaster(
          hint:          'Text Here',
          fillColor: Colors.white,
          controller:    _subDescEnCtrl,
          height:        100,
          maxLines:      4,
          maxLength:     300,
          showCharCount: true,
          submitted:     _submitted,
          textDirection: TextDirection.ltr,
          textAlign:     TextAlign.start,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 8.h),
        _fieldLabelAr('وصف فرعي'),
        SizedBox(height: 4.h),
        CustomValidatedTextFieldMaster(
          hint:          'أدخل النص هنا',
          controller:    _subDescArCtrl,
          fillColor: Colors.white,
          height:        100,
          maxLines:      4,
          maxLength:     300,
          showCharCount: true,
          submitted:     _submitted,
          textDirection: TextDirection.rtl,
          textAlign:     TextAlign.right,
          onChanged:     (_) => setState(() {}),
        ),
        SizedBox(height: 20.h),

        // ── Email ──
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Email'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint:          'Text Here',
                    fillColor: Colors.white,
                    controller:    _emailCtrl,
                    height:        42,
                    maxLines:      1,
                    maxLength:     100,
                    submitted:     _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign:     TextAlign.start,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            SizedBox(width: 30.sp),
            const Expanded(child: Center()),
          ],
        ),
        SizedBox(height: 20.h),

        // ── Social Icons Grid ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_socialIconItems.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics:    const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:  2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing:  20.h,
                  mainAxisExtent:   100.sp,
                ),
                itemCount:    _socialIconItems.length,
                itemBuilder:  (context, index) =>
                    _socialIconWidget(_socialIconItems[index]),
              ),

            SizedBox(height: 16.h),

            GestureDetector(
              onTap: _addSocialIcon,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color:        const Color(0xFF555555),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Icon',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize:   13.sp,
                        fontWeight: FontWeight.w600,
                        color:      Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ],
    );
  }

  // ── Social Icon Widget ────────────────────────────────────────────────────

  Widget _socialIconWidget(_SocialIconItem s) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Link Dropdown ──────────────────────────────────────────────
          Row(
            children: [
              _fieldLabel('Select Link'),
              Spacer(),
              GestureDetector(
                onTap: () => _removeSocialIcon(s.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color:        ColorPick.red,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize:   12.sp,
                      fontWeight: FontWeight.w600,
                      color:      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _SocialLinkDropdown(
            footerLinks:   _footerSocialLinks,
            selectedIndex: s.selectedIndex,
            onChanged:     (idx) => setState(() => s.selectedIndex = idx),
            submitted:     _submitted,
          ),
        ],
      ),
    );
  }

  // ── Office Locations Section ──────────────────────────────────────────────

  Widget _officeLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._officeLocationItems.map(_officeLocationWidget).toList(),
        GestureDetector(
          onTap: _addOfficeLocation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color:        const Color(0xFF555555),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'Location',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize:   13.sp,
                    fontWeight: FontWeight.w600,
                    color:      Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _officeLocationWidget(_OfficeLocationItem o) {
    return Container(
      margin: EdgeInsets.only(bottom: 0.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageUploadCircle(
                label: 'Icon',
                bytes: o.iconBytes,
                url:   o.iconUrl,
                onTap: () async {
                  final b = await _pickImage(allowSvg: true);
                  if (b != null) setState(() => o.iconBytes = b);
                },
                isSvg: true,
              ),
              GestureDetector(
                onTap: () => _removeOfficeLocation(o.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color:        ColorPick.red,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize:   12.sp,
                      fontWeight: FontWeight.w600,
                      color:      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Location Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Location Name'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint:          'Text Here',
                      controller:    o.locationNameEnCtrl,
                      height:        42,
                      maxLines:      1,
                      fillColor: Colors.white,
                      maxLength:     200,
                      submitted:     _submitted,
                      textDirection: TextDirection.ltr,
                      textAlign:     TextAlign.start,
                      onChanged:     (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _fieldLabelAr('اسم الموقع'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint:          'أدخل النص هنا',
                      controller:    o.locationNameArCtrl,
                      fillColor: Colors.white,
                      height:        42,
                      maxLines:      1,
                      maxLength:     200,
                      submitted:     _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign:     TextAlign.right,
                      onChanged:     (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Text'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint:          'Text Here',
                      fillColor: Colors.white,
                      controller:    o.text1EnCtrl,
                      height:        42,
                      maxLines:      1,
                      maxLength:     200,
                      submitted:     _submitted,
                      textDirection: TextDirection.ltr,
                      textAlign:     TextAlign.start,
                      onChanged:     (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _fieldLabelAr('النص'),
                    SizedBox(height: 8.h),
                    CustomValidatedTextFieldMaster(
                      hint:          'أدخل النص هنا',
                      fillColor: Colors.white,
                      controller:    o.text1ArCtrl,
                      height:        42,
                      maxLines:      1,
                      maxLength:     200,
                      submitted:     _submitted,
                      textDirection: TextDirection.rtl,
                      textAlign:     TextAlign.right,
                      onChanged:     (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _fieldLabel('Google Maps Link'),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextFieldMaster(
                  hint:          'https://maps.google.com/?q=...',
                  controller:    o.mapLinkCtrl,
                  height:        42,
                  fillColor: Colors.white,
                  maxLines:      1,
                  maxLength:     500,
                  submitted:     false,
                  textDirection: TextDirection.ltr,
                  textAlign:     TextAlign.start,
                  onChanged:     (_) => setState(() {}),
                ),
              ),
              SizedBox(width: 15.sp),
              Expanded(child: Container())
            ],
          ),
        ],
      ),
    );
  }

  Widget _confirmMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        _imageUploadCircle(
          label: 'SVG',
          bytes: _confirmSvgBytes,
          url:   _confirmSvgUrl,
          onTap: () async {
            final b = await _pickSvgFile();
            if (b != null) setState(() => _confirmSvgBytes = b);
          },
          isSvg: true,
        ),
        SizedBox(height: 20.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Title'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint:          'Text Here',
                    fillColor: Colors.white,
                    controller:    _confirmTitleEnCtrl,
                    height:        42,
                    maxLines:      1,
                    maxLength:     200,
                    submitted:     _submitted,
                    textDirection: TextDirection.ltr,
                    textAlign:     TextAlign.start,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _fieldLabelAr('العنوان'),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    hint:          'أدخل النص هنا',
                    controller:    _confirmTitleArCtrl,
                    height:        42,
                    fillColor: Colors.white,
                    maxLines:      1,
                    maxLength:     200,
                    submitted:     _submitted,
                    textDirection: TextDirection.rtl,
                    textAlign:     TextAlign.right,
                    onChanged:     (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Description'),
            SizedBox(height: 8.h),
            CustomValidatedTextFieldMaster(
              hint:          'Text Here',
              controller:    _confirmDescEnCtrl,
              height:        100,
              fillColor: Colors.white,
              maxLines:      4,
              maxLength:     500,
              showCharCount: true,
              submitted:     _submitted,
              textDirection: TextDirection.ltr,
              textAlign:     TextAlign.start,
              onChanged:     (_) => setState(() {}),
            ),
            SizedBox(height: 16.h),
            _fieldLabelAr('الوصف'),
            SizedBox(height: 8.h),
            CustomValidatedTextFieldMaster(
              hint:          'أدخل النص هنا',
              controller:    _confirmDescArCtrl,
              fillColor: Colors.white,
              height:        100,
              maxLines:      4,
              maxLength:     500,
              showCharCount: true,
              submitted:     _submitted,
              textDirection: TextDirection.rtl,
              textAlign:     TextAlign.right,
              onChanged:     (_) => setState(() {}),
            ),
          ],
        ),
      ],
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────────────

  Widget _actionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                label:  'Preview',
                color:  const Color(0xFF608570),
                onTap:  () => context.goNamed('contact-cms-preview'),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _btn(
                label:  'Publish',
                color:  ColorPick.primary,
                onTap:  _handlePublish,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _btn(
                label:  'Discard',
                color:  const Color(0xFF797979),
                onTap:  () => context.goNamed('contact-cms'),
              ),
            ),
            SizedBox(width: 15.sp),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  // ── Saving Overlay ────────────────────────────────────────────────────────

  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width:  180.w,
          height: 100.h,
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: ColorPick.primary),
              SizedBox(height: 12.h),
              Text(
                'Saving...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   14.sp,
                  color:      Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────

  Widget _imageUploadCircle({
    required String       label,
    required Uint8List?   bytes,
    required String       url,
    required VoidCallback onTap,
    bool isSvg = false,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize:   13.sp,
            fontWeight: FontWeight.w600,
            color:      Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width:  64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: hasImage
                    ? ClipOval(child: _buildImageWidget(bytes, url, isSvg))
                    : Icon(
                  isSvg
                      ? Icons.description_outlined
                      : Icons.add,
                  color: Colors.grey[600],
                  size:  28.sp,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 25.w,
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                        child: CustomSvg(assetPath: "assets/control/camera.svg", width: 10.w, height: 10.h, fit: BoxFit.scaleDown)
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(Uint8List? bytes, String url, bool isSvg) {
    bool isSvgData = false;
    if (bytes != null && bytes.length > 5) {
      final header = String.fromCharCodes(bytes.sublist(0, 5));
      isSvgData = header.startsWith('<svg') || header.startsWith('<?xml');
    }

    if (isSvg || isSvgData) {
      if (bytes != null) {
        try {
          return Padding(
            padding: EdgeInsets.all(16.r),
            child: SvgPicture.memory(
              bytes,
              fit: BoxFit.contain,
              placeholderBuilder: (context) =>
                  Icon(Icons.description, color: Colors.grey[400], size: 28.sp),
            ),
          );
        } catch (_) {
          return Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp);
        }
      } else if (url.isNotEmpty) {
        return FutureBuilder(
          future: _loadSvg(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Icon(Icons.description, color: Colors.grey[400], size: 28.sp);
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Icon(Icons.broken_image, color: Colors.red[300], size: 28.sp);
            }
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: SvgPicture.memory(snapshot.data!, fit: BoxFit.contain),
            );
          },
        );
      }
    } else {
      if (bytes != null) return Image.memory(bytes, fit: BoxFit.cover);
      if (url.isNotEmpty) {
        return NetworkImageView(url: url, fit: BoxFit.cover);
      }
    }

    return Icon(
      isSvg ? Icons.description : Icons.image,
      color: Colors.grey,
      size:  28.sp,
    );
  }

  Future<Uint8List> _loadSvg(String url) async {
    final response = await html.HttpRequest.request(
      url,
      method:       'GET',
      responseType: 'arraybuffer',
    );
    if (response.status != 200) {
      throw Exception('Failed to load SVG: ${response.status}');
    }
    return (response.response as ByteBuffer).asUint8List();
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Cairo',
      fontSize:   13.sp,
      fontWeight: FontWeight.w600,
      color:      Colors.black87,
    ),
  );

  Widget _fieldLabelAr(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize:   13.sp,
        fontWeight: FontWeight.w600,
        color:      Colors.black87,
      ),
    ),
  );

  Widget _btn({
    required String       label,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color:        color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize:   15.sp,
              fontWeight: FontWeight.w700,
              color:      Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
