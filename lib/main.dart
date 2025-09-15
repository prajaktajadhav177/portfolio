import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prajakta Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PortfolioHomePage(),
    );
  }
}

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {



// Skill Item Widget
Widget _skillItem(IconData icon, String skill) {
  return Row(
    children: [
      Icon(icon, size: 24, color: Colors.blueAccent),
      const SizedBox(width: 10),
      Text(
        skill,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    ],
  );
}

  // Add this function above your build method (outside the widget tree)
Widget _highlightCard(String title, String description, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 26, color: Colors.blueAccent),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSocialIcon(IconData icon, String url) {
  return InkWell(
    onTap: () async {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    },
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: FaIcon(icon, color: Colors.white, size: 28),
    ),
  );
}




Widget _buildProjectCard({
  required String title,
  required String description,
  required String githubUrl,
  required IconData icon,
  required Color color,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
    width: 280,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Colors.blue.shade50],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => launchUrl(Uri.parse(githubUrl)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.code, size: 20, color: Colors.blueAccent),
              SizedBox(width: 6),
              Text(
                "View on GitHub",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Inline social icon button widget
Widget _socialIconButton({
  required IconData icon,
  required String tooltip,
  required String url,
  required Color color,
}) {
  return InkWell(
    onTap: () async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    },
    borderRadius: BorderRadius.circular(50),
    child: Tooltip(
      message: tooltip,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white.withOpacity(0.1),
        child: Icon(icon, color: color, size: 26),
      ),
    ),
  );
}


  final ScrollController _scrollController = ScrollController();

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final _skillsKey = GlobalKey();
final _educationKey = GlobalKey();


  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }



  bool _animateAbout = false;

void _checkAboutVisibility() {
  if (!_animateAbout) {
    final RenderBox? aboutBox =
        _aboutKey.currentContext?.findRenderObject() as RenderBox?;
    if (aboutBox != null) {
      final position = aboutBox.localToGlobal(Offset.zero).dy;
      final screenHeight = MediaQuery.of(context).size.height;

      if (position < screenHeight * 0.7) {
        setState(() {
          _animateAbout = true;
        });
      }
    }
  }
}

@override
void initState() {
  super.initState();
  _scrollController.addListener(_checkAboutVisibility);
}

