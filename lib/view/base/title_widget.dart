
import 'package:flutter/material.dart';

import '../../utils/dimension.dart';
import '../../utils/style.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final int? orderCount;

  const TitleWidget({
    Key? key,
    required this.title,
    this.onTap,
    this.orderCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Title text
        Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),

        /// View all + badge
        if (onTap != null)
          InkWell(
            onTap: onTap as void Function()?,
            borderRadius: BorderRadius.circular(6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'View All',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault, // bigger
                    fontWeight: FontWeight.w600, // bolder
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),

                /// Badge with order count
                if (orderCount != null)
                  Container(
                    margin: const EdgeInsets.only(left: 4), // closer
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      orderCount.toString(),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault, // bigger
                        fontWeight: FontWeight.bold, // bold
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
