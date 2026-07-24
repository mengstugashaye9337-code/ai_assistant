import 'package:ai_assistant/features/auth/application/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/features/auth/presentation/validator.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_assistant/core/router/app_router.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});
  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  late final TextEditingController _emailcontroller,
      _firstNamecontroller,
      _secondNamecontroller;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final GlobalKey<FormState> _formKey;
  late final FocusNode _focusNode;
  @override
  void initState() {
    super.initState();
    _firstNamecontroller = TextEditingController();
    _secondNamecontroller = TextEditingController();

    _emailcontroller = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordController.dispose();

    _focusNode.dispose();
    // Added to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailcontroller,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validator.validateEmail,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: Validator.validatePassword,
              ),
              TextFormField(
                controller: _firstNamecontroller,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validator.validateName,
              ),
              TextFormField(
                controller: _secondNamecontroller,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: Validator.validateName,
              ),

              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => Validator.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signUp(
                                _firstNamecontroller.text,
                                _secondNamecontroller.text,
                                _emailcontroller.text,
                                _passwordController.text,
                              );
                        }
                      },
                child: const Text('Sign up'),
              ),

              ElevatedButton(
                onPressed: () => context.go(AppRoutes.signIn),
                child: const Text('already signup? signin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
