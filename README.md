# 💰 CashUp - Gestión de Finanzas Personales

CashUp es una aplicación móvil desarrollada en Flutter para la gestión de finanzas personales. Permite a los usuarios registrar ingresos y gastos, categorizar transacciones, visualizar estadísticas financieras y mantener un control completo de sus finanzas.

## ✨ Características

- 🔐 **Autenticación de Usuarios**: Registro, inicio de sesión y recuperación de contraseña
- 💵 **Gestión de Transacciones**: Crear, editar y eliminar ingresos y gastos
- 📊 **Estadísticas Financieras**: Visualización de gastos por categoría, resúmenes diarios, semanales y mensuales
- 🏷️ **Categorías Personalizadas**: Crear y gestionar categorías personalizadas con iconos y colores
- 📈 **Gráficas Interactivas**: Visualización de distribución de gastos mediante gráficas de donut
- 🔄 **Sincronización en Tiempo Real**: Datos sincronizados con Supabase
- 📱 **Diseño Moderno**: Interfaz intuitiva y moderna siguiendo Material Design 3

## 🏗️ Arquitectura

La aplicación sigue los principios de **Clean Architecture** y **SOLID**, organizando el código en capas bien definidas:

```
lib/
├── domain/          # Capa de Dominio (Lógica de Negocio)
│   ├── entities/   # Entidades puras del negocio
│   ├── repositories/ # Interfaces de repositorios
│   └── usecases/    # Casos de uso (lógica de negocio)
│
├── data/            # Capa de Datos
│   ├── datasources/ # Fuentes de datos (Supabase, LocalStorage)
│   ├── models/      # Modelos de datos (DTOs)
│   └── repositories/ # Implementaciones de repositorios
│
└── presentation/    # Capa de Presentación
    ├── blocs/       # Gestión de estado (BLoC Pattern)
    ├── screens/     # Pantallas de la aplicación
    └── widgets/     # Widgets reutilizables
```

### Principios de Diseño

- **Separación de Responsabilidades**: Cada capa tiene una responsabilidad única
- **Inversión de Dependencias**: Las capas superiores dependen de abstracciones, no de implementaciones
- **Testabilidad**: Arquitectura diseñada para facilitar pruebas unitarias
- **Escalabilidad**: Fácil agregar nuevas funcionalidades sin afectar código existente

## 🛠️ Tecnologías Utilizadas

### Frontend

- **Flutter** (`^3.8.1`): Framework multiplataforma para desarrollo móvil
- **Dart**: Lenguaje de programación

### Gestión de Estado

- **flutter_bloc** (`^8.1.4`): Patrón BLoC para gestión de estado reactivo
- **bloc** (`^8.1.4`): Biblioteca base para BLoC

### Navegación

- **go_router** (`^14.1.0`): Sistema de navegación declarativo con deep linking

### Inyección de Dependencias

- **get_it** (`^7.7.0`): Service Locator para inyección de dependencias

### Backend y Base de Datos

- **supabase_flutter** (`^2.5.0`): Cliente Flutter para Supabase
  - Autenticación de usuarios
  - Base de datos PostgreSQL
  - Funciones RPC (Remote Procedure Calls)
  - Row Level Security (RLS)

### Almacenamiento Local

- **shared_preferences** (`^2.3.5`): Almacenamiento local para preferencias del usuario

### Utilidades

- **intl** (`^0.20.2`): Internacionalización y formato de fechas/monedas
- **equatable** (`^2.0.7`): Comparación de objetos simplificada
- **fl_chart** (`^0.68.0`): Librería para gráficas y visualizaciones

## 📁 Estructura del Proyecto

### Capa de Dominio (`lib/domain/`)

**Entidades** (`entities/`):
- `user_entity.dart`: Usuario autenticado
- `transaction_entity.dart`: Transacción financiera
- `category_entity.dart`: Categoría de transacción
- `transaction_type.dart`: Tipo de transacción (income/expense)
- `category_statistics_entity.dart`: Estadísticas por categoría
- `daily_summary_entity.dart`: Resumen diario
- `weekly_summary_entity.dart`: Resumen semanal
- `monthly_summary_entity.dart`: Resumen mensual

**Repositorios** (`repositories/`):
- Interfaces que definen contratos para acceso a datos
- Implementaciones en la capa de datos

