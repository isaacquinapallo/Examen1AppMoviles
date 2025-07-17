# List-To-Do (Flutter y Supabase)

Aplicación móvil y web desarrollada en Flutter con backend en Supabase, que permite a los usuarios autenticarse, crear tareas, subir imágenes, y añadir reseñas con sistema de roles.

## Capturas de pantalla

### Registro de usuario con rol personalizado

<img width="886" height="466" alt="image" src="https://github.com/user-attachments/assets/6e148846-e2a1-4e69-a0d4-750aeb70b5a0" />


Los usuarios se registran con su nombre completo, email y contraseña. Luego, pueden iniciar sesión si su correo ha sido confirmado.

### Lista de tareas con imagen y estado
<img width="623" height="831" alt="image" src="https://github.com/user-attachments/assets/93a9fa56-aeb3-4a05-8b56-5d047c84f644" />

Una vez autenticado, el usuario accede a su lista de tareas personal, donde puede:
- Ver tareas propias
- Filtrar por estado
- Visualizar la imagen asociada (opcional)

### Crear nueva tarea
<img width="628" height="833" alt="image" src="https://github.com/user-attachments/assets/7c175134-43ae-4df7-8e47-9ce04fa8e57e" />


Formulario de creación de tareas que permite:
- Título
- Descripción (opcional)
- URL de imagen (opcional)
- Subida de imagen local al Storage de Supabase

### Reseñas asociadas a tareas
<img width="622" height="833" alt="image" src="https://github.com/user-attachments/assets/51e94d99-90d2-4ae3-8127-67691e112924" />


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

- Flutter
- Supabase (Auth, Database, Storage)
- Dart lenguaje de programación
- Image Picker para cámara y galería
- Supabase Flutter SDK para integración backend

## Autor

- Isaac Quinapallo
- isaac.quinapallo@epn.edu.ec

## Cómo ejecutar

flutter pub get
flutter run
