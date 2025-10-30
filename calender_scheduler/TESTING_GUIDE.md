## 🧪 반복 이벤트 통합 테스트 가이드

이 문서는 RRULE 기반 반복 이벤트 시스템의 전체 기능을 실제 앱에서 테스트하는 방법을 설명합니다.

---

## ✅ 준비 사항

1. **앱 빌드 및 실행**
   ```bash
   cd /Users/junsung/Desktop/Que/calender_scheduler/calender_scheduler
   flutter run
   ```

2. **Debug 콘솔 열기**
   - Xcode: View → Debug Area → Activate Console
   - Android Studio: Run → View Breakpoints → Attach Debugger
   - VS Code: Debug Console 탭

3. **로그 필터링**
   - 찾을 키워드: `[ScheduleWolt]`, `[TaskWolt]`, `[RecurringHelpers]`

---

## 📋 테스트 시나리오 1: この回のみ 수정

### 1-1. 반복 일정 생성
1. 앱 실행 → `+` 버튼 클릭
2. 제목: "주간 회의"
3. 시간: 10:00 - 11:00
4. 반복: 매주 월요일
5. 저장

### 1-2. 특정 날짜만 수정
1. 11월 11일 (월) 클릭
2. "주간 회의" 카드 클릭
3. 수정 버튼 클릭
4. 시간 변경: 14:00 - 15:00
5. 저장 → **반복 수정 모달** 표시
6. **"この回のみ"** 선택

### 1-3. 검증

#### A. Debug 로그 확인
```
🔥 [ScheduleWolt] updateScheduleThisOnly 호출 - selectedDate: 2025-11-11
🔥 [RecurringHelpers] updateScheduleThisOnly 실행
   - Schedule ID: 1
   - selectedDate (originalDate): 2025-11-11 00:00:00.000
   - schedule.start: 2025-11-04 10:00:00.000  ← 다르면 정상!
✅ [Schedule] この回のみ 수정 완료 (RFC 5545 RecurringException)
```

**✅ 성공 조건:**
- `selectedDate`가 클릭한 날짜(11월 11일)와 일치
- `schedule.start`는 Base Event의 시작일(11월 4일)
- 두 값이 **다르면 정상**

**❌ 실패 사례:**
- `selectedDate`가 `schedule.start`와 같음
- → Modal에 `selectedDate`가 전달되지 않음

#### B. 월뷰 확인
- 11월 4일 (월): 10:00-11:00 (변경 없음)
- **11월 11일 (월): 14:00-15:00** ← 수정됨!
- 11월 18일 (월): 10:00-11:00 (변경 없음)

#### C. DB 확인 (선택사항)
```bash
# check_rrule_db.dart 실행
dart run check_rrule_db.dart
```

**확인 항목:**
- `Schedule` 테이블: Base Event 1개만 존재
- `RecurringPattern` 테이블: 1개 존재
- `RecurringException` 테이블: 
  - `originalDate`: 2025-11-11 00:00:00
  - `isRescheduled`: true
  - `newStartDate`: 2025-11-11 14:00:00
  - `newEndDate`: 2025-11-11 15:00:00

---

## 📋 테스트 시나리오 2: この予定以降 수정

### 2-1. 동일한 반복 일정 사용

### 2-2. 이후 날짜 모두 수정
1. 11월 18일 (월) 클릭
2. "주간 회의" 카드 클릭
3. 수정 버튼 클릭
4. 제목 변경: "팀 미팅"
5. 저장 → **반복 수정 모달** 표시
6. **"この予定以降"** 선택

### 2-3. 검증

#### A. Debug 로그 확인
```
🔥 [ScheduleWolt] updateScheduleFuture 호출 - selectedDate: 2025-11-18
🔥 [RecurringHelpers] updateScheduleFuture 실행
   - Schedule ID: 1
   - selectedDate: 2025-11-18
   - schedule.start: 2025-11-04
   - 기존 패턴 UNTIL 설정: 2025-11-17
   - 새 Schedule 생성: ID=2
   - 새 RecurringPattern 생성: dtstart=2025-11-18
✅ [Schedule] この予定以降 수정 완료 (RRULE 분할)
```

