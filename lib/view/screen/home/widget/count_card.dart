// count_card.dart

import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';


import '../../../../utils/dimension.dart';
import '../../../../utils/style.dart';

class CountCard extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String? value;
  final double height;

  const CountCard({
    Key? key,
    required this.backgroundColor,
    required this.title,
    required this.value,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          value != null
              ? AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: robotoBold.copyWith(fontSize: 36, color: Colors.white),
            child: Text(
              value!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
              : Shimmer(
            duration: const Duration(seconds: 2),
            enabled: value == null,
            color: Colors.grey[500]!,
            child: Container(
              height: 50,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Colors.white,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}