import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';

/// A subject belonging to a class/curriculum combination.
class SubjectModel {
  final String id;
  final String name;
  final String iconLabel;
  final Color  iconBgColor;
  final Color  iconColor;
  final int    totalChapters;
  final int    totalTopics;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.iconLabel,
    required this.iconBgColor,
    required this.iconColor,
    this.totalChapters = 0,
    this.totalTopics   = 0,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id:            map['id']            as String,
      name:          map['name']          as String,
      iconLabel:     map['iconLabel']     as String? ?? '',
      iconBgColor:   AppColors.cardBackground,
      iconColor:     AppColors.accentCyan,
      totalChapters: (map['totalChapters'] as num?)?.toInt() ?? 0,
      totalTopics:   (map['totalTopics']   as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':            id,
    'name':          name,
    'iconLabel':     iconLabel,
    'totalChapters': totalChapters,
    'totalTopics':   totalTopics,
  };

  // ── Full catalogue — every subject the platform supports ──────────────────
  static const List<SubjectModel> _catalogue = [
    SubjectModel(
      id: 'mathematics', name: 'Mathematics',
      iconLabel: 'Σ',
      iconBgColor: AppColors.mathColor,
      iconColor:   AppColors.accentBlue,
    ),
    SubjectModel(
      id: 'physics', name: 'Physics',
      iconLabel: '⚛',
      iconBgColor: AppColors.physicsColor,
      iconColor:   AppColors.accentCyan,
    ),
    SubjectModel(
      id: 'chemistry', name: 'Chemistry',
      iconLabel: '⚗',
      iconBgColor: AppColors.chemColor,
      iconColor:   AppColors.accentGreen,
    ),
    SubjectModel(
      id: 'biology', name: 'Biology',
      iconLabel: '🧬',
      iconBgColor: AppColors.bioColor,
      iconColor:   AppColors.accentGreen,
    ),
    SubjectModel(
      id: 'computer_science', name: 'Computer Science',
      iconLabel: '</>',
      iconBgColor: AppColors.csColor,
      iconColor:   AppColors.accentPurple,
    ),
    SubjectModel(
      id: 'english', name: 'English',
      iconLabel: 'En',
      iconBgColor: AppColors.engColor,
      iconColor:   AppColors.accentOrange,
    ),
    SubjectModel(
      id: 'urdu', name: 'Urdu',
      iconLabel: 'اُ',
      iconBgColor: AppColors.urduColor,
      iconColor:   AppColors.accentOrange,
    ),
    SubjectModel(
      id: 'islamiat', name: 'Islamiat',
      iconLabel: '☪',
      iconBgColor: AppColors.islamColor,
      iconColor:   AppColors.accentGreen,
    ),
  ];

  // ── Resolve a list of SubjectModels from a set of IDs ─────────────────────
  /// Used by HomeNotifier to show only the subjects the student selected during
  /// onboarding.  Falls back to a 4-subject default when [selectedIds] is empty.
  static List<SubjectModel> fromSelectedIds(List<String> selectedIds) {
    if (selectedIds.isEmpty) {
      return defaultSubjects('');
    }
    final resolved = _catalogue
        .where((s) => selectedIds.contains(s.id))
        .toList();
    return resolved.isEmpty ? defaultSubjects('') : resolved;
  }

  /// Default 4-subject fallback for new users with no selection yet.
  static List<SubjectModel> defaultSubjects(String classLevel) {
    return _catalogue.take(4).toList();
  }
}
