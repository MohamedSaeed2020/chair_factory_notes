import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:chair_factory_notes/data/models/note_model.dart';
import 'package:chair_factory_notes/presentation/screens/home_screen.dart';
import 'package:chair_factory_notes/presentation/screens/inspected_chairs.dart';
import 'package:chair_factory_notes/presentation/screens/new_note.dart';
import 'package:chair_factory_notes/shared/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitialState());

  //Variables
  int currentIndex = 0;
  List<Widget> screens = [
    const NewNoteScreen(),
    const InspectedChairsScreen(),
  ];
  List<String> titles = ["New Note", "Inspected Chairs"];
  Database? database;
  List<Note> allNotes = [];
  List<Note> newNotes = [];
  List<Note> inspectedChairs = [];
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  File? noteImage;
  var picker = ImagePicker();

  //get instance of AppCubit class
  static AppCubit get(context) => BlocProvider.of(context);

  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeBottomNavBarState());
  }

  void changeBottomSheetState({required bool isShow, required IconData icon}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(ChangeBottomSheetState());
  }

  void getNoteImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        noteImage = File(pickedFile.path);
        emit(NoteImagePickedSuccessState());
      } else {
        debugPrint('Error In Picking The Note Image');
        emit(NoteImagePickedErrorState());
      }
    } catch (error) {
      debugPrint('Exception In Picking The Note Image: $error');
    }
  }

  void removeNoteImage() {
    noteImage = null;
    emit(RemoveNoteImageState());
  }

  void createDatabase() {
    openDatabase(
      "chairs.db",
      version: 1,
      onCreate: (database, version) {
        debugPrint("Database hase been created successfully!");

        //create table
        database
            .execute(
                "CREATE TABLE notes (id INTEGER PRIMARY KEY, title TEXT, description TEXT, date TEXT, time TEXT, image TEXT, status TEXT)")
            .then((value) {
          debugPrint("Table hase been created successfully!");
        }).catchError((error) {
          debugPrint("Error hase been occurred ${error.toString()}");
        });
      },
      onOpen: (database) async {
        debugPrint("Database hase been opened successfully!");
        getDataFromDatabase(database);
      },
    ).then((value) {
      database = value;
      emit(CreateDatabaseState());
    });
  }

  void getDataFromDatabase(database) {
    newNotes = [];
    allNotes = [];
    inspectedChairs = [];
    emit(GetDatabaseLoadingState());
    database!.rawQuery('SELECT * FROM notes').then((List<dynamic> notes) {
      if (notes.isNotEmpty) {
        debugPrint("Database hase been returned successfully! $notes");
        allNotes = notes.map((note) {
          return Note.fromJsom(note);
        }).toList();
        for (var note in allNotes) {
          if (note.noteStatus == 'Open') {
            newNotes.add(note);
          } else {
            inspectedChairs.add(note);
          }
        }
      }
      emit(GetDatabaseSuccessState());
    });
  }

  void insertToDatabase({
    required String title,
    required String description,
    required String date,
    required String time,
    required String image,
  }) async {
    await database?.transaction((txn) async {
      txn
          .rawInsert(
        'INSERT INTO notes(title, description, date, time, image, status) VALUES("$title", "$description", "$date", "$time", "$image", "Open")',
      )
          .then((value) {
        emit(InsertToDatabaseState());
        showToast('Note Added Successfully', ToastStates.success);
        debugPrint("Database hase been inserted successfully! $value");
        getDataFromDatabase(database);
      }).catchError((error) {
        debugPrint("Error hase been occurred ${error.toString()}");
      });
    });
  }

  void updateNoteStatusDatabase({required String status, required int id}) {
    database!.rawUpdate(
        'UPDATE notes SET status = ? WHERE id = ?', [status, id]).then((value) {
      getDataFromDatabase(database);
      emit(UpdateNoteStatusState());
      showToast('Inspected Successfully', ToastStates.success);
      debugPrint("Database hase been updated successfully! $value");
    });
  }

  void updateNoteDatabase(
    BuildContext context, {
    required String title,
    required String description,
    required String date,
    required String time,
    required String image,
    required int id,
  }) {
    emit(UpdateDatabaseLoadingState());
    database!.rawUpdate(
        'UPDATE notes SET title = ?, description = ?, date = ?, time = ?, image = ? WHERE id = ?',
        [title, description, date, time, image, id]).then((value) {
      getDataFromDatabase(database);
      emit(UpdateDatabaseSuccessState());
      showToast('Note Updated Successfully', ToastStates.success);
      debugPrint("Database hase been updated successfully! $value");
    }).whenComplete(() {
      navigateAndFinish(context, const Home());
      removeNoteImage();
    });
  }

  void deleteDatabase({required int id}) {
    database!.rawDelete('DELETE from notes WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(DeleteDatabaseState());
      showToast('Note Deleted Successfully', ToastStates.success);
      debugPrint("Task hase been deleted successfully! $value");
    });
  }
}
