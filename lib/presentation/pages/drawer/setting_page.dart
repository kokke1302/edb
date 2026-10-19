import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:edb/domain/model/value_object/setting_data.dart';
import 'package:edb/presentation/view_models/setting_notifier.dart';

class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 保存済みの設定
    final saved = ref.watch(settingsProvider);

    // シングルトン
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // 編集中の値（保存するまで反映されない）
    final urlController = useTextEditingController(text: saved.apiUrl);
    final useTranslation = useState(saved.useTranslationApi);
    final useDictionary = useState(saved.useDictionaryApi);
    final isSaving = useState(false);

    // URLの入力のたびに再描画する
    useListenable(urlController);

    // 現在の入力値を正規化
    final currentInputUrl = SettingData.normalizeUrl(urlController.text);

    // URLが空欄になったら自動的にSwitchをOFFにする
    useEffect(() {
      if (currentInputUrl.isEmpty) {
        useTranslation.value = false;
        useDictionary.value = false;
      }
      return null;
    }, [currentInputUrl]);

    // 差分（変更があるか）の判定
    final isDirty =
        currentInputUrl != saved.apiUrl ||
        useTranslation.value != saved.useTranslationApi ||
        useDictionary.value != saved.useDictionaryApi;

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;

      final messenger = ScaffoldMessenger.of(context);
      isSaving.value = true;
      try {
        await ref
            .read(settingsProvider.notifier)
            .save(
              settings: SettingData(
                apiUrl: currentInputUrl,
                useTranslationApi: useTranslation.value,
                useDictionaryApi: useDictionary.value,
              ),
            );
        if (!context.mounted) return;

        // 末尾の「/」などを取り除いた、保存後の表記に揃える
        urlController.text = currentInputUrl;
        messenger.showSnackBar(const SnackBar(content: Text('API設定を保存しました')));
      } catch (e) {
        if (!context.mounted) return;
        messenger.showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
      } finally {
        if (context.mounted) isSaving.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: urlController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'API URL',
                  hintText: 'https://example.com',
                  helperText: '空欄のときは、翻訳も辞書もAPIを使用しません',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final url = SettingData.normalizeUrl(value ?? '');
                  if (url.isEmpty) return null;
                  return SettingData.isValidUrl(url)
                      ? null
                      : 'http:// または https:// から始まるURLを入力してください';
                },
              ),
              if (kIsWeb && currentInputUrl.startsWith('http://'))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '※ httpのURLはブラウザにブロックされることがあります。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('翻訳でAPIを使用する'),
                subtitle: const Text(
                  '再翻訳ボタンの翻訳をAPIに任せます。通信に失敗したときは端末内の処理に切り替わります。',
                ),
                // URLが空の場合は強制的にfalseにする
                value: currentInputUrl.isNotEmpty && useTranslation.value,
                onChanged: currentInputUrl.isEmpty
                    ? null // URLが空ならスイッチを無効化
                    : (value) => useTranslation.value = value,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('辞書でAPIを使用する'),
                subtitle: const Text(
                  '辞書機能シートの候補をAPIから取得します。通信に失敗したときは内部辞書を使います。',
                ),
                // URLが空の場合は強制的にfalseにする
                value: currentInputUrl.isNotEmpty && useDictionary.value,
                onChanged: currentInputUrl.isEmpty
                    ? null // URLが空ならスイッチを無効化
                    : (value) => useDictionary.value = value,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: isDirty && !isSaving.value ? save : null,
                icon: const Icon(Icons.save),
                label: Text(isSaving.value ? '保存中' : '保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
