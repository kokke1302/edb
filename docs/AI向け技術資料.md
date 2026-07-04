# AI開発資料

## 本資料の位置づけ

本資料は、`edb`（英語学習支援アプリ）のソースコード全文（`all_souses.txt`）・`pubspec.yaml`と組み合わせて使うことを想定した、AIによるコーディング支援用のリファレンスである。

- 本資料は実装（ソースコード）を要約したものであり、**実装内容と本資料が矛盾する場合はソースコードを正とする**。ただし、両者が食い違っている箇所のうち意図的な仕様か実装漏れか未確定なものは「既知の課題・要確認事項」に列挙しているので、そちらを先に確認すること。
- テストの期待値（`all_tests.txt`）は「その処理が本来どう振る舞うべきか」を示す仕様書としても機能する。実装とテストの記述が食い違う場合も同様に「既知の課題・要確認事項」を参照すること。
- 本資料はファイル単位の責務・シグネチャ・テスト内容の把握を目的とし、実装の背景や設計判断の理由（なぜこの設計にしたか）は[開発資料.md](./開発資料.md)、構造の全体像は[アーキテクチャ.md](./アーキテクチャ.md)を参照する。

## 開発規約

コードを追加・変更する際は以下を守ること。

- **依存方向**: `Presentation → Domain ← Data`。Domain層（`entity` / `usecase` / `repository_abstract`）はPresentation・Dataのどちらにも依存しない。
- **Provider定義の場所**: Riverpodの`Provider`/`NotifierProvider`は、対応する`usecase`ファイルまたは`repository_abstract`ファイル内に定義する（`providers.dart`のような集約ファイルは存在しない）。
- **Notifier間の呼び出し制約**（状態の競合回避のため）:
  - 他Notifierのプロパティは、Notifierの`build()`内でしか`watch`できない。
  - Notifierのメソッド内では、他のNotifierのメソッドは1度しか呼び出せない。
- **UseCaseの粒度**: 1 UseCase = 1メソッド（`execute`）が基本。複数のRepositoryを跨ぐ処理はUseCase内でオーケストレーションする（例: `FetchDictionaryDataUseCase`は`DictionaryRepository`の2メソッドを呼び分けて1つの`DictionaryData`に合成する）。
- **Entityの使い分け**: 同じ「単語」でも用途によって型が異なる。新しい処理を書く際は、既存の型（下記「永続化データの定義」「ファイルの責務」参照）を流用できないか先に確認し、安易に新しい型を増やさない。
- **命名の癖**: `Based`（列挙型）、`isShow`/`isHidden`（意味が反転している場所がある）、`nowShow`など、直感的でない命名がそのまま使われている箇所がある。推測でリネームせず、既存の綴り・大小文字をそのまま使うこと。ファイル名にtypoが残っている箇所もある（「既知の課題・要確認事項」参照）。

## 永続化データの定義

### 単語帳テーブル（Vocabularies）

| フィールド名        | 型       | 説明                                                                      |
| :------------------ | :------- | :------------------------------------------------------------------------ |
| id                  | integer  | 主キー、自動インクリメント                                                |
| englishWord         | text     | 英単語（小文字で保存）                                                    |
| japaneseTranslation | text     | 日本語訳                                                                  |
| isHidden            | boolean  | true のとき翻訳に使用しない（ドメイン層では `isShow` として反転して扱う） |
| memo                | text     | ユーザーメモ                                                              |
| createdAt           | dateTime | 登録日時                                                                  |
| updatedAt           | dateTime | 更新日時                                                                  |

> **排他制御**: `isHidden=false`（表示する）で登録・更新する際、`LocalRegisterRepository._setAllOthersHidden`が同じ英単語の他の全エントリを`isHidden=true`に更新する。1単語につき表示対象は常に1件以下になる想定（実装上の懸念点は既知の課題を参照）。

### 内部辞書テーブル（InternalDictionaries）

| フィールド名 | 型      | 説明                           |
| :----------- | :------ | :----------------------------- |
| id           | integer | 主キー                         |
| key          | text    | 検索用キー（小文字のみ）       |
| word         | text    | 英単語（表示用、大小文字混合） |
| mean         | text    | 日本語訳                       |
| memo         | text    | メモ（nullable）               |

読み取り専用。初回起動時にアセット（`assets/output.sqlite3`）からDBファイルごとコピーされる。

### 英文履歴テーブル（EnglishTexts）

| フィールド名      | 型       | 説明                                                 |
| :---------------- | :------- | :--------------------------------------------------- |
| id                | integer  | 主キー、自動インクリメント                           |
| originalText      | text     | 元の英文全体                                         |
| parsedWordsJson   | text     | `TokenData` のリストをJSON形式でシリアライズしたもの |
| createdAt         | dateTime | 保存日時                                             |
| updatedAt         | dateTime | 更新日時                                             |

#### parsedWordsJson の内部構造

`TokenData.toJson()`の配列。`TokenMapper.fromJson`で復元する。

```json
[
  {
    "id": 0,
    "vocabId": 42,
    "showWord": "I",
    "nowShow": true,
    "translation": "私"
  },
  {
    "id": 1,
    "vocabId": -1,
    "showWord": "am",
    "nowShow": false,
    "translation": ""
  }
]
```

| キー          | 型      | 説明                                                                 |
| :------------ | :------ | :-------------------------------------------------------------------- |
| `id`          | int     | トークンリスト内での位置インデックス（0始まりの連番）                |
| `vocabId`     | int     | 対応する単語帳エントリのID。未登録・内部辞書のみの場合は`-1`         |
| `showWord`    | String  | 表示する文字列そのもの（大小文字混合、句読点・空白も含みうる）        |
| `nowShow`     | bool    | 訳語を翻訳画面に表示するかどうか                                     |
| `translation` | String  | 表示する訳語文字列（未設定時は空文字列）                             |

