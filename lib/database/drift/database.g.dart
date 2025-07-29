// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LocalAudiosTableTable extends LocalAudiosTable
    with TableInfo<$LocalAudiosTableTable, LocalAudiosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAudiosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<Uint8List> cover = GeneratedColumn<Uint8List>(
    'cover',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumMeta = const VerificationMeta(
    'trackNum',
  );
  @override
  late final GeneratedColumn<int> trackNum = GeneratedColumn<int>(
    'track_num',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isPodcastMeta = const VerificationMeta(
    'isPodcast',
  );
  @override
  late final GeneratedColumn<bool> isPodcast = GeneratedColumn<bool>(
    'is_podcast',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_podcast" IN (0, 1))',
    ),
    clientDefault: () => false,
  );
  static const VerificationMeta _isAlarmMeta = const VerificationMeta(
    'isAlarm',
  );
  @override
  late final GeneratedColumn<bool> isAlarm = GeneratedColumn<bool>(
    'is_alarm',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_alarm" IN (0, 1))',
    ),
    clientDefault: () => false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    title,
    duration,
    artist,
    album,
    cover,
    genre,
    trackNum,
    path,
    isPodcast,
    isAlarm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_audios_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAudiosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('track_num')) {
      context.handle(
        _trackNumMeta,
        trackNum.isAcceptableOrUnknown(data['track_num']!, _trackNumMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('is_podcast')) {
      context.handle(
        _isPodcastMeta,
        isPodcast.isAcceptableOrUnknown(data['is_podcast']!, _isPodcastMeta),
      );
    }
    if (data.containsKey('is_alarm')) {
      context.handle(
        _isAlarmMeta,
        isAlarm.isAcceptableOrUnknown(data['is_alarm']!, _isAlarmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAudiosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAudiosTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}cover'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      trackNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_num'],
      ),
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      isPodcast: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_podcast'],
      )!,
      isAlarm: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_alarm'],
      )!,
    );
  }

  @override
  $LocalAudiosTableTable createAlias(String alias) {
    return $LocalAudiosTableTable(attachedDatabase, alias);
  }
}

