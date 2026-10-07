import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/auth/auth.dart';
import 'package:template_app/features/general/general.dart';

class AuthFakeDatasource implements AuthRemoteDatasource {
  const AuthFakeDatasource();

  @override
  Future<Either<Failure, LoginResponse>> login(LoginParams params) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 600));

    final token = 'fake_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    final refreshToken =
        'fake_refresh_token_${DateTime.now().millisecondsSinceEpoch}';

    return Right(
      LoginResponse(
        diagnostic: const Diagnostic(
          status: '200',
          message: 'Login successful',
        ),
        data: DataLogin(
          token: token,
          tokenType: 'Bearer',
          refreshToken: refreshToken,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, RegisterResponse>> register(
    RegisterParams params,
  ) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 600));

    return Right(
      RegisterResponse(
        diagnostic: const Diagnostic(
          status: '201',
          message: 'Account successfully registered',
        ),
        data: DataRegister(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: params.name,
          email: params.email,
          verified: true,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, DiagnosticResponse>> logout() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));

    return const Right(
      DiagnosticResponse(
        diagnostic: Diagnostic(status: '200', message: 'Logout successful'),
      ),
    );
  }
}
