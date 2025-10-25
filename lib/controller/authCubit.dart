import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stichanda_driver/data/models/profile_model.dart';
import 'package:stichanda_driver/data/repository/auth_repo.dart';
import 'package:stichanda_driver/services/location_service.dart';

import '../helper/firebase_error_handler.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final bool isAuthenticated;
  final ProfileModel? profile;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.profile,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    ProfileModel? profile,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      profile: profile ?? this.profile,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isAuthenticated, profile, errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;
  final LocationService _locationService;
  StreamSubscription<ProfileModel?>? _profileSub;
  StreamSubscription<Position>? _positionSub;
  int _lastAvailability = -1;

  AuthCubit({
    required AuthRepo authRepo,
    required LocationService locationService,
  })  : _authRepo = authRepo,
        _locationService = locationService,
        super(const AuthState()) {
    fetchProfile();
  }

  void _attachLocationListenerIfNeeded(int availabilityStatus) async {
    if (availabilityStatus == 1) {
      if (_lastAvailability != 1) {
        // Transitioned to online
        try { await _locationService.start(); } catch (_) {}
        await _positionSub?.cancel();
        _positionSub = _locationService.locationStream.listen((pos) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              await _authRepo.updateCurrentLocation(pos.latitude, pos.longitude);
            } catch (_) {}
          }
        });
      }
    } else {
      if (_lastAvailability != 0) {
        // Transitioned to offline
        await _positionSub?.cancel();
        _positionSub = null;
        try { await _locationService.stop(); } catch (_) {}
      }
    }
    _lastAvailability = availabilityStatus;
  }

  void _subscribeToProfile(String uid) {
    _profileSub?.cancel();
    _profileSub = _authRepo.driverProfileStream(uid).listen((profile) async {
      if (profile == null) return;
      _attachLocationListenerIfNeeded(profile.availabilityStatus);
      emit(state.copyWith(
        isAuthenticated: true,
        profile: profile,
        isLoading: false,
      ));
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fname,
    required String lname,
    required String phone,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _authRepo.signUpWithEmailAndPassword(
      email,
      password,
      fname,
      lname,
      phone,
    );

    if (result.success) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      _subscribeToProfile(uid);
    } else {
      emit(state.copyWith(isLoading: false, errorMessage: result.message));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _authRepo.signInWithEmailAndPassword(email, password);

    if (result.success) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      _subscribeToProfile(uid);
    } else {
      emit(state.copyWith(isLoading: false, errorMessage: result.message));
    }
  }

  Future<void> fetchProfile() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(state.copyWith(isLoading: false, isAuthenticated: false, profile: null));
        return;
      }
      _subscribeToProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'fetchProfile')));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void clearError() {
    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _authRepo.sendPasswordResetEmail(email);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateActiveStatus(int newStatus) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    // Snapshot current profile to allow rollback on failure
    final prevProfile = state.profile;
    final prevStatus = prevProfile?.availabilityStatus ?? 0;

    // Optimistic UI update for snappy switch feedback
    if (prevProfile != null) {
      emit(state.copyWith(
        isLoading: true,
        profile: prevProfile.copyWith(availabilityStatus: newStatus),
      ));
    } else {
      emit(state.copyWith(isLoading: true));
    }

    // Start/stop location immediately based on desired status
    try {
      if (newStatus == 1) {
        await _locationService.start();
      } else {
        await _locationService.stop();
      }
    } catch (_) {}

    final success = await _authRepo.updateActiveStatus(newStatus);

    if (!success) {
      // Rollback UI + location service if Firestore write failed
      if (prevProfile != null) {
        emit(state.copyWith(
          isLoading: false,
          profile: prevProfile,
          errorMessage: "Failed to update availability status",
        ));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: "Failed to update availability status"));
      }

      try {
        if (prevStatus == 1) {
          await _locationService.start();
        } else {
          await _locationService.stop();
        }
      } catch (_) {}
    } else {
      // Success: Firestore is updated; keep UI and finish loading
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> logout() async {
    await _profileSub?.cancel();
    await _positionSub?.cancel();
    _positionSub = null;
    _lastAvailability = -1;
    emit(state.copyWith(isLoading: true));
    await _authRepo.signOut();
    await _locationService.stop();
    emit(const AuthState(isAuthenticated: false, profile: null, isLoading: false));
  }

  @override
  Future<void> close() {
    _profileSub?.cancel();
    _positionSub?.cancel();
    return super.close();
  }
}
