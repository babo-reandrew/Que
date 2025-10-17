# 바텀시트 상태 진단 및 wolt_modal_sheet 0.11.0 적용 방안

## 📊 현재 바텀시트 상태 진단

### 🔍 바텀시트 구조 분석

#### 1. **CreateEntryBottomSheet** (메인 바텀시트)
- **복잡도**: ⭐⭐⭐⭐⭐ (매우 복잡)
- **상태 변수**: 15개 이상의 상태 변수
- **책임**: 폼 검증, 저장, UI 렌더링, 애니메이션, 캐시 관리
- **문제점**: 
  - 너무 많은 책임을 가진 거대한 클래스
  - Quick Add 모드와 Legacy Form 모드가 혼재
  - 애니메이션 컨트롤러가 있지만 실제로는 사용되지 않음 (begin: 500.0, end: 500.0)

#### 2. **FullScheduleBottomSheet** (상세 일정 바텀시트)
- **복잡도**: ⭐⭐⭐⭐ (복잡)
- **상태 변수**: 10개 이상의 상태 변수
- **문제점**:
  - CreateEntryBottomSheet와 유사한 복잡한 상태 관리
  - 애니메이션 컨트롤러가 있지만 사용 여부 불분명

#### 3. **FullTaskBottomSheet** (상세 할일 바텀시트)
- **복잡도**: ⭐⭐⭐⭐ (복잡)
- **상태 변수**: 8개 이상의 상태 변수
- **문제점**: FullScheduleBottomSheet와 거의 동일한 구조

#### 4. **RepeatOptionBottomSheet** (반복 설정 모달)
- **복잡도**: ⭐⭐⭐ (보통)
- **상태 변수**: 4개의 상태 변수
- **문제점**: TODO가 남아있음 (initialRepeatRule 파싱 미완성)

#### 5. **ReminderOptionBottomSheet** (리마인더 설정 모달)
- **복잡도**: ⭐⭐ (단순)
- **상태 변수**: 1개의 상태 변수
- **문제점**: TODO가 남아있음 (initialReminder 파싱 미완성)

### 🚨 주요 문제점들

#### 1. **아키텍처 문제**
- **단일 책임 원칙 위반**: CreateEntryBottomSheet가 너무 많은 책임을 가짐
- **의존성 복잡성**: 각 바텀시트가 독립적으로 구현되어 의존성 관리 어려움
- **코드 중복**: 색상 선택, 반복/리마인더 설정이 여러 곳에 중복

#### 2. **디자인 일관성 부족**
- **스타일 불일치**: 각 바텀시트마다 다른 컨테이너 스타일, 색상, 패딩
- **레이아웃 차이**: 일부는 고정 높이, 일부는 동적 높이
- **애니메이션 불일치**: 일부는 AnimationController 사용, 일부는 사용 안함

#### 3. **상태 관리 복잡성**
- **분산된 상태**: 각 바텀시트마다 독립적인 상태 관리
- **상태 동기화 문제**: 바텀시트 간 상태 공유가 어려움
- **메모리 누수 위험**: 많은 상태 변수로 인한 메모리 관리 어려움

#### 4. **미완성 기능**
- **TODO 미완성**: initialRepeatRule, initialReminder 파싱 로직 미완성
- **에러 처리 부족**: 일관된 에러 처리 방식 부재
- **접근성 부족**: 키보드 네비게이션, 스크린 리더 지원 부족

## 🎯 wolt_modal_sheet 0.11.0 적용 방안

### 📦 wolt_modal_sheet 0.11.0 핵심 기능

