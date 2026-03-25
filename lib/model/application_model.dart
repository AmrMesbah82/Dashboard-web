// ═══════════════════════════════════════════════════════════════════
// FILE 1: application_model.dart
// Path: lib/model/application_model.dart
// ═══════════════════════════════════════════════════════════════════

class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String department;

  // Personal Info
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String countryCode;
  final String yearOfGraduation;

  // Profile / Documents
  final String resumeUrl;
  final String resumeName;
  final String coverLetterUrl;
  final String coverLetterName;

  // Status
  final ApplicationStatus status;
  final String tag; // 'Weak', 'Adequate', 'Strong'

  // Scoring Interview
  final int technicalSkills;
  final int communicationSkills;
  final int experienceBackground;
  final int cultureFit;
  final int leadershipPotential;
  final String comments;

  // Meta
  final DateTime? applicationDate;
  final String workType;
  final String employmentType;
  final String experienceLevel;
  final String salaryRange;
  final String currency;
  final String jobLocation;
  final String employmentDuration;
  final String requiredQualification;
  final String requiredSkills;

  const ApplicationModel({
    required this.id,
    required this.jobId,
    this.jobTitle = '',
    this.department = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.countryCode = '+234',
    this.yearOfGraduation = '',
    this.resumeUrl = '',
    this.resumeName = '',
    this.coverLetterUrl = '',
    this.coverLetterName = '',
    this.status = ApplicationStatus.applied,
    this.tag = '',
    this.technicalSkills = 0,
    this.communicationSkills = 0,
    this.experienceBackground = 0,
    this.cultureFit = 0,
    this.leadershipPotential = 0,
    this.comments = '',
    this.applicationDate,
    this.workType = '',
    this.employmentType = '',
    this.experienceLevel = '',
    this.salaryRange = '',
    this.currency = '',
    this.jobLocation = '',
    this.employmentDuration = '',
    this.requiredQualification = '',
    this.requiredSkills = '',
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ApplicationModel.fromMap(String id, Map<String, dynamic> map) {
    return ApplicationModel(
      id: id,
      jobId: map['jobId'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      department: map['department'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      countryCode: map['countryCode'] as String? ?? '+234',
      yearOfGraduation: map['yearOfGraduation'] as String? ?? '',
      resumeUrl: map['resumeUrl'] as String? ?? '',
      resumeName: map['resumeName'] as String? ?? '',
      coverLetterUrl: map['coverLetterUrl'] as String? ?? '',
      coverLetterName: map['coverLetterName'] as String? ?? '',
      status: ApplicationStatusExt.fromString(map['status'] as String? ?? 'Applied'),
      tag: map['tag'] as String? ?? '',
      technicalSkills: map['technicalSkills'] as int? ?? 0,
      communicationSkills: map['communicationSkills'] as int? ?? 0,
      experienceBackground: map['experienceBackground'] as int? ?? 0,
      cultureFit: map['cultureFit'] as int? ?? 0,
      leadershipPotential: map['leadershipPotential'] as int? ?? 0,
      comments: map['comments'] as String? ?? '',
      applicationDate: map['applicationDate'] != null
          ? DateTime.tryParse(map['applicationDate'] as String)
          : null,
      workType: map['workType'] as String? ?? '',
      employmentType: map['employmentType'] as String? ?? '',
      experienceLevel: map['experienceLevel'] as String? ?? '',
      salaryRange: map['salaryRange'] as String? ?? '',
      currency: map['currency'] as String? ?? '',
      jobLocation: map['jobLocation'] as String? ?? '',
      employmentDuration: map['employmentDuration'] as String? ?? '',
      requiredQualification: map['requiredQualification'] as String? ?? '',
      requiredSkills: map['requiredSkills'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'jobId': jobId,
    'jobTitle': jobTitle,
    'department': department,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'countryCode': countryCode,
    'yearOfGraduation': yearOfGraduation,
    'resumeUrl': resumeUrl,
    'resumeName': resumeName,
    'coverLetterUrl': coverLetterUrl,
    'coverLetterName': coverLetterName,
    'status': status.label,
    'tag': tag,
    'technicalSkills': technicalSkills,
    'communicationSkills': communicationSkills,
    'experienceBackground': experienceBackground,
    'cultureFit': cultureFit,
    'leadershipPotential': leadershipPotential,
    'comments': comments,
    'applicationDate': (applicationDate ?? DateTime.now()).toIso8601String(),
    'workType': workType,
    'employmentType': employmentType,
    'experienceLevel': experienceLevel,
    'salaryRange': salaryRange,
    'currency': currency,
    'jobLocation': jobLocation,
    'employmentDuration': employmentDuration,
    'requiredQualification': requiredQualification,
    'requiredSkills': requiredSkills,
  };

  ApplicationModel copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? department,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? countryCode,
    String? yearOfGraduation,
    String? resumeUrl,
    String? resumeName,
    String? coverLetterUrl,
    String? coverLetterName,
    ApplicationStatus? status,
    String? tag,
    int? technicalSkills,
    int? communicationSkills,
    int? experienceBackground,
    int? cultureFit,
    int? leadershipPotential,
    String? comments,
    DateTime? applicationDate,
    String? workType,
    String? employmentType,
    String? experienceLevel,
    String? salaryRange,
    String? currency,
    String? jobLocation,
    String? employmentDuration,
    String? requiredQualification,
    String? requiredSkills,
  }) =>
      ApplicationModel(
        id: id ?? this.id,
        jobId: jobId ?? this.jobId,
        jobTitle: jobTitle ?? this.jobTitle,
        department: department ?? this.department,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        countryCode: countryCode ?? this.countryCode,
        yearOfGraduation: yearOfGraduation ?? this.yearOfGraduation,
        resumeUrl: resumeUrl ?? this.resumeUrl,
        resumeName: resumeName ?? this.resumeName,
        coverLetterUrl: coverLetterUrl ?? this.coverLetterUrl,
        coverLetterName: coverLetterName ?? this.coverLetterName,
        status: status ?? this.status,
        tag: tag ?? this.tag,
        technicalSkills: technicalSkills ?? this.technicalSkills,
        communicationSkills: communicationSkills ?? this.communicationSkills,
        experienceBackground: experienceBackground ?? this.experienceBackground,
        cultureFit: cultureFit ?? this.cultureFit,
        leadershipPotential: leadershipPotential ?? this.leadershipPotential,
        comments: comments ?? this.comments,
        applicationDate: applicationDate ?? this.applicationDate,
        workType: workType ?? this.workType,
        employmentType: employmentType ?? this.employmentType,
        experienceLevel: experienceLevel ?? this.experienceLevel,
        salaryRange: salaryRange ?? this.salaryRange,
        currency: currency ?? this.currency,
        jobLocation: jobLocation ?? this.jobLocation,
        employmentDuration: employmentDuration ?? this.employmentDuration,
        requiredQualification: requiredQualification ?? this.requiredQualification,
        requiredSkills: requiredSkills ?? this.requiredSkills,
      );
}

// ── Status Enum ──────────────────────────────────────────────────────────────

enum ApplicationStatus {
  applied,
  qualified,
  unqualified,
  interviewPassed,
  interviewFailed,
  interviewWithdrew,
  offerApproved,
  offerPending,
  offerRejected,
  hired,
}

extension ApplicationStatusExt on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.applied:           return 'Applied';
      case ApplicationStatus.qualified:         return 'Qualified';
      case ApplicationStatus.unqualified:       return 'Unqualified';
      case ApplicationStatus.interviewPassed:   return 'Interview: Passed';
      case ApplicationStatus.interviewFailed:   return 'Interview: Failed';
      case ApplicationStatus.interviewWithdrew: return 'Interview: Withdrew';
      case ApplicationStatus.offerApproved:     return 'Offer: Approved';
      case ApplicationStatus.offerPending:      return 'Offer: Pending';
      case ApplicationStatus.offerRejected:     return 'Offer: Rejected';
      case ApplicationStatus.hired:             return 'Hired: Completed';
    }
  }

  /// Which pipeline stage this status belongs to
  String get stage {
    switch (this) {
      case ApplicationStatus.applied:
      case ApplicationStatus.qualified:
      case ApplicationStatus.unqualified:
        return 'Applied';
      case ApplicationStatus.interviewPassed:
      case ApplicationStatus.interviewFailed:
      case ApplicationStatus.interviewWithdrew:
        return 'Interview';
      case ApplicationStatus.offerApproved:
      case ApplicationStatus.offerPending:
      case ApplicationStatus.offerRejected:
        return 'Offer';
      case ApplicationStatus.hired:
        return 'Hired';
    }
  }

  static ApplicationStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'applied':             return ApplicationStatus.applied;
      case 'qualified':           return ApplicationStatus.qualified;
      case 'unqualified':         return ApplicationStatus.unqualified;
      case 'interview: passed':   return ApplicationStatus.interviewPassed;
      case 'interview: failed':   return ApplicationStatus.interviewFailed;
      case 'interview: withdrew': return ApplicationStatus.interviewWithdrew;
      case 'offer: approved':     return ApplicationStatus.offerApproved;
      case 'offer: pending':      return ApplicationStatus.offerPending;
      case 'offer: rejected':     return ApplicationStatus.offerRejected;
      case 'hired: completed':    return ApplicationStatus.hired;
      default:                    return ApplicationStatus.applied;
    }
  }
}