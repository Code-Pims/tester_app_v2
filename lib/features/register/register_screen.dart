import 'package:dojodex_instructor/blocs/authentication/authentication_bloc.dart';
import 'package:dojodex_common/dojodex_string_utils.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Text controllers for the textfields
  late TextEditingController firstNameTextController;
  late TextEditingController lastNameTextController;
  late TextEditingController emailTextController;
  late TextEditingController passwordTextController;
  late TextEditingController confirmPasswordTextController;
  late TextEditingController dobTextController;

  /// Form key for the form
  final _formKey = GlobalKey<FormState>();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  @override
  void initState() {
    passwordTextController = TextEditingController();
    confirmPasswordTextController = TextEditingController();
    firstNameTextController = TextEditingController();
    lastNameTextController = TextEditingController();
    emailTextController = TextEditingController();
    dobTextController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRegisterForms(),
                    const SizedBox(height: 30),
                    _buildRegisterButton(),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _buildRegisterButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return PrimaryButtonWidget(
              isLoading: state.isRegisteringUser,
              style: ButtonStyles.defaultStyle,
              canonicalButtonName: "Register",
              onPressed: state.isRegisteringUser ?? false
                  ? null
                  : _onAttemptToRegisterUser,
              children: const [
                Text(
                  "Register",
                )
              ],
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _onAttemptToRegisterUser() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthenticationBloc>().add(
            RegisterUser(
              email: emailTextController.text,
              password: passwordTextController.text,
              firstName: firstNameTextController.text,
              lastName: lastNameTextController.text,
            ),
          );
    }
  }

  Column _buildRegisterForms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildEmailTextfield(),
        const SizedBox(height: 20),
        _buildFirstnameTextfield(),
        const SizedBox(height: 20),
        _buildLastnameTextfield(),
        const SizedBox(height: 20),
        _buildPasswordTextfield(),
        const SizedBox(height: 20),
        _buildConfirmPasswordTextfield(),
        const SizedBox(height: 20),
      ],
    );
  }

  CustomInputLayout _buildConfirmPasswordTextfield() {
    return CustomInputLayout(
      label: "Confirm password",
      child: CustomTextfield(
        controller: confirmPasswordTextController,
        textFieldName: "Confirm password",
        isObscureText: !confirmPasswordVisible,
        validator: (p0) {
          if (p0 == null || p0.isEmpty) {
            return "Confirm password is required";
          }
          return null;
        },
        suffixIcon: IconButton(
          icon: Icon(
            !confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: confirmPasswordVisible ? Colors.black26 : Colors.black26,
          ),
          onPressed: () {
            setState(() {
              confirmPasswordVisible = !confirmPasswordVisible;
            });
          },
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
        validator: (p0) {
          if (p0 == null || p0.isEmpty) {
            return "Password is required";
          }
          if (p0 != confirmPasswordTextController.text) {
            return "Passwords do not match";
          }
          return null;
        },
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
      ),
    );
  }

  CustomInputLayout _buildLastnameTextfield() {
    return CustomInputLayout(
      label: "Last name",
      child: CustomTextfield(
        controller: lastNameTextController,
        textFieldName: "Last name",
        validator: (p0) {
          if (p0 == null || p0.isEmpty) {
            return "Last name is required";
          }
          return null;
        },
      ),
    );
  }

  CustomInputLayout _buildFirstnameTextfield() {
    return CustomInputLayout(
      label: "First name",
      child: CustomTextfield(
        controller: firstNameTextController,
        textFieldName: "First name",
        validator: (p0) {
          if (p0 == null || p0.isEmpty) {
            return "First name is required";
          }
          return null;
        },
      ),
    );
  }

  CustomInputLayout _buildEmailTextfield() {
    return CustomInputLayout(
      label: "Email",
      child: CustomTextfield(
        controller: emailTextController,
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