#### 1. **다양한 페이지 유형 지원**
```dart
// 1. SliverWoltModalSheetPage - 스크롤 가능한 리스트/그리드
SliverWoltModalSheetPage(
  mainContentSliversBuilder: (context) => [
    SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return ListTile(title: Text('Item $index'));
      }),
    ),
  ],
  pageTitle: Text('반복 설정'),
  heroImage: Image.asset('assets/repeat_icon.png'),
)

// 2. WoltModalSheetPage - 간단한 위젯
WoltModalSheetPage(
  child: ColorPickerWidget(),
  pageTitle: Text('색상 선택'),
  isTopBarVisible: true,
)

// 3. NonScrollingWoltModalSheetPage - 유동적 높이
NonScrollingWoltModalSheetPage(
  child: HabitInputForm(),
  pageTitle: Text('습관 추가'),
)
```

#### 2. **모달 내 동적 네비게이션**
```dart
// 페이지 추가
WoltModalSheet.of(context).addPages([
  RepeatOptionPage(),
  ReminderOptionPage(),
]);

// 현재 페이지 교체
WoltModalSheet.of(context).replaceCurrentPage(
  ColorPickerPage()
);

// 특정 페이지 제거
WoltModalSheet.of(context).removePage('repeat-page');
```

#### 3. **고급 애니메이션 커스터마이징**
```dart
WoltModalSheetThemeData(
  animationStyle: WoltModalSheetAnimationStyle(
    paginationAnimationStyle: WoltModalSheetPaginationAnimationStyle(
      paginationDuration: Duration(milliseconds: 250),
      paginationCurve: Curves.easeInOut,
    ),
    scrollAnimationStyle: WoltModalSheetScrollAnimationStyle(
      heroImageScaleStart: 1.0,
      heroImageScaleEnd: 0.9,
      scrollAnimationDuration: Duration(milliseconds: 300),
    ),
  ),
)
```

#### 4. **제스처 기반 인터랙션**
- 드래그로 닫기 기능
- 스와이프 네비게이션
- 키보드 높이 자동 조정
- 백드롭 탭으로 닫기

### 🏗️ 구체적인 리팩토링 전략

#### 1. **현재 바텀시트별 wolt_modal_sheet 적용 방안**

##### CreateEntryBottomSheet → WoltModalSheetPage
```dart
// 기존 복잡한 구조
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => CreateEntryBottomSheet(...),
);

// wolt_modal_sheet 적용
WoltModalSheet.show(
  context: context,
  pageListBuilder: (context) => [
    WoltModalSheetPage(
      child: QuickAddMode(), // Quick Add 모드
      pageTitle: Text('빠른 추가'),
      isTopBarVisible: true,
      heroImage: Image.asset('assets/quick_add_icon.png'),
    ),
    NonScrollingWoltModalSheetPage(
      child: HabitInputMode(), // 습관 입력 모드
      pageTitle: Text('습관 추가'),
      isTopBarVisible: true,
    ),
  ],
  onModalDismissedWithBarrierTap: () {
    // 모달 닫기 처리
  },
);
```

##### RepeatOptionBottomSheet → SliverWoltModalSheetPage
```dart
// 기존
showModalBottomSheet(
  context: context,
  builder: (context) => RepeatOptionBottomSheet(...),
);

// wolt_modal_sheet 적용
WoltModalSheet.show(
  context: context,
  pageListBuilder: (context) => [
    SliverWoltModalSheetPage(
      mainContentSliversBuilder: (context) => [
        SliverToBoxAdapter(
          child: _buildModeSelector(), // 매일/매월/간격 토글
        ),
        SliverToBoxAdapter(
          child: _buildModeContent(), // 선택된 모드 컨텐츠
        ),
      ],
      pageTitle: Text('반복 설정'),
      heroImage: Image.asset('assets/repeat_icon.png'),
      isTopBarVisible: true,
    ),
  ],
);
```

##### ReminderOptionBottomSheet → SliverWoltModalSheetPage
```dart
WoltModalSheet.show(
  context: context,
  pageListBuilder: (context) => [
    SliverWoltModalSheetPage(
      mainContentSliversBuilder: (context) => [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildReminderItem(index),
            childCount: _reminderOptions.length,
          ),
        ),
      ],
      pageTitle: Text('리마인더 설정'),
      heroImage: Image.asset('assets/reminder_icon.png'),
    ),
  ],
);
```

