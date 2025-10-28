// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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

class $SubscriptionTableTable extends SubscriptionTable
    with TableInfo<$SubscriptionTableTable, SubscriptionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<String> podcastId = GeneratedColumn<String>(
    'podcast_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subscribedAtMeta = const VerificationMeta(
    'subscribedAt',
  );
  @override
  late final GeneratedColumn<DateTime> subscribedAt = GeneratedColumn<DateTime>(
    'subscribed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastListenAtMeta = const VerificationMeta(
    'lastListenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastListenAt = GeneratedColumn<DateTime>(
    'last_listen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    podcastId,
    title,
    author,
    artworkUrl,
    feedUrl,
    subscribedAt,
    lastListenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionTableData> instance, {
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
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
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
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('subscribed_at')) {
      context.handle(
        _subscribedAtMeta,
        subscribedAt.isAcceptableOrUnknown(
          data['subscribed_at']!,
          _subscribedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_listen_at')) {
      context.handle(
        _lastListenAtMeta,
        lastListenAt.isAcceptableOrUnknown(
          data['last_listen_at']!,
          _lastListenAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}podcast_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      ),
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      subscribedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscribed_at'],
      )!,
      lastListenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_listen_at'],
      )!,
    );
  }

  @override
  $SubscriptionTableTable createAlias(String alias) {
    return $SubscriptionTableTable(attachedDatabase, alias);
  }
}

