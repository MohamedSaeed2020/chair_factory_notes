import 'package:chair_factory_notes/business_layer/app_cubit/app_cubit.dart';
import 'package:chair_factory_notes/presentation/widgets/note_image_picker.dart';
import 'package:chair_factory_notes/shared/components/components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //variables
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();


  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (BuildContext context, Object? state) {
        //check if you insert to database close the bottom sheet.
        if (state is InsertToDatabaseState) {
          Navigator.pop(context);
        }
      },
      builder: (BuildContext context, state) {
        AppCubit cubit = AppCubit.get(context);
        var noteImage = cubit.noteImage;
        return Scaffold(
          backgroundColor: Colors.white,
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(cubit.titles[cubit.currentIndex]),
          ),
          body: ConditionalBuilder(
              condition: state is! GetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => const CircularProgressIndicator(),
          ),
          //floatingActionButton to add new note.
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              //if it is opened insert into database
              if (cubit.isBottomSheetShown) {
                if(noteImage!=null){
                  checkFormValidation(cubit,noteImage);
                }
                else{
                  showToast('Please Select An Image', ToastStates.error);
                  checkFormValidation(cubit,noteImage);
                }
              }
              else {
                //if it is closed open it and insert into database
                scaffoldKey.currentState
                    ?.showBottomSheet(
                      (context) => SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          color:Colors.white,
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //Note Title
                                defaultTextFormField(
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Enter The Title Of The Note";
                                    }
                                  },
                                  controller: titleController,
                                  type: TextInputType.text,
                                  label: "Note Title",
                                  icon: Icons.title,
                                ),
                                const SizedBox(height: 20.0),
                                //Note Description
                                defaultTextFormField(
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Enter The Description Of The Note";
                                    }
                                  },
                                  controller: descriptionController,
                                  type: TextInputType.text,
                                  label: "Note Description",
                                  icon: Icons.description,
                                ),
                                const SizedBox(height: 20.0),
                                //Note Time
                                defaultTextFormField(
                                  readOnly: true,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Enter The Time Of The Note";
                                    }
                                  },
                                  onTap: () {
                                    showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now())
                                        .then((value) {
                                      debugPrint('$value');
                                      if (value != null) {
                                        timeController.text =
                                            value.format(context);
                                      } else {
                                        timeController.text =
                                            "${DateTime.now().hour}:${DateTime.now().minute}";
                                      }
                                    });
                                  },
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  label: "Note Time",
                                  icon: Icons.watch_later_outlined,
                                ),
                                const SizedBox(height: 20.0),
                                //Note Date
                                defaultTextFormField(
                                  readOnly: true,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Enter The Date Of The Note";
                                    }
                                  },
                                  onTap: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now(),
                                    )
                                        .then((value) {
                                      if (value != null) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value);
                                      } else {
                                        dateController.text = DateFormat.yMMMd()
                                            .format(DateTime.now());
                                      }
                                    });
                                  },
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  label: "Note Date",
                                  icon: Icons.calendar_today,
                                ),
                                const SizedBox(height: 20.0),
                                //Capture An Image By The Camera.
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: const NoteImagePicker(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      elevation: 20.0,
                    )
                    .closed
                    .then((value) {
                  cubit.changeBottomSheetState(
                      isShow: false, icon: Icons.edit);
                });
                cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
              }
            },
            child: Icon(
              cubit.fabIcon,
            ),
          ),
          //bottomNavigationBar (all notes screen and inspected notes screen)
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: "Notes",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lock),
                label: "Inspected",
              ),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: cubit.currentIndex,
            onTap: (index) {
              cubit.changeIndex(index);
            },
          ),
        );
      },
    );
  }
  void checkFormValidation(cubit,noteImage){
    if (formKey.currentState!.validate()&& noteImage!=null) {
      cubit.insertToDatabase(
        title: titleController.text,
        description: descriptionController.text,
        date: dateController.text,
        time: timeController.text,
        image:noteImage.path,
      );
      titleController.clear();
      descriptionController.clear();
      timeController.clear();
      dateController.clear();
      cubit.removeNoteImage();
      cubit.changeBottomSheetState(
          isShow: false, icon: Icons.edit);
    }
  }
}