`TokenData.isWord`（getter）は`RegExp(r'\w').hasMatch(showWord)`で単語かどうかを判定する（句読点・空白のみのトークンはfalse）。`TokenData.word`（getter）は`showWord.toLowerCase()`。

## ディレクトリ構造

```
lib/
├── main.dart
├── presentation/
│   ├── view_models/
│   │   ├── book_notifier.dart
│   │   ├── dictionary_notifier.dart
│   │   ├── regidata_receiver.dart
│   │   ├── register_notifier.dart
│   │   ├── selected_token_notifier.dart
│   │   ├── sorting_notifier.dart
│   │   ├── tiles_notifier.dart
│   │   └── translation_notifier.dart
│   ├── pages/
│   │   ├── wordbook/
│   │   │   ├── book_screen.dart
│   │   │   ├── list/
│   │   │   │   ├── book_card.dart
│   │   │   │   ├── book_footer.dart
│   │   │   │   └── initial_error.dart
│   │   │   └── search/
│   │   │       ├── searchbar.dart
│   │   │       ├── sort_dropdown.dart
│   │   │       └── sort_order.dart
│   │   ├── drawer/
│   │   │   ├── drawer.dart
│   │   │   └── tile.dart
│   │   ├── translation/
│   │   │   ├── translation.dart
│   │   │   ├── text_field.dart
│   │   │   ├── block_field.dart
│   │   │   ├── word_block.dart
│   │   │   ├── translate_fab.dart
│   │   │   └── bookmark_fab.dart
│   │   ├── register/
│   │   │   ├── registration_page.dart
│   │   │   ├── regi_english_card.dart
│   │   │   ├── regi_translation_card.dart
│   │   │   ├── regi_memo_card.dart
│   │   │   ├── regi_visual_card.dart
│   │   │   └── regi_footer_bar.dart
│   │   └── dictionary/
│   │       ├── dictionary_sheet.dart
│   │       ├── registered_card.dart
│   │       └── dictionary_card.dart
│   └── root/
│       ├── common_screen.dart
│       ├── bottom_index.dart
│       └── routing.dart
├── domain/
│   ├── entity/
│   │   ├── value/
│   │   │   ├── base_status.dart
│   │   │   ├── sync_status.dart
│   │   │   ├── sort_field.dart
│   │   │   └── sort_order.dart
│   │   ├── model/
│   │   │   ├── book_data.dart
│   │   │   ├── card_data.dart
│   │   │   ├── dictionary_data.dart
│   │   │   ├── sorting_data.dart
│   │   │   ├── tiles_data.dart
│   │   │   ├── token_data.dart
│   │   │   └── translation_data.dart
│   │   └── carry/
│   │       ├── vocab_entry.dart
│   │       ├── tile_data.dart
│   │       └── tile_detail.dart
│   ├── usecase/
│   │   ├── fetch_bookdata_usecase.dart
│   │   ├── fetch_dictionarydata_usecase.dart
│   │   ├── toggle_card_visibiliry_usecase.dart
│   │   ├── process_translation_usecase.dart
│   │   ├── save_register_usecase.dart
│   │   ├── delete_register_usecase.dart
│   │   ├── fetch_tiles_all_usecase.dart
│   │   ├── fetch_tile_detail_usecase.dart
│   │   ├── save_tile_usecase.dart
│   │   └── delete_tile_usecase.dart
│   └── repository_abstract/
│       ├── book_repository.dart
│       ├── processor_repository.dart
│       ├── dictionary_repository.dart
│       ├── register_repository.dart
│       ├── tiles_repository.dart
│       └── translation_repository.dart
└── data/
    ├── repository_impl/
    │   ├── local_book_repository.dart
    │   ├── local_dictionary_repository.dart
    │   ├── local_text_processor.dart
    │   ├── local_register_repository.dart
    │   ├── local_tiles_repository.dart
    │   └── local_translation_repository.dart
    ├── mapper/
    │   ├── vocab_mapper.dart
    │   ├── tile_mapper.dart
    │   └── token_mapper.dart
    └── db/
        ├── app_database.dart
        ├── app_database.g.dart        # Drift自動生成（編集不要）
        ├── database_initializer.dart
        ├── _connection_native.dart
        └── _connection_web.dart

test/
├── usecase_test/    # UseCase層。Repositoryをmocktailでモック化した単体テスト
└── impl_tast/       # RepositoryImpl層。ディレクトリ名にtypoあり（impl_test ではない）
```

## ファイルの責務

### Entity（`domain/entity/`）

#### value/（列挙型）

- `Based { vocabularies, dictionary, init }`: `VocabEntry`の出自。DBの単語帳由来／内部辞書由来／未保存の初期状態、を区別する。
- `SyncStatus { normal, err, load }`: 単語帳リストの下端（ページング）の状態。
- `SortField { createdAt, englishWord }` / `SortOrder { asc, desc }`: 単語帳のソート条件。

#### model/（画面・ユースケース間でやり取りする状態）