**Casos de Uso** (`usecases/`):
- `auth/`: Autenticación (login, registro, logout, reset password)
- `transactions/`: Gestión de transacciones (CRUD completo)
- `categories/`: Gestión de categorías
- `statistics/`: Obtención de estadísticas financieras
- `onboarding/`: Gestión del estado de onboarding

### Capa de Datos (`lib/data/`)

**Data Sources** (`datasources/`):
- `supabase_auth_datasource.dart`: Autenticación con Supabase
- `supabase_transaction_datasource.dart`: Operaciones CRUD de transacciones
- `supabase_category_datasource.dart`: Gestión de categorías
- `supabase_statistics_datasource.dart`: Estadísticas mediante RPC
- `local_storage.dart`: Almacenamiento local (SharedPreferences)

**Modelos** (`models/`):
- Modelos que extienden entidades y manejan serialización JSON
- Conversión entre formato Supabase y entidades de dominio

**Repositorios** (`repositories/`):
- Implementaciones concretas de los repositorios del dominio

### Capa de Presentación (`lib/presentation/`)

**BLoCs** (`blocs/`):
- `auth/`: Estado de autenticación
- `home/`: Estado de la pantalla principal
- `add_transaction/`: Formulario de creación de transacciones
- `create_category/`: Formulario de creación de categorías
- `transaction_detail/`: Detalle y edición de transacciones
- `statistics/`: Estado de la pantalla de estadísticas
- `onboarding/`: Estado del onboarding

**Pantallas** (`screens/`):
- `onboarding_screen.dart`: Pantalla de bienvenida
- `login_screen.dart`: Inicio de sesión
- `register_screen.dart`: Registro de usuarios
- `forgot_password_screen.dart`: Recuperación de contraseña
- `home_screen.dart`: Pantalla principal con balance y transacciones
- `add_transaction_screen.dart`: Formulario para agregar transacciones
- `create_category_screen.dart`: Formulario para crear categorías
- `transaction_detail_screen.dart`: Detalle y edición de transacciones
- `statistics_screen.dart`: Estadísticas financieras

**Widgets** (`widgets/`):
- Widgets reutilizables para diferentes funcionalidades
- Componentes comunes (SnackBar personalizado, navegación inferior)

## 🔄 Flujo de la Aplicación

### Flujo de Inicio

1. **Inicialización** (`main.dart`):
   - Se inicializa Flutter bindings
   - Se configura Supabase con URL y anonKey
   - Se inicializan dependencias con GetIt
   - Se inicializa formato de fechas para español
   - Se crea AuthBloc para verificar sesión activa

2. **Navegación Inicial** (`app_router.dart`):
   - El router verifica si hay sesión activa
   - Si hay sesión → Redirige a `/home`
   - Si no hay sesión → Verifica estado de onboarding
     - Si no ha visto onboarding → Redirige a `/onboarding`
     - Si ya vio onboarding → Redirige a `/login`

### Flujo de Autenticación

1. **Registro**:
   - Usuario completa formulario (email, contraseña, nombre, apellido, fecha de nacimiento, género opcional)
   - `AuthBloc` procesa el registro mediante `RegisterUser` use case
   - Se crea perfil en Supabase
   - Redirección automática a `/home`

2. **Inicio de Sesión**:
   - Usuario ingresa email y contraseña
   - `AuthBloc` valida credenciales con Supabase
   - Se guarda sesión automáticamente
   - Redirección a `/home`

3. **Cerrar Sesión**:
   - Usuario presiona icono de perfil → Menú → "Cerrar Sesión"
   - `AuthBloc` ejecuta logout
   - Sesión se elimina de Supabase
   - Redirección automática a `/login`

### Flujo de Transacciones

1. **Crear Transacción**:
   - Usuario presiona "+ Ingreso" o "+ Gasto" en home
   - Se abre modal con `AddTransactionScreen`
   - Usuario completa formulario (título, monto, categoría, descripción, fecha)
   - `AddTransactionBloc` valida y crea transacción
   - Se actualiza balance automáticamente
   - Modal se cierra y home se refresca

2. **Ver Detalle**:
   - Usuario presiona una transacción en la lista
   - Navegación a `/transaction/:id`
   - `TransactionDetailBloc` carga datos de la transacción
   - Se muestra información completa

