// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InitialImpl _$$InitialImplFromJson(Map<String, dynamic> json) =>
    _$InitialImpl(
      running: json['running'] as bool,
      count: json['count'] as int,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      currentTime: json['currentTime'] == null
          ? null
          : DateTime.parse(json['currentTime'] as String),
    );

Map<String, dynamic> _$$InitialImplToJson(_$InitialImpl instance) =>
    <String, dynamic>{
      'running': instance.running,
      'count': instance.count,
      'startTime': instance.startTime?.toIso8601String(),
      'currentTime': instance.currentTime?.toIso8601String(),
    };