- `TokenData`: 翻訳画面のトークン1つ分の状態。フィールドは`id`・`vocabId`・`showWord`・`nowShow`・`translation`。`isWord`・`word`のgetterを持つ。`copyWith`・`toJson`・`fromInit`あり（`fromJson`は本体ではなく`TokenMapper`側にある）。
- `CardData`: 辞書シート・単語帳リストで使う単語カード。`nowShow`（bool）と`vocab`（`VocabEntry`）を持つ。コンストラクタで`nowShow`省略時は`vocab.isShow`を初期値にする。`fromVocabEntry`ファクトリあり。
- `DictionaryData`: 辞書シート全体の状態。`showCard`（現在表示中、nullable）・`vocabularyCards`（単語帳候補）・`dictionaryCards`（内部辞書候補）。
- `TranslationData`: 翻訳画面全体の状態。`originalText`と`tokens`（`List<TokenData>`）。
- `BookData`: 単語帳リスト画面の状態。`pageSize`・`cards`・`tailStatus`（`SyncStatus`）。`isDataEnd`は`cards.length < pageSize`で判定。
- `SortingData`: 検索・ソート条件。`field`・`order`・`searchWord`（確定した検索語）・`typingWord`（入力中の文字列）を分けて保持する。
- `TilesData`: 保存済み英文（Tile）一覧の状態。`list`（`List<TileData>`）のみ。

#### carry/（レイヤーをまたいで受け渡すデータ）

- `VocabEntry`: 単語帳・内部辞書のどちらの単語も表現できる汎用エンティティ。`id`・`word`・`translation`・`isShow`・`memo`・`createdAt`・`updatedAt`・`based`。`VocabEntry.init(word)`で未保存の初期状態を作れる（`based: Based.init`、`isShow: true`）。
- `TileData`: 保存済み英文の一覧表示用。`id`・`text`のみ（軽量、リスト表示用）。
- `TileDetail`: 保存済み英文の詳細復元用。`title`（元の英文）・`chain`（`List<TokenData>`、復元済みトークン列）。

> 旧設計にあった`TokenEntry`（`entity/carry/token_entry.dart`）は現在存在しない。`TranslationRepository.fetchTranslationsBatch`の返り値は`({int id, String word, bool isShow})`という無名レコード型に置き換わっている。

### UseCase（`domain/usecase/`）

#### FetchBookDataUseCase（`fetch_bookdata_usecase.dart`）

- Provider: `bookUseCaseProvider`
- `execute({currentCount, pageSize, sorter})`: `BookRepository.fetchVocabulariesWithPaging`で取得した`VocabEntry`のリストを`CardData`に変換して返す。
- Test（`fetch_bookdata_test.dart`）:
  - 正常系: repositoryが返した`VocabEntry`リストが正しく`CardData`に変換されること／`fetchVocabulariesWithPaging`が期待した引数（offset・limit・sorter）で呼ばれること／空リストが返ったとき空リストを返すこと
  - 異常系: repositoryが例外をスローしたとき、そのまま例外を投げること

#### FetchDictionaryDataUseCase（`fetch_dictionarydata_usecase.dart`）

- Provider: `dictionaryUseCaseProvider`
- `execute(TokenData token)`: `fetchVocabularies`・`fetchDictionaries`を並行して呼び、`token.nowShow`かつ`vocab.id == token.vocabId`のカードを`showCard`として分離し、残りを`vocabularyCards`に振り分ける。`dictionaryCards`はそのまま。
- Test（`fetch_dictionarydata_test.dart`）:
  - 正常系（データ取得・基本検証）: 2つのrepositoryメソッドが期待した引数で呼ばれること
  - 正常系（振り分けロジック: showCardが設定されるケース／されないケース）: `token.nowShow`と`vocabId`の一致条件による振り分けの検証
  - 正常系（dictionaryCards）: 内部辞書由来のカードがそのまま`dictionaryCards`に入ること
  - 正常系（空データ）: 双方が空リストのときの挙動
  - 異常系: いずれかのrepositoryが例外をスローしたときそのまま例外を投げること

#### ToggleCardVisibilityUseCase（`toggle_card_visibility_usecase.dart`）

- Provider: `toggleCardVisibilityUseCaseProvider`
- `execute({required DictionaryData currentData, required CardData targetCard, required TokenData currentToken})`: 辞書シート内でのカード選択・選択解除を処理する。現在の`showCard`をリストに戻し、選択されたカードを`showCard`に昇格。対応する`TokenData`も`vocabId`・`nowShow`・`translation`を選択後の状態に同期して返す（`(DictionaryData, TokenData)`のタプルを返す）。
- Test（`toggle_card_visibility_test.dart`）:
  - 正常系（showCard → vocabularyCards）: 表示中カードを非表示にするケース
  - 正常系（vocabularyCards → showCard、showCardなし）: リストから新規選択するケース
  - 正常系（vocabularyCards → showCard、showCardあり）: 既存のshowCardと入れ替えるケース
  - 正常系（TokenDataのvocabIdとtranslationが正しく同期することの検証）
  - 異常系（対象カードが見つからない場合）

#### ProcessTranslationUseCase（`process_translation_usecase.dart`）

- Provider: `processTranslationUseCaseProvider`
- `execute({required String text, required List<TokenData> currentTokens, required bool isFullScan})`: `text`が空なら即座に空リストを返す。`isFullScan`で`TextProcessor.fullTranslation`（全体翻訳）と`partTranslation`（差分翻訳）を使い分ける。
- Test（`process_translation_test.dart`）:
  - 正常系（早期リターン）: textが空文字のとき空リストを返し、processorのメソッドが呼ばれないこと
  - 正常系（fullTranslation, isFullScan=true）: fullTranslationが適切に呼ばれ、その返り値がそのまま返ること
  - 正常系（partTranslation, isFullScan=false）: partTranslationが適切に呼ばれ、その返り値がそのまま返ること
  - 異常系: processorが例外をスローしたとき、そのまま例外を投げること（fullTranslation・partTranslation両方のケース）

