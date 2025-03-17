import 'package:flutter/material.dart';
import 'sign_in_screen.dart';

class FarmWelcomeScreen extends StatelessWidget {
  const FarmWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width * 0.06; // 6% of screen width

    return Scaffold(
      body: Stack(
        children: [
          // Background with custom clipper
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: screenSize.height * 0.75,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF2E7D32),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenSize.height - MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenSize.height * 0.1),

                      // Logo placeholder
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(screenSize.width * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.eco,
                            size: screenSize.width * 0.12,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ),

                      SizedBox(height: screenSize.height * 0.05),

                      // Welcome Text
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Welcome to',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.08,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Farm Management',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.1,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),

                      SizedBox(height: screenSize.height * 0.02),

                      Text(
                        'Manage your farm efficiently with our smart solutions',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),

                      SizedBox(height: screenSize.height * 0.2),

                      // Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.02,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4CAF50),
                            padding: EdgeInsets.symmetric(
                              vertical: screenSize.height * 0.02,
                            ),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenSize.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height * 0.7);
    final secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: const Color(0xFF4CAF50),
      fontFamily: 'Poppins',
    ),
    home: const FarmWelcomeScreen(),
  ));
}