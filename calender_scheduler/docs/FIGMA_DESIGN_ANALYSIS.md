# 📐 Figma 바텀시트 디자인 완전 분석

## 🎯 발견된 바텀시트 종류 (총 10개)

### 1️⃣ **루틴 변경 확인 모달** (Property 1=Change)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2324-8067
- **크기**: 370×437px
- **용도**: "이 회만 / 이 예정 이후 / 모든 회" 선택
- **CTA 버튼**: 青(#0000FF) "移動する"

### 2️⃣ **루틴 이동 확인 모달** (Property 1=Move)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2324-8068
- **크기**: 370×438px
- **용도**: 루틴 이동 범위 선택
- **CTA 버튼**: 青(#0000FF) "移動する"

### 3️⃣ **변경 내용 파기 확인 모달** (Property 1=Cancel)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2324-8069
- **크기**: 370×299px
- **용도**: "変更した内容を破棄しますか？"
- **CTA 버튼**: 赤(#FF0000) "削除する"

### 4️⃣ **삭제 확인 모달** (Property 1=Delete)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2324-8070
- **크기**: 370×438px
- **용도**: 삭제 최종 확인
- **CTA 버튼**: 赤(#FF0000) "削除する"

### 5️⃣ **짧은 취소 확인 모달** (Property 1=Cancel_Short)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2365-15475
- **크기**: 370×303px
- **용도**: "内容を削除ますか？"
- **CTA 버튼**: 赤(#FF0000) "削除する"

### 6️⃣ **스케줄 상세 바텀시트** (Schedule isEmpty Default)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2326-11044
- **크기**: 393×583px
- **상태**: 비어있는 상태
- **구성**: 타이틀 입력 + 종일 토글 + 시작/종료 시간 선택 + 옵션(색상/반복/리마인더) + 삭제 버튼

### 7️⃣ **할 일 상세 바텀시트** (Task isEmpty Default)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2326-11045
- **크기**: 393×615px
- **상태**: 비어있는 상태
- **구성**: 타이틀 입력 + 마감일 라벨 + 날짜 선택 + 옵션(색상/반복/리마인더) + 삭제 버튼

### 8️⃣ **습관 상세 바텀시트** (Habit isEmpty Default)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2326-11046
- **크기**: 393×409px
- **상태**: 비어있는 상태
- **구성**: 타이틀 입력 + 옵션(색상/반복/리마인더) + 삭제 버튼

### 9️⃣ **스케줄 상세 (입력 완료)** (Schedule isPresent Default)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2326-11047
- **크기**: 393×576px
- **상태**: 모든 필드 입력됨
- **특징**: 날짜/시간 대형 폰트(33px), 반복/리마인더 텍스트 표시

### 🔟 **할 일 상세 (입력 완료)** (Task isPresent Default)
- **Figma**: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2326-11048
- **크기**: 393×584px
- **상태**: 모든 필드 입력됨

---

## 🎨 통합 디자인 시스템 분석

### 📦 컨테이너 (Component 66)
```css
background: #FCFCFC;
border: 1px solid rgba(17, 17, 17, 0.1);
box-shadow: 0px 2px 20px rgba(165, 165, 165, 0.2);
border-radius: 36px;
```

**Flutter 변환:**
```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFFFCFCFC),
    border: Border.all(
      color: Color(0xFF111111).withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0xFFA5A5A5).withOpacity(0.2),
        offset: Offset(0, 2),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ],
    borderRadius: BorderRadius.circular(36),
  ),
)
```

### 🎨 컬러 팔레트

#### 메인 컬러
- **배경색**: `#FCFCFC` (거의 흰색)
- **검정**: `#111111` (메인 텍스트)
- **회색 계열**:
  - `#262626` (버튼 배경)
  - `#505050` (서브 타이틀)
  - `#656565` (설명 텍스트)
  - `#7A7A7A` (비활성 상태)
  - `#AAAAAA` (플레이스홀더)
  - `#BBBBBB` (라벨)
  - `#E4E4E4` (토글 배경)
  - `#EEEEEE` (비활성 숫자)
  - `#FAFAFA` (흰색 버튼)

#### 액션 컬러
- **Primary Blue**: `#0000FF` (이동 버튼)
- **Danger Red**: `#FF0000` (삭제 버튼)
- **Sub Red**: `#F74A4A` (삭제 아이콘)

#### 투명도 패턴
- Border: `rgba(17, 17, 17, 0.1)` - 10% 검정
- Border Light: `rgba(17, 17, 17, 0.08)` - 8% 검정
- Border Lighter: `rgba(17, 17, 17, 0.06)` - 6% 검정
- Border Super Light: `rgba(17, 17, 17, 0.02)` - 2% 검정
- Shadow: `rgba(165, 165, 165, 0.2)` - 20% 회색

### 📐 반경 시스템

| 컴포넌트 | Border Radius |
|---------|---------------|
| 메인 바텀시트 | 36px (상단만) |
| 작은 모달 | 36px (전체) |
| CTA 버튼 | 24px |
| DetailOption 버튼 | 24px |
| 완료 버튼 | 16px |
| 삭제 버튼 | 16px |
| 닫기 버튼 (원형) | 100px |
| 토글 | 100px |

### 📏 간격 시스템

| 용도 | Gap/Padding |
|------|-------------|
| 바텀시트 padding | 32px (상단), 0px (좌우), 56~210px (하단) |
| Column gap (주요) | 12px, 24px, 36px, 48px |
| Row gap | 8px, 10px |
| DetailOption 간격 | 8px |
| 텍스트 행간 | 2px, 10px, 12px, 20px |

### 🔤 타이포그래피

#### 폰트 패밀리
```
font-family: 'LINE Seed JP App_TTF';
```

#### 타이틀 스타일
```css
/* 메인 타이틀 (스케줄명) */
font-weight: 800;
font-size: 19px;
line-height: 140%; /* 27px */
letter-spacing: -0.005em;
color: #111111;

/* 모달 타이틀 (변경/삭제 확인) */
font-weight: 800;
font-size: 22px;
line-height: 130%; /* 29px */
letter-spacing: -0.005em;
color: #262626;
```

#### 본문 스타일
```css
/* 서브 타이틀 (スケジュール) */
font-weight: 700;
font-size: 16px;
line-height: 140%; /* 22px */
letter-spacing: -0.005em;
color: #505050;

/* 옵션 텍스트 (２日毎, 10分前) */
font-weight: 700;
font-size: 13px;
line-height: 140%; /* 18px */
letter-spacing: -0.005em;
color: #111111;

/* 설명 텍스트 */
font-weight: 400;
font-size: 13px;
line-height: 140%; /* 18px */
letter-spacing: -0.005em;
color: #656565;
```

#### 대형 숫자 (날짜/시간)
```css
/* 날짜 표시 (25. 7. 30) */
font-weight: 800;
font-size: 19px;
line-height: 120%; /* 23px */
letter-spacing: -0.005em;
color: #111111;
text-shadow: 0px 4px 20px rgba(0, 0, 0, 0.1);

/* 시간 표시 (15:30) */
font-weight: 800;
font-size: 33px;
line-height: 120%; /* 40px */
letter-spacing: -0.005em;
color: #111111;
text-shadow: 0px 4px 20px rgba(0, 0, 0, 0.1);

/* 대형 플레이스홀더 (10) */
font-weight: 800;
font-size: 50px;
line-height: 120%; /* 60px */
letter-spacing: -0.005em;
color: #EEEEEE;
```

#### 버튼 텍스트
```css
/* CTA 버튼 (移動する, 削除する) */
font-weight: 700;
font-size: 15px;
line-height: 140%; /* 21px */
letter-spacing: -0.005em;
color: #FFFFFF;

/* 완료 버튼 */
font-weight: 800;
font-size: 13px;
line-height: 140%; /* 18px */
letter-spacing: -0.005em;
color: #FAFAFA;

/* 삭제 버튼 텍스트 */
font-weight: 700;
font-size: 13px;
line-height: 140%; /* 18px */
letter-spacing: -0.005em;
color: #F74A4A;
```

### 📦 버튼 디자인

#### CTA 버튼 (Primary)
```css
/* 이동 버튼 */
padding: 10px;
background: #0000FF;
border: 1px solid rgba(17, 17, 17, 0.01);
border-radius: 24px;
```

**Flutter:**
```dart
Container(
  padding: EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: Color(0xFF0000FF),
    border: Border.all(
      color: Color(0xFF111111).withOpacity(0.01),
      width: 1,
    ),
    borderRadius: BorderRadius.circular(24),
  ),
  child: Text(
    '移動する',
    style: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      height: 1.4,
      letterSpacing: -0.075,
      color: Color(0xFFFFFFFF),
    ),
  ),
)
```

#### CTA 버튼 (Danger)
```css
/* 삭제 버튼 */
padding: 10px;
background: #FF0000;
border: 1px solid rgba(17, 17, 17, 0.01);
border-radius: 24px;
```

#### 완료 버튼
```css
padding: 12px 24px;
background: #111111;
box-shadow: 0px -2px 8px rgba(186, 186, 186, 0.08);
border-radius: 16px;
```

#### DetailOption 버튼
```css
padding: 20px;
width: 64px;
height: 64px;
background: #FFFFFF;
border: 1px solid rgba(17, 17, 17, 0.08);
box-shadow: 
  0px 2px 8px rgba(186, 186, 186, 0.08),
  0px 4px 20px rgba(0, 0, 0, 0.02);
border-radius: 24px;
```

**Flutter:**
```dart
Container(
  width: 64,
  height: 64,
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: Color(0xFF111111).withOpacity(0.08),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0xFFBABABA).withOpacity(0.08),
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        offset: Offset(0, 4),
        blurRadius: 20,
      ),
    ],
    borderRadius: BorderRadius.circular(24),
  ),
  child: Icon(...), // 또는 Text
)
```

#### 삭제 버튼 (작은)
```css
padding: 16px 24px;
gap: 6px;
background: #FAFAFA;
border: 1px solid rgba(186, 186, 186, 0.08);
box-shadow: 0px 4px 20px rgba(17, 17, 17, 0.03);
border-radius: 16px;
```

#### 닫기 버튼 (모달)
```css
padding: 8px;
width: 36px;
height: 36px;
background: rgba(228, 228, 228, 0.9);
border: 1px solid rgba(17, 17, 17, 0.02);
box-shadow: 0px 4px 20px rgba(0, 0, 0, 0.04);
border-radius: 100px;
```

#### 날짜/시간 선택 버튼
```css
/* 검정 원형 버튼 (32×32px) */
padding: 4px;
width: 32px;
height: 32px;
background: #262626;
border: 1px solid rgba(17, 17, 17, 0.06);
box-shadow: 0px -2px 8px rgba(186, 186, 186, 0.08);
border-radius: 100px;
```

### 🔘 토글 스위치

```css
/* Togle_Off */
width: 40px;
height: 24px;
background: #E4E4E4;
border: 1px solid #E4E4E4;
border-radius: 100px;

/* Ellipse (토글 원) */
width: 16px;
height: 16px;
left: 10%;
background: #FAFAFA;
```

**Flutter:**
```dart
Switch(
  value: false,
  activeColor: Color(0xFF0000FF), // 켜졌을 때
  inactiveThumbColor: Color(0xFFFAFAFA),
  inactiveTrackColor: Color(0xFFE4E4E4),
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
)
```

### 📊 아이콘 크기

| 용도 | 크기 |
|------|------|
| DetailOption 아이콘 | 24×24px |
| 닫기 버튼 아이콘 | 20×20px |
| 삭제 버튼 아이콘 | 20×20px |
| 날짜/시간 선택 아이콘 | 24×24px |
| 종일/마감일 라벨 아이콘 | 19×19px |

### 🎭 애니메이션 & Shadow

#### Box Shadow 패턴
```css
/* 메인 바텀시트 */
box-shadow: 0px 2px 20px rgba(165, 165, 165, 0.2);

/* DetailOption 버튼 */
box-shadow: 
  0px 2px 8px rgba(186, 186, 186, 0.08),
  0px 4px 20px rgba(0, 0, 0, 0.02);

/* 완료 버튼 */
box-shadow: 0px -2px 8px rgba(186, 186, 186, 0.08);

/* 삭제 버튼 */
box-shadow: 0px 4px 20px rgba(17, 17, 17, 0.03);

/* 닫기 버튼 */
box-shadow: 0px 4px 20px rgba(0, 0, 0, 0.04);
```

#### Text Shadow
```css
/* 날짜/시간 텍스트 */
text-shadow: 0px 4px 20px rgba(0, 0, 0, 0.1);
```

### 📱 레이아웃 구조

#### TopNavi (공통)
```css
/* Auto layout */
flex-direction: row;
justify-content: space-between;
padding: 9px 28px;
gap: 205px;
height: 60px;
```

#### Frame 구조
- **Frame 778**: 메인 컨텐츠 컨테이너 (gap: 48px)
- **Frame 777**: 폼 필드 그룹 (gap: 36px)
- **Frame 776**: 입력 영역 (gap: 24px)
- **Frame 780**: 타이틀 영역 (padding: 12px 0px)
- **DetailOption/Box**: 옵션 버튼 그룹 (gap: 8px)

---

## 🎯 키보드 상태별 높이 변화

| 바텀시트 | Default | Keyboard |
|---------|---------|----------|
| Schedule | 583px | 773px (+190px) |
| Task | 615px | 727px (+112px) |
| Habit | 409px | 553px (+144px) |

**Bottom Padding 변화:**
- Default: 56~98px
- Keyboard: 210px

---

## 💡 wolt_modal_sheet 적용 가이드

### WoltModalSheetPage 변환 예시

```dart
// 스케줄 상세 바텀시트
SliverWoltModalSheetPage(
  mainContentSliversBuilder: (context) => [
    // TopNavi
    SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'スケジュール',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.08,
                color: Color(0xFF505050),
              ),
            ),
            _buildCompleteButton(),
          ],
        ),
      ),
    ),
    
    // 간격 12px
    SliverToBoxAdapter(child: SizedBox(height: 12)),
    
    // Frame 778: 메인 컨텐츠
    SliverToBoxAdapter(
      child: Column(
        children: [
          // Frame 776: 입력 영역
          _buildTitleInput(),
          SizedBox(height: 24),
          _buildAllDayToggle(),
          SizedBox(height: 12),
          _buildDateTimeSelector(),
        ],
      ),
    ),
    
    // 간격 36px
    SliverToBoxAdapter(child: SizedBox(height: 36)),
    
    // DetailOption/Box
    SliverToBoxAdapter(
      child: _buildDetailOptions(),
    ),
    
    // 간격 48px
    SliverToBoxAdapter(child: SizedBox(height: 48)),
    
    // 삭제 버튼
    SliverToBoxAdapter(
      child: _buildDeleteButton(),
    ),
  ],
  
  topBarTitle: Text('スケジュール'),
  backgroundColor: Color(0xFFFCFCFC),
  surfaceTintColor: Colors.transparent,
  
  // Figma border & shadow
  hasTopBarLayer: false,
  
  // 반경 36px (상단만)
  modalTypeBuilder: (context) => WoltModalType.bottomSheet,
)
```

---

## 🚀 다음 단계

1. ✅ **WoltDesignTokens 클래스 생성** (이 분석 기반)
2. ✅ **WoltTheme 클래스 생성** (TextStyle, ButtonStyle 정의)
3. ⏳ **재사용 컴포넌트 생성**:
   - WoltModalHeader (TopNavi)
   - WoltDetailOption (64×64px 버튼)
   - WoltCTAButton (이동/삭제 버튼)
   - WoltDeleteButton (작은 삭제 버튼)
   - WoltDateTimeSelector (날짜/시간 선택)
4. ⏳ **바텀시트 마이그레이션**:
   - FullScheduleBottomSheet → WoltScheduleSheet
   - FullTaskBottomSheet → WoltTaskSheet
   - HabitDetailPopup → WoltHabitSheet
   - 확인 모달들 → WoltConfirmDialog

---

**분석 완료!** 🎉

이제 완벽한 Apple 네이티브 수준의 디자인 시스템을 구축할 수 있습니다!
