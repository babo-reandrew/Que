# Quick Add Frame Transition Report

## 🎯 최종 구현: Frame 704 ↔ Frame 705 자연스러운 전환

### ✅ 핵심 변경사항

**Before (문제)**:
- Frame 704 (타입 선택기): 별도 위치에 항상 표시
- Frame 705 (타입 선택 팝업): Positioned로 우측 하단에 별도 표시
- 결과: 두 개의 UI가 동시에 보이거나 위치가 맞지 않음

**After (해결)**:
- Frame 704와 Frame 705가 **같은 위치**에서 조건부 렌더링
- 追加 버튼 클릭 → `_showDetailPopup = true` → Frame 705로 교체
- 자연스러운 애니메이션 (52px → 172px)

## 📝 코드 구조

### 1. 조건부 렌더링 (같은 위치)

```dart
// Column 내부 - Frame 701 아래 8px gap
const SizedBox(height: 8),

// ✅ 같은 위치에서 조건부 전환
_showDetailPopup && _selectedType == null
    ? _buildTypePopup()      // Frame 705: 타입 선택 팝업 (220×172px)
    : _buildTypeSelector(),  // Frame 704: 타입 선택기 (220×52px)
```

### 2. Frame 704 빌더 (기본 상태)

```dart
Widget _buildTypeSelector() {
  return Container(
    width: 220,   // Figma: Frame 704 width
    height: 52,   // Figma: Frame 704 height
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: QuickAddTypeSelector(
      selectedType: _selectedType,
      onTypeSelected: _onTypeSelected,
    ),
  );
}
```

### 3. Frame 705 빌더 (追加 클릭 후)

```dart
Widget _buildTypePopup() {
  return QuickDetailPopup(
    // ✅ 220×172px 컨테이너
    // ✅ 52px → 172px 애니메이션 내장
    onScheduleSelected: () {
      _saveDirectSchedule();
      setState(() => _showDetailPopup = false);
    },
    onTaskSelected: () {
      _saveDirectTask();
      setState(() => _showDetailPopup = false);
    },
    onHabitSelected: () {
      _saveDirectHabit();
      setState(() => _showDetailPopup = false);
    },
  );
}
```

## 🎬 사용자 플로우

```
1. 기본 상태 (Property 1=Anything)
   ├─ Frame 701: 텍스트 필드 비어있음
   ├─ Frame 702: 追加 버튼 비활성 (#DDDDDD)
   └─ Frame 704: 타입 선택기 (220×52px) ✅

2. 텍스트 입력 후 (Property 1=Variant5)
   ├─ Frame 701: "회의" 입력됨
   ├─ Frame 702: 追加 버튼 활성화 (#111111)
   └─ Frame 704: 타입 선택기 유지 ✅

3. 追加 버튼 클릭 (Property 1=Touched_Anything)
   ├─ setState(() => _showDetailPopup = true)
   ├─ Frame 704 숨김
   └─ Frame 705 표시 (같은 위치에서 52px→172px 애니메이션) ✅
      ├─ 今日のスケジュール
      ├─ タスク
      └─ ルーティン

4. 타입 선택 (예: タスク)
   ├─ _saveDirectTask() 실행
   ├─ DB 저장 (마감기한 없이)
   ├─ setState(() => _showDetailPopup = false)
   └─ Frame 704로 복귀 ✅
```

## 🎨 레이아웃 구조

```
Column (crossAxisAlignment: center)
├─ SizedBox (8px gap)
│
├─ Stack (Frame 701 + Frame 702)
│  ├─ Container (Frame 701 - 텍스트 입력)
│  └─ Positioned (Frame 702 - 追加 버튼)
│
├─ SizedBox (8px gap)
│
└─ [조건부 렌더링] ✅ 같은 위치
   ├─ _showDetailPopup ? _buildTypePopup()   // Frame 705
   └─                  : _buildTypeSelector() // Frame 704
```

## ✨ 애니메이션 상세

**QuickDetailPopup 내부 (quick_detail_popup.dart)**:

```dart
class _QuickDetailPopupState extends State<QuickDetailPopup>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350), // Figma spec
    );

    _heightAnimation = Tween<double>(
      begin: 52.0,   // Frame 704 높이
      end: 172.0,    // Frame 705 높이
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic, // Apple-like
    ));

    _controller.forward(); // 즉시 애니메이션 시작
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 220,
          height: _heightAnimation.value, // 52 → 172px
          // ... 내부 UI
        );
      },
    );
  }
}
```

## 🔍 변경사항 요약

### 삭제된 코드

```dart
// ❌ 삭제: Positioned로 별도 배치되던 QuickDetailPopup
if (_showDetailPopup && _selectedType == null)
  Positioned(
    right: 0,
    bottom: -20,
    child: QuickDetailPopup(...),
  ),
```

### 추가된 코드

```dart
// ✅ 추가: 조건부 렌더링으로 같은 위치 전환
_showDetailPopup && _selectedType == null
    ? _buildTypePopup()      // Frame 705
    : _buildTypeSelector(),  // Frame 704

// ✅ 추가: Frame 705 빌더 메서드
Widget _buildTypePopup() {
  return QuickDetailPopup(
    onScheduleSelected: () => _saveDirectSchedule(),
    onTaskSelected: () => _saveDirectTask(),
    onHabitSelected: () => _saveDirectHabit(),
  );
}
```

## 📊 Figma vs 구현 비교

| 항목 | Figma | 구현 | 상태 |
|------|-------|------|------|
| Frame 704 위치 | Frame 701 아래 8px | `SizedBox(height: 8)` | ✅ |
| Frame 705 위치 | Frame 704와 동일 | 조건부 렌더링 | ✅ |
| 전환 방식 | 같은 위치 확장 | `_showDetailPopup` 플래그 | ✅ |
| 애니메이션 | 52px → 172px | `_heightAnimation` | ✅ |
| Duration | 350ms | `Duration(milliseconds: 350)` | ✅ |
| Easing | easeInOutCubic | `Curves.easeInOutCubic` | ✅ |

## 🧪 테스트 시나리오

### Test 1: Frame 전환
1. 앱 실행 → Frame 704 표시 확인 (220×52px)
2. "회의" 입력 → 追加 버튼 활성화
3. 追加 클릭 → Frame 704 사라지고 Frame 705 나타남
4. **검증**: 위치 변화 없이 높이만 52→172px 애니메이션

### Test 2: 직접 저장
1. Frame 705에서 "今日のスケジュール" 선택
2. **검증**: 현재시간 반올림 + 1시간으로 저장
3. Frame 705 사라지고 Frame 704 복귀

### Test 3: 애니메이션 부드러움
1. 追加 클릭
2. **검증**: 350ms 동안 부드러운 높이 전환 (easeInOutCubic)

## 🎯 최종 결과

✅ **Frame 704와 Frame 705가 같은 위치에서 자연스럽게 전환**
✅ **최소한의 코드 수정 (조건부 렌더링만 변경)**
✅ **Positioned 제거로 레이아웃 단순화**
✅ **애니메이션 유지 (QuickDetailPopup 내장)**
✅ **Figma 디자인 100% 준수**

---

**Implementation Date**: 2024-10-16
**Key Changes**: Frame 704/705 조건부 렌더링으로 같은 위치 전환
**Files Modified**: `quick_add_control_box.dart` (최소 수정)
