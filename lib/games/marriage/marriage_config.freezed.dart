// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marriage_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarriageGameConfig {

// === Core Rules ===
/// Joker Block Rule: When a Joker is discarded, next player
/// CANNOT pick from discard pile, must draw from deck.
 bool get jokerBlocksDiscard;/// Wild Card Pickup: If false, players cannot pick Tiplu/Jhiplu/Poplu
/// from discard pile.
 bool get canPickupWildFromDiscard;/// Pure Sequence Required: Must have at least one pure sequence
/// (no wilds) to declare. "No Life" penalty applies otherwise.
 bool get requirePureSequence;/// Marriage Required: Must have Jhiplu+Tiplu+Poplu combo to declare.
 bool get requireMarriageToWin;// === Bonus Rules ===
/// Dublee Bonus: Award 25 points for two sequences of same suit.
 bool get dubleeBonus;/// Tunnel Bonus: Award points for 3 cards of same rank AND suit.
/// If shown before first draw, award 5 pts (authentic Nepali rule).
 bool get tunnelBonus;/// Tunnel display bonus value (shown before first draw).
 int get tunnelDisplayBonusValue;/// Marriage Bonus: Award 10 points for Jhiplu+Tiplu+Poplu combo of same suit.
 bool get marriageBonus;/// Marriage combo value (Jhiplu+Tiplu+Poplu).
 int get marriageBonusValue;/// 8-Dublee Win: Player can win by holding 8 pairs of same rank+suit.
 bool get eightDubleeWinEnabled;/// Bonus points for winning with 8 Dublees.
 int get eightDubleeWinBonus;// === Limits ===
/// Minimum cards required for a valid sequence.
 int get minSequenceLength;/// Maximum wild cards allowed in a single meld.
 int get maxWildsInMeld;/// Cards dealt per player.
 int get cardsPerPlayer;// === Turn Rules ===
/// First turn must draw from deck, cannot pick initial discard.
 bool get firstDrawFromDeck;/// Turn timeout in seconds (0 = no timeout).
 int get turnTimeoutSeconds;// === Scoring ===
/// Penalty for declaring without a pure sequence.
 int get noLifePenalty;/// Maximum penalty (full count - no melds at all).
 int get fullCountPenalty;/// Penalty for wrong/invalid declaration.
 int get wrongDeclarationPenalty;// === Display Options ===
/// Automatically sort hand by suit and rank.
 bool get autoSortHand;/// Show meld suggestions to help player.
 bool get showMeldSuggestions;/// Total rounds to play.
 int get totalRounds;/// Point value per unit (for settlements).
 double get pointValue;// === Visiting Rules (Gatekeeper Logic) ===
/// Number of pure sequences required to "Visit" (unlock Maal).
 int get sequencesRequiredToVisit;/// Allow Dublee Visit: Player can visit with 7 pairs instead of sequences.
 bool get allowDubleeVisit;/// Number of pairs required for Dublee visit.
 int get dubleeCountRequired;/// Tunnel counts as a sequence for visiting purposes.
 bool get tunnelAsSequence;/// Must visit before picking from discard pile (strict visiting).
 bool get mustVisitToPickDiscard;// === Maal (Value Card) System ===
/// Tiplu value (exact match of drawn wild card).
 int get tipluValue;/// Poplu value (rank +1, same suit as Tiplu).
 int get popluValue;/// Jhiplu value (rank -1, same suit as Tiplu).
 int get jhipluValue;/// Alter value (same rank+color, different suit as Tiplu).
 int get alterValue;/// Man (printed Joker) value.
 int get manValue;/// Enable Man (printed Joker) as Maal.
 bool get isManEnabled;/// Tunnel Pachaunu: Tunnel points (5/15/25) are VOIDED if player
/// fails to make at least 1 pure sequence (Phase 1).
 bool get tunnelPachaunu;// === Kidnap/Murder Rules ===
/// Kidnap: If winner and opponent not visited, opponent's Maal goes to winner.
 bool get enableKidnap;/// Murder: If not visited, Maal points are set to 0 (stricter than Kidnap).
 bool get enableMurder;/// Penalty for losing while not visited.
 int get unvisitedPenalty;/// Penalty for losing while visited.
 int get visitedPenalty;// === Open Mode (Training/Learning) ===
/// Open Mode: All player hands are visible to everyone.
/// Useful for learning, teaching, or spectator mode.
 bool get isOpenMode;
