import 'package:flutter/material.dart';

import '../../utils/dimension.dart';
import '../../utils/style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? actionWidget;
  const CustomAppBar({Key? key, required this.title, this.isBackButtonExist = true, this.onBackPressed, this.actionWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      leading: isBackButtonExist ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Theme.of(context).textTheme.bodyLarge!.color,
        onPressed: (){
          if(onBackPressed != null){
            onBackPressed!();
          }else if(Navigator.canPop(context)){
            Navigator.pop(context);
          }else{
            // Navigator.pushReplacementNamed(context, '/');
          }
        } ,
      ) : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          child: actionWidget ?? const SizedBox(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size(1170, 50);
}
