import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/routing/routes.dart';
import 'package:sooq/core/theme/app_colors.dart';
import 'package:sooq/core/theme/app_text_styles.dart';
import 'package:sooq/core/utils/custom_button.dart';
import 'package:sooq/core/utils/custom_text.dart';
import 'package:sooq/core/utils/validators.dart';
import 'package:sooq/features/Auth/presentation/cubits/Auth_Cubit/auth_cubit.dart';
import 'package:sooq/features/Auth/presentation/views/widgets/custom_text_field.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginContainer extends StatefulWidget {
  const LoginContainer({super.key});

  @override
  State<LoginContainer> createState() => _LoginContainerState();
}

class _LoginContainerState extends State<LoginContainer> {
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier(false);
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController(text: 'a@gmail.com');
    _passwordController = TextEditingController(text: 'Aa@012100');

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(40),
            topEnd: Radius.circular(40),
          ),
          color: AppColors.primary,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(35),
                CustomText(
                  text: 'Login',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 26
                  ),
                ),

                const Gap(35),
                //email field
                CustomTextField(
                  validation: Validators.email,
                  prefixIcon: const Icon(Icons.person),
                  hint: 'email or phone number',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const Gap(20),
                //password field
                ValueListenableBuilder<bool>(
                  valueListenable: _isPasswordVisible,
                  builder: (context, isVisible, _) {
                    return CustomTextField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(CupertinoIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => _isPasswordVisible.value = !isVisible,
                      ),
                      secure: !isVisible,
                      hint: 'password',
                      validation: Validators.password,
                    );
                  },
                ),

                const Gap(5),
                //forget password
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CustomText(
                      text: 'Forget password ?',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.grey100,
                      ),
                    ),
                  ),
                ),

                const Gap(30),

                //login button
                _LoginBtn(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
                const Gap(40),

                //dvider
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.border, thickness: 0.7),
                    ),
                    Gap(3),
                    CustomText(text: ' OR ', style: AppTextStyles.button),

                    Gap(3),
                    Expanded(
                      child: Divider(color: AppColors.border, thickness: 0.7),
                    ),
                  ],
                ),
                const Gap(20),

                // ── Social Buttons
                _buildSocialButton(
                  label: 'Continue with Google',
                  icon: SvgPicture.asset(
                    'assets/img/loginmethods/icons8-google.svg',
                    width: 25,
                  ),
                  onTap: () {},
                ),

                _buildSocialButton(
                  label: 'Continue with GitHub',
                  icon: SvgPicture.asset(
                    'assets/img/loginmethods/github-svgrepo-com.svg',
                    width: 25,
                  ),
                  onTap: () {},
                ),

                const Gap(10),

                //go to register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: 'Do not have an account?',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.grey100,
                      ),
                    ),
                    const Gap(5),
                    TextButton(
                      onPressed: () => context.push(Routes.signup),
                      child: const CustomText(
                        text: 'Sign Up',
                        style: AppTextStyles.button,
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

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        margin: const EdgeInsets.only(bottom: 12),

        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            icon,
            const Gap(25),
            CustomText(
              text: label,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginBtn extends StatelessWidget {
  const _LoginBtn({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  void _login(BuildContext context) {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().onTapLoginBut(
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
          onPressed: isLoading ? null : () => _login(context),
          color: AppColors.white,
          radius: 13,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: 'Login',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.black,
                  fontSize: 18,
                ),
              ),

              if (isLoading) ...[
                const Gap(11),
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
