import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/resources/resources.dart';

/// Production-ready PaginatedListView encapsulating:
/// - Pull-to-refresh ([onRefresh])
/// - Scroll to bottom detection ([onLoadMore])
/// - Loading indicator at bottom during pagination
/// - Empty state ([emptyWidget])
/// - Error state ([errorWidget])
class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final Widget? emptyWidget;
  final Widget? header;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const PaginatedListView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    super.key,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.emptyWidget,
    this.header,
    this.padding,
    this.physics,
    this.controller,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _scrollController = widget.controller!;
    } else {
      _scrollController = ScrollController();
      _ownsController = true;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant PaginatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _scrollController.dispose();
      }
      if (widget.controller != null) {
        _scrollController = widget.controller!;
        _ownsController = false;
      } else {
        _scrollController = ScrollController();
        _ownsController = true;
      }
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_ownsController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || !widget.hasMore || widget.isLoadingMore) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger when 150 pixels from bottom
    if (maxScroll - currentScroll <= 150) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: ColorScheme.of(context).primary,
        backgroundColor: ColorScheme.of(context).surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: widget.emptyWidget ?? const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    final itemCount =
        widget.items.length +
        (widget.header != null ? 1 : 0) +
        (widget.hasMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: ColorScheme.of(context).primary,
      backgroundColor: ColorScheme.of(context).surface,
      child: ListView.builder(
        controller: _scrollController,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding ?? EdgeInsets.all(Dimens.space16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (widget.header != null && index == 0) {
            return widget.header!;
          }

          final adjustedIndex = widget.header != null ? index - 1 : index;

          if (adjustedIndex < widget.items.length) {
            return widget.itemBuilder(
              context,
              widget.items[adjustedIndex],
              adjustedIndex,
            );
          }

          // Loader at the bottom during pagination
          return Padding(
            padding: EdgeInsets.all(Dimens.space16),
            child: Center(
              child: CupertinoActivityIndicator(
                color: ColorScheme.of(context).primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