3. **Editar Transacción**:
   - Usuario presiona "Editar" en detalle
   - Se habilita modo edición
   - Usuario modifica campos
   - Al guardar, se llama función RPC `update_transaction` en Supabase
   - Se refresca pantalla y se regresa a home

4. **Eliminar Transacción**:
   - Usuario presiona "Eliminar" en detalle
   - Se muestra diálogo de confirmación
   - Se llama función RPC `delete_transaction` en Supabase
   - Se elimina transacción y se regresa a home

### Flujo de Estadísticas

1. **Acceso a Estadísticas**:
   - Usuario navega a pantalla de estadísticas mediante barra inferior
   - `StatisticsBloc` carga datos iniciales (mes actual por defecto)

2. **Filtrado**:
   - Usuario selecciona período (Día, Semana, Mes, Año)
   - Usuario selecciona fecha específica mediante date picker
   - Se recalculan estadísticas según período seleccionado

3. **Visualización**:
   - Se muestra resumen (ingresos, gastos, balance)
   - Gráfica de donut con distribución de gastos
   - Lista de categorías con barras de progreso
   - Opción de mostrar solo gastos diarios

## 🗄️ Backend y Base de Datos

### Supabase

CashUp utiliza **Supabase** como Backend as a Service (BaaS), proporcionando:

- **Autenticación**: Sistema completo de autenticación con email/contraseña
- **Base de Datos PostgreSQL**: Base de datos relacional escalable
- **Row Level Security (RLS)**: Seguridad a nivel de fila para proteger datos de usuarios
- **Funciones RPC**: Lógica de negocio ejecutada en el servidor

### Esquema de Base de Datos

#### Tabla `profiles`

Almacena información del perfil de usuario:

```sql
- id (UUID, PK, FK a auth.users)
- first_name (TEXT)
- last_name (TEXT)
- birth_date (DATE)
- gender (TEXT, nullable)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### Tabla `categories`

Almacena categorías de transacciones:

```sql
- id (UUID, PK)
- user_id (UUID, FK a auth.users)
- name (TEXT)
- type (transaction_type ENUM: 'income' | 'expense')
- color (TEXT, hex color)
- icon (TEXT, emoji)
- is_system (BOOLEAN, default false)
- created_at (TIMESTAMP)
```

**Categorías del Sistema**: Categorías predefinidas disponibles para todos los usuarios (`is_system = true`)

#### Tabla `transactions`

Almacena todas las transacciones financieras:

```sql
- id (UUID, PK)
- user_id (UUID, FK a auth.users)
- title (TEXT)
- amount (NUMERIC)
- type (transaction_type ENUM: 'income' | 'expense')
- category_id (UUID, FK a categories)
- description (TEXT, nullable)
- transaction_date (DATE)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### Funciones RPC (Remote Procedure Calls)

Las funciones RPC ejecutan lógica de negocio en el servidor:

#### `get_user_balance`
Calcula el balance total del usuario (ingresos - gastos).

#### `get_category_statistics`
Obtiene estadísticas agrupadas por categoría con totales y porcentajes.

#### `get_daily_summary`
Obtiene resúmenes diarios de transacciones.

#### `get_weekly_summary`
Obtiene resumen semanal de transacciones.

#### `get_monthly_summary`
Obtiene resumen mensual de transacciones.

#### `update_transaction`
Actualiza una transacción con validaciones completas:
- Verifica propiedad del usuario
- Valida monto positivo
- Valida tipo de transacción
- Valida categoría y tipo coincidente

#### `delete_transaction`
Elimina una transacción verificando propiedad del usuario.

#### `validate_transaction_category`
Función trigger que valida que la categoría pertenezca al usuario y coincida con el tipo de transacción.

### Seguridad

- **Row Level Security (RLS)**: Todas las tablas tienen políticas RLS activadas
- **Validación en Servidor**: Las funciones RPC validan permisos y datos
- **Autenticación**: Todas las operaciones requieren usuario autenticado
- **Tokens JWT**: Supabase maneja tokens de autenticación automáticamente

## 🎨 Frontend

### Gestión de Estado (BLoC Pattern)

Cada pantalla tiene su propio BLoC que gestiona:

- **Estados**: Representan diferentes estados de la UI (loading, loaded, error)
- **Eventos**: Acciones del usuario que disparan cambios de estado
- **Lógica de Negocio**: Coordinación entre use cases y actualización de estado