**✅ 성공 조건:**
- 새 Schedule ID가 생성됨
- 기존 패턴이 11월 17일까지로 제한됨

#### B. 월뷰 확인
- 11월 4일 (월): "주간 회의" 10:00-11:00
- 11월 11일 (월): "주간 회의" 14:00-15:00 (시나리오 1의 수정 유지)
- **11월 18일 (월): "팀 미팅" 10:00-11:00** ← 제목 변경!
- **11월 25일 (월): "팀 미팅" 10:00-11:00** ← 제목 변경!

#### C. DB 확인
- `Schedule` 테이블: **2개** (Base Event가 분리됨)
  - ID=1: "주간 회의" (start: 2025-11-04)
  - ID=2: "팀 미팅" (start: 2025-11-18)
- `RecurringPattern` 테이블: **2개**
  - ID=1: entityId=1, until=2025-11-17
  - ID=2: entityId=2, until=null

---

## 📋 테스트 시나리오 3: すべての回 수정

### 3-1. 새 반복 일정 생성
1. 제목: "매일 스탠드업"
2. 시간: 09:00 - 09:15
3. 반복: 매일
4. 저장

### 3-2. 모든 반복 수정
1. 아무 날짜 클릭
2. "매일 스탠드업" 카드 클릭
3. 수정 버튼 클릭
4. 시간 변경: 09:30 - 09:45
5. 저장 → **반복 수정 모달** 표시
6. **"すべての回"** 선택

### 3-3. 검증

#### A. Debug 로그 확인
```
🔥 [ScheduleWolt] すべての回 수정 실행
   - Base Event 직접 수정
   - RecurringPattern 업데이트
✅ [Schedule] すべての回 수정 완료
```

#### B. 월뷰 확인
- 모든 날짜가 09:30-09:45로 변경됨

#### C. DB 확인
- `Schedule` 테이블: Base Event가 직접 수정됨
- `RecurringException` 테이블: 영향 없음 (이전 예외는 유지)

---

## 📋 테스트 시나리오 4: この回のみ 삭제

### 4-1. 특정 날짜만 삭제
1. 11월 12일 클릭
2. "매일 스탠드업" 카드 클릭
3. 삭제 버튼 클릭
4. **"この回のみ"** 선택

### 4-2. 검증

#### A. Debug 로그 확인
```
🔥 [ScheduleWolt] deleteScheduleThisOnly 호출 - selectedDate: 2025-11-12
🔥 [RecurringHelpers] deleteScheduleThisOnly 실행
   - selectedDate (originalDate): 2025-11-12
✅ [Schedule] この回のみ 삭제 완료 (RFC 5545 EXDATE)
```

#### B. 월뷰 확인
- 11월 11일: 표시됨
- **11월 12일: 표시 안 됨** ← 삭제됨!
- 11월 13일: 표시됨

#### C. DB 확인
- `RecurringException` 테이블:
  - `originalDate`: 2025-11-12 00:00:00
  - `isCancelled`: true

---

## 📋 테스트 시나리오 5: 완료 기능

### 5-1. 특정 날짜만 완료
1. 11월 13일 클릭
2. "매일 스탠드업" 카드 클릭
3. **체크박스 클릭 (완료 처리)**

### 5-2. 검증

#### A. 월뷰 확인
- 11월 13일: **완료 후 사라짐**
- 11월 14일: 여전히 표시됨 (미완료)

#### B. 디테일뷰 확인
1. 11월 13일 클릭
2. "매일 스탠드업" 카드가 보이지 않음 (완료 필터링)
3. 또는 완료 표시와 함께 흐리게 표시

#### C. DB 확인
- `ScheduleCompletion` 테이블:
  - `scheduleId`: 해당 Schedule ID
  - `completedDate`: 2025-11-13 00:00:00

### 5-3. 완료 취소
1. 11월 13일 디테일뷰에서 체크박스 다시 클릭
2. 월뷰에 다시 표시됨

