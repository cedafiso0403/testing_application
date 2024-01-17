import 'package:flutter/material.dart';

class FSExpandableListCard extends StatefulWidget {
  final Widget? mainContent;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Widget? cardTitle;
  final EdgeInsets? padding;
  final EdgeInsets? paddingChildren;
  final EdgeInsets? cardMargin;
  final double? width;

  const FSExpandableListCard({
    super.key,
    this.padding,
    this.mainContent,
    this.initiallyExpanded = false,
    required this.children,
    this.paddingChildren,
    this.width,
    this.cardMargin,
    this.cardTitle,
  });

  @override
  _FSExpandableListCardState createState() => _FSExpandableListCardState();
}

class _FSExpandableListCardState extends State<FSExpandableListCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpansion() {
    setState(
      () {
        _isExpanded = !_isExpanded;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggleExpansion(),
      child: Card(
        margin: widget.cardMargin ?? EdgeInsets.zero,
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(0.0),
          child: Container(
            width: widget.width ?? double.infinity,
            child: Column(
              children: <Widget>[
                widget.cardTitle != null
                    ? Padding(
                        padding:
                            widget.paddingChildren ?? const EdgeInsets.all(0.0),
                        child: widget.cardTitle,
                      )
                    : SizedBox.shrink(),
                Padding(
                  padding: widget.paddingChildren ?? const EdgeInsets.all(0.0),
                  child: widget.mainContent ?? widget.children.first,
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 500),
                  firstChild:
                      Container(), // It provides the width of the expanded element, it has functionality
                  secondChild: SingleChildScrollView(
                    child: Column(
                      children: widget.children
                          .sublist(
                        widget.mainContent == null ? 1 : 0,
                      )
                          .map((item) {
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _isExpanded ? 1.0 : 0.0,
                          child: Padding(
                            padding: widget.paddingChildren ??
                                const EdgeInsets.all(0.0),
                            child: item,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FSTransitionCard extends StatefulWidget {
  final Widget? defaultContent;
  final Widget? expandedContent;
  final bool initiallyExpanded;
  final Widget? cardTitle;
  final EdgeInsets? padding;
  final EdgeInsets? paddingChildren;
  final EdgeInsets? cardMargin;

  const FSTransitionCard({
    super.key,
    this.padding,
    this.initiallyExpanded = false,
    this.paddingChildren,
    this.defaultContent,
    this.expandedContent,
    this.cardMargin,
    this.cardTitle,
  });

  @override
  _FSTransitionCardState createState() => _FSTransitionCardState();
}

class _FSTransitionCardState extends State<FSTransitionCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpansion() {
    setState(
      () {
        _isExpanded = !_isExpanded;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggleExpansion(),
      child: Card(
        margin: widget.cardMargin ?? EdgeInsets.zero,
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(0),
          child: Container(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                widget.cardTitle ?? SizedBox.shrink(),
                Container(
                  width: double.infinity,
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 500),
                    firstChild: Container(
                      width: double.infinity,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: _isExpanded ? 0.0 : 1.0,
                        child: Padding(
                          padding: widget.paddingChildren ??
                              const EdgeInsets.all(0.0),
                          child: widget.defaultContent ?? SizedBox.shrink(),
                        ),
                      ),
                    ),
                    secondChild: Container(
                      width: double.infinity,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: _isExpanded ? 1.0 : 0.0,
                        child: Padding(
                          padding: widget.paddingChildren ??
                              const EdgeInsets.all(0.0),
                          child: widget.expandedContent ?? SizedBox.shrink(),
                        ),
                      ),
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
