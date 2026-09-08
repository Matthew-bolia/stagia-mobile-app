class ReponsePaginee<T> {
  const ReponsePaginee({required this.donnees, required this.meta});
  final List<T> donnees;
  final MetaPagination meta;
}

class MetaPagination {
  const MetaPagination({
    required this.page,
    required this.parPage,
    required this.total,
    required this.dernierePage,
  });
  final int page;
  final int parPage;
  final int total;
  final int dernierePage;

  factory MetaPagination.fromJson(Map<String, dynamic> json) => MetaPagination(
    page: json['page'] as int,
    parPage: json['per_page'] as int,
    total: json['total'] as int,
    dernierePage: json['last_page'] as int,
  );
}

class ErreurApi implements Exception {
  const ErreurApi({
    required this.code,
    required this.message,
    this.details,
    this.requestId,
  });
  final String code;
  final String message;
  final Object? details;
  final String? requestId;

  @override
  String toString() => message;
}
