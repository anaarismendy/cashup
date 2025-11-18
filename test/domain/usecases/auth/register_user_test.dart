import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cashup/domain/usecases/auth/register_user.dart';
import 'package:cashup/domain/repositories/auth_repository.dart';
import 'package:cashup/domain/entities/user_entity.dart';

import 'register_user_test.mocks.dart';

/// **REGISTER_USER_TEST**
/// 
/// Pruebas unitarias para el caso de uso RegisterUser.
/// 
/// **Qué probamos:**
/// 1. ✅ Registro exitoso con datos válidos
/// 2. ✅ Llamada correcta al repository con parámetros correctos
/// 3. ✅ Propagación de errores del repository
/// 
/// **Por qué es importante:**
/// - El registro es crítico para la seguridad de la app
/// - Valida que los datos se pasen correctamente entre capas
/// - Asegura que los errores se manejen apropiadamente

@GenerateMocks([AuthRepository])
void main() {
  // Instanciamos el use case y el mock del repository
  late RegisterUser useCase;
  late MockAuthRepository mockRepository;

  // Configuramos el setUp para cada test
  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUser(mockRepository);
  });

  group('RegisterUser', () {
    // Datos de prueba
    const tEmail = 'test@email.com';
    const tPassword = 'password123';
    const tFirstName = 'Ana Sofia';
    const tLastName = 'Arismendy';
    final tBirthDate = DateTime(2000, 1, 1);
    const tGender = 'femenino';

    final tProfile = ProfileEntity(
      id: 'user-123',
      email: tEmail,
      firstName: tFirstName,
      lastName: tLastName,
      birthDate: tBirthDate,
      gender: tGender,
      currency: 'COP',
    );

    final tUser = UserEntity(
      id: 'user-123',
      email: tEmail,
      profile: tProfile,
    );

    // Test 1: Registro exitoso cuando el repository retorna un usuario
    test(
      'should register user successfully when repository returns user',
      () async {
        // Arrange (Preparar)
        // Configuramos el mock para que retorne un usuario exitoso
        when(mockRepository.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        )).thenAnswer((_) async => tUser);

        // Act (Actuar)
        // Ejecutamos el caso de uso
        final result = await useCase(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        );

        // Assert (Verificar)
        // Verificamos que el resultado sea el esperado
        expect(result, equals(tUser));
        
        // Verificamos que el repository fue llamado con los parámetros correctos
        verify(mockRepository.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        )).called(1);
        
        // Verificamos que no se llamaron otros métodos
        verifyNoMoreInteractions(mockRepository);
      },
    );

    // Test 2: Registro exitoso cuando el gender es null
    test(
      'should register user with null gender when gender is not provided',
      () async {
        // Arrange
        when(mockRepository.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: null,
        )).thenAnswer((_) async => tUser);

        // Act
        final result = await useCase(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: null,
        );

        // Assert
        expect(result, equals(tUser));
        verify(mockRepository.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: null,
        )).called(1);
      },
    );

    // Test 3: Propagación de errores cuando el repository lanza una excepción
    test(
      'should propagate error when repository throws exception',
      () async {
        // Arrange
        const errorMessage = 'Error al registrar usuario';
        when(mockRepository.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        )).thenThrow(Exception(errorMessage));

        // Act & Assert
        expect(
          () => useCase(
            email: tEmail,
            password: tPassword,
            firstName: tFirstName,
            lastName: tLastName,
            birthDate: tBirthDate,
            gender: tGender,
          ),
          throwsA(isA<Exception>()),
        );

        verify(mockRepository.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        )).called(1);
      },
    );

    // Test 4: Llamada correcta al repository con parámetros correctos
    test(
      'should call repository exactly once',
      () async {
        // Arrange
        when(mockRepository.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          firstName: anyNamed('firstName'),
          lastName: anyNamed('lastName'),
          birthDate: anyNamed('birthDate'),
          gender: anyNamed('gender'),
        )).thenAnswer((_) async => tUser);

        // Act
        await useCase(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        );

        // Assert
        verify(mockRepository.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          birthDate: tBirthDate,
          gender: tGender,
        )).called(1);
      },
    );
  });
}

