import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Base use case interface
/// [Type] is the return type
/// [Params] is the parameter type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base stream use case for real-time data
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// No parameters class
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Pagination parameters
class PaginationParams extends Equatable {
  final int page;
  final int limit;

  const PaginationParams({
    this.page = 1,
    this.limit = 20,
  });

  int get offset => (page - 1) * limit;

  @override
  List<Object?> get props => [page, limit];
}

/// Date range parameters
class DateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Search parameters
class SearchParams extends Equatable {
  final String query;
  final int? page;
  final int? limit;

  const SearchParams({
    required this.query,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [query, page, limit];
}
