## クラス図

```marmaid
---
config:
  layout: elk
---
classDiagram
  namespace Data {
    class Based {
      <<enumeration>>
      vocabularies
      dictionary
      init
    }
    class VocabEntry {
      +String word
      +String translation
      +bool isShow
      +bool nowShow
      +String memo
      +Based based
      +copyWith() VocabEntry
      +fromVocabularies(entity) VocabEntry
      +fromfromToken(text) VocabEntry
      +fromfromDictionary(entity) VocabEntry
      +toJson() Map<String, dynamic>
      +fromJson(json) VocabEntry
    }
    class TranslationDBSource {
      +fetchTranslationsBatch(keys) Future~List~TokenData~~
    }
    class TokenData {
      +int id
      +bool isWord
      +VocabEntry vocab;
      +copyWith() TokenData
      +fromString() TokenData
      +toJson() Map<String, dynamic>
      +fromJson(json) TokenData
    }
    class TranslationState {
      +String originalText
      +List~TokenData~ tokens
      +copyWith() TranslationState
      +targetToken(id) TokenData
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
    class SyncStatus {
      <<enumeration>>
      noemal
      err
      load
    }
    class CardData {
      +int id
      +DateTime createdAt
      +DateTime updatedAt
      +VocabEntry vocab;
      +copyWith() CardData
      +fromDB(entry) CardData
    }
    class WordListState {
      +int pageSize
      +List~CardData~ words
      +SyncStatus tailStatus
      +bool isDataEnd
      +copyWith() WordListState
    }
    class SortSetting {
      +SortField field
      +SortOrder order
      +String searchWord
      +String typingWord
      +copyWith() SortSetting
    }
    class TileData {
      +int id
      +String text
      +copyWith(id, text) TileData
    }
    class TileState {
      +List<TileData> list
      +copyWith(list) TileState
    }
  }

  namespace domain{
    class LocalBatchRepository{
      +AppDatabase db
      +fetchTranslationsBatch() Future~List~TokenData~~
    }
    class TextProcessor{
      +TranslationDBSource ds
      +incrementalTranslation(nowTokens, newText) Future~List~TokenData~~
      +fullTranslation(text) Future~List~TokenData~~
    }
    class TranslationNotifier {
      +TranslationState state
      +build() TranslationState
      +restore(text, chain)
      +updateToken(updatedToken)
      +updateOriginalText(newText)
      +pushTriggerButton()
    }
    class WordListNotifier {
      +WordListState state
      +build() WordListState
      +loadNextPage() Future~void~
      +reload() Future~void~
    }
    class ListRepository {
      +AppDatabase db
      +fetchVocabulariesWithPaging(offset, limit, queryText, sorter)
    }
    class SortSettingNotifier {
      +SortSetting state
      +build() SortSetting
      +setField(newField)
      +setOrder(newOrder)
      +setSearchWord(text)
      +setTypeWord(text)
    }
    class TileMessageNotifier {
      +String state
      +build() String
      +setString(text)
    }
    class TileRepository {
      +AppDatabase db
      +createTile(text, chain) Future~int~
      +fetchAllTile() Future~List~TypedResult~~
      +fetchTileDetail(id) Future~EnglishText~
      +deleteTile(id) Future~int~
    }
    class TileListNotifier {
      TileState state
      +build() Future~TileState~
      +addTile() Future~void~
      +deleteTile(id) Future~void~
      +makeTokenChain(id) Future~void~
    }
  }

  VocabEntry --> Based
  TokenData --> VocabEntry
  TranslationState --> TokenData
  TranslationState --> SyncStatus
  LocalBatchRepository ..|> TranslationDBSource
  LocalBatchRepository --> AppDatabase
  TextProcessor --> TranslationDBSource
  TranslationNotifier --> TranslationState: state
  TranslationNotifier ..> TextProcessor: read
  ListRepository --> AppDatabase
  CardData --> VocabEntry
  SortSetting --> SortField
  SortSetting --> SortOrder
  WordListState --> CardData
  WordListState --> SyncStatus
  WordListNotifier --> WordListState: state
  WordListNotifier ..> ListRepository: read
  WordListNotifier ..> SortSettingNotifier: read
  SortSettingNotifier --> SortSetting: state
  TileRepository --> AppDatabase
  TileState --> TileData
  TileListNotifier --> TileState: state
  TileListNotifier ..> TileMessageNotifier: read
  TileListNotifier ..> TileRepository: watch
  TileListNotifier ..> TranslationNotifier: read
```
