// Age Verification Service & Gate
//
// Mandatory 18+ verification before app access.
// Required for Google Play compliance.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clubroyale/core/constants/disclaimers.dart';

/// Age verification state management
class AgeVerificationService {
  static const String _ageVerifiedKey = 'age_verified';
  static const String _disclaimerAcceptedKey = 'disclaimer_accepted';
  static const String _verifiedAtKey = 'verified_at';
  
  final SharedPreferences _prefs;
  
  AgeVerificationService(this._prefs);
  
  bool get isAgeVerified => _prefs.getBool(_ageVerifiedKey) ?? false;
  bool get isDisclaimerAccepted => _prefs.getBool(_disclaimerAcceptedKey) ?? false;
  bool get canProceed => isAgeVerified && isDisclaimerAccepted;
  
  DateTime? get verifiedAt {
    final timestamp = _prefs.getInt(_verifiedAtKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  
  Future<void> setAgeVerified(bool value) async {
    await _prefs.setBool(_ageVerifiedKey, value);
    if (value) {
      await _prefs.setInt(_verifiedAtKey, DateTime.now().millisecondsSinceEpoch);
    }
  }
  
  Future<void> setDisclaimerAccepted(bool value) async {
    await _prefs.setBool(_disclaimerAcceptedKey, value);
  }
  
  Future<void> reset() async {
    await _prefs.remove(_ageVerifiedKey);
    await _prefs.remove(_disclaimerAcceptedKey);
    await _prefs.remove(_verifiedAtKey);
  }

  /// Factory to create with SharedPreferences
  static Future<AgeVerificationService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AgeVerificationService(prefs);
  }
}

/// Age verification dialog with checkboxes
class AgeVerificationDialog extends StatefulWidget {
  final VoidCallback onVerified;
  final VoidCallback onDeclined;
  
  const AgeVerificationDialog({
    super.key,
    required this.onVerified,
    required this.onDeclined,
  });
  
  @override
  State<AgeVerificationDialog> createState() => _AgeVerificationDialogState();
}

class _AgeVerificationDialogState extends State<AgeVerificationDialog> {
  bool _isOver18 = false;
  bool _acceptedTerms = false;
  bool _understandsNoRealMoney = false;
  
  bool get _canContinue => _isOver18 && _acceptedTerms && _understandsNoRealMoney;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user,
                  size: 48,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Age Verification Required',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Disclaimer box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(
                  Disclaimers.safeHarbor,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
              
              // Checkboxes
              _buildCheckbox(
                value: _isOver18,
                onChanged: (v) => setState(() => _isOver18 = v ?? false),
                title: 'I am 18 years of age or older',
                icon: Icons.cake,
              ),
              _buildCheckbox(
                value: _acceptedTerms,
                onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                title: 'I accept the terms and conditions',
                icon: Icons.description,
              ),
              _buildCheckbox(
                value: _understandsNoRealMoney,
                onChanged: (v) => setState(() => _understandsNoRealMoney = v ?? false),
                title: 'I understand this app does not process real money',
                icon: Icons.money_off,
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onDeclined,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _canContinue ? widget.onVerified : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: value ? Colors.green.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value ? Colors.green.shade300 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.green,
              ),
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: value ? Colors.black87 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget that shows age gate on app start
class AgeGateWrapper extends StatefulWidget {
  final Widget child;
  
  const AgeGateWrapper({
    super.key,
    required this.child,
  });
  
  @override
  State<AgeGateWrapper> createState() => _AgeGateWrapperState();
}

class _AgeGateWrapperState extends State<AgeGateWrapper> {
  AgeVerificationService? _service;
  bool _loading = true;
  bool _canProceed = false;
  
  @override
  void initState() {
    super.initState();
    _initService();
  }
  
  Future<void> _initService() async {
    _service = await AgeVerificationService.create();
    setState(() {
      _canProceed = _service!.canProceed;
      _loading = false;
    });
  }
  
  Future<void> _onVerified() async {
    await _service?.setAgeVerified(true);
    await _service?.setDisclaimerAccepted(true);
    setState(() {
      _canProceed = true;
    });
  }
  
  void _onDeclined() {
    // Show message and close app
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text(
          'You must be 18+ and accept the terms to use ClubRoyale.',
        ),
        actions: [
          FilledButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_canProceed) {
      return widget.child;
    }
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: AgeVerificationDialog(
          onVerified: _onVerified,
          onDeclined: _onDeclined,
        ),
      ),
    );
  }
}
