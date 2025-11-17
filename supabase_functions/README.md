WR# Funciones RPC de Supabase para CashUp

Este directorio contiene las funciones RPC (Remote Procedure Call) de PostgreSQL que deben ejecutarse en Supabase para manejar la lógica de negocio en la base de datos.

## ⚠️ IMPORTANTE: Ejecutar las funciones SQL

**Debes ejecutar estos scripts en Supabase antes de usar la funcionalidad de editar/eliminar transacciones.**

## Instalación

### Opción 1: Desde el SQL Editor de Supabase (Recomendado)

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. Navega a **SQL Editor** (en el menú lateral)
3. Haz clic en **New Query**
4. Copia y pega el contenido completo de `update_transaction.sql`
5. Haz clic en **Run** (o presiona `Ctrl+Enter`)
6. Repite los pasos 4-5 para `delete_transaction.sql`

### Opción 2: Desde la línea de comandos (si tienes Supabase CLI)

```bash
# Ejecutar todas las funciones
supabase db execute -f supabase_functions/update_transaction.sql
supabase db execute -f supabase_functions/delete_transaction.sql
```

## Funciones Disponibles

### 1. `update_transaction`

Actualiza una transacción existente con validaciones completas.

**Parámetros:**
- `p_transaction_id` (UUID, requerido): ID de la transacción a actualizar
- `p_title` (TEXT, opcional): Nuevo título
- `p_amount` (NUMERIC, opcional): Nuevo monto (debe ser > 0)
- `p_type` (TEXT, opcional): Nuevo tipo ('income' o 'expense')
- `p_category_id` (UUID, opcional): Nuevo ID de categoría
- `p_description` (TEXT, opcional): Nueva descripción
- `p_transaction_date` (DATE, opcional): Nueva fecha

**Validaciones:**
- ✅ Verifica que el usuario esté autenticado
- ✅ Verifica que la transacción pertenezca al usuario
- ✅ Valida que el monto sea positivo
- ✅ Valida que el tipo sea 'income' o 'expense'
- ✅ Valida que la categoría exista y pertenezca al usuario (o sea del sistema)
- ✅ Valida que la categoría coincida con el tipo de transacción

**Retorna:**
La transacción actualizada con todos sus campos.

### 2. `delete_transaction`

Elimina una transacción con validaciones de seguridad.

**Parámetros:**
- `p_transaction_id` (UUID, requerido): ID de la transacción a eliminar

**Validaciones:**
- ✅ Verifica que el usuario esté autenticado
- ✅ Verifica que la transacción pertenezca al usuario

**Retorna:**
Un mensaje de confirmación de eliminación.

## Ventajas de usar funciones RPC

1. **Seguridad**: La lógica se ejecuta en el servidor con permisos controlados
2. **Validación centralizada**: Todas las validaciones están en un solo lugar
3. **Consistencia**: Garantiza que las reglas de negocio se apliquen siempre
4. **Rendimiento**: Las operaciones se ejecutan directamente en la base de datos
5. **Mantenibilidad**: Cambios en la lógica solo requieren actualizar la función SQL

## Notas Importantes

- Las funciones usan `SECURITY DEFINER`, lo que significa que se ejecutan con los permisos del creador de la función
- Todas las funciones verifican que el usuario esté autenticado usando `auth.uid()`
- Las funciones solo permiten operaciones sobre recursos que pertenecen al usuario autenticado
- Los permisos de ejecución se otorgan a usuarios autenticados mediante `GRANT EXECUTE`

## Solución de Problemas

### Error: "column reference 'id' is ambiguous"

Si ves este error, significa que la función SQL no está actualizada. Asegúrate de ejecutar la versión más reciente de `update_transaction.sql` que incluye alias explícitos para todas las tablas.

### Error: "function does not exist"

Asegúrate de haber ejecutado los scripts SQL en el orden correcto y que no haya errores de sintaxis.

