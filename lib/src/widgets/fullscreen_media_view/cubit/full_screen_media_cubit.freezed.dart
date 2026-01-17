// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'full_screen_media_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FullScreenMediaState implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'FullScreenMediaState'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FullScreenMediaState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'FullScreenMediaState()';
}


}

/// @nodoc
class $FullScreenMediaStateCopyWith<$Res>  {
$FullScreenMediaStateCopyWith(FullScreenMediaState _, $Res Function(FullScreenMediaState) __);
}


/// Adds pattern-matching-related methods to [FullScreenMediaState].
extension FullScreenMediaStatePatterns on FullScreenMediaState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<MediaItem> mediaItems,  int currentIndex,  Map<String, Uint8List?> imageCache,  bool showSelectionIndicators,  List<MediaItem> selectedMediaItems,  bool? isVideoPlaying,  double? videoPosition,  double? videoDuration,  bool? isVideoBuffering)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.mediaItems,_that.currentIndex,_that.imageCache,_that.showSelectionIndicators,_that.selectedMediaItems,_that.isVideoPlaying,_that.videoPosition,_that.videoDuration,_that.isVideoBuffering);case _Error() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<MediaItem> mediaItems,  int currentIndex,  Map<String, Uint8List?> imageCache,  bool showSelectionIndicators,  List<MediaItem> selectedMediaItems,  bool? isVideoPlaying,  double? videoPosition,  double? videoDuration,  bool? isVideoBuffering)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.mediaItems,_that.currentIndex,_that.imageCache,_that.showSelectionIndicators,_that.selectedMediaItems,_that.isVideoPlaying,_that.videoPosition,_that.videoDuration,_that.isVideoBuffering);case _Error():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<MediaItem> mediaItems,  int currentIndex,  Map<String, Uint8List?> imageCache,  bool showSelectionIndicators,  List<MediaItem> selectedMediaItems,  bool? isVideoPlaying,  double? videoPosition,  double? videoDuration,  bool? isVideoBuffering)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.mediaItems,_that.currentIndex,_that.imageCache,_that.showSelectionIndicators,_that.selectedMediaItems,_that.isVideoPlaying,_that.videoPosition,_that.videoDuration,_that.isVideoBuffering);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial with DiagnosticableTreeMixin implements FullScreenMediaState {
  const _Initial();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'FullScreenMediaState.initial'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'FullScreenMediaState.initial()';
}


}




/// @nodoc


class _Loading with DiagnosticableTreeMixin implements FullScreenMediaState {
  const _Loading();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'FullScreenMediaState.loading'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'FullScreenMediaState.loading()';
}


}




/// @nodoc


class _Loaded with DiagnosticableTreeMixin implements FullScreenMediaState {
  const _Loaded({required final  List<MediaItem> mediaItems, required this.currentIndex, required final  Map<String, Uint8List?> imageCache, required this.showSelectionIndicators, required final  List<MediaItem> selectedMediaItems, this.isVideoPlaying, this.videoPosition, this.videoDuration, this.isVideoBuffering}): _mediaItems = mediaItems,_imageCache = imageCache,_selectedMediaItems = selectedMediaItems;
  

 final  List<MediaItem> _mediaItems;
 List<MediaItem> get mediaItems {
  if (_mediaItems is EqualUnmodifiableListView) return _mediaItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaItems);
}

 final  int currentIndex;
 final  Map<String, Uint8List?> _imageCache;
 Map<String, Uint8List?> get imageCache {
  if (_imageCache is EqualUnmodifiableMapView) return _imageCache;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_imageCache);
}

 final  bool showSelectionIndicators;
 final  List<MediaItem> _selectedMediaItems;
 List<MediaItem> get selectedMediaItems {
  if (_selectedMediaItems is EqualUnmodifiableListView) return _selectedMediaItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedMediaItems);
}

 final  bool? isVideoPlaying;
 final  double? videoPosition;
 final  double? videoDuration;
 final  bool? isVideoBuffering;

