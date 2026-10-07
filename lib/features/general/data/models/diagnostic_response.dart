import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:template_app/features/general/general.dart';

part 'diagnostic_response.freezed.dart';
part 'diagnostic_response.g.dart';

@freezed
sealed class DiagnosticResponse with _$DiagnosticResponse {
  const factory DiagnosticResponse({
    @JsonKey(name: 'diagnostic') Diagnostic? diagnostic,
  }) = _DiagnosticResponse;

  factory DiagnosticResponse.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticResponseFromJson(json);
}
