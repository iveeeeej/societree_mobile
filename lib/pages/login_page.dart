import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:societree_mobile/components/button.dart';
import 'package:societree_mobile/components/qr_scanner.dart';
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
      backgroundColor: Color(0xFF8bc53f),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: Container(
                  height: 200,
                  width: 200,
                  child: Image.asset(
                    'assets/org_logos/societree_3.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 7.0),
                            child: Text(
                              'WELCOME',
                              style: GoogleFonts.oswald(
                                color: Color(0xFF2e2a2b),
                                fontSize: 42,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              //controller: _emailController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.assignment_ind, color: Color(0xFF666666)),
                                hintText: 'ID Number',
                                hintStyle: GoogleFonts.oswald(),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              //controller: _emailController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.lock, color: Color(0xFF666666)),
                                hintText: 'Password',
                                hintStyle: GoogleFonts.oswald(),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                    
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
                          child: InkWell(
                            child: myButton(context, 'LOGIN', (){
                              Get.toNamed('/dashboard');
                            },
                            style: ElevatedButton.styleFrom(
                              textStyle: GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              backgroundColor: Color(0xFF8bc53f),
                              foregroundColor: Color(0xFFffffff),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              )
                            ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.oswald(
                                      color: Colors.blue[600],
                                      fontSize: 18,
                                    ),
                                  ),
                                  onTap: () {
                                    //Get.toNamed('/signup');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.8,
                                color: Colors.grey[400],
                              )
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                vertical: 0,
                                horizontal: 10,
                              ),
                              child: Text(
                                'OR',
                                style: GoogleFonts.oswald(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.8,
                                color: Colors.grey[400],
                              )
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        InkWell(
                          onTap: () {
                            Get.toNamed('/scanner');
                          },
                          child: Icon(
                            Icons.qr_code_scanner,
                            size: 80,
                            color: Color(0xFF666666),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'SCAN ID',
                          style: GoogleFonts.oswald(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF666666)
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              )
            )
          ],
        ),
      ),
    );
  }
}