/// Create a copy of FullScreenMediaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'FullScreenMediaState.loaded'))
    ..add(DiagnosticsProperty('mediaItems', mediaItems))..add(DiagnosticsProperty('currentIndex', currentIndex))..add(DiagnosticsProperty('imageCache', imageCache))..add(DiagnosticsProperty('showSelectionIndicators', showSelectionIndicators))..add(DiagnosticsProperty('selectedMediaItems', selectedMediaItems))..add(DiagnosticsProperty('isVideoPlaying', isVideoPlaying))..add(DiagnosticsProperty('videoPosition', videoPosition))..add(DiagnosticsProperty('videoDuration', videoDuration))..add(DiagnosticsProperty('isVideoBuffering', isVideoBuffering));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._mediaItems, _mediaItems)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&const DeepCollectionEquality().equals(other._imageCache, _imageCache)&&(identical(other.showSelectionIndicators, showSelectionIndicators) || other.showSelectionIndicators == showSelectionIndicators)&&const DeepCollectionEquality().equals(other._selectedMediaItems, _selectedMediaItems)&&(identical(other.isVideoPlaying, isVideoPlaying) || other.isVideoPlaying == isVideoPlaying)&&(identical(other.videoPosition, videoPosition) || other.videoPosition == videoPosition)&&(identical(other.videoDuration, videoDuration) || other.videoDuration == videoDuration)&&(identical(other.isVideoBuffering, isVideoBuffering) || other.isVideoBuffering == isVideoBuffering));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mediaItems),currentIndex,const DeepCollectionEquality().hash(_imageCache),showSelectionIndicators,const DeepCollectionEquality().hash(_selectedMediaItems),isVideoPlaying,videoPosition,videoDuration,isVideoBuffering);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'FullScreenMediaState.loaded(mediaItems: $mediaItems, currentIndex: $currentIndex, imageCache: $imageCache, showSelectionIndicators: $showSelectionIndicators, selectedMediaItems: $selectedMediaItems, isVideoPlaying: $isVideoPlaying, videoPosition: $videoPosition, videoDuration: $videoDuration, isVideoBuffering: $isVideoBuffering)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $FullScreenMediaStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<MediaItem> mediaItems, int currentIndex, Map<String, Uint8List?> imageCache, bool showSelectionIndicators, List<MediaItem> selectedMediaItems, bool? isVideoPlaying, double? videoPosition, double? videoDuration, bool? isVideoBuffering
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of FullScreenMediaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mediaItems = null,Object? currentIndex = null,Object? imageCache = null,Object? showSelectionIndicators = null,Object? selectedMediaItems = null,Object? isVideoPlaying = freezed,Object? videoPosition = freezed,Object? videoDuration = freezed,Object? isVideoBuffering = freezed,}) {
  return _then(_Loaded(
mediaItems: null == mediaItems ? _self._mediaItems : mediaItems // ignore: cast_nullable_to_non_nullable
as List<MediaItem>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,imageCache: null == imageCache ? _self._imageCache : imageCache // ignore: cast_nullable_to_non_nullable
as Map<String, Uint8List?>,showSelectionIndicators: null == showSelectionIndicators ? _self.showSelectionIndicators : showSelectionIndicators // ignore: cast_nullable_to_non_nullable
as bool,selectedMediaItems: null == selectedMediaItems ? _self._selectedMediaItems : selectedMediaItems // ignore: cast_nullable_to_non_nullable
as List<MediaItem>,isVideoPlaying: freezed == isVideoPlaying ? _self.isVideoPlaying : isVideoPlaying // ignore: cast_nullable_to_non_nullable
as bool?,videoPosition: freezed == videoPosition ? _self.videoPosition : videoPosition // ignore: cast_nullable_to_non_nullable
as double?,videoDuration: freezed == videoDuration ? _self.videoDuration : videoDuration // ignore: cast_nullable_to_non_nullable
as double?,isVideoBuffering: freezed == isVideoBuffering ? _self.isVideoBuffering : isVideoBuffering // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc


class _Error with DiagnosticableTreeMixin implements FullScreenMediaState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of FullScreenMediaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'FullScreenMediaState.error'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'FullScreenMediaState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $FullScreenMediaStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of FullScreenMediaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
