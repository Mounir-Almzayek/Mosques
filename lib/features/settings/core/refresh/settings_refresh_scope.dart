import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsRefreshDelegate {
  final String id;
  final String label;
  final bool Function() hasUnsavedChanges;
  final Future<void> Function() save;
  final void Function() discard;

  const SettingsRefreshDelegate({
    required this.id,
    required this.label,
    required this.hasUnsavedChanges,
    required this.save,
    required this.discard,
  });
}

class SettingsRefreshRegistry extends ChangeNotifier {
  final Map<String, SettingsRefreshDelegate> _delegates = {};

  List<SettingsRefreshDelegate> get dirtyDelegates => _delegates.values
      .where((delegate) => delegate.hasUnsavedChanges())
      .toList(growable: false);

  void register(SettingsRefreshDelegate delegate) {
    _delegates[delegate.id] = delegate;
  }

  void unregister(String id) {
    _delegates.remove(id);
  }

  Future<void> saveDirty() async {
    for (final delegate in dirtyDelegates) {
      await delegate.save();
    }
  }

  void discardDirty() {
    for (final delegate in dirtyDelegates) {
      delegate.discard();
    }
  }
}

class SettingsRefreshScope extends InheritedWidget {
  final SettingsRefreshRegistry registry;

  const SettingsRefreshScope({
    super.key,
    required this.registry,
    required super.child,
  });

  static SettingsRefreshRegistry of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SettingsRefreshScope>();
    assert(scope != null, 'SettingsRefreshScope was not found.');
    return scope!.registry;
  }

  @override
  bool updateShouldNotify(SettingsRefreshScope oldWidget) =>
      registry != oldWidget.registry;
}

class SettingsRefreshRegistrar<B extends BlocBase<S>, S>
    extends StatefulWidget {
  final String id;
  final String label;
  final bool Function(S state) hasUnsavedChanges;
  final bool Function(S state) isSaving;
  final String? Function(S state) error;
  final void Function(B bloc) save;
  final void Function(B bloc) discard;
  final Widget child;

  const SettingsRefreshRegistrar({
    super.key,
    required this.id,
    required this.label,
    required this.hasUnsavedChanges,
    required this.isSaving,
    required this.error,
    required this.save,
    required this.discard,
    required this.child,
  });

  @override
  State<SettingsRefreshRegistrar<B, S>> createState() =>
      _SettingsRefreshRegistrarState<B, S>();
}

class _SettingsRefreshRegistrarState<B extends BlocBase<S>, S>
    extends State<SettingsRefreshRegistrar<B, S>> {
  SettingsRefreshRegistry? _registry;
  B? _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = SettingsRefreshScope.of(context);
    final bloc = context.read<B>();
    if (_registry == registry && _bloc == bloc) return;
    _registry?.unregister(widget.id);
    _registry = registry;
    _bloc = bloc;
    _registry!.register(
      SettingsRefreshDelegate(
        id: widget.id,
        label: widget.label,
        hasUnsavedChanges: () => widget.hasUnsavedChanges(_bloc!.state),
        save: () => _saveAndWait(_bloc!),
        discard: () => widget.discard(_bloc!),
      ),
    );
  }

  Future<void> _saveAndWait(B bloc) async {
    if (!widget.hasUnsavedChanges(bloc.state)) return;
    widget.save(bloc);
    final result = await bloc.stream
        .firstWhere((state) {
          final error = widget.error(state);
          if (error != null) return true;
          return !widget.isSaving(state) && !widget.hasUnsavedChanges(state);
        })
        .timeout(const Duration(seconds: 20));

    final error = widget.error(result);
    if (error != null) throw Exception(error);
  }

  @override
  void didUpdateWidget(covariant SettingsRefreshRegistrar<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registry?.unregister(oldWidget.id);
    final bloc = _bloc;
    if (bloc == null) return;
    _registry?.register(
      SettingsRefreshDelegate(
        id: widget.id,
        label: widget.label,
        hasUnsavedChanges: () => widget.hasUnsavedChanges(bloc.state),
        save: () => _saveAndWait(bloc),
        discard: () => widget.discard(bloc),
      ),
    );
  }

  @override
  void dispose() {
    _registry?.unregister(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
