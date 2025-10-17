import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// 재사용 가능한 시간 입력 바텀시트
/// 이 위젯은 어디서든 시간을 선택할 때 사용할 수 있도록 설계됨
/// 부모 위젯에서 초기값을 받고, 시간 선택 후 콜백으로 결과를 전달함
class OptionBottomSheet extends StatefulWidget {
  final DateTime? initialStartTime; // 시작 시간 초기값 (없으면 현재 시간 기준으로 설정)
  final DateTime? initialEndTime; // 종료 시간 초기값 (없으면 시작 시간 + 1시간으로 설정)
  final Function(DateTime startTime, DateTime endTime)
  onTimeSelected; // 시간 선택 완료 시 호출되는 콜백

  const OptionBottomSheet({
    super.key,
    required this.onTimeSelected, // 콜백은 필수로 받아야 함
    this.initialStartTime, // 초기값은 선택사항
    this.initialEndTime, // 초기값은 선택사항
  });

  @override
  State<OptionBottomSheet> createState() => _OptionBottomSheetState();
}

class _OptionBottomSheetState extends State<OptionBottomSheet> {
  late DateTime _selectedStartTime; // 현재 선택된 시작 시간을 저장
  late DateTime _selectedEndTime; // 현재 선택된 종료 시간을 저장

  @override
  void initState() {
    super.initState();
    // 초기값이 있으면 사용하고, 없으면 기본값으로 설정
    // 이렇게 하면 부모에서 시간을 미리 설정해둘 수 있음
    _selectedStartTime =
        widget.initialStartTime ??
        DateTime.now().copyWith(hour: 9, minute: 0, second: 0, millisecond: 0);
    _selectedEndTime =
        widget.initialEndTime ??
        DateTime.now().copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);