#### SaveRegisterUseCase（`save_register_usecase.dart`）

- Provider: `saveRegisterUseCaseProvider`
- `execute({required CardData card, required TokenData token})`: `card.vocab.based`で新規登録（`addVocabulary`）／更新（`updateVocabulary`）を判定し、結果の`VocabEntry.id`と`card.nowShow`を`token`に反映して返す。
- Test（`save_register_test.dart`）:
  - 正常系（新規登録: basedがvocabularies以外）: addVocabularyが呼ばれ、期待通りのTokenDataが返却されること
  - 正常系（更新: basedがvocabularies）: updateVocabularyが呼ばれ、期待通りのTokenDataが返却されること
  - 異常系: repositoryが例外をスローしたとき、そのまま例外を投げること（新規・更新それぞれ）

#### DeleteRegisterUseCase（`delete_register_usecase.dart`）

- Provider: `deleteRegisterUseCaseProvider`
- `execute({required CardData card, required TokenData token})`: `deleteVocabulary`実行後、`token`を`vocabId: -1`・`nowShow: false`にリセットして返す。
- Test（`delete_register_test.dart`）:
  - 正常系: 削除が正常に行われ、期待通りのTokenDataが返却されること
  - 異常系: repositoryが例外をスローしたとき、そのまま例外を投げること

#### SaveTileUseCase（`save_tile_usecase.dart`）

- Provider: `saveTileUseCaseProvider`
- `execute({required String originalText, required List<TokenData> tokens})`: `tokens`を`toJson`してJSON文字列化し、`TilesRepository.createTile`で保存。生成された`id`で`TileData`を返す。
- Test（`save_tile_test.dart`）:
  - 正常系: createTileが正しい引数（originalText・エンコード済みchain）で1回呼ばれ、期待通りのTileDataが返却されること
  - 異常系: repositoryが例外をスローしたとき、そのまま例外を投げること

#### FetchAllTilesUseCase（`fetch_tiles_all_usecase.dart`）

- Provider: `fetchAllTilesUseCaseProvider`
- `execute()`: `TilesRepository.fetchAllTiles`をそのまま返す薄いラッパー。
- Test（`fetch_tiles_all_test.dart`）:
  - 正常系: fetchAllTilesが1回呼ばれ、取得したTileDataのリストがそのまま返ること／空リストが返ったとき空リストを返すこと
  - 異常系: repositoryが例外をスローしたとき、そのまま例外を投げること

#### FetchTileDetailUseCase（`fetch_tile_detail_usecase.dart`）

- Provider: `fetchTileDetailUseCaseProvider`
- `execute({required int id})`: `TilesRepository.fetchTileDetail`をそのまま返す薄いラッパー。
- Test（`fetch_tile_detail_test.dart`）:
  - 正常系: 指定したidでfetchTileDetailが呼ばれ、期待通りのTileDetailが返ること
  - 異常系: repositoryが例外をスローしたとき、そのまま例外を投げること

#### DeleteTileUseCase（`delete_tile_usecase.dart`）

- Provider: `deleteTileUseCaseProvider`
- `execute({required int id})`: `TilesRepository.deleteTile`をそのまま呼ぶ薄いラッパー。戻り値なし。
- Test（`delete_tile_test.dart`）:
  - 正常系: deleteTileが指定したidを引数に1回呼ばれ、正常終了すること
  - 異常系: repositoryが例外をスローしたとき、そのまま例外を投げること

### RepositoryAbstract（`domain/repository_abstract/`）

| ファイル | インターフェース | 主なメソッド |
| :--- | :--- | :--- |
| `book_repository.dart` | `BookRepository` | `fetchVocabulariesWithPaging({offset, limit, sorter})` |
| `processor_repository.dart` | `TextProcessor` | `partTranslation({nowTokens, newText})` / `fullTranslation({text})` |
| `dictionary_repository.dart` | `DictionaryRepository` | `fetchVocabularies({word})` / `fetchDictionaries({word})` |
| `register_repository.dart` | `RegisterRepository` | `addVocabulary({vocab})` / `updateVocabulary({vocab})` / `deleteVocabulary({id})` |
| `translation_repository.dart` | `TranslationRepository` | `fetchTranslationsBatch(Set<String> keys)` → `List<({int id, String word, bool isShow})>` |
| `tiles_repository.dart` | `TilesRepository` | `createTile({text, chain})` / `fetchAllTiles()` / `fetchTileDetail({id})` / `deleteTile({id})` |

各ファイルにRiverpod Providerも同居している（例: `bookRepositoryProvider`は`LocalBookRepository(db)`を返す）。

> `TranslationRepository`はDBに問い合わせて訳語候補を返すだけの薄い層で、トークン化・差分検出などのロジックは持たない。そのロジックは`TextProcessor`（`processor_repository.dart`）側にあり、実装である`LocalTextProcessor`は内部で`TranslationRepository`に依存する構成になっている。

### RepositoryImpl（`data/repository_impl/`）

#### LocalBookRepository（`local_book_repository.dart`）

- `fetchVocabulariesWithPaging({offset, limit, sorter})`: `sorter.searchWord`が空でなければ`englishWord`・`japaneseTranslation`・`memo`への`LIKE`検索を適用。`sorter.field`・`sorter.order`に応じて`ORDER BY`を組み立て、`limit`/`offset`でページングして`VocabEntry`のリストを返す。
- Test（`local_book_test.dart`、`fetchVocabulariesWithPaging`）:
  - 正常系（基本取得）: DBが空のとき空リスト／件数一致／内容一致
  - 境界値（フィルタリング: searchWord）: 空文字で全件、englishWord/japaneseTranslation/memoそれぞれへの部分一致、いずれにも一致しない場合の空リスト
  - 境界値（ソート）: `SortField.englishWord`・`SortField.createdAt` × `asc`・`desc`の4パターン
  - 境界値（ページング）: offset=0、offset=limit（次ページ）、offsetが総件数以上（空リスト）、limitより行数が少ない場合

