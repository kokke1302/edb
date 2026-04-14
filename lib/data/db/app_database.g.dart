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
  static const VerificationMeta _englishWordMeta = const VerificationMeta(
    'englishWord',
  );
  @override
  late final GeneratedColumn<String> englishWord = GeneratedColumn<String>(
    'english_word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _japaneseTranslationMeta =
      const VerificationMeta('japaneseTranslation');
  @override
  late final GeneratedColumn<String> japaneseTranslation =
      GeneratedColumn<String>(
        'japanese_translation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
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
    englishWord,
    japaneseTranslation,
    isHidden,
    memo,
    createdAt,
    updatedAt,
  ];
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
    if (data.containsKey('english_word')) {
      context.handle(
        _englishWordMeta,
        englishWord.isAcceptableOrUnknown(
          data['english_word']!,
          _englishWordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishWordMeta);
    }
    if (data.containsKey('japanese_translation')) {
      context.handle(
        _japaneseTranslationMeta,
        japaneseTranslation.isAcceptableOrUnknown(
          data['japanese_translation']!,
          _japaneseTranslationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_japaneseTranslationMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    } else if (isInserting) {
      context.missing(_isHiddenMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    } else if (isInserting) {
      context.missing(_memoMeta);
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
  Vocabulary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vocabulary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      englishWord: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_word'],
      )!,
      japaneseTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}japanese_translation'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
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
  $VocabulariesTable createAlias(String alias) {
    return $VocabulariesTable(attachedDatabase, alias);
  }
}

class Vocabulary extends DataClass implements Insertable<Vocabulary> {
  final int id;
  final String englishWord;
  final String japaneseTranslation;
  final bool isHidden;
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Vocabulary({
    required this.id,
    required this.englishWord,
    required this.japaneseTranslation,
    required this.isHidden,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['english_word'] = Variable<String>(englishWord);
    map['japanese_translation'] = Variable<String>(japaneseTranslation);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['memo'] = Variable<String>(memo);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VocabulariesCompanion toCompanion(bool nullToAbsent) {
    return VocabulariesCompanion(
      id: Value(id),
      englishWord: Value(englishWord),
      japaneseTranslation: Value(japaneseTranslation),
      isHidden: Value(isHidden),
      memo: Value(memo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Vocabulary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vocabulary(
      id: serializer.fromJson<int>(json['id']),
      englishWord: serializer.fromJson<String>(json['englishWord']),
      japaneseTranslation: serializer.fromJson<String>(
        json['japaneseTranslation'],
      ),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      memo: serializer.fromJson<String>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'englishWord': serializer.toJson<String>(englishWord),
      'japaneseTranslation': serializer.toJson<String>(japaneseTranslation),
      'isHidden': serializer.toJson<bool>(isHidden),
      'memo': serializer.toJson<String>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Vocabulary copyWith({
    int? id,
    String? englishWord,
    String? japaneseTranslation,
    bool? isHidden,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Vocabulary(
    id: id ?? this.id,
    englishWord: englishWord ?? this.englishWord,
    japaneseTranslation: japaneseTranslation ?? this.japaneseTranslation,
    isHidden: isHidden ?? this.isHidden,
    memo: memo ?? this.memo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Vocabulary copyWithCompanion(VocabulariesCompanion data) {
    return Vocabulary(
      id: data.id.present ? data.id.value : this.id,
      englishWord: data.englishWord.present
          ? data.englishWord.value
          : this.englishWord,
      japaneseTranslation: data.japaneseTranslation.present
          ? data.japaneseTranslation.value
          : this.japaneseTranslation,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vocabulary(')
          ..write('id: $id, ')
          ..write('englishWord: $englishWord, ')
          ..write('japaneseTranslation: $japaneseTranslation, ')
          ..write('isHidden: $isHidden, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    englishWord,
    japaneseTranslation,
    isHidden,
    memo,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vocabulary &&
          other.id == this.id &&
          other.englishWord == this.englishWord &&
          other.japaneseTranslation == this.japaneseTranslation &&
          other.isHidden == this.isHidden &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VocabulariesCompanion extends UpdateCompanion<Vocabulary> {
  final Value<int> id;
  final Value<String> englishWord;
  final Value<String> japaneseTranslation;
  final Value<bool> isHidden;
  final Value<String> memo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const VocabulariesCompanion({
    this.id = const Value.absent(),
    this.englishWord = const Value.absent(),
    this.japaneseTranslation = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VocabulariesCompanion.insert({
    this.id = const Value.absent(),
    required String englishWord,
    required String japaneseTranslation,
    required bool isHidden,
    required String memo,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : englishWord = Value(englishWord),
       japaneseTranslation = Value(japaneseTranslation),
       isHidden = Value(isHidden),
       memo = Value(memo);
  static Insertable<Vocabulary> custom({
    Expression<int>? id,
    Expression<String>? englishWord,
    Expression<String>? japaneseTranslation,
    Expression<bool>? isHidden,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (englishWord != null) 'english_word': englishWord,
      if (japaneseTranslation != null)
        'japanese_translation': japaneseTranslation,
      if (isHidden != null) 'is_hidden': isHidden,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VocabulariesCompanion copyWith({
    Value<int>? id,
    Value<String>? englishWord,
    Value<String>? japaneseTranslation,
    Value<bool>? isHidden,
    Value<String>? memo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return VocabulariesCompanion(
      id: id ?? this.id,
      englishWord: englishWord ?? this.englishWord,
      japaneseTranslation: japaneseTranslation ?? this.japaneseTranslation,
      isHidden: isHidden ?? this.isHidden,
      memo: memo ?? this.memo,
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
    if (englishWord.present) {
      map['english_word'] = Variable<String>(englishWord.value);
    }
    if (japaneseTranslation.present) {
      map['japanese_translation'] = Variable<String>(japaneseTranslation.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
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
    return (StringBuffer('VocabulariesCompanion(')
          ..write('id: $id, ')
          ..write('englishWord: $englishWord, ')
          ..write('japaneseTranslation: $japaneseTranslation, ')
          ..write('isHidden: $isHidden, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EnglishTextsTable extends EnglishTexts
    with TableInfo<$EnglishTextsTable, EnglishText> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnglishTextsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _parsedWordsJsonMeta = const VerificationMeta(
    'parsedWordsJson',
  );
  @override
  late final GeneratedColumn<String> parsedWordsJson = GeneratedColumn<String>(
    'parsed_words_json',
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
    parsedWordsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'english_texts';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnglishText> instance, {
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
    if (data.containsKey('parsed_words_json')) {
      context.handle(
        _parsedWordsJsonMeta,
        parsedWordsJson.isAcceptableOrUnknown(
          data['parsed_words_json']!,
          _parsedWordsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parsedWordsJsonMeta);
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
  EnglishText map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnglishText(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      originalText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_text'],
      )!,
      parsedWordsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parsed_words_json'],
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
  $EnglishTextsTable createAlias(String alias) {
    return $EnglishTextsTable(attachedDatabase, alias);
  }
}

class EnglishText extends DataClass implements Insertable<EnglishText> {
  final int id;
  final String originalText;
  final String parsedWordsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EnglishText({
    required this.id,
    required this.originalText,
    required this.parsedWordsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['original_text'] = Variable<String>(originalText);
    map['parsed_words_json'] = Variable<String>(parsedWordsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EnglishTextsCompanion toCompanion(bool nullToAbsent) {
    return EnglishTextsCompanion(
      id: Value(id),
      originalText: Value(originalText),
      parsedWordsJson: Value(parsedWordsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EnglishText.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnglishText(
      id: serializer.fromJson<int>(json['id']),
      originalText: serializer.fromJson<String>(json['originalText']),
      parsedWordsJson: serializer.fromJson<String>(json['parsedWordsJson']),
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
      'parsedWordsJson': serializer.toJson<String>(parsedWordsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EnglishText copyWith({
    int? id,
    String? originalText,
    String? parsedWordsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EnglishText(
    id: id ?? this.id,
    originalText: originalText ?? this.originalText,
    parsedWordsJson: parsedWordsJson ?? this.parsedWordsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EnglishText copyWithCompanion(EnglishTextsCompanion data) {
    return EnglishText(
      id: data.id.present ? data.id.value : this.id,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      parsedWordsJson: data.parsedWordsJson.present
          ? data.parsedWordsJson.value
          : this.parsedWordsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnglishText(')
          ..write('id: $id, ')
          ..write('originalText: $originalText, ')
          ..write('parsedWordsJson: $parsedWordsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, originalText, parsedWordsJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnglishText &&
          other.id == this.id &&
          other.originalText == this.originalText &&
          other.parsedWordsJson == this.parsedWordsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EnglishTextsCompanion extends UpdateCompanion<EnglishText> {
  final Value<int> id;
  final Value<String> originalText;
  final Value<String> parsedWordsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EnglishTextsCompanion({
    this.id = const Value.absent(),
    this.originalText = const Value.absent(),
    this.parsedWordsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EnglishTextsCompanion.insert({
    this.id = const Value.absent(),
    required String originalText,
    required String parsedWordsJson,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : originalText = Value(originalText),
       parsedWordsJson = Value(parsedWordsJson);
  static Insertable<EnglishText> custom({
    Expression<int>? id,
    Expression<String>? originalText,
    Expression<String>? parsedWordsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalText != null) 'original_text': originalText,
      if (parsedWordsJson != null) 'parsed_words_json': parsedWordsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EnglishTextsCompanion copyWith({
    Value<int>? id,
    Value<String>? originalText,
    Value<String>? parsedWordsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EnglishTextsCompanion(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      parsedWordsJson: parsedWordsJson ?? this.parsedWordsJson,
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
    if (parsedWordsJson.present) {
      map['parsed_words_json'] = Variable<String>(parsedWordsJson.value);
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
    return (StringBuffer('EnglishTextsCompanion(')
          ..write('id: $id, ')
          ..write('originalText: $originalText, ')
          ..write('parsedWordsJson: $parsedWordsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $InternalDictionariesTable extends InternalDictionaries
    with TableInfo<$InternalDictionariesTable, InternalDictionary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InternalDictionariesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meanMeta = const VerificationMeta('mean');
  @override
  late final GeneratedColumn<String> mean = GeneratedColumn<String>(
    'mean',
    aliasedName,
    false,
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
  @override
  List<GeneratedColumn> get $columns => [id, key, word, mean, memo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'internal_dictionaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<InternalDictionary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('mean')) {
      context.handle(
        _meanMeta,
        mean.isAcceptableOrUnknown(data['mean']!, _meanMeta),
      );
    } else if (isInserting) {
      context.missing(_meanMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InternalDictionary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InternalDictionary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      mean: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mean'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
    );
  }

  @override
  $InternalDictionariesTable createAlias(String alias) {
    return $InternalDictionariesTable(attachedDatabase, alias);
  }
}

class InternalDictionary extends DataClass
    implements Insertable<InternalDictionary> {
  final int id;
  final String key;
  final String word;
  final String mean;
  final String? memo;
  const InternalDictionary({
    required this.id,
    required this.key,
    required this.word,
    required this.mean,
    this.memo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['word'] = Variable<String>(word);
    map['mean'] = Variable<String>(mean);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  InternalDictionariesCompanion toCompanion(bool nullToAbsent) {
    return InternalDictionariesCompanion(
      id: Value(id),
      key: Value(key),
      word: Value(word),
      mean: Value(mean),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory InternalDictionary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InternalDictionary(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      word: serializer.fromJson<String>(json['word']),
      mean: serializer.fromJson<String>(json['mean']),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'word': serializer.toJson<String>(word),
      'mean': serializer.toJson<String>(mean),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  InternalDictionary copyWith({
    int? id,
    String? key,
    String? word,
    String? mean,
    Value<String?> memo = const Value.absent(),
  }) => InternalDictionary(
    id: id ?? this.id,
    key: key ?? this.key,
    word: word ?? this.word,
    mean: mean ?? this.mean,
    memo: memo.present ? memo.value : this.memo,
  );
  InternalDictionary copyWithCompanion(InternalDictionariesCompanion data) {
    return InternalDictionary(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      word: data.word.present ? data.word.value : this.word,
      mean: data.mean.present ? data.mean.value : this.mean,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InternalDictionary(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('word: $word, ')
          ..write('mean: $mean, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, word, mean, memo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InternalDictionary &&
          other.id == this.id &&
          other.key == this.key &&
          other.word == this.word &&
          other.mean == this.mean &&
          other.memo == this.memo);
}

class InternalDictionariesCompanion
    extends UpdateCompanion<InternalDictionary> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> word;
  final Value<String> mean;
  final Value<String?> memo;
  const InternalDictionariesCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.word = const Value.absent(),
    this.mean = const Value.absent(),
    this.memo = const Value.absent(),
  });
  InternalDictionariesCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String word,
    required String mean,
    this.memo = const Value.absent(),
  }) : key = Value(key),
       word = Value(word),
       mean = Value(mean);
  static Insertable<InternalDictionary> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? word,
    Expression<String>? mean,
    Expression<String>? memo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (word != null) 'word': word,
      if (mean != null) 'mean': mean,
      if (memo != null) 'memo': memo,
    });
  }

  InternalDictionariesCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<String>? word,
    Value<String>? mean,
    Value<String?>? memo,
  }) {
    return InternalDictionariesCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      word: word ?? this.word,
      mean: mean ?? this.mean,
      memo: memo ?? this.memo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (mean.present) {
      map['mean'] = Variable<String>(mean.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InternalDictionariesCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('word: $word, ')
          ..write('mean: $mean, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VocabulariesTable vocabularies = $VocabulariesTable(this);
  late final $EnglishTextsTable englishTexts = $EnglishTextsTable(this);
  late final $InternalDictionariesTable internalDictionaries =
      $InternalDictionariesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vocabularies,
    englishTexts,
    internalDictionaries,
  ];
}

typedef $$VocabulariesTableCreateCompanionBuilder =
    VocabulariesCompanion Function({
      Value<int> id,
      required String englishWord,
      required String japaneseTranslation,
      required bool isHidden,
      required String memo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$VocabulariesTableUpdateCompanionBuilder =
    VocabulariesCompanion Function({
      Value<int> id,
      Value<String> englishWord,
      Value<String> japaneseTranslation,
      Value<bool> isHidden,
      Value<String> memo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
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

  ColumnFilters<String> get englishWord => $composableBuilder(
    column: $table.englishWord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get japaneseTranslation => $composableBuilder(
    column: $table.japaneseTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  ColumnOrderings<String> get englishWord => $composableBuilder(
    column: $table.englishWord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get japaneseTranslation => $composableBuilder(
    column: $table.japaneseTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  GeneratedColumn<String> get englishWord => $composableBuilder(
    column: $table.englishWord,
    builder: (column) => column,
  );

  GeneratedColumn<String> get japaneseTranslation => $composableBuilder(
    column: $table.japaneseTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
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
                Value<String> englishWord = const Value.absent(),
                Value<String> japaneseTranslation = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<String> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VocabulariesCompanion(
                id: id,
                englishWord: englishWord,
                japaneseTranslation: japaneseTranslation,
                isHidden: isHidden,
                memo: memo,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String englishWord,
                required String japaneseTranslation,
                required bool isHidden,
                required String memo,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VocabulariesCompanion.insert(
                id: id,
                englishWord: englishWord,
                japaneseTranslation: japaneseTranslation,
                isHidden: isHidden,
                memo: memo,
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
typedef $$EnglishTextsTableCreateCompanionBuilder =
    EnglishTextsCompanion Function({
      Value<int> id,
      required String originalText,
      required String parsedWordsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$EnglishTextsTableUpdateCompanionBuilder =
    EnglishTextsCompanion Function({
      Value<int> id,
      Value<String> originalText,
      Value<String> parsedWordsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$EnglishTextsTableFilterComposer
    extends Composer<_$AppDatabase, $EnglishTextsTable> {
  $$EnglishTextsTableFilterComposer({
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

  ColumnFilters<String> get parsedWordsJson => $composableBuilder(
    column: $table.parsedWordsJson,
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

class $$EnglishTextsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnglishTextsTable> {
  $$EnglishTextsTableOrderingComposer({
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

  ColumnOrderings<String> get parsedWordsJson => $composableBuilder(
    column: $table.parsedWordsJson,
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

class $$EnglishTextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnglishTextsTable> {
  $$EnglishTextsTableAnnotationComposer({
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

  GeneratedColumn<String> get parsedWordsJson => $composableBuilder(
    column: $table.parsedWordsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EnglishTextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnglishTextsTable,
          EnglishText,
          $$EnglishTextsTableFilterComposer,
          $$EnglishTextsTableOrderingComposer,
          $$EnglishTextsTableAnnotationComposer,
          $$EnglishTextsTableCreateCompanionBuilder,
          $$EnglishTextsTableUpdateCompanionBuilder,
          (
            EnglishText,
            BaseReferences<_$AppDatabase, $EnglishTextsTable, EnglishText>,
          ),
          EnglishText,
          PrefetchHooks Function()
        > {
  $$EnglishTextsTableTableManager(_$AppDatabase db, $EnglishTextsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnglishTextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnglishTextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnglishTextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> originalText = const Value.absent(),
                Value<String> parsedWordsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EnglishTextsCompanion(
                id: id,
                originalText: originalText,
                parsedWordsJson: parsedWordsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String originalText,
                required String parsedWordsJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EnglishTextsCompanion.insert(
                id: id,
                originalText: originalText,
                parsedWordsJson: parsedWordsJson,
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

typedef $$EnglishTextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnglishTextsTable,
      EnglishText,
      $$EnglishTextsTableFilterComposer,
      $$EnglishTextsTableOrderingComposer,
      $$EnglishTextsTableAnnotationComposer,
      $$EnglishTextsTableCreateCompanionBuilder,
      $$EnglishTextsTableUpdateCompanionBuilder,
      (
        EnglishText,
        BaseReferences<_$AppDatabase, $EnglishTextsTable, EnglishText>,
      ),
      EnglishText,
      PrefetchHooks Function()
    >;
typedef $$InternalDictionariesTableCreateCompanionBuilder =
    InternalDictionariesCompanion Function({
      Value<int> id,
      required String key,
      required String word,
      required String mean,
      Value<String?> memo,
    });
typedef $$InternalDictionariesTableUpdateCompanionBuilder =
    InternalDictionariesCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<String> word,
      Value<String> mean,
      Value<String?> memo,
    });

class $$InternalDictionariesTableFilterComposer
    extends Composer<_$AppDatabase, $InternalDictionariesTable> {
  $$InternalDictionariesTableFilterComposer({
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

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mean => $composableBuilder(
    column: $table.mean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InternalDictionariesTableOrderingComposer
    extends Composer<_$AppDatabase, $InternalDictionariesTable> {
  $$InternalDictionariesTableOrderingComposer({
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

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mean => $composableBuilder(
    column: $table.mean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InternalDictionariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InternalDictionariesTable> {
  $$InternalDictionariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get mean =>
      $composableBuilder(column: $table.mean, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);
}

class $$InternalDictionariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InternalDictionariesTable,
          InternalDictionary,
          $$InternalDictionariesTableFilterComposer,
          $$InternalDictionariesTableOrderingComposer,
          $$InternalDictionariesTableAnnotationComposer,
          $$InternalDictionariesTableCreateCompanionBuilder,
          $$InternalDictionariesTableUpdateCompanionBuilder,
          (
            InternalDictionary,
            BaseReferences<
              _$AppDatabase,
              $InternalDictionariesTable,
              InternalDictionary
            >,
          ),
          InternalDictionary,
          PrefetchHooks Function()
        > {
  $$InternalDictionariesTableTableManager(
    _$AppDatabase db,
    $InternalDictionariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InternalDictionariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InternalDictionariesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InternalDictionariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> mean = const Value.absent(),
                Value<String?> memo = const Value.absent(),
              }) => InternalDictionariesCompanion(
                id: id,
                key: key,
                word: word,
                mean: mean,
                memo: memo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                required String word,
                required String mean,
                Value<String?> memo = const Value.absent(),
              }) => InternalDictionariesCompanion.insert(
                id: id,
                key: key,
                word: word,
                mean: mean,
                memo: memo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InternalDictionariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InternalDictionariesTable,
      InternalDictionary,
      $$InternalDictionariesTableFilterComposer,
      $$InternalDictionariesTableOrderingComposer,
      $$InternalDictionariesTableAnnotationComposer,
      $$InternalDictionariesTableCreateCompanionBuilder,
      $$InternalDictionariesTableUpdateCompanionBuilder,
      (
        InternalDictionary,
        BaseReferences<
          _$AppDatabase,
          $InternalDictionariesTable,
          InternalDictionary
        >,
      ),
      InternalDictionary,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VocabulariesTableTableManager get vocabularies =>
      $$VocabulariesTableTableManager(_db, _db.vocabularies);
  $$EnglishTextsTableTableManager get englishTexts =>
      $$EnglishTextsTableTableManager(_db, _db.englishTexts);
  $$InternalDictionariesTableTableManager get internalDictionaries =>
      $$InternalDictionariesTableTableManager(_db, _db.internalDictionaries);
}
