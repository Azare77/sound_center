abstract class DataState<T> {
  final T? data;
  final dynamic error;

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(dynamic error) : super(error: error);
}
