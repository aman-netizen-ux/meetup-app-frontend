class PhoneCountry {
  const PhoneCountry({
    required this.name,
    required this.dialCode,
    required this.flag,
  });

  final String name;
  final String dialCode;
  final String flag;

  String get label => '$flag $name ($dialCode)';

  static const india = PhoneCountry(
    name: 'India',
    dialCode: '+91',
    flag: '🇮🇳',
  );

  static const supported = [
    india,
    PhoneCountry(name: 'United States', dialCode: '+1', flag: '🇺🇸'),
    PhoneCountry(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧'),
    PhoneCountry(name: 'United Arab Emirates', dialCode: '+971', flag: '🇦🇪'),
    PhoneCountry(name: 'Australia', dialCode: '+61', flag: '🇦🇺'),
    PhoneCountry(name: 'Singapore', dialCode: '+65', flag: '🇸🇬'),
    PhoneCountry(name: 'Germany', dialCode: '+49', flag: '🇩🇪'),
  ];
}
