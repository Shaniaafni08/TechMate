import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/techmate_logo.dart';
import '../widgets/form_label.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Silakan masuk.'),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const TechMateLogo(size: 70),

                const SizedBox(height: 12),

                const Text(
                  'Buat Akun TechMate',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Buat akun untuk mulai belajar',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textGrey,
                          ),
                        ),

                        const SizedBox(height: 22),

                        const FormLabel('Nama Lengkap'),

                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan nama lengkap',
                            prefixIcon: Icon(
                              Icons.person_outline,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const FormLabel('Email'),

                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'contoh@email.com',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Email tidak boleh kosong';
                            }

                            if (!value.contains('@')) {
                              return 'Format email tidak valid';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const FormLabel('Password'),

                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            hintText: 'Masukkan password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }

                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const FormLabel('Konfirmasi Password'),

                        TextFormField(
                          controller: _confirmPassCtrl,
                          obscureText: _hideConfirmPassword,
                          decoration: InputDecoration(
                            hintText: 'Ulangi password',
                            prefixIcon: const Icon(
                              Icons.lock_reset_outlined,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hideConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hideConfirmPassword =
                                      !_hideConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Konfirmasi password tidak boleh kosong';
                            }

                            if (value != _passCtrl.text) {
                              return 'Password tidak sama';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 26),

                        ElevatedButton(
                          onPressed: _register,
                          child: const Text('Daftar'),
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: 'Sudah punya akun? ',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Masuk',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}