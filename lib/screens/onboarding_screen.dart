import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Säästä rahaa pelastamalla',
      'description': 'Osta herkullista ruokaa naapureilta ja kaupoilta reilusti alennettuun hintaan.',
      'image': 'assets/onboarding_1.png', 
    },
    {
      'title': 'Heitä hyvästit hävikille',
      'description': 'Löydä tarjouksia läheltäsi! Selaa helposti päivittäin vaihtuvia ilmoituksia.',
      'image': 'assets/onboarding_2.png', 
    },
    {
      'title': 'Nouda ja nauti',
      'description': 'Varaa ruoka sovelluksessa, nouda se sovitusti ja nauti hyvästä ruoasta.',
      'image': 'assets/onboarding_3.png', 
    },
  ];

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Ei voitu avata linkkiä: $urlString');
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tervetuloa NaapuriSapuskaan!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ennen kuin jatkat, tarkista tietosuoja-asetuksesi ja käyttöehdot.', style: TextStyle(height: 1.5)),
              const SizedBox(height: 20),
              const Text(
                'Käyttämällä palvelua hyväksyt:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              _TermItem(
                text: 'Käyttöehdot',
                onTap: null, 
              ),
              _TermItem(
                text: 'Tietosuojakäytäntö',
                onTap: () => _launchURL('https://naaarezai.github.io/naapurisapuska/privacy.html'),
                isLink: true,
              ),
              const _TermItem(
                text: 'Sijainnin käytön ilmoitusten näyttämiseen',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
            },
            child: const Text('Peruuta', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              _finishOnboarding();
            },
            child: const Text('Hyväksy ja jatka'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // --- TÄSSÄ ON MUUTOS ---
                        // Kääritään kuva Containeriin, jossa on varjo ja pyöristys
                        Container(
                          height: 280, // Hieman korkeampi tila kuvalle
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white, // Taustaväri varjoa varten
                            borderRadius: BorderRadius.circular(24), // Pyöristetyt kulmat (isonna numeroa jos haluat pyöreämmän)
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08), // Hyvin pehmeä varjo
                                blurRadius: 20, // Varjon pehmeys
                                offset: const Offset(0, 8), // Varjon suunta (alaspäin)
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          // ClipRRect leikkaa sisällä olevan kuvan pyöreisiin kulmiin
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              _pages[index]['image']!,
                              fit: BoxFit.cover, // 'cover' täyttää koko alueen nätisti
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_not_supported,
                                  size: 100,
                                  color: Colors.grey.shade300,
                                );
                              },
                            ),
                          ),
                        ),
                        // -----------------------

                        const SizedBox(height: 40),
                        
                        Text(
                          _pages[index]['title']!,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          _pages[index]['description']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ALAPALKKI (Pysyy samana)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF388E3C)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _showTermsDialog();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF388E3C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Aloita käyttö' : 'Seuraava',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                  if (_currentPage != _pages.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            _pages.length - 1, 
                            duration: const Duration(milliseconds: 300), 
                            curve: Curves.easeIn
                          );
                        },
                        child: const Text('Ohita esittely', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLink;

  const _TermItem({
    required this.text,
    this.onTap,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF388E3C)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isLink ? Colors.blue[700] : Colors.black87,
                  decoration: isLink ? TextDecoration.underline : null,
                  decorationColor: Colors.blue[700],
                ),
              ),
            ),
            if (isLink)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.open_in_new, size: 16, color: Colors.blue[700]),
              ),
          ],
        ),
      ),
    );
  }
}