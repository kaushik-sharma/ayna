import 'package:ayna/core/helpers/ui_helpers.dart';
import 'package:ayna/features/auth/domain/entities/sign_up_entity.dart';
import 'package:ayna/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:ayna/router/router_config.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif/gif.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../di.dart';
import '../../../../gen/assets.gen.dart';
import '../../domain/entities/sign_in_entity.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late final GifController _gifController;

  var _email = '';
  var _password = '';
  var _name = '';

  var _authMode = AuthMode.signUp;
  var _isLoading = false;

  final _bloc = sl<AuthBloc>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => _email = _emailController.text.trim());
    _passwordController
        .addListener(() => _password = _passwordController.text.trim());
    _nameController.addListener(() => _name = _nameController.text.trim());
    _gifController = GifController(vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.when<void>(
          initial: () {},
          modeChanged: (mode) {
            _authMode = mode;
            _emailController.clear();
            _passwordController.clear();
            _nameController.clear();
            _email = '';
            _password = '';
            _name = '';
            _formKey.currentState!.reset();
          },
          loading: () {
            _isLoading = true;
            UiHelpers.showLoadingOverlay(context, showLoader: false);
          },
          loaded: () {
            _isLoading = false;
            UiHelpers.hideLoadingOverlay();
          },
          authSuccess: () {
            context.goNamed(Routes.home.name);
          },
          authFailure: (message) {
            UiHelpers.showSnackBar(message, mode: SnackBarMode.error);
          },
          signOutSuccess: () {},
          signOutFailure: () {},
        );
      },
      builder: (context, state) => Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: MediaQuery.sizeOf(context).width <= 500
                ? _buildMobileView()
                : _buildDesktopView(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileView() => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 100.h),
          child: _buildForm(),
        ),
      );

  Widget _buildDesktopView() => Row(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 0.55,
            padding: EdgeInsets.symmetric(horizontal: 300.w),
            child: _buildForm(),
          ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.45,
            child: _buildIllustration(),
          ),
        ],
      );

  Widget _buildForm() => Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 80.h,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            60.verticalSpace,
            if (_authMode == AuthMode.signUp) ...[
              SizedBox(
                width: double.infinity,
                child: CustomTextField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  hintText: 'Name',
                ),
              ),
              40.verticalSpace,
            ],
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!EmailValidator.validate(_email)) return 'Invalid';
                  return null;
                },
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
              ),
            ),
            40.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (value.length < 8) return 'Must be at-least 8 characters';
                  return null;
                },
                hintText: 'Password',
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.none,
                obscureText: true,
              ),
            ),
            80.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                type: ButtonType.elevated,
                onTap: _submit,
                text: _authMode == AuthMode.signUp ? 'Sign up' : 'Sign in',
                isLoading: _isLoading,
              ),
            ),
            30.verticalSpace,
            CustomButton(
              type: ButtonType.text,
              onTap: () {
                _bloc.add(AuthEvent.toggleMode(_authMode == AuthMode.signUp
                    ? AuthMode.signIn
                    : AuthMode.signUp));
              },
              text: _authMode == AuthMode.signUp
                  ? 'Sign-in instead?'
                  : 'Sign-up instead?',
            ),
          ],
        ),
      );

  Widget _buildIllustration() => Gif(
        controller: _gifController,
        fit: BoxFit.contain,
        autostart: Autostart.once,
        image: AssetImage(
          Assets.gifs.authentication.path,
        ),
        onFetchCompleted: () {
          _gifController.forward();
        },
      );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _authMode == AuthMode.signUp
        ? _bloc.add(AuthEvent.signUp(SignUpEntity(_email, _password, _name)))
        : _bloc.add(AuthEvent.signIn(SignInEntity(_email, _password)));
  }
}
