abstract class DuaEvent {}

class LoadDuaCategoriesEvent extends DuaEvent {}

class SearchDuasEvent extends DuaEvent {
  final String query;
  SearchDuasEvent(this.query);
}

class ClearSearchEvent extends DuaEvent {}
