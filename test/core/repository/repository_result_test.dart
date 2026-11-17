import "package:flutter_test/flutter_test.dart";
import "package:claudewatch/core/repository/repository_result.dart";
import "package:claudewatch/core/repository/repository_error.dart";

void main() {
  group("RepositoryResult Tests", () {
    test("RepositorySuccess holds data", () {
      const result = RepositorySuccess<String>("data");
      expect(result.data, "data");
    });

    test("RepositoryFailure holds exception", () {
      const exception = RepositoryException(
        type: RepositoryErrorType.notFound,
        message: "Item not found",
      );
      const result = RepositoryFailure<String>(exception);
      expect(result.error.type, RepositoryErrorType.notFound);
    });

    test("RepositoryCached holds data and timestamp", () {
      final now = DateTime.now();
      final result = RepositoryCached<String>("oldData", timestamp: now);
      expect(result.data, "oldData");
      expect(result.timestamp, now);
    });
  });
}
