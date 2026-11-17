import 'package:claudewatch/core/modules/module_contracts.dart';

abstract class PlaceholderFeatureModule extends FeatureModule {
  @override
  void register(ModuleContext context) {
    // Only placeholder services would be registered here if needed
  }
}

class HomeModule extends PlaceholderFeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.home',
    name: 'Home',
    version: '1.0.0',
    dependencies: ['core.infrastructure'],
  );
}

class WidgetsModule extends PlaceholderFeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.widgets',
    name: 'Widgets',
    version: '1.0.0',
    dependencies: ['core.infrastructure', 'feature.home'],
  );
}

class AnalyticsModule extends PlaceholderFeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.analytics',
    name: 'Analytics',
    version: '1.0.0',
    dependencies: ['core.infrastructure'],
  );
}

class UsageModule extends PlaceholderFeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.usage',
    name: 'Usage',
    version: '1.0.0',
    dependencies: ['core.infrastructure'],
  );
}

class SettingsModule extends PlaceholderFeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.settings',
    name: 'Settings',
    version: '1.0.0',
    dependencies: ['core.infrastructure'],
  );
}

class SearchModule extends PlaceholderFeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.search',
    name: 'Search',
    version: '1.0.0',
    dependencies: ['core.infrastructure'],
  );
}

class PromptsModule extends PlaceholderFeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.prompts',
    name: 'Prompts',
    version: '1.0.0',
    dependencies: ['core.infrastructure'],
  );
}

class AIProvidersModule extends PlaceholderFeatureModule {
  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'feature.aiproviders',
    name: 'AI Providers',
    version: '1.0.0',
    dependencies: ['core.infrastructure'],
  );
}
