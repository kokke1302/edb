// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RegisterNotifier)
final registerProvider = RegisterNotifierProvider._();

final class RegisterNotifierProvider
    extends $AsyncNotifierProvider<RegisterNotifier, VocabCore> {
  RegisterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerNotifierHash();

  @$internal
  @override
  RegisterNotifier create() => RegisterNotifier();
}

String _$registerNotifierHash() => r'92d6baba68c244289bf3df74ea763550105c92fd';

abstract class _$RegisterNotifier extends $AsyncNotifier<VocabCore> {
  FutureOr<VocabCore> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<VocabCore>, VocabCore>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VocabCore>, VocabCore>,
              AsyncValue<VocabCore>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