    print('🕐 시간 입력 바텀시트 초기화 완료');
    print(
      '  - 시작 시간: ${_selectedStartTime.hour}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
    );
    print(
      '  - 종료 시간: ${_selectedEndTime.hour}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // 바텀시트 높이를 400px로 설정
      padding: const EdgeInsets.all(16), // 전체 패딩 16px
      decoration: BoxDecoration(
        color: Colors.white, // 배경색을 흰색으로 설정
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ), // 상단만 둥글게 처리
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 영역 - 제목과 완료 버튼
          _buildHeader(),
          SizedBox(height: 20), // 헤더와 내용 사이 간격
          // 시작 시간 선택 영역
          _buildTimeSelector(
            label: '시작 시간', // 라벨 텍스트
            selectedTime: _selectedStartTime, // 현재 선택된 시간
            onTimeChanged: (DateTime time) {
              // 시간이 변경되면 상태를 업데이트하고 콘솔에 출력
              setState(() {
                _selectedStartTime = time;
              });
              print(
                '⏰ 시작 시간 변경됨: ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              );
            },
          ),

          SizedBox(height: 20), // 시작 시간과 종료 시간 사이 간격
          // 종료 시간 선택 영역
          _buildTimeSelector(
            label: '종료 시간', // 라벨 텍스트
            selectedTime: _selectedEndTime, // 현재 선택된 시간
            onTimeChanged: (DateTime time) {
              // 시간이 변경되면 상태를 업데이트하고 콘솔에 출력
              setState(() {
                _selectedEndTime = time;
              });
              print(
                '⏰ 종료 시간 변경됨: ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              );
            },
          ),

          SizedBox(height: 30), // 시간 선택과 완료 버튼 사이 간격
          // 완료 버튼
          _buildCompleteButton(),
        ],
      ),
    );
  }

  /// 헤더 영역을 구성하는 함수
  /// 제목과 완료 버튼을 포함하여 사용자가 무엇을 하고 있는지 명확하게 표시
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 양 끝 정렬
      children: [
        Text(
          '시간 선택', // 바텀시트 제목
          style: TextStyle(
            fontSize: 20, // 제목 크기
            fontWeight: FontWeight.bold, // 굵은 글씨
            color: Colors.black87, // 제목 색상
          ),
        ),
        TextButton(
          onPressed: () {
            // 완료 버튼을 누르면 선택된 시간을 부모에게 전달하고 바텀시트를 닫음
            print('✅ 시간 선택 완료');
            print(
              '  - 최종 시작 시간: ${_selectedStartTime.hour}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
            );
            print(
              '  - 최종 종료 시간: ${_selectedEndTime.hour}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
            );
            widget.onTimeSelected(
              _selectedStartTime,
              _selectedEndTime,
            ); // 부모에게 결과 전달
            Navigator.pop(context); // 바텀시트 닫기
          },
          child: Text(
            '완료',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue, // 완료 버튼 색상
            ),
          ),
        ),
      ],
    );
  }

  /// 시간 선택기를 구성하는 함수
  /// 라벨과 현재 시간을 표시하고, 터치하면 시간 선택 다이얼로그를 표시
  Widget _buildTimeSelector({
    required String label, // 시간 선택기 라벨 (예: "시작 시간", "종료 시간")
    required DateTime selectedTime, // 현재 선택된 시간
    required ValueChanged<DateTime> onTimeChanged, // 시간 변경 시 호출되는 콜백
  }) {
    return GestureDetector(
      onTap: () => _showTimePicker(
        context,
        label,
        selectedTime,
        onTimeChanged,
      ), // 터치하면 시간 선택기 표시
      child: Container(
        width: double.infinity, // 전체 너비 사용
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // 내부 패딩
        decoration: BoxDecoration(
          color: Colors.grey[50], // 배경색을 연한 회색으로 설정
          borderRadius: BorderRadius.circular(12), // 둥근 모서리
          border: Border.all(color: Colors.grey[300]!), // 테두리 추가
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 양 끝 정렬
          children: [
            // 라벨과 시간 표시
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
              children: [
                Text(
                  label, // 라벨 텍스트 (예: "시작 시간")
                  style: TextStyle(
                    fontSize: 14, // 라벨 크기
                    color: Colors.grey[600], // 라벨 색상
                    fontWeight: FontWeight.w500, // 라벨 굵기
                  ),
                ),
                SizedBox(height: 4), // 라벨과 시간 사이 간격
                Text(
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}', // 시간 표시 (예: "09:00")
                  style: TextStyle(
                    fontSize: 18, // 시간 크기
                    color: Colors.black87, // 시간 색상
                    fontWeight: FontWeight.w600, // 시간 굵기
                  ),
                ),
              ],
            ),
            // 시계 아이콘
            Icon(
              Icons.access_time, // 시계 아이콘
              color: Colors.grey[600], // 아이콘 색상
              size: 24, // 아이콘 크기
            ),
          ],
        ),
      ),
    );
  }

  /// 완료 버튼을 구성하는 함수
  /// 선택된 시간을 부모에게 전달하고 바텀시트를 닫는 역할
  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity, // 전체 너비 사용
      child: ElevatedButton(
        onPressed: () {
          // 완료 버튼을 누르면 선택된 시간을 부모에게 전달하고 바텀시트를 닫음
          print('✅ 시간 선택 완료 버튼 클릭');
          print(
            '  - 최종 시작 시간: ${_selectedStartTime.hour}:${_selectedStartTime.minute.toString().padLeft(2, '0')}',
          );
          print(
            '  - 최종 종료 시간: ${_selectedEndTime.hour}:${_selectedEndTime.minute.toString().padLeft(2, '0')}',
          );
          widget.onTimeSelected(
            _selectedStartTime,
            _selectedEndTime,
          ); // 부모에게 결과 전달
          Navigator.pop(context); // 바텀시트 닫기
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // 버튼 배경색을 검은색으로 설정
          foregroundColor: Colors.white, // 버튼 텍스트 색상을 흰색으로 설정
          padding: EdgeInsets.symmetric(vertical: 16), // 버튼 내부 패딩
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 버튼 모서리를 둥글게 처리
          ),
        ),
        child: Text(
          '완료', // 버튼 텍스트
          style: TextStyle(
            fontSize: 16, // 텍스트 크기
            fontWeight: FontWeight.w600, // 텍스트 굵기
          ),
        ),
      ),
    );
  }

  /// 시간 선택 다이얼로그를 표시하는 함수
  /// 애플 스타일의 CupertinoDatePicker를 사용하여 시간을 선택할 수 있게 함
  void _showTimePicker(
    BuildContext context,
    String label, // 다이얼로그 제목으로 사용할 라벨
    DateTime initialTime, // 초기 시간
    ValueChanged<DateTime> onTimeChanged, // 시간 변경 시 호출되는 콜백
  ) {
    print('🕐 시간 선택 다이얼로그 표시: $label');

    showCupertinoModalPopup(
      context: context, // 현재 컨텍스트 사용
      builder: (context) => Container(
        height: 300, // 다이얼로그 높이
        color: Colors.white, // 배경색을 흰색으로 설정
        child: Column(
          children: [
            // 다이얼로그 헤더
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ), // 헤더 패딩
              decoration: BoxDecoration(
                color: Colors.grey[100], // 헤더 배경색
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!), // 하단 테두리
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 양 끝 정렬
                children: [
                  // 취소 버튼
                  CupertinoButton(
                    padding: EdgeInsets.zero, // 버튼 패딩 제거
                    onPressed: () {
                      print('❌ 시간 선택 취소: $label');
                      Navigator.pop(context); // 다이얼로그 닫기
                    },
                    child: Text(
                      '취소', // 취소 버튼 텍스트
                      style: TextStyle(
                        color: Colors.blue, // 취소 버튼 색상
                        fontSize: 16, // 텍스트 크기
                        fontWeight: FontWeight.w500, // 텍스트 굵기
                      ),
                    ),
                  ),
                  // 다이얼로그 제목
                  Text(
                    label, // 다이얼로그 제목 (예: "시작 시간", "종료 시간")
                    style: TextStyle(
                      fontSize: 18, // 제목 크기
                      fontWeight: FontWeight.w600, // 제목 굵기
                      color: Colors.black87, // 제목 색상
                    ),
                  ),
                  // 완료 버튼
                  CupertinoButton(
                    padding: EdgeInsets.zero, // 버튼 패딩 제거
                    onPressed: () {
                      print('✅ 시간 선택 완료: $label');
                      onTimeChanged(initialTime); // 선택된 시간을 콜백으로 전달
                      Navigator.pop(context); // 다이얼로그 닫기
                    },
                    child: Text(
                      '완료', // 완료 버튼 텍스트
                      style: TextStyle(
                        color: Colors.blue, // 완료 버튼 색상
                        fontSize: 16, // 텍스트 크기
                        fontWeight: FontWeight.w600, // 텍스트 굵기
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 시간 선택기
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time, // 시간 선택 모드로 설정
                initialDateTime: initialTime, // 초기 시간 설정
                use24hFormat: true, // 24시간 형식 사용
                onDateTimeChanged: (DateTime newTime) {
                  // 시간이 변경되면 초기 시간을 업데이트
                  initialTime = newTime;
                  print(
                    '⏰ 시간 변경됨: ${newTime.hour}:${newTime.minute.toString().padLeft(2, '0')}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
