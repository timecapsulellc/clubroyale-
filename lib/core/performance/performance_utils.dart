// Performance Optimization Utilities
//
// These utilities help reduce unnecessary rebuilds and
// optimize render performance across the app.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Memoized widget builder - only rebuilds when dependencies change
class MemoizedBuilder<T> extends StatefulWidget {
  final T value;
  final Widget Function(BuildContext context, T value) builder;

  const MemoizedBuilder({
    super.key,
    required this.value,
    required this.builder,
  });

  @override
  State<MemoizedBuilder<T>> createState() => _MemoizedBuilderState<T>();
}

class _MemoizedBuilderState<T> extends State<MemoizedBuilder<T>> {
  late Widget _cachedWidget;
  late T _cachedValue;

  @override
  void initState() {
    super.initState();
    _cachedValue = widget.value;
    _cachedWidget = widget.builder(context, widget.value);
  }

  @override
  void didUpdateWidget(MemoizedBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _cachedValue) {
      _cachedValue = widget.value;
      _cachedWidget = widget.builder(context, widget.value);
    }
  }

  @override
  Widget build(BuildContext context) => _cachedWidget;
}

/// Debounced callback to prevent rapid-fire events
class DebouncedAction {
  final Duration delay;
  Timer? _timer;

  DebouncedAction({this.delay = const Duration(milliseconds: 300)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttled callback - executes at most once per interval
class ThrottledAction {
  final Duration interval;
  DateTime? _lastExecution;

  ThrottledAction({this.interval = const Duration(milliseconds: 100)});

  void call(VoidCallback action) {
    final now = DateTime.now();
    if (_lastExecution == null ||
        now.difference(_lastExecution!) >= interval) {
      _lastExecution = now;
      action();
    }
  }
}

/// Lazy initialization for heavy objects
class Lazy<T> {
  T? _value;
  final T Function() _factory;

  Lazy(this._factory);

  T get value => _value ??= _factory();

  bool get isInitialized => _value != null;

  void reset() => _value = null;
}

/// Performance monitoring widget (debug only)
class PerformanceOverlay extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const PerformanceOverlay({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    return Stack(
      children: [
        child,
        if (kDebugMode)
          const Positioned(
            top: 50,
            right: 10,
            child: _RebuildIndicator(),
          ),
      ],
    );
  }
}

class _RebuildIndicator extends StatefulWidget {
  const _RebuildIndicator();

  @override
  State<_RebuildIndicator> createState() => _RebuildIndicatorState();
}

class _RebuildIndicatorState extends State<_RebuildIndicator> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Rebuilds: $_buildCount',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

/// RepaintBoundary wrapper for isolating expensive content
class IsolatedRepaint extends StatelessWidget {
  final Widget child;

  const IsolatedRepaint({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: child);
  }
}

/// Selector builder - rebuilds only when selected value changes
class SelectBuilder<T, S> extends StatefulWidget {
  final T data;
  final S Function(T data) selector;
  final Widget Function(BuildContext context, S selectedValue) builder;

  const SelectBuilder({
    super.key,
    required this.data,
    required this.selector,
    required this.builder,
  });

  @override
  State<SelectBuilder<T, S>> createState() => _SelectBuilderState<T, S>();
}

class _SelectBuilderState<T, S> extends State<SelectBuilder<T, S>> {
  late S _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selector(widget.data);
  }

  @override
  void didUpdateWidget(SelectBuilder<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.selector(widget.data);
    if (newValue != _selectedValue) {
      _selectedValue = newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selectedValue);
  }
}

/// Cached network image placeholder (use with cached_network_image package)
Widget cachedImagePlaceholder() {
  return Container(
    color: Colors.grey[900],
    child: const Center(
      child: Icon(Icons.image, color: Colors.grey, size: 32),
    ),
  );
}

/// Deferred content loader - delays heavy content until after first frame
class DeferredLoader extends StatefulWidget {
  final Widget placeholder;
  final Widget Function() builder;
  final Duration delay;

  const DeferredLoader({
    super.key,
    required this.placeholder,
    required this.builder,
    this.delay = Duration.zero,
  });

  @override
  State<DeferredLoader> createState() => _DeferredLoaderState();
}

class _DeferredLoaderState extends State<DeferredLoader> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.delay == Duration.zero) {
        if (mounted) setState(() => _loaded = true);
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) setState(() => _loaded = true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loaded ? widget.builder() : widget.placeholder;
  }
}

/// Widget size calculator (useful for responsive layouts)
class SizeReporter extends StatelessWidget {
  final Widget child;
  final void Function(Size size) onSizeChanged;

  const SizeReporter({
    super.key,
    required this.child,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onSizeChanged(Size(constraints.maxWidth, constraints.maxHeight));
        });
        return child;
      },
    );
  }
}
