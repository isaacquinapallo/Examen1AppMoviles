import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'detalle_tarea_page.dart';
import 'services/auth_service.dart';
import 'services/image_service.dart';
import 'login_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _formKey = GlobalKey<FormState>();
  String imagenUrl = '';
  String descripcion = '';
  String nombre = '';
  bool _showForm = false;
  Map<String, dynamic>? _userProfile;
  bool _isPublisher = false;

  final _supabase = Supabase.instance.client;

  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userId = AuthService.currentUser?.id;
    if (userId != null) {
      final perfil = await _supabase
          .from('turismo_perfiles')
          .select()
          .eq('usuario_id', userId)
          .maybeSingle();

      if (mounted && perfil != null) {
        setState(() {
          _userProfile = perfil;
          _isPublisher = perfil['rol'] == 'publicador';
        });
      }
    }
  }

  Future<void> _agregarTarea() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      String? fotoUrl;

      if (_selectedImages.isNotEmpty) {
        final urls = await ImageService.uploadMultipleImages(
          _selectedImages,
          'tareas-images',
        );
        if (urls.isNotEmpty) {
          fotoUrl = urls.first;
        }
      }

      final dataToInsert = {
        'usuario_id': AuthService.currentUser?.id,
        'titulo': nombre,
        'estado': 'pendiente',
        'foto_url': fotoUrl,
        'fecha': DateTime.now().toIso8601String(),
        'compartida': false,
        'descripcion': descripcion,
        'imagen_url': imagenUrl,
      };

      await _supabase.from('tareas').insert(dataToInsert);

      _formKey.currentState!.reset();
      setState(() {
        _selectedImages = [];
        _showForm = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea agregada exitosamente')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar tarea: $error')),
        );
      }
    }
  }

  Future<void> _selectImages() async {
    final images = await ImageService.showImageOptions(context);
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages = [images.first];
      });
    }
  }

  // Método para cerrar sesión
  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Widget _buildFormOverlay() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador de arrastre
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Barra superior
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agregar tarea',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showForm = false;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Campo Título
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Título de la tarea',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese un título' : null,
                      onSaved: (value) => nombre = value!,
                    ),
                    const SizedBox(height: 12),

                    // Campo URL imagen
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'URL de imagen (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSaved: (value) => imagenUrl = value ?? '',
                    ),
                    const SizedBox(height: 12),

                    // Campo Descripción (opcional si luego quieres usarla)
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                      onSaved: (value) => descripcion = value ?? '',
                    ),
                    const SizedBox(height: 16),

                    // Imagen local
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Imagen local',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _selectImages,
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Seleccionar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isPublisher
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_selectedImages.isNotEmpty)
                              SizedBox(
                                height: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(
                                          _selectedImages.first.path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_selectedImages.first.path),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              )
                            else
                              const Text(
                                'Opcional: 1 imagen local (se subirá al storage)',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón Agregar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _agregarTarea,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPublisher
                              ? const Color(0xFF4CAF50)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Agregar tarea',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    // Espacio adicional para teclado
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 0
                          ? 200
                          : 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Mis tareas'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () async {
              await _loadUserProfile();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Rol: ${_userProfile?['rol'] ?? 'sin rol'} | Publicador: $_isPublisher',
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
          ),

          // Mostrar solo si no es publicador
          if (_userProfile == null || _userProfile?['rol'] != 'publicador')
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(
                      mensajeInicial:
                          'Debes iniciar sesión o registrarte como publicador',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
            ),

          if (_userProfile != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userProfile!['nombre'] ?? 'Usuario',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _userProfile!['rol'] ?? 'visitante',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),

      body: Builder(
        builder: (context) {
          final userId = AuthService.currentUser?.id;

          if (userId == null) {
            return const Center(
              child: Text(
                'Debes iniciar sesión para ver tus tareas',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Stack(
            children: [
              // Lista de tareas
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _supabase
                    .from('tareas')
                    .stream(primaryKey: ['id'])
                    .eq('usuario_id', userId)
                    .order('fecha', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 80, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar datos',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red[700],
                            ),
                          ),
                          Text(
                            '${snapshot.error}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final tareas = snapshot.data ?? [];
                  if (tareas.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay tareas aún',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            'Agrega tu primera tarea',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tareas.length,
                    itemBuilder: (context, index) {
                      final data = tareas[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  (data['foto_url'] != null &&
                                      data['foto_url'].toString().isNotEmpty)
                                  ? Image.network(
                                      data['foto_url'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                            );
                                          },
                                    )
                                  : const Icon(
                                      Icons.task_alt,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          title: Text(
                            data['titulo'] ?? 'Sin título',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Estado: ${data['estado'] ?? 'pendiente'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: data['estado'] == 'completada'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              if (data['fecha'] != null)
                                Text(
                                  'Fecha: ${data['fecha']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetalleTareaPage(data: data),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),

              // Overlay del formulario
              if (_showForm) _buildFormOverlay(),
            ],
          );
        },
      ),

      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showForm
            ? null
            : FloatingActionButton.extended(
                key: const ValueKey('add_button'),
                onPressed: _isPublisher
                    ? () {
                        setState(() {
                          _showForm = true;
                        });
                      }
                    : () {
                        final currentUser = AuthService.currentUser;
                        if (currentUser == null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(
                                mensajeInicial:
                                    'Debes iniciar sesión para agregar tareas',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Debes ser publicador para agregar tareas. Rol actual: ${_userProfile?['rol'] ?? 'sin rol'}',
                              ),
                            ),
                          );
                        }
                      },
                backgroundColor: _isPublisher
                    ? const Color(0xFF4CAF50)
                    : Colors.grey,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  _isPublisher ? 'Agregar tarea' : 'Registrar',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
