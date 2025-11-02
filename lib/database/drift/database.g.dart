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
  static const VerificationMeta _totalEpisodesMeta = const VerificationMeta(
    'totalEpisodes',
  );
  @override
  late final GeneratedColumn<int> totalEpisodes = GeneratedColumn<int>(
    'total_episodes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    totalEpisodes,
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
    if (data.containsKey('total_episodes')) {
      context.handle(
        _totalEpisodesMeta,
        totalEpisodes.isAcceptableOrUnknown(
          data['total_episodes']!,
          _totalEpisodesMeta,
        ),
      );
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
      totalEpisodes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_episodes'],
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
  final int totalEpisodes;
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
    required this.totalEpisodes,
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
    map['total_episodes'] = Variable<int>(totalEpisodes);
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
      totalEpisodes: Value(totalEpisodes),
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
      totalEpisodes: serializer.fromJson<int>(json['totalEpisodes']),
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
      'totalEpisodes': serializer.toJson<int>(totalEpisodes),
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
    int? totalEpisodes,
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
    totalEpisodes: totalEpisodes ?? this.totalEpisodes,
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
      totalEpisodes: data.totalEpisodes.present
          ? data.totalEpisodes.value
          : this.totalEpisodes,
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
          ..write('totalEpisodes: $totalEpisodes, ')
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
    totalEpisodes,
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
          other.totalEpisodes == this.totalEpisodes &&
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
  final Value<int> totalEpisodes;
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
    this.totalEpisodes = const Value.absent(),
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
    this.totalEpisodes = const Value.absent(),
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
    Expression<int>? totalEpisodes,
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
      if (totalEpisodes != null) 'total_episodes': totalEpisodes,
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
    Value<int>? totalEpisodes,
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
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
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
    if (totalEpisodes.present) {
      map['total_episodes'] = Variable<int>(totalEpisodes.value);
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
          ..write('totalEpisodes: $totalEpisodes, ')
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
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
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
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentUrlMeta = const VerificationMeta(
    'contentUrl',
  );
  @override
  late final GeneratedColumn<String> contentUrl = GeneratedColumn<String>(
    'content_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthMeta = const VerificationMeta('length');
  @override
  late final GeneratedColumn<int> length = GeneratedColumn<int>(
    'length',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    guid,
    title,
    description,
    author,
    imageUrl,
    contentUrl,
    length,
    duration,
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
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('content_url')) {
      context.handle(
        _contentUrlMeta,
        contentUrl.isAcceptableOrUnknown(data['content_url']!, _contentUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_contentUrlMeta);
    }
    if (data.containsKey('length')) {
      context.handle(
        _lengthMeta,
        length.isAcceptableOrUnknown(data['length']!, _lengthMeta),
      );
    } else if (isInserting) {
      context.missing(_lengthMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
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
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      contentUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_url'],
      )!,
      length: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}length'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
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
  final String guid;
  final String title;
  final String description;
  final String? author;
  final String? imageUrl;
  final String contentUrl;
  final int length;
  final int duration;
  const DownloadTableData({
    required this.id,
    required this.createdAt,
    required this.guid,
    required this.title,
    required this.description,
    this.author,
    this.imageUrl,
    required this.contentUrl,
    required this.length,
    required this.duration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['guid'] = Variable<String>(guid);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['content_url'] = Variable<String>(contentUrl);
    map['length'] = Variable<int>(length);
    map['duration'] = Variable<int>(duration);
    return map;
  }

  DownloadTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      guid: Value(guid),
      title: Value(title),
      description: Value(description),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      contentUrl: Value(contentUrl),
      length: Value(length),
      duration: Value(duration),
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
      guid: serializer.fromJson<String>(json['guid']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      author: serializer.fromJson<String?>(json['author']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      contentUrl: serializer.fromJson<String>(json['contentUrl']),
      length: serializer.fromJson<int>(json['length']),
      duration: serializer.fromJson<int>(json['duration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'guid': serializer.toJson<String>(guid),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'author': serializer.toJson<String?>(author),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'contentUrl': serializer.toJson<String>(contentUrl),
      'length': serializer.toJson<int>(length),
      'duration': serializer.toJson<int>(duration),
    };
  }

  DownloadTableData copyWith({
    int? id,
    DateTime? createdAt,
    String? guid,
    String? title,
    String? description,
    Value<String?> author = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    String? contentUrl,
    int? length,
    int? duration,
  }) => DownloadTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    guid: guid ?? this.guid,
    title: title ?? this.title,
    description: description ?? this.description,
    author: author.present ? author.value : this.author,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    contentUrl: contentUrl ?? this.contentUrl,
    length: length ?? this.length,
    duration: duration ?? this.duration,
  );
  DownloadTableData copyWithCompanion(DownloadTableCompanion data) {
    return DownloadTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      guid: data.guid.present ? data.guid.value : this.guid,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      author: data.author.present ? data.author.value : this.author,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      contentUrl: data.contentUrl.present
          ? data.contentUrl.value
          : this.contentUrl,
      length: data.length.present ? data.length.value : this.length,
      duration: data.duration.present ? data.duration.value : this.duration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('guid: $guid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('length: $length, ')
          ..write('duration: $duration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    guid,
    title,
    description,
    author,
    imageUrl,
    contentUrl,
    length,
    duration,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.guid == this.guid &&
          other.title == this.title &&
          other.description == this.description &&
          other.author == this.author &&
          other.imageUrl == this.imageUrl &&
          other.contentUrl == this.contentUrl &&
          other.length == this.length &&
          other.duration == this.duration);
}

class DownloadTableCompanion extends UpdateCompanion<DownloadTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> guid;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> author;
  final Value<String?> imageUrl;
  final Value<String> contentUrl;
  final Value<int> length;
  final Value<int> duration;
  const DownloadTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.guid = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.contentUrl = const Value.absent(),
    this.length = const Value.absent(),
    this.duration = const Value.absent(),
  });
  DownloadTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String guid,
    required String title,
    required String description,
    this.author = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required String contentUrl,
    required int length,
    required int duration,
  }) : guid = Value(guid),
       title = Value(title),
       description = Value(description),
       contentUrl = Value(contentUrl),
       length = Value(length),
       duration = Value(duration);
  static Insertable<DownloadTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? guid,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? author,
    Expression<String>? imageUrl,
    Expression<String>? contentUrl,
    Expression<int>? length,
    Expression<int>? duration,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (guid != null) 'guid': guid,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (author != null) 'author': author,
      if (imageUrl != null) 'image_url': imageUrl,
      if (contentUrl != null) 'content_url': contentUrl,
      if (length != null) 'length': length,
      if (duration != null) 'duration': duration,
    });
  }

  DownloadTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? guid,
    Value<String>? title,
    Value<String>? description,
    Value<String?>? author,
    Value<String?>? imageUrl,
    Value<String>? contentUrl,
    Value<int>? length,
    Value<int>? duration,
  }) {
    return DownloadTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      guid: guid ?? this.guid,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      contentUrl: contentUrl ?? this.contentUrl,
      length: length ?? this.length,
      duration: duration ?? this.duration,
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
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (contentUrl.present) {
      map['content_url'] = Variable<String>(contentUrl.value);
    }
    if (length.present) {
      map['length'] = Variable<int>(length.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('guid: $guid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('length: $length, ')
          ..write('duration: $duration')
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
      Value<int> totalEpisodes,
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
      Value<int> totalEpisodes,
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

  ColumnFilters<int> get totalEpisodes => $composableBuilder(
    column: $table.totalEpisodes,
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

  ColumnOrderings<int> get totalEpisodes => $composableBuilder(
    column: $table.totalEpisodes,
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

  GeneratedColumn<int> get totalEpisodes => $composableBuilder(
    column: $table.totalEpisodes,
    builder: (column) => column,
  );

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
                Value<int> totalEpisodes = const Value.absent(),
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
                totalEpisodes: totalEpisodes,
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
                Value<int> totalEpisodes = const Value.absent(),
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
                totalEpisodes: totalEpisodes,
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
      required String guid,
      required String title,
      required String description,
      Value<String?> author,
      Value<String?> imageUrl,
      required String contentUrl,
      required int length,
      required int duration,
    });
typedef $$DownloadTableTableUpdateCompanionBuilder =
    DownloadTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String> guid,
      Value<String> title,
      Value<String> description,
      Value<String?> author,
      Value<String?> imageUrl,
      Value<String> contentUrl,
      Value<int> length,
      Value<int> duration,
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

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentUrl => $composableBuilder(
    column: $table.contentUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
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

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentUrl => $composableBuilder(
    column: $table.contentUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
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

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get contentUrl => $composableBuilder(
    column: $table.contentUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get length =>
      $composableBuilder(column: $table.length, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);
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
                Value<String> guid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> contentUrl = const Value.absent(),
                Value<int> length = const Value.absent(),
                Value<int> duration = const Value.absent(),
              }) => DownloadTableCompanion(
                id: id,
                createdAt: createdAt,
                guid: guid,
                title: title,
                description: description,
                author: author,
                imageUrl: imageUrl,
                contentUrl: contentUrl,
                length: length,
                duration: duration,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String guid,
                required String title,
                required String description,
                Value<String?> author = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                required String contentUrl,
                required int length,
                required int duration,
              }) => DownloadTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                guid: guid,
                title: title,
                description: description,
                author: author,
                imageUrl: imageUrl,
                contentUrl: contentUrl,
                length: length,
                duration: duration,
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
