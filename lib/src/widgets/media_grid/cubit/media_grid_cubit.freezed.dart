// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_grid_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MediaGridState implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MediaGridState'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaGridState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MediaGridState()';
}


}

/// @nodoc
class $MediaGridStateCopyWith<$Res>  {
$MediaGridStateCopyWith(MediaGridState _, $Res Function(MediaGridState) __);
}


/// Adds pattern-matching-related methods to [MediaGridState].
extension MediaGridStatePatterns on MediaGridState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _PermissionRequesting value)?  permissionRequesting,TResult Function( _PermissionDenied value)?  permissionDenied,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _PermissionRequesting() when permissionRequesting != null:
return permissionRequesting(_that);case _PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case _Loaded() when loaded != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _PermissionRequesting value)  permissionRequesting,required TResult Function( _PermissionDenied value)  permissionDenied,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _PermissionRequesting():
return permissionRequesting(_that);case _PermissionDenied():
return permissionDenied(_that);case _Loaded():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _PermissionRequesting value)?  permissionRequesting,TResult? Function( _PermissionDenied value)?  permissionDenied,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _PermissionRequesting() when permissionRequesting != null:
return permissionRequesting(_that);case _PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case _Loaded() when loaded != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  permissionRequesting,TResult Function()?  permissionDenied,TResult Function( List<MediaItem> mediaItems,  Map<String, Uint8List?> thumbnailCache,  bool hasMoreItems,  int currentOffset,  bool isLoadingMore,  bool showSelectionIndicators,  List<MediaItem> selectedMediaItems)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _PermissionRequesting() when permissionRequesting != null:
return permissionRequesting();case _PermissionDenied() when permissionDenied != null:
return permissionDenied();case _Loaded() when loaded != null:
return loaded(_that.mediaItems,_that.thumbnailCache,_that.hasMoreItems,_that.currentOffset,_that.isLoadingMore,_that.showSelectionIndicators,_that.selectedMediaItems);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  permissionRequesting,required TResult Function()  permissionDenied,required TResult Function( List<MediaItem> mediaItems,  Map<String, Uint8List?> thumbnailCache,  bool hasMoreItems,  int currentOffset,  bool isLoadingMore,  bool showSelectionIndicators,  List<MediaItem> selectedMediaItems)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _PermissionRequesting():
return permissionRequesting();case _PermissionDenied():
return permissionDenied();case _Loaded():
return loaded(_that.mediaItems,_that.thumbnailCache,_that.hasMoreItems,_that.currentOffset,_that.isLoadingMore,_that.showSelectionIndicators,_that.selectedMediaItems);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  permissionRequesting,TResult? Function()?  permissionDenied,TResult? Function( List<MediaItem> mediaItems,  Map<String, Uint8List?> thumbnailCache,  bool hasMoreItems,  int currentOffset,  bool isLoadingMore,  bool showSelectionIndicators,  List<MediaItem> selectedMediaItems)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _PermissionRequesting() when permissionRequesting != null:
return permissionRequesting();case _PermissionDenied() when permissionDenied != null:
return permissionDenied();case _Loaded() when loaded != null:
return loaded(_that.mediaItems,_that.thumbnailCache,_that.hasMoreItems,_that.currentOffset,_that.isLoadingMore,_that.showSelectionIndicators,_that.selectedMediaItems);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial with DiagnosticableTreeMixin implements MediaGridState {
  const _Initial();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MediaGridState.initial'))
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
  return 'MediaGridState.initial()';
}


}




/// @nodoc


class _Loading with DiagnosticableTreeMixin implements MediaGridState {
  const _Loading();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MediaGridState.loading'))
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
  return 'MediaGridState.loading()';
}


}




/// @nodoc


class _PermissionRequesting with DiagnosticableTreeMixin implements MediaGridState {
  const _PermissionRequesting();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MediaGridState.permissionRequesting'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PermissionRequesting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MediaGridState.permissionRequesting()';
}


}




/// @nodoc


class _PermissionDenied with DiagnosticableTreeMixin implements MediaGridState {
  const _PermissionDenied();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MediaGridState.permissionDenied'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PermissionDenied);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MediaGridState.permissionDenied()';
}


}




/// @nodoc


class _Loaded with DiagnosticableTreeMixin implements MediaGridState {
  const _Loaded({required final  List<MediaItem> mediaItems, required final  Map<String, Uint8List?> thumbnailCache, required this.hasMoreItems, required this.currentOffset, required this.isLoadingMore, required this.showSelectionIndicators, required final  List<MediaItem> selectedMediaItems}): _mediaItems = mediaItems,_thumbnailCache = thumbnailCache,_selectedMediaItems = selectedMediaItems;
  

