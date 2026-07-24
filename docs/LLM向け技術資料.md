# AI開発資料

## 本資料の位置づけ

本資料は、`edb`（英語学習支援アプリ）のソースコード全文（`all_souses.txt`）・`pubspec.yaml`と組み合わせて使うことを想定した、AIによるコーディング支援用のリファレンスである。

- 実装内容と本資料が矛盾する場合、本資料を正とする。
- テストコードの指示については、テストコード全文（`all_tests.txt`）のヘッダー部を参照せよ。そこは、期待値（その処理が本来どう振る舞うべきか）を示す仕様書として機能する。
- 本資料はファイル単位の責務・シグネチャ・テスト内容の把握を目的とし、実装の背景や設計判断の理由（なぜこの設計にしたか）は[開発記.md](./開発記.md)、構造の全体像は[人間向け技術資料.md](./人間向け技術資料.md#アーキテクチャの概要)を参照せよ。

## 開発規約

コードを追加・変更する際は以下を守ること。

- **依存方向**: `Presentation → Domain ← Data`。Domain層（`entity` / `usecase` / `repository_abstract`）はPresentation・Dataのどちらにも依存しない。
- **Provider定義の場所**: Riverpodの`Provider`は、対応する`usecase`ファイルや`repository_abstract`ファイル内に直接定義する（`providers.dart`のような集約ファイルは存在しない）。
- **Notifier間の呼び出し制約**（状態の競合回避のため）:
  - 他Notifierのプロパティは、Notifierの`build()`内でしか`watch`できない。
  - Notifierのメソッド内では、他のNotifierのメソッドは1度しか呼び出せない。
- **UseCaseの粒度**: 1 UseCase = 1メソッド（`execute`）が基本。複数のRepositoryを跨ぐ処理はUseCase内でオーケストレーションする。
- **Entityの使い分け**: 同じ「単語」でも用途によって型が異なる。新しい処理を書く際は、既存の型（下記「永続化データの定義」「ファイルの責務」参照）を流用できないか先に確認し、安易に新しい型を増やさない。

## ディレクトリ構造

lib/main.dart                                                   # アプリのエントリーポイント。初期データ投入・初期化処理を担う。

### Presentation Layer (View Models & Routing)

lib/presentation/view_models/book_notifier.dart                 # BookNotifier, bookProvider (単語帳の無限スクロール・リスト状態管理)
lib/presentation/view_models/dictionary_notifier.dart           # DictionaryNotifier, dictionaryProvider (辞書シートの候補表示・表示切替)
lib/presentation/view_models/bottom_index_notifier.dart         # BottomNavIndexNotifier, bottomNavIndexProvider (ボトムナビのインデックス管理)
lib/presentation/view_models/regidata_receiver.dart             # RegiDataReceiver, regiDataReceiver (単語登録画面の初期値受け渡し中継)
lib/presentation/view_models/register_notifier.dart             # RegisterNotifier, registerProvider (単語登録・編集の入力状態管理、保存・削除)
lib/presentation/view_models/selected_token_notifier.dart       # SelectedTokenNotifier, selectedTokenProvider (辞書シートで選択中のトークン管理)
lib/presentation/view_models/sorting_notifier.dart              # SortingNotifier, sortingProvider (単語帳のソート条件・検索文字列管理)
lib/presentation/view_models/tiles_notifier.dart                # TilesNotifier, tilesProvider (保存済み英文履歴の管理・復元トリガー)
lib/presentation/view_models/translation_notifier.dart          # TranslationNotifier, translationProvider, tokenProvider (翻訳画面の入力文・トークン群管理)
lib/presentation/root/common_screen.dart                        # CommonScreen (ボトムナビゲーションバー付きの共通Scaffold)
lib/presentation/root/bottom_index.dart                         # （ボトムナビゲーション関連のコンポーネント・レイアウト）
lib/presentation/root/routing.dart                              # EnglishLearningApp, SettingPage, HelpPage (GoRouterによるルーティング定義)

### Presentation Layer (Pages & UI Components)

lib/presentation/pages/wordbook/book_screen.dart                # MyBookScreen (単語帳画面のルート。検索、ソート、リストの統合)
lib/presentation/pages/wordbook/list/book_card.dart             # MyBookCard (単語帳リストの1件分のカードUI)
lib/presentation/pages/wordbook/list/book_footer.dart           # MyBookFooter (リスト下部のロード中・エラー・終端状態の出し分け)
lib/presentation/pages/wordbook/list/initial_error.dart         # MyInitialError (単語帳の初回ロード失敗時のエラー表示とリトライ導線)
lib/presentation/pages/wordbook/search/searchbar.dart           # MySearchBar (検索キーワード入力バー。入力中と確定状態の分離管理)
lib/presentation/pages/wordbook/search/sort_dropdown.dart       # MySortDropdownMenu (ソート項目（作成日時/英単語）の選択ドロップダウン)
lib/presentation/pages/wordbook/search/sort_order.dart          # MySortOrderButton (ソート順序（昇順/降順）の切り替えトグルボタン)
lib/presentation/pages/drawer/drawer.dart                       # MyDrawer (アプリ共通のドロワー。保存済み英文履歴や設定への導線)
lib/presentation/pages/drawer/tile.dart                         # MyTile (Drawer内の保存済み英文1件分のListTile。復元・削除)
lib/presentation/pages/translation/translation.dart             # TranslationModePage (翻訳モード画面の全体レイアウト専用Widget)
lib/presentation/pages/translation/text_field.dart              # MyTextField (翻訳モードの英文入力フィールド。双方向同期対応)
lib/presentation/pages/translation/block_field.dart             # MyBlockField (トークン列をWrapで表示するエリア。ピリオド改行ロジック)
lib/presentation/pages/translation/word_block.dart              # WordBlock (トークン1件分の表示ブロック（英単語＋訳語）)
lib/presentation/pages/translation/translate_fab.dart           # MyTranslateFab (再翻訳を実行するボタン。処理中の制御)
lib/presentation/pages/translation/bookmark_fab.dart            # MyBookmarkFab (現在の翻訳結果を英文履歴として保存するボタン)
lib/presentation/pages/register/registration_page.dart          # MyEntryScreen (単語登録・編集画面のルート・レイアウト)
lib/presentation/pages/register/regi_english_card.dart          # MyEnglishCard (英単語の表示/編集フィールド。既存変更時の確認挟み)
lib/presentation/pages/register/regi_translation_card.dart      # MyTranslationCard (日本語訳入力フィールド（必須項目）)
lib/presentation/pages/register/regi_memo_card.dart             # MyMemoCard (ユーザーメモ入力フィールド)
lib/presentation/pages/register/regi_visual_card.dart           # MyVisibilitySwitchCard (訳の表示可否（isShow）を切り替えるスイッチ)
lib/presentation/pages/register/regi_footer_bar.dart            # MyFooterBar (登録・編集画面下部の操作バー（削除・キャンセル・保存）)
lib/presentation/pages/dictionary/dictionary_sheet.dart         # MyDictionarySheet (辞書機能シート本体。候補一覧や新規登録導線)
lib/presentation/pages/dictionary/registered_card.dart          # MyRegisteredCard (単語帳由来の候補カード。表示切替や編集導線)
lib/presentation/pages/dictionary/dictionary_card.dart          # MyDictionaryCard (内部辞書由来の候補カード。単語帳への登録導線)

### Domain Layer (UseCases)

lib/domain/usecase/process_translation_usecase.dart             # ProcessTranslationUseCase, processTranslationUseCaseProvider (英文解析)
lib/domain/usecase/fetch_tiles_all_usecase.dart                 # FetchAllTilesUseCase, fetchAllTilesUseCaseProvider (英文履歴一覧取得)
lib/domain/usecase/fetch_bookdata_usecase.dart                  # FetchBookDataUseCase, fetchBookDataUseCaseProvider (単語帳ページング取得)
lib/domain/usecase/fetch_tile_detail_usecase.dart               # FetchTileDetailUseCase, fetchTileDetailUseCaseProvider (指定IDの英文復元用データ取得)
lib/domain/usecase/fetch_dictionarydata_usecase.dart            # FetchDictionaryDataUseCase, fetchDictionaryDataUseCaseProvider (辞書候補取得)
lib/domain/usecase/save_tile_usecase.dart                       # SaveTileUseCase, saveTileUseCaseProvider (翻訳状態の英文履歴保存)
lib/domain/usecase/delete_register_usecase.dart                 # DeleteRegisterUseCase, deleteRegisterUseCaseProvider (単語帳エントリ削除)
lib/domain/usecase/delete_tile_usecase.dart                     # DeleteTileUseCase, deleteTileUseCaseProvider (指定IDの英文履歴削除)
lib/domain/usecase/save_register_usecase.dart                   # SaveRegisterUseCase, saveRegisterUseCaseProvider (単語帳エントリの新規追加・更新)
lib/domain/usecase/toggle_card_visibiliry_usecase.dart          # ToggleCardVisibilityUseCase, toggleCardVisibilityUseCaseProvider (候補表示切替)

### Domain Layer (Repository Interfaces)

lib/domain/repository_abstract/book_repository.dart             # BookRepository, bookRepositoryProvider (単語帳テーブル検索・ページング定義)
lib/domain/repository_abstract/processor_repository.dart        # TextProcessor, textProcessorProvider (英文解析ロジック定義)
lib/domain/repository_abstract/dictionary_repository.dart       # DictionaryRepository, dictionaryRepositoryProvider (単語帳・内部辞書検索定義)
lib/domain/repository_abstract/register_repository.dart         # RegisterRepository, registerRepositoryProvider (単語帳テーブルへのCUD操作定義)
lib/domain/repository_abstract/translation_repository.dart      # TranslationRepository, translationRepositoryProvider (翻訳用エントリ一括取得定義)
lib/domain/repository_abstract/tiles_repository.dart            # TilesRepository, tilesRepositoryProvider (英文履歴テーブルのCRUD操作定義)

### Domain Layer (Entities & DTOs)

lib/domain/entity/value/base_status.dart                        # Based (enum: 出典元（単語帳/内部辞書/初期値）を定義)
lib/domain/entity/value/sync_status.dart                        # SyncStatus (enum: リスト下部の同期状態（通常/ロード中/エラー）を定義)
lib/domain/entity/value/sort_field.dart                         # SortField (enum: ソート対象カラム（作成日時/英単語）を定義)
lib/domain/entity/value/sort_order.dart                         # SortOrder (enum: ソート順（昇順/降順）を定義)
lib/domain/entity/model/book_data.dart                          # BookData (単語帳画面の状態クラス。ロード済みリストや終端判定)
lib/domain/entity/model/card_data.dart                          # CardData (表示可否フラグと単語帳エントリを保持するUIモデル)
lib/domain/entity/model/dictionary_data.dart                    # DictionaryData (辞書機能シートの選択中カード・候補リストを保持)
lib/domain/entity/model/sorting_data.dart                       # SortingData (ソート項目・順序・検索文字列などの条件保持クラス)
lib/domain/entity/model/tiles_data.dart                         # TilesData (保存済み英文履歴リストの保持クラス)
lib/domain/entity/model/token_data.dart                         # TokenData (翻訳トークンの情報クラス。ID・訳・表示フラグ・判定ロジック)
lib/domain/entity/model/translation_data.dart                   # TranslationData (入力英文全体とパースされたトークン列の保持クラス)
lib/domain/entity/carry/vocab_entry.dart                        # VocabEntry (単語帳/内部辞書の共通データ持ち運び用DTO)
lib/domain/entity/carry/token_entry.dart                        # TokenEntry (翻訳処理時のトークン割り当て用DTO)
lib/domain/entity/carry/tile_data.dart                          # TileData (英文履歴リスト表示用の軽量DTO)
lib/domain/entity/carry/tile_detail.dart                        # TileDetail (英文履歴からの復元用詳細DTO（本文とトークンチェーン）)

### Data Layer (Repository Implementations)

lib/data/repository_impl/local_book_repository.dart             # LocalBookRepository (Vocabulariesの検索付きページングクエリ実装)
lib/data/repository_impl/local_dictionary_repository.dart       # LocalDictionaryRepository (VocabulariesとInternalDictionariesの検索実装)
lib/data/repository_impl/local_text_processor.dart              # LocalTextProcessor (トークン化、差分計算、辞書検索を組み合わせた解析中核)
lib/data/repository_impl/local_register_repository.dart         # LocalRegisterRepository (単語帳のCUD。一単語一表示の排他制御実装)
lib/data/repository_impl/local_tiles_repository.dart            # LocalTilesRepository (EnglishTextsテーブルへのCRUD操作実装)
lib/data/repository_impl/local_translation_repository.dart      # LocalTranslationRepository (複数キーに一致する有効な訳語の一括取得実装)

### Data Layer (Mappers)

lib/data/mapper/tile_mapper.dart                                # TileMapper (EnglishText行 ⇔ TileData/TileDetail 変換、JSONデコード)
lib/data/mapper/vocab_mapper.dart                               # VocabMapper (Vocabulary/InternalDictionary行 → VocabEntry 変換)
lib/data/mapper/token_mapper.dart                               # TokenMapper (JSON ⇔ TokenData 変換、Vocabulary行 → TokenEntry 変換)

### Data Layer (Database & Initializers)

lib/data/db/app_database.dart                                   # AppDatabase, databaseProvider (Driftデータベース本体の定義。シングルトン)
lib/data/db/app_database.g.dart                                 # Drift自動生成ファイル（編集不要）
lib/data/db/database_initializer.dart                           # DatabaseInitializer (初回データ投入、アセットからのDBコピー)
lib/data/db/_connection_native.dart                             # Native用のQueryExecutor生成関数（constructDb）定義
lib/data/db/_connection_web.dart                                # Web用のQueryExecutor生成関数（constructDb）定義

### Test Layer (UseCase Tests)

test/usecase_test/delete_tile_test.dart                         # DeleteTileUseCase のテスト
test/usecase_test/fetch_tile_detail_test.dart                   # FetchTileDetailUseCase のテスト
test/usecase_test/process_translation_test.dart                 # ProcessTranslationUseCase のテスト
test/usecase_test/save_register_test.dart                       # SaveRegisterUseCase のテスト
test/usecase_test/toggle_card_visibility_test.dart              # ToggleCardVisibilityUseCase のテスト
test/usecase_test/fetch_bookdata_test.dart                      # FetchBookDataUseCase のテスト
test/usecase_test/save_tile_test.dart                           # SaveTileUseCase のテスト
test/usecase_test/fetch_tiles_all_test.dart                     # FetchAllTilesUseCase のテスト
test/usecase_test/fetch_dictionarydata_test.dart                # FetchDictionaryDataUseCase のテスト
test/usecase_test/delete_register_test.dart                     # DeleteRegisterUseCase のテスト

### Test Layer (Repository Implementation Tests)

test/impl_test/local_dictionary_test.dart                       # LocalDictionaryRepository のテスト
test/impl_test/local_tiles_test.dart                            # LocalTilesRepository のテスト
test/impl_test/local_book_test.dart                             # LocalBookRepository のテスト
test/impl_test/local_text_processor_test.dart                   # LocalTextProcessor のテスト
test/impl_test/local_translation_test.dart                      # LocalTranslationRepository のテスト
test/impl_test/local_register_test.dart                         # LocalRegisterRepository のテスト

## 永続化データの定義

### 単語帳テーブル（Vocabularies）

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| id | integer | 主キー、自動インクリメント |
| englishWord | text | 英単語（小文字で保存） |
| japaneseTranslation | text | 日本語訳 |
| isHidden | boolean | true のとき翻訳に使用しない（ドメイン層では `isShow` として反転して扱う） |
| memo | text | ユーザーメモ |
| createdAt | dateTime | 登録日時 |
| updatedAt | dateTime | 更新日時 |

### 内部辞書テーブル（InternalDictionaries）

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| id | integer | 主キー |
| key | text | 検索用キー（小文字のみ） |
| word | text | 英単語（表示用、大小文字混合） |
| mean | text | 日本語訳 |
| memo | text | メモ（nullable） |

### 英文テーブル（EnglishTexts）

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| id | integer | 主キー、自動インクリメント |
| originalText | text | 元の英文全体 |
| parsedWordsJson | text | `TokenData` のリストをJSON形式でシリアライズしたもの |
| createdAt | dateTime | 保存日時 |
| updatedAt | dateTime | 更新日時 |

### 英文JSON（parsedWordsJson）

内部構造は`TokenData.toJson()`の配列で、以下の形式で保存される。
英文履歴からの復元は`TokenMapper.fromJson`で行われ、`TileMapper.toTileDetail`が`parsedWordsJson`をデコードして`TileDetail`（`title`・`chain`）に変換する。

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

- `id`: トークンリスト内での位置インデックス（0始まりの連番）
- `vocabId`: 対応する単語帳エントリのID（未登録・内部辞書のみの場合は`-1`）
- `showWord`: 表示する文字列そのもの（大小文字混合、句読点も含む）
- `nowShow`: 訳語を翻訳画面に表示するかどうか
- `translation`: 表示する訳語文字列

## ファイルの責務

### view_models/

描画に必要な情報を管理する。
riverpodのNotifierを使用している。
データの流通を円滑にするための、メモリとしても使用している。

#### book_notifier.dart

- クラス名: BookNotifier
- 役割: 単語帳画面のリスト状態（ロード済みカード・ページング・終端判定）を管理し、無限スクロールの取得ロジックを提供するNotifier。
- 管理する状態: `AsyncValue<BookData>`（ロード済みカード群・終端状態）
- Provider: bookProvider（AsyncNotifierProvider.autoDispose）

build()はsortingProviderをwatchし、変化時に自動で再取得される。

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| Future\<void> | loadNextPage | - | 無限スクロールで次のページ分のカードを表示できるようにするために使う。ロード中・データ終端時は何もしない。取得に失敗した場合はリスト下部にエラー状態を表示させる。 | FetchBookDataUseCase |
| Future\<void> | reload | - | Pull-to-Refreshや検索確定で、一覧を最新の内容に作り直すために使う。 | sortingProvider |

#### sorting_notifier.dart

- クラス名: SortingNotifier
- 役割: 単語帳画面のソート条件・検索文字列（確定済み／入力中）を管理するNotifier。
- 管理する状態: `SortingData`（ソート項目・順序・検索文字列・ページサイズ）
- Provider: sortingProvider（NotifierProvider）

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| void | setField | SortField newField | 単語帳の並び替え基準を切り替えるために使う。 | - |
| void | setOrder | SortOrder newOrder | 単語帳の並び順（昇順/降順）を切り替えるために使う。 | - |
| void | setSearchWord | String text | 検索条件を確定させ、絞り込み結果を反映させるために使う（Enter確定時などに使用）。 | - |
| void | setTypeWord | String text | 検索バーの入力内容をその都度状態へ反映するために使う。 | - |

#### register_notifier.dart

- クラス名: RegisterNotifier
- 役割: 単語登録・編集画面の入力状態を管理し、保存・削除処理を他Notifierと連携させてオーケストレーションするNotifier。
- 管理する状態: `AsyncValue<CardData>`（編集中の単語帳エントリ）
- Provider: registerProvider（AsyncNotifierProvider.autoDispose）

build()で`regiDataReceiver`から初期値を受け取る。

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| void | updateEnglish | String text | 英単語フィールドへの入力を画面の状態に反映するために使う。 | - |
| void | updateTranslation | String text | 日本語訳フィールドへの入力を画面の状態に反映するために使う。 | - |
| void | updateMemo | String text | メモフィールドへの入力を画面の状態に反映するために使う。 | - |
| void | toggleIsShowing | bool isShow | この訳を翻訳に使うかどうかを切り替えるために使う。 | - |
| Future\<void> | save | - | 登録・編集内容を確定し保存する。単語帳一覧や翻訳結果など他画面への反映も行う。 | SaveRegisterUseCase, TranslationNotifier, BookNotifier, RegiDataReceiver |
| Future\<void> | delete | - | 単語帳エントリを削除する。単語帳一覧や翻訳結果など他画面への反映も行う。削除対象がない場合は何もしない。 | DeleteRegisterUseCase, TranslationNotifier, BookNotifier, RegiDataReceiver |
| void | _updateVocab（private） | VocabEntry Function(VocabEntry) update | VocabEntryの一部だけを差し替えたいときに使う共通ヘルパー。 | - |

#### translation_notifier.dart

- クラス名: TranslationNotifier
- 役割: 翻訳モード画面の入力英文とトークン化結果を管理し、翻訳ロジックのトリガーを引くNotifier。
- 管理する状態: `AsyncValue<TranslationData>`（入力文とパースされたトークン群）
- Provider: translationProvider（AsyncNotifierProvider）, tokenProvider（Provider.family.autoDispose、指定idのTokenDataのみを監視）

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| void | restore | {required String text, required List\<TokenData> chain} | Drawerで選んだ保存済み英文を翻訳画面に呼び戻すために使う。 | - |
| void | updateToken | {required TokenData updatedToken} | 辞書機能シートで訳の表示が変更された場合、対象の1トークンだけに反映するために使う。 | - |
| void | updateOriginalText | {required String newText} | 英文入力のたびに呼ばれ、入力が落ち着いたタイミングで自動的に部分翻訳を実行するために使う。 | Throttle |
| void | pushTriggerButton | - | 再翻訳ボタン押下時に、入力中の英文全体を翻訳し直すために使う。 | Throttle |
| Future\<void> | _runTranslation（private） | {bool isFullScan = true} | 翻訳の実行と反映。 | ProcessTranslationUseCase |

#### selected_token_notifier.dart

- クラス名: SelectedTokenNotifier
- 役割: 辞書機能シートで表示させる、選択中のトークン（単語）を管理するNotifier。
- 管理する状態: `TokenData`（選択中トークン、初期値は空語のTokenData.init）
- Provider: selectedTokenProvider（NotifierProvider）

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| void | selectNew | {required TokenData token} | 選択中のトークンを切り替えるために使う。同じトークンが選択済みの場合は何もしない。 | - |

#### regidata_receiver.dart

- クラス名: RegiDataReceiver
- 役割: 登録・編集画面（RegisterNotifier）の初期状態を受け渡す中継Notifier。単語帳カード・内部辞書カードいずれから遷移しても共通の初期化窓口になる。
- 管理する状態: `CardData`
- Provider: regiDataReceiver（NotifierProvider）

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| void | initialCard | {String word = ''} | 単語を新規登録する画面を、空の状態から開始できるようにするために使う。 | - |
| void | receiveRegisteredCard | {required CardData card} | 単語帳カードの内容を編集画面に引き継ぎ、編集を開始できるようにするために使う。 | - |
| void | receiveDictionaryCard | {required CardData card} | 内部辞書カードの内容を登録画面に引き継ぎ、新規登録を開始できるようにするために使う。 | - |

#### bottom_index_notifier.dart

- クラス名: BottomNavIndexNotifier
- 役割: ボトムナビゲーションバーの選択インデックスを管理するNotifier。
- 管理する状態: `int`（選択中タブのインデックス）
- Provider: bottomNavIndexProvider（NotifierProvider）

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| void | setIndex | int newIndex | ボトムナビゲーションの選択状態を切り替えるために使う。 | - |

#### dictionary_notifier.dart

- クラス名: DictionaryNotifier
- 役割: 辞書機能シートに表示する候補リスト（単語帳・内部辞書）を取得・管理し、表示切替を行うNotifier。
- 管理する状態: `AsyncValue<DictionaryData>`
- Provider: dictionaryProvider（AsyncNotifierProvider.autoDispose）

build()はselectedTokenProviderを読み取り、FetchDictionaryDataUseCaseで候補リストを取得する。

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| Future\<void> | toggleVisibility | {required CardData card} | 辞書機能シートで選んだ候補を「現在使用する訳」として切り替え、翻訳結果にも反映するために使う。単語帳由来のカード以外や処理中のものは対象外。 | ToggleCardVisibilityUseCase, TranslationNotifier |

#### tiles_notifier.dart

- クラス名: TilesNotifier
- 役割: 保存済み英文履歴（Drawer表示用）を管理するNotifier。
- 管理する状態: `AsyncValue<TilesData>`
- Provider: tilesProvider（AsyncNotifierProvider）

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| Future\<void> | addTile | - | 現在の翻訳状態を、後で見返せるように英文履歴として保存するために使う。翻訳が未確定・ロード中の場合は保存しない。 | SaveTileUseCase, translationProvider（参照のみ） |
| Future\<void> | deleteTile | {required int id} | 保存済みの英文履歴を一覧から削除するために使う。 | DeleteTileUseCase |
| Future\<void> | makeTokenChain | {required int id} | 保存済み英文を翻訳画面に呼び戻すために使う。 | FetchTileDetailUseCase, TranslationNotifier |

### root/

比較的最初に読み込まれる。
ルーティングと、共通画面の定義を行っている。

#### routing.dart

- クラス名: EnglishLearningApp, SettingPage, HelpPage（同一ファイル内に3クラス）

##### EnglishLearningApp

- 役割: GoRouterによるルーティング定義とMaterialAppの共通設定（テーマ・ロケール）のルート。ShellRoute配下にボトムナビ切替対象（/translate, /words）を、独立画面として/registration・/setting・/helpを定義する。
- Provider: なし

| パス | 対応ページ | 備考 |
| :--- | :--- | :--- |
| /translate | TranslationModePage | 初期表示画面、ShellRoute配下（CommonScreen） |
| /words | MyBookScreen | ShellRoute配下（CommonScreen） |
| /registration | MyEntryScreen | 独立画面 |
| /setting | SettingPage | 独立画面、未実装のプレースホルダー |
| /help | HelpPage | 独立画面、未実装のプレースホルダー |

##### SettingPage

- 役割: 設定画面。現状は固定テキストのみを表示する未実装のプレースホルダー。

##### HelpPage

- 役割: ヘルプ画面。現状は固定テキストのみを表示する未実装のプレースホルダー。

#### common_screen.dart

- クラス名: CommonScreen
- 役割: ボトムナビゲーションバー付きの共通Scaffold。現在のタブに応じてAppBarタイトルとルーティング先を切り替える。
- Provider: なし

| 型 | 関数名 | 引数 | 説明 | 依存 |
| :--- | :--- | :--- | :--- | :--- |
| void | onTap（BottomNavigationBar） | int newIndex | ボトムナビのタップに応じて表示中の画面を切り替えるために使う。 | bottomNavIndexProvider |

### pages/

役割の説明を主とし、状態を持たない・またはロジックが薄いWidgetについては表を省略する。
表中の「クラス名」列には、部品化されていない要素（ボタン・アイコン等）についてはWidget型名（`IconButton`等）を記載する。
画面全体を管理するコンポーネントについては、子コンポーネント（および画面直下に配置されたボタン等）のリストとして表を構成する。

#### wordbook/

##### book_screen.dart

- クラス名: MyBookScreen
- 役割: 単語帳画面のルート。無限スクロール・検索バー・ソートUI・単語カードリストを統合する。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 検索入力欄 | MySearchBar | AppBarタイトル部 | - | 検索キーワードを入力する（子コンポーネント）。 | sortingProvider, bookProvider |
| 昇順/降順切替ボタン | MySortOrderButton | AppBar右側（actions先頭） | - | 単語帳の並び順を切り替える（子コンポーネント）。 | sortingProvider |
| ソート項目ドロップダウン | MySortDropdownMenu | AppBar右側（actions2番目） | - | 並び替え基準を選択する（子コンポーネント）。 | sortingProvider |
| ホームアイコンボタン | IconButton（Icons.home） | AppBar右端 | onPressed | 検索・ソート条件を初期状態に戻すために使う。 | sortingProvider, bookProvider |
| 再読み込みアイコンボタン | IconButton（Icons.loop） | AppBar右端 | onPressed | 単語帳一覧を読み込み直すために使う。 | bookProvider |
| 単語帳カードリスト | MyBookCard（一覧） | 画面中央（CustomScrollViewのSliverList） | scrollListener | リスト終端に近づくと無限スクロールで次ページを自動読み込みする。各行は子コンポーネント。 | bookProvider, Throttle |
| リスト下部フッター | MyBookFooter | リスト最下部 | - | ロード中・エラー・終端の状態に応じた表示を出し分ける（子コンポーネント）。 | bookProvider |
| 初回ロード中インジケータ | CircularProgressIndicator | 画面中央 | - | 初回データ取得中であることを示す。 | bookProvider |
| 初回エラー画面 | MyInitialError | 画面中央 | - | 初回データ取得に失敗した際のエラー表示とリトライ導線（子コンポーネント）。 | bookProvider |
| Pull-to-Refresh | RefreshIndicator（画面全体をラップ） | 画面全体 | onRefresh | 下に引っ張って単語帳一覧を最新の内容に更新するために使う。 | bookProvider |
| 新規追加ボタン | FloatingActionButton | 画面右下 | onPressed | 新規単語を登録する画面（/registration）を開くために使う。 | regiDataReceiver |

##### list/book_footer.dart

- クラス名: MyBookFooter
- 役割: リスト下部の状態（途中ロード中・途中エラー・終端）に応じたフッターを出し分ける。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| ロード中インジケータ | CircularProgressIndicator（_MyLoadingFooter） | リスト最下部 | - | 次ページ読み込み中であることを示す。 | bookProvider |
| エラーメッセージ＋リトライボタン | ElevatedButton「リトライ」（_MyErrorFooter） | リスト最下部 | onPressed | 次ページの取得に失敗した際、再取得を試みるために使う。 | bookProvider |
| 全件読み込み完了メッセージ | Text（_MyEndFooter） | リスト最下部 | - | 単語帳データを全て読み込んだことを知らせる。 | - |

##### list/initial_error.dart

- クラス名: MyInitialError
- 役割: 初回ロード失敗時のエラー表示とリトライ導線。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| エラーメッセージ・詳細テキスト | Text（2行） | 画面中央 | - | 初回ロードに失敗した旨とエラー内容を表示する。 | - |
| リトライボタン | ElevatedButton「リトライ」 | 画面中央 | onPressed | 初回読み込みに失敗した単語帳一覧を、取得し直すために使う。 | bookProvider |

##### list/book_card.dart

- クラス名: MyBookCard
- 役割: 単語帳リストの1件分のカードUI（英単語・訳語・メモ・非表示アイコン・更新日時）を表示する。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| カード全体 | Card（角丸・薄枠） | リスト内1件分 | - | 単語帳1件分の情報をまとめて表示する。 | - |
| 英単語表示 | Text | カード上段左 | - | 登録済みの英単語を表示する。 | - |
| 日本語訳表示 | Text | カード上段右 | - | 対応する日本語訳を表示する。 | - |
| メモ表示 | Text | カード下段左 | - | ユーザーが入力したメモを表示する。 | - |
| 非表示アイコン | Icon（visibility_off） | カード下段（isShow=false時のみ） | - | この訳が翻訳で使われない設定であることを示す。 | - |
| 更新日時表示 | Text「更新: YYYY/MM/DD」 | カード下段右寄り | - | 最終更新日を表示する。 | - |
| 編集アイコン | IconButton（Icons.more_vert） | カード下段右端 | onPressed | このカードの内容を編集する画面（/registration）を開くために使う。 | regiDataReceiver |

##### search/sort_order.dart

- クラス名: MySortOrderButton
- 役割: ソート順序（昇順/降順）を切り替えるトグルボタン。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 昇順/降順切替ボタン | IconButton（矢印アイコン） | AppBar内 | onPressed | 単語帳の並び順（昇順/降順）を切り替えるために使う。 | sortingProvider |

##### search/sort_dropdown.dart

- クラス名: MySortDropdownMenu
- 役割: ソート項目（作成日時/英単語）を選択するドロップダウン。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| ソート項目選択メニュー | DropdownButton\<SortField\> | AppBar内 | onChanged | 単語帳の並び替え基準（作成日時/英単語）を切り替えるために使う。 | sortingProvider |

##### search/searchbar.dart

- クラス名: MySearchBar
- 役割: 検索キーワード入力バー。入力中文字列と確定済み文字列を分離管理し、Enterで検索を確定してDBへ問い合わせる。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 検索入力欄 | TextField（検索アイコン付き） | AppBarタイトル部 | onChanged | 検索バーの入力内容をその都度状態に反映するために使う。 | sortingProvider |
| 検索入力欄（確定） | 同上 | 同上 | onSubmitted | 入力した検索語を確定させ、単語帳一覧を絞り込むために使う。 | sortingProvider, bookProvider |
| クリアボタン | IconButton（Icons.clear、suffixIcon） | 検索欄右端（入力中のみ表示） | onPressed | 検索入力をクリアするために使う。 | sortingProvider |

#### drawer/

##### tile.dart

- クラス名: MyTile
- 役割: Drawer内の保存済み英文1件分のListTile。タップで復元、削除アイコンで消去する。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 保存済み英文タイル | ListTile（履歴アイコン+テキスト） | Drawerリスト内1件分 | onTap | 保存済みの英文を翻訳画面に呼び戻すために使う。復元に失敗した場合はエラーダイアログを表示する。 | tilesProvider |
| 削除アイコン | IconButton（Icons.delete、trailing） | タイル右端 | onPressed | 保存済みの英文を一覧から削除するために使う。失敗した場合はエラーダイアログを表示する。 | tilesProvider |

##### drawer.dart

- クラス名: MyDrawer
- 役割: アプリ共通のDrawer。保存済み英文一覧・設定・ヘルプへの導線を提供する。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| ヘッダー | DrawerHeader「保存した英文」 | Drawer最上部 | - | Drawerの見出しを表示する。 | - |
| 保存済み英文リスト | MyTile（一覧） | Drawer中央 | - | 保存済み英文の一覧を表示する（子コンポーネント）。 | tilesProvider |
| 設定リストタイル | ListTile「設定」 | Drawer下部 | onTap | 設定画面（/setting）を開くために使う。 | - |
| ヘルプリストタイル | ListTile「ヘルプ」 | Drawer最下部 | onTap | ヘルプ画面（/help）を開くために使う。 | - |

#### translation/

##### translate_fab.dart

- クラス名: MyTranslateFab
- 役割: 再翻訳を実行するボタン。処理中は無効化しラベルを変更する。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 再翻訳ボタン | ElevatedButton.icon（play_arrow＋「再翻訳」） | 入力欄下のボタン列左 | onPressed | 入力中の英文を再翻訳するために使う。処理中は「翻訳中」表示になり無効化される。 | translationProvider |

##### text_field.dart

- クラス名: MyTextField
- 役割: 翻訳モードの英文入力フィールド。外部状態（Provider）とTextEditingControllerの双方向同期を行う。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 英文入力欄 | TextField（複数行対応） | 画面上部 | onChanged | 英文入力を翻訳処理に反映するために使う。 | translationProvider |
| クリアボタン | IconButton（Icons.clear、suffixIcon） | 入力欄右端（入力中のみ表示） | onPressed | 入力中の英文と翻訳結果をまとめてリセットするために使う。 | translationProvider |

##### translation.dart

- クラス名: TranslationModePage
- 役割: 翻訳モード画面のレイアウト。入力欄・翻訳/保存ボタン・トークン表示エリアを縦に並べるレイアウト専用StatelessWidget。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 英文入力欄 | MyTextField | 画面上部 | - | 翻訳対象の英文を入力する（子コンポーネント）。 | - |
| 再翻訳ボタン | MyTranslateFab | ボタン列左 | - | 再翻訳を実行する（子コンポーネント）。 | - |
| 保存ボタン | MyBookmarkFab | ボタン列右 | - | 現在の翻訳結果を英文履歴として保存する（子コンポーネント）。 | - |
| 単語ブロック表示エリア | MyBlockField | 画面下部 | - | トークン列を折り返し表示する（子コンポーネント）。 | - |

##### word_block.dart

- クラス名: WordBlock
- 役割: トークン1件分の表示ブロック（英単語＋訳語）。単語トークンをタップすると辞書機能シートを開く。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 単語ブロック | InkWell＋Container（英単語+訳語） | MyBlockField内1トークン分 | onTap | タップした単語の辞書・別訳候補を確認できるよう、辞書機能シートを開くために使う（単語トークンのみ対象）。 | selectedTokenProvider |

##### bookmark_fab.dart

- クラス名: MyBookmarkFab
- 役割: 現在の翻訳結果を英文履歴として保存するボタン。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 保存ボタン | ElevatedButton.icon（bookmark_add＋「保存」） | ボタン列右 | onPressed | 現在の翻訳結果を、後で見返せるように英文履歴として保存するために使う。保存後はスナックバーで通知する。 | tilesProvider |

##### block_field.dart

- クラス名: MyBlockField
- 役割: トークン列をWrapレイアウトで表示するエリア。ピリオドトークンの直後に改行用ダミーウィジェットを挿入する表示専用ロジックを持つ。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 単語ブロック一覧 | WordBlock（Wrapレイアウト） | 画面下部 | - | トークン列を折り返し表示する。ピリオド直後に改行を挿入する（子コンポーネント）。 | translationProvider |
| ロード中インジケータ | CircularProgressIndicator | 画面下部 | - | 翻訳処理中であることを示す。 | translationProvider |
| エラーメッセージ | Text | 画面下部 | - | 翻訳処理に失敗したことを知らせ、再翻訳を促す。 | translationProvider |

#### register/

##### regi_memo_card.dart

- クラス名: MyMemoCard
- 役割: メモ入力フィールド。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| メモ入力欄 | TextField（ラベル「メモ」） | カード内 | onChanged | メモ入力を画面の状態に反映するために使う。 | registerProvider |

##### regi_translation_card.dart

- クラス名: MyTranslationCard
- 役割: 日本語訳入力フィールド（必須項目）。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 日本語訳入力欄 | TextField（ラベル「日本語訳 *」） | カード内 | onChanged | 日本語訳の入力を画面の状態に反映するために使う。 | registerProvider |

##### regi_footer_bar.dart

- クラス名: MyFooterBar
- 役割: 登録・編集画面下部の操作バー（削除・キャンセル・保存）。既存エントリの場合のみ削除ボタンを表示し、保存条件を満たさない場合は保存ボタンを無効化する。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 削除ボタン | ElevatedButton「消去」 | フッター左（既存エントリのみ表示） | onPressed | 単語帳エントリを削除するために使う。結果はスナックバーで伝え、成功時は画面を閉じる。 | registerProvider |
| キャンセルボタン | TextButton「キャンセル」 | フッター中央 | onPressed | 編集を中断して画面を閉じるために使う。 | - |
| 保存ボタン | ElevatedButton「新規保存/上書き保存」 | フッター右 | onPressed | 入力内容を保存するために使う。保存条件を満たさない場合は無効化される。結果はスナックバーで伝え、成功時は画面を閉じる。 | registerProvider |

##### regi_english_card.dart

- クラス名: MyEnglishCard
- 役割: 英単語表示/編集フィールド。既存エントリでは表示のみとし、確認ダイアログを経てから編集モードに切り替える（誤変更防止のワンクッション）。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 英単語表示/入力欄 | Text または TextField（切替式） | カード内 | - | 既存エントリでは表示のみ、新規エントリでは直接入力可能。 | registerProvider |
| 編集ボタン | TextButton「編集」 | カード右上（既存エントリのみ表示） | onPressed | 確認ダイアログを経て編集モードに切り替えるために使う。 | - |
| 確認ダイアログの続行ボタン | ElevatedButton「続行」（AlertDialog内） | ダイアログ内 | onPressed | 誤変更防止の確認を経て編集モードへ切り替える。 | - |
| 確認ダイアログのキャンセルボタン | TextButton「キャンセル」（AlertDialog内） | ダイアログ内 | onPressed | 編集モードへの切り替えを中止する。 | - |
| 英単語入力欄（編集モード時） | TextField（ラベル「英単語 *」） | カード内 | onChanged | 英単語の入力を画面の状態に反映するために使う。 | registerProvider |

##### registration_page.dart

- クラス名: MyEntryScreen
- 役割: 単語登録・編集画面のルート。各入力カードとフッターバーを配置するレイアウト専用Widget。新規/編集でAppBarタイトルを出し分ける。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| AppBarタイトル | Text「カードを編集」/「カードを作成」 | AppBar | - | 新規登録か編集かでタイトルを出し分ける。 | registerProvider |
| 英単語カード | MyEnglishCard | 画面上部 | - | 英単語の表示/編集（子コンポーネント）。 | - |
| 日本語訳カード | MyTranslationCard | 英単語カード下 | - | 日本語訳の入力（子コンポーネント）。 | - |
| メモカード | MyMemoCard | 日本語訳カード下 | - | メモの入力（子コンポーネント）。 | - |
| 表示可否スイッチカード | MyVisibilitySwitchCard | メモカード下 | - | 訳の表示可否切り替え（子コンポーネント）。 | - |
| フッターバー | MyFooterBar | 画面最下部 | - | 保存・キャンセル・削除操作（子コンポーネント）。 | - |

##### regi_visual_card.dart

- クラス名: MyVisibilitySwitchCard
- 役割: 訳の表示可否（isShow）を切り替えるスイッチカード。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 表示切り替えアイコンボタン | IconButton（visibility/visibility_off） | カード右側 | onPressed | この訳を翻訳に使うかどうかを切り替えるために使う。 | registerProvider |

#### dictionary/

##### dictionary_sheet.dart

- クラス名: MyDictionarySheet
- 役割: 辞書機能シート本体。選択中トークンに対応する単語帳・内部辞書の候補一覧を表示し、オリジナル登録への導線を提供する。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 見出し（選択中の単語） | Text | シート上部左 | - | 選択中のトークンの英単語を大きく表示する。 | selectedTokenProvider |
| 閉じるボタン | IconButton（Icons.close） | シート上部右 | onPressed | 辞書機能シートを閉じるために使う。 | - |
| 単語帳由来の候補カード一覧 | MyRegisteredCard（一覧） | シート中央 | - | 単語帳に登録済みの訳語候補を表示する（子コンポーネント）。 | dictionaryProvider |
| 内部辞書由来の候補カード一覧 | MyDictionaryCard（一覧） | シート中央 | - | 内部辞書由来の訳語候補を表示する（子コンポーネント）。 | dictionaryProvider |
| オリジナル登録リストタイル | ListTile「オリジナルを登録」 | シート最下部 | onTap | 候補にない単語を新規登録するために、登録画面（/registration）を開く。 | regiDataReceiver |

##### registered_card.dart

- クラス名: MyRegisteredCard
- 役割: 単語帳由来の候補カード。表示/非表示切り替えと単語帳編集への導線を持つ。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| カード全体 | Card（枠線、選択中は強調） | 候補リスト内1件分 | - | 単語帳由来の訳語候補を表示する。現在選択中の訳は枠線を強調する。 | - |
| 訳語表示 | Text | カード上段左 | - | 候補の日本語訳を表示する。 | - |
| 表示切り替えアイコン | IconButton（visibility/visibility_off） | カード上段右（単語帳由来カードのみ表示） | onPressed | この訳を翻訳に使うかどうかを切り替えるために使う。 | dictionaryProvider |
| 編集アイコン | IconButton（Icons.book） | カード上段右端 | onPressed | このカードの内容を編集する画面（/registration）を開くために使う。 | regiDataReceiver |
| メモ表示 | Text（アイコン付き） | カード下段 | - | 登録済みのメモを表示する。訳語表示中の場合は目のアイコンを添える。 | - |

##### dictionary_card.dart

- クラス名: MyDictionaryCard
- 役割: 内部辞書由来の候補カード。オリジナル登録への導線を持つ。

| 見た目 | クラス名 | 場所 | イベント/関数 | 役割 | 依存 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| カード全体 | Card（枠線） | 候補リスト内1件分 | - | 内部辞書由来の訳語候補を表示する。 | - |
| 訳語表示 | Text | カード上段 | - | 候補の日本語訳を表示する。 | - |
| 登録アイコン | IconButton（Icons.book_outlined） | カード上段右 | onPressed | 内部辞書の候補を単語帳に登録するために、登録画面（/registration）を開く。 | regiDataReceiver |
| メモ表示 | Text | カード下段（メモがある場合のみ） | - | 補足メモを表示する。 | - |

### usecase/

UseCaseは「1 UseCase = 1メソッド（execute）」の原則に基づく。

#### process_translation_usecase.dart

- クラス名: ProcessTranslationUseCase
- 役割: 英文の全文解析または部分解析をTextProcessorに委譲するUseCase。
- Provider: processTranslationUseCaseProvider
- 依存: ProcessorRepository（TextProcessor）

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<List\<TokenData>> | execute | {required String text, required List\<TokenData> currentTokens, required bool isFullScan} | 入力中の英文に対応する翻訳結果（トークン列）を得るために使う。状況に応じて全文解析・部分解析を使い分ける。 |

#### fetch_tiles_all_usecase.dart

- クラス名: FetchAllTilesUseCase
- 役割: 保存済み英文履歴の一覧を取得するUseCase。
- Provider: fetchAllTilesUseCaseProvider
- 依存: TilesRepository

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<List\<TileData>> | execute | - | Drawerに表示する、保存済み英文履歴の一覧を取得するために使う。 |

#### fetch_bookdata_usecase.dart

- クラス名: FetchBookDataUseCase
- 役割: 単語帳データをページング取得し、CardDataへ変換するUseCase。
- Provider: fetchBookDataUseCaseProvider
- 依存: BookRepository

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future<\List\<CardData>> | execute | {required int currentCount, required SortingData sorter} | 単語帳一覧を、画面表示にそのまま使える形式（CardData）で取得するために使う。 |

#### fetch_tile_detail_usecase.dart

- クラス名: FetchTileDetailUseCase
- 役割: 指定IDの英文トークン列を取得するUseCase。
- Provider: fetchTileDetailUseCaseProvider
- 依存: TilesRepository

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<TileDetail> | execute | {required int id} | 保存済み英文を翻訳画面に復元するために必要な情報を取得するために使う。 |

#### fetch_dictionarydata_usecase.dart

- クラス名: FetchDictionaryDataUseCase
- 役割: 選択中トークンに対応する単語帳・内部辞書候補を取得し、表示中カード（showCard）と候補リストに振り分けるUseCase。
- Provider: fetchDictionaryDataUseCaseProvider
- 依存: DictionaryRepository

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<DictionaryData> | execute | TokenData token | 辞書機能シートに表示するために、現在採用中の訳とその他の候補を区別して取得するために使う。 |

#### save_tile_usecase.dart

- クラス名: SaveTileUseCase
- 役割: 現在の翻訳状態（英文＋トークン列）を英文履歴としてDBに保存するUseCase。
- Provider: saveTileUseCaseProvider
- 依存: TilesRepository

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<TileData> | execute | {required String originalText, required List\<TokenData> tokens} | 現在の翻訳結果を、後で見返せるように英文履歴として保存するために使う。 |

#### delete_register_usecase.dart

- クラス名: DeleteRegisterUseCase
- 役割: 単語帳エントリを削除するUseCase。
- Provider: deleteRegisterUseCaseProvider
- 依存: RegisterRepository

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<TokenData> | execute | {required CardData card, required TokenData token} | 単語帳エントリを削除する。翻訳画面側のトークンも未登録の状態に戻す。 |

#### delete_tile_usecase.dart

- クラス名: DeleteTileUseCase
- 役割: 指定IDの英文履歴を削除するUseCase。
- Provider: deleteTileUseCaseProvider
- 依存: TilesRepository

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<void> | execute | {required int id} | 保存済み英文履歴を一覧から削除するために使う。 |

#### save_register_usecase.dart

- クラス名: SaveRegisterUseCase
- 役割: 単語帳エントリの新規追加または更新を行うUseCase。
- Provider: saveRegisterUseCaseProvider
- 依存: RegisterRepository

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<TokenData> | execute | {required CardData card, required TokenData token} | 単語帳エントリを新規登録または更新する。その結果を翻訳画面側のトークンにも反映するために使う。 |

#### toggle_card_visibility_usecase.dart

- クラス名: ToggleCardVisibilityUseCase
- 役割: 辞書機能シート内で候補カードの表示/非表示を切り替え、DictionaryDataとTokenDataの整合を取るUseCase（DBアクセスなし、純粋なロジックのみ）。
- Provider: toggleCardVisibilityUseCaseProvider
- 依存: なし

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| (DictionaryData, TokenData) | execute | {required DictionaryData currentData, required CardData targetCard, required TokenData currentToken} | 表示中の訳を取りやめる。単語帳の訳を使用する。既に表示中の訳がある場合、表示中の訳を取りやめ、単語帳の訳を表示する。対象が候補に見つからない場合は変更しない。 |

### repository_abstract/

リポジトリの抽象interface。
各Providerで具象実装（`data/repository_impl/`配下）を注入する。

#### book_repository.dart

- クラス名: BookRepository
- 役割: 単語帳テーブルでの検索付きページングを定義する抽象interface。
- Provider: bookRepositoryProvider（実装: LocalBookRepository）

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<List\<VocabEntry>> | fetchVocabulariesWithPaging | {required int offset, required SortingData sorter} | 検索語・並び替え条件に応じた単語帳一覧を、ページ単位で取得する。 |

#### processor_repository.dart

- クラス名: TextProcessor
- 役割: 翻訳ロジックを定義する抽象interface。
- Provider: textProcessorProvider（実装: LocalTextProcessor）

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<List\<TokenData>> | partTranslation | {required List\<TokenData> nowTokens, required String newText} | 英文の一部だけが変更された際に、変更のあった箇所だけを再解析し、翻訳結果を効率よく更新する。 |
| Future\<List\<TokenData>> | fullTranslation | {required String text} | 英文全体を最初から解析し、翻訳結果を作り直す。 |

#### dictionary_repository.dart

- クラス名: DictionaryRepository
- 役割: 単語帳・内部辞書それぞれから、特定の単語に対応する候補を取得する抽象interface。
- Provider: dictionaryRepositoryProvider（実装: LocalDictionaryRepository）

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<List\<VocabEntry>> | fetchVocabularies | {required String word} | 指定した単語に一致する単語帳エントリを、辞書機能シートの候補として取得する。 |
| Future\<List\<VocabEntry>> | fetchDictionaries | {required String word} | 指定した単語に一致する内部辞書エントリを、辞書機能シートの候補として取得するために使う。 |

#### register_repository.dart

- クラス名: RegisterRepository
- 役割: 単語帳テーブルへのCUD操作を定義する抽象interface。
- Provider: registerRepositoryProvider（実装: LocalRegisterRepository）

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<VocabEntry> | addVocabulary | {required VocabEntry vocab} | 単語帳テーブルへ新規追加する。表示予定の訳がある場合は、他の訳と表示が重複しないよう調整する。 |
| Future\<VocabEntry> | updateVocabulary | {required VocabEntry vocab} | 単語帳テーブルの既存エントリを更新する。表示予定の訳がある場合は、他の訳と表示が重複しないよう調整する。 |
| Future\<void> | deleteVocabulary | {required int id} | 単語帳テーブルの既存エントリを削除する。 |

#### translation_repository.dart

- クラス名: TranslationRepository
- 役割: 翻訳処理で使う単語帳エントリの一括取得を定義する抽象interface。
- Provider: translationRepositoryProvider（実装: LocalTranslationRepository）

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<List\<TokenEntry>> | fetchTranslationsBatch | {required Set\<String> keys} | 翻訳画面に表示する訳語を、複数の単語についてまとめて取得するために使う（非表示設定のエントリは対象外）。 |

#### tiles_repository.dart

- クラス名: TilesRepository
- 役割: 英文履歴テーブルへのCRUD操作を定義する抽象interface。
- Provider: tilesRepositoryProvider（実装: LocalTilesRepository）

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<int> | createTile | {required String text, required String chain} | 英文を保存する。 |
| Future\<void> | deleteTile | {required int id} | 指定idの英文を削除する。 |
| Future\<List\<TileData>> | fetchAllTiles | - | 英文履歴の一覧（id・原文のみ）を取得する。 |
| Future\<TileDetail> | fetchTileDetail | {required int id} | 指定IDの英文履歴（英文・トークン列）を取得する。 |

### entity/

#### value/

ソート順やステータスなど。
システム内であらかじめ決まった選択肢や概念そのものを定義している。

##### base_status.dart

- クラス名: Based

| 列挙値 | 型 | 説明 |
| :--- | :--- | :--- |
| vocabularies | enum | 単語帳DB由来 |
| dictionary | enum | 内部辞書DB由来 |
| init | enum | 初期値（未登録） |

##### sync_status.dart

- クラス名: SyncStatus

| 列挙値 | 型 | 説明 |
| :--- | :--- | :--- |
| normal | enum | 通常状態 |
| load | enum | 途中ロード中 |
| err | enum | 途中エラー |

##### sort_field.dart

- クラス名: SortField

| 列挙値 | 型 | 説明 |
| :--- | :--- | :--- |
| createdAt | enum | 作成日時でソート |
| englishWord | enum | 英単語でソート |

##### sort_order.dart

- クラス名: SortOrder

| 列挙値 | 型 | 説明 |
| :--- | :--- | :--- |
| asc | enum | 昇順 |
| desc | enum | 降順 |

#### model

画面（UI）に何を表示するか、スクロールがどこまで進んだかなど。
現在の状態、UIに必要な情報を保持する。

##### book_data.dart

- クラス名: BookData

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| pageSize | int | 1ページあたりの取得件数 |
| cards | List\<CardData> | ロード済み単語カードのリスト |
| tailStatus | SyncStatus | リスト下部に表示すべき状態 |
| isDataEnd | bool | getter: cards.length < pageSize でデータ終端かを判定 |

##### card_data.dart

- クラス名: CardData

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| nowShow | bool | 現在この訳語が翻訳に表示されているか |
| vocab | VocabEntry | 単語帳エントリ本体 |

##### dictionary_data.dart

- クラス名: DictionaryData

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| showCard | CardData? | 現在選択・表示中のカード（null = 非選択） |
| vocabularyCards | List\<CardData> | 単語帳からの候補リスト（未選択分） |
| dictionaryCards | List\<CardData> | 内部辞書からの候補リスト |

##### sorting_data.dart

- クラス名: SortingData

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| field | SortField | ソート対象カラム |
| order | SortOrder | ソート順 |
| searchWord | String | 確定済み検索文字列 |
| typingWord | String | 入力中の検索文字列（未確定） |
| pageSize | int | 1ページあたりの取得件数（既定値20） |

##### tiles_data.dart

- クラス名: TilesData

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| list | List\<TileData> | 保存済み英文履歴リスト |

##### token_data.dart

- クラス名: TokenData

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| id | int | リスト内の位置インデックス |
| vocabId | int | 対応する単語帳エントリID（未登録は -1） |
| showWord | String | 表示する文字列（大小文字混合） |
| nowShow | bool | 訳語を翻訳画面に表示するか |
| translation | String | 表示する訳語 |
| isWord | bool | getter: 単語か句読点かを正規表現で判定 |
| word | String | getter: showWord.toLowerCase()（DB検索キー） |

##### translation_data.dart

- クラス名: TranslationData

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| originalText | String | 入力された英文全体 |
| tokens | List\<TokenData> | トークン化・訳語割り当て済みのリスト |

#### carry

データベース（外部）から取ってきた生データを、アプリケーション内部で持ち運んだり受け渡したりするための中継役（=DTO）。

##### vocab_entry.dart

- クラス名: VocabEntry

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| id | int | 単語帳DBのID（内部辞書由来は -1） |
| word | String | 英単語（小文字） |
| translation | String | 日本語訳 |
| isShow | bool | 翻訳に使用するか（DBのisHiddenの反転） |
| memo | String | メモ |
| createdAt | DateTime | 登録日時 |
| updatedAt | DateTime | 更新日時 |
| based | Based | 出典元 |

##### token_entry.dart

- クラス名: TokenEntry

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| vocabId | int | 対応する単語帳エントリID |
| showWord | String | 英単語（表示用） |
| translation | String | 日本語訳 |
| isShow | bool | 翻訳に表示するか |

##### tile_data.dart

- クラス名: TileData

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| id | int | 英文履歴DBのID |
| text | String | 英文テキスト（履歴リスト表示用） |

##### tile_detail.dart

- クラス名: TileDetail

| フィールド名 | 型 | 説明 |
| :--- | :--- | :--- |
| title | String | 英文テキスト |
| chain | List\<TokenData> | 訳語割り当て済みトークンリスト（履歴からの復元用） |

### repository_impl/

各`repository_abstract`の具象実装。
メソッドの説明は`repository_abstract`に従う。
ヘルパー関数のみを記す。

#### local_book_repository.dart

- クラス名: LocalBookRepository
- 役割: BookRepositoryの実装。Vocabulariesテーブルに対し検索・ソート・ページングを組み合わせたクエリを発行する。

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Expression | _getSortExpression（private） | SortField field | 並び替え対象のカラムを決めるための内部処理。 |
| OrderingMode | _getSortMode（private） | SortOrder order | 並び順（昇順/降順）を決めるための内部処理。 |

#### local_dictionary_repository.dart

- クラス名: LocalDictionaryRepository
- 役割: DictionaryRepositoryの実装。VocabulariesテーブルとInternalDictionariesテーブルの双方から、指定単語に一致する候補を検索する。

#### local_text_processor.dart

- クラス名: LocalTextProcessor
- 役割: ProcessorRepository（TextProcessor）の実装。英文解析ロジックの中核を担う。
  - 正規表現によるトークン化
  - `diffutil_dart`による差分計算
  - TranslationRepository経由の辞書一括検索

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| List\<TokenData> | _tokenizeText（private） | {required String text} | 英文を単語・句読点などのトークン単位に分解するための内部処理。 |

備考: 同一検索キーに複数エントリがある場合`isShow: true`のものを優先する。

#### local_translation_repository.dart

- クラス名: LocalTranslationRepository
- 役割: TranslationRepositoryの実装。複数キーに対応する単語帳エントリ（isHidden=falseのみ）を一括取得する。

#### local_register_repository.dart

- クラス名: LocalRegisterRepository
- 役割: RegisterRepositoryの実装。単語帳テーブルへのCUD操作を行う。同一英単語につき「表示する訳」は1件のみとする排他制御を担う。

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<int> | _setAllOthersHidden（private） | {required String word} | 同じ英単語について「表示する訳は常に1件のみ」というルールを保つための内部処理。 |

#### local_tiles_repository.dart

- クラス名: LocalTilesRepository
- 役割: TilesRepositoryの実装。英文テーブル（EnglishTexts）へのCRUD操作を行う。

### mapper/

DBの行オブジェクト・JSON・ドメイン層のcarry/model間の変換のみを担う純粋な変換クラス群。
Provider定義は持たない。

#### tile_mapper.dart

- クラス名: TileMapper
- 役割: `EnglishText`（DB行）⇔ `TileData`/`TileDetail`間の変換。

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| TileData | toTileData | {required int id, required String text} | EnglishText行をTileDataへ変換する。英文リスト表示に使用。 |
| TileDetail | toTileDetail | {required EnglishText et} | EnglishText行をTileDetailへ変換する。英文復元に使用。parsedWordsJsonをデコードし、TokenMapper.fromJsonでトークン列（chain）を復元する。 |

#### vocab_mapper.dart

- クラス名: VocabMapper
- 役割: `Vocabulary`/`InternalDictionary`（DB行）→ `VocabEntry`への変換。

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| VocabEntry | fromVocabularies | {required Vocabulary vocabulary} | Vocabulary行をVocabEntryへ変換する。単語帳の情報を保持させる。isHiddenを反転してisShowにマッピングする。based: Based.vocabulariesを付与する。 |
| VocabEntry | fromDictionary | {required InternalDictionary dictionary} | InternalDictionary行をVocabEntryへ変換する。内部辞書の情報を保持させる。isHiddenを反転してisShowにマッピングする。based: Based.dictionaryを付与する。id: -1固定、isShow: true固定、memoはnull時に空文字を補う。 |

#### token_mapper.dart

- クラス名: TokenMapper
- 役割: JSON⇔`TokenData`間、`Vocabulary`→`TokenEntry`間の変換。

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| TokenData | fromJson | {required Map<String, dynamic> json} | parsedWordsJsonの1要素をTokenDataへ変換する。英文復元に使用。 |
| TokenEntry | fromVocabularies | {required Vocabulary voc} | Vocabulary行をTokenEntryへ変換する。翻訳時、トークンに訳を表示させるために使用。isHiddenを反転してisShowにマッピングする。 |

### db/

#### app_database.dart

- クラス名: AppDatabase
- 役割: Driftデータベース本体の定義。
  - 単語帳テーブル（`Vocabularies`）、内部辞書テーブル（`InternalDictionaries`）、英文テーブル（`EnglishTexts`）の3テーブルを保持するシングルトン。
  - テスト用に`AppDatabase.forTesting(executor)`コンストラクタを持つ。
- schemaVersion: 1（マイグレーション戦略は現状`onCreate`のみ）。
- Provider: databaseProvider（AppDatabaseのインスタンスを提供）。

#### database_initializer.dart

- クラス名: DatabaseInitializer
- 役割: 初回起動時のデータ投入・アセットからのDBファイルコピーを担う。

| 型 | メソッド名 | 引数 | 説明 |
| :--- | :--- | :--- | :--- |
| Future\<void> | insertManualVocabularies | - | 単語帳の初期投入。 |
| static Future\<void> | ensureDictionaryCopied | - | 内部辞書の初期投入。ネイティブ環境用。 |

#### _connection_native.dart

- 役割: プラットフォーム分岐用のQueryExecutor生成関数（`constructDb`）を定義する。`app_database.dart`から条件付きimportで切り替えられ、ネイティブの場合このファイルが読み込まれ、`NativeDatabase`を返す。

### _connection_web.dart

- 役割: プラットフォーム分岐用のQueryExecutor生成関数（`constructDb`）を定義する。`app_database.dart`から条件付きimportで切り替えられ、Webの場合はこのファイルが読み込まれ、`drift_flutter`の`driftDatabase`（sqlite3.wasm使用）を返す。

#### app_database.g.dart

- 役割: Drift自動生成ファイル。編集不要（ディレクトリ構造セクションに既出）。

### main.dart

- 役割: アプリケーションのエントリーポイント。
  - WidgetsFlutterBinding初期化
  - 辞書DBコピー（DatabaseInitializer.ensureDictionaryCopied）
  - AppDatabaseインスタンス取得
  - 単語帳初期データ投入（insertManualVocabularies）
  - `ProviderScope(child: EnglishLearningApp())`の起動
