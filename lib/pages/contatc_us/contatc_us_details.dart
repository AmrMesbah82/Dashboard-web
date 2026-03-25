// ******************* FILE INFO *******************
// File Name: contact_detail_page.dart
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:web_app_admin/controller/contact_us/contatc_us_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contatc_us_state.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/core/widget/textfield.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/theme/text.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kBg         = Color(0xFFF2F2F2);
const Color _kSurface    = Color(0xFFFFFFFF);
const Color _kFieldBg    = Color(0xFFF5F5F5);

const List<Map<String, String>> _statusItems = [
  {'key': 'New',     'value': 'New'},
  {'key': 'Replied', 'value': 'Replied'},
  {'key': 'Closed',  'value': 'Closed'},
];

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class ContactDetailPage extends StatefulWidget {
  final ContactSubmission submission;
  const ContactDetailPage({super.key, required this.submission});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  late String _status;
  late final TextEditingController _noteCtrl;
  bool _submitted = false;
  bool _isSaving  = false;

  @override
  void initState() {
    super.initState();
    _status   = widget.submission.status;
    _noteCtrl = TextEditingController(text: widget.submission.note);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() { _submitted = true; _isSaving = true; });
    final updated = widget.submission.copyWith(
      status: _status,
      note:   _noteCtrl.text.trim(),
    );
    await context.read<ContactCubit>().updateSubmission(updated);
  }

  // ── Read-only field ───────────────────────────────────────────────────────

  Widget _readField(String label, String value, {bool hasCalendar = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize13Weight400.copyWith(color: Colors.black87),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          height: 42.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isEmpty ? '' : value,
                  style: StyleText.fontSize13Weight400.copyWith(
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasCalendar)
                Icon(Icons.calendar_today_outlined,
                    size: 16.sp, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  // ── Multi-line read-only field ────────────────────────────────────────────

  Widget _readFieldMulti(String label, String value, {double height = 90}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize13Weight400.copyWith(color: Colors.black87),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          height: height.h,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            value.isEmpty ? '' : value,
            style: StyleText.fontSize13Weight400.copyWith(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s = widget.submission;
    final formattedDate = DateFormat('dd/MM/yyyy').format(s.submissionDate);

    return BlocListener<ContactCubit, ContactState>(
      listener: (context, state) {
        if (state is ContactUpdated) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Submission updated successfully!'),
            backgroundColor: _kGreenSolid,
          ));
          context.goNamed('contacts');
        }
        if (state is ContactError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: _kRed,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: _kBg,
        body: Stack(
          children: [
            Column(
              children: [
                AppNavbar(currentRoute: '/contacts'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Title ──────────────────────────────────────────
                        Text(
                          'Submission Details',
                          style: StyleText.fontSize45Weight600.copyWith(
                            fontSize: 36.sp,
                            color: _kGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 28.h),

                        // ── Row 1: Status dropdown top-right ─────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 180.w,
                              child: CustomDropdownFormFieldInvMaster(
                                selectedValue: _status,
                                items: _statusItems,
                                dropdownColor: AppColors.card,
                                onChanged: (val) => setState(
                                        () => _status = val ?? _status),
                                widthIcon: 18,
                                heightIcon: 18,
                                height: 38,
                                borderRadius: 4,
                                hint: Text(
                                  'Select Status',
                                  style: StyleText.fontSize12Weight400
                                      .copyWith(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ── Card ───────────────────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            color: _kSurface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [



                              // ── Submission Date (full width) ──────────────
                              _readField(
                                'Submission Date',
                                formattedDate,
                                hasCalendar: true,
                              ),
                              SizedBox(height: 16.h),

                              // ── Full Name + Email ─────────────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _readField('Full Name', s.fullName),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: _readField('Email', s.email),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),

                              // ── Phone + Subject ───────────────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _readField(
                                      'Phone Number',
                                      '${s.countryCode} ${s.phoneNumber}',
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: _readField('Subject', s.subject),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),

                              // ── Message (multi-line read-only) ────────────
                              _readFieldMulti('Message', s.message),
                              SizedBox(height: 16.h),

                              // ── Our Notes (editable) ──────────────────────
                              Text(
                                'Our Notes',
                                style: StyleText.fontSize13Weight400
                                    .copyWith(color: Colors.black87),
                              ),
                              SizedBox(height: 6.h),
                              CustomValidatedTextFieldMaster(
                                hint:          'Text Here',
                                controller:    _noteCtrl,
                                height:        90,
                                maxLines:      4,
                                maxLength:     500,
                                showCharCount: true,
                                submitted:     _submitted,
                                onChanged:     (_) => setState(() {}),
                              ),
                              SizedBox(height: 28.h),

                              // ── Discard / Submit ──────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: _actionBtn(
                                      label: 'Discard',
                                      color: Colors.grey.shade400,
                                      onTap: () => context.goNamed('contacts'),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: _actionBtn(
                                      label: 'Submit',
                                      color: _kGreenSolid,
                                      onTap: _save,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 48.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Saving overlay ──────────────────────────────────────────────
            if (_isSaving)
              Container(
                color: Colors.black45,
                child: Center(
                  child: Container(
                    width: 180.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: _kGreenSolid),
                        SizedBox(height: 12.h),
                        Text('Saving…',
                            style: StyleText.fontSize14Weight400
                                .copyWith(color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
    required String       label,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: StyleText.fontSize15Weight600.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}