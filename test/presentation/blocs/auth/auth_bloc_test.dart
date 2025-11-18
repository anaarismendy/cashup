import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cashup/presentation/blocs/auth/auth_bloc.dart';
import 'package:cashup/presentation/blocs/auth/auth_event.dart';
import 'package:cashup/presentation/blocs/auth/auth_state.dart';
import 'package:cashup/domain/usecases/auth/register_user.dart';
import 'package:cashup/domain/usecases/auth/login_user.dart';
import 'package:cashup/domain/usecases/auth/logout_user.dart';
import 'package:cashup/domain/usecases/auth/get_current_user.dart';
import 'package:cashup/domain/usecases/auth/reset_password.dart';
import 'package:cashup/domain/repositories/auth_repository.dart';
import 'package:cashup/domain/entities/user_entity.dart';

import 'auth_bloc_test.mocks.dart';

/// **AUTH_BLOC_TEST**
/// 
/// Pruebas unitarias para el BLoC de autenticación.
/// 
/// **Qué probamos:**
/// 1. ✅ Estados iniciales correctos
/// 2. ✅ Transiciones de estado en login exitoso
/// 3. ✅ Transiciones de estado en login fallido
/// 4. ✅ Transiciones de estado en registro exitoso
/// 5. ✅ Transiciones de estado en logout
/// 6. ✅ Manejo de errores
/// 
/// **Por qué es importante:**
/// - El BLoC maneja toda la lógica de estado de autenticación
/// - Errores aquí afectan directamente la UX
/// - Validar transiciones de estado previene bugs

// Generamos los mocks para los use cases y el repository
@GenerateMocks([
  RegisterUser,
  LoginUser,
  LogoutUser,
  GetCurrentUser,
  ResetPassword,
  AuthRepository,
])
void main() {
  // Instanciamos el bloc y los mocks
  late AuthBloc authBloc;
  late MockRegisterUser mockRegisterUser;
  late MockLoginUser mockLoginUser;
  late MockLogoutUser mockLogoutUser;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockResetPassword mockResetPassword;
  late MockAuthRepository mockAuthRepository;

  // Datos de prueba
  const tEmail = 'test@email.com';
  const tPassword = 'password123';
  const tFirstName = 'Ana Sofia';
  const tLastName = 'Arismendy';
  final tBirthDate = DateTime(2000, 1, 1);
  const tGender = 'femenino';

  // Datos de prueba para el profile
  final tProfile = ProfileEntity(
    id: 'user-123',
    email: tEmail,
    firstName: tFirstName,
    lastName: tLastName,
    birthDate: tBirthDate,
    gender: tGender,
    currency: 'COP',
  );

  // Datos de prueba para el usuario
  final tUser = UserEntity(
    id: 'user-123',
    email: tEmail,
    profile: tProfile,
  );

  // Configuramos el setUp para cada test
  setUp(() {
    mockRegisterUser = MockRegisterUser();
    mockLoginUser = MockLoginUser();
    mockLogoutUser = MockLogoutUser();
    mockGetCurrentUser = MockGetCurrentUser();
    mockResetPassword = MockResetPassword();
    mockAuthRepository = MockAuthRepository();

    // Mock del stream authStateChanges que se usa en el constructor de AuthBloc
    when(mockAuthRepository.authStateChanges)
        .thenAnswer((_) => Stream<UserEntity?>.value(null));

    // Mock de getCurrentUser que se llama automáticamente en el constructor
    when(mockGetCurrentUser()).thenAnswer((_) async => null);

    authBloc = AuthBloc(
      registerUser: mockRegisterUser,
      loginUser: mockLoginUser,
      logoutUser: mockLogoutUser,
      getCurrentUser: mockGetCurrentUser,
      resetPassword: mockResetPassword,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  // Test 1: Estado inicial correcto después de verificar
  test('initial state should be AuthUnauthenticated after check', () async {
    // El constructor llama automáticamente a AuthCheckRequested
    // que emite AuthLoading y luego AuthUnauthenticated
    // Esperamos a que termine el proceso inicial
    await Future.delayed(const Duration(milliseconds: 100));
    expect(authBloc.state, isA<AuthUnauthenticated>());
  });

  group('Login', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(mockLoginUser(
          email: tEmail,
          password: tPassword,
        )).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested(
        email: tEmail,
        password: tPassword,
      )),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
      verify: (_) {
        verify(mockLoginUser(
          email: tEmail,
          password: tPassword,
        )).called(1);
      },
    );

    // Test 2: Transiciones de estado en login fallido
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockLoginUser(
          email: tEmail,
          password: tPassword,
        )).thenThrow(Exception('Credenciales inválidas'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested(
        email: tEmail,
        password: tPassword,
      )),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Exception: Credenciales inválidas'),
      ],
    );
  });

  group('Register', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when register succeeds',
      build: () {
        when(mockRegisterUser(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        )).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthRegisterRequested(
        email: tEmail,
        password: tPassword,
        firstName: tFirstName,
        lastName: tLastName,
        birthDate: tBirthDate,
        gender: tGender,
      )),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
      verify: (_) {
        verify(mockRegisterUser(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        )).called(1);
      },
    );

    // Test 3: Transiciones de estado en registro fallido
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when register fails',
      build: () {
        when(mockRegisterUser(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        )).thenThrow(Exception('Email ya registrado'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthRegisterRequested(
        email: tEmail,
        password: tPassword,
        firstName: tFirstName,
        lastName: tLastName,
        birthDate: tBirthDate,
        gender: tGender,
      )),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Exception: Email ya registrado'),
      ],
    );
  });

  group('Logout', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout succeeds',
      build: () {
        when(mockLogoutUser()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(mockLogoutUser()).called(1);
      },
    );
  });

  group('ResetPassword', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSent] when reset password succeeds',
      build: () {
        when(mockResetPassword(email: tEmail))
            .thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthPasswordResetRequested(email: tEmail)),
      expect: () => [
        AuthLoading(),
        AuthPasswordResetSent(email: tEmail),
      ],
      verify: (_) {
        verify(mockResetPassword(email: tEmail)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when reset password fails',
      build: () {
        when(mockResetPassword(email: tEmail))
            .thenThrow(Exception('Email no encontrado'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthPasswordResetRequested(email: tEmail)),
      expect: () => [
        AuthLoading(),
        AuthError(message: 'Error al enviar email de recuperación'),
      ],
    );
  });
}

