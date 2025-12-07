// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameConfig _$GameConfigFromJson(Map<String, dynamic> json) => _GameConfig(
  pointValue: (json['pointValue'] as num?)?.toDouble() ?? 10,
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 8,
  allowAds: json['allowAds'] as bool? ?? true,
  totalRounds: (json['totalRounds'] as num?)?.toInt() ?? 5,
  bootAmount: (json['bootAmount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GameConfigToJson(_GameConfig instance) =>
    <String, dynamic>{
      'pointValue': instance.pointValue,
      'maxPlayers': instance.maxPlayers,
      'allowAds': instance.allowAds,
      'totalRounds': instance.totalRounds,
      'bootAmount': instance.bootAmount,
    };