/// Create a copy of MarriageGameConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarriageGameConfigCopyWith<MarriageGameConfig> get copyWith => _$MarriageGameConfigCopyWithImpl<MarriageGameConfig>(this as MarriageGameConfig, _$identity);

  /// Serializes this MarriageGameConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarriageGameConfig&&(identical(other.jokerBlocksDiscard, jokerBlocksDiscard) || other.jokerBlocksDiscard == jokerBlocksDiscard)&&(identical(other.canPickupWildFromDiscard, canPickupWildFromDiscard) || other.canPickupWildFromDiscard == canPickupWildFromDiscard)&&(identical(other.requirePureSequence, requirePureSequence) || other.requirePureSequence == requirePureSequence)&&(identical(other.requireMarriageToWin, requireMarriageToWin) || other.requireMarriageToWin == requireMarriageToWin)&&(identical(other.dubleeBonus, dubleeBonus) || other.dubleeBonus == dubleeBonus)&&(identical(other.tunnelBonus, tunnelBonus) || other.tunnelBonus == tunnelBonus)&&(identical(other.tunnelDisplayBonusValue, tunnelDisplayBonusValue) || other.tunnelDisplayBonusValue == tunnelDisplayBonusValue)&&(identical(other.marriageBonus, marriageBonus) || other.marriageBonus == marriageBonus)&&(identical(other.marriageBonusValue, marriageBonusValue) || other.marriageBonusValue == marriageBonusValue)&&(identical(other.eightDubleeWinEnabled, eightDubleeWinEnabled) || other.eightDubleeWinEnabled == eightDubleeWinEnabled)&&(identical(other.eightDubleeWinBonus, eightDubleeWinBonus) || other.eightDubleeWinBonus == eightDubleeWinBonus)&&(identical(other.minSequenceLength, minSequenceLength) || other.minSequenceLength == minSequenceLength)&&(identical(other.maxWildsInMeld, maxWildsInMeld) || other.maxWildsInMeld == maxWildsInMeld)&&(identical(other.cardsPerPlayer, cardsPerPlayer) || other.cardsPerPlayer == cardsPerPlayer)&&(identical(other.firstDrawFromDeck, firstDrawFromDeck) || other.firstDrawFromDeck == firstDrawFromDeck)&&(identical(other.turnTimeoutSeconds, turnTimeoutSeconds) || other.turnTimeoutSeconds == turnTimeoutSeconds)&&(identical(other.noLifePenalty, noLifePenalty) || other.noLifePenalty == noLifePenalty)&&(identical(other.fullCountPenalty, fullCountPenalty) || other.fullCountPenalty == fullCountPenalty)&&(identical(other.wrongDeclarationPenalty, wrongDeclarationPenalty) || other.wrongDeclarationPenalty == wrongDeclarationPenalty)&&(identical(other.autoSortHand, autoSortHand) || other.autoSortHand == autoSortHand)&&(identical(other.showMeldSuggestions, showMeldSuggestions) || other.showMeldSuggestions == showMeldSuggestions)&&(identical(other.totalRounds, totalRounds) || other.totalRounds == totalRounds)&&(identical(other.pointValue, pointValue) || other.pointValue == pointValue)&&(identical(other.sequencesRequiredToVisit, sequencesRequiredToVisit) || other.sequencesRequiredToVisit == sequencesRequiredToVisit)&&(identical(other.allowDubleeVisit, allowDubleeVisit) || other.allowDubleeVisit == allowDubleeVisit)&&(identical(other.dubleeCountRequired, dubleeCountRequired) || other.dubleeCountRequired == dubleeCountRequired)&&(identical(other.tunnelAsSequence, tunnelAsSequence) || other.tunnelAsSequence == tunnelAsSequence)&&(identical(other.mustVisitToPickDiscard, mustVisitToPickDiscard) || other.mustVisitToPickDiscard == mustVisitToPickDiscard)&&(identical(other.tipluValue, tipluValue) || other.tipluValue == tipluValue)&&(identical(other.popluValue, popluValue) || other.popluValue == popluValue)&&(identical(other.jhipluValue, jhipluValue) || other.jhipluValue == jhipluValue)&&(identical(other.alterValue, alterValue) || other.alterValue == alterValue)&&(identical(other.manValue, manValue) || other.manValue == manValue)&&(identical(other.isManEnabled, isManEnabled) || other.isManEnabled == isManEnabled)&&(identical(other.tunnelPachaunu, tunnelPachaunu) || other.tunnelPachaunu == tunnelPachaunu)&&(identical(other.enableKidnap, enableKidnap) || other.enableKidnap == enableKidnap)&&(identical(other.enableMurder, enableMurder) || other.enableMurder == enableMurder)&&(identical(other.unvisitedPenalty, unvisitedPenalty) || other.unvisitedPenalty == unvisitedPenalty)&&(identical(other.visitedPenalty, visitedPenalty) || other.visitedPenalty == visitedPenalty)&&(identical(other.isOpenMode, isOpenMode) || other.isOpenMode == isOpenMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,jokerBlocksDiscard,canPickupWildFromDiscard,requirePureSequence,requireMarriageToWin,dubleeBonus,tunnelBonus,tunnelDisplayBonusValue,marriageBonus,marriageBonusValue,eightDubleeWinEnabled,eightDubleeWinBonus,minSequenceLength,maxWildsInMeld,cardsPerPlayer,firstDrawFromDeck,turnTimeoutSeconds,noLifePenalty,fullCountPenalty,wrongDeclarationPenalty,autoSortHand,showMeldSuggestions,totalRounds,pointValue,sequencesRequiredToVisit,allowDubleeVisit,dubleeCountRequired,tunnelAsSequence,mustVisitToPickDiscard,tipluValue,popluValue,jhipluValue,alterValue,manValue,isManEnabled,tunnelPachaunu,enableKidnap,enableMurder,unvisitedPenalty,visitedPenalty,isOpenMode]);

@override
String toString() {
  return 'MarriageGameConfig(jokerBlocksDiscard: $jokerBlocksDiscard, canPickupWildFromDiscard: $canPickupWildFromDiscard, requirePureSequence: $requirePureSequence, requireMarriageToWin: $requireMarriageToWin, dubleeBonus: $dubleeBonus, tunnelBonus: $tunnelBonus, tunnelDisplayBonusValue: $tunnelDisplayBonusValue, marriageBonus: $marriageBonus, marriageBonusValue: $marriageBonusValue, eightDubleeWinEnabled: $eightDubleeWinEnabled, eightDubleeWinBonus: $eightDubleeWinBonus, minSequenceLength: $minSequenceLength, maxWildsInMeld: $maxWildsInMeld, cardsPerPlayer: $cardsPerPlayer, firstDrawFromDeck: $firstDrawFromDeck, turnTimeoutSeconds: $turnTimeoutSeconds, noLifePenalty: $noLifePenalty, fullCountPenalty: $fullCountPenalty, wrongDeclarationPenalty: $wrongDeclarationPenalty, autoSortHand: $autoSortHand, showMeldSuggestions: $showMeldSuggestions, totalRounds: $totalRounds, pointValue: $pointValue, sequencesRequiredToVisit: $sequencesRequiredToVisit, allowDubleeVisit: $allowDubleeVisit, dubleeCountRequired: $dubleeCountRequired, tunnelAsSequence: $tunnelAsSequence, mustVisitToPickDiscard: $mustVisitToPickDiscard, tipluValue: $tipluValue, popluValue: $popluValue, jhipluValue: $jhipluValue, alterValue: $alterValue, manValue: $manValue, isManEnabled: $isManEnabled, tunnelPachaunu: $tunnelPachaunu, enableKidnap: $enableKidnap, enableMurder: $enableMurder, unvisitedPenalty: $unvisitedPenalty, visitedPenalty: $visitedPenalty, isOpenMode: $isOpenMode)';
}


}

