import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stichanda_driver/data/repository/auth_repo.dart';
import 'package:stichanda_driver/services/location_service.dart';
import 'package:equatable/equatable.dart';

import '../data/models/profile_model.dart';

class AuthState extends Equatable {
  final ProfileModel? profileModel;
  final bool isloading;
  final String? errorMessage;


  const AuthState({this.profileModel,this.isloading=false,this.errorMessage});

  AuthState copyWith({ProfileModel? profileModel,bool? isloading,String? errorMessage}) {
    return AuthState(
      isloading: isloading??this.isloading,
      profileModel: profileModel ?? this.profileModel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [profileModel,isloading,errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  final authRepo=AuthRepo();
  // Authentication logic here

  Future<User?> signUp({required String email, required String password}) async {
    emit(state.copyWith(isloading: true));
    try
        {
          authRepo.signUpWithEmailAndPassword(email, password);
        }
     catch(e){
        emit(state.copyWith(isloading: false,errorMessage: e.toString()));
     }
  }


  Future<bool> updateActiveStatus(int tempstatus) async {
    final response = await authRepo.updateActiveStatus();
    if (response==true ){
      int newActiveStatus = tempstatus;

        // Create a new ProfileModel instance with updated active status
        // the profile here would be driver profile locally stored in state
        // int newActiveStatus = profile.active == 0 ? 1 : 0;
        // ProfileModel updatedProfile = profile.copyWith(active: newActiveStatus);

        // showCustomSnackBar(response.body['message'], isError: false);

        // emit(state.copyWith(profileModel: updatedProfile));


          if (newActiveStatus == 1) {
            await LocationService().start();
          } else {
            await LocationService().stop();
          }

      }
      return Future.value(true);

    }


}