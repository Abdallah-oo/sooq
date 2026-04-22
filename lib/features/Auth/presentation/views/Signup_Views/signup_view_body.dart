import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sooq/core/utils/snack_bar.dart';
import 'package:sooq/features/Auth/presentation/cubits/Auth_Cubit/auth_cubit.dart';
import 'package:sooq/features/Auth/presentation/cubits/Pick_Image_Cubit/pick_image_cubit.dart';
import 'package:sooq/features/Auth/presentation/views/widgets/pick_image.dart';
import 'package:sooq/features/Auth/presentation/views/widgets/signup_container.dart';

class SignupViewBody extends StatelessWidget {
  const SignupViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    //    CupertinoActivityIndicator(color: Colors.white, radius: 15),
    return MultiBlocListener(
      listeners: [
        BlocListener<PickImageCubit, PickImageState>(
          listener: (context, state) {
            if (state is PickImageFailure) {
              CustomSnackBar.error(context, state.errorMessage);
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.failure) {
              CustomSnackBar.error(context, state.errorMessage ?? '');
            }
            if (state.status == AuthStatus.success) {
              CustomSnackBar.success(
                context,
                'Successfully Registered , you can login now',
              );
              context.pop();
         
            }
          },
        ),
      ],
      child: const SafeArea(
        child: Column(
          children: [
            Gap(30),
            PickImageWidget(isProfile: true),
            Gap(20),
            Expanded(child: SignupContainer()),
          ],
        ),
      ),
    );
  }
}
