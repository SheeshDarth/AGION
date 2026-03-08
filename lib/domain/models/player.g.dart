// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator (manual for Hive)
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Player(
      uid: fields[0] as String,
      level: fields[1] as int,
      xp: fields[2] as int,
      rank: fields[3] as String,
      title: fields[4] as String,
      streak: fields[5] as int,
      lastActive: fields[6] as DateTime,
      displayName: fields[7] as String,
      dailyWaterTarget: fields[8] as int,
      stepGoal: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.xp)
      ..writeByte(3)
      ..write(obj.rank)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.streak)
      ..writeByte(6)
      ..write(obj.lastActive)
      ..writeByte(7)
      ..write(obj.displayName)
      ..writeByte(8)
      ..write(obj.dailyWaterTarget)
      ..writeByte(9)
      ..write(obj.stepGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
