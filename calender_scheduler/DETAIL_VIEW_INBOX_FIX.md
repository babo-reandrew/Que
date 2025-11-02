# 디테일뷰 인박스 모드 리스트 표시 문제 수정

## 문제점

디테일뷰에서 인박스 모드로 전환했을 때, 리스트가 비어있다고 표시되는 문제가 있었습니다.
원래는 디테일뷰의 일정/할일/습관 데이터가 그대로 보여야 하는데, "값이 없다"고 나왔습니다.

## 원인 분석

`date_detail_view.dart` 파일의 `_buildUnifiedItemList()` 함수 (Line 3120-3182)에서:

1. `_isInboxMode`가 true일 때, `TempExtractedItems` 테이블에서 데이터를 조회
2. 하지만 실제 아이템 추가 로직이 `TODO` 주석으로 스킵됨 (Line 3176-3179)
3. 빈 리스트 (`items`)를 바로 반환 (Line 3182)
4. 정상적인 일정/할일/습관 데이터 처리 로직이 실행되지 않음

```dart
// 🎯 인박스 모드일 때는 TempExtractedItems 테이블에서 데이터 조회
if (_isInboxMode) {
  // ... 데이터 조회 코드 ...
  
  for (final item in dateItems) {
    // TODO: TempExtractedItemData를 UnifiedListItem으로 변환하는 로직 필요
    // 지금은 일단 스킵 - 다음 단계에서 처리
  }
  
  return items; // ❌ 빈 리스트 반환!
}
```

## 해결책

인박스 모드에서도 일반 모드와 동일하게 실제 일정/할일/습관 데이터를 표시하도록 수정:

- `TempExtractedItems` 조회 블록 전체 제거 (Line 3120-3182)
- 인박스 모드와 일반 모드 모두 동일한 데이터 처리 로직 사용

### 수정 내용

```dart
// 🎯 인박스 모드에서도 정상적인 일정/할일/습관 데이터를 표시
// 기존 TempExtractedItems 조회 로직은 제거하고, 일반 모드와 동일하게 처리

// 🎯 완료된 습관 ID 조회 (HabitCompletion 테이블)
final completedHabits = await GetIt.I<AppDatabase>()
    .watchCompletedHabitsByDay(date)
    .first;
// ... 이하 정상 로직 ...
```

## 영향 범위

- **수정 파일**: `lib/screen/date_detail_view.dart`
- **수정 라인**: 3120-3119 (73줄 삭제, 2줄 추가)
- **영향**: 인박스 모드에서 디테일뷰 리스트가 정상적으로 표시됨

## 테스트 필요 사항

1. 일반 모드 → 인박스 모드 전환 시 리스트 표시 확인
2. 인박스 모드에서 날짜 변경 시 해당 날짜의 일정/할일/습관 표시 확인
3. 인박스 모드에서 드래그&드롭 기능 정상 동작 확인
