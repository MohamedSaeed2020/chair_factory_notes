import 'dart:io';
import 'package:chair_factory_notes/business_layer/app_cubit/app_cubit.dart';
import 'package:chair_factory_notes/presentation/screens/edit_note.dart';
import 'package:flutter/material.dart';

class NoteItemBuilder extends StatelessWidget {
  final Map notesModel;
  final BuildContext context;
  final Function()? onClosedPressed;
  final IconData? closedIcon;

  const NoteItemBuilder({
    Key? key,
    required this.notesModel,
    required this.context,
    this.onClosedPressed,
    this.closedIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditNote(notesModel: notesModel),
            ));
      },
      child: Dismissible(
        key: Key(notesModel['id'].toString()),
        onDismissed: (direction) {
          AppCubit.get(context).deleteDatabase(id: notesModel['id']);
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            color: Colors.white,
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15.0,
                    child: Text(
                      "${notesModel['id']}",
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: FileImage(
                          File("${notesModel['image']}"),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${notesModel['title']}",
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${notesModel['description']}",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${notesModel['time']}, ${notesModel['date']}",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${notesModel['status']}",
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                      onPressed: onClosedPressed,
                      icon: Icon(
                        closedIcon,
                        color: Colors.green,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
