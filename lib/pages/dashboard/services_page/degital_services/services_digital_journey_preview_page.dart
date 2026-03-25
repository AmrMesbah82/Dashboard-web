// ******************* FILE INFO *******************
// File Name: services_digital_journey_preview_page.dart
// Screen 7 — Services CMS: Preview Digital Journey section
// Matches the Cards tab layout from ServicesMainPageMaster:
//   - Accordion with subtitle fields (EN + AR)
//   - 4-column journey items grid (icon, title, description)
//   - Back | Save buttons at bottom
// Save triggers confirm dialog before persisting.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/services/services_cubit.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/widgets/admin_sub_navbar.dart';

class _C {
  static const Color primary    = Color(0xFF008037);
  static const Color sectionBg  = Color(0xFFF5F5F5);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color labelText  = Color(0xFF333333);
  static const Color hintText   = Color(0xFFAAAAAA);
  static const Color greenLight = Color(0xFFE8F5EE);
  static const Color back       = Color(0xFFF1F2ED);
}

class ServicesDigitalJourneyPreviewPage extends StatefulWidget {
  final ServicePageModel model;
  const ServicesDigitalJourneyPreviewPage({super.key, required this.model});

  @override
  State<ServicesDigitalJourneyPreviewPage> createState() =>
      _ServicesDigitalJourneyPreviewPageState();
}

class _ServicesDigitalJourneyPreviewPageState
    extends State<ServicesDigitalJourneyPreviewPage> {
  bool _accordionOpen = true;

  void _onSave() async {
    final confirmed = await _showConfirmDialog(context);
    if (confirmed == true && mounted) {
      context.read<ServiceCmsCubit>().save(publishStatus: 'published');
      Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  void _onBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    return Scaffold(
      backgroundColor: _C.back,
      body: BlocListener<ServiceCmsCubit, ServiceCmsState>(
        listener: (context, state) {
          if (state is ServiceCmsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved successfully')),
            );
          }
        },
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 20.h),
                SizedBox(
                  width: 1000.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: 10.h),

                      AdminSubNavBar(activeIndex: 2),

                      SizedBox(height: 24.h),


                      // ── Title ─────────────────────────────────────────
                      Text(
                        'Preview Digital Journey Details',
                        style: StyleText.fontSize45Weight600.copyWith(
                          color: _C.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ── Accordion ─────────────────────────────────────
                      _buildAccordion(model),
                      SizedBox(height: 24.h),

                      // ── Back | Save ───────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44.h,
                              child: ElevatedButton(
                                onPressed: _onBack,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9E9E9E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text('Back',
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: SizedBox(
                              height: 44.h,
                              child: ElevatedButton(
                                onPressed: _onSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text('Save',
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────
  Widget _buildAccordion(ServicePageModel model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _accordionOpen = !_accordionOpen),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: _accordionOpen
                    ? BorderRadius.only(
                  topLeft: Radius.circular(6.r),
                  topRight: Radius.circular(6.r),
                )
                    : BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Digital Journey',
                        style: StyleText.fontSize14Weight600
                            .copyWith(color: Colors.white)),
                  ),
                  Icon(
                    _accordionOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          // Body
          if (_accordionOpen)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6.r),
                  bottomRight: Radius.circular(6.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Subtitle fields (EN + AR) ───────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _readField(
                          'SubTitle',
                          model.shortDescription.en.isEmpty
                              ? 'Text Here'
                              : model.shortDescription.en,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _readFieldRtl(
                          'العنوان',
                          model.shortDescription.ar,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // ── Journey items grid ──────────────────────────────
                  if (model.journeyItems.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Text('No journey items yet.',
                            style: StyleText.fontSize13Weight400
                                .copyWith(color: _C.hintText)),
                      ),
                    )
                  else
                    _journeyGrid(model.journeyItems),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Journey grid (4 columns, same as main page) ───────────────────────────
  Widget _journeyGrid(List<JourneyItemModel> items) {
    final List<List<JourneyItemModel>> rows = [];
    for (int i = 0; i < items.length; i += 4) {
      rows.add(items.skip(i).take(4).toList());
    }
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...row.map((item) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _journeyMiniCard(item),
                ),
              )),
              // Fill empty slots so columns stay equal width
              ...List.generate(
                  4 - row.length, (_) => const Expanded(child: SizedBox())),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Journey mini card (matches main page style) ───────────────────────────
  Widget _journeyMiniCard(JourneyItemModel item) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: _C.sectionBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: _C.greenLight,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: item.iconUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Padding(
                padding: EdgeInsets.all(7.r),
                child: SvgPicture.network(
                  item.iconUrl,
                  width: 14.w,
                  height: 14.w,
                  fit: BoxFit.contain,
                ),
              ),
            )
                : Icon(Icons.miscellaneous_services_outlined,
                size: 16.sp, color: _C.primary),
          ),
          SizedBox(height: 6.h),

          // Title
          Text(
            item.title.en.isNotEmpty ? item.title.en : 'Title',
            style: StyleText.fontSize12Weight600
                .copyWith(color: const Color(0xFF1A1A1A)),
          ),
          SizedBox(height: 4.h),

          // Description
          Text(
            item.description.en.isNotEmpty
                ? item.description.en
                : 'Description',
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryBlack, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Read-only field LTR ───────────────────────────────────────────────────
  Widget _readField(String label, String value, {double height = 36}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(label,
            style:
            StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: height.h,
          padding: EdgeInsets.symmetric(
              horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment:
          height > 36 ? Alignment.topLeft : Alignment.centerLeft,
          child: Text(
            value,
            style:
            StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
            maxLines: height > 36 ? 4 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Read-only field RTL ───────────────────────────────────────────────────
  Widget _readFieldRtl(String label, String value, {double height = 36}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(label,
              style:
              StyleText.fontSize12Weight500.copyWith(color: _C.labelText)),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            height: height.h,
            padding: EdgeInsets.symmetric(
                horizontal: 10.w, vertical: height > 36 ? 8.h : 0),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            alignment:
            height > 36 ? Alignment.topRight : Alignment.centerRight,
            child: Text(
              value.isEmpty ? 'أكتب هنا' : value,
              style:
              StyleText.fontSize12Weight400.copyWith(color: _C.hintText),
              textDirection: TextDirection.rtl,
              maxLines: height > 36 ? 4 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm Dialog ─────────────────────────────────────────────────────────

Future<bool?> _showConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(24.r),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(Icons.edit_note,
                size: 40.sp, color: const Color(0xFF008037)),
          ),
          SizedBox(height: 16.h),
          Text(
            'EDITING SERVICE DETAILS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Do you want to save the changes made to this Service Details?',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                color: AppColors.secondaryBlack),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E9E9E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('Back',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008037),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('Confirm',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}