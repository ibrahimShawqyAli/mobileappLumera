abstract class StartupState {}

class StartupInit extends StartupState {}

class StartupAnimationUpdate extends StartupState {}

class StartupAnimationDone extends StartupState {}

class LoginLoading extends StartupState {}

class LoginSuccess extends StartupState {}

class LoginError extends StartupState {
  final String error;

  LoginError({required this.error});
}
