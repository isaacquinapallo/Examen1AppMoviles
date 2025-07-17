import 'package:flutter/material.dart';
import './services/auth_service.dart';
import 'task_list_page.dart';

class LoginPage extends StatefulWidget {
  final String? mensajeInicial;

  const LoginPage({super.key, this.mensajeInicial});

  @override
  State<LoginPage> createState() => _LoginPageState();
  
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.mensajeInicial != null && widget.mensajeInicial!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.mensajeInicial!)));
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
    _nameController.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    bool success = false;
    String message = '';

    try {
      if (_isLogin) {
        success = await AuthService.loginWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
        message = success ? 'Login exitoso' : 'Error en las credenciales';
      } else {
        success = await AuthService.signUp(
  _emailController.text.trim(),
  _passwordController.text,
  _nameController.text.trim(),
);

        message = success ? 'Registro exitoso' : 'Error en el registro';
      }

      if (success && mounted) {
        if (_isLogin) {
          // Después de login exitoso
          await AuthService.refreshCurrentUser();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inicio de sesión exitoso ✅')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TaskListPage()),
          );
        } else {
          // Después de registro exitoso (sin login inmediato)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registro exitoso. Revisa tu email para confirmar antes de iniciar sesión.',
              ),
            ),
          );

          setState(() {
            _isLogin = true; // Cambiar a formulario de login
          });
        }
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('List-To-Do'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.check_circle_outline,
                size: 90,
                color: Color(0xFF1E88E5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bienvenido a List-To-Do',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              if (!_isLogin) ...[
                TextFormField(
  controller: _nameController,
  decoration: InputDecoration(

                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingrese su nombre' : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese su email';
                  if (!value.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese su contraseña';
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLogin ? 'Iniciar Sesión' : 'Registrarse',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                child: Text(
                  _isLogin
                      ? '¿No tienes cuenta? Regístrate'
                      : '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
