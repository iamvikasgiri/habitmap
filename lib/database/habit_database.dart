import 'package:flutter/material.dart';
import 'package:habitmap/models/app_settings.dart';
import 'package:habitmap/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Habit Database

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;
  // Set up

  // Initialize Database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  // save first date of app startup (for the Heatmap)
  Future<void> saveFisrtLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first date of app startup (for the Heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /* C R U D */

  // List of habits
  final List<Habit> currentHabits = [];

  // Create - add a new habit
  Future<void> addHabit(String habitName) async {
    // create a new habit
    final newHabit = Habit()..name = habitName;

    // save it to the database
    await isar.writeTxn(() => isar.habits.put(newHabit));

    // reding the habit from the database
    readHabits();
  }

  // Read - read saved habits from the database
  Future<void> readHabits() async {
    // fetch all habit from database
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    // update the list of current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    // update ui
    notifyListeners();
  }

  // Update - Turn habit on or off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // find specific habit
    final habit = await isar.habits.get(id);

    // update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        // if habit is completed -> add the current date to the list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          // today
          final today = DateTime.now();

          // add the current date if its not already in the list
          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            ),
          );
        }
        // if habit is not completed -> remove the current date from the list
        else {
          // remove current date if the habit is marked as not completed
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }

        // save updated habits to database
        await isar.habits.put(habit);
      });
    }

    // re-read from database
    readHabits();
  }

  // Update - Edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    // find specific habit name
    final habit = await isar.habits.get(id);

    // update habit name
    if (habit != null) {
      // update name
      await isar.writeTxn(() async {
        habit.name = newName;
        // save updated habits to database
        await isar.habits.put(habit);
      });
    }

    // re-read from database
    readHabits();
  }

  // Delete habit
  Future<void> deleteHabit(int id) async {
    // delete the haibit
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    // re-read from database
    readHabits();
  }
}
