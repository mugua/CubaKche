import 'package:flutter/material.dart';

import '../../services/index.dart';

class CartScreen extends StatefulWidget {
  final bool isModal;
  final bool isBuyNow;

  CartScreen({this.isModal, this.isBuyNow = false});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Services().widget.renderCartPageView(
          isModal: widget.isModal,
          isBuyNow: widget.isBuyNow,
          pageController: pageController,
          context: context),
    );
  }
}
