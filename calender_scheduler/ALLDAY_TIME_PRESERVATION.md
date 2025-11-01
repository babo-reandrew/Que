# ✅ 종일 토글 시간 정보 보존 구현 완료

## 📋 개요

일정(Schedule)에서 **종일 토글 시 시간 정보를 캐시에 보존**하고, 종일 해제 시 복원하도록 구현 완료.

## 🎯 구현 내용

### 1. 문제점

**기존 문제:**
- 종일을 켜면 시간이 00:00 ~ 23:59로 변경됨
- 종일을 끄면 이전 시간이 아닌 00:00 ~ 23:59가 그대로 표시됨
- 사용자가 설정했던 실제 시간 정보가 사라짐

### 2. 해결 방법

**캐시 메커니즘:**
- 종일 ON: 현재 시간을 `_cachedStartTime`, `_cachedEndTime`에 저장
- 종일 OFF: 캐시에서 시간 복원

**데이터베이스 저장:**
- 종일: 00:00:00 ~ 23:59:59로 저장
- 일반: 실제 선택된 시간으로 저장

## 📝 수정 파일

### 1. `lib/providers/schedule_form_controller.dart`

#### 캐시 변수 추가
```dart
// ✅ 종일 토글 시 시간 정보 캐시 (종일 해제 시 복원용)
TimeOfDay? _cachedStartTime;
TimeOfDay? _cachedEndTime;
```

#### `toggleAllDay()` 메서드 수정
```dart
void toggleAllDay() {
  _isAllDay = !_isAllDay;
  
  if (_isAllDay) {
    // ✅ 종일 ON: 현재 시간을 캐시에 저장하고 00:00 ~ 23:59로 설정
    if (_startTime != null) {
      _cachedStartTime = _startTime;
    }
    if (_endTime != null) {
      _cachedEndTime = _endTime;
    }
    _startTime = const TimeOfDay(hour: 0, minute: 0);
    _endTime = const TimeOfDay(hour: 23, minute: 59);
    debugPrint(
      '🔄 [ScheduleForm] 終日 ON: 시간 캐시 저장 (start=${_cachedStartTime}, end=${_cachedEndTime}) → 00:00 ~ 23:59',
    );
  } else {
    // ✅ 종일 OFF: 캐시에서 시간 복원
    if (_cachedStartTime != null) {
      _startTime = _cachedStartTime;
    }
    if (_cachedEndTime != null) {
      _endTime = _cachedEndTime;
    }
    debugPrint(
      '🔄 [ScheduleForm] 終日 OFF: 시간 복원 (start=$_startTime, end=$_endTime)',
    );
  }
  
  notifyListeners();
}
```

#### `setAllDay()` 메서드 수정
```dart
void setAllDay(bool value) {
  if (_isAllDay == value) return;
  _isAllDay = value;
  
  if (_isAllDay) {
    // ✅ 종일 ON: 현재 시간을 캐시에 저장하고 00:00 ~ 23:59로 설정
    if (_startTime != null) {
      _cachedStartTime = _startTime;
    }
    if (_endTime != null) {
      _cachedEndTime = _endTime;
    }
    _startTime = const TimeOfDay(hour: 0, minute: 0);
    _endTime = const TimeOfDay(hour: 23, minute: 59);
  } else {
    // ✅ 종일 OFF: 캐시에서 시간 복원
    if (_cachedStartTime != null) {
      _startTime = _cachedStartTime;
    }
    if (_cachedEndTime != null) {
      _endTime = _cachedEndTime;
    }
  }
  
  notifyListeners();
}
```

#### `startDateTime` / `endDateTime` getter 수정
```dart
/// 시작 DateTime 빌드
/// ✅ 종일일 때: 00:00:00으로 저장 (시간 정보는 캐시에 보존)
/// ✅ 일반일 때: 실제 시간 사용
DateTime? get startDateTime {
  if (_startDate == null) return null;
  if (_isAllDay) {
    // 종일: 무조건 00:00:00 (시간은 _cachedStartTime에 보존됨)
    return DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      0,
      0,
      0,
    );
  }
  // 일반: 실제 시간 사용
  if (_startTime == null) {
    return DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      0,
      0,
      0,
    );
  }
  return DateTime(
    _startDate!.year,
    _startDate!.month,
    _startDate!.day,
    _startTime!.hour,
    _startTime!.minute,
    0,
  );
}

/// 종료 DateTime 빌드
/// ✅ 종일일 때: 23:59:59로 저장 (시간 정보는 캐시에 보존)
/// ✅ 일반일 때: 실제 시간 사용
DateTime? get endDateTime {
  if (_endDate == null) return null;
  if (_isAllDay) {
    // 종일: 무조건 23:59:59 (시간은 _cachedEndTime에 보존됨)
    return DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      23,
      59,
      59,
    );
  }
  // 일반: 실제 시간 사용
  if (_endTime == null) {
    return DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      23,
      59,
      59,
    );
  }
  return DateTime(
    _endDate!.year,
    _endDate!.month,
    _endDate!.day,
    _endTime!.hour,
    _endTime!.minute,
    0,
  );
}
```

