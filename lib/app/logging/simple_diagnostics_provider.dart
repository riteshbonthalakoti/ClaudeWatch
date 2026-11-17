import 'package:claudewatch/core/logging/diagnostics.dart';

class SimpleDiagnosticsProvider implements DiagnosticsProvider {
  final List<DiagnosticsCollector> _collectors = [];

  @override
  void registerCollector(DiagnosticsCollector collector) {
    _collectors.add(collector);
  }

  @override
  Future<DiagnosticsSnapshot> generateSnapshot() async {
    final collectorData = <String, dynamic>{};
    for (final collector in _collectors) {
      await collector.collect(collectorData);
    }

    return DiagnosticsSnapshot(
      timestamp: DateTime.now(),
      appVersion: '1.0.0+1', // In a real app, use package_info_plus
      environment: 'Development', // Placeholder
      buildMode: 'Debug', // Placeholder
      registeredServicesCount: collectorData['services_count'] ?? 0,
      currentRoute: collectorData['current_route'] ?? '/',
      memoryUsagePlaceholder: '24MB',
      startupDuration: const Duration(milliseconds: 150),
    );
  }
}
