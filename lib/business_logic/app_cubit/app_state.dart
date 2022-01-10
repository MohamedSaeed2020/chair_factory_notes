part of 'app_cubit.dart';

@immutable
abstract class AppState {}

class AppInitialState extends AppState {}

class ChangeBottomSheetState extends AppState {}

class ChangeBottomNavBarState extends AppState {}

//Database States
class CreateDatabaseState extends AppState {}

class InsertToDatabaseState extends AppState {}

class GetDatabaseLoadingState extends AppState {}

class GetDatabaseSuccessState extends AppState {}

class UpdateDatabaseLoadingState extends AppState {}

class UpdateDatabaseSuccessState extends AppState {}

class UpdateNoteStatusState extends AppState {}

class DeleteDatabaseState extends AppState {}

//Image Picking States
class NoteImagePickedSuccessState extends AppState {}

class NoteImagePickedErrorState extends AppState {}

class RemoveNoteImageState extends AppState {}
