import 'package:claudewatch/app/bootstrap/bootstrap.dart';
import 'package:claudewatch/app/bootstrap/locator_impl.dart';
import 'package:claudewatch/app/lifecycle/lifecycle_manager.dart';
import 'package:claudewatch/app/lifecycle/lifecycle_state.dart';
import 'package:claudewatch/core/config/configuration.dart';
import 'package:claudewatch/core/di/service_locator.dart';
import 'package:claudewatch/app/navigation/route_registry.dart';
import 'package:claudewatch/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:claudewatch/features/dashboard/presentation/controllers/dashboard_view_model.dart';
import 'package:claudewatch/features/history/presentation/screens/history_screen.dart';
import 'package:claudewatch/features/history/presentation/controllers/history_view_model.dart';
import 'package:claudewatch/features/prompts/presentation/screens/prompt_library_screen.dart';
import 'package:claudewatch/features/prompts/presentation/controllers/prompt_library_view_model.dart';
import 'package:claudewatch/features/search/presentation/screens/search_screen.dart';
import 'package:claudewatch/features/search/presentation/controllers/search_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Temporary Startup Logging
  debugPrint('--- CLAUDEWATCH STARTUP ---');
  debugPrint('Bootstrap started');
  AppLifecycleManager.instance.transitionTo(AppLifecycleStage.bootstrap);

  debugPrint('Dependency Registration started');
  AppLifecycleManager.instance.transitionTo(
    AppLifecycleStage.dependencyRegistration,
  );
  final bootstrapper = AppBootstrapper();
  final locator = await bootstrapper.bootstrap();
  debugPrint('DI initialized');

  debugPrint('Configuration loaded');
  AppLifecycleManager.instance.transitionTo(
    AppLifecycleStage.configurationLoaded,
  );

  debugPrint('Navigation initialized');
  AppLifecycleManager.instance.transitionTo(AppLifecycleStage.navigationReady);

  AppLifecycleManager.instance.transitionTo(AppLifecycleStage.uiReady);
  debugPrint('Lifecycle entering Running');
  AppLifecycleManager.instance.transitionTo(AppLifecycleStage.running);
  debugPrint('Application ready');

  runApp(ClaudeWatchApp(locator: locator));
}

class ClaudeWatchApp extends StatelessWidget {
  final ServiceLocator locator;

  const ClaudeWatchApp({required this.locator, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClaudeWatch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _AppShell(locator: locator),
    );
  }
}

/// The main application shell with bottom navigation.
class _AppShell extends StatefulWidget {
  final ServiceLocator locator;

  const _AppShell({required this.locator});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _selectedIndex = 0;

  late final DashboardViewModel _dashboardViewModel;
  late final HistoryViewModel _historyViewModel;
  late final PromptLibraryViewModel _promptViewModel;
  late final SearchViewModel _searchViewModel;

  @override
  void initState() {
    super.initState();
    _dashboardViewModel = widget.locator.get<DashboardViewModel>();
    _historyViewModel = widget.locator.get<HistoryViewModel>();
    _promptViewModel = widget.locator.get<PromptLibraryViewModel>();
    _searchViewModel = widget.locator.get<SearchViewModel>();
  }

  @override
  void dispose() {
    _dashboardViewModel.dispose();
    _historyViewModel.dispose();
    _promptViewModel.dispose();
    _searchViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(viewModel: _dashboardViewModel),
          HistoryScreen(viewModel: _historyViewModel),
          PromptLibraryScreen(viewModel: _promptViewModel),
          SearchScreen(viewModel: _searchViewModel),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Prompts',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}

class VerificationScreen extends StatelessWidget {
  final AppConfiguration config;

  const VerificationScreen({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final lifecycle = AppLifecycleManager.instance.currentStage;
    final isDIOk = AppServiceLocator.instance.isRegistered<AppConfiguration>();
    final isNavOk = RouteRegistry.routes.isNotEmpty;

    String getBuildMode() {
      if (kDebugMode) return 'Debug';
      if (kProfileMode) return 'Profile';
      return 'Release';
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ClaudeWatch',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Layer 2 Architecture Verification',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildStatusRow('Bootstrap Complete', true),
                        _buildStatusRow(
                          'Dependency Injection Initialized',
                          isDIOk,
                        ),
                        _buildStatusRow('Navigation Initialized', isNavOk),
                        _buildStatusRow(
                          'Lifecycle Manager Running',
                          lifecycle == AppLifecycleStage.running,
                        ),
                        _buildStatusRow('Route Registry Loaded', isNavOk),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetadataRow('Build:', getBuildMode()),
                        _buildMetadataRow('Version:', '1.0.0+1'),
                        _buildMetadataRow(
                          'Environment:',
                          config.environment.environmentName.toUpperCase(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Ready for Layer 2 Development',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isOk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.error,
            color: isOk ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
