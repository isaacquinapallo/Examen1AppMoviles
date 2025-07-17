# List-To-Do (Flutter + Supabase)

Aplicación móvil y web desarrollada en Flutter con backend en Supabase, que permite a los usuarios autenticarse, crear tareas, subir imágenes, y añadir reseñas con sistema de roles.

## Capturas de pantalla

### Registro de usuario con rol personalizado
![Registro](./assets/screenshots/registro.png)

Los usuarios se registran con su nombre completo, email y contraseña. Luego, pueden iniciar sesión si su correo ha sido confirmado.

### Lista de tareas con imagen y estado
![Lista de tareas](./assets/screenshots/lista_tareas.png)

Una vez autenticado, el usuario accede a su lista de tareas personal, donde puede:
- Ver tareas propias
- Filtrar por estado
- Visualizar la imagen asociada (opcional)

### Crear nueva tarea
![Agregar tarea](./assets/screenshots/agregar_tarea.png)

Formulario de creación de tareas que permite:
- Título
- Descripción (opcional)
- URL de imagen (opcional)
- Subida de imagen local al Storage de Supabase

### Reseñas asociadas a tareas
![Detalle tarea y reseñas](./assets/screenshots/detalle_tarea.png)

Cada tarea puede recibir reseñas de usuarios con rol 'publicador'. Estas reseñas permiten también respuestas anidadas (comentarios a comentarios).

## Funcionalidades principales

- Autenticación de usuarios con Supabase Auth
- Asignación de rol ('publicador' o visitante) mediante tabla `turismo_perfiles`
- Gestión de tareas: crear, ver, y listar
- Subida de imágenes a Supabase Storage
- Sistema de reseñas y respuestas con relación padre-hijo (`resena_padre`)
- Interfaz responsiva (Flutter Web y Mobile)

## Base de datos

### Tablas principales:
- `usuarios` (auth integrada)
- `turismo_perfiles`: gestiona el rol por `usuario_id`
- `tareas`: contiene `titulo`, `descripcion`, `estado`, `imagen_url`, etc.
- `turismo_resenas`: reseñas de tareas, con soporte a respuestas (`resena_padre`)

## Tecnologías usadas

- Flutter (SDK 3.22+)
- Supabase (Auth, Database, Storage)
- Dart lenguaje de programación
- Image Picker para cámara y galería
- Supabase Flutter SDK para integración backend

## Autor

- Isaac Quinapallo
- isaac.quinapallo@epn.edu.ec

## Cómo ejecutar

```bash
flutter pub get
flutter run
```

Recuerda configurar tu archivo `.env` o directamente tu Supabase URL y anon/public key.