@override
void dispose() {
  _scrollController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Spacer(),
            TextButton(
              onPressed: () => scrollToSection(_aboutKey),
              child: const Text("About", style: TextStyle(color: Colors.black)),
            ),
             TextButton(
              onPressed: () => scrollToSection(_experienceKey),
              child: const Text("Experience", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () => scrollToSection(_projectsKey),
              child: const Text("Projects", style: TextStyle(color: Colors.black)),
            ),

            TextButton(
  onPressed: () => scrollToSection(_skillsKey),
  child: const Text("Skills",style: TextStyle(color: Colors.black)),
),
TextButton(
  onPressed: () => scrollToSection(_educationKey),
  child: const Text("Education",style: TextStyle(color: Colors.black)),
),
           
            TextButton(
              onPressed: () => scrollToSection(_contactKey),
              child: const Text("Contact", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Home Section
  Container(
  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
  margin: const EdgeInsets.all(20),
  width: double.infinity,
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color.fromARGB(154, 1, 48, 40), Color.fromARGB(255, 113, 211, 233)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CircleAvatar(
            backgroundImage: const AssetImage('profile.jpeg'),
            radius: 55,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Prajakta Ganesh Jadhav",
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Flutter Developer | Problem Solver | Tech Enthusiast",
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 30),
      Text(
"Computer Science Engineering student skilled in Flutter, Firebase, SQL, MongoDB, Java, C++, Git/GitHub, Sqflite, and SharedPreferences. Passionate about building cross-platform apps with secure authentication, clean UI/UX, optimized performance, and seamless user experience. Strong problem-solver focused on writing maintainable, efficient, and scalable code.",
 style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 18,
          height: 1.6,
        ),
      ),
      const SizedBox(height: 25),

       const SizedBox(height: 30),

      // Buttons
      Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => scrollToSection(_projectsKey),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2193b0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
            icon: const Icon(Icons.arrow_forward),
            label: Text(
              "View Projects",
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 20),
          OutlinedButton.icon(
            onPressed: () async {
              final Uri url = Uri.parse(
                  "https://drive.google.com/file/d/1M9S68By5o7iq7tGXl73OrND0HXLgIfIm/view?usp=drive_link");
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1.5),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.attach_file),
            label: Text(
              "Resume",
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 25),

      Row(
        children: [
          Tooltip(
      message: "GitHub",
      child: _buildSocialIcon(
        FontAwesomeIcons.github,
        "https://github.com/prajaktajadhav177",
      ),
    ),

    const SizedBox(width: 16),
    Tooltip(
      message: "LinkedIn",
      child: _buildSocialIcon(
        FontAwesomeIcons.linkedin,
        "https://www.linkedin.com/in/prajakta-jadhav-7a4613320",
      ),
    ),
          
   const SizedBox(width: 13),
    Tooltip(
      message: "Email",
      child: IconButton(
        tooltip: "Email",
        onPressed: () async {
          final Uri email = Uri(
            scheme: 'mailto',
            path: 'prajaktajadhav177@gmail.com',
            query: 'subject=Hello Prajakta!',
          );
          if (!await launchUrl(email)) throw 'Could not launch $email';
        },
        icon: const Icon(Icons.mail,
            color: Colors.white, size: 32),
      ),
    ),
          
      
        ],
      ),
    ],
  ),
),
              // About Section
  Container(
  key: _aboutKey,
  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 70),
  width: double.infinity,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFF9FAFB), Color(0xFFEFF3F6)], // subtle light gradient
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section Title
      Row(
        children: [
          Container(
            width: 6,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "About Me",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      const SizedBox(height: 40),

      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side - About Text
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Who I Am",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
"I am a final-year Computer Science student passionate about building impactful mobile and web applications. With 6 months of hands-on internship experience, I enjoy creating smooth, engaging, and visually appealing user experiences while continuously improving my technical skills in Flutter, Firebase, SQL, and other technologies.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 50),

          // Right Side - Highlights
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _highlightCard(
                  "Mobile App Development",
                  "Specializing in Flutter & Firebase, building smooth, scalable cross-platform apps.",
                  Icons.phone_android,
                ),
                _highlightCard(
                  "Backend & Database Skills",
                  "Experience with Firebase, SQL, and REST APIs for reliable data management.",
                  Icons.storage,
                ),
                _highlightCard(
                  "UI/UX Focus",
                  "Clean, user-friendly, and responsive interfaces with attention to detail.",
                  Icons.design_services,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
),


        
// Experience Section
Container(
  key: _experienceKey,
  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
  width: double.infinity,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue.shade50, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title with divider
      Row(
        children:[
            Container(
            width: 6,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Experience",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
     
      const SizedBox(height: 30),

      // Experience Card 1
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.work_outline, size: 28, color: Colors.indigo),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Software Engineering Intern",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Intern Labs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "28 Jun 2025 – 28 Sep 2025",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("✔ Working on cross-platform app development using Flutter & Dart."),
                        Text("✔ Implementing clean UI/UX, Firebase integration, and state management."),
                        Text("✔ Contributing to testing, debugging, and performance optimization."),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Experience Card 2 (repeat structure)
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.developer_mode, size: 28, color: Colors.indigo),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Flutter Developer Intern",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Incubators System Pvt. Ltd",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "1 Aug 2024 – 31 Oct 2024",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("✔ Developed cross-platform mobile apps using Flutter & Dart."),
                        Text("✔ Implemented animations, login screens, and Firebase authentication."),
                        Text("✔ Worked with GitLab for collaborative development."),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),



// Projects Section
Container(
  key: _projectsKey,
  width: double.infinity,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFFBBDEFB), // Medium-light blue
        Color(0xFFE3F2FD), // Very light blue
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Heading Row with Animated Bar
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 50),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Container(
                width: 6,
                height: value,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlue],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Text(
            "Projects",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),

      // Underline Animation
      const SizedBox(height: 8),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 120),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Container(
            height: 4,
            width: value,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),

      const SizedBox(height: 16),
      const Text(
        "Here are some of my highlighted works",
        style: TextStyle(
          fontSize: 18,
          color: Colors.black54,
          fontStyle: FontStyle.italic,
        ),
      ),
      const SizedBox(height: 40),

      // Project Cards
      Wrap(
        spacing: 50,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          _buildProjectCard(
            title: "RentRider",
            description:
                "Vehicle booking app with Firebase authentication, smooth UI, and booking management.",
            githubUrl: "https://github.com/prajaktajadhav177/rent-rider",
            icon: Icons.directions_bike,
            color: Colors.blue,
          ),
          _buildProjectCard(
            title: "SoulSync",
            description:
                "Matrimony app with profile matching, chat, video call , voice call and Firebase authentication.",
            githubUrl: "https://github.com/prajaktajadhav177/soulsync",
            icon: Icons.favorite,
            color: Colors.pink,
          ),
          _buildProjectCard(
            title: "Expense Tracker",
            description:
                "Track expenses, set savings goals, and view budget analytics with dark mode toggle.",
            githubUrl:
                "https://github.com/prajaktajadhav177/web-app-expence-tracker",
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          _buildProjectCard(
            title: "ToDo App",
            description:
                "A simple ToDo app to manage tasks, set priorities, and track daily progress efficiently.",
            githubUrl: "https://github.com/prajaktajadhav177/Basic-todo-app",
            icon: Icons.check_circle,
            color: Colors.deepPurple,
          ),
        ],
      ),
    ],
  ),
),




