// ******************* FILE INFO *******************
// File Name: add_intern.dart
// Figma: Adding New Intern / Editing Intern Details
// UPDATED: Fixed photo picker to only accept image formats (PNG, JPG, JPEG)

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:web_app_admin/core/custom_svg.dart';
import 'package:web_app_admin/core/widget/textfield.dart';

import '../../../../../core/constant/color.dart';
import '../../../../../core/custom_dialog.dart';
import '../../../../../core/main_widgets/admin_sub_navbar.dart';
import '../../../../../core/main_widgets/app_admin_navbar.dart';
import '../../../../../core/main_widgets/delete_intern_dialog.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../main/presentation/ui/pages/main_main.dart';
import '../../../data/models/intern_model.dart';
import '../../controller/intern_cubit.dart';
import '../../controller/intern_state.dart';


// class _C {
//   static const Color primary   = Color(0xFF008037);
//   static const Color bg        = Color(0xFFF1F2ED);
//   static const Color cardBg    = Color(0xFFFFFFFF);
//   static const Color labelText = Color(0xFF333333);
//   static const Color hintText  = Color(0xFFAAAAAA);
//   static const Color discard   = Color(0xFF797979);
//   static const Color removeRed = Color(0xFFD32F2F);
//   static const Color errorRed  = Color(0xFFD32F2F);
// }

// ═══════════════════════════════════════════════════════════════════════════════
class AddInternPage extends StatefulWidget {
  /// Pass an existing intern to edit, null to create new.
  final InternModel? existing;

  const AddInternPage({super.key, this.existing});

  @override
  State<AddInternPage> createState() => _AddInternPageState();
}

class _AddInternPageState extends State<AddInternPage> {
  bool _submitted  = false;
  bool _isSaving   = false;
  bool _isRemoving = false;

