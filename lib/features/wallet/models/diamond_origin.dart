
/// Origin of diamonds for Governance Weights in V5
enum DiamondOrigin {
  purchase,
  gameplayWin,
  dailyLogin,
  p2pTransfer,
  referral,
  adminGrant,
  verificationFee, // Specific for spent/burned logic
  unknown;

  /// Governance Weight (Multiplier)
  /// Gameplay/Skill earned diamonds have higher weight than purchased ones.
  double get governanceWeight {
    switch (this) {
      case DiamondOrigin.gameplayWin: return 2.0; // High skill value
      case DiamondOrigin.purchase: return 0.5; // Lower voting power
      case DiamondOrigin.dailyLogin: return 1.0;
      case DiamondOrigin.p2pTransfer: return 0.8;
      case DiamondOrigin.referral: return 1.0;
      default: return 1.0;
    }
  }
  
  String get displayName {
     switch (this) {
      case DiamondOrigin.purchase: return 'Store Purchase';
      case DiamondOrigin.gameplayWin: return 'Gameplay Winnings';
      case DiamondOrigin.dailyLogin: return 'Daily Login';
      case DiamondOrigin.p2pTransfer: return 'Transfers';
      case DiamondOrigin.referral: return 'Referrals';
      case DiamondOrigin.adminGrant: return 'Admin Grant';
      case DiamondOrigin.verificationFee: return 'Verification Fee';
      case DiamondOrigin.unknown: return 'Unknown';
    }
  }
}
