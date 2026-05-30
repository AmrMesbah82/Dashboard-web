part of '../../pages/strategy_page/strategy_edit.dart';

extension _StrategyImageWidgets on _StrategyEditPageState {
  // ══════════════════════════════════════════════════════════════════════════
  // SVG / Image detection helpers
  // ══════════════════════════════════════════════════════════════════════════

  bool _isSvgBytesCheck(Uint8List? bytes) {
    if (bytes == null || bytes.length < 5) return false;
    final checkLen = bytes.length > 100 ? 100 : bytes.length;
    final headerStr = String.fromCharCodes(bytes.sublist(0, checkLen));
    return headerStr.contains('<svg') || headerStr.contains('<?xml');
  }

  bool _isSvgUrlCheck(String url) {
    final decodedUrl = Uri.decodeFull(url).toLowerCase();
    return decodedUrl.contains('.svg') ||
        decodedUrl.contains('%2Esvg') ||
        decodedUrl.contains('image/svg+xml');
  }

  Future<Uint8List> _loadSvgBytes(String url) async {
    try {
      final res = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'arraybuffer',
      );
      if (res.status != 200) {
        throw Exception('Failed to load SVG: ${res.status}');
      }
      return (res.response as ByteBuffer).asUint8List();
    } catch (e) {
      rethrow;
    }
  }

  Widget _brokenImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.grey[400], size: 48.sp),
          SizedBox(height: 8.h),
          Text(
            'Failed to load image',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // IMAGE UPLOAD BOX — large rectangle (Strategic House sections)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _imageUploadBox({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
    VoidCallback? onRemove,
    double previewWidth = double.infinity,
    bool showError = false,
  }) {
    final hasImage = bytes != null || url.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: previewWidth,
            height: 220.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: hasImage
                ? Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Builder(
                    builder: (context) {
                      if (bytes != null) {
                        if (_isSvgBytesCheck(bytes)) {
                          return SvgPicture.memory(
                            bytes,
                            width: previewWidth,
                            height: 220.h,
                            fit: BoxFit.contain,
                            placeholderBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return Image.memory(
                            bytes,
                            width: previewWidth,
                            height: 220.h,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 48.sp,
                            ),
                          );
                        }
                      }

                      if (url.isNotEmpty) {
                        final isSvg = _isSvgUrlCheck(url);
                        if (isSvg) {
                          return FutureBuilder<Uint8List>(
                            future: _cachedLoadSvg(url),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasData) {
                                return SvgPicture.memory(
                                  snapshot.data!,
                                  width: previewWidth,
                                  height: 220.h,
                                  fit: BoxFit.contain,
                                );
                              }
                              return _brokenImagePlaceholder();
                            },
                          );
                        } else {
                          return FutureBuilder<Uint8List>(
                            future: _cachedLoadImage(url),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  width: previewWidth,
                                  height: 220.h,
                                  fit: BoxFit.contain,
                                );
                              }
                              return _brokenImagePlaceholder();
                            },
                          );
                        }
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
                if (onRemove != null)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: ColorPick.red,
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
                  ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvg(
                  assetPath: "assets/images/upload-image.svg",
                  width: 100.w,
                  height: 100.h,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Drop your image here',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (showError)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'This field is required',
              style: TextStyle(fontSize: 10.sp, color: Colors.red),
            ),
          ),

        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButtonWithImage(
              title: label,
              function: onTap,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white),
              height: 38.h,
              space: 8.sp,
              width: 250.w,
              radius: 8.r,
              color: ColorPick.primary,
              image: "",
              widthImage: 16.w,
              heightImage: 16.h,
              colorBorder: Colors.transparent,
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // IMAGE UPLOAD CIRCLE — Navigation Label icon
  // ══════════════════════════════════════════════════════════════════════════
  Widget _imageUploadCircle({
    required String label,
    required Uint8List? bytes,
    required String url,
    required VoidCallback onTap,
    bool showError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Builder(
                    builder: (context) {
                      if (bytes != null) {
                        if (_isSvgBytesCheck(bytes)) {
                          return Padding(
                            padding: EdgeInsets.all(15.r),
                            child: SvgPicture.memory(
                              bytes,
                              width: 30.w,
                              height: 30.h,
                              fit: BoxFit.contain,
                            ),
                          );
                        }
                        return Image.memory(
                          bytes,
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: 28.sp,
                          ),
                        );
                      }

                      if (url.isNotEmpty) {
                        final isSvg = _isSvgUrlCheck(url);
                        final Future<Uint8List> future = isSvg
                            ? _cachedLoadSvg(url)
                            : _cachedLoadImage(url);

                        return FutureBuilder<Uint8List>(
                          future: future,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF008037), strokeWidth: 2),
                              );
                            }
                            if (snapshot.hasData) {
                              final data = snapshot.data!;
                              if (isSvg || _isSvgBytesCheck(data)) {
                                return Padding(
                                  padding: EdgeInsets.all(15.r),
                                  child: SvgPicture.memory(
                                    data,
                                    width: 30.w,
                                    height: 30.h,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              }
                              return Image.memory(
                                data,
                                width: 60.w,
                                height: 60.h,
                                fit: BoxFit.cover,
                              );
                            }
                            return Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 28.sp,
                            );
                          },
                        );
                      }

                      return Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 22.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 25.w,
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: ColorPick.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomSvg(
                      assetPath: "assets/control/camera.svg",
                      width: 10.w,
                      height: 10.h,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showError)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'This field is required',
              style: TextStyle(fontSize: 10.sp, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
