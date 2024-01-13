// given a habit list of completion days
// is the habit completed today?

import 'package:habitmap/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completionDays) {
  final today = DateTime.now();
  return completionDays.any(
    (date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day,
  );
}

// prepare heatmap dataset
Map<DateTime, int> prepHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> dataset = {};

  for (var habit in habits) {
    for (var date in habit.completedDays) {
      // normalize date to avoid time mismatch
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // if the date already exists in the dataset, increment the count
      if (dataset.containsKey(normalizedDate)) {
        dataset[normalizedDate] = dataset[normalizedDate]! + 1;
      } else {
        // initialize with count 1
        dataset[normalizedDate] = 1;
      }
    }
  }
  return dataset;
}
