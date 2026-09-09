part of 'cloud_bloc.dart';

sealed class CloudEvent {}

class LoadHistory extends CloudEvent {}

class SearchCloud extends CloudEvent {
  final String queryText;
  final SearchFilter filter;

  SearchCloud({required this.queryText, required this.filter});
}
