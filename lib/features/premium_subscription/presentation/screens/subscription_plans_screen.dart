import 'package:flutter/material.dart';
import '../widgets/subscription_card.dart';
import '../../domain/entities/subscription_period.dart';
import '../widgets/faq_section.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  static const TextStyle _titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle _subtitleTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  void _handlePageViewChanged(int index) {
    setState(() {
      _tabController.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5B1E8C), Color(0xFFD4186C)],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "What's next in music is first on SoundCloud",
                          style: _titleTextStyle,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Whether you want to share your sound or enjoy ad-free listening, we have the right plan for you.',
                          style: _subtitleTextStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: SizedBox(
                      height: 450,
                      width: 380,
                      child: PageView(
                        controller: _pageViewController,
                        onPageChanged: _handlePageViewChanged,
                        children: const [
                          SubscriptionCard(
                            subscriptionPeriod: SubscriptionPeriod.yearly,
                          ),
                          SubscriptionCard(
                            subscriptionPeriod: SubscriptionPeriod.monthly,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: TabPageSelector(
                      controller: _tabController,
                      color: const Color(0xFF7A2D63),
                      selectedColor: const Color(0xFF111111),
                      borderStyle: BorderStyle.none,
                      indicatorSize: 8,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "SoundCloud supports independent artists",
                  style: _titleTextStyle,
                ),
                SizedBox(height: 10),
                Text(
                  'From fan-powered royalties to our audience-building artists plans, your subscription helps support the SoundCloud global community.',
                  style: _subtitleTextStyle,
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5D0F97), Color(0xFF423BB3)],
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 200),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "“It's such a simple idea. Your monthly fees get split up between the songs you actually listen to.”",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "— RAC, musician and producer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 20,
                top: 25,
                bottom: -30,
                child: Container(
                  width: 170,
                  height: 200,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://specials-images.forbesimg.com/imageserve/6047077e9d0982ef2a4e2817/960x0.jpg',
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FaqSection(),
          ),
        ],
      ),
    );
  }
}
