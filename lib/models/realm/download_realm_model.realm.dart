// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_realm_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class DownloadRealmModel extends _DownloadRealmModel
    with RealmEntity, RealmObjectBase, RealmObject {
  DownloadRealmModel(
    ObjectId id,
    String url,
    String type,
    String name,
    String size,
    int duration,
    String category,
    DateTime createdAt, {
    Iterable<int> thumbnail = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'url', url);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'size', size);
    RealmObjectBase.set(this, 'duration', duration);
    RealmObjectBase.set<RealmList<int>>(
        this, 'thumbnail', RealmList<int>(thumbnail));
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'createdAt', createdAt);
  }

  DownloadRealmModel._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get url => RealmObjectBase.get<String>(this, 'url') as String;
  @override
  set url(String value) => RealmObjectBase.set(this, 'url', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get size => RealmObjectBase.get<String>(this, 'size') as String;
  @override
  set size(String value) => RealmObjectBase.set(this, 'size', value);

  @override
  int get duration => RealmObjectBase.get<int>(this, 'duration') as int;
  @override
  set duration(int value) => RealmObjectBase.set(this, 'duration', value);

  @override
  RealmList<int> get thumbnail =>
      RealmObjectBase.get<int>(this, 'thumbnail') as RealmList<int>;
  @override
  set thumbnail(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  String get category =>
      RealmObjectBase.get<String>(this, 'category') as String;
  @override
  set category(String value) => RealmObjectBase.set(this, 'category', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  Stream<RealmObjectChanges<DownloadRealmModel>> get changes =>
      RealmObjectBase.getChanges<DownloadRealmModel>(this);

  @override
  Stream<RealmObjectChanges<DownloadRealmModel>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<DownloadRealmModel>(this, keyPaths);

  @override
  DownloadRealmModel freeze() =>
      RealmObjectBase.freezeObject<DownloadRealmModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'url': url.toEJson(),
      'type': type.toEJson(),
      'name': name.toEJson(),
      'size': size.toEJson(),
      'duration': duration.toEJson(),
      'thumbnail': thumbnail.toEJson(),
      'category': category.toEJson(),
      'createdAt': createdAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(DownloadRealmModel value) => value.toEJson();
  static DownloadRealmModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'url': EJsonValue url,
        'type': EJsonValue type,
        'name': EJsonValue name,
        'size': EJsonValue size,
        'duration': EJsonValue duration,
        'category': EJsonValue category,
        'createdAt': EJsonValue createdAt,
      } =>
        DownloadRealmModel(
          fromEJson(id),
          fromEJson(url),
          fromEJson(type),
          fromEJson(name),
          fromEJson(size),
          fromEJson(duration),
          fromEJson(category),
          fromEJson(createdAt),
          thumbnail: fromEJson(ejson['thumbnail']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(DownloadRealmModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, DownloadRealmModel, 'DownloadRealmModel', [
      SchemaProperty('id', RealmPropertyType.objectid),
      SchemaProperty('url', RealmPropertyType.string),
      SchemaProperty('type', RealmPropertyType.string),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('size', RealmPropertyType.string),
      SchemaProperty('duration', RealmPropertyType.int),
      SchemaProperty('thumbnail', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('category', RealmPropertyType.string),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
