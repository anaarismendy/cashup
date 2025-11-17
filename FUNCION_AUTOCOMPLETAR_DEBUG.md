# 🚀 Función de Auto-completado en Modo Debug

## ✅ **FUNCIONALIDAD IMPLEMENTADA**

Se ha agregado una función que **auto-completa automáticamente** todos los campos del formulario de registro cuando la app está en **modo debug**.

---

## 🎯 **CARACTERÍSTICAS**

### **1. Auto-completado automático:**
- ✅ Se ejecuta **automáticamente** al abrir la pantalla de registro
- ✅ Solo funciona en **modo debug** (`kDebugMode`)
- ✅ **NO aparece en producción** (modo release)

### **2. Botón flotante manual:**
- ✅ Botón pequeño en la esquina inferior derecha
- ✅ Solo visible en modo debug
- ✅ Permite **re-auto-completar** los campos cuando quieras
- ✅ Ícono: `auto_fix_high` (varita mágica)

### **3. Datos generados:**
- ✅ **Email único:** `ana_test_[número]@email.com` (evita duplicados)
- ✅ **Nombre:** Ana Sofia
- ✅ **Apellido:** Arismendy
- ✅ **Contraseña:** password123
- ✅ **Confirmar contraseña:** password123
- ✅ **Fecha de nacimiento:** 18 años atrás (cumple validación de edad)
- ✅ **Género:** Femenino

---

## 📱 **CÓMO USAR**

### **Opción 1: Auto-completado automático**
```
1. Abre la app en modo debug
2. Ve a "Regístrate"
3. ✅ Los campos se llenan automáticamente
4. Solo presiona "Crear Cuenta"
```

### **Opción 2: Botón flotante**
```
1. Abre la pantalla de registro
2. Si limpiaste los campos, presiona el botón flotante (esquina inferior derecha)
3. ✅ Los campos se vuelven a llenar
```

---

## 🔧 **CÓDIGO IMPLEMENTADO**

### **Función de auto-completado:**
```dart
void _autoFillDebugData() {
  if (!kDebugMode) return;

  // Generar email único con timestamp
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomSuffix = timestamp % 10000;

  // Llenar campos
  _firstNameController.text = 'Ana Sofia';
  _lastNameController.text = 'Arismendy';
  _emailController.text = 'ana_test_$randomSuffix@email.com';
  _passwordController.text = 'password123';
  _confirmPasswordController.text = 'password123';

  // Fecha de nacimiento (18 años)
  _selectedBirthDate = DateTime.now().subtract(
    const Duration(days: 18 * 365),
  );

  // Género
  _selectedGender = Gender.femenino;

  setState(() {});
}
```

### **Auto-ejecución en initState:**
```dart
@override
void initState() {
  super.initState();
  if (kDebugMode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFillDebugData();
    });
  }
}
```

### **Botón flotante:**
```dart
floatingActionButton: kDebugMode
    ? FloatingActionButton(
        mini: true,
        backgroundColor: AppColors.primary.withOpacity(0.8),
        onPressed: _autoFillDebugData,
        tooltip: 'Auto-completar campos (Debug)',
        child: const Icon(Icons.auto_fix_high),
      )
    : null,
```

---

## 🎨 **APARIENCIA**

### **Botón flotante:**
- 📍 **Posición:** Esquina inferior derecha
- 🎨 **Color:** Verde turquesa semi-transparente
- 📏 **Tamaño:** Mini (pequeño)
- 🎯 **Ícono:** Varita mágica (`auto_fix_high`)
- 💬 **Tooltip:** "Auto-completar campos (Debug)"

---

## 🔒 **SEGURIDAD**

### **Solo en modo debug:**
```dart
if (kDebugMode) {
  // Solo se ejecuta en desarrollo
}
```

**Garantías:**
- ✅ **NO aparece en producción** (modo release)
- ✅ **NO afecta usuarios finales**
- ✅ **Solo para desarrollo/testing**

---

## 📊 **DATOS GENERADOS**

| Campo | Valor | Notas |
|-------|-------|-------|
| **Nombre** | Ana Sofia | Fijo |
| **Apellido** | Arismendy | Fijo |
| **Email** | `ana_test_[número]@email.com` | Único por timestamp |
| **Contraseña** | password123 | Fijo |
| **Confirmar** | password123 | Coincide |
| **Fecha nac.** | Hace 18 años | Cumple validación ≥15 |
| **Género** | Femenino | Pre-seleccionado |

---

## 🧪 **CASOS DE USO**

### **1. Testing rápido:**
```
✅ Abre registro → Campos llenos → Presiona "Crear Cuenta"
✅ Prueba el flujo completo en segundos
```

### **2. Desarrollo iterativo:**
```
✅ No necesitas escribir datos cada vez
✅ Enfócate en probar funcionalidad, no en llenar formularios
```

### **3. Demostraciones:**
```
✅ Muestra el registro funcionando rápidamente
✅ Sin tener que escribir datos manualmente
```

---

## ⚙️ **PERSONALIZACIÓN**

Si quieres cambiar los datos generados, edita la función `_autoFillDebugData()`:

```dart
// Cambiar nombre
_firstNameController.text = 'Tu Nombre';

// Cambiar email base
_emailController.text = 'tu_email_$randomSuffix@email.com';

// Cambiar contraseña
_passwordController.text = 'tu_contraseña';

// Cambiar edad (asegúrate que sea >= 15)
_selectedBirthDate = DateTime.now().subtract(
  const Duration(days: 20 * 365), // 20 años
);

// Cambiar género
_selectedGender = Gender.masculino;
```

---

## 🎯 **BENEFICIOS**

### **Para desarrollo:**
- ⚡ **Más rápido:** No escribes datos cada vez
- 🎯 **Enfoque:** Te concentras en la funcionalidad
- 🔄 **Iterativo:** Pruebas rápidas y repetidas

### **Para testing:**
- ✅ **Consistente:** Siempre los mismos datos base
- ✅ **Único:** Email único evita conflictos
- ✅ **Válido:** Todos los datos pasan validaciones

---

## 📝 **NOTAS IMPORTANTES**

### **Email único:**
El email se genera con un timestamp para evitar duplicados:
```dart
ana_test_1234@email.com  // Primera vez
ana_test_5678@email.com  // Segunda vez (diferente)
```

### **Validaciones cumplidas:**
- ✅ Edad ≥ 15 años (18 años)
- ✅ Contraseña ≥ 6 caracteres (password123)
- ✅ Contraseñas coinciden
- ✅ Email válido
- ✅ Todos los campos requeridos llenos

### **Modo release:**
En producción (modo release):
- ❌ NO se auto-completa
- ❌ NO aparece el botón flotante
- ✅ Los usuarios deben llenar manualmente

---

## 🚀 **RESULTADO**

Ahora cuando abras la pantalla de registro en modo debug:

1. ✅ **Campos se llenan automáticamente**
2. ✅ **Botón flotante disponible** para re-llenar
3. ✅ **Solo presiona "Crear Cuenta"**
4. ✅ **Testing rápido y eficiente**

---

## 🎉 **¡LISTO PARA USAR!**

La funcionalidad está implementada y funcionando. Solo abre la pantalla de registro en modo debug y verás los campos auto-completados.

**¿Quieres cambiar algún dato generado o agregar más campos?** 🚀

