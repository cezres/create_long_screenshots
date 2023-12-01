part of 'image_caches_cubit.dart';

class ImageCachesState extends Equatable {
  const ImageCachesState({
    this.imageCache = const {},
  });

  final Map<int, Uint8List> imageCache;

  @override
  List<Object> get props => [
        imageCache.keys,
      ];

  ImageCachesState copyWith({
    Map<int, Uint8List>? imageCache,
  }) {
    return ImageCachesState(
      imageCache: imageCache ?? this.imageCache,
    );
  }
}
