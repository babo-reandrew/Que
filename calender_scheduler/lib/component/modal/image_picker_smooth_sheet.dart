import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../screen/loading_screen.dart'; // 🔍 LoadingScreen import

/// Wrapper that represents either an existing gallery AssetEntity or a
/// temporarily captured image file (not saved to album).
class PickedImage {
  final AssetEntity? asset;
  final XFile? file;

  PickedImage({this.asset, this.file}) : assert(asset != null || file != null);

  bool get isAsset => asset != null;
  bool get isFile => file != null;

  String idOrPath() => asset?.id ?? file?.path ?? '';
}

/// 📋 Image Picker Smooth Sheet - smooth_sheets 구현
/// 2단계 높이 조절: 45% (중간), 90% (최대)
class ImagePickerSmoothSheet extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(List<PickedImage>) onImagesSelected;

  const ImagePickerSmoothSheet({
    super.key,
    this.onClose,
    required this.onImagesSelected,
  });

  @override
  State<ImagePickerSmoothSheet> createState() => _ImagePickerSmoothSheetState();
}

class _ImagePickerSmoothSheetState extends State<ImagePickerSmoothSheet> {
  final SheetController _sheetController = SheetController();
  final List<PickedImage> _selectedImages = [];
  final List<AssetEntity> _galleryAssets = [];
  final List<PickedImage> _capturedPhotos = []; // 📸 카메라로 촬영한 사진들 (임시, 앨범에 저장 안함)
  bool _isLoading = false; // false로 변경 - 첫 로드를 위해
  final ImagePicker _imagePicker = ImagePicker();

  // 페이징 관련 상태
  AssetPathEntity? _currentPath;
  int _currentPage = 0;
  int _totalCount = 0;
  bool _hasMore = true;
  static const int _pageSize = 24; // 24개씩 로드
  bool _isLimitedAccess = false; // 제한적 권한 여부

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();

