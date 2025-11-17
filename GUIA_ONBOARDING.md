# 📱 GUÍA COMPLETA: Onboarding de CashUp

Esta guía explica toda la implementación del onboarding con Arquitectura Limpia, BLoC, GetIt y GoRouter.

---

## 📋 Tabla de Contenidos

1. [Estructura del Proyecto](#estructura-del-proyecto)
2. [Conceptos Clave](#conceptos-clave)
3. [Cómo Funciona](#cómo-funciona)
4. [Cómo Ejecutar](#cómo-ejecutar)
5. [Próximos Pasos](#próximos-pasos)
6. [Solución de Problemas](#solución-de-problemas)

---

## 📁 Estructura del Proyecto

```
lib/
├── core/                          # Funcionalidades core de la app
│   ├── constants/                 # Valores constantes
│   │   ├── app_colors.dart        # Colores de la app
│   │   ├── app_images.dart        # Rutas de imágenes
│   │   └── app_strings.dart       # Textos de la app
│   ├── di/                        # Dependency Injection
│   │   └── injector.dart          # Configuración de GetIt
│   └── routes/                    # Navegación
│       └── app_router.dart        # Configuración de GoRouter
│
├── data/                          # Capa de Datos
│   ├── datasources/               # Fuentes de datos
│   │   └── local_storage.dart     # SharedPreferences wrapper
│   └── repositories/              # Implementación de repositorios
│       └── onboarding_repository_impl.dart
│
├── domain/                        # Capa de Dominio (Lógica de Negocio)
│   ├── repositories/              # Contratos de repositorios
│   │   └── onboarding_repository.dart
│   └── usecases/                  # Casos de uso
│       ├── check_onboarding_status.dart
│       └── mark_onboarding_as_seen.dart
│
├── presentation/                  # Capa de Presentación (UI)
│   ├── blocs/                     # BLoCs
│   │   └── onboarding/
│   │       ├── onboarding_bloc.dart
│   │       ├── onboarding_event.dart
│   │       └── onboarding_state.dart
│   ├── screens/                   # Pantallas
│   │   ├── onboarding_screen.dart
│   │   └── login_screen.dart
│   └── widgets/                   # Widgets reutilizables
│       └── onboarding_page.dart
│
├── assets/                        # Recursos
│   └── images/
│       └── onboarding/            # Imágenes del onboarding
│
└── main.dart                      # Punto de entrada
```

---

## 🎓 Conceptos Clave

### 1️⃣ **Arquitectura Limpia (Clean Architecture)**

La app está dividida en 3 capas:

#### **Presentation Layer (Presentación)**
- **Qué hace:** Muestra la UI y maneja interacciones del usuario
- **Componentes:** Screens, Widgets, BLoCs
- **Depende de:** Domain Layer
- **Ejemplo:** `OnboardingScreen` muestra las páginas y botones

#### **Domain Layer (Dominio)**
- **Qué hace:** Contiene la lógica de negocio pura
- **Componentes:** Use Cases, Repository Interfaces
- **Depende de:** Nada (es independiente)
- **Ejemplo:** `CheckOnboardingStatus` verifica si ya se vio el onboarding

#### **Data Layer (Datos)**
- **Qué hace:** Maneja el almacenamiento y recuperación de datos
- **Componentes:** Repository Implementations, Data Sources
- **Depende de:** Domain Layer
- **Ejemplo:** `LocalStorage` guarda datos en SharedPreferences

**Ventajas:**
✅ Cada capa tiene una responsabilidad única (SOLID)
✅ Fácil de testear (puedes mockear cada capa)
✅ Flexible (puedes cambiar implementaciones sin afectar otras capas)

---

### 2️⃣ **BLoC Pattern (Business Logic Component)**

BLoC separa la lógica de negocio de la UI usando Streams.

**Componentes:**

1. **Events (Eventos):** Acciones que el usuario realiza
   ```dart
   OnboardingNextPressed()  // Usuario presiona "Siguiente"
   OnboardingSkipped()      // Usuario presiona "Saltar"
   ```

2. **States (Estados):** Cómo debe verse la UI
   ```dart
   OnboardingInProgress(currentPage: 0)  // Mostrando página 0
   OnboardingFinished()                   // Onboarding completado
   ```

3. **BLoC:** Recibe eventos, ejecuta lógica, emite estados
   ```dart
   Event → BLoC → Use Case → Repository → Estado → UI
   ```

**Flujo completo:**
```
Usuario presiona "Siguiente"
    ↓
UI envía: OnboardingNextPressed()
    ↓
BLoC recibe el evento
    ↓
BLoC incrementa currentPage
    ↓
BLoC emite: OnboardingInProgress(currentPage: 1)
    ↓
UI se reconstruye mostrando la página 1
```

---

### 3️⃣ **GetIt (Dependency Injection)**

GetIt es un Service Locator que maneja las dependencias.

**¿Por qué inyección de dependencias?**
En lugar de crear objetos dentro de las clases:
```dart
// ❌ MAL - Acoplamiento fuerte
class MyScreen {
  final repo = OnboardingRepositoryImpl(LocalStorage());
}
```

Los "inyectamos" desde fuera:
```dart
// ✅ BIEN - Inyección de dependencias
class MyScreen {
  final OnboardingRepository repo;
  MyScreen(this.repo);
}
```

**Tipos de registro:**
- **Singleton:** Una sola instancia para toda la app
  ```dart
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage(sl()));
  ```

- **Factory:** Nueva instancia cada vez
  ```dart
  sl.registerFactory<OnboardingBloc>(() => OnboardingBloc(sl()));
  ```

**Uso:**
```dart
// Obtener una dependencia
final bloc = sl<OnboardingBloc>();

// En un BlocProvider
BlocProvider(
  create: (context) => sl<OnboardingBloc>(),
  child: OnboardingScreen(),
)
```

---

### 4️⃣ **GoRouter (Navegación)**

GoRouter maneja la navegación de forma declarativa.

**Rutas definidas:**
- `/` → Redirige a `/onboarding` o `/login`
- `/onboarding` → Pantalla de onboarding
- `/login` → Pantalla de login

**Métodos de navegación:**
```dart
// Reemplazar pantalla (no se puede regresar)
context.go('/login');

// Apilar pantalla (se puede regresar)
context.push('/profile');

// Regresar
context.pop();
```

**Redirección automática:**
El router verifica si el usuario ya vio el onboarding:
- Si NO lo vio → va a `/onboarding`
- Si YA lo vio → va a `/login`

---

## ⚙️ Cómo Funciona

### **Flujo de Inicio de la App:**

```
1. main() se ejecuta
   ↓
2. initializeDependencies() registra todo en GetIt
   ↓
3. MyApp se crea con AppRouter
   ↓
4. AppRouter ejecuta redirect()
   ↓
5. CheckOnboardingStatus verifica SharedPreferences
   ↓
6. Si NO vio onboarding → va a /onboarding
   Si YA lo vio → va a /login
```

### **Flujo del Onboarding:**

```
1. Usuario ve OnboardingScreen
   ↓
2. Desliza o presiona "Siguiente"
   ↓
3. UI envía evento al OnboardingBloc
   ↓
4. BLoC actualiza currentPage
   ↓
5. BLoC emite nuevo estado
   ↓
6. UI se reconstruye mostrando la nueva página
   ↓
7. En la última página, presiona "Comenzar"
   ↓
8. BLoC llama a MarkOnboardingAsSeen use case
   ↓
9. Use case llama al repositorio
   ↓
10. Repositorio guarda en LocalStorage
    ↓
11. BLoC emite OnboardingFinished
    ↓
12. UI detecta el estado y navega a /login
```

---

## 🚀 Cómo Ejecutar

### **1. Agregar las imágenes**

Coloca las imágenes del onboarding en:
```
lib/assets/images/onboarding/
  - onboarding_1.png
  - onboarding_2.png
  - onboarding_3.png
```

Si no tienes imágenes, la app mostrará placeholders.

### **2. Instalar dependencias**

```bash
flutter pub get
```

### **3. Ejecutar la app**

```bash
flutter run
```

### **4. Probar el onboarding**

La primera vez que abras la app:
1. Verás la pantalla de onboarding
2. Desliza o presiona "Siguiente"
3. Al final, presiona "Comenzar"
4. Llegarás al login

Cierra y abre la app de nuevo:
- Ya NO verás el onboarding
- Irás directo al login

### **5. Resetear el onboarding (para testing)**

Si quieres ver el onboarding de nuevo, desinstala la app:
```bash
flutter clean
flutter run
```

O modifica temporalmente el código en `main.dart` para resetear:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  
  // SOLO PARA TESTING - Resetea el onboarding
  final localStorage = sl<LocalStorage>();
  await localStorage.resetOnboarding();
  
  runApp(const MyApp());
}
```

---

## 🔜 Próximos Pasos

### **1. Integrar Supabase (Backend)**

```dart
// En injector.dart
final supabase = await Supabase.initialize(
  url: 'TU_SUPABASE_URL',
  anonKey: 'TU_SUPABASE_ANON_KEY',
);
sl.registerLazySingleton<SupabaseClient>(() => supabase.client);
```

### **2. Crear AuthBloc para Login**

```
lib/presentation/blocs/auth/
  - auth_bloc.dart
  - auth_event.dart
  - auth_state.dart
```

### **3. Crear Use Cases de autenticación**

```dart
// lib/domain/usecases/auth/
- login_with_email.dart
- register_with_email.dart
- logout.dart
- get_current_user.dart
```

### **4. Agregar pantalla de Home**

```dart
GoRoute(
  path: '/home',
  builder: (context, state) => const HomeScreen(),
),
```

### **5. Proteger rutas autenticadas**

```dart
redirect: (context, state) {
  final isAuthenticated = await checkAuthStatus();
  if (!isAuthenticated && state.matchedLocation == '/home') {
    return '/login';
  }
  return null;
}
```

---

## 🔧 Solución de Problemas

### **Problema: La app no compila**

**Solución:**
```bash
flutter clean
flutter pub get
flutter run
```

---

### **Problema: Las imágenes no aparecen**

**Causas posibles:**
1. Las imágenes no están en la carpeta correcta
2. Los nombres no coinciden exactamente

**Solución:**
1. Verifica que estén en `lib/assets/images/onboarding/`
2. Nombres exactos: `onboarding_1.png`, `onboarding_2.png`, `onboarding_3.png`
3. Reinicia con hot restart (R en mayúscula en la consola)

---

### **Problema: El onboarding se muestra siempre**

**Causa:** El estado no se está guardando

**Solución:**
1. Verifica que `SharedPreferences` se esté inicializando
2. Revisa los logs en la consola
3. Asegúrate de que `OnboardingCompleted` se esté llamando

---

### **Problema: Errores de GetIt (no encuentra dependencias)**

**Causa:** Las dependencias no se registraron correctamente

**Solución:**
1. Verifica que `initializeDependencies()` se llame en `main()`
2. Revisa el orden de registro en `injector.dart`
3. Asegúrate de que todas las dependencias estén registradas

---

### **Problema: BLoC no reacciona a eventos**

**Solución:**
```dart
// Verifica que estés enviando el evento correctamente
context.read<OnboardingBloc>().add(OnboardingNextPressed());

// Y que tengas BlocConsumer o BlocBuilder
BlocConsumer<OnboardingBloc, OnboardingState>(
  listener: (context, state) { },
  builder: (context, state) { },
)
```

---

## 📚 Recursos Adicionales

### **Documentación oficial:**
- [Flutter Bloc](https://bloclibrary.dev/)
- [GetIt](https://pub.dev/packages/get_it)
- [GoRouter](https://pub.dev/packages/go_router)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### **Tutoriales recomendados:**
- [Reso Coder - Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Flutter Bloc Tutorial](https://bloclibrary.dev/tutorials/flutter-counter/)

---

## 🎯 Principios SOLID Aplicados

1. **Single Responsibility (Responsabilidad Única)**
   - Cada clase tiene una sola razón para cambiar
   - `LocalStorage` solo maneja storage
   - `OnboardingBloc` solo maneja lógica de onboarding

2. **Open/Closed (Abierto/Cerrado)**
   - Abierto para extensión, cerrado para modificación
   - Podemos agregar nuevos use cases sin modificar existentes

3. **Liskov Substitution (Sustitución de Liskov)**
   - Podemos reemplazar implementaciones sin afectar el código
   - `OnboardingRepositoryImpl` puede ser reemplazado por otra implementación

4. **Interface Segregation (Segregación de Interfaces)**
   - Interfaces pequeñas y específicas
   - `OnboardingRepository` solo tiene métodos relacionados con onboarding

5. **Dependency Inversion (Inversión de Dependencias)**
   - Dependemos de abstracciones, no de implementaciones
   - `OnboardingBloc` depende de `OnboardingRepository` (interfaz), no de su implementación

---

## ✅ Checklist de Implementación

- [x] Arquitectura Limpia implementada
- [x] BLoC para manejo de estado
- [x] GetIt para inyección de dependencias
- [x] GoRouter para navegación
- [x] SharedPreferences para persistencia
- [x] Pantallas de onboarding (3 páginas)
- [x] Pantalla de login (sin funcionalidad)
- [x] Navegación automática basada en estado
- [x] Código bien documentado
- [ ] Integración con Supabase (próximo paso)
- [ ] Autenticación funcional (próximo paso)
- [ ] Tests unitarios (recomendado)

---

## 🤝 Contribuir

Si encuentras errores o mejoras, no dudes en modificar el código siguiendo los mismos patrones establecidos.

---

¡Felicitaciones! 🎉 Has implementado un onboarding profesional con las mejores prácticas de Flutter.

