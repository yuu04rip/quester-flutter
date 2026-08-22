// lib/models/mission_type.dart

enum MissionType {
  giornaliero(
    label: 'Giornaliero',
    dbValue: 'GIORNALIERO',
    xpReward: 30,
    coinReward: 1,
  ),
  settimanale(
    label: 'Settimanale',
    dbValue: 'SETTIMANALE',
    xpReward: 120,
    coinReward: 5,
  ),
  speciale(
    label: 'Speciale',
    dbValue: 'SPECIALE',
    xpReward: 400,
    coinReward: 15,
  );

  const MissionType({
    required this.label,
    required this.dbValue,
    required this.xpReward,
    required this.coinReward,
  });

  final String label;
  final String dbValue;
  final int xpReward;
  final int coinReward;

  static MissionType fromDbValue(String value) {
    return MissionType.values.firstWhere(
          (type) => type.dbValue.toLowerCase() == value.toLowerCase(),
      orElse: () => MissionType.giornaliero,
    );
  }
}