import 'package:flutter/material.dart';

void main() {
  runApp(const EnglishLearningApp());
}

class EnglishLearningApp extends StatelessWidget {
  const EnglishLearningApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '英語学習支援アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Tailwind CSSの指示に合わせ、Interフォントを仮定
        useMaterial3: true, // Material Design 3を有効化
      ),
      home: const TranslationModeScreen(),
    );
  }
}

// 翻訳モード画面
class TranslationModeScreen extends StatefulWidget {
  const TranslationModeScreen({super.key});

  @override
  State<TranslationModeScreen> createState() => _TranslationModeScreenState();
}

class _TranslationModeScreenState extends State<TranslationModeScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  List<WordBlockData> _wordBlocks = [];

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
    super.dispose();
  }

  // テキストが変更されたときに単語を解析し、UIを更新
  void _onTextChanged() {
    setState(() {
      _wordBlocks = _parseTextAndGenerateWordBlocks(
        _textEditingController.text,
      );
    });
  }

  // ダミーの単語解析と訳語生成ロジック
  List<WordBlockData> _parseTextAndGenerateWordBlocks(String text) {
    if (text.isEmpty) {
      return [];
    }

    // スペースと主要な句読点で分割
    // 設計資料の「ハイフンやアポストロフィを含む単語は分割せず1つの単語として扱う」に対応するための正規表現
    final RegExp wordRegex = RegExp(r"(\b[\w'-]+\b|[.,!?;:'()\[\]])");
    final Iterable<RegExpMatch> matches = wordRegex.allMatches(text);

    List<WordBlockData> blocks = [];
    for (final match in matches) {
      final String token = match.group(0)!;
      final bool isWord = RegExp(
        r"[\p{L}\p{N}']",
        unicode: true,
      ).hasMatch(token); // 文字または数字、アポストロフィを含むか

      String displayWord = token;
      String? displayTranslation;

      if (isWord) {
        // ダミーの辞書連携
        displayTranslation = _getDummyTranslation(token.toLowerCase());
      }

      blocks.add(
        WordBlockData(
          word: displayWord,
          translation: displayTranslation,
          isWord: isWord,
        ),
      );
    }
    return blocks;
  }

  // ダミーの辞書機能
  String? _getDummyTranslation(String word) {
    // 設計資料の内部辞書と単語帳の概念を模擬
    final Map<String, String> dummyDictionary = {
      'i': '私',
      'have': '持っている',
      'a': '一つの',
      'pen': 'ペン',
      'please': 'どうぞ',
      'follow': 'ついてくる',
      'me': '私を',
      'or': 'または',
      'push': '押す',
    };
    return dummyDictionary[word];
  }

  // 辞書機能シートを表示する
  void _showVocabularyInputSheet(WordBlockData wordBlock) {
    if (!wordBlock.isWord) return; // 単語でない場合はシートを表示しない

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 全画面に近い高さで表示可能にする
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: VocabularyInputSheet(wordBlock: wordBlock),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text('翻訳モード'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                '保存済みの英文',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('履歴1: I have a pen.'),
              onTap: () {
                // TODO: 履歴タップ時の処理
                Navigator.pop(context); // ドロワーを閉じる
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () {
                // TODO: 設定画面への遷移
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('ヘルプ'),
              onTap: () {
                // TODO: ヘルプ画面への遷移
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          // 英文入力エリア
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textEditingController,
              maxLines: null, // 複数行を可能にする
              decoration: InputDecoration(
                hintText: 'タップでキーボードが起動します',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.all(16.0),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min, // アイコンの幅を最小限に
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _textEditingController.clear();
                      },
                      tooltip: 'クリア',
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_paste),
                      onPressed: () async {
                        // TODO: クリップボードからのペースト機能
                        _textEditingController.text =
                            'I have a pen. Please follow me.'; // ダミーのペースト
                      },
                      tooltip: 'ペースト',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 単語ブロック表示エリア
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0, // 単語ブロック間の水平方向のスペース
                runSpacing: 8.0, // 単語ブロック間の垂直方向のスペース
                children: _wordBlocks.map((wordBlock) {
                  return GestureDetector(
                    onTap: () => _showVocabularyInputSheet(wordBlock),
                    child: WordBlock(wordBlock: wordBlock),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 翻訳モードが選択されている状態
        onTap: (index) {
          if (index == 1) {
            // 単語帳モードへの遷移 (ここでは仮に画面遷移は行わない)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('単語帳モードへ切り替えます (未実装)')),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.translate), label: '翻訳モード'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '単語帳モード'),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'translate_fab',
            onPressed: () {
              _onTextChanged(); // 再解析と表示更新をトリガー
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('翻訳を開始します！')));
            },
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'save_fab',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('英文を保存します (未実装)')));
            },
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }
}

// 単語ブロックのデータモデル
class WordBlockData {
  final String word;
  final String? translation;
  final bool isWord;

  WordBlockData({required this.word, this.translation, required this.isWord});
}

// 単語ブロックのウィジェット
class WordBlock extends StatelessWidget {
  final WordBlockData wordBlock;

  const WordBlock({super.key, required this.wordBlock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: wordBlock.isWord ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: wordBlock.isWord ? Colors.blue.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            wordBlock.word,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          if (wordBlock.isWord &&
              wordBlock.translation != null &&
              wordBlock.translation!.isNotEmpty)
            Text(
              wordBlock.translation!,
              style: TextStyle(fontSize: 12.0, color: Colors.grey.shade700),
            ),
        ],
      ),
    );
  }
}

