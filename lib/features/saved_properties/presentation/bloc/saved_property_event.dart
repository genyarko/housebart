import 'package:equatable/equatable.dart';

abstract class SavedPropertyEvent extends Equatable {
  const SavedPropertyEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedProperties extends SavedPropertyEvent {
  final bool refresh;

  const LoadSavedProperties({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreSavedProperties extends SavedPropertyEvent {
  const LoadMoreSavedProperties();
}

class ToggleSaveProperty extends SavedPropertyEvent {
  final String propertyId;

  const ToggleSaveProperty({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

class CheckPropertySaved extends SavedPropertyEvent {
  final String propertyId;

  const CheckPropertySaved({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}