class SubscriptionTableData extends DataClass
    implements Insertable<SubscriptionTableData> {
  final int id;
  final DateTime createdAt;
  final String? podcastId;
  final String title;
  final String? author;
  final String? artworkUrl;
  final String feedUrl;
  final DateTime subscribedAt;
  final DateTime lastListenAt;
  const SubscriptionTableData({
    required this.id,
    required this.createdAt,
    this.podcastId,
    required this.title,
    this.author,
    this.artworkUrl,
    required this.feedUrl,
    required this.subscribedAt,
    required this.lastListenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || podcastId != null) {
      map['podcast_id'] = Variable<String>(podcastId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    map['feed_url'] = Variable<String>(feedUrl);
    map['subscribed_at'] = Variable<DateTime>(subscribedAt);
    map['last_listen_at'] = Variable<DateTime>(lastListenAt);
    return map;
  }

  SubscriptionTableCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      podcastId: podcastId == null && nullToAbsent
          ? const Value.absent()
          : Value(podcastId),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      feedUrl: Value(feedUrl),
      subscribedAt: Value(subscribedAt),
      lastListenAt: Value(lastListenAt),
    );
  }

  factory SubscriptionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      podcastId: serializer.fromJson<String?>(json['podcastId']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      subscribedAt: serializer.fromJson<DateTime>(json['subscribedAt']),
      lastListenAt: serializer.fromJson<DateTime>(json['lastListenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'podcastId': serializer.toJson<String?>(podcastId),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'subscribedAt': serializer.toJson<DateTime>(subscribedAt),
      'lastListenAt': serializer.toJson<DateTime>(lastListenAt),
    };
  }

  SubscriptionTableData copyWith({
    int? id,
    DateTime? createdAt,
    Value<String?> podcastId = const Value.absent(),
    String? title,
    Value<String?> author = const Value.absent(),
    Value<String?> artworkUrl = const Value.absent(),
    String? feedUrl,
    DateTime? subscribedAt,
    DateTime? lastListenAt,
  }) => SubscriptionTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    podcastId: podcastId.present ? podcastId.value : this.podcastId,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
    feedUrl: feedUrl ?? this.feedUrl,
    subscribedAt: subscribedAt ?? this.subscribedAt,
    lastListenAt: lastListenAt ?? this.lastListenAt,
  );
  SubscriptionTableData copyWithCompanion(SubscriptionTableCompanion data) {
    return SubscriptionTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      subscribedAt: data.subscribedAt.present
          ? data.subscribedAt.value
          : this.subscribedAt,
      lastListenAt: data.lastListenAt.present
          ? data.lastListenAt.value
          : this.lastListenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('podcastId: $podcastId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('lastListenAt: $lastListenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    podcastId,
    title,
    author,
    artworkUrl,
    feedUrl,
    subscribedAt,
    lastListenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.podcastId == this.podcastId &&
          other.title == this.title &&
          other.author == this.author &&
          other.artworkUrl == this.artworkUrl &&
          other.feedUrl == this.feedUrl &&
          other.subscribedAt == this.subscribedAt &&
          other.lastListenAt == this.lastListenAt);
}

class SubscriptionTableCompanion
    extends UpdateCompanion<SubscriptionTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String?> podcastId;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> artworkUrl;
  final Value<String> feedUrl;
  final Value<DateTime> subscribedAt;
  final Value<DateTime> lastListenAt;
  const SubscriptionTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.podcastId = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.lastListenAt = const Value.absent(),
  });
  SubscriptionTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.podcastId = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    required String feedUrl,
    this.subscribedAt = const Value.absent(),
    this.lastListenAt = const Value.absent(),
  }) : title = Value(title),
       feedUrl = Value(feedUrl);
  static Insertable<SubscriptionTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? podcastId,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? artworkUrl,
    Expression<String>? feedUrl,
    Expression<DateTime>? subscribedAt,
    Expression<DateTime>? lastListenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (podcastId != null) 'podcast_id': podcastId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
      if (lastListenAt != null) 'last_listen_at': lastListenAt,
    });
  }

  SubscriptionTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String?>? podcastId,
    Value<String>? title,
    Value<String?>? author,
    Value<String?>? artworkUrl,
    Value<String>? feedUrl,
    Value<DateTime>? subscribedAt,
    Value<DateTime>? lastListenAt,
  }) {
    return SubscriptionTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      podcastId: podcastId ?? this.podcastId,
      title: title ?? this.title,
      author: author ?? this.author,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      feedUrl: feedUrl ?? this.feedUrl,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      lastListenAt: lastListenAt ?? this.lastListenAt,
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
    if (podcastId.present) {
      map['podcast_id'] = Variable<String>(podcastId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (subscribedAt.present) {
      map['subscribed_at'] = Variable<DateTime>(subscribedAt.value);
    }
    if (lastListenAt.present) {
      map['last_listen_at'] = Variable<DateTime>(lastListenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('podcastId: $podcastId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('lastListenAt: $lastListenAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadTableTable extends DownloadTable
    with TableInfo<$DownloadTableTable, DownloadTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<String> episodeId = GeneratedColumn<String>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _podcastFeedUrlMeta = const VerificationMeta(
    'podcastFeedUrl',
  );
  @override
  late final GeneratedColumn<String> podcastFeedUrl = GeneratedColumn<String>(
    'podcast_feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    episodeId,
    title,
    audioUrl,
    localFilePath,
    downloadedAt,
    podcastFeedUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadTableData> instance, {
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
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('podcast_feed_url')) {
      context.handle(
        _podcastFeedUrlMeta,
        podcastFeedUrl.isAcceptableOrUnknown(
          data['podcast_feed_url']!,
          _podcastFeedUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_podcastFeedUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      podcastFeedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}podcast_feed_url'],
      )!,
    );
  }

  @override
  $DownloadTableTable createAlias(String alias) {
    return $DownloadTableTable(attachedDatabase, alias);
  }
}

class DownloadTableData extends DataClass
    implements Insertable<DownloadTableData> {
  final int id;
  final DateTime createdAt;
  final String episodeId;
  final String title;
  final String audioUrl;
  final String localFilePath;
  final DateTime downloadedAt;
  final String podcastFeedUrl;
  const DownloadTableData({
    required this.id,
    required this.createdAt,
    required this.episodeId,
    required this.title,
    required this.audioUrl,
    required this.localFilePath,
    required this.downloadedAt,
    required this.podcastFeedUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['episode_id'] = Variable<String>(episodeId);
    map['title'] = Variable<String>(title);
    map['audio_url'] = Variable<String>(audioUrl);
    map['local_file_path'] = Variable<String>(localFilePath);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    map['podcast_feed_url'] = Variable<String>(podcastFeedUrl);
    return map;
  }

  DownloadTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      episodeId: Value(episodeId),
      title: Value(title),
      audioUrl: Value(audioUrl),
      localFilePath: Value(localFilePath),
      downloadedAt: Value(downloadedAt),
      podcastFeedUrl: Value(podcastFeedUrl),
    );
  }

  factory DownloadTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      episodeId: serializer.fromJson<String>(json['episodeId']),
      title: serializer.fromJson<String>(json['title']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      podcastFeedUrl: serializer.fromJson<String>(json['podcastFeedUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'episodeId': serializer.toJson<String>(episodeId),
      'title': serializer.toJson<String>(title),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'podcastFeedUrl': serializer.toJson<String>(podcastFeedUrl),
    };
  }

  DownloadTableData copyWith({
    int? id,
    DateTime? createdAt,
    String? episodeId,
    String? title,
    String? audioUrl,
    String? localFilePath,
    DateTime? downloadedAt,
    String? podcastFeedUrl,
  }) => DownloadTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    episodeId: episodeId ?? this.episodeId,
    title: title ?? this.title,
    audioUrl: audioUrl ?? this.audioUrl,
    localFilePath: localFilePath ?? this.localFilePath,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    podcastFeedUrl: podcastFeedUrl ?? this.podcastFeedUrl,
  );
  DownloadTableData copyWithCompanion(DownloadTableCompanion data) {
    return DownloadTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      title: data.title.present ? data.title.value : this.title,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      podcastFeedUrl: data.podcastFeedUrl.present
          ? data.podcastFeedUrl.value
          : this.podcastFeedUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('episodeId: $episodeId, ')
          ..write('title: $title, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('podcastFeedUrl: $podcastFeedUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    episodeId,
    title,
    audioUrl,
    localFilePath,
    downloadedAt,
    podcastFeedUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.episodeId == this.episodeId &&
          other.title == this.title &&
          other.audioUrl == this.audioUrl &&
          other.localFilePath == this.localFilePath &&
          other.downloadedAt == this.downloadedAt &&
          other.podcastFeedUrl == this.podcastFeedUrl);
}

class DownloadTableCompanion extends UpdateCompanion<DownloadTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> episodeId;
  final Value<String> title;
  final Value<String> audioUrl;
  final Value<String> localFilePath;
  final Value<DateTime> downloadedAt;
  final Value<String> podcastFeedUrl;
  const DownloadTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.title = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.podcastFeedUrl = const Value.absent(),
  });
  DownloadTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String episodeId,
    required String title,
    required String audioUrl,
    required String localFilePath,
    this.downloadedAt = const Value.absent(),
    required String podcastFeedUrl,
  }) : episodeId = Value(episodeId),
       title = Value(title),
       audioUrl = Value(audioUrl),
       localFilePath = Value(localFilePath),
       podcastFeedUrl = Value(podcastFeedUrl);
  static Insertable<DownloadTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? episodeId,
    Expression<String>? title,
    Expression<String>? audioUrl,
    Expression<String>? localFilePath,
    Expression<DateTime>? downloadedAt,
    Expression<String>? podcastFeedUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (episodeId != null) 'episode_id': episodeId,
      if (title != null) 'title': title,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (podcastFeedUrl != null) 'podcast_feed_url': podcastFeedUrl,
    });
  }

  DownloadTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? episodeId,
    Value<String>? title,
    Value<String>? audioUrl,
    Value<String>? localFilePath,
    Value<DateTime>? downloadedAt,
    Value<String>? podcastFeedUrl,
  }) {
    return DownloadTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      episodeId: episodeId ?? this.episodeId,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      podcastFeedUrl: podcastFeedUrl ?? this.podcastFeedUrl,
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
    if (episodeId.present) {
      map['episode_id'] = Variable<String>(episodeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (podcastFeedUrl.present) {
      map['podcast_feed_url'] = Variable<String>(podcastFeedUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('episodeId: $episodeId, ')
          ..write('title: $title, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('podcastFeedUrl: $podcastFeedUrl')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlaylistTableTable playlistTable = $PlaylistTableTable(this);
  late final $SubscriptionTableTable subscriptionTable =
      $SubscriptionTableTable(this);
  late final $DownloadTableTable downloadTable = $DownloadTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playlistTable,
    subscriptionTable,
    downloadTable,
  ];
}

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

  ColumnFilters<int> get audio => $composableBuilder(
    column: $table.audio,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<int> get audio => $composableBuilder(
    column: $table.audio,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<int> get audio =>
      $composableBuilder(column: $table.audio, builder: (column) => column);
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
          (
            PlaylistTableData,
            BaseReferences<
              _$AppDatabase,
              $PlaylistTableTable,
              PlaylistTableData
            >,
          ),
          PlaylistTableData,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        PlaylistTableData,
        BaseReferences<_$AppDatabase, $PlaylistTableTable, PlaylistTableData>,
      ),
      PlaylistTableData,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionTableTableCreateCompanionBuilder =
    SubscriptionTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String?> podcastId,
      required String title,
      Value<String?> author,
      Value<String?> artworkUrl,
      required String feedUrl,
      Value<DateTime> subscribedAt,
      Value<DateTime> lastListenAt,
    });
typedef $$SubscriptionTableTableUpdateCompanionBuilder =
    SubscriptionTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String?> podcastId,
      Value<String> title,
      Value<String?> author,
      Value<String?> artworkUrl,
      Value<String> feedUrl,
      Value<DateTime> subscribedAt,
      Value<DateTime> lastListenAt,
    });

class $$SubscriptionTableTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionTableTable> {
  $$SubscriptionTableTableFilterComposer({
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

  ColumnFilters<String> get podcastId => $composableBuilder(
    column: $table.podcastId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastListenAt => $composableBuilder(
    column: $table.lastListenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionTableTable> {
  $$SubscriptionTableTableOrderingComposer({
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

  ColumnOrderings<String> get podcastId => $composableBuilder(
    column: $table.podcastId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastListenAt => $composableBuilder(
    column: $table.lastListenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionTableTable> {
  $$SubscriptionTableTableAnnotationComposer({
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

  GeneratedColumn<String> get podcastId =>
      $composableBuilder(column: $table.podcastId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastListenAt => $composableBuilder(
    column: $table.lastListenAt,
    builder: (column) => column,
  );
}

class $$SubscriptionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionTableTable,
          SubscriptionTableData,
          $$SubscriptionTableTableFilterComposer,
          $$SubscriptionTableTableOrderingComposer,
          $$SubscriptionTableTableAnnotationComposer,
          $$SubscriptionTableTableCreateCompanionBuilder,
          $$SubscriptionTableTableUpdateCompanionBuilder,
          (
            SubscriptionTableData,
            BaseReferences<
              _$AppDatabase,
              $SubscriptionTableTable,
              SubscriptionTableData
            >,
          ),
          SubscriptionTableData,
          PrefetchHooks Function()
        > {
  $$SubscriptionTableTableTableManager(
    _$AppDatabase db,
    $SubscriptionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> podcastId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<DateTime> subscribedAt = const Value.absent(),
                Value<DateTime> lastListenAt = const Value.absent(),
              }) => SubscriptionTableCompanion(
                id: id,
                createdAt: createdAt,
                podcastId: podcastId,
                title: title,
                author: author,
                artworkUrl: artworkUrl,
                feedUrl: feedUrl,
                subscribedAt: subscribedAt,
                lastListenAt: lastListenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> podcastId = const Value.absent(),
                required String title,
                Value<String?> author = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                required String feedUrl,
                Value<DateTime> subscribedAt = const Value.absent(),
                Value<DateTime> lastListenAt = const Value.absent(),
              }) => SubscriptionTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                podcastId: podcastId,
                title: title,
                author: author,
                artworkUrl: artworkUrl,
                feedUrl: feedUrl,
                subscribedAt: subscribedAt,
                lastListenAt: lastListenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionTableTable,
      SubscriptionTableData,
      $$SubscriptionTableTableFilterComposer,
      $$SubscriptionTableTableOrderingComposer,
      $$SubscriptionTableTableAnnotationComposer,
      $$SubscriptionTableTableCreateCompanionBuilder,
      $$SubscriptionTableTableUpdateCompanionBuilder,
      (
        SubscriptionTableData,
        BaseReferences<
          _$AppDatabase,
          $SubscriptionTableTable,
          SubscriptionTableData
        >,
      ),
      SubscriptionTableData,
      PrefetchHooks Function()
    >;
typedef $$DownloadTableTableCreateCompanionBuilder =
    DownloadTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      required String episodeId,
      required String title,
      required String audioUrl,
      required String localFilePath,
      Value<DateTime> downloadedAt,
      required String podcastFeedUrl,
    });
typedef $$DownloadTableTableUpdateCompanionBuilder =
    DownloadTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String> episodeId,
      Value<String> title,
      Value<String> audioUrl,
      Value<String> localFilePath,
      Value<DateTime> downloadedAt,
      Value<String> podcastFeedUrl,
    });

class $$DownloadTableTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadTableTable> {
  $$DownloadTableTableFilterComposer({
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

  ColumnFilters<String> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get podcastFeedUrl => $composableBuilder(
    column: $table.podcastFeedUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadTableTable> {
  $$DownloadTableTableOrderingComposer({
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

  ColumnOrderings<String> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get podcastFeedUrl => $composableBuilder(
    column: $table.podcastFeedUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadTableTable> {
  $$DownloadTableTableAnnotationComposer({
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

  GeneratedColumn<String> get episodeId =>
      $composableBuilder(column: $table.episodeId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get podcastFeedUrl => $composableBuilder(
    column: $table.podcastFeedUrl,
    builder: (column) => column,
  );
}

class $$DownloadTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadTableTable,
          DownloadTableData,
          $$DownloadTableTableFilterComposer,
          $$DownloadTableTableOrderingComposer,
          $$DownloadTableTableAnnotationComposer,
          $$DownloadTableTableCreateCompanionBuilder,
          $$DownloadTableTableUpdateCompanionBuilder,
          (
            DownloadTableData,
            BaseReferences<
              _$AppDatabase,
              $DownloadTableTable,
              DownloadTableData
            >,
          ),
          DownloadTableData,
          PrefetchHooks Function()
        > {
  $$DownloadTableTableTableManager(_$AppDatabase db, $DownloadTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> episodeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<String> localFilePath = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<String> podcastFeedUrl = const Value.absent(),
              }) => DownloadTableCompanion(
                id: id,
                createdAt: createdAt,
                episodeId: episodeId,
                title: title,
                audioUrl: audioUrl,
                localFilePath: localFilePath,
                downloadedAt: downloadedAt,
                podcastFeedUrl: podcastFeedUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String episodeId,
                required String title,
                required String audioUrl,
                required String localFilePath,
                Value<DateTime> downloadedAt = const Value.absent(),
                required String podcastFeedUrl,
              }) => DownloadTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                episodeId: episodeId,
                title: title,
                audioUrl: audioUrl,
                localFilePath: localFilePath,
                downloadedAt: downloadedAt,
                podcastFeedUrl: podcastFeedUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadTableTable,
      DownloadTableData,
      $$DownloadTableTableFilterComposer,
      $$DownloadTableTableOrderingComposer,
      $$DownloadTableTableAnnotationComposer,
      $$DownloadTableTableCreateCompanionBuilder,
      $$DownloadTableTableUpdateCompanionBuilder,
      (
        DownloadTableData,
        BaseReferences<_$AppDatabase, $DownloadTableTable, DownloadTableData>,
      ),
      DownloadTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlaylistTableTableTableManager get playlistTable =>
      $$PlaylistTableTableTableManager(_db, _db.playlistTable);
  $$SubscriptionTableTableTableManager get subscriptionTable =>
      $$SubscriptionTableTableTableManager(_db, _db.subscriptionTable);
  $$DownloadTableTableTableManager get downloadTable =>
      $$DownloadTableTableTableManager(_db, _db.downloadTable);
}
