// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      email: fields[4] as String,
      IM: fields[1] as String,
      phone: fields[5] as String,
      address: fields[6] as String,
      position: fields[7] as String,
      attribution: fields[8] as String,
      direction: fields[9] as String,
      entryDate: fields[10] as DateTime,
      senator: fields[11] as bool,
      token: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.IM)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.position)
      ..writeByte(8)
      ..write(obj.attribution)
      ..writeByte(9)
      ..write(obj.direction)
      ..writeByte(10)
      ..write(obj.entryDate)
      ..writeByte(11)
      ..write(obj.senator)
      ..writeByte(12)
      ..write(obj.token);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
