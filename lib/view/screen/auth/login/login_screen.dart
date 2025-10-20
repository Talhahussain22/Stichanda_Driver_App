import 'package:flutter/material.dart';
import 'package:stichanda_driver/view/base/custom_button.dart';
import 'package:stichanda_driver/view/base/custom_text_field.dart';
import 'package:stichanda_driver/view/screen/auth/signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {


  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;

  late TextEditingController passwordController;

  @override
  void initState() {
    emailController=TextEditingController();
    passwordController=TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Welcome back',style: TextStyle(color: Colors.grey.shade600,fontWeight: FontWeight.bold,fontSize: 35),),
          SizedBox(height: 10,),
          Text('Please enter your details to sign in',style: TextStyle(color: Colors.grey,fontSize:14),),
          const SizedBox(height: 30),
          CustomTextField(hintText: 'Enter your email',controller: emailController,keyboardType: TextInputType.emailAddress,),
          CustomTextField(hintText: 'Enter your password',obscureText: true,controller: passwordController,keyboardType: TextInputType.visiblePassword,),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: (){},
                  child: Text('Forgot Password?',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
            child: CustomButton(buttonText: 'Login', onPressed: (){}),
          ),
        ],
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?",style: TextStyle(color: Colors.grey.shade600),),
            SizedBox(width: 5,),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupScreen()));
              },
              child: Text('Sign Up',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
            )
          ],
        )
      ],
    );
  }
}
