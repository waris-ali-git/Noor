import '../models/dua_category_model.dart';

abstract class DuaState {}

class DuaInitial extends DuaState {}

class DuaLoading extends DuaState {}

class DuaCategoriesLoaded extends DuaState {
  final List<DuaCategory> categories;
  final List<DuaCategory> filtered;
  final String searchQuery;

  DuaCategoriesLoaded({
    required this.categories,
    required this.filtered,
    this.searchQuery = '',
  });
}

class DuaError extends DuaState {
  final String message;
  DuaError(this.message);
}
