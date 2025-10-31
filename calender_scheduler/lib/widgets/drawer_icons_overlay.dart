import 'package:flutter/material.dart';

/// Inbox 모드에서 하단에 나타나는 서랍 아이콘 오버레이 위젯
/// 이거를 설정하고 → 피그마 디자인(Frame 850)을 정확히 구현해서
/// 이거를 해서 → 280px 흰색 바 + 64px 추가 버튼을 표시하고
/// 이거는 이래서 → 사용자에게 일관된 디자인 경험을 제공한다
///
/// 피그마 스펙:
/// - 전체 컨테이너: 352px × 64px
/// - 메인 바: 280px × 64px (흰색, border-radius: 100px)
/// - 아이콘: 각 56×56px, gap: 20px
/// - 레이블: 9px Bold, letter-spacing: -0.005em
/// - 추가 버튼: 64×64px 원형 (흰색)
class DrawerIconsOverlay extends StatefulWidget {
  /// 아이콘 클릭 시 실행될 콜백 함수들
  final VoidCallback? onScheduleTap;
  final VoidCallback? onTaskTap;
  final VoidCallback? onRoutineTap;
  final VoidCallback? onAddTap;

  const DrawerIconsOverlay({
    super.key,
    this.onScheduleTap,
    this.onTaskTap,
    this.onRoutineTap,
    this.onAddTap,
  });

  @override
  State<DrawerIconsOverlay> createState() => _DrawerIconsOverlayState();
}

class _DrawerIconsOverlayState extends State<DrawerIconsOverlay>
    with TickerProviderStateMixin {
  late AnimationController _containerController;
  late AnimationController _addButtonController;
  late List<AnimationController> _iconControllers;

  late Animation<double> _containerScaleAnimation;
  late Animation<double> _containerOpacityAnimation;
  late Animation<double> _addButtonScaleAnimation;
  late List<Animation<double>> _iconScaleAnimations;
  late List<Animation<double>> _iconOpacityAnimations;

  /// 3개의 메인 아이콘 데이터 (스케줄, 태스크, 루틴)
  final List<IconData> _mainIcons = [
    Icons.calendar_today_outlined,
    Icons.check_box_outlined,
    Icons.refresh,
  ];

  final List<String> _mainLabels = [
    'スケジュール', // 스케줄
    'タスク', // 태스크
    'ルーティン', // 루틴
  ];

  @override
  void initState() {
    super.initState();

    // 메인 컨테이너 애니메이션
    _containerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _containerScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _containerController, curve: Curves.elasticOut),
    );

    _containerOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _containerController, curve: Curves.easeOut),
    );

    // 추가 버튼 애니메이션
    _addButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _addButtonScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _addButtonController, curve: Curves.elasticOut),
    );

    // 각 아이콘 애니메이션
    _iconControllers = List.generate(
      _mainIcons.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _iconScaleAnimations = _iconControllers
        .map(
          (controller) => Tween<double>(
            begin: 0.5,
            end: 1.0,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    _iconOpacityAnimations = _iconControllers
        .map(
          (controller) => Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    _startAnimations();
  }

  void _startAnimations() {

    // 1. 메인 컨테이너 등장
    _containerController.forward();

    // 2. 추가 버튼 등장
    _addButtonController.forward();

    // 3. 아이콘들 순차 등장
    Future.delayed(const Duration(milliseconds: 200), () {
      for (int i = 0; i < _iconControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 50), () {
          if (mounted) {
            _iconControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _containerController.dispose();
    _addButtonController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 352, // 피그마: Frame 850 width
      height: 64, // 피그마: Frame 850 height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 메인 바 (280px, 흰색)
          AnimatedBuilder(
            animation: Listenable.merge([
              _containerScaleAnimation,
              _containerOpacityAnimation,
            ]),
            builder: (context, child) {
              return Opacity(
                opacity: _containerOpacityAnimation.value,
                child: Transform.scale(
                  scale: _containerScaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildMainBar(),
          ),

          const SizedBox(width: 8), // 피그마: gap 8px
          // 추가 버튼 (64px, 흰색 원형)
          AnimatedBuilder(
            animation: _addButtonScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _addButtonScaleAnimation.value,
                child: child,
              );
            },
            child: _buildAddButton(),
          ),
        ],
      ),
    ); // SizedBox 닫기
  }

  /// 메인 바 (280px × 64px, 흰색)
  Widget _buildMainBar() {
    return Container(
      width: 280,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(
          color: const Color(0xFF111111).withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA5A5A5).withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          _mainIcons.length,
          (index) => _buildIconColumn(index),
        ),
      ),
    );
  }

  /// 개별 아이콘 컬럼 (56px × 56px)
  Widget _buildIconColumn(int index) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _iconScaleAnimations[index],
        _iconOpacityAnimations[index],
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _iconOpacityAnimations[index].value,
          child: Transform.scale(
            scale: _iconScaleAnimations[index].value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _handleIconTap(index),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_mainIcons[index], size: 24, color: const Color(0xFF262626)),
              const SizedBox(height: 4),
              Text(
                _mainLabels[index],
                style: const TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF262626),
                  letterSpacing: -0.045,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 추가 버튼 (64px × 64px, 흰색 원형)
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        widget.onAddTap?.call();
      },
      child: Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(
            color: const Color(0xFF111111).withOpacity(0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBABABA).withOpacity(0.08),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 24, color: Color(0xFF111111)),
      ),
    );
  }

  void _handleIconTap(int index) {

    switch (index) {
      case 0:
        widget.onScheduleTap?.call();
        break;
      case 1:
        widget.onTaskTap?.call();
        break;
      case 2:
        widget.onRoutineTap?.call();
        break;
    }
  }
}