#### `reset()` / `resetWithDate()` 메서드 수정
```dart
void reset() {
  titleController.clear();
  _isAllDay = false;
  _startDate = null;
  _startTime = null;
  _endDate = null;
  _endTime = null;
  _cachedStartTime = null; // ✅ 캐시 초기화
  _cachedEndTime = null; // ✅ 캐시 초기화
  notifyListeners();
}

void resetWithDate(DateTime selectedDate) {
  titleController.clear();
  _isAllDay = false;
  _startDate = selectedDate;
  _endDate = selectedDate;
  final now = TimeOfDay.now();
  _startTime = now;
  _endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
  _cachedStartTime = null; // ✅ 캐시 초기화
  _cachedEndTime = null; // ✅ 캐시 초기화
  notifyListeners();
}
```

### 2. `lib/component/modal/schedule_detail_wolt_modal.dart`

#### 기존 일정 로드 시 종일 판단 로직 추가
```dart
if (schedule != null) {
  // 기존 일정 수정
  scheduleController.titleController.text = schedule.summary;
  scheduleController.setStartDate(schedule.start);
  scheduleController.setEndDate(schedule.end);

  // ✅ 종일 여부 확인: 00:00:00 ~ 23:59:59인지 체크
  final isAllDay = schedule.start.hour == 0 &&
      schedule.start.minute == 0 &&
      schedule.start.second == 0 &&
      schedule.end.hour == 23 &&
      schedule.end.minute == 59 &&
      schedule.end.second == 59;

  if (isAllDay) {
    // 종일 일정: 종일 설정하고 기본 시간 사용
    scheduleController.setAllDay(true);
    debugPrint('✅ [ScheduleWolt] 종일 일정 로드: ${schedule.start} ~ ${schedule.end}');
  } else {
    // 일반 일정: 실제 시간 사용
    scheduleController.setStartTime(TimeOfDay.fromDateTime(schedule.start));
    scheduleController.setEndTime(TimeOfDay.fromDateTime(schedule.end));
    debugPrint('✅ [ScheduleWolt] 일반 일정 로드: ${schedule.start} ~ ${schedule.end}');
  }

  bottomSheetController.updateColor(schedule.colorId);
  bottomSheetController.updateReminder(schedule.alertSetting);
  bottomSheetController.updateRepeatRule(schedule.repeatRule);
}
```

## 📊 데이터 흐름

### 종일 ON 시나리오

```
[사용자가 종일 토글 ON]
       ↓
[현재 시간 저장]
  _cachedStartTime = _startTime (예: 10:00)
  _cachedEndTime = _endTime (예: 11:30)
       ↓
[시간 변경]
  _startTime = 00:00
  _endTime = 23:59
       ↓
[UI 표시]
  종일 토글: ON
  시간 선택기: 숨김
       ↓
[저장]
  데이터베이스: 00:00:00 ~ 23:59:59 저장
  캐시: 10:00 ~ 11:30 보존됨
```

### 종일 OFF 시나리오

```
[사용자가 종일 토글 OFF]
       ↓
[캐시에서 시간 복원]
  _startTime = _cachedStartTime (10:00)
  _endTime = _cachedEndTime (11:30)
       ↓
[UI 표시]
  종일 토글: OFF
  시간 선택기: 10:00 ~ 11:30 표시
       ↓
[저장]
  데이터베이스: 10:00:00 ~ 11:30:00 저장
```

### 데이터베이스 저장 형식

**종일 일정:**
```
start: 2025-11-15 00:00:00
end: 2025-11-15 23:59:59
```

**일반 일정:**
```
start: 2025-11-15 10:00:00
end: 2025-11-15 11:30:00
```

## ✅ 테스트 체크리스트

### 새 일정 생성

#### 시나리오 1: 종일 ON → OFF
1. [ ] 새 일정 생성 모달 열기
2. [ ] 시작: 10:00, 종료: 11:30 설정
3. [ ] 종일 토글 ON
4. [ ] **검증:**
   - [ ] 시간 선택기가 숨겨짐
5. [ ] 종일 토글 OFF
6. [ ] **검증:**
   - [ ] 시간 선택기에 10:00 ~ 11:30 표시됨
   - [ ] 이전에 설정한 시간이 유지됨

