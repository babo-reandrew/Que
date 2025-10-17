/// 검증 결과를 표준화된 형태로 관리하는 모델 클래스
/// 검증 성공/실패, 에러 메시지, 경고 메시지를 하나의 객체로 통합해서 관리한다
class ValidationResult {
  final bool isValid; // 검증 성공 여부 - true면 검증 통과, false면 검증 실패
  final Map<String, String> errors; // 필드별 에러 메시지 - 키는 필드명, 값은 에러 메시지
  final List<String> warnings; // 경고 메시지 목록 - 검증은 통과했지만 사용자에게 알릴 내용

  /// 기본 생성자 - 모든 값을 직접 설정할 때 사용한다
  ValidationResult({
    required this.isValid, // 검증 성공 여부를 필수로 받는다
    this.errors = const {}, // 에러가 없으면 빈 맵으로 초기화한다
    this.warnings = const [], // 경고가 없으면 빈 리스트로 초기화한다
  });

  /// 성공 결과를 생성하는 팩토리 생성자 - 검증이 모두 통과했을 때 사용한다
  /// 에러와 경고가 모두 없는 상태로 초기화한다
  ValidationResult.success()
    : isValid = true, // 검증 성공으로 설정한다
      errors = {}, // 에러가 없다
      warnings = []; // 경고가 없다

  /// 실패 결과를 생성하는 팩토리 생성자 - 검증이 실패했을 때 사용한다
  /// 에러 메시지 맵을 받아서 실패 결과를 생성한다
  ValidationResult.failure(Map<String, String> errorMap)
    : isValid = false, // 검증 실패로 설정한다
      errors = errorMap, // 전달받은 에러 메시지를 저장한다
      warnings = []; // 실패 시에는 경고가 없다

  /// 경고가 있는 성공 결과를 생성하는 팩토리 생성자
  /// 검증은 통과했지만 사용자에게 알릴 내용이 있을 때 사용한다
  ValidationResult.successWithWarnings(List<String> warningList)
    : isValid = true, // 검증은 성공이다
      errors = {}, // 에러는 없다
      warnings = warningList; // 경고 메시지를 저장한다

  /// 에러가 있는지 확인하는 헬퍼 메소드 - UI에서 에러 표시 여부를 결정할 때 사용한다
  bool get hasErrors => errors.isNotEmpty;

  /// 경고가 있는지 확인하는 헬퍼 메소드 - UI에서 경고 표시 여부를 결정할 때 사용한다
  bool get hasWarnings => warnings.isNotEmpty;

  /// 완전히 깨끗한 상태인지 확인하는 헬퍼 메소드 - 에러도 경고도 없는 완벽한 상태를 확인한다
  bool get isPerfect => isValid && !hasErrors && !hasWarnings;

  /// 모든 에러 메시지를 하나의 문자열로 결합하는 헬퍼 메소드
  /// UI에서 한 번에 모든 에러를 표시할 때 사용한다
  String get allErrorMessages => errors.values.join('\n');

  /// 모든 경고 메시지를 하나의 문자열로 결합하는 헬퍼 메소드
  /// UI에서 한 번에 모든 경고를 표시할 때 사용한다
  String get allWarningMessages => warnings.join('\n');

  /// 특정 필드의 에러 메시지를 가져오는 헬퍼 메소드
  /// TextFormField의 errorText에 직접 사용할 수 있다
  String? getErrorForField(String fieldName) => errors[fieldName];

  /// 여러 ValidationResult를 병합하는 정적 메소드
  /// 여러 검증 결과를 하나로 통합할 때 사용한다
  static ValidationResult merge(List<ValidationResult> results) {
    // 하나라도 실패하면 전체가 실패다
    final isValid = results.every((result) => result.isValid);

    // 모든 에러를 하나의 맵으로 병합한다
    final Map<String, String> allErrors = {};
    for (final result in results) {
      allErrors.addAll(result.errors);
    }

    // 모든 경고를 하나의 리스트로 병합한다
    final List<String> allWarnings = [];
    for (final result in results) {
      allWarnings.addAll(result.warnings);
    }

    return ValidationResult(
      isValid: isValid,
      errors: allErrors,
      warnings: allWarnings,
    );
  }

  /// 디버깅을 위한 문자열 표현
  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: $errors, warnings: $warnings)';
  }
}