    // Sheet의 extent 변화 감지 - 일정 threshold 이하로 내려가면 자동으로 닫기
    _sheetController.addListener(_onSheetExtentChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetExtentChanged);
    _sheetController.dispose();
    super.dispose();
  }

  bool _isClosing = false; // 중복 호출 방지

  /// 🎯 버튼 클릭 시 즉시 닫기 (배경과 함께 사라지도록)
  void _closeSheetImmediately() {
    if (_isClosing) return;
    _isClosing = true;
    
    if (mounted && widget.onClose != null) {
      widget.onClose!();
    }
  }

  /// Sheet extent 변화 감지 - 임계값 이하로 내려가면 즉시 닫기
  void _onSheetExtentChanged() {
    if (_isClosing) return; // 이미 닫는 중이면 무시

    final metrics = _sheetController.value;
    final currentExtent = metrics.pixels;
    final maxExtent = metrics.maxPixels;

    if (maxExtent > 0) {
      final ratio = currentExtent / maxExtent;

      // 🎯 5% 이하로 내려가면 즉시 닫기 (배경과 함께 사라지도록)
      if (ratio < 0.05 && mounted) {
        _isClosing = true;
        if (widget.onClose != null) {
          widget.onClose!();
        }
      }
    }
  }

  /// 갤러리 이미지 로드 (페이징)
  Future<void> _loadGalleryImages() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.hasAccess) {
        print('❌ [ImagePicker] 갤러리 권한 거부됨');
        if (mounted) {
          _showPermissionDialog();
          setState(() => _isLoading = false);
        }
        return;
      }

      // 제한적 권한일 경우 알림
      if (ps.isAuth == false && ps.hasAccess) {
        print('⚠️ [ImagePicker] 제한적 갤러리 권한으로 접근 중');
        if (mounted) {
          setState(() {
            _isLimitedAccess = true;
          });
        }
      }

      // 첫 로드: 앨범 경로 가져오기
      if (_currentPath == null) {
        final List<AssetPathEntity> albums =
            await PhotoManager.getAssetPathList(
              type: RequestType.image,
              hasAll: true,
            );

        if (albums.isEmpty) {
          print('⚠️ [ImagePicker] 앨범이 비어있음 (제한적 권한일 수 있음)');
          if (mounted) {
            setState(() => _isLoading = false);
          }
          return;
        }

        _currentPath = albums.first;
        _totalCount = await _currentPath!.assetCountAsync;
        print(
          '✅ [ImagePicker] 총 이미지 개수: $_totalCount (제한적: $_isLimitedAccess)',
        );
      }

      // 페이징 로드
      final List<AssetEntity> assets = await _currentPath!.getAssetListPaged(
        page: _currentPage,
        size: _pageSize,
      );

      print('✅ [ImagePicker] Page $_currentPage 로드: ${assets.length}개');

      if (!mounted) return;

      setState(() {
        _galleryAssets.addAll(assets);
        _currentPage++;
        _hasMore = _galleryAssets.length < _totalCount;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [ImagePicker] 에러: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = (screenHeight - safeAreaTop - 8) / screenHeight;

    return Stack(
      children: [
        // 바텀시트
        ScrollableSheet(
          controller: _sheetController,
          initialExtent: const Extent.proportional(0.45), // 초기 45%
          physics: BouncingSheetPhysics(
            parent: SnappingSheetPhysics(
              snappingBehavior: SnapToNearest(
                snapTo: [
                  Extent.proportional(0.0), // 닫기 0% - 자연스러운 dismiss
                  Extent.proportional(0.45), // 중간 45%
                  Extent.proportional(0.90), // 최대 90%
                ],
              ),
            ),
          ),
          minExtent: const Extent.proportional(0.0), // 0%까지 내릴 수 있음 (닫기 위해)
          maxExtent: Extent.proportional(maxHeight),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                shape: SmoothRectangleBorder(
                  side: const BorderSide(
                    color: Color(0x14111111), // #111111 8%
                    width: 1,
                  ),
                  borderRadius: SmoothBorderRadius.vertical(
                    top: SmoothRadius(cornerRadius: 40, cornerSmoothing: 0.6),
                  ),
                ),
                child: Container(
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFCFCFC),
                    shape: SmoothRectangleBorder(
                      side: const BorderSide(
                        color: Color(0x14111111),
                        width: 1,
                      ),
                      borderRadius: SmoothBorderRadius.vertical(
                        top: SmoothRadius(
                          cornerRadius: 40,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x14BABABA),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 드래그 핸들 + TopNavi 전체를 SheetDraggable로 묶기
                      SheetDraggable(
                        child: Column(
                          children: [
                            // 드래그 핸들
                            Container(
                              color: Colors.transparent,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              height: 36,
                              child: Center(
                                child: Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0x1A111111),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                            ),
                            // TopNavi
                            _buildTopNaviContent(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 이미지 그리드
                      Expanded(child: _buildImageGrid()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 🎨 하단 네비 배경 (바텀 네비와 동일한 스타일)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              width: double.infinity,
              height: 104,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00FAFAFA), // 상단 0% #FAFAFA (투명)
                    Color(0xFFBABABA), // 하단 100% #BABABA (불투명)
                  ],
                ),
              ),
            ),
          ),
        ),

        // 📊 선택된 이미지 프리뷰 버튼 (Figma Frame 884)
        if (_selectedImages.isNotEmpty)
          Positioned(
            right: 24,
            bottom: 24,
            child: _buildSelectionPreviewButton(),
          ),
      ],
    );
  }

  /// 선택된 이미지 프리뷰 버튼
  Widget _buildSelectionPreviewButton() {
    return GestureDetector(
      onTap: () async {
        if (_isClosing) return;
        _isClosing = true;

        // 시트 닫기 (배경과 함께)
        if (mounted && widget.onClose != null) {
          widget.onClose!();
        }

        // 🔍 LoadingScreen으로 이동
        if (mounted) {
          // 약간의 딜레이 후 이동 (닫히는 애니메이션 완료 대기)
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    LoadingScreen(selectedImages: _selectedImages),
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF566099),
          border: Border.all(
            color: const Color(0x14111111), // #111111 8%
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A111111), // #111111 10%
              offset: Offset(0, 4),
              blurRadius: 30,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 선택된 이미지 개수
            Text(
              '${_selectedImages.length}',
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.4,
                letterSpacing: -0.005,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            // 화살표 아이콘
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TopNavi (72px): 画像で追加 + 닫기 버튼 (내용만)
  Widget _buildTopNaviContent() {
    return Container(
      height: 72,
      width: double.infinity, // 전체 너비 차지
      color: Colors.transparent, // 투명 색상으로 터치 영역 확보
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text(
            '画像で追加',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.095,
              color: Color(0xFF566099),
              height: 1.4,
            ),
          ),
          const Spacer(),
          // 닫기 버튼
          GestureDetector(
            onTap: () {
              // 🎯 즉시 닫기 (배경과 함께)
              _closeSheetImmediately();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E4E4).withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 20,
                color: Color(0xFF111111),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 이미지 그리드
  Widget _buildImageGrid() {
    if (_isLoading && _galleryAssets.isEmpty && _capturedPhotos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 갤러리가 비어있어도 제한적 권한이면 버튼들은 표시
    if (_galleryAssets.isEmpty &&
        _capturedPhotos.isEmpty &&
        !_isLimitedAccess) {
      return const Center(
        child: Text(
          '画像がありません',
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7A7A7A),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 9 / 16, // 9:16 비율 (세로로 길게)
      ),
      itemCount:
          1 +
          (_isLimitedAccess ? 1 : 0) + // 제한적 권한 시 추가 선택 버튼
          _capturedPhotos.length +
          _galleryAssets.length +
          (_isLoading ? 1 : 0), // 카메라 + 추가선택버튼 + 촬영사진 + 갤러리 + 로딩
      itemBuilder: (context, index) {
        // 첫 번째 아이템: 카메라 버튼
        if (index == 0) {
          return _buildCameraButton();
        }

        // 두 번째 아이템: 제한적 권한 시 추가 선택 버튼
        if (_isLimitedAccess && index == 1) {
          return _buildAddMoreButton();
        }

        final capturedCount = _capturedPhotos.length;
        final buttonOffset = _isLimitedAccess ? 2 : 1; // 카메라 + (추가선택)

        // 촬영한 사진 영역 (버튼들 바로 다음)
        if (index <= buttonOffset + capturedCount - 1) {
          final capturedIndex = index - buttonOffset;
          return _buildImageSlot(_capturedPhotos[capturedIndex]);
        }

        // 갤러리 사진 영역 (촬영한 사진들 뒤)
        final assetIndex = index - capturedCount - buttonOffset;

        // 스크롤 끝 감지 - 다음 페이지 로드
        if (assetIndex == _galleryAssets.length && _hasMore && !_isLoading) {
          _loadGalleryImages();
        }

        // 로딩 인디케이터
        if (_isLoading && assetIndex == _galleryAssets.length) {
          return Container(
            color: const Color(0xFFD3D3D3),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF566099)),
            ),
          );
        }

        if (assetIndex < _galleryAssets.length) {
          final asset = _galleryAssets[assetIndex];
          return _buildImageSlot(PickedImage(asset: asset));
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// 이미지 슬롯 (촬영사진 or 갤러리사진)
  Widget _buildImageSlot(PickedImage image) {
    final isSelected = _selectedImages.any(
      (img) => img.idOrPath() == image.idOrPath(),
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedImages.removeWhere(
              (img) => img.idOrPath() == image.idOrPath(),
            );
          } else {
            _selectedImages.add(image);
          }
        });
      },
      child: Stack(
        children: [
          // 이미지
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: image.isAsset && image.asset != null
                  ? AssetEntityImage(
                      image.asset!,
                      fit: BoxFit.cover,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize.square(
                        150,
                      ), // 150x150 압축 썸네일
                    )
                  : image.isFile && image.file != null
                  ? Image.file(
                      File(image.file!.path),
                      fit: BoxFit.cover,
                      cacheWidth: 150, // 압축된 크기로 메모리 캐시
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // 선택 표시 (SVG 아이콘)
          Positioned(
            right: 12,
            top: 12,
            child: SvgPicture.asset(
              isSelected
                  ? 'asset/icon/Selected.svg'
                  : 'asset/icon/NotSelected.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// 권한 거부 시 다이얼로그
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('写真へのアクセスが必要です'),
        content: const Text('写真を選択するには、設定で写真へのアクセスを許可してください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              PhotoManager.openSetting();
              Navigator.pop(context);
            },
            child: const Text('設定を開く'),
          ),
        ],
      ),
    );
  }

  /// 제한적 권한 시 추가 이미지 선택 (iOS 시스템 피커 사용)
  Future<void> _pickAdditionalImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isEmpty) {
        print('📸 [ImagePicker] 추가 이미지 선택 취소');
        return;
      }

      setState(() {
        for (var image in images) {
          final picked = PickedImage(file: image);
          _capturedPhotos.insert(0, picked);
        }
      });

      print('📸 [ImagePicker] 추가 이미지 ${images.length}개 선택됨');
    } catch (e) {
      print('📸 [ImagePicker] 추가 이미지 선택 에러: $e');
    }
  }

  /// 카메라 버튼
  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: () async {
        try {
          final XFile? photo = await _imagePicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
          );

          if (photo == null) {
            print('📸 [Camera] 촬영 취소');
            return;
          }

          // 임시 PickedImage 생성 (앨범에는 저장하지 않음)
          final picked = PickedImage(file: photo);

          setState(() {
            // 카메라 슬롯 다음 앞부분에 추가 (앞에서부터 차례로 쌓음)
            _capturedPhotos.insert(0, picked);
          });

          print('📸 [Camera] 임시 이미지 추가: ${photo.path}');
        } catch (e) {
          print('📸 [Camera] 에러: $e');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4E4),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.camera_alt, size: 36, color: Color(0xFF566099)),
      ),
    );
  }

  /// 추가 이미지 선택 버튼 (제한적 권한 시)
  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: _pickAdditionalImages,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4E4),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: Color(0xFF566099),
            ),
            const SizedBox(height: 4),
            Text(
              '追加',
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF566099),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