class LocalAudiosTableData extends DataClass
    implements Insertable<LocalAudiosTableData> {
  final int id;
  final DateTime createdAt;
  final String title;
  final int duration;
  final String? artist;
  final String? album;
  final Uint8List? cover;
  final String? genre;
  final int? trackNum;
  final String path;
  final bool isPodcast;
  final bool isAlarm;
  const LocalAudiosTableData({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.duration,
    this.artist,
    this.album,
    this.cover,
    this.genre,
    this.trackNum,
    required this.path,
    required this.isPodcast,
    required this.isAlarm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['title'] = Variable<String>(title);
    map['duration'] = Variable<int>(duration);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<Uint8List>(cover);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || trackNum != null) {
      map['track_num'] = Variable<int>(trackNum);
    }
    map['path'] = Variable<String>(path);
    map['is_podcast'] = Variable<bool>(isPodcast);
    map['is_alarm'] = Variable<bool>(isAlarm);
    return map;
  }

  LocalAudiosTableCompanion toCompanion(bool nullToAbsent) {
    return LocalAudiosTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      title: Value(title),
      duration: Value(duration),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      cover: cover == null && nullToAbsent
          ? const Value.absent()
          : Value(cover),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      trackNum: trackNum == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNum),
      path: Value(path),
      isPodcast: Value(isPodcast),
      isAlarm: Value(isAlarm),
    );
  }

  factory LocalAudiosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAudiosTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      title: serializer.fromJson<String>(json['title']),
      duration: serializer.fromJson<int>(json['duration']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      cover: serializer.fromJson<Uint8List?>(json['cover']),
      genre: serializer.fromJson<String?>(json['genre']),
      trackNum: serializer.fromJson<int?>(json['trackNum']),
      path: serializer.fromJson<String>(json['path']),
      isPodcast: serializer.fromJson<bool>(json['isPodcast']),
      isAlarm: serializer.fromJson<bool>(json['isAlarm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'title': serializer.toJson<String>(title),
      'duration': serializer.toJson<int>(duration),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'cover': serializer.toJson<Uint8List?>(cover),
      'genre': serializer.toJson<String?>(genre),
      'trackNum': serializer.toJson<int?>(trackNum),
      'path': serializer.toJson<String>(path),
      'isPodcast': serializer.toJson<bool>(isPodcast),
      'isAlarm': serializer.toJson<bool>(isAlarm),
    };
  }

  LocalAudiosTableData copyWith({
    int? id,
    DateTime? createdAt,
    String? title,
    int? duration,
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<Uint8List?> cover = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<int?> trackNum = const Value.absent(),
    String? path,
    bool? isPodcast,
    bool? isAlarm,
  }) => LocalAudiosTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    title: title ?? this.title,
    duration: duration ?? this.duration,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    cover: cover.present ? cover.value : this.cover,
    genre: genre.present ? genre.value : this.genre,
    trackNum: trackNum.present ? trackNum.value : this.trackNum,
    path: path ?? this.path,
    isPodcast: isPodcast ?? this.isPodcast,
    isAlarm: isAlarm ?? this.isAlarm,
  );
  LocalAudiosTableData copyWithCompanion(LocalAudiosTableCompanion data) {
    return LocalAudiosTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      title: data.title.present ? data.title.value : this.title,
      duration: data.duration.present ? data.duration.value : this.duration,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      cover: data.cover.present ? data.cover.value : this.cover,
      genre: data.genre.present ? data.genre.value : this.genre,
      trackNum: data.trackNum.present ? data.trackNum.value : this.trackNum,
      path: data.path.present ? data.path.value : this.path,
      isPodcast: data.isPodcast.present ? data.isPodcast.value : this.isPodcast,
      isAlarm: data.isAlarm.present ? data.isAlarm.value : this.isAlarm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAudiosTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('duration: $duration, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('cover: $cover, ')
          ..write('genre: $genre, ')
          ..write('trackNum: $trackNum, ')
          ..write('path: $path, ')
          ..write('isPodcast: $isPodcast, ')
          ..write('isAlarm: $isAlarm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    title,
    duration,
    artist,
    album,
    $driftBlobEquality.hash(cover),
    genre,
    trackNum,
    path,
    isPodcast,
    isAlarm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAudiosTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.title == this.title &&
          other.duration == this.duration &&
          other.artist == this.artist &&
          other.album == this.album &&
          $driftBlobEquality.equals(other.cover, this.cover) &&
          other.genre == this.genre &&
          other.trackNum == this.trackNum &&
          other.path == this.path &&
          other.isPodcast == this.isPodcast &&
          other.isAlarm == this.isAlarm);
}

class LocalAudiosTableCompanion extends UpdateCompanion<LocalAudiosTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> title;
  final Value<int> duration;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<Uint8List?> cover;
  final Value<String?> genre;
  final Value<int?> trackNum;
  final Value<String> path;
  final Value<bool> isPodcast;
  final Value<bool> isAlarm;
  const LocalAudiosTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.title = const Value.absent(),
    this.duration = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.cover = const Value.absent(),
    this.genre = const Value.absent(),
    this.trackNum = const Value.absent(),
    this.path = const Value.absent(),
    this.isPodcast = const Value.absent(),
    this.isAlarm = const Value.absent(),
  });
  LocalAudiosTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String title,
    required int duration,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.cover = const Value.absent(),
    this.genre = const Value.absent(),
    this.trackNum = const Value.absent(),
    required String path,
    this.isPodcast = const Value.absent(),
    this.isAlarm = const Value.absent(),
  }) : title = Value(title),
       duration = Value(duration),
       path = Value(path);
  static Insertable<LocalAudiosTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? title,
    Expression<int>? duration,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<Uint8List>? cover,
    Expression<String>? genre,
    Expression<int>? trackNum,
    Expression<String>? path,
    Expression<bool>? isPodcast,
    Expression<bool>? isAlarm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (title != null) 'title': title,
      if (duration != null) 'duration': duration,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (cover != null) 'cover': cover,
      if (genre != null) 'genre': genre,
      if (trackNum != null) 'track_num': trackNum,
      if (path != null) 'path': path,
      if (isPodcast != null) 'is_podcast': isPodcast,
      if (isAlarm != null) 'is_alarm': isAlarm,
    });
  }

  LocalAudiosTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? title,
    Value<int>? duration,
    Value<String?>? artist,
    Value<String?>? album,
    Value<Uint8List?>? cover,
    Value<String?>? genre,
    Value<int?>? trackNum,
    Value<String>? path,
    Value<bool>? isPodcast,
    Value<bool>? isAlarm,
  }) {
    return LocalAudiosTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      cover: cover ?? this.cover,
      genre: genre ?? this.genre,
      trackNum: trackNum ?? this.trackNum,
      path: path ?? this.path,
      isPodcast: isPodcast ?? this.isPodcast,
      isAlarm: isAlarm ?? this.isAlarm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (cover.present) {
      map['cover'] = Variable<Uint8List>(cover.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (trackNum.present) {
      map['track_num'] = Variable<int>(trackNum.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (isPodcast.present) {
      map['is_podcast'] = Variable<bool>(isPodcast.value);
    }
    if (isAlarm.present) {
      map['is_alarm'] = Variable<bool>(isAlarm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAudiosTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('duration: $duration, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('cover: $cover, ')
          ..write('genre: $genre, ')
          ..write('trackNum: $trackNum, ')
          ..write('path: $path, ')
          ..write('isPodcast: $isPodcast, ')
          ..write('isAlarm: $isAlarm')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTableTable extends PlaylistTable
    with TableInfo<$PlaylistTableTable, PlaylistTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioMeta = const VerificationMeta('audio');
  @override
  late final GeneratedColumn<int> audio = GeneratedColumn<int>(
    'audio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_audios_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, title, order, audio];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('audio')) {
      context.handle(
        _audioMeta,
        audio.isAcceptableOrUnknown(data['audio']!, _audioMeta),
      );
    } else if (isInserting) {
      context.missing(_audioMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      audio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio'],
      )!,
    );
  }

  @override
  $PlaylistTableTable createAlias(String alias) {
    return $PlaylistTableTable(attachedDatabase, alias);
  }
}

class PlaylistTableData extends DataClass
    implements Insertable<PlaylistTableData> {
  final int id;
  final DateTime createdAt;
  final String title;
  final int order;
  final int audio;
  const PlaylistTableData({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.order,
    required this.audio,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['title'] = Variable<String>(title);
    map['order'] = Variable<int>(order);
    map['audio'] = Variable<int>(audio);
    return map;
  }

  PlaylistTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      title: Value(title),
      order: Value(order),
      audio: Value(audio),
    );
  }

  factory PlaylistTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      title: serializer.fromJson<String>(json['title']),
      order: serializer.fromJson<int>(json['order']),
      audio: serializer.fromJson<int>(json['audio']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'title': serializer.toJson<String>(title),
      'order': serializer.toJson<int>(order),
      'audio': serializer.toJson<int>(audio),
    };
  }

  PlaylistTableData copyWith({
    int? id,
    DateTime? createdAt,
    String? title,
    int? order,
    int? audio,
  }) => PlaylistTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    title: title ?? this.title,
    order: order ?? this.order,
    audio: audio ?? this.audio,
  );
  PlaylistTableData copyWithCompanion(PlaylistTableCompanion data) {
    return PlaylistTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      title: data.title.present ? data.title.value : this.title,
      order: data.order.present ? data.order.value : this.order,
      audio: data.audio.present ? data.audio.value : this.audio,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('order: $order, ')
          ..write('audio: $audio')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, title, order, audio);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.title == this.title &&
          other.order == this.order &&
          other.audio == this.audio);
}

class PlaylistTableCompanion extends UpdateCompanion<PlaylistTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> title;
  final Value<int> order;
  final Value<int> audio;
  const PlaylistTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.title = const Value.absent(),
    this.order = const Value.absent(),
    this.audio = const Value.absent(),
  });
  PlaylistTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String title,
    required int order,
    required int audio,
  }) : title = Value(title),
       order = Value(order),
       audio = Value(audio);
  static Insertable<PlaylistTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? title,
    Expression<int>? order,
    Expression<int>? audio,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (title != null) 'title': title,
      if (order != null) 'order': order,
      if (audio != null) 'audio': audio,
    });
  }

  PlaylistTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? title,
    Value<int>? order,
    Value<int>? audio,
  }) {
    return PlaylistTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      order: order ?? this.order,
      audio: audio ?? this.audio,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (audio.present) {
      map['audio'] = Variable<int>(audio.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('order: $order, ')
          ..write('audio: $audio')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalAudiosTableTable localAudiosTable = $LocalAudiosTableTable(
    this,
  );
  late final $PlaylistTableTable playlistTable = $PlaylistTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localAudiosTable,
    playlistTable,
  ];
}

typedef $$LocalAudiosTableTableCreateCompanionBuilder =
    LocalAudiosTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      required String title,
      required int duration,
      Value<String?> artist,
      Value<String?> album,
      Value<Uint8List?> cover,
      Value<String?> genre,
      Value<int?> trackNum,
      required String path,
      Value<bool> isPodcast,
      Value<bool> isAlarm,
    });