  Uint8List? _photoBytes;
  String     _photoUrl = '';

  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _positionCtrl    = TextEditingController();
  final _degreesCtrl     = TextEditingController();
  final _whatLearnedCtrl = TextEditingController();
  DateTime? _joinedDate;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.existing!;
      _photoUrl             = e.photoUrl;
      _firstNameCtrl.text   = e.firstName;
      _lastNameCtrl.text    = e.lastName;
      _positionCtrl.text    = e.position;
      _degreesCtrl.text     = e.degrees;
      _whatLearnedCtrl.text = e.whatHaveILearned;
      _joinedDate           = e.joinedDate;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _positionCtrl.dispose();
    _degreesCtrl.dispose();
    _whatLearnedCtrl.dispose();
    super.dispose();
  }

  // ── Pick photo (PNG, JPG, JPEG only - NO SVG) ────────────────────────────────
  Future<void> _pickPhoto() async {
    final completer = Completer<Uint8List?>();
    bool done = false;
    // Only accept image formats, NOT SVG
    final input = html.FileUploadInputElement()
      ..accept = 'image/png,image/jpeg,image/jpg';

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        if (!done) { done = true; completer.complete(null); }
        return;
      }

      final file = files.first;
      final fileName = file.name.toLowerCase();

      // Validate file type - reject SVG
      if (fileName.endsWith('.svg') || file.type == 'image/svg+xml') {
        if (!done) {
          done = true;
          completer.complete(null);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('SVG files are not allowed for photos. Please use PNG or JPG.',
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: Colors.white)),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
            );
          }
        }
        return;
      }

      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (!done) {
          done = true;
          if (result is List<int>) {
            completer.complete(Uint8List.fromList(result));
          } else {
            completer.complete(null);
          }
        }
      });
      reader.onError.listen((_) {
        if (!done) { done = true; completer.complete(null); }
      });
      reader.readAsArrayBuffer(files.first);
    });

    input.click();

    Future.delayed(const Duration(minutes: 5), () {
      if (!done) { done = true; completer.complete(null); }
    });

    final bytes = await completer.future;
    if (bytes != null && mounted) setState(() => _photoBytes = bytes);
  }

  // ── Custom calendar date picker ────────────────────────────────────────────
  Future<void> _pickDate() async {
    final bool isTablet =
        MediaQuery.of(context).size.shortestSide > 600;

    final result = await showCalendarDatePicker2Dialog(
      context: context,
      dialogBackgroundColor: Colors.white,
      barrierDismissible: true,
      value: [_joinedDate],
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDate: DateTime(2000),
        lastDate:  DateTime.now(),
        currentDate: _joinedDate ?? DateTime.now(),
        calendarType: CalendarDatePicker2Type.single,
        centerAlignModePicker: true,
        closeDialogOnCancelTapped: true,
        closeDialogOnOkTapped: true,

        // Day builder — rounded squares, green selected
        dayBuilder: ({
          required DateTime date,
          BoxDecoration? decoration,
          bool? isDisabled,
          bool? isSelected,
          bool? isToday,
          TextStyle? textStyle,
        }) {
          final isNow = date.day   == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year  == DateTime.now().year;
          return Center(
            child: Container(
              width: 28.sp, height: 28.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: isSelected == true
                    ? ColorPick.primary
                    : const Color(0xFFF5F5F5),
                border: Border.all(
                  color: isNow ? ColorPick.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isSelected == true
                        ? Colors.white
                        : isDisabled == true
                        ? AppColors.secondaryText
                        : AppColors.text,
                    fontWeight: isSelected == true
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },

        // OK button — green
        okButton: Material(
          color: Colors.transparent,
          child: Container(
            height: 38.sp,
            width:  isTablet ? 140.sp : 110.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: ColorPick.primary,
            ),
            child: Center(
              child: Text('Set Date',
                  style: TextStyle(
                    color:      Colors.white,
                    fontSize:   13.sp,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ),

        // Cancel button — grey
        cancelButton: Material(
          color: Colors.transparent,
          child: Container(
            height: 38.sp,
            width:  isTablet ? 140.sp : 110.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: const Color(0xFFE0E0E0),
            ),
            child: Center(
              child: Text('Cancel',
                  style: TextStyle(
                    color:      ColorPick.discard,
                    fontSize:   13.sp,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ),

        // Styling
        selectedDayHighlightColor: ColorPick.primary,
        selectedRangeHighlightColor: ColorPick.primary.withOpacity(0.15),
        weekdayLabelTextStyle: TextStyle(
          color:      ColorPick.primary,
          fontSize:   12.sp,
          fontWeight: FontWeight.w600,
        ),
        controlsTextStyle: TextStyle(
          color:      ColorPick.primary,
          fontSize:   13.sp,
          fontWeight: FontWeight.w600,
        ),
        dayTextStyle: TextStyle(
          color:    AppColors.text,
          fontSize: 11.sp,
        ),
        selectedDayTextStyle: TextStyle(
          color:      Colors.white,
          fontSize:   11.sp,
          fontWeight: FontWeight.w600,
        ),
        todayTextStyle: TextStyle(
          color:    ColorPick.primary,
          fontSize: 11.sp,
        ),
        yearTextStyle: TextStyle(
          color:    AppColors.text,
          fontSize: 12.sp,
        ),
        buttonPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 30.sp : 12.sp),
      ),
      dialogSize: isTablet ? Size(440.sp, 310.sp) : Size(320.w, 320.h),
      borderRadius: BorderRadius.circular(12),
      useSafeArea: true,
    );

    if (result != null && result.isNotEmpty && result.first != null && mounted) {
      setState(() => _joinedDate = result.first);
    }
  }

  // ── Validate all fields ────────────────────────────────────────────────────
  bool _validateAllFields() {
    // Required fields
    if (_firstNameCtrl.text.trim().isEmpty) return false;
    if (_lastNameCtrl.text.trim().isEmpty) return false;
    if (_whatLearnedCtrl.text.trim().isEmpty) return false;

    // Photo is required for new interns
    if (!_isEdit && _photoBytes == null) return false;

    // Joined date is required
    if (_joinedDate == null) return false;

    return true;
  }

  // ── Perform Save (create / update) ─────────────────────────────────────────
  Future<void> _performSave() async {
    setState(() => _isSaving = true);
    final cubit = context.read<InternCubit>();

    final tags = _positionCtrl.text.trim().isEmpty
        ? <String>[]
        : _positionCtrl.text.trim().split(' ').take(2).toList();

    final model = InternModel(
      id:               _isEdit ? widget.existing!.id : '',
      photoUrl:         _photoUrl,
      firstName:        _firstNameCtrl.text.trim(),
      lastName:         _lastNameCtrl.text.trim(),
      position:         _positionCtrl.text.trim(),
      degrees:          _degreesCtrl.text.trim(),
      joinedDate:       _joinedDate,
      whatHaveILearned: _whatLearnedCtrl.text.trim(),
      tags:             tags,
    );

    try {
      if (_isEdit) {
        await cubit.update(model, photoBytes: _photoBytes);
      } else {
        await cubit.create(model, photoBytes: _photoBytes);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Handle Publish with confirmation dialog ─────────────────────────────────
  Future<void> _handlePublish() async {
    setState(() => _submitted = true);

    if (!_validateAllFields()) {
      // Show validation error message
      String errorMessage = 'Please fill all required fields';
      if (!_isEdit && _photoBytes == null) {
        errorMessage = 'Please upload a photo (PNG or JPG)';
      } else if (_joinedDate == null) {
        errorMessage = 'Please select joined date';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: Colors.white)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r)),
        ),
      );
      return;
    }

    // Show confirmation dialog
    await showPublishConfirmDialog(
      context: context,
      title: _isEdit ? 'UPDATE INTERN' : 'PUBLISH NEW INTERN',
      subtitle: _isEdit
          ? 'Do you want to save the changes made to this intern?'
          : 'Do you want to publish this new intern?',
      confirmLabel: _isEdit ? 'Save' : 'Publish',
      backLabel: 'Back',
      onConfirm: _performSave,
    );
  }

  Future<void> _remove() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DeleteInternDialog(
        internName: '${widget.existing!.firstName} ${widget.existing!.lastName}',
        onDelete: () async {
          setState(() => _isRemoving = true);
          final cubit = context.read<InternCubit>();
          await cubit.delete(widget.existing!.id);
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternCubit, InternState>(
      listener: (context, state) {
        if (state is InternCreated || state is InternUpdated) {
          setState(() { _isSaving = false; _isRemoving = false; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isEdit ? 'Intern updated!' : 'Intern created!',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: ColorPick.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ));
          Navigator.pop(context);
        }
        if (state is InternDeleted) {
          setState(() => _isRemoving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Intern removed.',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ));
          Navigator.pop(context);
        }
        if (state is InternError) {
          setState(() { _isSaving = false; _isRemoving = false; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}',
                style: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final busy = _isSaving || _isRemoving;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: ColorPick.background,
              body: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [


                        AppAdminNavbar(
                          activeLabel: 'Web Page',
                          homePage: HomeMainPage(),
                          webPage: HomeMainPage(),
                          jobListingPage: HomeMainPage(),
                        ),
                        AdminSubNavBar(activeIndex: 5),
                        SizedBox(height: 30.h),

                        SizedBox(
                          width: 1000.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Page title ──────────────────────────────
                              Text(
                                _isEdit
                                    ? 'Editing Intern Details'
                                    : 'Adding New Intern',
                                style: StyleText.fontSize45Weight600.copyWith(
                                  color:      ColorPick.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 15.h),
                              Row(
                                children: [
                                  const Spacer(),
                                  // Remove button — edit mode only
                                  if (_isEdit)
                                    GestureDetector(
                                      onTap: busy ? null : _remove,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.w,
                                            vertical: 8.h),
                                        decoration: BoxDecoration(
                                          color: _isRemoving
                                              ? Colors.red
                                              .withOpacity(0.6)
                                              : Colors.red,
                                          borderRadius:
                                          BorderRadius.circular(6.r),
                                        ),
                                        child: _isRemoving
                                            ? SizedBox(
                                          width:  14.w,
                                          height: 14.h,
                                          child:
                                          const CircularProgressIndicator(
                                            color:       Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                            : Text(
                                          'Remove',
                                          style: StyleText
                                              .fontSize13Weight600
                                              .copyWith(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 15.h),

                              // ── Card ────────────────────────────────────
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  color:        Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    // ── Card header: title ────────────────
                                    Row(
                                      children: [
                                        Text(
                                          'Intern Information',
                                          style: StyleText.fontSize16Weight600
                                              .copyWith(
                                            color:      ColorPick.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),

                                    // ── Photo + Joined Date ─────────────────
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _photoPicker()),
                                        SizedBox(width: 20.w),
                                        Expanded(child: _dateField()),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),

                                    // ── First Name / Last Name ──────────────
                                    Row(children: [
                                      Expanded(
                                        child: CustomValidatedTextFieldMaster(
                                          label:        'First Name',
                                          hint:         'Text Here',
                                          controller:   _firstNameCtrl,
                                          height:       44,
                                          submitted:    _submitted,
                                          primaryColor: ColorPick.primary,
                                          isRequired:   true,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: CustomValidatedTextFieldMaster(
                                          label:        'Last Name',
                                          hint:         'Text Here',
                                          controller:   _lastNameCtrl,
                                          height:       44,
                                          submitted:    _submitted,
                                          primaryColor: ColorPick.primary,
                                          isRequired:   true,
                                        ),
                                      ),
                                    ]),
                                    SizedBox(height: 14.h),

                                    // ── Position / Degrees ──────────────────
                                    Row(children: [
                                      Expanded(
                                        child: CustomValidatedTextFieldMaster(
                                          label:        'Position',
                                          hint:         'Text Here',
                                          controller:   _positionCtrl,
                                          height:       44,
                                          submitted:    _submitted,
                                          primaryColor: ColorPick.primary,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: CustomValidatedTextFieldMaster(
                                          label:        'Degrees',
                                          hint:         'Text Here',
                                          controller:   _degreesCtrl,
                                          height:       44,
                                          submitted:    _submitted,
                                          primaryColor: ColorPick.primary,
                                        ),
                                      ),
                                    ]),
                                    SizedBox(height: 14.h),

                                    // ── What Have I Learned ─────────────────
                                    CustomValidatedTextFieldMaster(
                                      label:        'What Have I Learned',
                                      hint:         'Text Here',
                                      controller:   _whatLearnedCtrl,
                                      height:       100,
                                      maxLines:     5,
                                      submitted:    _submitted,
                                      primaryColor: ColorPick.primary,
                                      isRequired:   true,
                                    ),
                                    SizedBox(height: 24.h),

                                    // ── Discard / Publish buttons ───────────
                                    Row(children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: busy
                                              ? null
                                              : () => Navigator.pop(context),
                                          child: Container(
                                            height: 50.h,
                                            decoration: BoxDecoration(
                                              color: busy
                                                  ? ColorPick.discard.withOpacity(0.5)
                                                  : ColorPick.discard,
                                              borderRadius:
                                              BorderRadius.circular(8.r),
                                            ),
                                            child: Center(
                                              child: Text('Discard',
                                                  style: StyleText
                                                      .fontSize16Weight600
                                                      .copyWith(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 300.w),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: busy ? null : _handlePublish,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            height: 50.h,
                                            decoration: BoxDecoration(
                                              color: busy
                                                  ? ColorPick.primary.withOpacity(0.5)
                                                  : ColorPick.primary,
                                              borderRadius:
                                              BorderRadius.circular(8.r),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _isEdit ? 'Save' : 'Publish',
                                                style: StyleText
                                                    .fontSize16Weight600
                                                    .copyWith(
                                                    color:
                                                    Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
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
            ),

            // ── Full-screen saving overlay ─────────────────────────────────
            if (busy)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.w, vertical: 32.h),
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: _isRemoving ? Colors.red : ColorPick.primary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _isRemoving ? 'Removing...' : 'Saving...',
                          style: StyleText.fontSize14Weight600.copyWith(
                            color: _isRemoving ? Colors.red : ColorPick.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Photo picker widget ────────────────────────────────────────────────────
  Widget _photoPicker() {
    final hasPhoto = _photoBytes != null || _photoUrl.isNotEmpty;
    final hasError = _submitted && !_isEdit && !hasPhoto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Photo',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text)),
          ],
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: _pickPhoto,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width:  70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE0E0E0),
                  image: _photoBytes != null
                      ? DecorationImage(
                    image: MemoryImage(_photoBytes!),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Handle any decode errors gracefully
                      debugPrint('Error loading photo: $exception');
                    },
                  )
                      : _photoUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(_photoUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      debugPrint('Error loading photo URL: $exception');
                    },
                  )
                      : null,
                ),
                child: hasPhoto
                    ? null
                    : Center(
                  child: CustomSvg( color: Colors.grey, assetPath: 'assets/control/camera.svg',width: 30.w,height: 30.h,fit: BoxFit.fill,)
                ),
              ),
              // Camera badge
              Positioned(
                bottom: 0,
                left:   45.w,
                child: Container(
                  width:  24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color:  ColorPick.primary,
                    shape:  BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: CustomSvg(
                      assetPath: 'assets/control/camera.svg',
                      width: 11.w, height: 11.h,
                      fit: BoxFit.scaleDown,
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

  // ── Date field widget — opens custom calendar ──────────────────────────────
  Widget _dateField() {
    final label = _joinedDate != null
        ? DateFormat('dd MMM yyyy').format(_joinedDate!)
        : 'Select Date';
    final hasError = _submitted && _joinedDate == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Joined Date',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text)),
            Text(' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width:  double.infinity,
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color:        const Color(0xFFF1F2ED),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: hasError ? Colors.red: Colors.transparent,
                width: hasError ? 1.5 : 0,
              ),
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  label,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: _joinedDate != null ? AppColors.text : AppColors.secondaryText,
                  ),
                ),
              ),
              CustomSvg(
                assetPath: "assets/control/Calendar.svg",
                width: 16.w,
                height: 16.h,
                fit: BoxFit.scaleDown,
                color: hasError ? Colors.red : null,
              ),
            ]),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            'Joined date is required',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}