---

## 🚨 주의사항 및 트러블슈팅

### ❌ 문제 1: 모든 날짜가 한꺼번에 변경됨
**증상:** この回のみ를 선택했는데 모든 날짜가 변경됨

**원인:** `selectedDate`가 아닌 `schedule.start`가 전달됨

**해결:**
1. `date_detail_view.dart` 확인:
   ```dart
   showScheduleDetailWoltModal(
     context: context,
     schedule: schedule,
     selectedDate: _currentDate, // ← 이게 있는가?
   );
   ```

2. Modal 내부 확인:
   ```dart
   onEditThis: () async {
     await RecurringHelpers.updateScheduleThisOnly(
       selectedDate: selectedDate, // ← schedule.start가 아님!
     );
   }
   ```

### ❌ 문제 2: 모달이 닫히지 않음
**증상:** 수정/삭제 후 모달이 그대로 남아있음

**원인:** 에러 발생 또는 Navigator.pop 누락

**해결:**
1. Debug 콘솔에서 에러 확인
2. try-catch 블록이 있는지 확인
3. `Navigator.pop(context)` 호출 확인

### ❌ 문제 3: 날짜가 하루 밀림
**증상:** 11월 11일을 수정했는데 11월 10일 또는 12일로 저장됨

**원인:** UTC 변환 문제, 시간 포함 문제

**해결:**
1. 날짜 정규화 확인:
   ```dart
   DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
   ```

2. `normalizeDtstartDates()` 마이그레이션 실행

---

## ✅ 모든 테스트 통과 체크리스트

- [ ] この回のみ 수정: selectedDate가 로그에 올바르게 표시됨
- [ ] この予定以降 수정: 새 Schedule이 생성됨
- [ ] すべての回 수정: Base Event가 수정됨
- [ ] この回のみ 삭제: RecurringException (isCancelled=true)
- [ ] この予定以降 삭제: UNTIL 설정됨
- [ ] すべての回 삭제: Base Event 삭제됨
- [ ] 완료 기능: 월뷰에서 숨김/표시 정상 작동
- [ ] 모달 닫기: 수정/삭제 후 자동으로 닫힘
- [ ] 날짜 정규화: UTC 변환 문제 없음

---

## 💡 추가 검증 항목

### Edge Cases
- [ ] 반복 시작일(첫 번째 인스턴스) 수정/삭제
- [ ] 반복 마지막일 수정/삭제 (UNTIL 설정된 경우)
- [ ] 같은 날짜를 두 번 수정 시도 (UNIQUE 제약)
- [ ] 빈 RRULE (반복 없는 일정)

### 성능
- [ ] 반복 일정 10개 × 30일 = 300개 인스턴스 렌더링 속도
- [ ] DB 쿼리 성능
- [ ] 메모리 사용량

---

## 📊 데이터베이스 직접 확인

```bash
# SQLite DB 위치
cd ~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Documents/

# 또는 check_rrule_db.dart 스크립트 사용
dart run check_rrule_db.dart
```

**주요 쿼리:**
```sql
-- Base Event 개수 확인
SELECT COUNT(*) FROM schedule;

-- RecurringPattern 확인
SELECT * FROM recurring_pattern;

-- RecurringException 확인
SELECT * FROM recurring_exception;

-- ScheduleCompletion 확인
SELECT * FROM schedule_completion;
```

---

## 🎯 최종 확인

모든 테스트를 통과했다면:

1. ✅ TODO #1: 데이터베이스 구조 이해 완료
2. ✅ TODO #2: Base Event 저장 검증 완료
3. ✅ TODO #5-6: Modal selectedDate 전달 검증 완료
4. ✅ TODO #7: RecurringHelpers 함수 검증 완료
5. ✅ TODO #10: UI 모달 닫기 로직 검증 완료
6. ✅ TODO #11-13: 통합 테스트 완료

**다음 단계:** TODO #3 (월뷰 표시 로직 검증), TODO #4 (디테일뷰 표시 로직 검증), TODO #17 (문서화)
