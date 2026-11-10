import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myanmar 2D 3D VIP',
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0B132B)),
      home: const MainNav(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _idx = 0;
  final List<Widget> _pages = [const TwoDPage(), const GiftPage(), const ChatPage(), const ThreeDPage(), const HistoryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1C2541),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white54,
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: '2D Live'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'လက်ဆောင်'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.looks_3), label: '3D'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'မှတ်တမ်း'),
        ],
      ),
    );
  }
}

class TwoDPage extends StatefulWidget {
  const TwoDPage({super.key});
  @override
  State<TwoDPage> createState() => _TwoDPageState();
}

class _TwoDPageState extends State<TwoDPage> {
  String live2D = "--", setV = "--.--", valV = "--.--", time = "Live", m2D = "--", e2D = "--";
  Timer? _t;

  @override
  void initState() {
    super.initState();
    fetch();
    _t = Timer.periodic(const Duration(seconds: 10), (_) => fetch());
  }

  Future<void> fetch() async {
    try {
      final res = await http.get(Uri.parse('https://thaistock2d.com'));
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        final list = d['result'] as List;
        setState(() {
          live2D = d['live']['twod'] ?? "--";
          setV = d['live']['set'] ?? "--.--";
          valV = d['live']['value'] ?? "--.--";
          time = d['live']['time'] ?? "Live";
          if (list.isNotEmpty) m2D = list[0]['twod'] ?? "--";
          if (list.length > 1) e2D = list[1]['twod'] ?? "--";
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() { _t?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF1C2541), centerTitle: true, title: const Text('မြန်မာ့ 2D LIVE', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: Text('Updated: $time', style: const TextStyle(color: Colors.greenAccent))),
        const SizedBox(height: 20),
        Center(child: Container(
          width: 180, height: 180,
          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1C2541), border: Border.all(color: const Color(0xFFFFD700), width: 3)),
          alignment: Alignment.center,
          child: Text(live2D, style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.white)),
        )),
        const SizedBox(height: 25),
        Row(children: [
          Expanded(child: _box('SET', setV, Colors.cyanAccent)),
          const SizedBox(width: 12),
          Expanded(child: _box('VALUE', valV, Colors.amberAccent)),
        ]),
        const SizedBox(height: 20),
        _row('12:01 PM (မနက်)', m2D),
        const SizedBox(height: 10),
        _row('04:30 PM (ညနေ)', e2D),
      ]),
    );
  }

  Widget _box(String t, String v, Color c) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1C2541), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(t, style: const TextStyle(color: Colors.white54)), const SizedBox(height: 5), Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c))]));
  Widget _row(String t, String r) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C2541), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)), Text(r, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent))]));
}

class GiftPage extends StatefulWidget {
  const GiftPage({super.key});
  @override
  State<GiftPage> createState() => _GiftPageState();
}

class _GiftPageState extends State<GiftPage> {
  String vipMain = "25 - 52";
  String vipSub = "အပူး: 22, 55 | မွေးဂဏန်း: 89";
  String adminNote = "ယနေ့အတွက် အထူးလက်ဆောင် ဖြစ်ပါသည်။";
  int _tapCount = 0;