// 辞書機能シート（VocabularyInputSheet）
class VocabularyInputSheet extends StatefulWidget {
  final WordBlockData wordBlock;

  const VocabularyInputSheet({super.key, required this.wordBlock});

  @override
  State<VocabularyInputSheet> createState() => _VocabularyInputSheetState();
}

class _VocabularyInputSheetState extends State<VocabularyInputSheet> {
  bool _isShowTranslation = true; // 「訳を表示するかどうか」のダミーステート
  bool _isRegisteredToVocabulary = false; // 「単語帳へ登録済みかどうか」のダミーステート

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      // ボトムシートの高さを動的に調整するためにFlexibleを使用
      child: Column(
        mainAxisSize: MainAxisSize.min, // コンテンツの高さに合わせる
        children: [
          // 英単語表示部
          Text(
            widget.wordBlock.word,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 訳語表示セクション（ダミーデータ）
          _buildTranslationSection(context),
          const SizedBox(height: 20),

          // オリジナル訳語セクション
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // シートを閉じる
              // TODO: オリジナル登録フィールドへ遷移
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.wordBlock.word} のオリジナル訳語を登録/編集します (未実装)',
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('オリジナル', style: TextStyle(color: Colors.grey)),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // シートを閉じる
            },
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  // 訳語表示セクションを構築するヘルパーメソッド
  Widget _buildTranslationSection(BuildContext context) {
    // ダミーの訳語リスト
    List<Map<String, String>> dummyTranslations = [
      {'translation': widget.wordBlock.translation ?? '訳語なし', 'source': '内部辞書'},
      {'translation': 'ペン', 'source': '単語帳 (ユーザー登録)', 'memo': 'お気に入りの文具'},
      {'translation': '万年筆', 'source': '単語帳 (ユーザー登録)'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '訳語',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true, // コンテンツに合わせて高さを調整
          physics: const NeverScrollableScrollPhysics(), // ListView内部のスクロールを無効化
          itemCount: dummyTranslations.length,
          itemBuilder: (context, index) {
            final entry = dummyTranslations[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['translation']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (entry['memo'] != null)
                      Text(
                        'メモ: ${entry['memo']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ソース: ${entry['source']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Row(
                          children: [
                            const Text('訳を表示'),
                            Switch(
                              value: _isShowTranslation,
                              onChanged: (bool value) {
                                setState(() {
                                  _isShowTranslation = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${entry['translation']}の表示設定を${value ? "表示" : "非表示"}にしました (ダミー)',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Text('単語帳登録'),
                            Switch(
                              value: _isRegisteredToVocabulary,
                              onChanged: (bool value) {
                                setState(() {
                                  _isRegisteredToVocabulary = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${entry['translation']}を単語帳に${value ? "登録" : "解除"}しました (ダミー)',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
