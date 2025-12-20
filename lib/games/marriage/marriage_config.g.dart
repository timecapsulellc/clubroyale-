// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marriage_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarriageGameConfig _$MarriageGameConfigFromJson(Map<String, dynamic> json) =>
    _MarriageGameConfig(
      jokerBlocksDiscard: json['jokerBlocksDiscard'] as bool? ?? true,
      canPickupWildFromDiscard:
          json['canPickupWildFromDiscard'] as bool? ?? false,
      requirePureSequence: json['requirePureSequence'] as bool? ?? true,
      requireMarriageToWin: json['requireMarriageToWin'] as bool? ?? false,
      dubleeBonus: json['dubleeBonus'] as bool? ?? true,
      tunnelBonus: json['tunnelBonus'] as bool? ?? true,
      marriageBonus: json['marriageBonus'] as bool? ?? true,
      minSequenceLength: (json['minSequenceLength'] as num?)?.toInt() ?? 3,
      maxWildsInMeld: (json['maxWildsInMeld'] as num?)?.toInt() ?? 2,
      cardsPerPlayer: (json['cardsPerPlayer'] as num?)?.toInt() ?? 21,
      firstDrawFromDeck: json['firstDrawFromDeck'] as bool? ?? true,
      turnTimeoutSeconds: (json['turnTimeoutSeconds'] as num?)?.toInt() ?? 30,
      noLifePenalty: (json['noLifePenalty'] as num?)?.toInt() ?? 100,
      fullCountPenalty: (json['fullCountPenalty'] as num?)?.toInt() ?? 120,
      wrongDeclarationPenalty:
          (json['wrongDeclarationPenalty'] as num?)?.toInt() ?? 50,
      autoSortHand: json['autoSortHand'] as bool? ?? true,
      showMeldSuggestions: json['showMeldSuggestions'] as bool? ?? true,
      totalRounds: (json['totalRounds'] as num?)?.toInt() ?? 5,
      pointValue: (json['pointValue'] as num?)?.toDouble() ?? 1.0,
      sequencesRequiredToVisit:
          (json['sequencesRequiredToVisit'] as num?)?.toInt() ?? 3,
      allowDubleeVisit: json['allowDubleeVisit'] as bool? ?? true,
      dubleeCountRequired: (json['dubleeCountRequired'] as num?)?.toInt() ?? 7,
      tunnelAsSequence: json['tunnelAsSequence'] as bool? ?? true,
      mustVisitToPickDiscard: json['mustVisitToPickDiscard'] as bool? ?? false,
      tipluValue: (json['tipluValue'] as num?)?.toInt() ?? 3,
      popluValue: (json['popluValue'] as num?)?.toInt() ?? 2,
      jhipluValue: (json['jhipluValue'] as num?)?.toInt() ?? 2,
      alterValue: (json['alterValue'] as num?)?.toInt() ?? 5,
      manValue: (json['manValue'] as num?)?.toInt() ?? 2,
      isManEnabled: json['isManEnabled'] as bool? ?? true,
      enableKidnap: json['enableKidnap'] as bool? ?? true,
      enableMurder: json['enableMurder'] as bool? ?? false,
      unvisitedPenalty: (json['unvisitedPenalty'] as num?)?.toInt() ?? 10,
      visitedPenalty: (json['visitedPenalty'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$MarriageGameConfigToJson(_MarriageGameConfig instance) =>
    <String, dynamic>{
      'jokerBlocksDiscard': instance.jokerBlocksDiscard,
      'canPickupWildFromDiscard': instance.canPickupWildFromDiscard,
      'requirePureSequence': instance.requirePureSequence,
      'requireMarriageToWin': instance.requireMarriageToWin,
      'dubleeBonus': instance.dubleeBonus,
      'tunnelBonus': instance.tunnelBonus,
      'marriageBonus': instance.marriageBonus,
      'minSequenceLength': instance.minSequenceLength,
      'maxWildsInMeld': instance.maxWildsInMeld,
      'cardsPerPlayer': instance.cardsPerPlayer,
      'firstDrawFromDeck': instance.firstDrawFromDeck,
      'turnTimeoutSeconds': instance.turnTimeoutSeconds,
      'noLifePenalty': instance.noLifePenalty,
      'fullCountPenalty': instance.fullCountPenalty,
      'wrongDeclarationPenalty': instance.wrongDeclarationPenalty,
      'autoSortHand': instance.autoSortHand,
      'showMeldSuggestions': instance.showMeldSuggestions,
      'totalRounds': instance.totalRounds,
      'pointValue': instance.pointValue,
      'sequencesRequiredToVisit': instance.sequencesRequiredToVisit,
      'allowDubleeVisit': instance.allowDubleeVisit,
      'dubleeCountRequired': instance.dubleeCountRequired,
      'tunnelAsSequence': instance.tunnelAsSequence,
      'mustVisitToPickDiscard': instance.mustVisitToPickDiscard,
      'tipluValue': instance.tipluValue,
      'popluValue': instance.popluValue,
      'jhipluValue': instance.jhipluValue,
      'alterValue': instance.alterValue,
      'manValue': instance.manValue,
      'isManEnabled': instance.isManEnabled,
      'enableKidnap': instance.enableKidnap,
      'enableMurder': instance.enableMurder,
      'unvisitedPenalty': instance.unvisitedPenalty,
      'visitedPenalty': instance.visitedPenalty,
    };
