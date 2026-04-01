// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitness_profile.dart';

class FitnessProfileAdapter extends TypeAdapter<FitnessProfile> {
  @override
  final int typeId = 11;

  @override
  FitnessProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FitnessProfile(
      fitnessLevel: fields[0] as String,
      primaryGoal: fields[1] as String,
      equipment: fields[2] as String,
      workoutDaysPerWeek: fields[3] as int,
      workoutMinutes: fields[4] as int,
      bodyWeight: fields[5] as double,
      age: fields[6] as int,
      gender: fields[7] as String,
      targetWeeks: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FitnessProfile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.fitnessLevel)
      ..writeByte(1)..write(obj.primaryGoal)
      ..writeByte(2)..write(obj.equipment)
      ..writeByte(3)..write(obj.workoutDaysPerWeek)
      ..writeByte(4)..write(obj.workoutMinutes)
      ..writeByte(5)..write(obj.bodyWeight)
      ..writeByte(6)..write(obj.age)
      ..writeByte(7)..write(obj.gender)
      ..writeByte(8)..write(obj.targetWeeks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FitnessProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
