// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscribeDataAdapter extends TypeAdapter<SubscribeData> {
  @override
  final int typeId = 0;

  @override
  SubscribeData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscribeData(
      name: fields[0] as String,
      check: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SubscribeData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.check);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscribeDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
