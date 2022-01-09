import 'package:chair_factory_notes/business_layer/app_cubit/app_cubit.dart';
import 'package:chair_factory_notes/presentation/widgets/note_list_builder.dart';
import 'package:chair_factory_notes/shared/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewNoteScreen extends StatelessWidget {
  const NewNoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        List<Map> notes = AppCubit.get(context).newNotes;
        return NoteListBuilder(notes: notes, noteStatus: "New");
      },
    );
  }
}