#### 2. **통합된 디자인 시스템 구축**

##### 공통 테마 정의
```dart
class WoltDesignSystem {
  static final WoltModalSheetThemeData theme = WoltModalSheetThemeData(
    // 색상 시스템
    primaryColor: const Color(0xFF111111),
    secondaryColor: const Color(0xFFF7F7F7),
    backgroundColor: const Color(0xFFFCFCFC),
    surfaceColor: const Color(0xFFFFFFFF),
    
    // 타이포그래피
    titleTextStyle: const TextStyle(
      fontFamily: 'LINE Seed JP App_TTF',
      fontSize: 19,
      fontWeight: FontWeight.w700,
      color: Color(0xFF111111),
    ),
    
    // 간격 시스템
    pagePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    topBarHeight: 54.0,
    
    // 애니메이션
    animationStyle: WoltModalSheetAnimationStyle(
      paginationAnimationStyle: WoltModalSheetPaginationAnimationStyle(
        paginationDuration: Duration(milliseconds: 250),
        paginationCurve: Curves.easeInOut,
      ),
      scrollAnimationStyle: WoltModalSheetScrollAnimationStyle(
        heroImageScaleStart: 1.0,
        heroImageScaleEnd: 0.9,
        scrollAnimationDuration: Duration(milliseconds: 300),
      ),
    ),
  );
}
```

#### 3. **상태 관리 개선 - Provider 패턴**

##### 중앙화된 상태 관리
```dart
// 1. 바텀시트 상태 관리
class BottomSheetController extends ChangeNotifier {
  String? _selectedColor = 'gray';
  String? _repeatRule = '';
  String? _reminder = '';
  QuickAddType? _selectedType;
  
  // Getters
  String? get selectedColor => _selectedColor;
  String? get repeatRule => _repeatRule;
  String? get reminder => _reminder;
  QuickAddType? get selectedType => _selectedType;
  
  // Actions
  void updateColor(String color) {
    _selectedColor = color;
    notifyListeners();
  }
  
  void updateRepeatRule(String rule) {
    _repeatRule = rule;
    notifyListeners();
  }
  
  void updateReminder(String reminder) {
    _reminder = reminder;
    notifyListeners();
  }
  
  void updateType(QuickAddType type) {
    _selectedType = type;
    notifyListeners();
  }
  
  void reset() {
    _selectedColor = 'gray';
    _repeatRule = '';
    _reminder = '';
    _selectedType = null;
    notifyListeners();
  }
}

// 2. Provider 설정
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomSheetController()),
      ],
      child: MaterialApp(...),
    );
  }
}
```

#### 4. **재사용 가능한 컴포넌트 분리**

##### 공통 헤더 컴포넌트
```dart
class WoltBottomSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  final Widget? heroImage;
  
  const WoltBottomSheetHeader({
    required this.title,
    this.onClose,
    this.heroImage,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: WoltDesignSystem.theme.titleTextStyle),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(0xFFE4E4E4).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(Icons.close, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
```

##### 통합 옵션 아이콘 컴포넌트
```dart
class WoltOptionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  
  const WoltOptionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF111111) : Color(0xFFF7F7F7),
          border: Border.all(
            color: Color(0xFF111111).withOpacity(0.08),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? Colors.white : Color(0xFF111111),
        ),
      ),
    );
  }
}
```

##### 통합 색상 선택기
```dart
class WoltColorPicker extends StatelessWidget {
  final String selectedColor;
  final Function(String) onColorSelected;
  
  const WoltColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return SliverWoltModalSheetPage(
      mainContentSliversBuilder: (context) => [
        SliverToBoxAdapter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: categoryColors.length,
            itemBuilder: (context, index) {
              final color = categoryColors[index];
              final colorName = ColorUtils.colorToString(color);
              final isSelected = colorName == selectedColor;
              
              return GestureDetector(
                onTap: () => onColorSelected(colorName),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Color(0xFF111111) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
      pageTitle: Text('색상 선택'),
      heroImage: Image.asset('assets/color_icon.png'),
    );
  }
}
```

