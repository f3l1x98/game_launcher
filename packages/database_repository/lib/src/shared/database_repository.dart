import 'package:database_data_layer/database_data_layer.dart';
import 'package:database_repository/src/shared/base_model.dart';
import 'package:meta/meta.dart';

abstract class DatabaseRepository<T extends BaseModel> {
  @protected
  final Database database;

  DatabaseRepository({required this.database});

  Stream<List<T>> get all;

  Future<T?> getById(int id);

  Future<T> insert(T model);

  Future<void> update(T model);
}
