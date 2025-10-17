import 'package:flutter/material.dart';
import '../const/color.dart';

class CustomFillField extends StatelessWidget {
  final String label;
  final FormFieldSetter<String>?
  onSaved; // Schedule 모델의 특정 필드에 값을 저장하기 위한 콜백 함수
  final FormFieldValidator<String>? validator; // 입력값 유효성 검사를 위한 콜백 함수
  final String? initialValue; // 초기값 설정을 위한 필드

  const CustomFillField({
    super.key,
    required this.label,
    this.validator,
    this.onSaved,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: gray950,
            fontWeight: FontWeight.w900,
          ),
        ),
        TextFormField(
          initialValue: initialValue, // 초기값을 설정해서 폼이 로드될 때 미리 채워진 값을 표시한다
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: gray300,
          ),
          onSaved: onSaved, // 폼이 저장될 때 호출되는 콜백으로 Schedule 모델의 특정 필드에 값을 저장한다
          validator: validator, // 입력값이 유효한지 검사하는 콜백으로 빈 값이나 잘못된 형식을 체크한다
        ),
      ],
    );
  }
}
