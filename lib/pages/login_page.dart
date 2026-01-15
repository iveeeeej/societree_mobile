import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:societree_mobile/reusables/button.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:basictools/reusables/button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();

  // Future<void> logIn() async {
  // try {
  //   await FirebaseAuth.instance.signInWithEmailAndPassword(
  //     email: _emailController.text.trim(),
  //     password: _passwordController.text.trim(),
  //   );
  //   // Navigate to home page if successful
  //   Get.offNamed('/home');
  // } on FirebaseAuthException catch (e) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(e.message ?? "Error Login")),
  //   );
  //   }
  // }

  // @override
  // void dispose() {
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                Container(
                  height: 300,
                  width: 300,
                  child: Image.asset(
                    'assets/org_logos/societree_transparent.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Text(
                      'LOGIN',
                      style: GoogleFonts.oswald(
                        color: Color(0xFF2e2a2b),
                        fontSize: 35,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
            
                SizedBox(
                  height: 20,
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    child: TextField(
                      //controller: _emailController,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8bc53f),
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8bc53f)
                          ),
                        ),
                        prefixIcon: Icon(Icons.assignment_ind),
                        hintText: 'ID Number'
                      ),
                    ),
                  ),
                ),
            
                SizedBox(
                  height: 10,
                ),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    child: TextField(
                      //controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8bc53f),
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8bc53f)
                          ),
                        ),
                        prefixIcon: Icon(Icons.lock),
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
            
                SizedBox(
                  height: 25,
                ),
            
                // SizedBox(
                //   height: 50,
                //   width: 350,
                //     child: GestureDetector(
                //       onTap: logIn,
                //       child: myButton(context, 'LOGIN', (){
                //         logIn();
                //       },
                //       style: ElevatedButton.styleFrom(
                //       backgroundColor: Color(0xFF2e2a2b),
                //       foregroundColor: Color(0xFFffffff),
                //       )
                //       ),
                //     ),
                //   //),
                // ),

                SizedBox(
                  height: 50,
                  width: 350,
                  child: myButton(context, 'LOGIN', (){
                    Get.toNamed('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8bc53f),
                    foregroundColor: Color(0xFFffffff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1)
                    )
                  )
                  ),
                ),
            
                SizedBox(
                  height: 15,
                ),

                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.oswald(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            //Get.toNamed('/signup');
                          },
                        ),
                      ),
                    ],
                  ),
                )
            
              ],
            ),
          ),
        ),
      )
    );
  }
}