import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isAuthenticated, profile, errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;
  final LocationService _locationService;

  AuthCubit({
    required AuthRepo authRepo,
    required LocationService locationService,
  })  : _authRepo = authRepo,
        _locationService = locationService,
        super(const AuthState());


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
      final profile = await _authRepo.getDriverProfile();
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: profile,
      ));
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
    print("Login result: ${result.success}, message: ${result.message}");

    if (result.success) {
      final profile = await _authRepo.getDriverProfile();
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: profile,
      ));
    } else {
      emit(state.copyWith(isLoading: false, errorMessage: result.message));
    }
  }

  /// 🔹 Fetch Profile (on app start or refresh)
  Future<void> fetchProfile() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(state.copyWith(isLoading: false, isAuthenticated: false));
        return;
      }

      final profile = await _authRepo.getDriverProfile();
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: profile,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'fetchProfile')));
    }
    catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
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
    if (state.profile == null) return;

    emit(state.copyWith(isLoading: true));

    final success = await _authRepo.updateActiveStatus(newStatus);
    if (success) {
      final updatedProfile = state.profile!.copyWith(
        availabilityStatus: newStatus,
        updatedAt: DateTime.now(),
      );

      if (newStatus == 1) {
        await _locationService.start();
      } else {
        await _locationService.stop();
      }

      emit(state.copyWith(
        isLoading: false,
        profile: updatedProfile,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Failed to update availability status",
      ));
    }
  }


  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));

    await _authRepo.signOut();

    emit(const AuthState(
      isAuthenticated: false,
      profile: null,
      isLoading: false,
    ));
  }
}
