```marmaid
---
config:
  layout: elk
---
classDiagram

    DB Layer
    class AppDatabase {
        +int schemaVersion
        +Vocabularies vocabularies
        +EnglishTexts englishTexts
        +InternalDictionaries internalDictionaries
    }
    class Vocabularies {
        <<Table>>
        +int id
        +String englishWord
        +String japaneseTranslation
        +bool isHidden
        +String memo
        +DateTime createdAt
        +DateTime updatedAt
    }
    class InternalDictionaries {
        <<Table>>
        +int id
        +String key
        +String word
        +String mean
        +String memo
    }
    class EnglishTexts {
        <<Table>>
        +int id
        +String originalText
        +String parsedWordsJson
        +DateTime createdAt
        +DateTime updatedAt
    }

    %% namespace data{
    %%     class Based {
    %%         <<enumeration>>
    %%         vocabularies
    %%         dictionary
    %%         init
    %%     }
    %%     class SyncStatus {
    %%         <<enumeration>>
    %%         normal
    %%         err
    %%         load
    %%     }
    %%     class SortField {
    %%         <<enumeration>>
    %%         createdAt
    %%         englishWord
    %%     }
    %%     class SortOrder {
    %%         <<enumeration>>
    %%         asc
    %%         desc
    %%     }
    %%     class VocabEntry {
    %%         +int id
    %%         +String word
    %%         +String translation
    %%         +bool isShow
    %%         +bool nowShow
    %%         +String memo
    %%         +Based based
    %%         +copyWith(...) VocabEntry
    %%         +fromVocabularies(vocabulary) VocabEntry$
    %%         +fromInit(text) VocabEntry$
    %%         +fromDictionary(dictionary) VocabEntry$
    %%         +fromJson(json) VocabEntry$
    %%         +toJson() Map
    %%     }
    %%     class CardData {
    %%         +String showWord
    %%         +DateTime createdAt
    %%         +DateTime updatedAt
    %%         +VocabEntry vocab
    %%         +copyWith(...) CardData
    %%         +fromVocabularies(vocabulary) CardData$
    %%         +fromDctionaries(ve) CardData$
    %%         +fromInit(word) CardData$
    %%     }
    %%     class TokenData {
    %%         +int id
    %%         +bool isWord
    %%         +String showWord
    %%         +VocabEntry vocab
    %%         +copyWith(...) TokenData
    %%         +fromString(id, text) TokenData$
    %%         +fromTextProcesser(token, id, vocabulary) TokenData$
    %%         +fromJson(json) TokenData$
    %%         +toJson() Map
    %%     }
    %%     class TranslationData {
    %%         +String originalText
    %%         +List~TokenData~ tokens
    %%         +copyWith(originalText, tokens) TranslationData
    %%     }
    %%     class DictionaryData {
    %%         +CardData showWord
    %%         +List~CardData~ vocabularyWords
    %%         +List~VocabEntry~ dictionaryWords
    %%         +copyWith(...) DictionaryData
    %%     }
    %%     class SortingData {
    %%         +SortField field
    %%         +SortOrder order
    %%         +String searchWord
    %%         +String typingWord
    %%         +copyWith(...) SortingData
    %%     }
    %%     class BookData {
    %%         +int pageSize
    %%         +List~CardData~ words
    %%         +SyncStatus tailStatus
    %%         +bool isDataEnd
    %%         +copyWith(...) BookData
    %%     }
    %%     class TileData {
    %%         +int id
    %%         +String text
    %%         +copyWith(text) TileData
    %%     }
    %%     class TilesData {
    %%         +List~TileData~ list
    %%         +copyWith(list) TilesData
    %%     }
    %% }

    namespace repository_imp{
        class LocalBatchRepository {
            +AppDatabase db
            +fetchTranslationsBatch(keys) Future~List~Vocabulary~~
        }
        class LocalDicrionaryRepository {
            +AppDatabase db
            +fetchVocabularyEntries(englishWord) Future~List~Vocabulary~~
            +fetchDictionaryEntries(wordKey) Future~List~InternalDictionary~~
        }
        class LocalRegiserRepository {
            +AppDatabase db
            +addVocabulary(card) Future~Vocabulary~
            +updateVocabulary(card) Future~Vocabulary~
            +deleteVocabulary(id) Future~int~
            -_setAllOthersHidden(word) Future~int~
        }
        class LocalBookRepository {
            +AppDatabase db
            +fetchVocabulariesWithPaging(offset, limit, queryText, sorter) Future~List~Vocabulary~~
            -_getSortExpression(field) Expression
            -_getSortMode(order) OrderingMode
        }
        class LocalTilesRepository {
            +AppDatabase db
            +createTile(text, chain) Future~int~
            +fetchAllTiles() Future~List~TileData~~
            +fetchTileDetail(id) Future~EnglishText~
            +deleteTile(id) Future~int~
        }
    }

    namespace repository {
        class TilesRepository {
            <<interface>>
            +createTile(text, chain) Future~int~
            +fetchAllTiles() Future~List~TileData~~
            +fetchTileDetail(id) Future~EnglishText~
            +deleteTile(id) Future~int~
        }
        class TranslationRepository {
            <<interface>>
            +fetchTranslationsBatch(keys) Future~List~Vocabulary~~
        }
        class DicrionaryRepository {
            <<interface>>
            +fetchVocabularyEntries(englishWord) Future~List~Vocabulary~~
            +fetchDictionaryEntries(wordKey) Future~List~InternalDictionary~~
        }
        class BookRepository {
            <<interface>>
            +fetchVocabulariesWithPaging(offset, limit, queryText, sorter) Future~List~Vocabulary~~
        }
        class RegisterRepository {
            <<interface>>
            +addVocabulary(card) Future~Vocabulary~
            +updateVocabulary(card) Future~Vocabulary~
            +deleteVocabulary(id) Future~int~
        }
    }

    %% Translation
    %% class TextProcessor {
    %%     +TranslationRepository ds
    %%     +partTranslation(nowTokens, newText) Future~List~TokenData~~
    %%     +fullTranslation(text) Future~List~TokenData~~
    %%     -_tokenizeText(text) List~TokenData~
    %% }
    %% class TranslationNotifier {
    %%     +build() TranslationState
    %%     +restore(text, chain) void
    %%     +updateToken(updatedToken) void
    %%     +updateOriginalText(newText) void
    %%     +pushTriggerButton() void
    %%     -_runTranslation(isFullScan) Future~void~
    %% }

    %% Dictionary
    %% class DictionaryNotifier {
    %%     +build() Future~DictionaryState~
    %%     +toggleVisibility(card) Future~void~
    %% }
    %% class SelectedTokenNotifier {
    %%     +build() TokenData
    %%     +selsectNew(token) void
    %% }

    %% Register
    %% class RegiDataReceiver {
    %%     +build() CardData
    %%     +receiveRegisteredCard(card) void
    %%     +receiveDictionaryCard(ve) void
    %%     +receiveNew(word) void
    %%     -_initialCard(word) CardData
    %% }
    %% class RegistrationNotifier {
    %%     +build() Future~CardData~
    %%     +updateEnglish(text) void
    %%     +updateTranslation(text) void
    %%     +updateMemo(text) void
    %%     +toggleIsShowing(isShow) void
    %%     +save() Future~void~
    %%     +delete() Future~void~
    %%     -_updateVocab(update) void
    %% }

    %% Wordbook
    %% class SortingNotifier {
    %%     +build() SortingData
    %%     +setField(newField) void
    %%     +setOrder(newOrder) void
    %%     +setSearchWord(text) void
    %%     +setTypeWord(text) void
    %% }
    %% class BookNotifier {
    %%     +build() Future~BookData~
    %%     +loadNextPage() Future~void~
    %%     +reload() Future~void~
    %%     -_fetchData(offset, limit, queryText) Future~List~CardData~~
    %% }

    %% Drawer / Tiles
    %% class TilesNotifier {
    %%     +build() Future~TilesData~
    %%     +addTile() Future~void~
    %%     +deleteTile(id) Future~void~
    %%     +makeTokenChain(id) Future~void~
    %% }

    %% DB relationships
    AppDatabase "1" --> "1" Vocabularies : has table
    AppDatabase "1" --> "1" EnglishTexts : has table
    AppDatabase "1" --> "1" InternalDictionaries : has table

    %% Enum relationships
    %% VocabEntry --> Based : uses
    %% BookData --> SyncStatus : uses
    %% SortingData --> SortField : uses
    %% SortingData --> SortOrder : uses

    %% Domain model composition
    %% CardData --> VocabEntry : has
    %% TokenData --> VocabEntry : has
    %% TranslationData o-- TokenData : contains
    %% DictionaryData o-- CardData : contains
    %% DictionaryData o-- VocabEntry : contains
    %% BookData o-- CardData : contains
    %% TilesData o-- TileData : contains

    %% Translation layer
    LocalBatchRepository ..|> TranslationRepository : realizes
    LocalBatchRepository --> AppDatabase : depends
    TextProcessor --> TranslationRepository : depends
    %% TranslationNotifier --> TranslationData : manages
    %% TranslationNotifier ..> TextProcessor : depends

    %% Dictionary layer
    LocalDicrionaryRepository ..|> DicrionaryRepository : realizes
    LocalDicrionaryRepository --> AppDatabase : depends
    %% DictionaryNotifier --> DictionaryData : manages
    DictionaryNotifier ..> DicrionaryRepository : depends
    %% DictionaryNotifier ..> SelectedTokenNotifier : depends
    %% DictionaryNotifier ..> TranslationNotifier : depends

    %% Register layer
    LocalRegiserRepository ..|> RegisterRepository : realizes
    LocalRegiserRepository --> AppDatabase : depends
    %% RegiDataReceiver --> CardData : manages
    RegistrationNotifier ..> RegisterRepository : depends
    %% RegistrationNotifier ..> RegiDataReceiver : depends
    %% RegistrationNotifier ..> SelectedTokenNotifier : depends
    %% RegistrationNotifier ..> TranslationNotifier : depends
    %% RegistrationNotifier ..> BookNotifier : depends
    %% RegistrationNotifier --> CardData : manages

    %% Wordbook layer
    LocalBookRepository ..|> BookRepository : realizes
    LocalBookRepository --> AppDatabase : depends
    LocalBookRepository --> SortingData : depends
    %% BookNotifier --> BookData : manages
    BookNotifier ..> BookRepository : depends
    %% BookNotifier ..> SortingNotifier : depends
    %% SortingNotifier --> SortingData : manages

    %% Tiles layer
    LocalTilesRepository ..|> TilesRepository : realizes
    LocalTilesRepository --> AppDatabase : depends
    %% TilesNotifier --> TilesData : manages
    TilesNotifier ..> TilesRepository : depends
    %% TilesNotifier ..> TranslationNotifier : depends
```

