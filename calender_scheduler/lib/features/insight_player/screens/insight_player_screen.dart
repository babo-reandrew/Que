import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart'; // ✅ SpringSimulation 사용
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:amlv/amlv.dart';
import '../../../Database/schedule_database.dart';
import '../../../const/motion_config.dart'; // ✅ Safari 스프링 파라미터

/// Insight Player - Figma 디자인 완벽 구현
/// 📱 Figma: iPhone 16 (393px) 스펙 100% 일치
/// 🎵 amlv 패키지로 오디오 재생 + 자동 스크롤
/// 💾 DB 싱크: onLyricChanged로 재생 위치 자동 저장
/// 🚀 Pull-to-dismiss: DateDetailView와 동일한 스와이프 제스처로 닫기
class InsightPlayerScreen extends ConsumerStatefulWidget {
  final DateTime targetDate;
  final VoidCallback? onClose; // 🚀 Pull-to-dismiss 완료 시 OpenContainer 닫기 콜백

  const InsightPlayerScreen({
    super.key,
    required this.targetDate,
    this.onClose, // ✅ OpenContainer의 action()을 받아서 실제 닫기 처리
  });

  @override
  ConsumerState<InsightPlayerScreen> createState() =>
      _InsightPlayerScreenState();
}

class _InsightPlayerScreenState extends ConsumerState<InsightPlayerScreen>
    with TickerProviderStateMixin {
  int? _currentAudioContentId;

  // ✅ Pull-to-dismiss 관련 변수 (DateDetailView 기반)
  late AnimationController _dismissController; // Pull-to-dismiss 애니메이션 컨트롤러
  late AnimationController _entryController; // 진입 헤딩 모션 컨트롤러
  late Animation<double> _entryScaleAnimation; // 진입 스케일 애니메이션
  double _dragOffset = 0.0; // Pull-to-dismiss를 위한 드래그 오프셋

  @override
  void initState() {
    super.initState();

    // ✅ Pull-to-dismiss 스프링 애니메이션 컨트롤러 (unbounded)
    // Safari 스타일: 물리 기반 스프링 시뮬레이션 사용
    _dismissController = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() {
          // SpringSimulation 값이 dragOffset에 반영됨
        });
      });

    // ✅ 진입 헤딩 모션: 0.95 → 1.0 스케일로 부드럽게 확대
    // Apple 쫀득한 느낌: OpenContainer와 동일한 520ms + Emphasized curve
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520), // OpenContainer와 동기화
    );

    _entryScaleAnimation =
        Tween<double>(
          begin: 0.95, // 95% 크기로 시작
          end: 1.0, // 100% 크기로 확대
        ).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Cubic(
              0.05,
              0.7,
              0.1,
              1.0,
            ), // Material Design 3 Emphasized (쫀득한 느낌)
          ),
        );

    // 진입 애니메이션 시작
    _entryController.forward();

    // Status Bar 색상 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF566099), // Status Bar 배경색
        statusBarIconBrightness: Brightness.light, // 아이콘 밝은색
      ),
    );

    print('🎵 [InsightPlayerScreen] 초기화 완료 - 날짜: ${widget.targetDate}');
  }

  @override
  void dispose() {
    // ✅ 메모리 누수 방지를 위해 컨트롤러 정리
    _dismissController.dispose();
    _entryController.dispose();
    print('🗑️ [InsightPlayerScreen] 리소스 정리 완료');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dismissProgress = (_dragOffset / screenHeight).clamp(0.0, 1.0);
    final scale = 1.0 - (dismissProgress * 0.25); // 1.0 → 0.75
    final borderRadius = 36.0 - (dismissProgress * 24.0); // 36 → 12

    // ✅ dismissProgress에 따라 배경 투명도 조절 (뒤에 InsightButton 보이도록)
    final backgroundColor = Color.lerp(
      const Color(0xFF566099), // 100% 불투명 (정상 상태)
      const Color(0x00566099), // 100% 투명 (드래그 중)
      dismissProgress, // 0.0 ~ 1.0
    )!;

    return AnimatedBuilder(
      animation: _entryScaleAnimation,
      builder: (context, child) {
        final combinedScale = _entryScaleAnimation.value * scale;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFF566099), // Status Bar 배경색
            statusBarIconBrightness: Brightness.light, // 아이콘 밝은색
          ),
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: Transform.scale(
                  scale: combinedScale,
                  alignment: Alignment.topCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent, // ✅ BoxDecoration 안으로 이동!
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: dismissProgress > 0.0
                          ? Border.all(
                              color: const Color(0xFF111111).withOpacity(0.1),
                              width: 1,
                            )
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Scaffold(
                        backgroundColor: backgroundColor, // ✅ 동적 배경색
                        body: FutureBuilder<AudioContentData?>(
                          future: GetIt.I<AppDatabase>().getInsightForDate(
                            widget.targetDate,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data == null) {
                              return _buildEmptyState();
                            }

                            final audioContent = snapshot.data!;
                            return _buildInsightPlayer(
                              audioContent,
                              dismissProgress, // ✅ dismissProgress 전달
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ========================================
  // ✅ Pull-to-dismiss 드래그 핸들러 (DateDetailView 기반, 단순화)
  // ========================================

  void _handleDragUpdate(DragUpdateDetails details) {
    // 🎵 LyricViewer는 자동 스크롤이므로 항상 드래그 허용
    // 아래로만 끌 수 있도록 제한 (위로는 불가)
    if (details.delta.dy > 0) {
      setState(() {
        _dragOffset += details.delta.dy;
        if (_dragOffset < 0) _dragOffset = 0;
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final screenHeight = MediaQuery.of(context).size.height;
    final progress = _dragOffset / screenHeight;

    if (velocity > MotionConfig.dismissThresholdVelocity ||
        progress > MotionConfig.dismissThresholdProgress) {
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      _runSpringAnimation(velocity, screenHeight);
    }
  }

  void _runSpringAnimation(double velocity, double screenHeight) {
    const spring = SpringDescription(
      mass: MotionConfig.springMass,
      stiffness: MotionConfig.springStiffness,
      damping: MotionConfig.springDamping,
    );

    final normalizedStart = _dragOffset / screenHeight;
    final normalizedVelocity = -velocity / screenHeight;
    final simulation = SpringSimulation(
      spring,
      normalizedStart,
      0.0,
      normalizedVelocity,
    );

    _dismissController.animateWith(simulation);

    void listener() {
      if (mounted) {
        setState(() {
          _dragOffset = _dismissController.value * screenHeight;
        });
      }
    }

    _dismissController.addListener(listener);

    _dismissController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dismissController.removeListener(listener);
        if (mounted) {
          setState(() {
            _dragOffset = 0.0;
          });
        }
      }
    });
  }

  // ========================================
  // ✅ UI 빌드 메서드들
  // ========================================

  /// 비어있는 상태 (인사이트 없음)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            '이 날짜에는 인사이트가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'LINE Seed JP App_TTF',
            ),
          ),
        ],
      ),
    );
  }

  /// TranscriptLineData 리스트를 amlv의 Lyric 포맷으로 변환
  Lyric _convertToLyric(
    AudioContentData audioContent,
    List<TranscriptLineData> lines,
  ) {
    final lyricLines = lines.map((line) {
      return LyricLine(
        time: Duration(milliseconds: line.startTimeMs),
        content: line.content,
      );
    }).toList();

    return Lyric(
      title: audioContent.title,
      artist: audioContent.subtitle,
      album: null,
      duration: Duration(seconds: audioContent.durationSeconds),
      audio: AssetSource('audio/insight_001.mp3'), // assets/ 제거
      lines: lyricLines,
    );
  }

  /// Figma 디자인 기반 Insight Player 전체 UI
  Widget _buildInsightPlayer(
    AudioContentData audioContent,
    double dismissProgress, // ✅ dismissProgress 파라미터 추가
  ) {
    _currentAudioContentId = audioContent.id;

    // ✅ dismissProgress에 따라 배경색 투명도 조절
    final insightBackgroundColor = Color.lerp(
      const Color(0xFF566099), // 100% 불투명 (정상)
      const Color(0x00566099), // 100% 투명 (드래그 중)
      dismissProgress,
    )!;

    return StreamBuilder<List<TranscriptLineData>>(
      stream: GetIt.I<AppDatabase>().watchTranscriptLines(audioContent.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final lines = snapshot.data!;
        final lyric = _convertToLyric(audioContent, lines);

        return Stack(
          children: [
            // 🎨 전체 배경 (Status Bar 포함) - 동적 투명도
            Positioned.fill(
              child: Container(
                color: insightBackgroundColor, // ✅ 동적 배경색
              ),
            ),

            // 📝 amlv LyricViewer (탭바 제외)
            _buildLyricViewerArea(lyric, audioContent, insightBackgroundColor),

            // 🎨 상단 그라데이션 오버레이 (190px)
            _buildTopGradient(insightBackgroundColor),

            // 📱 탭바
            _buildHeaderWidget(audioContent, insightBackgroundColor),

            // 🎨 Top Navi 아래 그라디언트 박스 (64px) - 탭바 위에 배치
            _buildTopNaviGradient(insightBackgroundColor),
          ],
        );
      },
    );
  }

  /// 📝 amlv LyricViewer 영역 (상단 32px에서 시작)
  Widget _buildLyricViewerArea(
    Lyric lyric,
    AudioContentData audioContent,
    Color insightBackgroundColor, // ✅ 동적 배경색
  ) {
    return Positioned(
      top: 32, // 상단 32px에서 시작
      left: 0,
      right: 0,
      bottom: 0,
      child: LyricViewer(
        lyric: lyric,
        activeColor: const Color(0xFFFFFFFF), // Figma: #FFFFFF (활성화 라인)
        inactiveColor: const Color(
          0xFFFFFFFF,
        ).withOpacity(0.3), // Figma: #FFFFFF 30% (비활성화)
        gradientColor1: insightBackgroundColor, // ✅ 동적 배경색
        gradientColor2: insightBackgroundColor, // ✅ 동적 배경색
        // Figma TextStyle 적용
        activeTextStyle: const TextStyle(
          fontFamily: 'LINE Seed JP App_TTF',
          fontSize: 18, // Figma: 18px
          fontWeight: FontWeight.w700, // Figma: 700 (정확한 weight)
          height: 1.65, // Figma: 165% line-height
          letterSpacing: -0.005 * 18, // Figma: -0.005em
          color: Color(0xFFFFFFFF), // Figma: #FFFFFF
        ),
        inactiveTextStyle: TextStyle(
          fontFamily: 'LINE Seed JP App_TTF',
          fontSize: 18, // Figma: 18px
          fontWeight: FontWeight.w700, // Figma: 700 (정확한 weight)
          height: 1.65, // Figma: 165% line-height
          letterSpacing: -0.005 * 18, // Figma: -0.005em
          color: const Color(0xFFFFFFFF).withOpacity(0.3), // Figma: #FFFFFF 30%
        ),
        // headerWidget 제거 - 더 이상 필요 없음
        onLyricChanged: (LyricLine line, String source) async {
          final positionMs = line.time.inMilliseconds;
          print('💾 [DB] 재생 위치 저장: ${positionMs}ms');

          if (_currentAudioContentId != null) {
            await GetIt.I<AppDatabase>().updateAudioProgress(
              _currentAudioContentId!,
              positionMs,
            );
          }
        },
        onCompleted: () async {
          print('✅ [amlv] 재생 완료');
          if (_currentAudioContentId != null) {
            await GetIt.I<AppDatabase>().markInsightAsCompleted(
              _currentAudioContentId!,
            );
          }
        },
      ),
    );
  }

  /// 📱 헤더 위젯 (탭바) - 최상위 레이어
  Widget _buildHeaderWidget(
    AudioContentData audioContent,
    Color insightBackgroundColor, // ✅ 동적 배경색
  ) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          const SizedBox(height: 64), // Status bar 영역
          Container(
            height: 57, // Figma: height 57px
            color: insightBackgroundColor, // ✅ 동적 배경색
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 📝 제목 영역
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 서브 타이틀 (위로 이동)
                      Text(
                        audioContent.subtitle,
                        style: const TextStyle(
                          fontFamily: 'LINE Seed JP App_TTF',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.4,
                          letterSpacing: -0.005 * 12,
                          color: Color(0xFFCFCFCF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 메인 타이틀 (아래로 이동)
                      Text(
                        audioContent.title,
                        style: const TextStyle(
                          fontFamily: 'LINE Seed JP App_TTF',
                          fontWeight: FontWeight.bold, // w800 → bold
                          fontSize: 14,
                          height: 1.4,
                          letterSpacing: -0.005 * 14,
                          color: Color(0xFFE4E4E4),
                        ),
                      ),
                    ],
                  ),

                  // ⬇️ 닫기 버튼
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E4E4).withOpacity(0.2),
                        border: Border.all(
                          color: const Color(0xFF111111).withOpacity(0.02),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBABABA).withOpacity(0.08),
                            offset: const Offset(0, -2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: Color(0xFFE4E4E4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 상단 그라데이션 (0~50px 투명, 그 위는 단일 색상)
  Widget _buildTopGradient(Color insightBackgroundColor) {
    // ✅ 그라데이션용 완전 투명 색상
    final transparentColor = insightBackgroundColor.withOpacity(0.0);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 190, // Figma: height 190px
      child: Column(
        children: [
          // 상단 140px: 단일 색상 (동적 배경색)
          Container(height: 140, color: insightBackgroundColor),
          // 하단 50px: 그라데이션 (투명으로)
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  insightBackgroundColor, // ✅ 동적 배경색에서 시작
                  transparentColor, // ✅ 동적 투명으로
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Top Navi 아래 그라디언트 박스 (Figma: 64px, 100%→0% #566099)
  Widget _buildTopNaviGradient(Color insightBackgroundColor) {
    // ✅ 그라데이션용 완전 투명 색상
    final transparentColor = insightBackgroundColor.withOpacity(0.0);

    return Positioned(
      top: 121, // Top Navi 아래 (64px + 57px = 121px)
      left: 0,
      right: 0,
      height: 64, // Figma: 64px
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              insightBackgroundColor, // ✅ 동적 배경색 100%
              transparentColor, // ✅ 동적 투명 0%
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
