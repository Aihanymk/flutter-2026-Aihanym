import 'dart:math' show max;

import 'package:flutter/foundation.dart';

import 'countdown.dart';
import 'session_category.dart';

@immutable
class Session {
  const Session({
    required this.id,
    required this.title,
    required this.category,
    required this.scheduledAt,
    required this.venue,
    required this.limit,
    required this.online,
    this._names = const [],
    this.description,
    this.favourite = false,
  });

  Session.empty()
    : this(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        category: SessionCategory.strength,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        venue: '',
        limit: 10,
        online: false,
      );

  static const Duration length = Duration(minutes: 90);

  final String id;
  final String title;
  final SessionCategory category;
  final DateTime scheduledAt;
  final String venue;
  final int limit;
  final bool online;
  final String? description;
  final bool favourite;

  final List<String> _names;

  List<String> get names => List.unmodifiable(_names);

  int get count => _names.length;
  int get free => max(0, limit - count);
  bool get isFull => count >= limit;
  bool get isPast => scheduledAt.isBefore(DateTime.now());

  bool contains(String name) {
    final wanted = name.trim().toLowerCase();
    return wanted.isNotEmpty && _names.any((n) => n.toLowerCase() == wanted);
  }

  ({int taken, int free}) get places => (taken: count, free: free);

  Countdown countdownAt(DateTime now) {
    final untilStart = scheduledAt.difference(now);
    if (!untilStart.isNegative) return Upcoming(untilStart);
    final elapsed = -untilStart;
    return elapsed < length ? Started(elapsed) : const Ended();
  }

  Session copyWith({
    String? id,
    String? title,
    SessionCategory? category,
    DateTime? scheduledAt,
    String? venue,
    int? limit,
    bool? online,
    List<String>? names,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      venue: venue ?? this.venue,
      limit: limit ?? this.limit,
      online: online ?? this.online,
      names: List.unmodifiable(names ?? _names),
      description: clearDescription ? null : (description ?? this.description),
      favourite: favourite ?? this.favourite,
    );
  }
}