typedef $$LocalAudiosTableTableUpdateCompanionBuilder =
    LocalAudiosTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String> title,
      Value<int> duration,
      Value<String?> artist,
      Value<String?> album,
      Value<Uint8List?> cover,
      Value<String?> genre,
      Value<int?> trackNum,
      Value<String> path,
      Value<bool> isPodcast,
      Value<bool> isAlarm,
    });

final class $$LocalAudiosTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalAudiosTableTable,
          LocalAudiosTableData
        > {
  $$LocalAudiosTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PlaylistTableTable, List<PlaylistTableData>>
  _playlistTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistTable,
    aliasName: $_aliasNameGenerator(
      db.localAudiosTable.id,
      db.playlistTable.audio,
    ),
  );

  $$PlaylistTableTableProcessedTableManager get playlistTableRefs {
    final manager = $$PlaylistTableTableTableManager(
      $_db,
      $_db.playlistTable,
    ).filter((f) => f.audio.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalAudiosTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAudiosTableTable> {
  $$LocalAudiosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNum => $composableBuilder(
    column: $table.trackNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPodcast => $composableBuilder(
    column: $table.isPodcast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlarm => $composableBuilder(
    column: $table.isAlarm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistTableRefs(
    Expression<bool> Function($$PlaylistTableTableFilterComposer f) f,
  ) {
    final $$PlaylistTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTable,
      getReferencedColumn: (t) => t.audio,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalAudiosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAudiosTableTable> {
  $$LocalAudiosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNum => $composableBuilder(
    column: $table.trackNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPodcast => $composableBuilder(
    column: $table.isPodcast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlarm => $composableBuilder(
    column: $table.isAlarm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAudiosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAudiosTableTable> {
  $$LocalAudiosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<Uint8List> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get trackNum =>
      $composableBuilder(column: $table.trackNum, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<bool> get isPodcast =>
      $composableBuilder(column: $table.isPodcast, builder: (column) => column);

  GeneratedColumn<bool> get isAlarm =>
      $composableBuilder(column: $table.isAlarm, builder: (column) => column);

  Expression<T> playlistTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTable,
      getReferencedColumn: (t) => t.audio,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalAudiosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAudiosTableTable,
          LocalAudiosTableData,
          $$LocalAudiosTableTableFilterComposer,
          $$LocalAudiosTableTableOrderingComposer,
          $$LocalAudiosTableTableAnnotationComposer,
          $$LocalAudiosTableTableCreateCompanionBuilder,
          $$LocalAudiosTableTableUpdateCompanionBuilder,
          (LocalAudiosTableData, $$LocalAudiosTableTableReferences),
          LocalAudiosTableData,
          PrefetchHooks Function({bool playlistTableRefs})
        > {
  $$LocalAudiosTableTableTableManager(
    _$AppDatabase db,
    $LocalAudiosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAudiosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAudiosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAudiosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<Uint8List?> cover = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> trackNum = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<bool> isPodcast = const Value.absent(),
                Value<bool> isAlarm = const Value.absent(),
              }) => LocalAudiosTableCompanion(
                id: id,
                createdAt: createdAt,
                title: title,
                duration: duration,
                artist: artist,
                album: album,
                cover: cover,
                genre: genre,
                trackNum: trackNum,
                path: path,
                isPodcast: isPodcast,
                isAlarm: isAlarm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String title,
                required int duration,
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<Uint8List?> cover = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> trackNum = const Value.absent(),
                required String path,
                Value<bool> isPodcast = const Value.absent(),
                Value<bool> isAlarm = const Value.absent(),
              }) => LocalAudiosTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                title: title,
                duration: duration,
                artist: artist,
                album: album,
                cover: cover,
                genre: genre,
                trackNum: trackNum,
                path: path,
                isPodcast: isPodcast,
                isAlarm: isAlarm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalAudiosTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistTableRefs) db.playlistTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistTableRefs)
                    await $_getPrefetchedData<
                      LocalAudiosTableData,
                      $LocalAudiosTableTable,
                      PlaylistTableData
                    >(
                      currentTable: table,
                      referencedTable: $$LocalAudiosTableTableReferences
                          ._playlistTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LocalAudiosTableTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.audio == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalAudiosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAudiosTableTable,
      LocalAudiosTableData,
      $$LocalAudiosTableTableFilterComposer,
      $$LocalAudiosTableTableOrderingComposer,
      $$LocalAudiosTableTableAnnotationComposer,
      $$LocalAudiosTableTableCreateCompanionBuilder,
      $$LocalAudiosTableTableUpdateCompanionBuilder,
      (LocalAudiosTableData, $$LocalAudiosTableTableReferences),
      LocalAudiosTableData,
      PrefetchHooks Function({bool playlistTableRefs})
    >;
typedef $$PlaylistTableTableCreateCompanionBuilder =
    PlaylistTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      required String title,
      required int order,
      required int audio,
    });
typedef $$PlaylistTableTableUpdateCompanionBuilder =
    PlaylistTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String> title,
      Value<int> order,
      Value<int> audio,
    });

final class $$PlaylistTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlaylistTableTable, PlaylistTableData> {
  $$PlaylistTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalAudiosTableTable _audioTable(_$AppDatabase db) =>
      db.localAudiosTable.createAlias(
        $_aliasNameGenerator(db.playlistTable.audio, db.localAudiosTable.id),
      );

  $$LocalAudiosTableTableProcessedTableManager get audio {
    final $_column = $_itemColumn<int>('audio')!;

    final manager = $$LocalAudiosTableTableTableManager(
      $_db,
      $_db.localAudiosTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_audioTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalAudiosTableTableFilterComposer get audio {
    final $$LocalAudiosTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audio,
      referencedTable: $db.localAudiosTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAudiosTableTableFilterComposer(
            $db: $db,
            $table: $db.localAudiosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalAudiosTableTableOrderingComposer get audio {
    final $$LocalAudiosTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audio,
      referencedTable: $db.localAudiosTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAudiosTableTableOrderingComposer(
            $db: $db,
            $table: $db.localAudiosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$LocalAudiosTableTableAnnotationComposer get audio {
    final $$LocalAudiosTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audio,
      referencedTable: $db.localAudiosTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAudiosTableTableAnnotationComposer(
            $db: $db,
            $table: $db.localAudiosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistTableTable,
          PlaylistTableData,
          $$PlaylistTableTableFilterComposer,
          $$PlaylistTableTableOrderingComposer,
          $$PlaylistTableTableAnnotationComposer,
          $$PlaylistTableTableCreateCompanionBuilder,
          $$PlaylistTableTableUpdateCompanionBuilder,
          (PlaylistTableData, $$PlaylistTableTableReferences),
          PlaylistTableData,
          PrefetchHooks Function({bool audio})
        > {
  $$PlaylistTableTableTableManager(_$AppDatabase db, $PlaylistTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<int> audio = const Value.absent(),
              }) => PlaylistTableCompanion(
                id: id,
                createdAt: createdAt,
                title: title,
                order: order,
                audio: audio,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String title,
                required int order,
                required int audio,
              }) => PlaylistTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                title: title,
                order: order,
                audio: audio,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({audio = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (audio) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.audio,
                                referencedTable: $$PlaylistTableTableReferences
                                    ._audioTable(db),
                                referencedColumn: $$PlaylistTableTableReferences
                                    ._audioTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistTableTable,
      PlaylistTableData,
      $$PlaylistTableTableFilterComposer,
      $$PlaylistTableTableOrderingComposer,
      $$PlaylistTableTableAnnotationComposer,
      $$PlaylistTableTableCreateCompanionBuilder,
      $$PlaylistTableTableUpdateCompanionBuilder,
      (PlaylistTableData, $$PlaylistTableTableReferences),
      PlaylistTableData,
      PrefetchHooks Function({bool audio})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalAudiosTableTableTableManager get localAudiosTable =>
      $$LocalAudiosTableTableTableManager(_db, _db.localAudiosTable);
  $$PlaylistTableTableTableManager get playlistTable =>
      $$PlaylistTableTableTableManager(_db, _db.playlistTable);
}
