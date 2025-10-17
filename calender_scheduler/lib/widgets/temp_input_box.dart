import 'package:flutter/material.dart';
import '../utils/temp_input_cache.dart';
import '../design_system/typography.dart' as AppTypography;

/// TempInputBox - 임시 입력 박스
/// 이거를 설정하고 → Figma 2447-60074 디자인을 정확히 구현해서
/// 이거를 해서 → 하단에 고정된 임시 입력 박스를 표시한다
/// 이거는 이래서 → 사용자가 입력만 하고 닫아도 데이터를 볼 수 있다
/// 이거라면 → 클릭 시 QuickAdd를 다시 열어 이어서 작업할 수 있다
class TempInputBox extends StatefulWidget {
  final VoidCallback? onTap; // 박스 클릭 시 콜백
  final VoidCallback? onDismiss; // 삭제 시 콜백

  const TempInputBox({Key? key, this.onTap, this.onDismiss}) : super(key: key);

  @override
  State<TempInputBox> createState() => _TempInputBoxState();
}

class _TempInputBoxState extends State<TempInputBox> {
  String? _tempText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTempInput();
  }

  /// 임시 입력 불러오기
  /// 이거를 설정하고 → 저장된 임시 입력을 불러와서
  /// 이거를 해서 → 화면에 표시한다
  Future<void> _loadTempInput() async {
    final text = await TempInputCache.getTempInput();
    setState(() {
      _tempText = text;
      _isLoading = false;
    });
  }

  /// 임시 입력 삭제
  /// 이거를 설정하고 → 저장된 임시 입력을 삭제하고
  /// 이거를 해서 → 부모 위젯에 알린다
  Future<void> _clearTempInput() async {
    await TempInputCache.clearTempInput();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → 로딩 중이거나 텍스트가 없으면 표시하지 않는다
    if (_isLoading || _tempText == null || _tempText!.isEmpty) {
      return const SizedBox.shrink();
    }

    // 이거를 설정하고 → Figma 2447-60074 디자인대로 구현해서
    // 이거를 해서 → 정확한 크기, 색상, 여백을 적용한다
    return Container(
      margin: const EdgeInsets.only(
        left: 16, // Figma: 좌측 여백 16px
        right: 16, // Figma: 우측 여백 16px
        bottom: 20, // Figma: 하단 여백 20px (네비게이션 바 위)
      ),
      decoration: BoxDecoration(
        // 이거를 설정하고 → Figma 디자인의 배경색을 적용해서
        color: const Color(0xFFF5F5F5), // Figma: #F5F5F5
        borderRadius: BorderRadius.circular(12), // Figma: cornerRadius 12px
        boxShadow: [
          // 이거를 해서 → 부드러운 그림자 효과를 추가한다
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // 이거는 이래서 → 클릭 시 QuickAdd를 다시 열 수 있다
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, // Figma: 좌우 패딩 16px
              vertical: 14, // Figma: 상하 패딩 14px
            ),
            child: Row(
              children: [
                // 좌측: 아이콘
                // 이거를 설정하고 → Figma 디자인의 아이콘을 표시해서
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0), // Figma: 아이콘 배경색
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF666666), // Figma: 아이콘 색상
                  ),
                ),

                const SizedBox(width: 12), // Figma: 아이콘-텍스트 간격 12px
                // 중앙: 텍스트
                // 이거를 해서 → 저장된 임시 입력을 표시한다
                Expanded(
                  child: Text(
                    _tempText!,
                    style: AppTypography.Typography.bodyLargeMedium.copyWith(
                      color: const Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8), // Figma: 텍스트-삭제버튼 간격 8px
                // 우측: 삭제 버튼
                // 이거라면 → 사용자가 임시 입력을 삭제할 수 있다
                IconButton(
                  onPressed: _clearTempInput,
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF999999), // Figma: 삭제 아이콘 색상
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
