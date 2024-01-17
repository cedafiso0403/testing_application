import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.onTap,
    required this.tabTitles,
    required this.tabColors,
    this.titleHorizontalPadding,
    this.titleVerticalPadding,
    required this.chips,
  });

  final ValueChanged<int> onTap;
  final List<String> tabTitles;
  final List<Color> tabColors;
  final Widget chips;

  final double? titleHorizontalPadding;
  final double? titleVerticalPadding;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _opacityController;
  int selected = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 300,
      ),
      vsync: this,
    );
    _opacityController = AnimationController(
      duration: const Duration(
        milliseconds: 800,
      ),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeTabSelection(
      onTap: widget.onTap,
      tabTitles: widget.tabTitles,
      tabColors: widget.tabColors,
      animationController: _animationController,
      opacityController: _opacityController,
      titleHorizontalPadding: widget.titleHorizontalPadding,
      titleVerticalPadding: widget.titleVerticalPadding,
      chips: widget.chips,
    );
  }
}

class HomeTabSelection extends MultiChildRenderObjectWidget {
  final ValueChanged<int> onTap;

  final List<String> tabTitles;
  final List<Color> tabColors;
  final AnimationController? animationController;
  final Widget chips;
  final AnimationController? opacityController;
  final double? titleHorizontalPadding;
  final double? titleVerticalPadding;
  HomeTabSelection({
    Key? key,
    required this.onTap,
    required this.tabTitles,
    required this.tabColors,
    this.titleHorizontalPadding,
    this.titleVerticalPadding,
    this.animationController,
    this.opacityController,
    required this.chips,
  })  : assert(
          tabTitles.length == tabColors.length,
          'The number of tab titles and tab colors must be the same',
        ),
        super(key: key, children: [chips]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _HomeTabSelectionRenderObject(
      onTap: onTap,
      tabTitles: tabTitles,
      tabColors: tabColors,
      textDirection: Directionality.of(context),
      animationController: animationController,
      opacityController: opacityController,
      buildContext: context,
      titleHorizontalPadding: titleHorizontalPadding != null
          ? (titleHorizontalPadding! < 0
              ? 0
              : titleHorizontalPadding! > 1
                  ? 1
                  : titleHorizontalPadding)
          : null,
      titleVerticalPadding: titleVerticalPadding != null
          ? (titleVerticalPadding! < 0
              ? 0
              : titleVerticalPadding! > 1
                  ? 1
                  : titleVerticalPadding)
          : null,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _HomeTabSelectionRenderObject renderObject) {
    renderObject
      ..selected = renderObject.tabTitles.length != tabTitles.length
          ? 0
          : renderObject.selected
      ..onTap = onTap
      ..tabTitles = tabTitles
      ..tabColors = tabColors;
  }
}

class _HomeTab extends ContainerBoxParentData<RenderBox>
    with ContainerParentDataMixin<RenderBox> {}

class _HomeTabSelectionRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _HomeTab>,
        RenderBoxContainerDefaultsMixin<RenderBox, _HomeTab> {
  _HomeTabSelectionRenderObject({
    required ValueChanged<int> onTap,
    required List<String> tabTitles,
    required List<Color> tabColors,
    required TextDirection textDirection,
    required BuildContext buildContext,
    AnimationController? animationController,
    AnimationController? opacityController,
    double? titleHorizontalPadding,
    double? titleVerticalPadding,
  })  : _onTap = onTap,
        _tabTitles = tabTitles,
        _tabColors = tabColors,
        _textDirection = textDirection,
        _buildContext = buildContext,
        _animationController = animationController,
        _opacityController = opacityController,
        _titleHorizontalPadding = titleHorizontalPadding,
        _titleVerticalPadding = titleVerticalPadding {
    if (_animationController != null) {
      _colorAnimationArea = ColorTween(
        begin: _tabColors[_selected],
        end: _tabColors[_selected],
      ).animate(
        _animationController!,
      );
      _colorAnimationSelectTab = ColorTween(
        begin: _tabColors[_selected],
        end: _tabColors[_selected],
      ).animate(
        _animationController!,
      );
      _expansionAnimation = hasSize
          ? SizeTween(
              begin: Size(
                constraints.maxWidth,
                size.height,
              ),
              end: Size(
                constraints.maxWidth,
                size.height,
              ),
            ).animate(
              _animationController!,
            )
          : null;
    }

    if (_opacityController != null) {
      _opacityAnimation = Tween<double>(
        begin: 255,
        end: 255,
      ).animate(
        _opacityController!,
      );
    }
  }

  final AnimationController? _animationController;

  final AnimationController? _opacityController;
  bool needUpdate = false;

  late Animation<Color?> _colorAnimationArea;
  late Animation<Color?> _colorAnimationSelectTab;
  late Animation<Size?>? _expansionAnimation;
  late Animation<double?> _opacityAnimation;
  final BuildContext _buildContext;

  TextDirection _textDirection;

  int _selected = 0;

  ValueChanged<int> _onTap;

  List<String> _tabTitles;
  List<Color> _tabColors;
  double? _titleHorizontalPadding;
  double? _titleVerticalPadding;
  ValueChanged<int> get onTap => _onTap;

  double? get titleVerticalPadding => _titleVerticalPadding;

  double? get titleHorizontalPadding => _titleHorizontalPadding;

  set titleVerticalPadding(double? value) {
    if (_titleVerticalPadding == value) {
      return;
    }
    _titleVerticalPadding = value;
    markNeedsPaint();
  }

  set titleHorizontalPadding(double? value) {
    if (_titleHorizontalPadding == value) {
      return;
    }
    _titleHorizontalPadding = value;
    markNeedsPaint();
  }

  set onTap(ValueChanged<int> value) {
    if (_onTap == value) {
      return;
    }
    _onTap = value;
  }

  int get selected => _selected;
  set selected(int value) {
    if (_selected == value) {
      return;
    }
    _selected = value;
    needUpdate = true;
    if (_animationController != null) {
      _animationController?.reset();
      _colorAnimationArea = ColorTween(
        begin: _tabColors[_selected],
        end: _tabColors[value],
      ).animate(
        _animationController!,
      );

      _colorAnimationSelectTab = ColorTween(
        begin: const Color.fromARGB(255, 229, 229, 229),
        end: _tabColors[value],
      ).animate(
        _animationController!,
      );
      _animationController?.forward();
    }
    if (_opacityController != null) {
      _opacityController?.reset();
      _opacityAnimation = Tween<double>(
        begin: 0,
        end: 255,
      ).animate(
        _opacityController!,
      );
      _opacityController?.forward();
    }
  }

  List<Color> get tabColors => _tabColors;
  set tabColors(List<Color> value) {
    if (_tabColors == value) {
      return;
    }
    _tabColors = value;
    markNeedsPaint();
  }

  List<String> get tabTitles => _tabTitles;
  set tabTitles(List<String> value) {
    if (_tabTitles == value) {
      return;
    }
    _tabTitles = value;
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value ?? TextDirection.ltr;
    markNeedsPaint();
  }

  double get _tabGap => hasSize && _tabTitles.length > 1
      ? ((size.width) * 0.05) / (_tabTitles.length - 1)
      : 0;

  double get _tabHeight {
    return _textHeight * 1.75;
  }

  double get _tabWidth => hasSize ? (size.width * 0.95) / _tabTitles.length : 0;
  double get _textHeight {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    double textHeight = 0.0;
    for (var i = 0; i < _tabTitles.length; i++) {
      textPainter.text = TextSpan(
        text: _tabTitles[i],
        style: Theme.of(_buildContext).textTheme.titleMedium?.apply(
              fontWeightDelta: -1,
            ),
      );

      textPainter.layout();

      final textMetrics = textPainter.computeLineMetrics();
      textHeight = max(textHeight, textMetrics.last.height);
    }
    return textHeight;
  }

  void _drawTab(int index, Offset offset, bool isSelected, Path shadowPath,
      Canvas canvas) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final tabsPainter = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    textPainter.text = TextSpan(
      text: _tabTitles[index],
      style: Theme.of(_buildContext).textTheme.titleMedium?.apply(
            fontWeightDelta: -1,
          ),
    );

    tabsPainter.color = isSelected
        ? _colorAnimationSelectTab.value ?? _tabColors[index]
        : const Color.fromARGB(255, 229, 229, 229);

    final rectTab = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        offset.dx + (index * _tabWidth) + (index * _tabGap),
        offset.dy,
        _tabWidth,
        _tabHeight,
      ),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );

    if (isSelected) {
      shadowPath
        ..addRRect(rectTab.inflate(2.5))
        ..close();

      canvas.drawShadow(
        shadowPath,
        Theme.of(_buildContext).colorScheme.shadow,
        10,
        true,
      );
    }

    canvas.drawRRect(rectTab, tabsPainter);

    textPainter.ellipsis = '...';
    textPainter.maxLines = 1;
    textPainter.layout(maxWidth: 75);

    textPainter.layout(
      maxWidth: _tabWidth * 0.9,
    );

    textPainter.paint(
      canvas,
      Offset(
        offset.dx +
            (index * _tabWidth) +
            (index * _tabGap) +
            (_tabWidth - textPainter.width) / 2,
        offset.dy + (_tabHeight - _textHeight) / 2,
      ),
    );
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerUpEvent) {
      // Calculate the tapped tab index based on the position
      int tappedIndex =
          ((event.localPosition.dx / size.width) * _tabTitles.length).floor();
      if (tappedIndex >= 0 && tappedIndex < _tabTitles.length) {
        // Check if the event is outside the area reserved for the tabs
        if (event.localPosition.dy <= _tabHeight) {
          // Handle the tab selection
          _onTap(tappedIndex);
          selected = tappedIndex;
        }
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    double previousWidth = size.width * 0.05;

    for (final element in getChildrenAsList()) {
      // Calculate the hit testing position for each child
      final childOffset = position.translate(
        -(previousWidth),
        -_tabHeight * 1.20,
      );

      // Check if the hit test position is within the bounds of the current element
      if (childOffset.dx >= 0 &&
          childOffset.dx <= element.size.width &&
          childOffset.dy >= 0 &&
          childOffset.dy <= element.size.height) {
        // Add the current element to the hit test result

        element.hitTest(
          result,
          position: childOffset,
        );
      }

      // Update previousWidth with the width of the current element
      previousWidth += element.size.width;
    }

    return true; // Indicate that hit testing is handled
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    final areaContainerPainter = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final Rect areaContainer = Rect.fromLTWH(
      offset.dx,
      offset.dy + _tabHeight,
      size.width,
      size.height - _tabHeight,
    );

    final shadowPath = Path()
      ..addRect(
        Rect.fromLTWH(
          areaContainer.left,
          areaContainer.top - 10,
          areaContainer.width,
          areaContainer.height - 10,
        ),
      );

    for (var i = 0; i < _tabTitles.length; i++) {
      if (_selected != i) {
        _drawTab(i, offset, false, shadowPath, canvas);
      }
    }

    if (_tabTitles.isNotEmpty && _tabTitles.length > 1) {
      _drawTab(_selected, offset, true, shadowPath, canvas);
    }

    areaContainerPainter.color =
        _colorAnimationArea.value ?? _tabColors[_selected];

    canvas.drawRect(areaContainer, areaContainerPainter);

    getChildrenAsList().forEach(
      (element) {
        context.pushOpacity(
          offset,
          (_opacityAnimation.value ?? 255).toInt(),
          (context, offset) {
            context.paintChild(
              element,
              offset.translate(
                (size.width - element.size.width) / 2,
                _tabHeight + element.size.height * 0.1,
              ),
            );
          },
        );
      },
    );
  }

  @override
  void performLayout() {
    final previousSize = hasSize ? size.height : null;

    final childSize = childCount > 0
        ? ChildLayoutHelper.layoutChild(
            firstChild!,
            constraints,
          )
        : Size.zero;

    if (needUpdate && hasSize && _animationController != null) {
      _expansionAnimation = SizeTween(
        begin: Size(
          constraints.maxWidth,
          previousSize!,
        ),
        end: Size(
          constraints.maxWidth,
          childSize.height * 1.20 + _tabHeight,
        ),
      ).animate(
        _animationController!,
      );

      _expansionAnimation!.addListener(
        markNeedsLayout,
      );

      needUpdate = false;
    }

    size = constraints.constrain(
      !hasSize
          ? Size(
              constraints.maxWidth,
              childSize.height * 1.20 + _tabHeight,
            )
          : (_expansionAnimation?.status == AnimationStatus.completed ||
                  _expansionAnimation?.status == null
              ? Size(
                  constraints.maxWidth,
                  childSize.height * 1.20 + _tabHeight,
                )
              : (_expansionAnimation?.value ?? size)),
    );
  }

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = _HomeTab();
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _animationController?.addListener(
      markNeedsPaint,
    );
    _opacityController?.addListener(
      markNeedsPaint,
    );
  }

  @override
  void detach() {
    _animationController?.removeListener(
      markNeedsPaint,
    );
    _opacityController?.removeListener(
      markNeedsPaint,
    );
    super.detach();
  }

  @override
  void dispose() {
    _animationController?.removeListener(
      markNeedsPaint,
    );
    _opacityController?.removeListener(
      markNeedsPaint,
    );
    super.dispose();
  }
}
