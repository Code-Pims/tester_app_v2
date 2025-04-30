import 'package:dojodex_instructor/blocs/authentication/authentication_bloc.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/dojodex_string_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dojodex_common/ui/ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController usernameTextController;
  late TextEditingController passwordTextController;

  bool passwordVisible = false;

  /// Form key for the form
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    usernameTextController = TextEditingController();
    passwordTextController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Container(
                        height: 180,
                        width: 180,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildUsernameTextfield(),
                    const SizedBox(height: 20),
                    _buildPasswordTextfield(),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  RichText(
                      text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                        color: DojoDexColors.secondaryText, fontSize: 16),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              () => sl<RouteHelper>().showRegisterScreen(),
                        text: "Sign up",
                        style: const TextStyle(
                          color: DojoDexColors.primary,
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, state) {
                      return PrimaryButtonWidget(
                        style: ButtonStyles.defaultStyle,
                        canonicalButtonName: "Login",
                        onPressed: state.isLoggingIn ?? false
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthenticationBloc>().add(
                                        LoginUser(
                                          email: usernameTextController.text,
                                          password: passwordTextController.text,
                                        ),
                                      );
                                }
                              },
                        isLoading: state.isLoggingIn,
                        children: const [
                          Text(
                            "Login",
                          )
                        ],
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  CustomInputLayout _buildPasswordTextfield() {
    return CustomInputLayout(
      label: "Password",
      child: CustomTextfield(
        controller: passwordTextController,
        textFieldName: "Password",
        isObscureText: !passwordVisible,
        suffixIcon: IconButton(
          icon: Icon(
            !passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: passwordVisible ? Colors.black26 : Colors.black26,
          ),
          onPressed: () {
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
        ),
        validator: (p0) {
          if (p0 == null || p0.isEmpty) {
            return "Password is required";
          }
          return null;
        },
      ),
    );
  }

  CustomInputLayout _buildUsernameTextfield() {
    return CustomInputLayout(
      label: "Email",
      child: CustomTextfield(
        controller: usernameTextController,
        textFieldName: "Email",
        validator: (p0) {
          if (p0 == null || p0.isEmpty) {
            return "Email is required";
          }
          if (!isValidEmail(p0)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }
}
