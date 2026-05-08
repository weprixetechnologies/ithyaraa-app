import 'package:flutter/material.dart';

class RollingText extends StatefulWidget {
  final String text1;
  final String text2;
  final double height;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final Duration duration;

  const RollingText({
    super.key,
    required this.text1,
    required this.text2,
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.textStyle,
    this.duration = const Duration(seconds: 60),
  });

  @override
  State<RollingText> createState() => _RollingTextState();
}

class _RollingTextState extends State<RollingText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    if (!_scrollController.hasClients) return;
    
    // Smoothly wait for the list to be rendered and measured
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      // If no scroll is possible yet, try again later
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _startScrolling();
      return;
    }

    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.9) {
      _scrollController.jumpTo(0);
    }

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: widget.duration,
      curve: Curves.linear,
    );
    
    if (mounted) _startScrolling();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.textStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        );

    final item = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(widget.text1, style: style),
          const SizedBox(width: 20),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle)),
          const SizedBox(width: 20),
          Text(widget.text2, style: style),
          const SizedBox(width: 20),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle)),
        ],
      ),
    );

    return Container(
      height: widget.height,
      color: widget.backgroundColor,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 100, // Large enough to fill and scroll, but not infinite to avoid engine confusion
        itemBuilder: (context, index) => item,
      ),
    );
  }
}
