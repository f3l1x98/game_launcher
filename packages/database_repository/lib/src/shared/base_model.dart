import 'package:equatable/equatable.dart';

abstract class BaseModel extends Equatable {
  final int id;

  BaseModel({required this.id});

  @override
  List<Object?> get props => [id];
}