#### 5. **실제 사용 예시 - 통합된 바텀시트 플로우**

##### 메인 바텀시트에서 옵션 모달 호출
```dart
class MainBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BottomSheetController>(
      builder: (context, controller, child) {
        return WoltModalSheetPage(
          child: Column(
            children: [
              // Quick Add 입력 필드
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '새로운 일정을 추가하세요',
                ),
              ),
              
              SizedBox(height: 24),
              
              // 옵션 아이콘들
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WoltOptionIcon(
                    icon: Icons.refresh,
                    label: '반복',
                    onTap: () => _showRepeatModal(context),
                  ),
                  SizedBox(width: 8),
                  WoltOptionIcon(
                    icon: Icons.notifications_outlined,
                    label: '리마인더',
                    onTap: () => _showReminderModal(context),
                  ),
                  SizedBox(width: 8),
                  WoltOptionIcon(
                    icon: Icons.palette_outlined,
                    label: '색상',
                    onTap: () => _showColorModal(context),
                  ),
                ],
              ),
            ],
          ),
          pageTitle: Text('빠른 추가'),
          isTopBarVisible: true,
        );
      },
    );
  }
  
  void _showRepeatModal(BuildContext context) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        SliverWoltModalSheetPage(
          mainContentSliversBuilder: (context) => [
            SliverToBoxAdapter(
              child: _buildModeSelector(),
            ),
            SliverToBoxAdapter(
              child: _buildModeContent(),
            ),
          ],
          pageTitle: Text('반복 설정'),
          heroImage: Image.asset('assets/repeat_icon.png'),
        ),
      ],
    );
  }
  
  void _showColorModal(BuildContext context) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltColorPicker(
          selectedColor: context.read<BottomSheetController>().selectedColor ?? 'gray',
          onColorSelected: (color) {
            context.read<BottomSheetController>().updateColor(color);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
```

#### 6. **성능 최적화 및 접근성 개선**

##### 메모리 효율적인 리스트 구현
```dart
class OptimizedReminderList extends StatelessWidget {
  final List<ReminderOption> options;
  final String selectedReminder;
  final Function(String) onSelected;
  
  @override
  Widget build(BuildContext context) {
    return SliverWoltModalSheetPage(
      mainContentSliversBuilder: (context) => [
        SliverList.builder(
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = option.value == selectedReminder;
            
            return ListTile(
              title: Text(option.label),
              trailing: isSelected ? Icon(Icons.check) : null,
              onTap: () => onSelected(option.value),
              // 접근성 개선
              semanticLabel: '${option.label} ${isSelected ? '선택됨' : '선택 가능'}',
            );
          },
        ),
      ],
      pageTitle: Text('리마인더 설정'),
      heroImage: Image.asset('assets/reminder_icon.png'),
    );
  }
}
```

##### 키보드 높이 자동 조정
```dart
class KeyboardAwareBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final hasKeyboard = keyboardHeight > 0;
        
        return WoltModalSheetPage(
          child: Column(
            children: [
              if (hasKeyboard) SizedBox(height: keyboardHeight * 0.1),
              // 키보드가 있을 때 여백 조정
              YourContentWidget(),
            ],
          ),
          pageTitle: Text('입력'),
          isTopBarVisible: !hasKeyboard, // 키보드가 있을 때 헤더 숨김
        );
      },
    );
  }
}
```

### 🔧 구체적인 개선 방안

#### 1. **CreateEntryBottomSheet 리팩토링**

##### 현재 문제점
- 15개 이상의 상태 변수
- Quick Add 모드와 Legacy Form 모드 혼재
- 복잡한 조건부 렌더링