#### LocalDictionaryRepository（`local_dictionary_repository.dart`）

- `fetchVocabularies({word})`: `englishWord`（小文字化・完全一致）で単語帳を検索し`VocabEntry`（`based: Based.vocabularies`、`isShow = !isHidden`）に変換して返す。
- `fetchDictionaries({word})`: `key`（小文字化・完全一致）で内部辞書を検索し`VocabEntry`（`based: Based.dictionary`、`id: -1`、`isShow: true`）に変換して返す。`memo`がnullの場合は空文字にする。
- Test（`local_dictionary_test.dart`）:
  - `fetchVocabularies`正常系: 一致する行だけ返る／based=vocabularies／isHidden=trueならisShow=false／複数一致で全件／不一致で空リスト。境界値: 大文字混じりでも一致。
  - `fetchDictionaries`正常系: 一致する行だけ返る／word・translationがDBと一致／based=dictionary／id=-1／memoがnullなら空文字／複数一致で全件／不一致で空リスト。境界値: 大文字混じりでも一致。

#### LocalTextProcessor（`local_text_processor.dart`）

- `_tokenizeText(String text)`: 正規表現 `(\w+-\w+|\w+'\w+|\w+|[^\w\s]+|\s+)` で分割し、空白のみのトークンを除いて`TokenData.fromInit`の初期リストを作る。
- `fullTranslation({required String text})`: トークン化 → 単語トークンの`showWord.toLowerCase()`を集約 → `TranslationRepository.fetchTranslationsBatch`で一括取得 → 同一キーに複数件ある場合は`isShow: true`を優先してMap化 → 各トークンの`id`・`vocabId`・`nowShow`を反映して返す。
- `partTranslation({required List<TokenData> nowTokens, required String newText})`: 新旧トークン列の`showWord`を`diffutil_dart`（`calculateListDiff`）で比較し、挿入・削除・変更を反映した新トークン列を作る → 影響を受けたインデックスのみ`fetchTranslationsBatch`で再検索し反映 → 変更のなかったトークンはそのまま維持。
- Test（`local_text_processer_test.dart`、ファイル名typo注意）:
  - `fullTranslation` 正常系（トークン化）: 通常の単語／ハイフン語／アポストロフィ語がそれぞれ1トークンになること、句読点が独立トークンになること、空白のみのトークンが無視されること
  - `fullTranslation` 正常系（翻訳マッピング）: DB登録済み単語の反映、未登録単語・句読点トークンが初期値のままになること、idが0始まり連番になること
  - `fullTranslation` 境界値: 大文字・小文字混在時の反映、重複語があってもfetchTranslationsBatchへ渡すキーが重複しないこと
  - `partTranslation` 正常系（差分なし）: 既存トークンがそのまま返ること、fetchTranslationsBatchが空Setで呼ばれること
  - `partTranslation` 正常系（追加）: 末尾に単語が追加されたときの挿入、追加分への翻訳反映、既存トークンが変わらないこと
  - `partTranslation` 正常系（削除）: 末尾の単語が削除されたときの除去
  - `partTranslation` 正常系（変更）: 既存トークンが別の単語に変わったときの再翻訳、変更されていないトークンが変わらないこと
  - `partTranslation` 正常系（ID整合性）: 差分適用後の全トークンのidが0始まり連番になること
  - `partTranslation` 異常系: fetchTranslationsBatchが例外を投げたとき、そのまま投げること

  > `fullTranslation`/`partTranslation`のテストタイトルには「vocabId / translation / nowShow が反映されること」という記述があるが、実際のアサーションは`translation`を検証していない（「既知の課題・要確認事項」1番を参照）。

#### LocalRegisterRepository（`local_register_repository.dart`）

- `_setAllOthersHidden({required String word})`: 同じ`englishWord`（小文字比較）を持つ全行の`isHidden`をtrueに更新する排他制御用の内部メソッド。
- `addVocabulary({required VocabEntry vocab})`: `vocab.isShow`なら`_setAllOthersHidden`を呼んでから新規`insert`し、挿入結果を`VocabEntry`に変換して返す。
- `updateVocabulary({required VocabEntry vocab})`: `vocab.isShow`なら`_setAllOthersHidden`をawaitしてから`vocab.id`該当行を`update`し、更新結果を`VocabEntry`に変換して返す。
- `deleteVocabulary({required int id})`: `id`該当行を削除する。
- Test（`local_register_test.dart`）:
  - `addVocabulary` 正常系: 排他制御（他エントリのisHiddenがtrueになること）、idが自動採番の正の整数になること、挿入後にDBに該当行が存在すること。境界値: `vocab.isShow`がfalseのとき既存エントリのisHiddenが変更されないこと。
  - `updateVocabulary` 正常系: word/translation/memo/isHiddenが更新内容と一致すること、更新後にDBの該当行が新しい内容になっていること。境界値: `vocab.isShow`がfalseのとき既存エントリのisHiddenが変更されないこと。
  - `deleteVocabulary` 正常系: 削除後に同じidで取得しても該当行が存在しないこと。境界値: 存在しないidを指定しても例外が投げられないこと。

  > `addVocabulary`冒頭の`if (vocab.based == Based.vocabularies) updateVocabulary(...)`、`updateVocabulary`冒頭の`if (vocab.based != Based.vocabularies) addVocabulary(...)`は、いずれもawait/returnされていない。また`addVocabulary`の`_setAllOthersHidden`呼び出しも未awaitである（「既知の課題・要確認事項」2番を参照）。