Container(
  key: _skillsKey,
  width: double.infinity,
  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
  color: const Color(0xFFF5F7FA),
  child: Column(
    children: [
 Row(
        children: [
          Container(
                width: 6,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Skills",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
          const SizedBox(height: 30 ),
          
        ],
      ),

      Wrap(
        
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: List.generate(6, (index) {
          final skills = [
            {
              "icon": Icons.flutter_dash,
              "title": "Flutter & Dart",
              "description": "Build cross-platform apps with beautiful UI & responsive design."
            },
            {
              "icon": Icons.cloud,
              "title": "Firebase",
              "description": "Realtime database, auth, cloud functions & hosting."
            },
            {
              "icon": Icons.storage,
              "title": "SQL / MongoDB",
              "description": "Efficient data storage, querying & database management."
            },
            {
              "icon": Icons.merge_type,
              "title": "Git & GitHub",
              "description": "Version control and collaborative project management."
            },
            {
              "icon": Icons.design_services,
              "title": "UI/UX Design",
              "description": "Design clean, intuitive & user-friendly interfaces."
            },
            {
              "icon": Icons.code,
              "title": "Java / C++",
              "description": "Strong backend programming skills with OOP and algorithms."
            },
          ];
      
          bool isHovered = false;
      
          return StatefulBuilder(
            builder: (context, setState) {
              return MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isHovered ? 240 : 200,
                  height: isHovered ? 240 : 200,
                  padding: const EdgeInsets.all(16),
                  transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isHovered
                          ? [const Color.fromARGB(255, 174, 183, 234), const Color.fromARGB(255, 249, 246, 248)]
                          : [Colors.white, Colors.grey.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: isHovered ? 20 : 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: isHovered
                        ? Border.all(color: const Color.fromARGB(255, 31, 100, 219), width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(skills[index]["icon"] as IconData, size: 40, color: Colors.blueAccent),
                      const SizedBox(height: 12),
                      Text(
                        skills[index]["title"] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isHovered)
                        Text(
                          skills[index]["description"] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    ],
  ),
),





// Education Section
Container(
  key: _educationKey,
  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
  color: Colors.grey[50],
  width: double.infinity,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Education",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 30),

      Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "B.E. in Computer Science & Engineering",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Sinhgad Institute of Technology & Science, Pune (2022–2026)",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "CGPA: 8.14 / 10",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),


// Footer Section
Container(
  key: _contactKey,
  width: double.infinity,
  color: Colors.blueGrey[900],
  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Section Heading
      const Text(
        "Let's Connect",
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 12),

      // Tagline
      const Text(
        "Have a project in mind, collaboration idea, or just want to say hello? \nI’d love to hear from you!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white70,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 30),

      // Main Contact Buttons
      Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 3,
            ),
            onPressed: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'prajaktajadhav177@gmail.com',
                query: 'subject=Portfolio Contact',
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              }
            },
            icon: const Icon(Icons.email_outlined),
            label: const Text("Email Me"),
          ),
          // ElevatedButton.icon(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.tealAccent,
          //     foregroundColor: Colors.black,
          //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          //     elevation: 3,
          //   ),
          //   onPressed: () async {
          //     final Uri phoneUri = Uri(scheme: 'tel', path: '+919421950013');
          //     if (await canLaunchUrl(phoneUri)) {
          //       await launchUrl(phoneUri);
          //     }
          //   },
          //   icon: const Icon(Icons.phone_outlined),
          //   label: const Text("Call"),
          // ),
        ],
      ),

      const SizedBox(height: 40),

      // Social Media Icons Row
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _socialIconButton(
            icon: Icons.link,
            tooltip: "LinkedIn",
            url: "www.linkedin.com/in/prajakta-jadhav-7a4613320",
            color: Colors.lightBlueAccent,
          ),
          const SizedBox(width: 16),
          _socialIconButton(
            icon: Icons.code,
            tooltip: "GitHub",
            url: "https://github.com/prajaktajadhav177",
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          _socialIconButton(
            icon: Icons.picture_as_pdf,
            tooltip: "Download Resume",
            url: "https://drive.google.com/file/d/1M9S68By5o7iq7tGXl73OrND0HXLgIfIm/view?usp=drive_link", // Replace with actual resume link
            color: Colors.redAccent,
          ),
        ],
      ),

      const SizedBox(height: 40),

      // Divider Line for Clean Finish
      Divider(color: Colors.white24, thickness: 0.7, indent: 60, endIndent: 60),

      const SizedBox(height: 20),

      // Copyright / Footer Note
      const Text(
        "© 2025 Prajakta Ganesh Jadhav • Built with Flutter ❤️",
        style: TextStyle(
          color: Colors.white60,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    ],
  ),
)
]
)
)
);
  }
  }
