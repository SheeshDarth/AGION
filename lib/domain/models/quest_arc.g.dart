// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_arc.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestArcAdapter extends TypeAdapter<QuestArc> {
  @override
  final int typeId = 6;

  @override
  QuestArc read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestArc(
      id: fields[0] as String,
      name: fields[1] as String,
      theme: fields[2] as String,
      description: fields[3] as String,
      emoji: fields[4] as String,
      durationWeeks: fields[5] as int,
      phases: (fields[6] as List).cast<ArcPhase>(),
      xpMultiplier: fields[7] as double,
      bossFight: fields[8] as BossFight?,
      difficulty: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QuestArc obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.theme)
      ..writeByte(3)..write(obj.description)
      ..writeByte(4)..write(obj.emoji)
      ..writeByte(5)..write(obj.durationWeeks)
      ..writeByte(6)..write(obj.phases)
      ..writeByte(7)..write(obj.xpMultiplier)
      ..writeByte(8)..write(obj.bossFight)
      ..writeByte(9)..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestArcAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArcPhaseAdapter extends TypeAdapter<ArcPhase> {
  @override
  final int typeId = 7;

  @override
  ArcPhase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArcPhase(
      name: fields[0] as String,
      description: fields[1] as String,
      weekNumber: fields[2] as int,
      exercises: (fields[3] as List).cast<ArcExercise>(),
      daysPerWeek: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ArcPhase obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)..write(obj.name)
      ..writeByte(1)..write(obj.description)
      ..writeByte(2)..write(obj.weekNumber)
      ..writeByte(3)..write(obj.exercises)
      ..writeByte(4)..write(obj.daysPerWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArcPhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArcExerciseAdapter extends TypeAdapter<ArcExercise> {
  @override
  final int typeId = 8;

  @override
  ArcExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArcExercise(
      name: fields[0] as String,
      sets: fields[1] as int,
      reps: fields[2] as int,
      weight: fields[3] as double,
      restSeconds: fields[4] as int,
      type: fields[5] as String,
      instruction: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ArcExercise obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.name)
      ..writeByte(1)..write(obj.sets)
      ..writeByte(2)..write(obj.reps)
      ..writeByte(3)..write(obj.weight)
      ..writeByte(4)..write(obj.restSeconds)
      ..writeByte(5)..write(obj.type)
      ..writeByte(6)..write(obj.instruction);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArcExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BossFightAdapter extends TypeAdapter<BossFight> {
  @override
  final int typeId = 9;

  @override
  BossFight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BossFight(
      name: fields[0] as String,
      description: fields[1] as String,
      challenges: (fields[2] as List).cast<ArcExercise>(),
      bonusXp: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BossFight obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.name)
      ..writeByte(1)..write(obj.description)
      ..writeByte(2)..write(obj.challenges)
      ..writeByte(3)..write(obj.bonusXp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BossFightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArcProgressAdapter extends TypeAdapter<ArcProgress> {
  @override
  final int typeId = 10;

  @override
  ArcProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArcProgress(
      arcId: fields[0] as String,
      currentPhase: fields[1] as int,
      currentDay: fields[2] as int,
      completedDays: fields[3] as int,
      bossDefeated: fields[4] as bool,
      startedAt: fields[5] as DateTime,
      completedAt: fields[6] as DateTime?,
      workoutDates: (fields[7] as List).cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, ArcProgress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.arcId)
      ..writeByte(1)..write(obj.currentPhase)
      ..writeByte(2)..write(obj.currentDay)
      ..writeByte(3)..write(obj.completedDays)
      ..writeByte(4)..write(obj.bossDefeated)
      ..writeByte(5)..write(obj.startedAt)
      ..writeByte(6)..write(obj.completedAt)
      ..writeByte(7)..write(obj.workoutDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArcProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
