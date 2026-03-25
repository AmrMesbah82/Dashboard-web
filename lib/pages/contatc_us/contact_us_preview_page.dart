  // ******************* FILE INFO *******************
  // File Name: contact_us_cms_preview_page.dart
  // Created by: Claude Assistant

  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:flutter_svg/svg.dart';
  import 'package:go_router/go_router.dart';
  import 'package:web_app_admin/controller/contact_us/contacu_us_location_cubit.dart';
  import 'package:web_app_admin/controller/contact_us/contacu_us_location_state.dart';


  import 'package:web_app_admin/model/contact_model_location.dart';
  import 'package:web_app_admin/model/contact_us_model.dart';
  import 'package:web_app_admin/theme/appcolors.dart';
  import 'package:web_app_admin/theme/new_theme.dart';
  import 'package:web_app_admin/theme/text.dart';
  import 'package:web_app_admin/widgets/app_navbar.dart';
  import 'package:web_app_admin/widgets/app_footer.dart';

  const Color _kGreen      = Color(0xFF2D8C4E);
  const Color _kGreenLight = Color(0xFFE8F5EE);
  const Color _kDivider    = Color(0xFFDDE8DD);

  // ═══════════════════════════════════════════════════════════════════════════════
  // PAGE
  // ═══════════════════════════════════════════════════════════════════════════════

  class ContactUsCmsPreviewPage extends StatelessWidget {
    const ContactUsCmsPreviewPage({super.key});

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (_) => ContactUsCmsCubit()..load(),
        child: const _PreviewView(),
      );
    }
  }

  class _PreviewView extends StatelessWidget {
    const _PreviewView();

    @override
    Widget build(BuildContext context) {
      final double w = MediaQuery.of(context).size.width;
      final bool isMobile = w < 600;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<ContactUsCmsCubit, ContactUsCmsState>(
          builder: (context, state) {
            if (state is ContactUsCmsLoading || state is ContactUsCmsInitial) {
              return const Center(child: CircularProgressIndicator(color: _kGreen));
            }

            if (state is ContactUsCmsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<ContactUsCmsCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ContactUsCmsLoaded) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    AppNavbar(currentRoute: '/contact-cms-preview'),
                    if (isMobile)
                      _MobilePreview(data: state.data)
                    else
                      _DesktopPreview(data: state.data),
                    const AppFooter(),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // DESKTOP PREVIEW
  // ═══════════════════════════════════════════════════════════════════════════════

  class _DesktopPreview extends StatelessWidget {
    final ContactUsCmsModel data;

    const _DesktopPreview({required this.data});

    @override
    Widget build(BuildContext context) {
      final double contentW = (339.w * 4) + (12.w * 3);

      return SizedBox(
        width: 1000.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),

            // Title
            Center(
              child: SizedBox(
                width: contentW,
                child: Text(
                  'Contact us',
                  style: StyleText.fontSize45Weight600.copyWith(
                    fontSize: 48.sp,
                    color: _kGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Info Card + Form Placeholder
            Center(
              child: SizedBox(
                width: contentW,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _InfoCard(data: data),
                      ),
                      SizedBox(width: 28.w),
                      Expanded(
                        flex: 3,
                        child: _FormPlaceholder(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Office Locations
            Center(
              child: SizedBox(
                width: contentW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Office Locations',
                      style: StyleText.fontSize45Weight600.copyWith(
                        fontSize: 32.sp,
                        color: _kGreen,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: data.officeLocations.asMap().entries.map((e) {
                        final bool isLast = e.key == data.officeLocations.length - 1;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: isLast ? 0 : 16.w),
                            child: _OfficeCard(location: e.value),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 64.h),
          ],
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // MOBILE PREVIEW
  // ═══════════════════════════════════════════════════════════════════════════════

  class _MobilePreview extends StatelessWidget {
    final ContactUsCmsModel data;

    const _MobilePreview({required this.data});

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            Text(
              'Contact us',
              style: StyleText.fontSize45Weight600.copyWith(
                fontSize: 34,
                color: _kGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            _MobileInfoCard(data: data),
            const SizedBox(height: 20),

            _FormPlaceholder(isMobile: true),
            const SizedBox(height: 32),

            Text(
              'Office Locations',
              style: StyleText.fontSize22Weight700.copyWith(color: _kGreen),
            ),
            const SizedBox(height: 16),

            ...data.officeLocations.map((o) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _OfficeCardMobile(location: o),
            )),
            const SizedBox(height: 32),
          ],
        ),
      );
    }
  }

  // ─── Info Card (Desktop) ──────────────────────────────────────────────────────

  class _InfoCard extends StatelessWidget {
    final ContactUsCmsModel data;

    const _InfoCard({required this.data});

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(28.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.subDescription.en,
              style: StyleText.fontSize18Weight500.copyWith(
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 32.h),

            Text('Email', style: StyleText.fontSize16Weight600.copyWith(color: _kGreen)),
            SizedBox(height: 6.h),
            Text(data.email, style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54)),
            SizedBox(height: 28.h),

            Text('Follow Us', style: StyleText.fontSize16Weight600.copyWith(color: _kGreen)),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: data.socialIcons.where((s) => s.iconUrl.isNotEmpty).map((s) {
                return _SocialIconScaled(iconUrl: s.iconUrl);
              }).toList(),
            ),
          ],
        ),
      );
    }
  }

  // ─── Info Card (Mobile) ───────────────────────────────────────────────────────

  class _MobileInfoCard extends StatelessWidget {
    final ContactUsCmsModel data;

    const _MobileInfoCard({required this.data});

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.subDescription.en,
              style: StyleText.fontSize12Weight600.copyWith(
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 22),

            Text('Email', style: StyleText.fontSize15Weight600.copyWith(color: _kGreen)),
            const SizedBox(height: 4),
            Text(data.email, style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54)),
            const SizedBox(height: 20),

            Text('Follow Us', style: StyleText.fontSize15Weight600.copyWith(color: _kGreen)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: data.socialIcons.where((s) => s.iconUrl.isNotEmpty).map((s) {
                return _SocialIconRaw(iconUrl: s.iconUrl);
              }).toList(),
            ),
          ],
        ),
      );
    }
  }

  // ─── Form Placeholder ─────────────────────────────────────────────────────────

  class _FormPlaceholder extends StatelessWidget {
    final bool isMobile;

    const _FormPlaceholder({this.isMobile = false});

    @override
    Widget build(BuildContext context) {
      final double pad = isMobile ? 20 : 25.r;
      final double rad = isMobile ? 14 : 15.r;

      return Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rad),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GET IN TOUCH',
              style: StyleText.fontSize22Weight700.copyWith(
                fontSize: isMobile ? 22 : 26.sp,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: isMobile ? 16.0 : 20.h),

            Text('This is a preview. Form inputs are not functional.',
                style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54)),
            SizedBox(height: isMobile ? 16.0 : 20.h),

            _placeholderField('Full Name'),
            _placeholderField('Email'),
            _placeholderField('Phone Number'),
            _placeholderField('Subject'),
            _placeholderFieldLarge('Message'),

            SizedBox(height: 8.h),

            SizedBox(
              width: double.infinity,
              height: isMobile ? 52.0 : 48.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Send',
                  style: StyleText.fontSize16Weight600.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _placeholderField(String label) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
          const SizedBox(height: 6),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
             // border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(height: 4),
        ],
      );
    }

    Widget _placeholderFieldLarge(String label) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
          const SizedBox(height: 6),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(height: 4),
        ],
      );
    }
  }

  // ─── Office Card (Desktop) ────────────────────────────────────────────────────

  class _OfficeCard extends StatelessWidget {
    final ContactOfficeLocation location;

    const _OfficeCard({required this.location});

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        height: 267.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (location.iconUrl.isNotEmpty)
              Image.network(
                location.iconUrl,
                width: 100.w,
                height: 100.h,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.location_on, size: 100.w, color: _kGreen),
              )
            else
              Icon(Icons.location_on, size: 100.w, color: _kGreen),
            SizedBox(height: 16.h),

            Text(
              location.locationName.en,
              style: StyleText.fontSize16Weight700.copyWith(color: _kGreen),
            ),
            SizedBox(height: 6.h),

            if (location.text1.en.isNotEmpty)
              Text(
                location.text1.en,
                style: StyleText.fontSize13Weight400.copyWith(color: Colors.black45),
              ),
            if (location.text2.en.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  location.text2.en,
                  style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54),
                ),
              ),
          ],
        ),
      );
    }
  }

  // ─── Office Card (Mobile) ─────────────────────────────────────────────────────

  class _OfficeCardMobile extends StatelessWidget {
    final ContactOfficeLocation location;

    const _OfficeCardMobile({required this.location});

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (location.iconUrl.isNotEmpty)
              Image.network(
                location.iconUrl,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.location_on, size: 120, color: _kGreen),
              )
            else
              const Icon(Icons.location_on, size: 120, color: _kGreen),
            const SizedBox(height: 16),

            Text(
              location.locationName.en,
              style: StyleText.fontSize16Weight700.copyWith(color: _kGreen),
            ),
            const SizedBox(height: 6),

            if (location.text1.en.isNotEmpty)
              Text(
                location.text1.en,
                style: StyleText.fontSize13Weight400.copyWith(color: Colors.black45),
              ),
            if (location.text2.en.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  location.text2.en,
                  style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54),
                ),
              ),
          ],
        ),
      );
    }
  }

  // ─── Social Icons ─────────────────────────────────────────────────────────────

  class _SocialIconScaled extends StatelessWidget {
    final String iconUrl;

    const _SocialIconScaled({required this.iconUrl});

    @override
    Widget build(BuildContext context) {
      return Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          border: Border.all(color: _kGreen),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SvgPicture.network(          // ✅ Changed from Image.network
            iconUrl,
            width: 18.w,
            height: 18.h,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => Icon(Icons.link, size: 18.w, color: _kGreen),
          ),
        ),
      );
    }
  }

  class _SocialIconRaw extends StatelessWidget {
    final String iconUrl;

    const _SocialIconRaw({required this.iconUrl});

    @override
    Widget build(BuildContext context) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: _kGreen),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: SvgPicture.network(          // ✅ Changed from Image.network
            iconUrl,
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => const Icon(Icons.link, size: 18, color: _kGreen),
          ),
        ),
      );
    }
  }