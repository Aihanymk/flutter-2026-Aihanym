import 'package:flutter/material.dart';

enum SessionCategory {
  strength('Strength', Icons.fitness_center),
  cardio('Cardio', Icons.directions_run),
  yoga('Yoga', Icons.self_improvement),
  swimming('Swimming', Icons.pool),
  martial('Martial arts', Icons.sports_martial_arts);

  const SessionCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color colorOf(ColorScheme scheme) => switch (this) {
    SessionCategory.strength => scheme.primary,
    SessionCategory.cardio => scheme.secondary,
    SessionCategory.yoga => scheme.tertiary,
    SessionCategory.swimming => scheme.onPrimaryContainer,
    SessionCategory.martial => scheme.error,
  };
}
