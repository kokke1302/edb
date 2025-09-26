// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VocabulariesTable extends Vocabularies
    with TableInfo<$VocabulariesTable, Vocabulary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabulariesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [id, title, memo, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabularies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vocabulary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vocabulary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vocabulary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VocabulariesTable createAlias(String alias) {
    return $VocabulariesTable(attachedDatabase, alias);
  }
}

class Vocabulary extends DataClass implements Insertable<Vocabulary> {
  final int id;
  final String title;
  final String? memo;
  final DateTime createdAt;
  const Vocabulary({
    required this.id,
    required this.title,
    this.memo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VocabulariesCompanion toCompanion(bool nullToAbsent) {
    return VocabulariesCompanion(
      id: Value(id),
      title: Value(title),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory Vocabulary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vocabulary(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vocabulary copyWith({
    int? id,
    String? title,
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
  }) => Vocabulary(
    id: id ?? this.id,
    title: title ?? this.title,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
  );
  Vocabulary copyWithCompanion(VocabulariesCompanion data) {
    return Vocabulary(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vocabulary(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, memo, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vocabulary &&
          other.id == this.id &&
          other.title == this.title &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class VocabulariesCompanion extends UpdateCompanion<Vocabulary> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  const VocabulariesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VocabulariesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Vocabulary> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VocabulariesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
  }) {
    return VocabulariesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabulariesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EnglishSentenceTable extends EnglishSentence
    with TableInfo<$EnglishSentenceTable, EnglishSentenceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnglishSentenceTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _originalTextMeta = const VerificationMeta(
    'originalText',
  );
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
    'original_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    originalText,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'english_sentence';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnglishSentenceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('original_text')) {
      context.handle(
        _originalTextMeta,
        originalText.isAcceptableOrUnknown(
          data['original_text']!,
          _originalTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnglishSentenceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnglishSentenceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      originalText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EnglishSentenceTable createAlias(String alias) {
    return $EnglishSentenceTable(attachedDatabase, alias);
  }
}

class EnglishSentenceData extends DataClass
    implements Insertable<EnglishSentenceData> {
  final int id;
  final String originalText;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EnglishSentenceData({
    required this.id,
    required this.originalText,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['original_text'] = Variable<String>(originalText);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EnglishSentenceCompanion toCompanion(bool nullToAbsent) {
    return EnglishSentenceCompanion(
      id: Value(id),
      originalText: Value(originalText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EnglishSentenceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnglishSentenceData(
      id: serializer.fromJson<int>(json['id']),
      originalText: serializer.fromJson<String>(json['originalText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'originalText': serializer.toJson<String>(originalText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EnglishSentenceData copyWith({
    int? id,
    String? originalText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EnglishSentenceData(
    id: id ?? this.id,
    originalText: originalText ?? this.originalText,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EnglishSentenceData copyWithCompanion(EnglishSentenceCompanion data) {
    return EnglishSentenceData(
      id: data.id.present ? data.id.value : this.id,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnglishSentenceData(')
          ..write('id: $id, ')
          ..write('originalText: $originalText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, originalText, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnglishSentenceData &&
          other.id == this.id &&
          other.originalText == this.originalText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EnglishSentenceCompanion extends UpdateCompanion<EnglishSentenceData> {
  final Value<int> id;
  final Value<String> originalText;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EnglishSentenceCompanion({
    this.id = const Value.absent(),
    this.originalText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EnglishSentenceCompanion.insert({
    this.id = const Value.absent(),
    required String originalText,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : originalText = Value(originalText);
  static Insertable<EnglishSentenceData> custom({
    Expression<int>? id,
    Expression<String>? originalText,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalText != null) 'original_text': originalText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EnglishSentenceCompanion copyWith({
    Value<int>? id,
    Value<String>? originalText,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EnglishSentenceCompanion(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnglishSentenceCompanion(')
          ..write('id: $id, ')
          ..write('originalText: $originalText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VocabulariesTable vocabularies = $VocabulariesTable(this);
  late final $EnglishSentenceTable englishSentence = $EnglishSentenceTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vocabularies,
    englishSentence,
  ];
}

typedef $$VocabulariesTableCreateCompanionBuilder =
    VocabulariesCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });
typedef $$VocabulariesTableUpdateCompanionBuilder =
    VocabulariesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });

class $$VocabulariesTableFilterComposer
    extends Composer<_$AppDatabase, $VocabulariesTable> {
  $$VocabulariesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VocabulariesTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabulariesTable> {
  $$VocabulariesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabulariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabulariesTable> {
  $$VocabulariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VocabulariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabulariesTable,
          Vocabulary,
          $$VocabulariesTableFilterComposer,
          $$VocabulariesTableOrderingComposer,
          $$VocabulariesTableAnnotationComposer,
          $$VocabulariesTableCreateCompanionBuilder,
          $$VocabulariesTableUpdateCompanionBuilder,
          (
            Vocabulary,
            BaseReferences<_$AppDatabase, $VocabulariesTable, Vocabulary>,
          ),
          Vocabulary,
          PrefetchHooks Function()
        > {
  $$VocabulariesTableTableManager(_$AppDatabase db, $VocabulariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabulariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabulariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabulariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VocabulariesCompanion(
                id: id,
                title: title,
                memo: memo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VocabulariesCompanion.insert(
                id: id,
                title: title,
                memo: memo,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VocabulariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabulariesTable,
      Vocabulary,
      $$VocabulariesTableFilterComposer,
      $$VocabulariesTableOrderingComposer,
      $$VocabulariesTableAnnotationComposer,
      $$VocabulariesTableCreateCompanionBuilder,
      $$VocabulariesTableUpdateCompanionBuilder,
      (
        Vocabulary,
        BaseReferences<_$AppDatabase, $VocabulariesTable, Vocabulary>,
      ),
      Vocabulary,
      PrefetchHooks Function()
    >;
typedef $$EnglishSentenceTableCreateCompanionBuilder =
    EnglishSentenceCompanion Function({
      Value<int> id,
      required String originalText,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$EnglishSentenceTableUpdateCompanionBuilder =
    EnglishSentenceCompanion Function({
      Value<int> id,
      Value<String> originalText,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$EnglishSentenceTableFilterComposer
    extends Composer<_$AppDatabase, $EnglishSentenceTable> {
  $$EnglishSentenceTableFilterComposer({
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

  ColumnFilters<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnglishSentenceTableOrderingComposer
    extends Composer<_$AppDatabase, $EnglishSentenceTable> {
  $$EnglishSentenceTableOrderingComposer({
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

  ColumnOrderings<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnglishSentenceTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnglishSentenceTable> {
  $$EnglishSentenceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EnglishSentenceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnglishSentenceTable,
          EnglishSentenceData,
          $$EnglishSentenceTableFilterComposer,
          $$EnglishSentenceTableOrderingComposer,
          $$EnglishSentenceTableAnnotationComposer,
          $$EnglishSentenceTableCreateCompanionBuilder,
          $$EnglishSentenceTableUpdateCompanionBuilder,
          (
            EnglishSentenceData,
            BaseReferences<
              _$AppDatabase,
              $EnglishSentenceTable,
              EnglishSentenceData
            >,
          ),
          EnglishSentenceData,
          PrefetchHooks Function()
        > {
  $$EnglishSentenceTableTableManager(
    _$AppDatabase db,
    $EnglishSentenceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnglishSentenceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnglishSentenceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnglishSentenceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> originalText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EnglishSentenceCompanion(
                id: id,
                originalText: originalText,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String originalText,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EnglishSentenceCompanion.insert(
                id: id,
                originalText: originalText,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnglishSentenceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnglishSentenceTable,
      EnglishSentenceData,
      $$EnglishSentenceTableFilterComposer,
      $$EnglishSentenceTableOrderingComposer,
      $$EnglishSentenceTableAnnotationComposer,
      $$EnglishSentenceTableCreateCompanionBuilder,
      $$EnglishSentenceTableUpdateCompanionBuilder,
      (
        EnglishSentenceData,
        BaseReferences<
          _$AppDatabase,
          $EnglishSentenceTable,
          EnglishSentenceData
        >,
      ),
      EnglishSentenceData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VocabulariesTableTableManager get vocabularies =>
      $$VocabulariesTableTableManager(_db, _db.vocabularies);
  $$EnglishSentenceTableTableManager get englishSentence =>
      $$EnglishSentenceTableTableManager(_db, _db.englishSentence);
}
