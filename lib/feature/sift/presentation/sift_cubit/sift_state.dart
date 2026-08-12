import 'package:mindly/core/database/app_database.dart';

abstract class SiftState {}

class SiftLoading extends SiftState {}

class SiftLoaded extends SiftState {
  final List<Link> links;
  final int currentIndex;

  SiftLoaded({required this.links, required this.currentIndex});

  Link? get currentLink =>
      currentIndex < links.length ? links[currentIndex] : null;
  bool get isFinished => currentIndex >= links.length;

  SiftLoaded copyWith({List<Link>? links, int? currentIndex}) {
    return SiftLoaded(
      links: links ?? this.links,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class SiftEmpty extends SiftState {}

class SiftError extends SiftState {
  final String message;
  SiftError(this.message);
}