 final  List<MediaItem> _mediaItems;
 List<MediaItem> get mediaItems {
  if (_mediaItems is EqualUnmodifiableListView) return _mediaItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaItems);
}

 final  Map<String, Uint8List?> _thumbnailCache;
 Map<String, Uint8List?> get thumbnailCache {
  if (_thumbnailCache is EqualUnmodifiableMapView) return _thumbnailCache;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_thumbnailCache);
}

 final  bool hasMoreItems;
 final  int currentOffset;
 final  bool isLoadingMore;
 final  bool showSelectionIndicators;
 final  List<MediaItem> _selectedMediaItems;
 List<MediaItem> get selectedMediaItems {
  if (_selectedMediaItems is EqualUnmodifiableListView) return _selectedMediaItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedMediaItems);
}


/// Create a copy of MediaGridState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MediaGridState.loaded'))
    ..add(DiagnosticsProperty('mediaItems', mediaItems))..add(DiagnosticsProperty('thumbnailCache', thumbnailCache))..add(DiagnosticsProperty('hasMoreItems', hasMoreItems))..add(DiagnosticsProperty('currentOffset', currentOffset))..add(DiagnosticsProperty('isLoadingMore', isLoadingMore))..add(DiagnosticsProperty('showSelectionIndicators', showSelectionIndicators))..add(DiagnosticsProperty('selectedMediaItems', selectedMediaItems));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._mediaItems, _mediaItems)&&const DeepCollectionEquality().equals(other._thumbnailCache, _thumbnailCache)&&(identical(other.hasMoreItems, hasMoreItems) || other.hasMoreItems == hasMoreItems)&&(identical(other.currentOffset, currentOffset) || other.currentOffset == currentOffset)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.showSelectionIndicators, showSelectionIndicators) || other.showSelectionIndicators == showSelectionIndicators)&&const DeepCollectionEquality().equals(other._selectedMediaItems, _selectedMediaItems));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mediaItems),const DeepCollectionEquality().hash(_thumbnailCache),hasMoreItems,currentOffset,isLoadingMore,showSelectionIndicators,const DeepCollectionEquality().hash(_selectedMediaItems));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MediaGridState.loaded(mediaItems: $mediaItems, thumbnailCache: $thumbnailCache, hasMoreItems: $hasMoreItems, currentOffset: $currentOffset, isLoadingMore: $isLoadingMore, showSelectionIndicators: $showSelectionIndicators, selectedMediaItems: $selectedMediaItems)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $MediaGridStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<MediaItem> mediaItems, Map<String, Uint8List?> thumbnailCache, bool hasMoreItems, int currentOffset, bool isLoadingMore, bool showSelectionIndicators, List<MediaItem> selectedMediaItems
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of MediaGridState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mediaItems = null,Object? thumbnailCache = null,Object? hasMoreItems = null,Object? currentOffset = null,Object? isLoadingMore = null,Object? showSelectionIndicators = null,Object? selectedMediaItems = null,}) {
  return _then(_Loaded(
mediaItems: null == mediaItems ? _self._mediaItems : mediaItems // ignore: cast_nullable_to_non_nullable
as List<MediaItem>,thumbnailCache: null == thumbnailCache ? _self._thumbnailCache : thumbnailCache // ignore: cast_nullable_to_non_nullable
as Map<String, Uint8List?>,hasMoreItems: null == hasMoreItems ? _self.hasMoreItems : hasMoreItems // ignore: cast_nullable_to_non_nullable
as bool,currentOffset: null == currentOffset ? _self.currentOffset : currentOffset // ignore: cast_nullable_to_non_nullable
as int,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,showSelectionIndicators: null == showSelectionIndicators ? _self.showSelectionIndicators : showSelectionIndicators // ignore: cast_nullable_to_non_nullable
as bool,selectedMediaItems: null == selectedMediaItems ? _self._selectedMediaItems : selectedMediaItems // ignore: cast_nullable_to_non_nullable
as List<MediaItem>,
  ));
}


}

/// @nodoc


class _Error with DiagnosticableTreeMixin implements MediaGridState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of MediaGridState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MediaGridState.error'))
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
  return 'MediaGridState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $MediaGridStateCopyWith<$Res> {
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

/// Create a copy of MediaGridState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
