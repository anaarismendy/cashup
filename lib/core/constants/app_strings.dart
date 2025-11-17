class AppStrings {
  AppStrings._();

  // Textos del onboarding
  static const String onboarding1Title = 'Controla tus finanzas';
  static const String onboarding1Subtitle = 
      'Gestiona tu dinero de forma inteligente y alcanza tus metas financieras';

  static const String onboarding2Title = 'Registra ingresos\ny gastos';
  static const String onboarding2Subtitle = 
      'Mantén un registro detallado de todas tus transacciones';

  static const String onboarding3Title = 'Visualiza tus hábitos';
  static const String onboarding3Subtitle = 
      'Analiza tus patrones de gasto y toma mejores decisiones';

  // Botones
  static const String next = 'Siguiente';
  static const String skip = 'Saltar';
  static const String start = 'Comenzar';

  // Login
  static const String welcome = 'Bienvenido';
  static const String loginSubtitle = 'Inicia sesión para continuar';
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';
  static const String login = 'Iniciar Sesión';
  static const String logout = 'Cerrar Sesión';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String or = 'O';
  static const String noAccount = '¿No tienes cuenta?';
  static const String register = 'Regístrate';

  // Register
  static const String createAccount = 'Crear cuenta';
  static const String registerSubtitle = 'Completa tus datos para comenzar';
  static const String firstName = 'Nombre';
  static const String lastName = 'Apellido';
  static const String birthDate = 'Fecha de nacimiento';
  static const String gender = 'Género';
  static const String genderOptional = 'Género (opcional)';
  static const String selectGender = 'Selecciona tu género';
  static const String confirmPassword = 'Confirmar contraseña';
  static const String createAccountButton = 'Crear Cuenta';
  static const String alreadyHaveAccount = '¿Ya tienes cuenta?';
  static const String loginHere = 'Inicia sesión aquí';

  // Validaciones
  static const String fieldRequired = 'Este campo es requerido';
  static const String emailInvalid = 'Email inválido';
  static const String passwordTooShort = 'La contraseña debe tener al menos 6 caracteres';
  static const String passwordsDontMatch = 'Las contraseñas no coinciden';
  static const String mustBe15 = 'Debes tener al menos 15 años';

  // Mensajes
  static const String registering = 'Creando cuenta...';
  static const String loggingIn = 'Iniciando sesión...';
  static const String passwordResetSent = 'Email de recuperación enviado';
  
  // Recuperación de contraseña
  static const String resetPassword = 'Recuperar contraseña';
  static const String resetPasswordSubtitle = 'Ingresa tu email para recuperar tu contraseña';
  static const String sendResetEmail = 'Enviar email';
  static const String backToLogin = 'Volver al inicio de sesión';
  static const String resetPasswordSuccess = '¡Email enviado! Revisa tu bandeja de entrada';
  static const String resetPasswordError = 'Error al enviar email de recuperación';
  
  // Éxitos
  static const String loginSuccess = '¡Bienvenido de vuelta!';
  static const String registerSuccess = '¡Cuenta creada exitosamente!';
  
  // Home
  static const String hello = 'Hola,';
  static const String guest = 'Invitado';
  static const String balanceTotal = 'Balance Total';
  static const String income = 'Ingresos';
  static const String expenses = 'Gastos';
  static const String addIncome = 'Ingreso';
  static const String addExpense = 'Gasto';
  static const String recentMovements = 'Transacciones';
  static const String allTransactions = 'Todas las Transacciones';
  
  // Fechas
  static const String today = 'Hoy';
  static const String yesterday = 'Ayer';
  
  // Mensajes de error
  static const String pleaseCompleteAllFields = 'Por favor completa todos los campos';
  static const String selectBirthDate = 'Selecciona tu fecha de nacimiento';
  
  // Agregar Transacción
  static const String newTransaction = 'Nuevo Gasto';
  static const String newIncome = 'Nuevo Ingreso';
  static const String newExpense = 'Nuevo Gasto';
  static const String title = 'Título';
  static const String titlePlaceholder = 'Ej: Almuerzo';
  static const String amount = 'Monto';
  static const String description = 'Descripción (opcional)';
  static const String descriptionPlaceholder = 'Añade una nota...';
  static const String category = 'Categoría';
  static const String date = 'Fecha';
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String newCategory = 'Nueva';
  static const String selectCategory = 'Selecciona una categoría';
  
  // Crear Categoría
  static const String newCategoryTitle = 'Nueva Categoría';
  static const String categoryName = 'Nombre';
  static const String categoryNamePlaceholder = 'Ej: Restaurantes';
  static const String type = 'Tipo';
  static const String icon = 'Ícono';
  static const String color = 'Color';
  static const String preview = 'Vista previa';
  static const String categoryPreviewName = 'Nombre de categoría';
  static const String categoryPreviewTransactions = 'transacciones';
  
  // Mensajes de éxito/error
  static const String transactionSaved = 'Transacción guardada exitosamente';
  static const String transactionUpdated = 'Transacción actualizada exitosamente';
  static const String transactionDeleted = 'Transacción eliminada exitosamente';
  static const String categorySaved = 'Categoría creada exitosamente';
  static const String errorSavingTransaction = 'Error al guardar transacción';
  static const String errorUpdatingTransaction = 'Error al actualizar transacción';
  static const String errorDeletingTransaction = 'Error al eliminar transacción';
  static const String errorCreatingCategory = 'Error al crear categoría';
  static const String amountMustBeGreaterThanZero = 'El monto debe ser mayor a cero';

  // Detalle de Transacción
  static const String detail = 'Detalle';
  static const String edit = 'Editar';
  static const String delete = 'Eliminar';
  static const String editTransaction = 'Editar Transacción';
  static const String confirmDelete = '¿Estás seguro de eliminar esta transacción?';
  static const String yes = 'Sí';
  static const String no = 'No';

  // Estadísticas
  static const String statistics = 'Estadísticas';
  static const String expenseDistribution = 'Distribución de Gastos';
  static const String expensesByCategory = 'Gastos por Categoría';
  static const String day = 'Día';
  static const String week = 'Semana';
  static const String month = 'Mes';
  static const String year = 'Año';
  static const String total = 'Total';
  static const String balance = 'Balance';
  static const String selectDate = 'Seleccionar Fecha';
  static const String showDailyExpensesOnly = 'Mostrar solo gastos diarios';
  static const String selectDay = 'Seleccionar Día';
  static const String selectWeek = 'Seleccionar Semana';
  static const String selectMonth = 'Seleccionar Mes';
  static const String selectYear = 'Seleccionar Año';
}

