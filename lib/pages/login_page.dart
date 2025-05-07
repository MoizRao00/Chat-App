import 'package:chatapp/components/my_button.dart';
import 'package:chatapp/components/my_textfield.dart';
import 'package:flutter/material.dart';


import '../services/auth/auth_service.dart';

class LoginPage extends StatelessWidget {

  //email and password controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // to go to register page
  final void Function()? onTap;

  LoginPage({
    super.key,
    required this.onTap
  });

  //login method
  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();
    //try login
    try{
      await authService.signInWithEmailPassword(_emailController.text, _passwordController.text);
    }
    //catch any errors
    catch (e) {
      showDialog(context: context, builder: (context)=> AlertDialog(
        title: Text(e.toString()),
      ),
      );
    }
    

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),

            //Welcome Back Message

            const SizedBox(
              height: 50,
            ),

            Text(
              "Welcome Back, You Have Been Missed!!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            //email textifield
            MyTextField(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),

            const SizedBox(
              height: 10,
            ),

            // pw textified

            MyTextField(
              hintText: "Password",
              obscureText: true,
              controller: _passwordController,
            ),

            const SizedBox(
              height: 25,
            ),
            // login botton
            MyButton(text: "Login", onTap: () => login(context)),

            // register now
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a Member? ",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Register Now",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