#### LocalTilesRepository（`local_tiles_repository.dart`）

- `createTile({required String text, required String chain})`: `EnglishTexts`に`originalText`・`parsedWordsJson`を挿入し、生成idを返す。
- `fetchAllTiles()`: `id`・`originalText`のみを射影して`TileData`のリストを返す（軽量化のため`parsedWordsJson`は取得しない）。
- `fetchTileDetail({required int id})`: 該当行を全カラム取得し`TileMapper.toTileDetail`で`TileDetail`に変換する。
- `deleteTile({required int id})`: 該当行を削除し、削除件数を返す。
- Test（`local_tiles_test.dart`）:
  - `createTile`: 返り値が正の整数のIDになること、挿入後にDBに該当行が存在すること、originalText/parsedWordsJsonが引数と一致すること
  - `fetchAllTiles`: DBが空のとき空リスト、件数一致、各TileDataのid/textがDBと一致すること
  - `fetchTileDetail`: 指定したIDの行の内容が返ること、存在しないIDのとき例外が投げられること
  - `deleteTile`: 削除後に同じIDの行が存在しないこと、返り値が1（削除件数）になること、存在しないIDのとき返り値が0になること（例外が投げられないこと）

#### LocalTranslationRepository（`local_translation_repository.dart`）

- `fetchTranslationsBatch(Set<String> keys)`: `keys`に一致する`englishWord`（小文字比較）を持つ単語帳の行のうち`isHidden=false`のものだけを`({id, word, isShow})`のリストにして返す。訳語テキスト自体は返り値に含まれない。
- Test（`local_translation_test.dart`）:
  - 正常系: lookupKeysに一致するenglishWordの行のみ返ること、id/wordがDBの該当行と一致すること、isHiddenがtrueの行は含まれないこと、isHiddenがfalseの行のisShowがtrueにマッピングされること、複数キーを渡したとき一致する全行が返ること、一致行がないとき空リストが返ること
  - 境界値: lookupKeysが空Setのとき、DBを参照せず空リストが返ること／文字列が大文字混じりでも小文字登録済みの行が一致すること／含まれないキーを持つ行が返り値に混ざらないこと

### Mapper（`data/mapper/`）

- `VocabMapper.fromVocabularies({vocabulary})`: Drift行 → `VocabEntry`（`based: Based.vocabularies`、`isShow: !isHidden`）
- `VocabMapper.fromDictionary({dictionary})`: Drift行 → `VocabEntry`（`based: Based.dictionary`、`id: -1`、`isShow: true`、`memo`はnull安全に空文字化）
- `TileMapper.toTileData({id, text})`: 一覧表示用の軽量変換
- `TileMapper.toTileDetail({et})`: `EnglishText`行の`parsedWordsJson`をデコードし`TokenMapper.fromJson`で`List<TokenData>`に変換、`TileDetail`を返す
- `TokenMapper.fromJson(json)`: JSON Map → `TokenData`（`TokenData`本体に`fromJson`はなく、この専用Mapperを経由する）

### ViewModel（`presentation/view_models/`）

- `BookNotifier`（`bookProvider`, `AsyncNotifier<BookData>`）: `sortingProvider`の`searchWord`/`field`/`order`を`build()`内で監視し初期ページを取得。`loadNextPage()`で追加ロード（`tailStatus`で二重呼び出しをガード）、`reload()`でPull-to-Refresh（`invalidateSelf`）。
- `SortingNotifier`（`sortingProvider`, `Notifier<SortingData>`）: `setField`・`setOrder`・`setSearchWord`（確定検索語）・`setTypeWord`（入力中文字列）。
- `RegisterNotifier`（`registerProvider`, `AsyncNotifier<CardData>`）: `regiDataReceiver`から初期値を受け取る。`updateEnglish`/`updateTranslation`/`updateMemo`/`toggleIsShowing`で入力を更新。`save()`は入力（word・translation）が空なら早期リターンし、`SaveRegisterUseCase`実行後に`TranslationNotifier.updateToken`・`BookNotifier.reload`・`regiDataReceiver`初期化をオーケストレーションする。`delete()`は`based != Based.vocabularies`なら早期リターン。
- `TranslationNotifier`（`translationProvider`）: 翻訳画面の状態（`TranslationData`）管理。入力変更時は差分翻訳、手動ボタンでは全体翻訳を`ProcessTranslationUseCase`経由で実行。`updateToken`で単一トークンの更新を反映。`restore(text, chain)`でTileから復元。
- `SelectedTokenNotifier`（`selectedTokenProvider`）: 辞書シートを開いた対象トークンの一時保持。
- `RegidataReceiver`（`regiDataReceiver`）: 登録画面への遷移時に受け渡す初期`CardData`の保持・初期化（`initialCard()`）。
- `DictionaryNotifier`（`dictionaryProvider`）: 辞書シートの状態（`DictionaryData`）。`toggleVisibility(card)`で`ToggleCardVisibilityUseCase`を実行し、結果を自身のstateに反映しつつ`TranslationNotifier.updateToken`を呼んでトークン側にも反映する。
- `TilesNotifier`（`tilesProvider`, `AsyncNotifier<TilesData>`）: 保存済み英文一覧。`addTile()`は現在の`translationProvider`の値をバリデーションしてから`SaveTileUseCase`実行、`deleteTile({id})`はリストから該当idを除外、`makeTokenChain({id})`は`FetchTileDetailUseCase`の結果を`TranslationNotifier.restore`に渡して翻訳画面へ復元する。

