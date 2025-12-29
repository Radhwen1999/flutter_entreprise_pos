import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/biometric_service.dart';
import '../../data/datasources/settings_local_datasource.dart';

// ═══════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {}

class BiometricToggled extends SettingsEvent {
  final bool enabled;
  const BiometricToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class NotificationsToggled extends SettingsEvent {
  final bool enabled;
  const NotificationsToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class AutoSyncToggled extends SettingsEvent {
  final bool enabled;
  const AutoSyncToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SyncIntervalChanged extends SettingsEvent {
  final int minutes;
  const SyncIntervalChanged(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class LowStockThresholdChanged extends SettingsEvent {
  final int threshold;
  const LowStockThresholdChanged(this.threshold);

  @override
  List<Object?> get props => [threshold];
}

class CurrencyChanged extends SettingsEvent {
  final String code;
  const CurrencyChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class SettingsReset extends SettingsEvent {}

// ═══════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool biometricEnabled;
  final bool biometricAvailable;
  final bool notificationsEnabled;
  final bool autoSyncEnabled;
  final int syncInterval;
  final int lowStockThreshold;
  final String currencyCode;
  final String? biometricType; // 'fingerprint', 'face', or null

  const SettingsLoaded({
    required this.biometricEnabled,
    required this.biometricAvailable,
    required this.notificationsEnabled,
    required this.autoSyncEnabled,
    required this.syncInterval,
    required this.lowStockThreshold,
    required this.currencyCode,
    this.biometricType,
  });

  SettingsLoaded copyWith({
    bool? biometricEnabled,
    bool? biometricAvailable,
    bool? notificationsEnabled,
    bool? autoSyncEnabled,
    int? syncInterval,
    int? lowStockThreshold,
    String? currencyCode,
    String? biometricType,
  }) {
    return SettingsLoaded(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncInterval: syncInterval ?? this.syncInterval,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      currencyCode: currencyCode ?? this.currencyCode,
      biometricType: biometricType ?? this.biometricType,
    );
  }

  @override
  List<Object?> get props => [
        biometricEnabled,
        biometricAvailable,
        notificationsEnabled,
        autoSyncEnabled,
        syncInterval,
        lowStockThreshold,
        currencyCode,
        biometricType,
      ];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ═══════════════════════════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════════════════════════

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsLocalDataSource localDataSource;
  final BiometricService biometricService;

  SettingsBloc({
    required this.localDataSource,
    required this.biometricService,
  }) : super(SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<BiometricToggled>(_onBiometricToggled);
    on<NotificationsToggled>(_onNotificationsToggled);
    on<AutoSyncToggled>(_onAutoSyncToggled);
    on<SyncIntervalChanged>(_onSyncIntervalChanged);
    on<LowStockThresholdChanged>(_onLowStockThresholdChanged);
    on<CurrencyChanged>(_onCurrencyChanged);
    on<SettingsReset>(_onReset);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    try {
      // Load all settings
      final biometricEnabled = await localDataSource.getBiometricEnabled();
      final notificationsEnabled = await localDataSource.getNotificationsEnabled();
      final autoSyncEnabled = await localDataSource.getAutoSyncEnabled();
      final syncInterval = await localDataSource.getSyncInterval();
      final lowStockThreshold = await localDataSource.getLowStockThreshold();
      final currencyCode = await localDataSource.getCurrencyCode();

      // Check biometric availability
      final biometricAvailable = await biometricService.canCheckBiometrics();
      String? biometricType;
      
      if (biometricAvailable) {
        if (await biometricService.hasFaceIdSupport()) {
          biometricType = 'face';
        } else if (await biometricService.hasFingerprintSupport()) {
          biometricType = 'fingerprint';
        }
      }

      emit(SettingsLoaded(
        biometricEnabled: biometricEnabled,
        biometricAvailable: biometricAvailable,
        notificationsEnabled: notificationsEnabled,
        autoSyncEnabled: autoSyncEnabled,
        syncInterval: syncInterval,
        lowStockThreshold: lowStockThreshold,
        currencyCode: currencyCode,
        biometricType: biometricType,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onBiometricToggled(
    BiometricToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;

      if (event.enabled) {
        // Authenticate before enabling biometric
        final result = await biometricService.authenticate(
          reason: 'Authenticate to enable biometric login',
        );

        if (result.success) {
          await localDataSource.setBiometricEnabled(true);
          emit(currentState.copyWith(biometricEnabled: true));
        } else {
          // If auth fails, show error and revert to previous state
          // This ensures the toggle reverts to its original position
          emit(SettingsError(result.message));
          // Revert to previous state to fix the toggle
          emit(currentState);
        }
      } else {
        await localDataSource.setBiometricEnabled(false);
        emit(currentState.copyWith(biometricEnabled: false));
      }
    }
  }

  Future<void> _onNotificationsToggled(
    NotificationsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await localDataSource.setNotificationsEnabled(event.enabled);
      emit(currentState.copyWith(notificationsEnabled: event.enabled));
    }
  }

  Future<void> _onAutoSyncToggled(
    AutoSyncToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await localDataSource.setAutoSyncEnabled(event.enabled);
      emit(currentState.copyWith(autoSyncEnabled: event.enabled));
    }
  }

  Future<void> _onSyncIntervalChanged(
    SyncIntervalChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await localDataSource.setSyncInterval(event.minutes);
      emit(currentState.copyWith(syncInterval: event.minutes));
    }
  }

  Future<void> _onLowStockThresholdChanged(
    LowStockThresholdChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await localDataSource.setLowStockThreshold(event.threshold);
      emit(currentState.copyWith(lowStockThreshold: event.threshold));
    }
  }

  Future<void> _onCurrencyChanged(
    CurrencyChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      await localDataSource.setCurrencyCode(event.code);
      emit(currentState.copyWith(currencyCode: event.code));
    }
  }

  Future<void> _onReset(
    SettingsReset event,
    Emitter<SettingsState> emit,
  ) async {
    await localDataSource.clearSettings();
    add(SettingsLoadRequested());
  }
}
