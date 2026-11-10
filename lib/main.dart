import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myanmar 2D VIP',
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0B132B)),
      home: const TwoDPremiumScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TwoDPremiumScreen extends StatefulWidget {
  const TwoDPremiumScreen({super.key});
  @override
  State<TwoDPremiumScreen> createState() => _TwoDPremiumScreenState();
}

class _TwoDPremiumScreenState extends State<TwoDPremiumScreen> with SingleTickerProviderStateMixin {
  String setIndex = "1,420.55", valueAmount = "45,300.22", current2D = "52", lastUpdated = "အခုလေးတင်";
  bool isLoading = false;
  Timer? _timer;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    fetchData();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) => fetchData());
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('https://set.or.th'));
      if (res.statusCode == 200) {
        var doc = parser.parse(res.body);
        String rawSet = doc.querySelector('.set-index-value')?.text.trim() ?? "1420.55";
        String rawVal = doc.querySelector('.set-market-value')?.text.trim() ?? "45300.22";
        String d1 = rawSet.isNotEmpty ? rawSet.substring(rawSet.length - 1) : "0";
        String d2 = rawVal.isNotEmpty ? rawVal.substring(rawVal.length - 1) : "0";
        final now = DateTime.now();
        setState(() {
          setIndex = rawSet; valueAmount = rawVal; current2D = "$d1$d2";
          lastUpdated = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          isLoading = false;
        });
      }
    } catch (e) { setState(() => isLoading = false); }
  }

  @override
  void dispose() { _timer?.cancel(); _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2541), elevation: 0, centerTitle: true,
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_graph_rounded, color: Color(0xFFFFD700)), SizedBox(width: 8),
          Text('မြန်မာ့ 2D LIVE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        actions: [
          IconButton(
            icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700))) : const Icon(Icons.refresh_rounded, color: Color(0xFFFFD700)),
            onPressed: fetchData,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1C2541), Color(0xFF0B132B)])),
        child: RefreshIndicator(
          color: const Color(0xFFFFD700), onRefresh: fetchData,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.greenAccent.withOpacity(0.4))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                FadeTransition(opacity: _pulse, child: const Icon(Icons.circle, color: Colors.greenAccent, size: 10)),
                const SizedBox(width: 8), Text('Updated: $lastUpdated', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            )),
            const SizedBox(height: 30),
            Center(child: AnimatedBuilder(animation: _pulse, builder: (context, child) => Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF2B3A67), Color(0xFF1C2541)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: const Color(0xFFFFD700), width: 3),
                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.15 + (_pulse.value * 0.2)), blurRadius: 25, spreadRadius: 5)],
              ),
              alignment: Alignment.center,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('LIVE', style: TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3)),
                Text(current2D, style: const TextStyle(fontSize: 76, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
              ]),
            ))),
            const SizedBox(height: 35),
            Row(children: [
              Expanded(child: _card('SET INDEX', setIndex, Icons.trending_up, Colors.cyanAccent)),
              const SizedBox(width: 15),
              Expanded(child: _card('VALUE', valueAmount, Icons.account_balance_wallet, Colors.amberAccent)),
            ]),
            const SizedBox(height: 25),
            const Text('ယနေ့ ရလဒ်မှတ်တမ်း', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 12),
            _session('12:01 PM (မနက်ပိုင်း)', '1,418.20', '24,150.85', '05'),
            const SizedBox(height: 12),
            _session('04:30 PM (ညနေပိုင်း)', setIndex, valueAmount, current2D),
          ]),
        ),
      ),
    );
  }

  Widget _card(String title, String val, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF1C2541).withOpacity(0.8), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Text(title, style: const TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 10),
      Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    ]),
  );

  Widget _session(String title, String setV, String valA, String res2D) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(color: const Color(0xFF1C2541), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.25))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
        const SizedBox(height: 6),
        Text('SET: $setV  |  Val: $valA', style: const TextStyle(fontSize: 12, color: Colors.white60)),
      ]),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF0B132B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.greenAccent.withOpacity(0.5))),
        child: Text(res2D, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
      ),
    ]),
  );
}
