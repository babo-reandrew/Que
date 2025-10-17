# Documentation Index

## 📚 프로젝트 문서 목록

모든 프로젝트 문서가 이 폴더에 정리되어 있습니다.

### � Typography System (신규 - 2025-10-16)
- 🔴 **`TYPOGRAPHY_RULES_MANDATORY.md`** - 필수 준수 규칙 (모든 개발자 필독!)
- ⚡ **`TYPOGRAPHY_QUICK_REFERENCE.md`** - 빠른 참조 가이드 (작업 시 항상 열어두기)
- 📖 **`TYPOGRAPHY_MIGRATION_COMPLETE.md`** - 전체 마이그레이션 보고서
- 📋 `TYPOGRAPHY_VIOLATIONS.md` - 위반 사항 목록 (아카이브)

### �🎯 Phase별 완료 보고서
- `PHASE_0_COMPLETE_REPORT.md` - Phase 0 완료 보고서
- `PHASE_1_PROVIDER_REFACTORING.md` - Phase 1 Provider 리팩토링
- `PHASE_6_COMPLETION_REPORT.md` - Phase 6 완료 보고서
- `PHASE_6_1_COMPLETION_REPORT.md` - Phase 6.1 완료 보고서
- `PHASE_7_COMPLETION_REPORT.md` - Phase 7 완료 보고서

### 🎨 디자인 시스템 & Figma
- `FIGMA_DESIGN_ANALYSIS.md` - Figma 디자인 분석
- `FIGMA_BOTTOM_SHEETS.md` - Figma 바텀시트 분석
- `QUICK_ADD_DESIGN_DIFF.md` - Quick Add 디자인 차이점 분석

### ⚡ Quick Add 구현
- `QUICK_ADD_ANIMATION_COMPLETE.md` - Quick Add 애니메이션 완료
- `QUICK_ADD_REFACTORING_COMPLETE.md` - Quick Add 리팩토링 완료
- `FRAME_705_IMPLEMENTATION.md` - Frame 705 구현 보고서
- `FRAME_TRANSITION_FIX.md` - Frame 전환 수정 보고서

### 🏗️ 아키텍처 & 데이터베이스
- `DATABASE_ARCHITECTURE.md` - 데이터베이스 아키텍처
- `DATA_FLOW_DIAGRAM.md` - 데이터 플로우 다이어그램

### 🔧 기술적 구현
- `KEYBOARD_FIXED_ANIMATION.md` - 키보드 고정 애니메이션
- `KEYBOARD_FIXED_LAYOUT.md` - 키보드 고정 레이아웃
- `KEYBOARD_POSITION_LOCK.md` - 키보드 위치 고정
- `BOTTOM_FIXED_LAYOUT.md` - 하단 고정 레이아웃
- `ABSOLUTE_POSITION_FINAL.md` - 절대 위치 최종 구현
- `Y_POSITION_FIX_COMPLETE.md` - Y 위치 수정 완료

### 🔍 분석 & 진단
- `BOTTOM_SHEET_DIAGNOSIS.md` - 바텀시트 진단
- `DUPLICATION_ANALYSIS.md` - 중복 분석
- `CRUD_VERIFICATION.md` - CRUD 검증
- `VALIDATION_SYSTEM.md` - 검증 시스템

### ⚙️ 설정 & 전략
- `MOTION_CONFIGURATION.md` - 모션 설정
- `WOLT_MIGRATION_STRATEGY.md` - Wolt 마이그레이션 전략
- `REFACTORING_REPORT.md` - 리팩토링 보고서

### 📝 프로젝트 정보
- `README.md` - 프로젝트 개요

---

**총 문서 수**: 28개
**생성 일자**: 2024-10-16
**정리 상태**: ✅ 완료

## 📂 폴더 구조

```
calender_scheduler/
├── docs/                           # 📚 모든 프로젝트 문서
│   ├── INDEX.md                   # 이 파일 (문서 목록)
│   ├── DATABASE_ARCHITECTURE.md  # 데이터베이스 아키텍처
│   ├── DATA_FLOW_DIAGRAM.md      # 데이터 플로우
│   ├── FIGMA_*.md                # Figma 디자인 분석
│   ├── QUICK_ADD_*.md            # Quick Add 구현
│   ├── FRAME_*.md                # Frame 구현
│   ├── KEYBOARD_*.md             # 키보드 관련
│   ├── PHASE_*.md                # Phase별 완료 보고서
│   └── ...                       # 기타 문서들
├── lib/                          # Flutter 소스 코드
├── android/                      # Android 설정
├── ios/                         # iOS 설정
└── README.md                    # 메인 README
```