```marmaid
---
config:
  layout: elk
---
classDiagram

    %% DB Layer
    %% class AppDatabase {
    %%     +int schemaVersion
    %%     +Vocabularies vocabularies
    %%     +EnglishTexts englishTexts
    %%     +InternalDictionaries internalDictionaries
    %% }
    %% class Vocabularies {
    %%     <<Table>>
    %%     +int id
    %%     +String englishWord
    %%     +String japaneseTranslation
    %%     +bool isHidden
    %%     +String memo
    %%     +DateTime createdAt
    %%     +DateTime updatedAt
    %% }
    %% class InternalDictionaries {
    %%     <<Table>>
    %%     +int id
    %%     +String key
    %%     +String word
    %%     +String mean
    %%     +String memo
    %% }
    %% class EnglishTexts {
    %%     <<Table>>
    %%     +int id
    %%     +String originalText
    %%     +String parsedWordsJson
    %%     +DateTime createdAt
    %%     +DateTime updatedAt
    %% }

    namespace data{
        class Based {
            <<enumeration>>
            vocabularies
            dictionary
            init
        }
        class SyncStatus {
            <<enumeration>>
            normal
            err
            load
        }
        class SortField {
            <<enumeration>>
            createdAt
            englishWord
        }
        class SortOrder {
            <<enumeration>>
            asc
            desc
        }
        class VocabEntry {
            +int id
            +String word
            +String translation
            +bool isShow
            +bool nowShow
            +String memo
            +Based based
            +copyWith(...) VocabEntry
            +fromVocabularies(vocabulary) VocabEntry$
            +fromInit(text) VocabEntry$
            +fromDictionary(dictionary) VocabEntry$
            +fromJson(json) VocabEntry$
            +toJson() Map
        }
        class CardData {
            +String showWord
            +DateTime createdAt
            +DateTime updatedAt
            +VocabEntry vocab
            +copyWith(...) CardData
            +fromVocabularies(vocabulary) CardData$
            +fromDctionaries(ve) CardData$
            +fromInit(word) CardData$
        }
        class TokenData {
            +int id
            +bool isWord
            +String showWord
            +VocabEntry vocab
            +copyWith(...) TokenData
            +fromString(id, text) TokenData$
            +fromTextProcesser(token, id, vocabulary) TokenData$
            +fromJson(json) TokenData$
            +toJson() Map
        }
        class TranslationData {
            +String originalText
            +List~TokenData~ tokens
            +copyWith(originalText, tokens) TranslationData
        }
        class DictionaryData {
            +CardData showWord
            +List~CardData~ vocabularyWords
            +List~VocabEntry~ dictionaryWords
            +copyWith(...) DictionaryData
        }
        class SortingData {
            +SortField field
            +SortOrder order
            +String searchWord
            +String typingWord
            +copyWith(...) SortingData
        }
        class BookData {
            +int pageSize
            +List~CardData~ words
            +SyncStatus tailStatus
            +bool isDataEnd
            +copyWith(...) BookData
        }
        class TileData {
            +int id
            +String text
            +copyWith(text) TileData
        }
        class TilesData {
            +List~TileData~ list
            +copyWith(list) TilesData
        }
    }

    %% namespace repository_imp{
    %%     class LocalBatchRepository {
    %%         +AppDatabase db
    %%         +fetchTranslationsBatch(keys) Future~List~Vocabulary~~
    %%     }
    %%     class LocalDicrionaryRepository {
    %%         +AppDatabase db
    %%         +fetchVocabularyEntries(englishWord) Future~List~Vocabulary~~
    %%         +fetchDictionaryEntries(wordKey) Future~List~InternalDictionary~~
    %%     }
    %%     class LocalRegiserRepository {
    %%         +AppDatabase db
    %%         +addVocabulary(card) Future~Vocabulary~
    %%         +updateVocabulary(card) Future~Vocabulary~
    %%         +deleteVocabulary(id) Future~int~
    %%         -_setAllOthersHidden(word) Future~int~
    %%     }
    %%     class LocalBookRepository {
    %%         +AppDatabase db
    %%         +fetchVocabulariesWithPaging(offset, limit, queryText, sorter) Future~List~Vocabulary~~
    %%         -_getSortExpression(field) Expression
    %%         -_getSortMode(order) OrderingMode
    %%     }
    %%     class LocalTilesRepository {
    %%         +AppDatabase db
    %%         +createTile(text, chain) Future~int~
    %%         +fetchAllTiles() Future~List~TileData~~
    %%         +fetchTileDetail(id) Future~EnglishText~
    %%         +deleteTile(id) Future~int~
    %%     }
    %% }

    %% namespace repository {
    %%     class TilesRepository {
    %%         <<interface>>
    %%         +createTile(text, chain) Future~int~
    %%         +fetchAllTiles() Future~List~TileData~~
    %%         +fetchTileDetail(id) Future~EnglishText~
    %%         +deleteTile(id) Future~int~
    %%     }
    %%     class TranslationRepository {
    %%         <<interface>>
    %%         +fetchTranslationsBatch(keys) Future~List~Vocabulary~~
    %%     }
    %%     class DicrionaryRepository {
    %%         <<interface>>
    %%         +fetchVocabularyEntries(englishWord) Future~List~Vocabulary~~
    %%         +fetchDictionaryEntries(wordKey) Future~List~InternalDictionary~~
    %%     }
    %%     class BookRepository {
    %%         <<interface>>
    %%         +fetchVocabulariesWithPaging(offset, limit, queryText, sorter) Future~List~Vocabulary~~
    %%     }
    %%     class RegisterRepository {
    %%         <<interface>>
    %%         +addVocabulary(card) Future~Vocabulary~
    %%         +updateVocabulary(card) Future~Vocabulary~
    %%         +deleteVocabulary(id) Future~int~
    %%     }
    %% }

    %% Translation
    class TextProcessor {
        +TranslationRepository ds
        +partTranslation(nowTokens, newText) Future~List~TokenData~~
        +fullTranslation(text) Future~List~TokenData~~
        -_tokenizeText(text) List~TokenData~
    }
    class TranslationNotifier {
        +build() TranslationState
        +restore(text, chain) void
        +updateToken(updatedToken) void
        +updateOriginalText(newText) void
        +pushTriggerButton() void
        -_runTranslation(isFullScan) Future~void~
    }

    %% Dictionary
    class DictionaryNotifier {
        +build() Future~DictionaryState~
        +toggleVisibility(card) Future~void~
    }
    class SelectedTokenNotifier {
        +build() TokenData
        +selsectNew(token) void
    }

    %% Register
    class RegiDataReceiver {
        +build() CardData
        +receiveRegisteredCard(card) void
        +receiveDictionaryCard(ve) void
        +receiveNew(word) void
        -_initialCard(word) CardData
    }
    class RegistrationNotifier {
        +build() Future~CardData~
        +updateEnglish(text) void
        +updateTranslation(text) void
        +updateMemo(text) void
        +toggleIsShowing(isShow) void
        +save() Future~void~
        +delete() Future~void~
        -_updateVocab(update) void
    }

    %% Wordbook
    class SortingNotifier {
        +build() SortingData
        +setField(newField) void
        +setOrder(newOrder) void
        +setSearchWord(text) void
        +setTypeWord(text) void
    }
    class BookNotifier {
        +build() Future~BookData~
        +loadNextPage() Future~void~
        +reload() Future~void~
        -_fetchData(offset, limit, queryText) Future~List~CardData~~
    }

    %% Drawer / Tiles
    class TilesNotifier {
        +build() Future~TilesData~
        +addTile() Future~void~
        +deleteTile(id) Future~void~
        +makeTokenChain(id) Future~void~
    }

    %% DB relationships
    %% AppDatabase "1" --> "1" Vocabularies : has table
    %% AppDatabase "1" --> "1" EnglishTexts : has table
    %% AppDatabase "1" --> "1" InternalDictionaries : has table

    %% Enum relationships
    VocabEntry --> Based : uses
    BookData --> SyncStatus : uses
    SortingData --> SortField : uses
    SortingData --> SortOrder : uses

    %% Domain model composition
    CardData --> VocabEntry : has
    TokenData --> VocabEntry : has
    TranslationData o-- TokenData : contains
    DictionaryData o-- CardData : contains
    DictionaryData o-- VocabEntry : contains
    BookData o-- CardData : contains
    TilesData o-- TileData : contains

    %% Translation layer
    %% LocalBatchRepository ..|> TranslationRepository : realizes
    %% LocalBatchRepository --> AppDatabase : depends
    %% TextProcessor --> TranslationRepository : depends
    TranslationNotifier --> TranslationData : manages
    TranslationNotifier ..> TextProcessor : depends

    %% Dictionary layer
    %% LocalDicrionaryRepository ..|> DicrionaryRepository : realizes
    %% LocalDicrionaryRepository --> AppDatabase : depends
    DictionaryNotifier --> DictionaryData : manages
    %% DictionaryNotifier ..> DicrionaryRepository : depends
    DictionaryNotifier ..> SelectedTokenNotifier : depends
    DictionaryNotifier ..> TranslationNotifier : depends

    %% Register layer
    %% LocalRegiserRepository ..|> RegisterRepository : realizes
    %% LocalRegiserRepository --> AppDatabase : depends
    RegiDataReceiver --> CardData : manages
    %% RegistrationNotifier ..> RegisterRepository : depends
    RegistrationNotifier ..> RegiDataReceiver : depends
    RegistrationNotifier ..> SelectedTokenNotifier : depends
    RegistrationNotifier ..> TranslationNotifier : depends
    RegistrationNotifier ..> BookNotifier : depends
    RegistrationNotifier --> CardData : manages

    %% Wordbook layer
    %% LocalBookRepository ..|> BookRepository : realizes
    %% LocalBookRepository --> AppDatabase : depends
    %% LocalBookRepository --> SortingData : depends
    BookNotifier --> BookData : manages
    %% BookNotifier ..> BookRepository : depends
    BookNotifier ..> SortingNotifier : depends
    SortingNotifier --> SortingData : manages

    %% Tiles layer
    %% LocalTilesRepository ..|> TilesRepository : realizes
    %% LocalTilesRepository --> AppDatabase : depends
    TilesNotifier --> TilesData : manages
    %% TilesNotifier ..> TilesRepository : depends
    TilesNotifier ..> TranslationNotifier : depends
```
