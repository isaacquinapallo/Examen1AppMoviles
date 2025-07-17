import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  // Obtener usuario actual
  static User? get currentUser => _supabase.auth.currentUser;

  // Verificar si está autenticado
  static bool get isAuthenticated => currentUser != null;

  // Verificar si el usuario tiene rol 'publicador'
  static Future<bool> isPublisher() async {
    final userId = currentUser?.id;
    if (userId == null) return false;

    try {
      final perfil = await _supabase
          .from('turismo_perfiles')
          .select('rol')
          .eq('usuario_id', userId)
          .single();

      return perfil['rol'] == 'publicador';
    } catch (e) {
      print('Error al verificar rol: $e');
      return false;
    }
  }

  // Login con email y contraseña
  static Future<bool> loginWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  // Registro de usuario y creación de perfil
  static Future<bool> signUp(String email, String password, String nombre) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final userId = response.user?.id;

      if (userId != null) {
        // Verifica si ya existe un perfil
        final existing = await _supabase
            .from('turismo_perfiles')
            .select()
            .eq('usuario_id', userId)
            .maybeSingle();

        if (existing == null) {
          // Crea perfil con rol por defecto 'visitante'
          await _supabase.from('turismo_perfiles').insert({
            'usuario_id': userId,
            'nombre': nombre,
            'rol': 'visitante',
          });
        }
      }

      return response.user != null;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }

  // Refrescar usuario (por si hay cambios en la sesión)
  static Future<void> refreshCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _supabase.auth.refreshSession();
      }

      final user = _supabase.auth.currentUser;
      if (user != null) {
        print('Usuario refrescado: ${user.email}');
      } else {
        print('No se pudo refrescar usuario');
      }
    } catch (e) {
      print('Error refrescando usuario: $e');
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
