import 'dart:io';
import 'package:chair_factory_notes/business_layer/app_cubit/app_cubit.dart';
import 'package:chair_factory_notes/shared/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EditNote extends StatelessWidget {
  EditNote({Key? key, required this.notesModel}) : super(key: key);

  //variables
  final Map notesModel;
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<AppCubit>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Note'),
      ),
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          //Get fields data from database
          titleController.text = notesModel['title'];
          descriptionController.text = notesModel['description'];
          dateController.text = notesModel['date'];
          timeController.text = notesModel['time'];
          var noteImage = cubit.noteImage;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    if (state is UpdateDatabaseLoadingState)
                      const LinearProgressIndicator(),
                    if (state is UpdateDatabaseLoadingState)
                      const SizedBox(
                        height: 20.0,
                      ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    //Note Image
                    Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          radius: 64.0,
                          child: CircleAvatar(
                            radius: 60.0,
                            backgroundImage: noteImage == null
                                ? FileImage(File(notesModel['image']))
                                : FileImage(noteImage),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            cubit.getNoteImage();
                          },
                          icon: const CircleAvatar(
                            radius: 20.0,
                            child: Icon(
                              Icons.camera_alt,
                              size: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    //Note Title
                    defaultTextFormField(
                      validate: (value) {
                        if (value!.isEmpty) {
                          return 'Title Must Not Be Empty';
                        }
                      },
                      controller: titleController,
                      type: TextInputType.name,
                      label: 'Note Title',
                      icon: Icons.title,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    //Description Time
                    defaultTextFormField(
                      validate: (value) {
                        if (value!.isEmpty) {
                          return 'Description Must Not Be Empty';
                        }
                      },
                      controller: descriptionController,
                      type: TextInputType.text,
                      label: 'Note Description',
                      icon: Icons.description,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
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
                                context: context, initialTime: TimeOfDay.now())
                            .then((value) {
                          if (value != null) {
                            timeController.text = value.format(context);
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
                    const SizedBox(
                      height: 20.0,
                    ),
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
                        ).then((value) {
                          if (value != null) {
                            dateController.text =
                                DateFormat.yMMMd().format(value);
                          } else {
                            dateController.text =
                                DateFormat.yMMMd().format(DateTime.now());
                          }
                        });
                      },
                      controller: dateController,
                      type: TextInputType.datetime,
                      label: "Note Date",
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    //Update Note Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        child: defaultButton(
                          pressed: () {
                            if (formKey.currentState!.validate()) {
                              AppCubit.get(context).updateNoteDatabase(
                                context,
                                date: dateController.text,
                                time: timeController.text,
                                title: titleController.text,
                                description: descriptionController.text,
                                image: noteImage == null
                                    ? notesModel['image']
                                    : noteImage.path,
                                id: notesModel['id'],
                              );
                            }
                          },
                          text: 'Save Your Updates',
                          isUpperCase: false,
                          radius: 10.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