### Pages（`presentation/pages/`）

#### wordbook/

- `MyBookScreen`（`book_screen.dart`）: `SliverAppBar`に`MySearchBar`・`MySortDropdownMenu`・`MySortOrderButton`を内包。`SliverList`で`MyBookCard`を表示。`useEffect`＋スクロール監視＋Throttleで無限スクロール（`BookNotifier.loadNextPage`）。右下FABから`EntryScreen`（新規登録）へ遷移。
- `list/book_card.dart`（`MyBookCard`）・`book_footer.dart`・`initial_error.dart`: リスト末尾の状態表示・初期エラー表示。
- `search/searchbar.dart`（`MySearchBar`）・`sort_dropdown.dart`（`MySortDropdownMenu`）・`sort_order.dart`（`MySortOrderButton`）: 検索・ソートUI。`SortingNotifier`を操作する。

#### drawer/

- `MyDrawer`（`drawer.dart`）: 保存済み英文一覧（`MyTile`）、設定・ヘルプへの導線を持つサイドメニュー。
- `MyTile`（`tile.dart`）: 個々の保存済み英文の行。タップで`TilesNotifier.makeTokenChain`を呼び翻訳画面へ復元。

#### translation/

- `translation.dart`（`TranslationModePage`）: `MyTextField`・`MyTranslateFab`・`MyBookmarkFab`・`MyBlockField`を縦に並べる。
- `text_field.dart`（`MyTextField`）: 複数行英文入力欄。入力の都度`updateOriginalText`を呼び差分翻訳をスロットリング付きでトリガー。
- `block_field.dart`（`MyBlockField`）: `Wrap`で`WordBlock`を並べ、ピリオド直後に改行を挿入。
- `word_block.dart`（`WordBlock`）: 英単語（上段）と訳語（下段。`nowShow`がfalseなら`-`、trueなら`token.translation`をそのまま表示）。タップで`VocabularyInputSheet`をモーダル表示。
- `translate_fab.dart`（`MyTranslateFab`）・`bookmark_fab.dart`（`MyBookmarkFab`）: 手動全体翻訳ボタン・現在の翻訳状態を英文履歴として保存するボタン（`TilesNotifier.addTile`）。

#### register/

- `registration_page.dart`（`EntryScreen`）: `EnglishCard`・`TranslationCard`・`MemoCard`・`VisibilitySwitchCard`・`FooterBar`をまとめる。`My`プレフィックスなし。
- `regi_english_card.dart`（`EnglishCard`）・`regi_translation_card.dart`（`TranslationCard`）・`regi_memo_card.dart`（`MemoCard`）: それぞれ英単語・訳語・メモの入力欄。`RegisterNotifier`の`updateEnglish`/`updateTranslation`/`updateMemo`を呼ぶ。
- `regi_visual_card.dart`（`VisibilitySwitchCard`）: 表示/非表示切り替えアイコン。`isShow`の現在値に応じて表示するアイコンを切り替え、タップで`toggleIsShowing`を反転した値で呼ぶ。
- `regi_footer_bar.dart`（`FooterBar`）: 保存・キャンセル・削除ボタン。削除ボタンは既存エントリ編集時（`based == Based.vocabularies`）のみ表示。

#### dictionary/

- `dictionary_sheet.dart`（`VocabularyInputSheet`）: 選択中トークンの英単語を見出しに、`showCard`・`vocabularyCards`（`RegisteredCared`）・`dictionaryCards`（`DictionaryCard`）を順に並べる。末尾の「オリジナル訳語を登録」から登録画面へ遷移。
- `registered_card.dart`（`RegisteredCared`、クラス名typo）: 単語帳由来のカード。目のアイコンで`DictionaryNotifier.toggleVisibility`、本のアイコンで登録画面へ編集遷移。
- `dictionary_card.dart`（`DictionaryCard`）: 内部辞書由来のカード。本のアイコンで登録画面へ新規登録として遷移するのみ（表示切り替え不可）。

### root（`presentation/root/`）

- `routing.dart`（`EnglishLearningApp`）: GoRouterのルート定義。`ShellRoute`でボトムナビ画面（`/translate`・`/words`）を共通化し、`/registration`・`/setting`・`/help`は独立ルート。`SettingPage`・`HelpPage`は本ファイル内に簡易実装されている。
- `bottom_index.dart`（`bottomNavIndexProvider`）: ボトムナビの選択インデックス管理。旧`bottom_index_notifier.dart`（`presentation/view_models/`）から移動・改名されたもの。
- `common_screen.dart`（`CommonScreen`）: `bottomNavIndexProvider`を監視し、AppBarタイトル切り替え・`MyDrawer`表示・`BottomNavigationBar`によるページ遷移を担う共通Scaffold。

### DB・main（`data/db/`, `main.dart`）

- `app_database.dart` / `app_database.g.dart`: Drift定義本体（`Vocabularies`・`InternalDictionaries`・`EnglishTexts`の3テーブル）と自動生成コード。`app_database.g.dart`は編集不要。
- `database_initializer.dart`: `ensureDictionaryCopied()`でアプリ初回起動時にアセット（`assets/output.sqlite3`）からDBファイル全体（`db.sqlite`）をアプリストレージにコピーする（Web環境はスキップ）。`insertManualVocabularies()`は初期データを手動投入する関数だが、現状`initialData`リストは空（no-op）。
- `_connection_native.dart` / `_connection_web.dart`: プラットフォームごとのDrift接続実装（条件付きインポートで切り替え）。
- `main.dart`: アプリのエントリポイント。DB初期化を待ってから`ProviderScope`配下で`EnglishLearningApp`を起動する。

