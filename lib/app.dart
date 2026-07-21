import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth/auth_bloc.dart';
import 'auth/auth_event.dart';
import 'auth/auth_service.dart';
import 'auth/auth_state.dart';
import 'blocs/category_cubit.dart';
import 'blocs/dashboard_cubit.dart';
import 'blocs/family_cubit.dart';
import 'blocs/month_bloc.dart';
import 'blocs/recurring_bloc.dart';
import 'core/api_client.dart';
import 'core/env.dart';
import 'core/formatting.dart';
import 'repositories/category_repository.dart';
import 'repositories/family_repository.dart';
import 'repositories/finance_repository.dart';
import 'repositories/onboarding_repository.dart';
import 'repositories/recurring_repository.dart';
import 'repositories/transaction_repository.dart';
import 'ui/family_screen.dart';
import 'ui/home_screen.dart';
import 'ui/login_screen.dart';
import 'ui/onboarding_screen.dart';
import 'ui/recurring_screen.dart';
import 'ui/splash_screen.dart';
import 'theme/app_text_theme.dart';

class KeuanganApp extends StatelessWidget {
  final AuthService authService;
  const KeuanganApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
    final api = ApiClient(dio: dio, getToken: authService.currentToken);

    final categoryRepo = CategoryRepository(api);
    final txRepo = TransactionRepository(api);
    final financeRepo = FinanceRepository(api);
    final recurringRepo = RecurringRepository(api);
    final familyRepo = FamilyRepository(api);
    final onboardingRepo = OnboardingRepository(api);

    return RepositoryProvider<TransactionRepository>.value(
      value: txRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(authService)..add(AuthStarted())),
          BlocProvider(create: (_) => DashboardCubit(financeRepo)),
          BlocProvider(create: (_) => MonthBloc(finance: financeRepo, txRepo: txRepo)),
          BlocProvider(create: (_) => CategoryCubit(categoryRepo)),
          BlocProvider(create: (_) => RecurringBloc(recurringRepo)),
          BlocProvider(create: (_) => FamilyCubit(familyRepo)),
        ],
        child: MaterialApp(
          title: 'Keuangan',
          theme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            useMaterial3: true,
            textTheme: buildAppTextTheme(),
          ),
          routes: {
            '/recurring': (_) => const RecurringScreen(),
            '/family': (_) => const FamilyScreen(),
          },
          home: _Root(onboardingRepo: onboardingRepo, authService: authService),
        ),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  final OnboardingRepository onboardingRepo;
  final AuthService authService;
  const _Root({required this.onboardingRepo, required this.authService});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
          case AuthStatus.authenticating:
            return const SplashScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.authenticated:
            return _AuthedGate(onboardingRepo: onboardingRepo, displayName: authService.displayName ?? 'Saya');
        }
      },
    );
  }
}

/// After auth: bootstrap -> onboarding or main shell.
class _AuthedGate extends StatefulWidget {
  final OnboardingRepository onboardingRepo;
  final String displayName;
  const _AuthedGate({required this.onboardingRepo, required this.displayName});

  @override
  State<_AuthedGate> createState() => _AuthedGateState();
}

class _AuthedGateState extends State<_AuthedGate> {
  Future<bool>? _needsOnboarding;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _needsOnboarding = widget.onboardingRepo.needsOnboarding();
  }

  void _loadAll() {
    final ym = monthKeyOf(DateTime.now());
    context.read<MonthBloc>().add(MonthRequested(ym));
    context.read<DashboardCubit>().load(ym);
    context.read<CategoryCubit>().load();
    context.read<RecurringBloc>().add(RecurringRequested());
    context.read<FamilyCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _needsOnboarding,
      builder: (context, snap) {
        if (!snap.hasData) return const SplashScreen();
        if (snap.data == true) {
          return OnboardingScreen(
            repo: widget.onboardingRepo,
            displayName: widget.displayName,
            onDone: () => setState(() => _needsOnboarding = Future.value(false)),
          );
        }
        // Guarded: build() is not the right place for side effects, but re-running
        // _loadAll() on every rebuild would re-fire bloc events endlessly. Fire once.
        if (!_loaded) {
          _loaded = true;
          _loadAll();
        }
        return const _MainShell();
      },
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();
  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;
  static const _tabs = [HomeScreen(), RecurringScreen(), FamilyScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.repeat), label: 'Tetap'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Keluarga'),
        ],
      ),
    );
  }
}