#### 시나리오 2: 종일 ON → 저장
1. [ ] 새 일정 생성
2. [ ] 시작: 14:00, 종료: 15:30 설정
3. [ ] 종일 토글 ON
4. [ ] 저장
5. [ ] **검증:**
   - [ ] 데이터베이스: 00:00:00 ~ 23:59:59로 저장됨
   - [ ] 일정 목록에서 종일로 표시됨

#### 시나리오 3: 종일 ON → OFF → 저장
1. [ ] 새 일정 생성
2. [ ] 시작: 09:00, 종료: 10:00 설정
3. [ ] 종일 토글 ON
4. [ ] 종일 토글 OFF
5. [ ] 저장
6. [ ] **검증:**
   - [ ] 데이터베이스: 09:00:00 ~ 10:00:00로 저장됨
   - [ ] 캐시에서 복원된 시간으로 저장됨

### 기존 일정 수정

#### 시나리오 4: 종일 일정 로드
1. [ ] 종일 일정(00:00 ~ 23:59) 선택
2. [ ] **검증:**
   - [ ] 종일 토글이 ON 상태로 표시됨
   - [ ] 시간 선택기가 숨겨짐

#### 시나리오 5: 종일 일정 → 일반 일정 변경
1. [ ] 종일 일정 선택
2. [ ] 종일 토글 OFF
3. [ ] 시간 설정 (예: 13:00 ~ 14:00)
4. [ ] 저장
5. [ ] **검증:**
   - [ ] 데이터베이스: 13:00:00 ~ 14:00:00로 저장됨
   - [ ] 일정 목록에서 시간이 표시됨

#### 시나리오 6: 일반 일정 → 종일 일정 변경
1. [ ] 일반 일정(10:00 ~ 11:00) 선택
2. [ ] 종일 토글 ON
3. [ ] 저장
4. [ ] **검증:**
   - [ ] 데이터베이스: 00:00:00 ~ 23:59:59로 저장됨
   - [ ] 일정 목록에서 종일로 표시됨

#### 시나리오 7: 일반 일정 → 종일 → 일반 (시간 보존)
1. [ ] 일반 일정(15:00 ~ 16:30) 선택
2. [ ] 종일 토글 ON
3. [ ] 종일 토글 OFF
4. [ ] **검증:**
   - [ ] 시간 선택기에 15:00 ~ 16:30 표시됨
   - [ ] 원래 시간이 보존되어 있음

## 🎯 핵심 개선 사항

### Before (기존)
- 종일 ON → OFF 시 00:00 ~ 23:59가 그대로 표시됨
- 사용자가 설정한 시간 정보가 사라짐
- 종일을 잠깐 켰다가 끄면 시간을 다시 설정해야 함

### After (개선)
- 종일 ON → OFF 시 원래 시간이 복원됨
- 시간 정보가 캐시에 보존됨
- 종일을 켰다가 꺼도 이전 시간이 유지됨

## 🔍 기술적 세부사항

### 캐시 메커니즘
- `_cachedStartTime`: 종일 ON 전의 시작 시간 보존
- `_cachedEndTime`: 종일 ON 전의 종료 시간 보존
- 종일 OFF 시 캐시에서 자동 복원

### 데이터베이스 정합성
- 종일: 무조건 00:00:00 ~ 23:59:59로 저장
- 일반: 사용자가 선택한 실제 시간으로 저장
- 캐시는 메모리에만 존재, DB에는 저장 안 됨

### UI/UX 개선
- 종일 토글 시 시간 선택기 자동 숨김/표시
- 캐시 복원 시 즉시 UI에 반영
- 사용자가 시간 정보 손실을 걱정하지 않아도 됨

## 📝 참고사항

1. **캐시 초기화:**
   - `reset()` 호출 시 캐시도 함께 초기화됨
   - 새 일정 생성 시 캐시가 비어있음

2. **종일 판단 로직:**
   - 00:00:00 ~ 23:59:59인 일정을 종일로 판단
   - 초 단위까지 정확히 체크

3. **시간 보존 범위:**
   - 종일 토글 중에만 캐시 유효
   - 모달 닫으면 캐시 초기화됨

## ✅ 결론

✅ **사용자 경험 개선:**
- 종일 토글 시 시간 정보가 보존됨
- 실수로 종일을 켜도 시간 복원 가능
- 직관적이고 안전한 UI/UX

✅ **데이터 정합성:**
- 데이터베이스에는 종일/일반에 맞는 시간 저장
- 캐시는 메모리에만 존재하여 데이터 무결성 유지

✅ **코드 품질:**
- 캐시 로직이 명확하게 분리됨
- 디버그 로그로 추적 가능
- 유지보수가 용이함
