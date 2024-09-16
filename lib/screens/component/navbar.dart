import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wallzify/colors.dart';
import 'package:wallzify/var.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

enum BtnType { write, upload }

class NavBar extends StatefulWidget {
  List<ScrollController> scontrollers;
  Function switchBranch;
  NavBar({super.key, required this.scontrollers, required this.switchBranch});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with TickerProviderStateMixin {
  bool _showContainer = false;
  late final AnimationController _controller;
  late final AnimationController _navcontroller;
  late Animation<double> animation;

  void changeVisibility() {
    if (!_controller.isCompleted) {
      setState(() => _showContainer = !_showContainer);
      _controller.forward();
    } else {
      _controller
          .reverse()
          .then((value) => setState(() => _showContainer = !_showContainer));
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _navcontroller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    animation = CurvedAnimation(
      parent: _navcontroller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeIn,
    );
    for (ScrollController controller in widget.scontrollers) {
      listners(controller: controller);
    }
    super.initState();
    Provider.of<CurrentPage>(context, listen: false).addListener(
      () {
        _controller.reset();
        _navcontroller.reset();
      },
    );
  }

  void listners({required ScrollController controller}) {
    controller.addListener(
      () {
        if (controller.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_controller.isCompleted) {
            _controller.reverse().then(
                (value) => setState(() => _showContainer = !_showContainer));
          }
          _navcontroller.forward();
        } else {
          _navcontroller.reverse();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedBuilder(
            animation: _navcontroller,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, (animation.value * 100)),
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints(maxWidth: 600, minHeight: 65),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BlurContainer(
                  callback: changeVisibility,
                  switchBranch: widget.switchBranch,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlurContainer extends StatelessWidget {
  VoidCallback callback;
  Function switchBranch;

  BlurContainer({
    super.key,
    required this.callback,
    required this.switchBranch,
  });

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CurrentPage>(context);
    final List<String> icons = [
      'home',
      'category',
      'fav',
    ];
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadiusDirectional.vertical(
            top: Radius.circular(22),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              constraints: const BoxConstraints(maxWidth: 600, minHeight: 65),
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: BoxDecoration(
                color: WallzifyColors.black.withOpacity(0.3),
                borderRadius: const BorderRadiusDirectional.vertical(
                  top: Radius.circular(22),
                ),
                border: Border.all(
                  color: WallzifyColors.white.withOpacity(0),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            icons.length,
            (index) => GestureDetector(
              onTap: () {
                switchBranch(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                constraints: const BoxConstraints(maxWidth: 600),
                margin: const EdgeInsets.only(
                  bottom: 5,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (state.pageIndex == index)
                      ? Colors.white
                      : Colors.white.withOpacity(0),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: (state.pageIndex == index)
                          ? WallzifyColors.white.withOpacity(0.3)
                          : Colors.black38.withOpacity(0),
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: SvgPicture.asset(
                  height: 20,
                  color: (state.pageIndex == index)
                      ? WallzifyColors.grey
                      : WallzifyColors.white,
                  'assets/icons/${icons[index]}.svg',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