##### 개선 방안
```dart
// 1. 모드별 분리
class QuickAddBottomSheet extends StatelessWidget { ... }
class LegacyFormBottomSheet extends StatelessWidget { ... }

// 2. 상태 관리 분리
class BottomSheetController extends ChangeNotifier {
  // 상태 로직만 관리
}

// 3. UI 컴포넌트 분리
class QuickAddInput extends StatelessWidget { ... }
class HabitInput extends StatelessWidget { ... }
```

#### 2. **공통 모달 통일**

##### 현재 문제점
- RepeatOptionBottomSheet와 ReminderOptionBottomSheet가 각각 독립적
- TODO 미완성 상태

##### 개선 방안
```dart
// 통합된 옵션 설정 모달
class WoltOptionModal extends StatelessWidget {
  final OptionType type; // repeat, reminder, color
  final String? initialValue;
  final Function(String) onSave;
  
  // 타입에 따른 동적 UI 렌더링
}
```

#### 3. **디자인 시스템 구축**

##### 공통 디자인 토큰
```dart
class WoltDesignTokens {
  static const Color primaryColor = Color(0xFF111111);
  static const Color secondaryColor = Color(0xFFF7F7F7);
  static const Color backgroundColor = Color(0xFFFCFCFC);
  
  static const double borderRadius = 36.0;
  static const double optionIconSize = 64.0;
  static const double headerHeight = 54.0;
  
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 19,
    fontWeight: FontWeight.w700,
  );
}
```

### 📋 구체적인 마이그레이션 로드맵

#### Phase 1: 기반 구축 (1-2주)
```dart
// 1. 패키지 추가
dependencies:
  wolt_modal_sheet: ^0.11.0
  provider: ^6.0.0

// 2. 기본 테마 설정
class WoltDesignSystem {
  static final theme = WoltModalSheetThemeData(
    primaryColor: Color(0xFF111111),
    // ... 기타 설정
  );
}

// 3. Provider 설정
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomSheetController()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          extensions: [WoltDesignSystem.theme],
        ),
        home: MyHomePage(),
      ),
    );
  }
}
```

#### Phase 2: 단순 모달부터 시작 (1주)
```dart
// 1. ReminderOptionBottomSheet 먼저 마이그레이션
// 기존: showModalBottomSheet
// 신규: WoltModalSheet.show

// 2. 기본 컴포넌트 생성
class WoltBottomSheetHeader extends StatelessWidget { ... }
class WoltOptionIcon extends StatelessWidget { ... }

// 3. 테스트 및 검증
// - 애니메이션 동작 확인
// - 제스처 인터랙션 테스트
// - 접근성 검증
```

#### Phase 3: 복잡한 모달 마이그레이션 (2주)
```dart
// 1. RepeatOptionBottomSheet 마이그레이션
// SliverWoltModalSheetPage 사용
// 스크롤 가능한 요일/날짜 선택기

// 2. CreateEntryBottomSheet 분리
// QuickAddMode, HabitInputMode로 분리
// 각각 다른 WoltModalSheetPage로 구현

// 3. 상태 관리 통합
// Provider를 사용한 중앙화된 상태 관리
// 바텀시트 간 데이터 공유
```

#### Phase 4: 고급 기능 구현 (1-2주)
```dart
// 1. 동적 네비게이션 구현
WoltModalSheet.of(context).addPages([
  ColorPickerPage(),
  RepeatOptionPage(),
]);

// 2. 커스텀 애니메이션 적용
WoltModalSheetThemeData(
  animationStyle: WoltModalSheetAnimationStyle(
    // 커스텀 애니메이션 설정
  ),
)

// 3. 성능 최적화
// SliverList.builder 사용
// 메모리 효율적인 리스트 구현
```

#### Phase 5: 최종 통합 및 테스트 (1주)
```dart
// 1. 모든 바텀시트 통합 테스트
// 2. 사용자 시나리오 테스트
// 3. 성능 벤치마크
// 4. 접근성 검증
// 5. 문서화 및 가이드 작성
```

### 🧪 테스트 전략