/// @nodoc
abstract mixin class $MarriageGameConfigCopyWith<$Res>  {
  factory $MarriageGameConfigCopyWith(MarriageGameConfig value, $Res Function(MarriageGameConfig) _then) = _$MarriageGameConfigCopyWithImpl;
@useResult
$Res call({
 bool jokerBlocksDiscard, bool canPickupWildFromDiscard, bool requirePureSequence, bool requireMarriageToWin, bool dubleeBonus, bool tunnelBonus, int tunnelDisplayBonusValue, bool marriageBonus, int marriageBonusValue, bool eightDubleeWinEnabled, int eightDubleeWinBonus, int minSequenceLength, int maxWildsInMeld, int cardsPerPlayer, bool firstDrawFromDeck, int turnTimeoutSeconds, int noLifePenalty, int fullCountPenalty, int wrongDeclarationPenalty, bool autoSortHand, bool showMeldSuggestions, int totalRounds, double pointValue, int sequencesRequiredToVisit, bool allowDubleeVisit, int dubleeCountRequired, bool tunnelAsSequence, bool mustVisitToPickDiscard, int tipluValue, int popluValue, int jhipluValue, int alterValue, int manValue, bool isManEnabled, bool tunnelPachaunu, bool enableKidnap, bool enableMurder, int unvisitedPenalty, int visitedPenalty, bool isOpenMode
});




}
/// @nodoc
class _$MarriageGameConfigCopyWithImpl<$Res>
    implements $MarriageGameConfigCopyWith<$Res> {
  _$MarriageGameConfigCopyWithImpl(this._self, this._then);

  final MarriageGameConfig _self;
  final $Res Function(MarriageGameConfig) _then;

/// Create a copy of MarriageGameConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jokerBlocksDiscard = null,Object? canPickupWildFromDiscard = null,Object? requirePureSequence = null,Object? requireMarriageToWin = null,Object? dubleeBonus = null,Object? tunnelBonus = null,Object? tunnelDisplayBonusValue = null,Object? marriageBonus = null,Object? marriageBonusValue = null,Object? eightDubleeWinEnabled = null,Object? eightDubleeWinBonus = null,Object? minSequenceLength = null,Object? maxWildsInMeld = null,Object? cardsPerPlayer = null,Object? firstDrawFromDeck = null,Object? turnTimeoutSeconds = null,Object? noLifePenalty = null,Object? fullCountPenalty = null,Object? wrongDeclarationPenalty = null,Object? autoSortHand = null,Object? showMeldSuggestions = null,Object? totalRounds = null,Object? pointValue = null,Object? sequencesRequiredToVisit = null,Object? allowDubleeVisit = null,Object? dubleeCountRequired = null,Object? tunnelAsSequence = null,Object? mustVisitToPickDiscard = null,Object? tipluValue = null,Object? popluValue = null,Object? jhipluValue = null,Object? alterValue = null,Object? manValue = null,Object? isManEnabled = null,Object? tunnelPachaunu = null,Object? enableKidnap = null,Object? enableMurder = null,Object? unvisitedPenalty = null,Object? visitedPenalty = null,Object? isOpenMode = null,}) {
  return _then(_self.copyWith(
jokerBlocksDiscard: null == jokerBlocksDiscard ? _self.jokerBlocksDiscard : jokerBlocksDiscard // ignore: cast_nullable_to_non_nullable
as bool,canPickupWildFromDiscard: null == canPickupWildFromDiscard ? _self.canPickupWildFromDiscard : canPickupWildFromDiscard // ignore: cast_nullable_to_non_nullable
as bool,requirePureSequence: null == requirePureSequence ? _self.requirePureSequence : requirePureSequence // ignore: cast_nullable_to_non_nullable
as bool,requireMarriageToWin: null == requireMarriageToWin ? _self.requireMarriageToWin : requireMarriageToWin // ignore: cast_nullable_to_non_nullable
as bool,dubleeBonus: null == dubleeBonus ? _self.dubleeBonus : dubleeBonus // ignore: cast_nullable_to_non_nullable
as bool,tunnelBonus: null == tunnelBonus ? _self.tunnelBonus : tunnelBonus // ignore: cast_nullable_to_non_nullable
as bool,tunnelDisplayBonusValue: null == tunnelDisplayBonusValue ? _self.tunnelDisplayBonusValue : tunnelDisplayBonusValue // ignore: cast_nullable_to_non_nullable
as int,marriageBonus: null == marriageBonus ? _self.marriageBonus : marriageBonus // ignore: cast_nullable_to_non_nullable
as bool,marriageBonusValue: null == marriageBonusValue ? _self.marriageBonusValue : marriageBonusValue // ignore: cast_nullable_to_non_nullable
as int,eightDubleeWinEnabled: null == eightDubleeWinEnabled ? _self.eightDubleeWinEnabled : eightDubleeWinEnabled // ignore: cast_nullable_to_non_nullable
as bool,eightDubleeWinBonus: null == eightDubleeWinBonus ? _self.eightDubleeWinBonus : eightDubleeWinBonus // ignore: cast_nullable_to_non_nullable
as int,minSequenceLength: null == minSequenceLength ? _self.minSequenceLength : minSequenceLength // ignore: cast_nullable_to_non_nullable
as int,maxWildsInMeld: null == maxWildsInMeld ? _self.maxWildsInMeld : maxWildsInMeld // ignore: cast_nullable_to_non_nullable
as int,cardsPerPlayer: null == cardsPerPlayer ? _self.cardsPerPlayer : cardsPerPlayer // ignore: cast_nullable_to_non_nullable
as int,firstDrawFromDeck: null == firstDrawFromDeck ? _self.firstDrawFromDeck : firstDrawFromDeck // ignore: cast_nullable_to_non_nullable
as bool,turnTimeoutSeconds: null == turnTimeoutSeconds ? _self.turnTimeoutSeconds : turnTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,noLifePenalty: null == noLifePenalty ? _self.noLifePenalty : noLifePenalty // ignore: cast_nullable_to_non_nullable
as int,fullCountPenalty: null == fullCountPenalty ? _self.fullCountPenalty : fullCountPenalty // ignore: cast_nullable_to_non_nullable
as int,wrongDeclarationPenalty: null == wrongDeclarationPenalty ? _self.wrongDeclarationPenalty : wrongDeclarationPenalty // ignore: cast_nullable_to_non_nullable
as int,autoSortHand: null == autoSortHand ? _self.autoSortHand : autoSortHand // ignore: cast_nullable_to_non_nullable
as bool,showMeldSuggestions: null == showMeldSuggestions ? _self.showMeldSuggestions : showMeldSuggestions // ignore: cast_nullable_to_non_nullable
as bool,totalRounds: null == totalRounds ? _self.totalRounds : totalRounds // ignore: cast_nullable_to_non_nullable
as int,pointValue: null == pointValue ? _self.pointValue : pointValue // ignore: cast_nullable_to_non_nullable
as double,sequencesRequiredToVisit: null == sequencesRequiredToVisit ? _self.sequencesRequiredToVisit : sequencesRequiredToVisit // ignore: cast_nullable_to_non_nullable
as int,allowDubleeVisit: null == allowDubleeVisit ? _self.allowDubleeVisit : allowDubleeVisit // ignore: cast_nullable_to_non_nullable
as bool,dubleeCountRequired: null == dubleeCountRequired ? _self.dubleeCountRequired : dubleeCountRequired // ignore: cast_nullable_to_non_nullable
as int,tunnelAsSequence: null == tunnelAsSequence ? _self.tunnelAsSequence : tunnelAsSequence // ignore: cast_nullable_to_non_nullable
as bool,mustVisitToPickDiscard: null == mustVisitToPickDiscard ? _self.mustVisitToPickDiscard : mustVisitToPickDiscard // ignore: cast_nullable_to_non_nullable
as bool,tipluValue: null == tipluValue ? _self.tipluValue : tipluValue // ignore: cast_nullable_to_non_nullable
as int,popluValue: null == popluValue ? _self.popluValue : popluValue // ignore: cast_nullable_to_non_nullable
as int,jhipluValue: null == jhipluValue ? _self.jhipluValue : jhipluValue // ignore: cast_nullable_to_non_nullable
as int,alterValue: null == alterValue ? _self.alterValue : alterValue // ignore: cast_nullable_to_non_nullable
as int,manValue: null == manValue ? _self.manValue : manValue // ignore: cast_nullable_to_non_nullable
as int,isManEnabled: null == isManEnabled ? _self.isManEnabled : isManEnabled // ignore: cast_nullable_to_non_nullable
as bool,tunnelPachaunu: null == tunnelPachaunu ? _self.tunnelPachaunu : tunnelPachaunu // ignore: cast_nullable_to_non_nullable
as bool,enableKidnap: null == enableKidnap ? _self.enableKidnap : enableKidnap // ignore: cast_nullable_to_non_nullable
as bool,enableMurder: null == enableMurder ? _self.enableMurder : enableMurder // ignore: cast_nullable_to_non_nullable
as bool,unvisitedPenalty: null == unvisitedPenalty ? _self.unvisitedPenalty : unvisitedPenalty // ignore: cast_nullable_to_non_nullable
as int,visitedPenalty: null == visitedPenalty ? _self.visitedPenalty : visitedPenalty // ignore: cast_nullable_to_non_nullable
as int,isOpenMode: null == isOpenMode ? _self.isOpenMode : isOpenMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MarriageGameConfig].
extension MarriageGameConfigPatterns on MarriageGameConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarriageGameConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarriageGameConfig() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarriageGameConfig value)  $default,){
final _that = this;
switch (_that) {
case _MarriageGameConfig():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarriageGameConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MarriageGameConfig() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool jokerBlocksDiscard,  bool canPickupWildFromDiscard,  bool requirePureSequence,  bool requireMarriageToWin,  bool dubleeBonus,  bool tunnelBonus,  int tunnelDisplayBonusValue,  bool marriageBonus,  int marriageBonusValue,  bool eightDubleeWinEnabled,  int eightDubleeWinBonus,  int minSequenceLength,  int maxWildsInMeld,  int cardsPerPlayer,  bool firstDrawFromDeck,  int turnTimeoutSeconds,  int noLifePenalty,  int fullCountPenalty,  int wrongDeclarationPenalty,  bool autoSortHand,  bool showMeldSuggestions,  int totalRounds,  double pointValue,  int sequencesRequiredToVisit,  bool allowDubleeVisit,  int dubleeCountRequired,  bool tunnelAsSequence,  bool mustVisitToPickDiscard,  int tipluValue,  int popluValue,  int jhipluValue,  int alterValue,  int manValue,  bool isManEnabled,  bool tunnelPachaunu,  bool enableKidnap,  bool enableMurder,  int unvisitedPenalty,  int visitedPenalty,  bool isOpenMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarriageGameConfig() when $default != null:
return $default(_that.jokerBlocksDiscard,_that.canPickupWildFromDiscard,_that.requirePureSequence,_that.requireMarriageToWin,_that.dubleeBonus,_that.tunnelBonus,_that.tunnelDisplayBonusValue,_that.marriageBonus,_that.marriageBonusValue,_that.eightDubleeWinEnabled,_that.eightDubleeWinBonus,_that.minSequenceLength,_that.maxWildsInMeld,_that.cardsPerPlayer,_that.firstDrawFromDeck,_that.turnTimeoutSeconds,_that.noLifePenalty,_that.fullCountPenalty,_that.wrongDeclarationPenalty,_that.autoSortHand,_that.showMeldSuggestions,_that.totalRounds,_that.pointValue,_that.sequencesRequiredToVisit,_that.allowDubleeVisit,_that.dubleeCountRequired,_that.tunnelAsSequence,_that.mustVisitToPickDiscard,_that.tipluValue,_that.popluValue,_that.jhipluValue,_that.alterValue,_that.manValue,_that.isManEnabled,_that.tunnelPachaunu,_that.enableKidnap,_that.enableMurder,_that.unvisitedPenalty,_that.visitedPenalty,_that.isOpenMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool jokerBlocksDiscard,  bool canPickupWildFromDiscard,  bool requirePureSequence,  bool requireMarriageToWin,  bool dubleeBonus,  bool tunnelBonus,  int tunnelDisplayBonusValue,  bool marriageBonus,  int marriageBonusValue,  bool eightDubleeWinEnabled,  int eightDubleeWinBonus,  int minSequenceLength,  int maxWildsInMeld,  int cardsPerPlayer,  bool firstDrawFromDeck,  int turnTimeoutSeconds,  int noLifePenalty,  int fullCountPenalty,  int wrongDeclarationPenalty,  bool autoSortHand,  bool showMeldSuggestions,  int totalRounds,  double pointValue,  int sequencesRequiredToVisit,  bool allowDubleeVisit,  int dubleeCountRequired,  bool tunnelAsSequence,  bool mustVisitToPickDiscard,  int tipluValue,  int popluValue,  int jhipluValue,  int alterValue,  int manValue,  bool isManEnabled,  bool tunnelPachaunu,  bool enableKidnap,  bool enableMurder,  int unvisitedPenalty,  int visitedPenalty,  bool isOpenMode)  $default,) {final _that = this;
switch (_that) {
case _MarriageGameConfig():
return $default(_that.jokerBlocksDiscard,_that.canPickupWildFromDiscard,_that.requirePureSequence,_that.requireMarriageToWin,_that.dubleeBonus,_that.tunnelBonus,_that.tunnelDisplayBonusValue,_that.marriageBonus,_that.marriageBonusValue,_that.eightDubleeWinEnabled,_that.eightDubleeWinBonus,_that.minSequenceLength,_that.maxWildsInMeld,_that.cardsPerPlayer,_that.firstDrawFromDeck,_that.turnTimeoutSeconds,_that.noLifePenalty,_that.fullCountPenalty,_that.wrongDeclarationPenalty,_that.autoSortHand,_that.showMeldSuggestions,_that.totalRounds,_that.pointValue,_that.sequencesRequiredToVisit,_that.allowDubleeVisit,_that.dubleeCountRequired,_that.tunnelAsSequence,_that.mustVisitToPickDiscard,_that.tipluValue,_that.popluValue,_that.jhipluValue,_that.alterValue,_that.manValue,_that.isManEnabled,_that.tunnelPachaunu,_that.enableKidnap,_that.enableMurder,_that.unvisitedPenalty,_that.visitedPenalty,_that.isOpenMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool jokerBlocksDiscard,  bool canPickupWildFromDiscard,  bool requirePureSequence,  bool requireMarriageToWin,  bool dubleeBonus,  bool tunnelBonus,  int tunnelDisplayBonusValue,  bool marriageBonus,  int marriageBonusValue,  bool eightDubleeWinEnabled,  int eightDubleeWinBonus,  int minSequenceLength,  int maxWildsInMeld,  int cardsPerPlayer,  bool firstDrawFromDeck,  int turnTimeoutSeconds,  int noLifePenalty,  int fullCountPenalty,  int wrongDeclarationPenalty,  bool autoSortHand,  bool showMeldSuggestions,  int totalRounds,  double pointValue,  int sequencesRequiredToVisit,  bool allowDubleeVisit,  int dubleeCountRequired,  bool tunnelAsSequence,  bool mustVisitToPickDiscard,  int tipluValue,  int popluValue,  int jhipluValue,  int alterValue,  int manValue,  bool isManEnabled,  bool tunnelPachaunu,  bool enableKidnap,  bool enableMurder,  int unvisitedPenalty,  int visitedPenalty,  bool isOpenMode)?  $default,) {final _that = this;
switch (_that) {
case _MarriageGameConfig() when $default != null:
return $default(_that.jokerBlocksDiscard,_that.canPickupWildFromDiscard,_that.requirePureSequence,_that.requireMarriageToWin,_that.dubleeBonus,_that.tunnelBonus,_that.tunnelDisplayBonusValue,_that.marriageBonus,_that.marriageBonusValue,_that.eightDubleeWinEnabled,_that.eightDubleeWinBonus,_that.minSequenceLength,_that.maxWildsInMeld,_that.cardsPerPlayer,_that.firstDrawFromDeck,_that.turnTimeoutSeconds,_that.noLifePenalty,_that.fullCountPenalty,_that.wrongDeclarationPenalty,_that.autoSortHand,_that.showMeldSuggestions,_that.totalRounds,_that.pointValue,_that.sequencesRequiredToVisit,_that.allowDubleeVisit,_that.dubleeCountRequired,_that.tunnelAsSequence,_that.mustVisitToPickDiscard,_that.tipluValue,_that.popluValue,_that.jhipluValue,_that.alterValue,_that.manValue,_that.isManEnabled,_that.tunnelPachaunu,_that.enableKidnap,_that.enableMurder,_that.unvisitedPenalty,_that.visitedPenalty,_that.isOpenMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarriageGameConfig extends MarriageGameConfig {
  const _MarriageGameConfig({this.jokerBlocksDiscard = true, this.canPickupWildFromDiscard = false, this.requirePureSequence = true, this.requireMarriageToWin = false, this.dubleeBonus = true, this.tunnelBonus = true, this.tunnelDisplayBonusValue = 5, this.marriageBonus = true, this.marriageBonusValue = 10, this.eightDubleeWinEnabled = true, this.eightDubleeWinBonus = 5, this.minSequenceLength = 3, this.maxWildsInMeld = 2, this.cardsPerPlayer = 21, this.firstDrawFromDeck = true, this.turnTimeoutSeconds = 30, this.noLifePenalty = 100, this.fullCountPenalty = 120, this.wrongDeclarationPenalty = 50, this.autoSortHand = true, this.showMeldSuggestions = true, this.totalRounds = 5, this.pointValue = 1.0, this.sequencesRequiredToVisit = 3, this.allowDubleeVisit = true, this.dubleeCountRequired = 7, this.tunnelAsSequence = true, this.mustVisitToPickDiscard = false, this.tipluValue = 3, this.popluValue = 2, this.jhipluValue = 2, this.alterValue = 5, this.manValue = 2, this.isManEnabled = true, this.tunnelPachaunu = false, this.enableKidnap = true, this.enableMurder = false, this.unvisitedPenalty = 10, this.visitedPenalty = 3, this.isOpenMode = false}): super._();
  factory _MarriageGameConfig.fromJson(Map<String, dynamic> json) => _$MarriageGameConfigFromJson(json);

// === Core Rules ===
/// Joker Block Rule: When a Joker is discarded, next player
/// CANNOT pick from discard pile, must draw from deck.
@override@JsonKey() final  bool jokerBlocksDiscard;
/// Wild Card Pickup: If false, players cannot pick Tiplu/Jhiplu/Poplu
/// from discard pile.
@override@JsonKey() final  bool canPickupWildFromDiscard;
/// Pure Sequence Required: Must have at least one pure sequence
/// (no wilds) to declare. "No Life" penalty applies otherwise.
@override@JsonKey() final  bool requirePureSequence;
/// Marriage Required: Must have Jhiplu+Tiplu+Poplu combo to declare.
@override@JsonKey() final  bool requireMarriageToWin;
// === Bonus Rules ===
/// Dublee Bonus: Award 25 points for two sequences of same suit.
@override@JsonKey() final  bool dubleeBonus;
/// Tunnel Bonus: Award points for 3 cards of same rank AND suit.
/// If shown before first draw, award 5 pts (authentic Nepali rule).
@override@JsonKey() final  bool tunnelBonus;
/// Tunnel display bonus value (shown before first draw).
@override@JsonKey() final  int tunnelDisplayBonusValue;
/// Marriage Bonus: Award 10 points for Jhiplu+Tiplu+Poplu combo of same suit.
@override@JsonKey() final  bool marriageBonus;
/// Marriage combo value (Jhiplu+Tiplu+Poplu).
@override@JsonKey() final  int marriageBonusValue;
/// 8-Dublee Win: Player can win by holding 8 pairs of same rank+suit.
@override@JsonKey() final  bool eightDubleeWinEnabled;
/// Bonus points for winning with 8 Dublees.
@override@JsonKey() final  int eightDubleeWinBonus;
// === Limits ===
/// Minimum cards required for a valid sequence.
@override@JsonKey() final  int minSequenceLength;
/// Maximum wild cards allowed in a single meld.
@override@JsonKey() final  int maxWildsInMeld;
/// Cards dealt per player.
@override@JsonKey() final  int cardsPerPlayer;
// === Turn Rules ===
/// First turn must draw from deck, cannot pick initial discard.
@override@JsonKey() final  bool firstDrawFromDeck;
/// Turn timeout in seconds (0 = no timeout).
@override@JsonKey() final  int turnTimeoutSeconds;
// === Scoring ===
/// Penalty for declaring without a pure sequence.
@override@JsonKey() final  int noLifePenalty;
/// Maximum penalty (full count - no melds at all).
@override@JsonKey() final  int fullCountPenalty;
/// Penalty for wrong/invalid declaration.
@override@JsonKey() final  int wrongDeclarationPenalty;
// === Display Options ===
/// Automatically sort hand by suit and rank.
@override@JsonKey() final  bool autoSortHand;
/// Show meld suggestions to help player.
@override@JsonKey() final  bool showMeldSuggestions;
/// Total rounds to play.
@override@JsonKey() final  int totalRounds;
/// Point value per unit (for settlements).
@override@JsonKey() final  double pointValue;
// === Visiting Rules (Gatekeeper Logic) ===
/// Number of pure sequences required to "Visit" (unlock Maal).
@override@JsonKey() final  int sequencesRequiredToVisit;
/// Allow Dublee Visit: Player can visit with 7 pairs instead of sequences.
@override@JsonKey() final  bool allowDubleeVisit;
/// Number of pairs required for Dublee visit.
@override@JsonKey() final  int dubleeCountRequired;
/// Tunnel counts as a sequence for visiting purposes.
@override@JsonKey() final  bool tunnelAsSequence;
/// Must visit before picking from discard pile (strict visiting).
@override@JsonKey() final  bool mustVisitToPickDiscard;
// === Maal (Value Card) System ===
/// Tiplu value (exact match of drawn wild card).
@override@JsonKey() final  int tipluValue;
/// Poplu value (rank +1, same suit as Tiplu).
@override@JsonKey() final  int popluValue;
/// Jhiplu value (rank -1, same suit as Tiplu).
@override@JsonKey() final  int jhipluValue;
/// Alter value (same rank+color, different suit as Tiplu).
@override@JsonKey() final  int alterValue;
/// Man (printed Joker) value.
@override@JsonKey() final  int manValue;
/// Enable Man (printed Joker) as Maal.
@override@JsonKey() final  bool isManEnabled;
/// Tunnel Pachaunu: Tunnel points (5/15/25) are VOIDED if player
/// fails to make at least 1 pure sequence (Phase 1).
@override@JsonKey() final  bool tunnelPachaunu;
// === Kidnap/Murder Rules ===
/// Kidnap: If winner and opponent not visited, opponent's Maal goes to winner.
@override@JsonKey() final  bool enableKidnap;
/// Murder: If not visited, Maal points are set to 0 (stricter than Kidnap).
@override@JsonKey() final  bool enableMurder;
/// Penalty for losing while not visited.
@override@JsonKey() final  int unvisitedPenalty;
/// Penalty for losing while visited.
@override@JsonKey() final  int visitedPenalty;
// === Open Mode (Training/Learning) ===
/// Open Mode: All player hands are visible to everyone.
/// Useful for learning, teaching, or spectator mode.
@override@JsonKey() final  bool isOpenMode;

/// Create a copy of MarriageGameConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarriageGameConfigCopyWith<_MarriageGameConfig> get copyWith => __$MarriageGameConfigCopyWithImpl<_MarriageGameConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarriageGameConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarriageGameConfig&&(identical(other.jokerBlocksDiscard, jokerBlocksDiscard) || other.jokerBlocksDiscard == jokerBlocksDiscard)&&(identical(other.canPickupWildFromDiscard, canPickupWildFromDiscard) || other.canPickupWildFromDiscard == canPickupWildFromDiscard)&&(identical(other.requirePureSequence, requirePureSequence) || other.requirePureSequence == requirePureSequence)&&(identical(other.requireMarriageToWin, requireMarriageToWin) || other.requireMarriageToWin == requireMarriageToWin)&&(identical(other.dubleeBonus, dubleeBonus) || other.dubleeBonus == dubleeBonus)&&(identical(other.tunnelBonus, tunnelBonus) || other.tunnelBonus == tunnelBonus)&&(identical(other.tunnelDisplayBonusValue, tunnelDisplayBonusValue) || other.tunnelDisplayBonusValue == tunnelDisplayBonusValue)&&(identical(other.marriageBonus, marriageBonus) || other.marriageBonus == marriageBonus)&&(identical(other.marriageBonusValue, marriageBonusValue) || other.marriageBonusValue == marriageBonusValue)&&(identical(other.eightDubleeWinEnabled, eightDubleeWinEnabled) || other.eightDubleeWinEnabled == eightDubleeWinEnabled)&&(identical(other.eightDubleeWinBonus, eightDubleeWinBonus) || other.eightDubleeWinBonus == eightDubleeWinBonus)&&(identical(other.minSequenceLength, minSequenceLength) || other.minSequenceLength == minSequenceLength)&&(identical(other.maxWildsInMeld, maxWildsInMeld) || other.maxWildsInMeld == maxWildsInMeld)&&(identical(other.cardsPerPlayer, cardsPerPlayer) || other.cardsPerPlayer == cardsPerPlayer)&&(identical(other.firstDrawFromDeck, firstDrawFromDeck) || other.firstDrawFromDeck == firstDrawFromDeck)&&(identical(other.turnTimeoutSeconds, turnTimeoutSeconds) || other.turnTimeoutSeconds == turnTimeoutSeconds)&&(identical(other.noLifePenalty, noLifePenalty) || other.noLifePenalty == noLifePenalty)&&(identical(other.fullCountPenalty, fullCountPenalty) || other.fullCountPenalty == fullCountPenalty)&&(identical(other.wrongDeclarationPenalty, wrongDeclarationPenalty) || other.wrongDeclarationPenalty == wrongDeclarationPenalty)&&(identical(other.autoSortHand, autoSortHand) || other.autoSortHand == autoSortHand)&&(identical(other.showMeldSuggestions, showMeldSuggestions) || other.showMeldSuggestions == showMeldSuggestions)&&(identical(other.totalRounds, totalRounds) || other.totalRounds == totalRounds)&&(identical(other.pointValue, pointValue) || other.pointValue == pointValue)&&(identical(other.sequencesRequiredToVisit, sequencesRequiredToVisit) || other.sequencesRequiredToVisit == sequencesRequiredToVisit)&&(identical(other.allowDubleeVisit, allowDubleeVisit) || other.allowDubleeVisit == allowDubleeVisit)&&(identical(other.dubleeCountRequired, dubleeCountRequired) || other.dubleeCountRequired == dubleeCountRequired)&&(identical(other.tunnelAsSequence, tunnelAsSequence) || other.tunnelAsSequence == tunnelAsSequence)&&(identical(other.mustVisitToPickDiscard, mustVisitToPickDiscard) || other.mustVisitToPickDiscard == mustVisitToPickDiscard)&&(identical(other.tipluValue, tipluValue) || other.tipluValue == tipluValue)&&(identical(other.popluValue, popluValue) || other.popluValue == popluValue)&&(identical(other.jhipluValue, jhipluValue) || other.jhipluValue == jhipluValue)&&(identical(other.alterValue, alterValue) || other.alterValue == alterValue)&&(identical(other.manValue, manValue) || other.manValue == manValue)&&(identical(other.isManEnabled, isManEnabled) || other.isManEnabled == isManEnabled)&&(identical(other.tunnelPachaunu, tunnelPachaunu) || other.tunnelPachaunu == tunnelPachaunu)&&(identical(other.enableKidnap, enableKidnap) || other.enableKidnap == enableKidnap)&&(identical(other.enableMurder, enableMurder) || other.enableMurder == enableMurder)&&(identical(other.unvisitedPenalty, unvisitedPenalty) || other.unvisitedPenalty == unvisitedPenalty)&&(identical(other.visitedPenalty, visitedPenalty) || other.visitedPenalty == visitedPenalty)&&(identical(other.isOpenMode, isOpenMode) || other.isOpenMode == isOpenMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,jokerBlocksDiscard,canPickupWildFromDiscard,requirePureSequence,requireMarriageToWin,dubleeBonus,tunnelBonus,tunnelDisplayBonusValue,marriageBonus,marriageBonusValue,eightDubleeWinEnabled,eightDubleeWinBonus,minSequenceLength,maxWildsInMeld,cardsPerPlayer,firstDrawFromDeck,turnTimeoutSeconds,noLifePenalty,fullCountPenalty,wrongDeclarationPenalty,autoSortHand,showMeldSuggestions,totalRounds,pointValue,sequencesRequiredToVisit,allowDubleeVisit,dubleeCountRequired,tunnelAsSequence,mustVisitToPickDiscard,tipluValue,popluValue,jhipluValue,alterValue,manValue,isManEnabled,tunnelPachaunu,enableKidnap,enableMurder,unvisitedPenalty,visitedPenalty,isOpenMode]);

@override
String toString() {
  return 'MarriageGameConfig(jokerBlocksDiscard: $jokerBlocksDiscard, canPickupWildFromDiscard: $canPickupWildFromDiscard, requirePureSequence: $requirePureSequence, requireMarriageToWin: $requireMarriageToWin, dubleeBonus: $dubleeBonus, tunnelBonus: $tunnelBonus, tunnelDisplayBonusValue: $tunnelDisplayBonusValue, marriageBonus: $marriageBonus, marriageBonusValue: $marriageBonusValue, eightDubleeWinEnabled: $eightDubleeWinEnabled, eightDubleeWinBonus: $eightDubleeWinBonus, minSequenceLength: $minSequenceLength, maxWildsInMeld: $maxWildsInMeld, cardsPerPlayer: $cardsPerPlayer, firstDrawFromDeck: $firstDrawFromDeck, turnTimeoutSeconds: $turnTimeoutSeconds, noLifePenalty: $noLifePenalty, fullCountPenalty: $fullCountPenalty, wrongDeclarationPenalty: $wrongDeclarationPenalty, autoSortHand: $autoSortHand, showMeldSuggestions: $showMeldSuggestions, totalRounds: $totalRounds, pointValue: $pointValue, sequencesRequiredToVisit: $sequencesRequiredToVisit, allowDubleeVisit: $allowDubleeVisit, dubleeCountRequired: $dubleeCountRequired, tunnelAsSequence: $tunnelAsSequence, mustVisitToPickDiscard: $mustVisitToPickDiscard, tipluValue: $tipluValue, popluValue: $popluValue, jhipluValue: $jhipluValue, alterValue: $alterValue, manValue: $manValue, isManEnabled: $isManEnabled, tunnelPachaunu: $tunnelPachaunu, enableKidnap: $enableKidnap, enableMurder: $enableMurder, unvisitedPenalty: $unvisitedPenalty, visitedPenalty: $visitedPenalty, isOpenMode: $isOpenMode)';
}


}

/// @nodoc
abstract mixin class _$MarriageGameConfigCopyWith<$Res> implements $MarriageGameConfigCopyWith<$Res> {
  factory _$MarriageGameConfigCopyWith(_MarriageGameConfig value, $Res Function(_MarriageGameConfig) _then) = __$MarriageGameConfigCopyWithImpl;
@override @useResult
$Res call({
 bool jokerBlocksDiscard, bool canPickupWildFromDiscard, bool requirePureSequence, bool requireMarriageToWin, bool dubleeBonus, bool tunnelBonus, int tunnelDisplayBonusValue, bool marriageBonus, int marriageBonusValue, bool eightDubleeWinEnabled, int eightDubleeWinBonus, int minSequenceLength, int maxWildsInMeld, int cardsPerPlayer, bool firstDrawFromDeck, int turnTimeoutSeconds, int noLifePenalty, int fullCountPenalty, int wrongDeclarationPenalty, bool autoSortHand, bool showMeldSuggestions, int totalRounds, double pointValue, int sequencesRequiredToVisit, bool allowDubleeVisit, int dubleeCountRequired, bool tunnelAsSequence, bool mustVisitToPickDiscard, int tipluValue, int popluValue, int jhipluValue, int alterValue, int manValue, bool isManEnabled, bool tunnelPachaunu, bool enableKidnap, bool enableMurder, int unvisitedPenalty, int visitedPenalty, bool isOpenMode
});




}
/// @nodoc
class __$MarriageGameConfigCopyWithImpl<$Res>
    implements _$MarriageGameConfigCopyWith<$Res> {
  __$MarriageGameConfigCopyWithImpl(this._self, this._then);

  final _MarriageGameConfig _self;
  final $Res Function(_MarriageGameConfig) _then;

/// Create a copy of MarriageGameConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jokerBlocksDiscard = null,Object? canPickupWildFromDiscard = null,Object? requirePureSequence = null,Object? requireMarriageToWin = null,Object? dubleeBonus = null,Object? tunnelBonus = null,Object? tunnelDisplayBonusValue = null,Object? marriageBonus = null,Object? marriageBonusValue = null,Object? eightDubleeWinEnabled = null,Object? eightDubleeWinBonus = null,Object? minSequenceLength = null,Object? maxWildsInMeld = null,Object? cardsPerPlayer = null,Object? firstDrawFromDeck = null,Object? turnTimeoutSeconds = null,Object? noLifePenalty = null,Object? fullCountPenalty = null,Object? wrongDeclarationPenalty = null,Object? autoSortHand = null,Object? showMeldSuggestions = null,Object? totalRounds = null,Object? pointValue = null,Object? sequencesRequiredToVisit = null,Object? allowDubleeVisit = null,Object? dubleeCountRequired = null,Object? tunnelAsSequence = null,Object? mustVisitToPickDiscard = null,Object? tipluValue = null,Object? popluValue = null,Object? jhipluValue = null,Object? alterValue = null,Object? manValue = null,Object? isManEnabled = null,Object? tunnelPachaunu = null,Object? enableKidnap = null,Object? enableMurder = null,Object? unvisitedPenalty = null,Object? visitedPenalty = null,Object? isOpenMode = null,}) {
  return _then(_MarriageGameConfig(
jokerBlocksDiscard: null == jokerBlocksDiscard ? _self.jokerBlocksDiscard : jokerBlocksDiscard // ignore: cast_nullable_to_non_nullable
as bool,canPickupWildFromDiscard: null == canPickupWildFromDiscard ? _self.canPickupWildFromDiscard : canPickupWildFromDiscard // ignore: cast_nullable_to_non_nullable
as bool,requirePureSequence: null == requirePureSequence ? _self.requirePureSequence : requirePureSequence // ignore: cast_nullable_to_non_nullable
as bool,requireMarriageToWin: null == requireMarriageToWin ? _self.requireMarriageToWin : requireMarriageToWin // ignore: cast_nullable_to_non_nullable
as bool,dubleeBonus: null == dubleeBonus ? _self.dubleeBonus : dubleeBonus // ignore: cast_nullable_to_non_nullable
as bool,tunnelBonus: null == tunnelBonus ? _self.tunnelBonus : tunnelBonus // ignore: cast_nullable_to_non_nullable
as bool,tunnelDisplayBonusValue: null == tunnelDisplayBonusValue ? _self.tunnelDisplayBonusValue : tunnelDisplayBonusValue // ignore: cast_nullable_to_non_nullable
as int,marriageBonus: null == marriageBonus ? _self.marriageBonus : marriageBonus // ignore: cast_nullable_to_non_nullable
as bool,marriageBonusValue: null == marriageBonusValue ? _self.marriageBonusValue : marriageBonusValue // ignore: cast_nullable_to_non_nullable
as int,eightDubleeWinEnabled: null == eightDubleeWinEnabled ? _self.eightDubleeWinEnabled : eightDubleeWinEnabled // ignore: cast_nullable_to_non_nullable
as bool,eightDubleeWinBonus: null == eightDubleeWinBonus ? _self.eightDubleeWinBonus : eightDubleeWinBonus // ignore: cast_nullable_to_non_nullable
as int,minSequenceLength: null == minSequenceLength ? _self.minSequenceLength : minSequenceLength // ignore: cast_nullable_to_non_nullable
as int,maxWildsInMeld: null == maxWildsInMeld ? _self.maxWildsInMeld : maxWildsInMeld // ignore: cast_nullable_to_non_nullable
as int,cardsPerPlayer: null == cardsPerPlayer ? _self.cardsPerPlayer : cardsPerPlayer // ignore: cast_nullable_to_non_nullable
as int,firstDrawFromDeck: null == firstDrawFromDeck ? _self.firstDrawFromDeck : firstDrawFromDeck // ignore: cast_nullable_to_non_nullable
as bool,turnTimeoutSeconds: null == turnTimeoutSeconds ? _self.turnTimeoutSeconds : turnTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,noLifePenalty: null == noLifePenalty ? _self.noLifePenalty : noLifePenalty // ignore: cast_nullable_to_non_nullable
as int,fullCountPenalty: null == fullCountPenalty ? _self.fullCountPenalty : fullCountPenalty // ignore: cast_nullable_to_non_nullable
as int,wrongDeclarationPenalty: null == wrongDeclarationPenalty ? _self.wrongDeclarationPenalty : wrongDeclarationPenalty // ignore: cast_nullable_to_non_nullable
as int,autoSortHand: null == autoSortHand ? _self.autoSortHand : autoSortHand // ignore: cast_nullable_to_non_nullable
as bool,showMeldSuggestions: null == showMeldSuggestions ? _self.showMeldSuggestions : showMeldSuggestions // ignore: cast_nullable_to_non_nullable
as bool,totalRounds: null == totalRounds ? _self.totalRounds : totalRounds // ignore: cast_nullable_to_non_nullable
as int,pointValue: null == pointValue ? _self.pointValue : pointValue // ignore: cast_nullable_to_non_nullable
as double,sequencesRequiredToVisit: null == sequencesRequiredToVisit ? _self.sequencesRequiredToVisit : sequencesRequiredToVisit // ignore: cast_nullable_to_non_nullable
as int,allowDubleeVisit: null == allowDubleeVisit ? _self.allowDubleeVisit : allowDubleeVisit // ignore: cast_nullable_to_non_nullable
as bool,dubleeCountRequired: null == dubleeCountRequired ? _self.dubleeCountRequired : dubleeCountRequired // ignore: cast_nullable_to_non_nullable
as int,tunnelAsSequence: null == tunnelAsSequence ? _self.tunnelAsSequence : tunnelAsSequence // ignore: cast_nullable_to_non_nullable
as bool,mustVisitToPickDiscard: null == mustVisitToPickDiscard ? _self.mustVisitToPickDiscard : mustVisitToPickDiscard // ignore: cast_nullable_to_non_nullable
as bool,tipluValue: null == tipluValue ? _self.tipluValue : tipluValue // ignore: cast_nullable_to_non_nullable
as int,popluValue: null == popluValue ? _self.popluValue : popluValue // ignore: cast_nullable_to_non_nullable
as int,jhipluValue: null == jhipluValue ? _self.jhipluValue : jhipluValue // ignore: cast_nullable_to_non_nullable
as int,alterValue: null == alterValue ? _self.alterValue : alterValue // ignore: cast_nullable_to_non_nullable
as int,manValue: null == manValue ? _self.manValue : manValue // ignore: cast_nullable_to_non_nullable
as int,isManEnabled: null == isManEnabled ? _self.isManEnabled : isManEnabled // ignore: cast_nullable_to_non_nullable
as bool,tunnelPachaunu: null == tunnelPachaunu ? _self.tunnelPachaunu : tunnelPachaunu // ignore: cast_nullable_to_non_nullable
as bool,enableKidnap: null == enableKidnap ? _self.enableKidnap : enableKidnap // ignore: cast_nullable_to_non_nullable
as bool,enableMurder: null == enableMurder ? _self.enableMurder : enableMurder // ignore: cast_nullable_to_non_nullable
as bool,unvisitedPenalty: null == unvisitedPenalty ? _self.unvisitedPenalty : unvisitedPenalty // ignore: cast_nullable_to_non_nullable
as int,visitedPenalty: null == visitedPenalty ? _self.visitedPenalty : visitedPenalty // ignore: cast_nullable_to_non_nullable
as int,isOpenMode: null == isOpenMode ? _self.isOpenMode : isOpenMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
