// ******************* FILE INFO *******************
// File Name: contact_us_list.dart
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:web_app_admin/controller/contact_us/contatc_us_cubit.dart';
import 'package:web_app_admin/controller/contact_us/contatc_us_state.dart';
import 'package:web_app_admin/core/widget/custom_dropdwon.dart';
import 'package:web_app_admin/model/contact_us_model.dart';
import 'package:web_app_admin/theme/appcolors.dart';
import 'package:web_app_admin/theme/new_theme.dart';
import 'package:web_app_admin/theme/text.dart';
import 'package:web_app_admin/widgets/app_navbar.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
const Color _kGreenSolid = Color(0xFF008037);
const Color _kRed        = Color(0xFFD32F2F);
const Color _kOrange     = Color(0xFFE65100);
const Color _kBg         = Color(0xFFF2F2F2);
const Color _kSurface    = Color(0xFFFFFFFF);

Color _statusColor(String s) => switch (s) {
  'New'     => _kGreen,
  'Replied' => _kOrange,
  'Closed'  => _kRed,
  _         => Colors.grey,
};

const List<Map<String, String>> _statusItems = [
  {'key': '',        'value': 'All'},
  {'key': 'New',     'value': 'New'},
  {'key': 'Replied', 'value': 'Replied'},
  {'key': 'Closed',  'value': 'Closed'},
];

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class ContactsListPage extends StatelessWidget {
  const ContactsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactCubit()..loadAll(),
      child: const _ContactsListView(),
    );
  }
}

class _ContactsListView extends StatefulWidget {
  const _ContactsListView();
  @override
  State<_ContactsListView> createState() => _ContactsListViewState();
}

