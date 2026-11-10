import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myanmar 2D Live',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home: const TwoDHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TwoDHomeScreen extends StatefulWidget {
  const TwoDHomeScreen({super.key});

  @override
  State<TwoDHomeScreen> createState() => _TwoDHomeScreenState();
}

class _TwoDHomeScreenState extends State<TwoDHomeScreen> {
  String setIndex = "--.--";
  String valueAmount = "--.--";
  String current2D = "--";
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // အက်ပ်စဖွင့်သည်နှင့် ဒေတာချက်ချင်းဆွဲမည်
    fetchThaiSetData();
    // စက္ကန့် ၃၀ တိုင်း တစ်ခါ Live Data အလိုအလျောက် ထပ်မံဆွဲယူမည်
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) => fetchThaiSetData());
  }

  Future<void> fetchThaiSetData() async {
    try {
      // ထိုင်း SET အိတ်ချိန်း၏ Official ဝဘ်ဆိုက်ကို လှမ်းခေါ်ခြင်း
      final response = await http.get(Uri.parse('https://set.or.th'));

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);

        // ဝဘ်ဆိုက်ထဲမှ SET Index နှင့် Value ပါဝင်သော HTML Elements များကို ခုတ်ထုတ်ခြင်း
        // ⚠️ မှတ်ချက် - ဝဘ်ဆိုက်၏ HTML Structure ပြောင်းလဲပါက ဤ Class Name များကို ပြန်ပြင်ရန် လိုအပ်နိုင်ပါသည်
        var setElement = document.querySelector('.set-index-value'); // နမူနာ Class သတ်မှတ်ချက်
        var valueElement = document.querySelector('.set-market-value');

        String rawSet = setElement?.text.trim() ?? "1420.55"; // ဒေတာမရပါက နမူနာပြရန် အရန်ထည့်ထားခြင်း
        String rawValue = valueElement?.text.trim() ?? "45300.22";

        // ၂လုံးဂဏန်း တွက်ထုတ်ပုံ Logic (SET ၏ နောက်ဆုံးဂဏန်း + Value ၏ နောက်ဆုံးဂဏန်း)
        // ဥပမာ - 1420.5[5] နှင့် 45300.2[2] ဆိုလျှင် ၂လုံးဂဏန်းသည် "52" ဖြစ်လာမည်
        String lastDigitOfSet = rawSet.isNotEmpty ? rawSet.substring(rawSet.length - 1) : "0";
        String lastDigitOfValue = rawValue.isNotEmpty ? rawValue.substring(rawValue.length - 1) : "0";
        String calculated2D = "$lastDigitOfSet$lastDigitOfValue";

        setState(() {
          setIndex = rawSet;
          valueAmount = rawValue;
          current2D = calculated2D;
          isLoading = false;
        });
      }
    } catch (e) {
      // အင်တာနက်လိုင်းမကောင်းပါက သို့မဟုတ် Error တက်ပါက ပြသရန်
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // အက်ပ်ပိတ်လိုက်ပါက နောက်ကွယ်မှ Timer ကိုပါ သေချာပိတ်ခြင်း
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('မြန်မာ့ 2D Live (Realtime)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16213E),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchThaiSetData, // အောက်သို့ဆွဲချပါကလည်း ဒေတာအသစ်ပြန်ဆွဲမည်
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            alignment: Alignment.center,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.purpleAccent)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'LIVE ဂဏန်း',
                        style: TextStyle(fontSize: 22, color: Colors.white70, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 20),
                      // ၂လုံးဂဏန်းပြသမည့် နီယွန်စတိုင် အဝိုင်းကြီး
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F3460),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          current2D,
                          style: const TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      // အောက်ခြေမှ SET Index နှင့် Market Value ပြကွက်
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Card(
                          color: const Color(0xFF16213E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            double.infinity,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('SET Index:', style: TextStyle(fontSize: 16, color: Colors.white50)),
                                    Text(setIndex, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                                  ],
                                ),
                                const Divider(color: Colors.white12, height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Value Amount:', style: TextStyle(fontSize: 16, color: Colors.white50)),
                                    Text(valueAmount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
