import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'dart:convert';
import '../const/color.dart';
import '../const/typography.dart';

class ScheduleCard extends StatelessWidget {
  // schedule.dart의 필드명과 통일: start, end, summary, colorId, repeatRule, alertSetting
  final DateTime start;
  final DateTime end;
  final String? summary;
  final String? colorId;
  final String? repeatRule; // 반복 규칙 (JSON 문자열)
  final String? alertSetting; // 알림 설정 (JSON 문자열)

  const ScheduleCard({
    super.key,
    required this.start,
    required this.end,
    this.summary,
    this.colorId,
    this.repeatRule,
    this.alertSetting,
  });

  // colorId(String)를 Color로 변환하는 함수
  Color _getDisplayColor() {
    return categoryColorMap[colorId ?? 'gray'] ?? categoryGray;
  }

  // 시간 포맷: "17時 - 18時" 형식
  String _formatTime(DateTime time) {
    return '${time.hour}時';
  }

  // 알림 텍스트 파싱: JSON → "10分前" 형식
  String? _parseAlertText() {
    if (alertSetting == null || alertSetting!.isEmpty) return null;
    try {
      final data = jsonDecode(alertSetting!);
      if (data is Map && data.containsKey('display')) {
        return data['display'];
      }
      if (data is Map && data.containsKey('value')) {
        return data['value'];
      }
    } catch (e) {
      // JSON 파싱 실패 시 null 반환
    }
    return null;
  }

  // 반복 텍스트 파싱: JSON → "月火水木" 형식
  String? _parseRepeatText() {
    if (repeatRule == null || repeatRule!.isEmpty) return null;
    try {
      final data = jsonDecode(repeatRule!);
      if (data is Map && data.containsKey('display')) {
        return data['display'];
      }
      if (data is Map && data.containsKey('value')) {
        return data['value'];
      }
    } catch (e) {
      // JSON 파싱 실패 시 null 반환
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final alertText = _parseAlertText();
    final repeatText = _parseRepeatText();

    // 컨텐츠 높이 계산
    // - 제목: 16px * 1.2 (line height) * 최대2줄 = 최대 38.4px
    // - 간격1: 8px
    // - 시간: 13px * 1.2 = 15.6px
    // - 간격2: 10px
    // - 옵션: (있으면) 16px (아이콘 높이)
    // - 상하 패딩: 16px * 2 = 32px
    // - 추가 여유: 2px
    // 하지만 실제 텍스트 높이는 동적이므로 LayoutBuilder 사용

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 345, // Figma: 고정 너비
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 24,
                cornerSmoothing: 0.7, // Figma smoothing 70%
              ),
              side: BorderSide(
                color: const Color(0xFF111111).withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          child: Stack(
            children: [
              // 메인 컨텐츠
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  48,
                  16,
                ), // Figma: left 20, right 48, top/bottom 16
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 좌측 컬러 라인 - 컨텐츠 높이 + 상하 패딩 32px + 여유 2px
                      Container(
                        width: 4,
                        margin: const EdgeInsets.only(
                          top: 1,
                          bottom: 1,
                        ), // +2px 여유 (상하 각 1px)
                        decoration: BoxDecoration(
                          color: _getDisplayColor(),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 텍스트 영역
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목
                            Text(
                              summary ?? '',
                              style: CalendarTypography.calendarText.copyWith(
                                fontSize: 16,
                                color: gray950,
                                fontWeight: FontWeight.w800, // extrabold
                                height: 1.4, // 행간 140%
                              ),
                              maxLines: 2, // 최대 2줄
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // 시간
                            Row(
                              children: [
                                Text(
                                  _formatTime(start),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: gray950,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'LINESeedJP',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: gray950,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(end),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _getDisplayColor(),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'LINESeedJP',
                                  ),
                                ),
                              ],
                            ),
                            if (alertText != null || repeatText != null) ...[
                              const SizedBox(height: 8), // 위 여백 8px
                              // 옵션 행 (알림, 반복) - 제목, 시간과 같은 좌측 시작점에 정렬
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 6,
                                ), // 하단 여백 14px - 이미 있는 8px = 6px 추가
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 알림
                                    if (alertText != null) ...[
                                      SvgPicture.asset(
                                        'asset/icon/remind_icon.svg',
                                        width: 16,
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                          gray950.withOpacity(0.4),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        alertText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: gray950.withOpacity(0.4),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'LINESeedJP',
                                        ),
                                      ),
                                      if (repeatText != null)
                                        const SizedBox(width: 12),
                                    ],
                                    // 반복
                                    if (repeatText != null) ...[
                                      SvgPicture.asset(
                                        'asset/icon/repeat_icon.svg',
                                        width: 16,
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                          gray950.withOpacity(0.4),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        repeatText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: gray950.withOpacity(0.4),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'LINESeedJP',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 우측 중앙 드래그 아이콘 - 카드의 수직 중앙에 위치
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SvgPicture.asset(
                      'asset/icon/drag_menu_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFF0F0F0), // #F0F0F0
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
