import 'package:flutter/material.dart';
import 'package:habitmap/components/my_habit_tile.dart';
import 'package:habitmap/components/my_heat_map.dart';
import 'package:habitmap/database/habit_database.dart';
import 'package:habitmap/models/habit.dart';
import 'package:habitmap/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // read initial habits on app start up
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  // text controller
  final TextEditingController textController = TextEditingController();
  // Create new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: "Create a New Habit"),
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              // get new habit name
              String newHabitName = textController.text;

              // save to db
              context.read<HabitDatabase>().addHabit(newHabitName);

              // pop dialog
              Navigator.pop(context);

              // clear text controller
              textController.clear();
            },
            child: const Text("Save"),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear controller
              textController.clear();
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  // check habit on/off
  void checkHabitOnOff(bool? value, Habit habit) {
    // update the habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // edit habit box
  void editHabitBox(Habit habit) {
    // set controller's text to current habit name
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              // get new habit name
              String newHabitName = textController.text;

              // save to db
              context
                  .read<HabitDatabase>()
                  .updateHabitName(habit.id, newHabitName);

              // pop dialog
              Navigator.pop(context);

              // clear text controller
              textController.clear();
            },
            child: const Text("Save"),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear controller
              textController.clear();
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  // delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(" Are you sure you want to delete ${habit.name}?"),
        actions: [
          // delete button
          MaterialButton(
            onPressed: () {
              // save to db
              context.read<HabitDatabase>().deleteHabit(habit.id);

              // pop dialog
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("H A B I T M A P  "),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: [
          // Heat map
          _buildHeatMap(),

          // habit list
          _buildHabitList(),
        ],
      ),
    );
  }

  // build Heat Map
  Widget _buildHeatMap() {
    // habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return heat map
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        // once data is available -> build the heatmap
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepHeatMapDataset(currentHabits),
          );
        }

        // handles case if no data map is returned
        else {
          return Container();
        }
      },
    );
  }

  //buil habit list
  Widget _buildHabitList() {
    // habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // get current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return list of habits
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // get each individual habit
        final habit = currentHabits[index];

        // check if the habit is completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        // return habit tile
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}
