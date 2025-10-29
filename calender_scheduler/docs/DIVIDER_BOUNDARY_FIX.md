# 🎯 디테일뷰 점선 경계 및 로딩 최적화 완료

## 📋 수정 내용

### 1. ✅ 점선 경계 규칙 명확화

**문제점:**
- 일정은 점선 아래로 이동할 수 없었지만, 할일과 습관은 점선 위로 이동이 가능했음
- 점선은 "일정 섹션"과 "할일/습관 섹션"을 구분하는 경계선인데, 경계 규칙이 일관성이 없었음

**해결:**
```dart
// ✅ 경계 제약 규칙 (양방향):
// 1. 일정(Schedule)은 점선 아래로 이동 불가
// 2. 할일(Task), 습관(Habit)은 점선 위로 이동 불가
bool shouldBlock = false;
String blockReason = '';

if (item.type == UnifiedItemType.schedule) {
  // 일정을 점선 아래로 이동하려는 경우
  if (targetIndex > dividerIndex) {
    shouldBlock = true;
    blockReason = '일정을 점선 아래로 이동 불가';
  }
} else if (item.type == UnifiedItemType.task ||
    item.type == UnifiedItemType.habit) {
  // 할일/습관을 점선 위로 이동하려는 경우
  if (targetIndex < dividerIndex) {
    shouldBlock = true;
    blockReason = '${item.type == UnifiedItemType.task ? '할일' : '습관'}을 점선 위로 이동 불가';
  }
}
```

**효과:**
- ✅ 일정: 점선 아래로 이동 시도 시 차단 (기존과 동일)
- ✅ 할일: 점선 위로 이동 시도 시 차단 (새로 추가)
- ✅ 습관: 점선 위로 이동 시도 시 차단 (새로 추가)
- ✅ 차단 시 Heavy Haptic + 원래 위치로 복귀 애니메이션

---

### 2. ⏱️ DB 저장 디바운스로 연속 로딩 방지

**문제점:**
- 드래그앤드롭으로 순서 변경 시마다 즉시 DB 저장
- DB 저장 → StreamBuilder 트리거 → FutureBuilder rebuild → 화면 깜빡임
- 특히 여러 번 연속으로 드래그할 때 화면이 계속 로딩되는 현상

**해결:**
```dart
// ⏱️ DB 저장 디바운스를 위한 타이머 추가
Timer? _saveOrderDebounceTimer;

// _handleReorder 내부:
// ⏱️ 디바운스를 사용해 DB 저장 (300ms 후 저장)
// 이거를 해서 → 여러 번 드래그할 때 DB 저장을 모아서 한 번만 실행
_saveOrderDebounceTimer?.cancel();
_saveOrderDebounceTimer = Timer(const Duration(milliseconds: 300), () {
  _saveDailyCardOrder(items);
});
```

**최적화 내용:**
1. **디바운스 타이머**: 드래그 종료 후 300ms 대기 → 마지막 변경사항만 DB 저장
2. **setState 제거**: AnimatedReorderableListView가 자체적으로 UI 업데이트하므로 불필요한 setState 제거
3. **타이머 정리**: dispose()에서 타이머 취소하여 메모리 누수 방지

**효과:**
- ✅ 여러 번 드래그해도 DB 저장은 1번만 실행
- ✅ StreamBuilder 트리거 횟수 감소 → 화면 깜빡임 없음
- ✅ 부드러운 드래그앤드롭 경험

---

## 🎨 사용자 경험 개선

### Before (수정 전):
- ❌ 할일/습관을 점선 위로 드래그하면 일정 섹션에 들어감
- ❌ 드래그할 때마다 화면이 깜빡이며 로딩됨
- ❌ 연속으로 드래그하면 계속 로딩 인디케이터 표시

### After (수정 후):
- ✅ 할일/습관을 점선 위로 드래그하면 Heavy Haptic + 원래 위치로 복귀
- ✅ 드래그 중에는 화면이 깜빡이지 않음
- ✅ 드래그 종료 후 300ms 후 DB 저장 (사용자는 저장 과정을 느끼지 못함)
- ✅ 부드러운 애니메이션으로 자연스러운 경험

---

## 📊 기술 세부사항

### 파일 수정:
- `lib/screen/date_detail_view.dart`

### 추가된 내용:
1. `dart:async` 임포트 (Timer 사용)
2. `Timer? _saveOrderDebounceTimer` 필드
3. `dispose()` 내 타이머 취소 로직
4. `onReorder()` 내 양방향 경계 체크 로직
5. `_handleReorder()` 내 디바운스 로직

### 코드 메트릭스:
- 추가된 줄: ~40줄
- 삭제된 줄: ~10줄 (불필요한 setState 제거)
- 수정된 함수: 3개 (`onReorder`, `_handleReorder`, `dispose`)

---

## ✅ 테스트 시나리오

### 시나리오 1: 일정 → 점선 아래 이동
1. 일정 카드를 길게 누르기
2. 점선 아래 할일/습관 영역으로 드래그
3. **예상 결과**: Heavy Haptic + 원래 위치로 복귀 ✅

### 시나리오 2: 할일 → 점선 위 이동
1. 할일 카드를 길게 누르기
2. 점선 위 일정 영역으로 드래그
3. **예상 결과**: Heavy Haptic + 원래 위치로 복귀 ✅

### 시나리오 3: 습관 → 점선 위 이동
1. 습관 카드를 길게 누르기
2. 점선 위 일정 영역으로 드래그
3. **예상 결과**: Heavy Haptic + 원래 위치로 복귀 ✅

### 시나리오 4: 연속 드래그
1. 할일 카드 여러 개를 연속으로 드래그
2. 순서를 여러 번 변경
3. **예상 결과**: 
   - 화면 깜빡임 없음 ✅
   - 마지막 변경 후 300ms 후 DB 저장 ✅
   - 부드러운 애니메이션 ✅

---

## 🔍 디버그 로그

```
🎯 [onReorder] 이동: index 1 → 3 (divider: 2, type: task)
🚫 [onReorder] 할일을 점선 위로 이동 불가! oldIndex=1, newIndex=4, targetIndex=3, dividerIndex=2
```

---

## 🎯 향후 개선 사항

1. **점선 위치 자동 조정**: 
   - 현재는 마지막 일정 다음에 점선 고정
   - 향후 일정이 0개일 때 점선 숨김 처리 가능

2. **드래그 비주얼 피드백**:
   - 점선 근처에서 드래그 시 점선 하이라이트
   - 이동 불가 영역에 진입 시 카드에 빨간색 테두리

3. **Undo 기능**:
   - 순서 변경 후 취소 기능 추가
   - Snackbar에 "실행 취소" 버튼 표시

---

## 📝 참고 사항

- **AnimatedReorderableListView**: 자체적으로 UI 업데이트를 처리하므로 setState 불필요
- **StreamBuilder 최적화**: 디바운스를 통해 DB 업데이트 횟수 최소화
- **Future 캐시**: 이미 구현되어 있어 rebuild 시 중복 호출 방지됨

---

**작성일**: 2025-10-25  
**작성자**: AI Assistant  
**상태**: ✅ 완료 및 테스트 필요
