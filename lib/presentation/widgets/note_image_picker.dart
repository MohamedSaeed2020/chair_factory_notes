import 'package:chair_factory_notes/business_logic/app_cubit/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteImagePicker extends StatelessWidget {
  const NoteImagePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<AppCubit>(context, listen: true);
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        var noteImage = cubit.noteImage;
        return Container(
          color: Colors.white,
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              CircleAvatar(
                backgroundColor: Colors.lightBlue,
                radius: 64.0,
                child: CircleAvatar(
                  radius: 60.0,
                  backgroundImage: noteImage == null
                      ? const AssetImage('assets/images/thumbnail.png')
                      : FileImage(noteImage) as ImageProvider,
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
        );
      },
    );
  }
}