#### 1. **단위 테스트**
```dart
// 컴포넌트별 테스트
testWidgets('WoltOptionIcon should display correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WoltOptionIcon(
        icon: Icons.refresh,
        label: '반복',
        onTap: () {},
      ),
    ),
  );
  
  expect(find.byIcon(Icons.refresh), findsOneWidget);
  expect(find.text('반복'), findsOneWidget);
});

// 상태 관리 테스트
test('BottomSheetController should update color correctly', () {
  final controller = BottomSheetController();
  controller.updateColor('blue');
  expect(controller.selectedColor, 'blue');
});
```

#### 2. **통합 테스트**
```dart
// 바텀시트 플로우 테스트
testWidgets('Complete bottom sheet flow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 1. 바텀시트 열기
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // 2. 옵션 선택
  await tester.tap(find.byIcon(Icons.refresh));
  await tester.pumpAndSettle();
  
  // 3. 설정 완료
  await tester.tap(find.text('완료'));
  await tester.pumpAndSettle();
  
  // 4. 결과 검증
  expect(find.byType(WoltModalSheet), findsNothing);
});
```

#### 3. **성능 테스트**
```dart
// 메모리 사용량 모니터링
test('Memory usage should be optimized', () async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  
  // 바텀시트 열기/닫기 반복
  for (int i = 0; i < 100; i++) {
    await tester.pumpWidget(MyApp());
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  }
  
  // 메모리 사용량 확인
  expect(binding.memoryAccessor.memoryUsage, lessThan(100 * 1024 * 1024));
});
```

### 📊 성공 지표

#### 1. **개발 효율성**
- [ ] 코드 중복률 70% 감소
- [ ] 새 바텀시트 개발 시간 50% 단축
- [ ] 버그 발생률 60% 감소

#### 2. **사용자 경험**
- [ ] 바텀시트 열기 속도 200ms 이하
- [ ] 애니메이션 프레임 드롭 0%
- [ ] 접근성 점수 90점 이상

#### 3. **유지보수성**
- [ ] 컴포넌트 재사용률 80% 이상
- [ ] 테스트 커버리지 90% 이상
- [ ] 문서화 완성도 100%

### 🎨 예상 개선 효과

#### 1. **코드 품질 향상**
- 코드 중복 70% 감소 예상
- 유지보수성 대폭 향상
- 버그 발생률 감소

#### 2. **사용자 경험 개선**
- 일관된 디자인으로 사용자 혼란 감소
- 부드러운 애니메이션으로 사용성 향상
- 접근성 개선으로 더 많은 사용자 지원

#### 3. **개발 효율성 향상**
- 재사용 가능한 컴포넌트로 개발 속도 향상
- 일관된 디자인 시스템으로 디자인-개발 간 소통 개선
- 테스트 작성 용이성 향상

### ⚠️ 주의사항

#### 1. **기존 기능 보존**
- 현재 동작하는 모든 기능을 그대로 유지
- 사용자 경험의 연속성 보장
- 점진적 마이그레이션으로 리스크 최소화

#### 2. **성능 고려사항**
- 애니메이션 성능 최적화
- 메모리 사용량 모니터링
- 빌드 크기 증가 최소화

#### 3. **테스트 전략**
- 기존 기능 회귀 테스트 필수
- 새로운 컴포넌트 단위 테스트
- 사용자 시나리오 기반 통합 테스트

---

## 📝 결론

현재 바텀시트 시스템은 **복잡성과 일관성 부족**이라는 주요 문제를 가지고 있습니다. `wolt_modal_sheet 0.11.0`을 도입하여 **단계적 리팩토링**을 진행하면 다음과 같은 효과를 기대할 수 있습니다:

1. **코드 품질 대폭 향상** (중복 제거, 유지보수성 개선)
2. **사용자 경험 일관성 확보** (통일된 디자인, 부드러운 애니메이션)
3. **개발 효율성 향상** (재사용 가능한 컴포넌트, 일관된 개발 경험)

**중요**: 기존 기능을 변경하지 않고 점진적으로 개선하여 안정성을 보장해야 합니다.
