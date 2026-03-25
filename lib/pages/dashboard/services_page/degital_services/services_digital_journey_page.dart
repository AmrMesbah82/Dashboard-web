// ******************* FILE INFO *******************
// File Name: services_digital_journey_page.dart
// Screen 4 — Services CMS: Digital Journey tab list page
// Shows subtitle + all journey item cards with edit button
// Navigates to: ServicesDigitalJourneyEditPage (screen 5/6)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_app_admin/controller/services/services_cubit.dart';
import 'package:web_app_admin/controller/services/services_state.dart';
import 'package:web_app_admin/model/services_model.dart';
import 'package:web_app_admin/theme/app_theme.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/text.dart';
import 'services_digital_journey_edit_page.dart';

class ServicesDigitalJourneyPage extends StatefulWidget {
  const ServicesDigitalJourneyPage({super.key});

  @override
  State<ServicesDigitalJourneyPage> createState() =>
      _ServicesDigitalJourneyPageState();
}

class _ServicesDigitalJourneyPageState
    extends State<ServicesDigitalJourneyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceCmsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceCmsCubit, ServiceCmsState>(
      builder: (context, state) {
        final ServicePageModel model = switch (state) {
          ServiceCmsLoaded s => s.data,
          ServiceCmsSaved s  => s.data,
          _                  => ServicePageModel.empty(),
        };

        final bool isLoading = state is ServiceCmsLoading;
        const String lastUpdated = 'Last Updated On 12 Jul 2026';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page title ──────────────────────────────────
                Text(
                  'Services',
                  style:
                  AppTextStyles.font28BlackSemiBoldCairo.copyWith(
                    fontSize:   22.sp,
                    color:      const Color(0xFF008037),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Digital Journey accordion ───────────────────
                _DJSectionCard(
                  lastUpdated: lastUpdated,
                  model:       model,
                  onEditTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ServiceCmsCubit>(),
                        child: ServicesDigitalJourneyEditPage(
                            model: model),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── DJ Section Card ──────────────────────────────────────────────────────────

class _DJSectionCard extends StatefulWidget {
  final String           lastUpdated;
  final ServicePageModel model;
  final VoidCallback     onEditTap;

  const _DJSectionCard({
    required this.lastUpdated,
    required this.model,
    required this.onEditTap,
  });

  @override
  State<_DJSectionCard> createState() => _DJSectionCardState();
}

class _DJSectionCardState extends State<_DJSectionCard> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border:       Border.all(color: const Color(0xFFDDE8DD)),
      ),
      child: Column(
        children: [
          // ── Header bar ──────────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF008037),
                borderRadius: _open
                    ? BorderRadius.only(
                  topLeft:  Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                )
                    : BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Digital Journey',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize:   14.sp,
                          fontWeight: FontWeight.w600,
                          color:      Colors.white)),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          if (_open) ...[
            // ── Last updated + Edit button ───────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.lastUpdated,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize:   11.sp,
                          color:      AppColors.secondaryBlack)),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onEditTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF008037),
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Text('Edit Details',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize:   12.sp,
                                  fontWeight: FontWeight.w600,
                                  color:      Colors.white)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.settings,
                          size: 18.sp,
                          color: AppColors.secondaryBlack),
                    ],
                  ),
                ],
              ),
            ),

            // ── Journey item grid ────────────────────────────────────
            if (widget.model.journeyItems.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: _JourneyGrid(items: widget.model.journeyItems),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Journey Grid (4-column preview) ─────────────────────────────────────────

class _JourneyGrid extends StatelessWidget {
  final List<JourneyItemModel> items;
  const _JourneyGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    // Break into rows of 4
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
            children: row.map((item) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _JourneyMiniCard(item: item),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _JourneyMiniCard extends StatelessWidget {
  final JourneyItemModel item;
  const _JourneyMiniCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color:        const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
        border:       Border.all(color: const Color(0xFFDDE8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width:  28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color:        const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: item.iconUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: SvgPicture.network(
                item.iconUrl,
                width:  18.w,
                height: 18.w,
                fit:    BoxFit.contain,
              ),
            )
                : Icon(Icons.miscellaneous_services_outlined,
                size: 16.sp, color: const Color(0xFF008037)),
          ),
          SizedBox(height: 6.h),
          Text(
            item.title.en.isNotEmpty ? item.title.en : 'Title',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   11.sp,
                fontWeight: FontWeight.w600,
                color:      const Color(0xFF1A1A1A)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            item.description.en.isNotEmpty
                ? item.description.en
                : 'Description',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize:   10.sp,
                color:      AppColors.secondaryBlack,
                height:     1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}