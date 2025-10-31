import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get_it/get_it.dart';
import '../../../Database/schedule_database.dart';

/// 오디오 플레이어 상태
class AudioPlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isLoading;
  final String? errorMessage;
  final int? currentAudioContentId; // 🎵 현재 오디오 ID 추가

  const AudioPlayerState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isLoading = false,
    this.errorMessage,
    this.currentAudioContentId,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isLoading,
    String? errorMessage,
    int? currentAudioContentId,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentAudioContentId:
          currentAudioContentId ?? this.currentAudioContentId,
    );
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }
}

/// 오디오 플레이어 Provider
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();
  int? _currentAudioContentId;

  AudioPlayerNotifier() : super(const AudioPlayerState()) {
    _initListeners();
  }

  /// 리스너 초기화
  void _initListeners() {
    // 재생 상태 변경 리스너
    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading:
            playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering,
      );
    });

    // 재생 위치 변경 리스너
    _player.positionStream.listen((position) {
      state = state.copyWith(position: position);

      // 데이터베이스에 진행도 저장 (1초마다)
      if (_currentAudioContentId != null && position.inSeconds % 1 == 0) {
        _saveProgress();
      }
    });

    // 총 재생 시간 변경 리스너
    _player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  /// 오디오 초기화 및 로드
  Future<void> initAudio({
    required int audioContentId,
    required String audioPath,
    int? startPositionMs,
  }) async {
    try {
      _currentAudioContentId = audioContentId;
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentAudioContentId: audioContentId, // 🎵 상태에 ID 저장
      );

      // 오디오 파일 로드 (에셋)
      await _player.setAsset(audioPath);

      // 이전 재생 위치 복원
      if (startPositionMs != null && startPositionMs > 0) {
        await _player.seek(Duration(milliseconds: startPositionMs));
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '오디오 로드 실패: ${e.toString()}',
      );
    }
  }

  /// 재생/일시정지 토글
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// 재생
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      state = state.copyWith(errorMessage: '재생 실패: ${e.toString()}');
    }
  }

  /// 일시정지
  Future<void> pause() async {
    try {
      await _player.pause();
      await _saveProgress();
    } catch (e) {
      state = state.copyWith(errorMessage: '일시정지 실패: ${e.toString()}');
    }
  }

  /// 특정 위치로 이동
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      await _saveProgress();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Seek 실패: ${e.toString()}');
    }
  }

  /// 데이터베이스에 재생 진행도 저장
  Future<void> _saveProgress() async {
    if (_currentAudioContentId == null) return;

    try {
      await GetIt.I<AppDatabase>().updateAudioProgress(
        _currentAudioContentId!,
        state.position.inMilliseconds,
      );
    } catch (e) {
      // 진행도 저장 실패는 사용자에게 보여주지 않음
    }
  }

  /// 완료 표시
  Future<void> markAsCompleted() async {
    if (_currentAudioContentId == null) return;

    try {
      await GetIt.I<AppDatabase>().markInsightAsCompleted(
        _currentAudioContentId!,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: '완료 표시 실패: ${e.toString()}');
    }
  }

  /// 정리
  @override
  void dispose() {
    _saveProgress(); // 마지막 위치 저장
    _player.dispose();
    super.dispose();
  }
}

/// 오디오 플레이어 Provider 인스턴스
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
      return AudioPlayerNotifier();
    });

/// 🎵 현재 재생 중인 트랜스크립트 라인 Provider (최적화된 버전)
/// position이 변경될 때만 DB 쿼리를 수행하고, 같은 라인이면 업데이트하지 않음
final currentTranscriptLineProvider =
    StateNotifierProvider.autoDispose<CurrentLineNotifier, TranscriptLineData?>(
      (ref) {
        return CurrentLineNotifier(ref);
      },
    );

/// 현재 라인 Notifier (깜빡임 방지용 최적화)
class CurrentLineNotifier extends StateNotifier<TranscriptLineData?> {
  final Ref _ref;
  int? _lastPositionSeconds; // 초 단위로만 업데이트

  CurrentLineNotifier(this._ref) : super(null) {
    _init();
  }

  void _init() {
    // audioPlayerProvider를 listen (watch 대신 listen 사용)
    _ref.listen<AudioPlayerState>(audioPlayerProvider, (previous, next) {
      _updateCurrentLine(next);
    });
  }

  Future<void> _updateCurrentLine(AudioPlayerState audioState) async {
    final audioContentId = audioState.currentAudioContentId;
    if (audioContentId == null) {
      if (state != null) state = null;
      return;
    }

    // 🎯 최적화: 초 단위가 변경되었을 때만 DB 쿼리
    final currentSeconds = audioState.position.inSeconds;
    if (_lastPositionSeconds == currentSeconds) return;

    _lastPositionSeconds = currentSeconds;

    // DB에서 현재 라인 가져오기
    final positionMs = audioState.position.inMilliseconds;
    final newLine = await GetIt.I<AppDatabase>().getCurrentLine(
      audioContentId,
      positionMs,
    );

    // 🎯 최적화: 같은 라인이면 업데이트하지 않음 (깜빡임 방지)
    if (newLine?.id == state?.id) return;

    state = newLine;
  }
}
