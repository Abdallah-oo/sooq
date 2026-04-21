import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/snack_bar.dart';
import 'package:sooq/core/utils/validators.dart';
import 'package:sooq/features/Auth/presentation/views/cubits/Pick_Image_Cubit/pick_image_cubit.dart';
import 'package:sooq/features/Auth/presentation/views/cubits/Auth_Cubit/auth_cubit.dart';
import 'package:sooq/features/Auth/presentation/views/widgets/custom_text_field.dart';
import 'package:sooq/features/Auth/presentation/views/widgets/password_strength_indicator.dart';

class SignupContainer extends StatefulWidget {
  const SignupContainer({super.key});

  @override
  State<SignupContainer> createState() => _SignupContainerState();
}

class _SignupContainerState extends State<SignupContainer> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier(false);
  final ValueNotifier<String> _passwordNotifier = ValueNotifier('');
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordNotifier.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(40),
          topEnd: Radius.circular(40),
        ),
        color: AppColors.primary,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(35),
                CustomText(
                  text: 'Sign Up',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontSize: 26,
                  ),
                ),
              
                const Gap(35),
                //name field
                CustomTextField(
                  hint: 'Full Name',
                  controller: _nameController,
                  validation: Validators.required,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
            
                const Gap(20),
                //phone field
                CustomTextField(
                  hint: 'Phone',
                  controller: _phoneController,
                  validation: Validators.phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
             
                const Gap(20),
                //email field
                CustomTextField(
                  hint: 'Email',
                  controller: _emailController,
                  validation: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              
                const Gap(20),
                //password field
                ValueListenableBuilder<bool>(
                  valueListenable: _isPasswordVisible,
                  builder: (_, isVisible, __) => CustomTextField(
                    hint: 'Password',
                    controller: _passwordController,
                    validation: Validators.password,
                    onChange: (value) => _passwordNotifier.value = value,
                    secure: !isVisible,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(CupertinoIcons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => _isPasswordVisible.value = !isVisible,
                    ),
                  ),
                ),
                const Gap(15),
                //Password Strength Indicator
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: PasswordStrengthIndicator(
                    passwordNotifier: _passwordNotifier,
                  ),
                ),
                const Gap(20),
                //confirm password field
                CustomTextField(
                  hint: 'Confirm Password',
                  controller: _confirmPasswordController,
                  validation: Validators.confirmPassword(_passwordController),
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(CupertinoIcons.lock_rotation),
                ),
          
                const Gap(40),

                //Sign up button
                _SignUp(
                  formKey: _formKey,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
             
                const Gap(20),
                // go to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: 'Already have an account?',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.grey100,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: CustomText(
                        text: 'Log In',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
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
}

class _SignUp extends StatelessWidget {
  const _SignUp({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  void _signUP(BuildContext context) {
    final imageFile = context.read<PickImageCubit>().imageFile;
    if (imageFile == null) {
      CustomSnackBar.warning(context, 'Please select a profile picture');
      return;
    }
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().onTapSignUpBut(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, curr) =>
          prev.status == AuthStatus.loading ||
          curr.status == AuthStatus.loading,
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return CustomButton(
          radius: 10,
          color: AppColors.white,
          onPressed: isLoading ? null : () => _signUP(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: 'Signup',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.black,
                  fontSize: 18,
                ),
              ),
              if (isLoading) ...[
                const Gap(8),
                LoadingAnimationWidget.inkDrop(
                  color: AppColors.black,
                  size: 10,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