## 既知の課題・要確認事項

本セクションは、実装（all_souses.txt）とテスト（all_tests.txt）を突き合わせて見つかった、
仕様意図と実装が食い違っている可能性のある箇所をまとめたもの。
コード修正を行う際は、まずここに該当しないか確認すること。

### 1. 自動翻訳時にtranslation（訳語テキスト）が反映されない疑い

- 該当箇所: `LocalTextProcessor.fullTranslation` / `partTranslation`
  （`lib/data/repository_impl/local_text_processor.dart`）
- 内容:
  `TranslationRepository.fetchTranslationsBatch` の返り値は
  `({int id, String word, bool isShow})` というレコード型で、
  日本語訳のテキスト自体を含んでいない。
  `fullTranslation`/`partTranslation` 内の `token.copyWith(...)` は
  `id` / `vocabId` / `nowShow` のみを更新しており、`translation` フィールドは
  常に初期値（空文字列）のまま返される。
- 影響:
  英文入力時の自動翻訳（差分翻訳・全体翻訳）で `nowShow: true` になった単語は、
  訳語欄に空文字が表示される可能性が高い（`WordBlock` は `nowShow` が true なら
  `token.translation` をそのまま表示するため）。
  辞書シートから手動でカードを選択した場合（`ToggleCardVisibilityUseCase`）は
  `translation: target.vocab.translation` が明示的に設定されるため問題ない。
  つまり「バグが起きるルート」と「起きないルート」が両方存在する状態。
- テストとの矛盾:
  `local_text_processer_test.dart` の該当テストのタイトルは
  「DB に登録済みの単語に vocabId / translation / nowShow が反映されること」だが、
  実際のアサーションは `vocabId` と `nowShow` のみを検証しており、`translation` の
  検証が存在しない。テストのタイトルと実装、双方が同じ抜け漏れを持っている可能性が高い。
- 要確認: 意図した仕様か、実装漏れか。意図通りなら「なぜ手動選択時だけ訳語が出るのか」を
  ドキュメント化する必要がある。

### 2. LocalRegisterRepositoryの排他制御・分岐にawait漏れの疑い

- 該当箇所: `LocalRegisterRepository.addVocabulary` / `updateVocabulary`
  （`lib/data/repository_impl/local_register_repository.dart`）
- 内容（2点）:
  1. `addVocabulary` 冒頭の `if (vocab.based == Based.vocabularies) updateVocabulary(vocab: vocab);`
     と、`updateVocabulary` 冒頭の `if (vocab.based != Based.vocabularies) addVocabulary(vocab: vocab);`
     は、いずれも `await` されておらず `return` もされていない。呼び出し後もそのまま
     自分自身の本処理（insert/update）に処理が進む。
  2. `addVocabulary` 内の排他制御 `if (vocab.isShow) _setAllOthersHidden(word: vocab.word);` は
     `await` されていない（`updateVocabulary` 側は `await` されている）。
- 影響:
  現状の呼び出し元（`SaveRegisterUseCase`）は `based` を事前に判定してから
  `addVocabulary`/`updateVocabulary` のどちらか一方だけを呼んでいるため、1点目の分岐は
  実質デッドコードで今は問題を起こしていない。ただし今後別のusecaseやAIによる修正で
  直接呼び出し方が変わった場合、二重書き込みや不整合な例外が起きるリスクがある。
  2点目は、`isHidden` の一括更新が完了する前にinsertが確定する可能性があり、
  同一単語に対して一時的に複数の `isShow: true` エントリが存在しうる。

### 3. ファイル名・クラス名のtypoと命名規則の不統一（AIによる誤参照防止）

- `toggle_card_visibiliry_usecase.dart`（ファイル名のみtypo。クラス名は `ToggleCardVisibilityUseCase` で正しい）
- `test/impl_tast/`（ディレクトリ名typo。`impl_test` ではない）
- `local_text_processer_test.dart`（`processor` ではなく `processer`）
- 登録画面・辞書シート関連のクラスは `My` プレフィックスが付いていない
  （`EntryScreen` / `EnglishCard` / `TranslationCard` / `MemoCard` /
  `VisibilitySwitchCard` / `FooterBar` / `VocabularyInputSheet` / `DictionaryCard`）。
  一方で翻訳・単語帳・drawer関連は `My` プレフィックスが付いたまま
  （`MyTextField` / `MyBlockField` / `MyTranslateFab` / `MyBookmarkFab` /
  `MyBookScreen` / `MyBookCard` / `MyDrawer` / `MyTile`）。
- `RegisteredCared`（`registered_card.dart`）はクラス名自体がtypo
  （`Card` ではなく `Cared`）。

### 4. 旧設計からの構造的な置き換え（ファイル参照時に注意）

- `TokenChainRepository`（`token_chain_repository.dart`）は存在しない。
  `ProcessorRepository`（`processor_repository.dart`の`TextProcessor`）と
  `LocalTextProcessor`（`local_text_processor.dart`）に置き換わっている。
- `entity/carry/token_entry.dart`（`TokenEntry`）は存在しない。
  `({int id, String word, bool isShow})` という無名レコード型に置き換わっている。
- `bottom_index_notifier.dart` は `presentation/view_models/` ではなく
  `presentation/root/bottom_index.dart` にある。
- `database_initializer.dart` の `ensureDictionaryCopied` は、内部辞書テーブルだけでなく
  アプリのDBファイル全体（`assets/output.sqlite3` → `db.sqlite`）を事前パッケージからコピーする
  実装になっている。`insertManualVocabularies` の初期データリストは現状空。
