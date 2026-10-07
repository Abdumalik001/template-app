part of 'login_page.dart';

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.isValid,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
  });

  final GlobalKey<FormState> formKey;
  final ValueNotifier<bool> isValid;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    onChanged: () => isValid.value = formKey.currentState?.validate() ?? false,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      children: [
        FadeSlideIn(
          delay: Motion.stagger * 3,
          child: TextF(
            autoFillHints: const [AutofillHints.email],
            key: const Key('email'),
            focusNode: emailFocusNode,
            textInputAction: TextInputAction.next,
            controller: emailController,
            textInputType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.alternate_email_rounded),
            hint: Strings.of(context)!.emailHint,
            label: Strings.of(context)!.email,
            validator: (value) => !value.toString().isValidEmail()
                ? Strings.of(context)!.errorInvalidEmail
                : null,
          ),
        ),
        FadeSlideIn(
          delay: Motion.stagger * 4,
          child: TextF(
            autoFillHints: const [AutofillHints.password],
            key: const Key('password'),
            focusNode: passwordFocusNode,
            textInputAction: TextInputAction.done,
            controller: passwordController,
            isPassword: true,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            hint: Strings.of(context)!.passwordHint,
            label: Strings.of(context)!.password,
            validator: (value) => (value?.length ?? 0) < 5
                ? Strings.of(context)!.errorPasswordLength
                : null,
          ),
        ),
        SpacerV(value: Dimens.space24),
        FadeSlideIn(
          delay: Motion.stagger * 5,
          child: ValueListenableBuilder(
            valueListenable: isValid,
            builder: (_, formIsValid, _) => Button(
              title: Strings.of(context)!.login,
              width: double.maxFinite,
              onPressed: formIsValid
                  ? () => context.read<AuthCubit>().login(
                      LoginParams(
                        email: emailController.text,
                        password: passwordController.text,
                        osInfo: Platform.operatingSystem,
                        deviceInfo: Platform.localHostname,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    ),
  );
}
