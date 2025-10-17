import 'package:flutter/material.dart';
import '../const/color.dart';
import '../const/typography.dart';
import '../const/calendar_config.dart';

class ScheduleCard extends StatelessWidget {
  // schedule.dart의 필드명과 통일: start, end, summary, colorId
  final DateTime start; // startTime → start로 변경하여 schedule.dart와 통일
  final DateTime end; // endTime → end로 변경하여 schedule.dart와 통일
  final String? summary; // title → summary로 변경하여 schedule.dart와 통일
  final String?
  colorId; // color → colorId로 변경하여 schedule.dart와 통일 (String 타입으로 변경)
  //final String description;

  const ScheduleCard({
    super.key,
    required this.start, // startTime → start로 변경
    required this.end, // endTime → end로 변경
    this.summary, // title → summary로 변경 (required 제거하여 nullable로 변경)
    this.colorId, // color → colorId로 변경 (required 제거하여 nullable로 변경)
  });

  // colorId(String)를 Color로 변환하는 함수: colorId가 null이면 gray, 있으면 categoryColorMap에서 조회
  Color _getDisplayColor() {
    return categoryColorMap[colorId ?? 'gray'] ?? categoryGray;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start, // Column의 세로 정렬을 시작점으로 설정
      crossAxisAlignment: CrossAxisAlignment.start, // Column의 가로 정렬을 시작점으로 설정
      children: [
        SmoothWidgetUtils.createSmoothCard(
          // 스무딩 위젯 유틸리티를 사용해서 안전한 스무딩 카드를 생성
          height: 110, // 피그마 디자인: 고정 높이 110px
          borderRadius: 24, // 둥근 모서리 반지름을 24픽셀로 설정해서 부드러운 모양을 만듦
          backgroundColor: Colors.white, // 배경색을 흰색으로 설정해서 카드 배경을 만듦
          borderColor: const Color(
            0xFF111111,
          ).withOpacity(0.08), // 피그마: rgba(17,17,17,0.08)
          borderWidth: 1, // 테두리 두께를 1픽셀로 설정해서 얇은 경계선을 만듦
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0, // 좌우 패딩을 20픽셀로 설정해서 좌우 여백을 만듦
            vertical: 16.0, // 상하 패딩을 16픽셀로 설정해서 상하 여백을 만듦
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 4.0, // 좌우 여백 4px
          ), // 카드 좌우 여백
          child: Row(
            // 가로로 배치하기 위해 Row를 사용
            children: [
              Container(
                // 세로 선을 만들기 위한 컨테이너 (피그마: 4px)
                width: 4, // 선의 두께를 4픽셀로 설정 (피그마 디자인 기준)
                height: 70, // 선의 높이를 70픽셀로 설정
                decoration: BoxDecoration(
                  color:
                      _getDisplayColor(), // _getDisplayColor() 함수를 사용해서 colorId를 Color로 변환하여 동적 색상 설정
                ), // 선의 색상을 colorId를 Color로 변환한 값으로 설정하여 카테고리별 색상 표시
              ),

              Expanded(
                // 텍스트 영역을 Expanded로 감싸서 오버플로우를 방지하고 ShaderMask 페이드 효과를 적용
                child: Padding(
                  // 선과 제목 사이에 간격을 만들기 위해 패딩 추가
                  padding: const EdgeInsets.only(
                    left: 16.0,
                  ), // 왼쪽에만 16픽셀 패딩을 추가해서 선과 제목 사이에 간격을 만듦
                  child: ClipRect(
                    // ClipRect를 사용해서 넘어가는 텍스트를 완전히 잘라내서 숨김
                    child: ShaderMask(
                      // ShaderMask를 사용해서 텍스트 오버플로우 시 페이드 효과를 적용
                      shaderCallback: (Rect bounds) {
                        // 그라데이션 페이드 효과를 생성하는 함수
                        return LinearGradient(
                          begin: Alignment.centerLeft, // 왼쪽에서 시작
                          end: Alignment.centerRight, // 오른쪽에서 끝
                          colors: [
                            Colors.black, // 시작 부분은 완전 불투명
                            Colors.black, // 중간 부분도 완전 불투명
                            Colors.black.withOpacity(0.0), // 끝 부분은 완전 투명
                          ],
                          stops: [0.0, 0.85, 1.0], // 오른쪽 15%만 페이드 효과 적용
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn, // 투명도 적용 모드를 설정해서 페이드 효과를 만듦
                      child: Column(
                        // 제목과 시간을 세로로 배치하기 위해 Column 사용
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Column의 세로 정렬을 시작점으로 설정
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Column의 가로 정렬을 시작점으로 설정
                        children: [
                          Text(
                            summary ?? '', // title → summary로 변경하고 null 체크 추가
                            style: CalendarTypography.calendarText.copyWith(
                              fontSize: 16,
                              color: gray950,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1, // 제목을 1줄로 제한해서 오버플로우를 방지
                            softWrap: false, // 텍스트 줄바꿈을 비활성화해서 한 줄로 표시
                            overflow: TextOverflow
                                .visible, // 오버플로우를 허용해서 ShaderMask 페이드 효과가 작동하도록 함
                          ), // 일정의 제목을 표시하는 텍스트
                          SizedBox(height: 8), // 제목과 시간 사이에 8픽셀 간격을 추가
                          Row(
                            // 시작 시간과 종료 시간을 가로로 배치하기 위해 Row 사용
                            children: [
                              Text(
                                // 시작 시간을 표시하는 텍스트
                                '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}', // startTime → start로 변경하여 schedule.dart와 통일
                                style: TextStyle(
                                  fontSize: 13, // 폰트 크기를 13으로 설정
                                  color: gray950, // 텍스트 색상을 gray950으로 설정
                                  fontWeight: FontWeight
                                      .w700, // 폰트 굵기를 700으로 설정해서 굵게 표시
                                ),
                              ),
                              SizedBox(width: 8), // 시작 시간과 종료 시간 사이에 8픽셀 간격을 추가
                              Text(
                                // 종료 시간을 표시하는 텍스트
                                '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}', // endTime → end로 변경하여 schedule.dart와 통일
                                style: TextStyle(
                                  fontSize: 13, // 폰트 크기를 13으로 설정
                                  color:
                                      _getDisplayColor(), // color → _getDisplayColor()로 변경하여 colorId를 Color로 변환한 값 사용
                                  fontWeight: FontWeight
                                      .w700, // 폰트 굵기를 700으로 설정해서 굵게 표시
                                ),
                              ),
                            ],
                          ),
                        ],
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
