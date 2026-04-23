import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/dua_service.dart';
import 'dua_event.dart';
import 'dua_state.dart';

class DuaBloc extends Bloc<DuaEvent, DuaState> {
  final DuaService _service;

  DuaBloc(this._service) : super(DuaInitial()) {
    on<LoadDuaCategoriesEvent>(_onLoad);
    on<SearchDuasEvent>(_onSearch);
    on<ClearSearchEvent>(_onClear);
  }

  Future<void> _onLoad(LoadDuaCategoriesEvent event, Emitter<DuaState> emit) async {
    emit(DuaLoading());
    try {
      final categories = await _service.loadCategories();
      emit(DuaCategoriesLoaded(categories: categories, filtered: categories));
    } catch (e) {
      emit(DuaError('Failed to load duas: $e'));
    }
  }

  void _onSearch(SearchDuasEvent event, Emitter<DuaState> emit) {
    final current = state;
    if (current is DuaCategoriesLoaded) {
      final filtered = _service.search(current.categories, event.query);
      emit(DuaCategoriesLoaded(
        categories: current.categories,
        filtered: filtered,
        searchQuery: event.query,
      ));
    }
  }

  void _onClear(ClearSearchEvent event, Emitter<DuaState> emit) {
    final current = state;
    if (current is DuaCategoriesLoaded) {
      emit(DuaCategoriesLoaded(
        categories: current.categories,
        filtered: current.categories,
        searchQuery: '',
      ));
    }
  }
}
