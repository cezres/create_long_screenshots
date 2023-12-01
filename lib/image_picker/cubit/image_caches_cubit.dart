import 'dart:async';
import 'dart:typed_data';

import 'package:create_long_screenshots/image_picker/image_picker.dart';
import 'package:create_long_screenshots/main.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sembast/sembast.dart';

part 'image_caches_state.dart';

final kImageCaches = ImageCachesCubit();

class ImageCachesCubit extends Cubit<ImageCachesState> {
  ImageCachesCubit() : super(const ImageCachesState());

  Future<List<SelectedImage>> pickImages(
    BuildContext context, {
    int limit = 0,
    int maxCompressImageWidth = kMaxCompressImageWidth,
  }) async {
    final results = await imagesPicker(
      context,
      limit: limit,
      maxCompressImageWidth: maxCompressImageWidth,
    );
    if (results.isEmpty) {
      return [];
    }
    // await _addImages(results);
    final ids = results.values.toList();
    ids.sort((a, b) => a.imageId.compareTo(b.imageId));
    return ids;
  }

  Future<void> removeImages(List<int> imageIds,
      {Transaction? transaction}) async {
    final imageCache = state.imageCache;
    for (final imageId in imageIds) {
      imageCache.remove(imageId);
    }
    emit(state.copyWith(imageCache: imageCache));

    await _removeImagesFromDB(imageIds, transaction: transaction);
  }

  final store = StoreRef<String, dynamic>.main();

  Future<void> addImages(Map<int, Uint8List> images) async {
    final imageCache = Map<int, Uint8List>.from(state.imageCache);
    for (final entry in images.entries) {
      imageCache[entry.key] = entry.value;
    }
    emit(state.copyWith(imageCache: imageCache));

    await _addImagesToDB(images);
  }

  Future<void> _addImagesToDB(Map<int, Uint8List> images) async {
    kDatabase.transaction((transaction) async {
      for (final entry in images.entries) {
        final record = imageRecord(entry.key);
        await record.put(transaction, entry.value);
      }
    });
  }

  Future<void> _removeImagesFromDB(List<int> imageIds,
      {Transaction? transaction}) async {
    if (transaction != null) {
      for (final imageId in imageIds) {
        final record = imageRecord(imageId);
        await record.delete(transaction);
      }
    } else {
      await kDatabase.transaction((transaction) async {
        for (final imageId in imageIds) {
          final record = imageRecord(imageId);
          await record.delete(transaction);
        }
      });
    }
  }

  RecordRef<String, dynamic> imageRecord(int imageId) =>
      store.record('image_$imageId');

  void loadCachedImage(int imageId) async {
    if (state.imageCache.containsKey(imageId)) {
      return;
    }
    if (_loadingImageIds.contains(imageId)) {
      return;
    }

    _loadingImageIds.add(imageId);

    _loadCachedImages();
  }

  Future waitLoaded() async {
    if (_loadingImageIds.isEmpty) {
      return;
    }
    return _streamController.stream.firstWhere((element) => element);
  }

  // 等待2秒钟后加载资源文件
  void waitLoaded1Seconds() async {
    _isLoading = true;
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    if (_loadingImageIds.isNotEmpty) {
      _loadCachedImages();
    }
  }

  bool _isLoading = false;
  final Set<int> _loadingImageIds = {};
  final StreamController<bool> _streamController = StreamController.broadcast();

  void _loadCachedImages() async {
    if (_isLoading) {
      return;
    }
    if (_loadingImageIds.isEmpty) {
      return;
    }

    _isLoading = true;

    try {
      final imageId = _loadingImageIds.first;
      _loadingImageIds.remove(imageId);

      final bytes = await kDatabase.transaction(
        (transaction) async {
          final record = imageRecord(imageId);
          final bytes = await record.get(transaction);
          if (bytes is List) {
            return Uint8List.fromList(bytes.cast());
          } else {
            throw Exception("bytes is not List");
          }
        },
      );

      final imageCache = Map<int, Uint8List>.from(state.imageCache);
      imageCache[imageId] = bytes;
      emit(state.copyWith(imageCache: imageCache));
    } catch (e) {
      debugPrint(e.toString());
    }
    await Future.delayed(const Duration(milliseconds: 40));

    _streamController.add(_loadingImageIds.isEmpty);

    _isLoading = false;

    if (_loadingImageIds.isNotEmpty) {
      _loadCachedImages();
    }
  }
}