**Ejemplo - HomeBloc**:
- `HomeDataRequested`: Carga inicial de datos
- `HomeDataRefreshed`: Refrescar datos (pull-to-refresh)
- `HomeAddIncomePressed`: Navegación a formulario de ingreso
- `HomeAddExpensePressed`: Navegación a formulario de gasto

### Navegación (GoRouter)

- **Rutas Declarativas**: Todas las rutas definidas en un solo lugar
- **Redirecciones Condicionales**: Lógica de navegación basada en estado de autenticación
- **Deep Linking**: Soporte para abrir la app en rutas específicas
- **Protección de Rutas**: Rutas autenticadas protegidas automáticamente

### Diseño UI

- **Material Design 3**: Sistema de diseño moderno de Google
- **Colores Personalizados**: Paleta de colores definida en `app_colors.dart`
- **Widgets Reutilizables**: Componentes comunes para mantener consistencia
- **Animaciones**: Transiciones suaves y feedback visual
- **SnackBars Personalizados**: Notificaciones estéticas con animaciones

### Internacionalización

- **Español como Idioma Principal**: Toda la UI en español
- **Formato de Fechas**: Formato español para fechas y monedas
- **Localización de Material**: DatePickers y otros widgets en español

## 🎯 Decisiones Técnicas

### ¿Por qué Clean Architecture?

- **Mantenibilidad**: Código organizado y fácil de entender
- **Testabilidad**: Cada capa puede probarse independientemente
- **Escalabilidad**: Fácil agregar nuevas funcionalidades
- **Desacoplamiento**: Cambios en una capa no afectan otras

### ¿Por qué BLoC Pattern?

- **Separación de Lógica y UI**: La UI solo se preocupa de mostrar datos
- **Testeable**: La lógica de negocio puede probarse sin UI
- **Reactivo**: Cambios de estado se propagan automáticamente
- **Predecible**: Flujo unidireccional de datos

### ¿Por qué GetIt?

- **Simplicidad**: Fácil de usar y entender
- **Rendimiento**: Sin overhead de reflexión
- **Tipado Fuerte**: Errores detectados en tiempo de compilación
- **Flexibilidad**: Soporta diferentes tipos de registro (singleton, factory)

### ¿Por qué GoRouter?

- **Oficial**: Sistema de navegación recomendado por Flutter
- **Declarativo**: Rutas definidas en un solo lugar
- **Deep Linking**: Soporte nativo para enlaces profundos
- **Type-Safe**: Navegación con tipos seguros

### ¿Por qué Supabase?

- **Backend Completo**: Autenticación, base de datos y funciones RPC
- **PostgreSQL**: Base de datos relacional robusta
- **Row Level Security**: Seguridad integrada
- **Tiempo Real**: Posibilidad de sincronización en tiempo real
- **Escalable**: Infraestructura gestionada y escalable

### ¿Por qué Funciones RPC?

- **Seguridad**: Lógica ejecutada en el servidor con permisos controlados
- **Validación Centralizada**: Reglas de negocio en un solo lugar
- **Rendimiento**: Operaciones ejecutadas directamente en la base de datos
- **Consistencia**: Garantiza que las reglas se apliquen siempre


## 📱 Módulos de la Aplicación

### 1. Módulo de Autenticación
- Registro de usuarios
- Inicio de sesión
- Recuperación de contraseña
- Cerrar sesión
- Persistencia de sesión

### 2. Módulo de Onboarding
- Pantallas de bienvenida
- Explicación de funcionalidades
- Persistencia de estado (solo mostrar una vez)

### 3. Módulo de Transacciones
- Crear transacciones (ingresos/gastos)
- Listar todas las transacciones
- Ver detalle de transacción
- Editar transacción
- Eliminar transacción
- Cálculo automático de balance

### 4. Módulo de Categorías
- Crear categorías personalizadas
- Seleccionar categorías existentes
- Filtrar por tipo (ingreso/gasto)
- Iconos y colores personalizados

### 5. Módulo de Estadísticas
- Estadísticas por período (Día, Semana, Mes, Año)
- Selección de fechas específicas
- Gráfica de distribución de gastos
- Resúmenes diarios, semanales y mensuales
- Visualización por categorías