class _ContactsListViewState extends State<_ContactsListView> {
  final _searchCtrl   = TextEditingController();
  String?   _filterStatus;
  DateTime? _filterDate;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<ContactCubit>().filter(
      status: _filterStatus,
      date:   _filterDate,
    );
  }

  void _clearFilters() {
    setState(() {
      _filterStatus = null;
      _filterDate   = null;
      _searchCtrl.clear();
    });
    context.read<ContactCubit>().clearFilter();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _kGreenSolid),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _filterDate = picked);
      _applyFilters();
    }
  }

  void _export(List<ContactSubmission> list) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export triggered'),
        backgroundColor: _kGreenSolid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: BlocBuilder<ContactCubit, ContactState>(
        // ── KEY FIX: only rebuild when state IS ContactLoaded ──────────────
        buildWhen: (_, current) =>
        current is ContactLoaded ||
            current is ContactLoading ||
            current is ContactInitial ||
            current is ContactError,
        builder: (context, state) {
          // Loading / initial
          if (state is ContactLoading || state is ContactInitial) {
            return Column(children: [
              AppNavbar(currentRoute: '/contacts'),
              const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(color: _kGreenSolid))),
            ]);
          }

          // Error
          if (state is ContactError) {
            return Column(children: [
              AppNavbar(currentRoute: '/contacts'),
              Expanded(
                  child: Center(
                      child: Text(state.message,
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: Colors.red)))),
            ]);
          }

          // ── Safe cast — only proceed when truly ContactLoaded ────────────
          if (state is! ContactLoaded) {
            return Column(children: [
              AppNavbar(currentRoute: '/contacts'),
              const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(color: _kGreenSolid))),
            ]);
          }

          final loaded = state; // ContactLoaded — safe
          return Column(
            children: [
              AppNavbar(currentRoute: '/contacts'),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                  EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Contacts',
                        style: StyleText.fontSize45Weight600.copyWith(
                          fontSize: 36.sp,
                          color: _kGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Search bar
                      _SearchBar(
                        controller: _searchCtrl,
                        onSearch: (q) =>
                            context.read<ContactCubit>().search(q),
                      ),
                      SizedBox(height: 20.h),

                      // Stats cards
                      _StatsRow(submissions: loaded.all),
                      SizedBox(height: 20.h),

                      // Filter row
                      _FilterRow(
                        selectedStatus: _filterStatus,
                        selectedDate:   _filterDate,
                        onStatusChanged: (val) {
                          setState(() =>
                          _filterStatus = (val?.isEmpty ?? true) ? null : val);
                          _applyFilters();
                        },
                        onDateTap: _pickDate,
                        onExport:  () => _export(loaded.filtered),
                        onClear:   _clearFilters,
                        hasFilter: _filterStatus != null || _filterDate != null,
                      ),
                      SizedBox(height: 12.h),

                      // Data table
                      _SubmissionsTable(
                        submissions: loaded.filtered,
                        onRowTap: (sub) {
                          // Pass submission as extra — no cubit state needed
                          context.pushNamed(
                            'contact-detail',
                            extra: sub,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>  onSearch;
  const _SearchBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(Icons.search, color: Colors.grey, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onSearch,
              style: StyleText.fontSize14Weight400,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: StyleText.fontSize14Weight400
                    .copyWith(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onSearch(controller.text),
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              decoration: BoxDecoration(
                color: _kGreenSolid,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.r),
                  bottomRight: Radius.circular(10.r),
                ),
              ),
              child: Center(
                child: Text('Search',
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<ContactSubmission> submissions;
  const _StatsRow({required this.submissions});

  int _count(String? status) => status == null
      ? submissions.length
      : submissions.where((s) => s.status == status).length;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(label: 'Total Submission', count: _count(null),     barColor: Colors.grey.shade400),
      _StatItem(label: 'New',              count: _count('New'),     barColor: _kGreenSolid),
      _StatItem(label: 'Replied',          count: _count('Replied'), barColor: _kOrange),
      _StatItem(label: 'Closed',           count: _count('Closed'),  barColor: _kRed),
    ];

    return Row(
      children: items.asMap().entries.map((e) {
        final bool isLast = e.key == items.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 16.w),
            child: _StatCard(item: e.value),
          ),
        );
      }).toList(),
    );
  }
}

class _StatItem {
  final String label;
  final int    count;
  final Color  barColor;
  const _StatItem(
      {required this.label, required this.count, required this.barColor});
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: item.barColor,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(10.r)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.label,
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: Colors.black87)),
                  Text(item.count.toString(),
                      style: StyleText.fontSize16Weight600
                          .copyWith(color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String?               selectedStatus;
  final DateTime?             selectedDate;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback          onDateTap;
  final VoidCallback          onExport;
  final VoidCallback          onClear;
  final bool                  hasFilter;

  const _FilterRow({
    required this.selectedStatus,
    required this.selectedDate,
    required this.onStatusChanged,
    required this.onDateTap,
    required this.onExport,
    required this.onClear,
    required this.hasFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 160.w,
          child: CustomDropdownFormFieldInvMaster(
            selectedValue: selectedStatus,
            items: _statusItems,
            onChanged: onStatusChanged,
            widthIcon: 18,
            heightIcon: 18,
            height: 38,
            borderRadius: 8,
            hint: Text('Select Status',
                style:
                StyleText.fontSize12Weight400.copyWith(color: Colors.grey)),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onDateTap,
          child: Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                      : 'Select Date',
                  style: StyleText.fontSize12Weight400.copyWith(
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.calendar_today_outlined,
                    size: 16.sp, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (hasFilter) ...[
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onClear,
            child: Container(
              height: 38.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text('Clear',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: Colors.black54)),
              ),
            ),
          ),
        ],
        const Spacer(),
        GestureDetector(
          onTap: onExport,
          child: Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: _kGreenSolid,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.upload_outlined, color: Colors.white, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Export',
                    style: StyleText.fontSize12Weight600
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Submissions Table ────────────────────────────────────────────────────────

class _SubmissionsTable extends StatelessWidget {
  final List<ContactSubmission>         submissions;
  final ValueChanged<ContactSubmission> onRowTap;
  const _SubmissionsTable(
      {required this.submissions, required this.onRowTap});

  static const _headers = [
    'Submission Date',
    'Full Name',
    'Email',
    'Country Code',
    'Phone Number',
    'Subject',
    'Message',
    'Note',
    'Status',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: _kGreenSolid,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(10.r)),
            ),
            child: Row(
              children: _headers
                  .map((h) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 14.h, horizontal: 8.w),
                  child: Text(h,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize12Weight600
                          .copyWith(color: Colors.white)),
                ),
              ))
                  .toList(),
            ),
          ),

          // Rows
          if (submissions.isEmpty)
            Padding(
              padding: EdgeInsets.all(32.r),
              child: Center(
                child: Text('No submissions found.',
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: Colors.grey)),
              ),
            )
          else
            ...submissions.asMap().entries.map((e) => _TableRow(
              submission: e.value,
              isEven: e.key.isEven,
              onTap: () => onRowTap(e.value),
            )),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final ContactSubmission submission;
  final bool              isEven;
  final VoidCallback      onTap;
  const _TableRow(
      {required this.submission, required this.isEven, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = submission;
    final cells = [
      DateFormat('dd/MM/yyyy').format(s.submissionDate),
      s.fullName,
      s.email,
      s.countryCode,
      s.phoneNumber,
      s.subject,
      s.message.length > 30 ? '${s.message.substring(0, 30)}…' : s.message,
      s.note.isEmpty
          ? '—'
          : (s.note.length > 20 ? '${s.note.substring(0, 20)}…' : s.note),
    ];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: isEven ? Colors.white : const Color(0xFFF9F9F9),
          child: Row(
            children: [
              ...cells.map((c) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 12.h, horizontal: 8.w),
                  child: Text(c,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: Colors.black87)),
                ),
              )),
              // Status cell
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      s.status,
                      style: StyleText.fontSize12Weight600
                          .copyWith(color: _statusColor(s.status)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}