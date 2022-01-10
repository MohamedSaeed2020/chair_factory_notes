import 'package:chair_factory_notes/business_layer/app_cubit/app_cubit.dart';
import 'package:chair_factory_notes/data/models/note_model.dart';
import 'package:chair_factory_notes/presentation/widgets/build_note_item.dart';
import 'package:chair_factory_notes/presentation/widgets/no_notes.dart';
import 'package:flutter/material.dart';

class NoteListBuilder extends StatelessWidget {
  //variables
  final List<Note> notes;
  final String noteStatus;

  const NoteListBuilder(
      {Key? key, required this.notes, required this.noteStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notes.isNotEmpty) {
      return ListView.separated(
        itemBuilder: (context, index) {
          if (noteStatus == "Closed") {
            return NoteItemBuilder( notesModel: notes[index], context: context);
          } else {
            return NoteItemBuilder(
              notesModel: notes[index],
              context: context,
              onClosedPressed: () {
                AppCubit.get(context).updateNoteStatusDatabase(
                    status: 'Closed', id: notes[index].noteId);
              },
              closedIcon: Icons.lock_open,
            );
          }
        },
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 10.0,
          ),
          child: Container(
            width: double.infinity,
            height: 1.0,
            color: Colors.grey[300],
          ),
        ),
        itemCount: notes.length,);
    } else {
      return const NoNotesScreen();
    }
  }
}
