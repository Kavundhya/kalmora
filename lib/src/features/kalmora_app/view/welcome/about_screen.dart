import 'package:flutter/material.dart';
import '../../../authentication/view/login_page.dart';
import '../../../authentication/view/signup_page.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9D7B6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Express Yourself\nwith Voice",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            Image.asset(
              "assets/images/voice_image.png",
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 50),
            Text(
              "Capture\nyour thoughts effortlessly\nusing voice",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutScreen2()),
                );
              },
              child: Icon(
                Icons.arrow_forward_ios,
                size: 40,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen2 extends StatelessWidget {
  const AboutScreen2({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9D7B6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Understand Your Emotion",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            Image.asset(
              "assets/images/emotion_image.png",
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 50),
            Text(
              "Discover insights about your emotions",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutScreen3()),
                );
              },
              child: Icon(
                Icons.arrow_forward_ios,
                size: 40,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen3 extends StatelessWidget {
  const AboutScreen3({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9D7B6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Feel Better Every Day",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            Image.asset(
              "assets/images/feel_better_image.png",
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 50),
            Text(
              "Receive personalized recommendations",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FinalScreen()),
                );
              },
              child: Icon(
                Icons.arrow_forward_ios,
                size: 40,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FinalScreen extends StatelessWidget {
  const FinalScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9D7B6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              SizedBox(height: 1),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(text: "Stay with "),
                    TextSpan(
                      text: "KALMORA",
                      style: TextStyle(
                        fontFamily: 'CinzelDecorative',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Image.asset(
                "assets/images/kalmora_logo.png", 
                width: 300,
                height: 350,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 40),
              Text(
                "Let's Start",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "SIGN UP",
                  style: TextStyle(
                    color: Color(0xFFE9D7B6),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 1),
              GestureDetector(
                onTap: () {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black, 
                      fontFamily: Theme.of(context).textTheme.titleSmall?.fontFamily, 
                    ),
                    children: [
                      TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