  void _openAdminDialog() {
    final passCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1C2541),
      title: const Text('Admin Login', style: TextStyle(color: Color(0xFFFFD700))),
      content: TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Password (123456)')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ပိတ်မည်')),
        ElevatedButton(onPressed: () {
          if (passCtrl.text == '123456') {
            Navigator.pop(ctx);
            _showEditSheet();
          }
        }, child: const Text('ဝင်မည်')),
      ],
    ));
  }

  void _showEditSheet() {
    final mCtrl = TextEditingController(text: vipMain);
    final sCtrl = TextEditingController(text: vipSub);
    final nCtrl = TextEditingController(text: adminNote);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1C2541),
      title: const Text('လက်ဆောင်ဂဏန်း ပြင်ဆင်ရန်', style: TextStyle(color: Color(0xFFFFD700))),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: mCtrl, decoration: const InputDecoration(labelText: 'အဓိက ဂဏန်း')),
        TextField(controller: sCtrl, decoration: const InputDecoration(labelText: 'အရံ / အပူး ဂဏန်း')),
        TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Admin မှတ်ချက်')),
      ]),
      actions: [
        ElevatedButton(onPressed: () {
          setState(() { vipMain = mCtrl.text; vipSub = sCtrl.text; adminNote = nCtrl.text; });
          Navigator.pop(ctx);
        }, child: const Text('သိမ်းမည်')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2541), centerTitle: true,
        title: GestureDetector(
          onTap: () { _tapCount++; if (_tapCount >= 5) { _tapCount = 0; _openAdminDialog(); } },
          child: const Text('VIP လက်ဆောင်ဂဏန်း', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        ),
      ),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: const Color(0xFF1C2541), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFD700), width: 2)),
          child: Column(children: [
            const Text('ယနေ့ အထူးပတ်သီး / ဝမ်းချိန်း', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 15),
            Text(vipMain, style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
            const Divider(color: Colors.white24, height: 30),
            Text(vipSub, style: const TextStyle(fontSize: 18, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(adminNote, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('(Admin ပြင်ဆင်ရန် အပေါ်ခေါင်းစဉ်ကို ၅ ချက်နှိပ်ပါ)', style: TextStyle(fontSize: 11, color: Colors.white24)),
      ])),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> _msgs = [
    {'name': 'Admin', 'text': 'မင်္ဂလာပါ 2D ချစ်သူများ အားလုံးကံကောင်းကြပါစေ။'},
    {'name': 'Ko Kyaw', 'text': 'ညနေပိုင်း 5 ထိပ် စီးမယ်ထင်တယ်ဗျို့'},
  ];
  final _txtCtrl = TextEditingController();
  String _userName = "User_${DateTime.now().second}";

  void _send() {
    if (_txtCtrl.text.trim().isEmpty) return;
    setState(() {
      _msgs.add({'name': _userName, 'text': _txtCtrl.text.trim()});
      _txtCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2541), title: const Text('Viewer Chat (စကားဝိုင်း)', style: TextStyle(color: Color(0xFFFFD700))),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () {
            final nCtrl = TextEditingController(text: _userName);
            showDialog(context: context, builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1C2541), title: const Text('နာမည်ပြောင်းရန်'),content: TextField(controller: nCtrl),
actions: [ElevatedButton(onPressed: () { setState(() => _userName = nCtrl.text); Navigator.pop(ctx); }, child: const Text('OK'))],
));
}),
],
),
body: Column(children: [
Expanded(child: ListView.builder(
padding: const EdgeInsets.all(14), itemCount: _msgs.length,
itemBuilder: (ctx, i) => Container(
margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
decoration: BoxDecoration(color: const Color(0xFF1C2541), borderRadius: BorderRadius.circular(12)),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(_msgs[i]['name']!, style: TextStyle(fontWeight: FontWeight.bold, color: _msgs[i]['name'] == 'Admin' ? Colors.redAccent : const Color(0xFFFFD700), fontSize: 12)),
const SizedBox(height: 4),
Text(_msgs[i]['text']!, style: const TextStyle(color: Colors.white, fontSize: 15)),
]),
),
)),
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), color: const Color(0xFF1C2541),
child: Row(children: [
Expanded(child: TextField(controller: _txtCtrl, decoration: const InputDecoration(hintText: 'စာရိုက်ပါ...', border: InputBorder.none))),
IconButton(icon: const Icon(Icons.send, color: Color(0xFFFFD700)), onPressed: _send),
]),
),
]),
);
}
}
class ThreeDPage extends StatelessWidget {
const ThreeDPage({super.key});
@override
Widget build(BuildContext context) {
final list = [{'d': '01-11-2026', 'n': '519'}, {'d': '16-10-2026', 'n': '307'}, {'d': '01-10-2026', 'n': '964'}];
return Scaffold(
appBar: AppBar(backgroundColor: const Color(0xFF1C2541), centerTitle: true, title: const Text('3D ရလဒ်များ', style: TextStyle(color: Color(0xFFFFD700)))),
body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: list.length, itemBuilder: (ctx, i) => Card(color: const Color(0xFF1C2541), child: ListTile(title: Text(list[i]['d']!), trailing: Text(list[i]['n']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))))),
);
}
}
class HistoryPage extends StatefulWidget {
const HistoryPage({super.key});
@override
State createState() => _HistoryPageState();
}
class HistoryPageState extends State {
List data = [];
@override
void initState() { super.initState(); load(); }
Future load() async {
try {
final res = await http.get(Uri.parse('thaistock2d.com'));
if (res.statusCode == 200) setState(() => data = json.decode(res.body));
} catch () {}
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(backgroundColor: const Color(0xFF1C2541), centerTitle: true, title: const Text('2D မှတ်တမ်း', style: TextStyle(color: Color(0xFFFFD700)))),
body: data.isEmpty ? const Center(child: CircularProgressIndicator()) : ListView.builder(padding: const EdgeInsets.all(14), itemCount: data.length > 10 ? 10 : data.length, itemBuilder: (ctx, i) {
final c = data[i]['child'] as List;
return Card(color: const Color(0xFF1C2541), child: ListTile(title: Text(data[i]['date'] ?? '', style: const TextStyle(color: Color(0xFFFFD700))), subtitle: Text('မနက်: ${c.isNotEmpty ? c[0]['twod'] : '--'}  |  ညနေ: ${c.length > 1 ? c[1]['twod'] : '--'}', style: const TextStyle(color: Colors.white, fontSize: 16))));
}),
);
}
}
