import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(const PortfolioApp());

// ─── Palette ──────────────────────────────────────────────────────
const kNight     = Color(0xFF080C18);
const kNavy      = Color(0xFF0D1426);
const kNavyMid   = Color(0xFF111D35);
const kCard      = Color(0xFF131C30);
const kCardHov   = Color(0xFF192340);
const kGold      = Color(0xFFD4A843);
const kGoldSoft  = Color(0xFFF5D98A);
const kCream     = Color(0xFFF4F0E6);
const kCreamMid  = Color(0xFFB8B0A0);
const kCreamDim  = Color(0xFF6B6560);
const kBorder    = Color(0xFF1E2D48);
const kBorderHov = Color(0xFF2A3F60);
const kEmerald   = Color(0xFF10B981);

// ─── Links ────────────────────────────────────────────────────────
const kResumeUrl    = 'https://drive.google.com/file/d/1E8RWsutVJJildojM9LvyOBeyFZSnWuOr/view?usp=drive_link';
const kBadgeUrl     = 'https://drive.google.com/file/d/1Awvn8XhfXue5MyQ64SOlbiU5SffkOdLy/view?usp=sharing';
const kGithubUrl    = 'https://github.com/prajaktajadhav177';
const kLinkedinUrl  = 'https://www.linkedin.com/in/prajakta-jadhav-37484a260/';
const kEmailUrl     = 'mailto:prajaktajadhav177@gmail.com?subject=Opportunity for Prajakta';

// ══════════════════════════════════════════════════════════════════
//  Global scroll notifier
// ══════════════════════════════════════════════════════════════════
final _scrollNotifier = ValueNotifier<double>(0);

// ══════════════════════════════════════════════════════════════════
//  App root
// ══════════════════════════════════════════════════════════════════
class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Prajakta · Portfolio',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: kNight,
      colorScheme: const ColorScheme.dark(primary: kGold, surface: kNavy),
    ),
    home: const PortfolioPage(),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Subtle animated mesh background
// ══════════════════════════════════════════════════════════════════
class _MeshPainter extends CustomPainter {
  final double t;
  const _MeshPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final orbs = [
      (Offset(size.width*(0.18+0.06*math.sin(t*0.5)),
               size.height*(0.22+0.05*math.cos(t*0.4))),
       kGold, size.width*0.34, 0.05),
      (Offset(size.width*(0.78+0.05*math.cos(t*0.45)),
               size.height*(0.18+0.06*math.sin(t*0.6))),
       const Color(0xFF6366F1), size.width*0.27, 0.04),
      (Offset(size.width*(0.55+0.07*math.sin(t*0.35)),
               size.height*(0.72+0.05*math.cos(t*0.5))),
       const Color(0xFF0891B2), size.width*0.24, 0.04),
    ];
    for (final o in orbs) {
      canvas.drawCircle(o.$1, o.$3, Paint()
        ..shader = RadialGradient(colors:[
          o.$2.withOpacity(o.$4), o.$2.withOpacity(0)
        ]).createShader(Rect.fromCircle(center: o.$1, radius: o.$3)));
    }
  }
  @override bool shouldRepaint(_MeshPainter old) => old.t != t;
}

class _MeshBg extends StatefulWidget {
  final Widget child;
  const _MeshBg({required this.child});
  @override State<_MeshBg> createState() => _MeshBgState();
}
class _MeshBgState extends State<_MeshBg> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync:this, duration:const Duration(seconds:40))..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => RepaintBoundary(child: Stack(children:[
    Positioned.fill(child: AnimatedBuilder(
      animation: _c,
      builder: (_,__) => CustomPaint(painter: _MeshPainter(_c.value*2*math.pi)),
    )),
    widget.child,
  ]));
}

// ══════════════════════════════════════════════════════════════════
//  ScrollReveal — bidirectional on scroll
// ══════════════════════════════════════════════════════════════════
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double fromY, fromX;
  const ScrollReveal({super.key, required this.child,
      this.delay=Duration.zero, this.fromY=32, this.fromX=0});
  @override State<ScrollReveal> createState() => _SRState();
}
class _SRState extends State<ScrollReveal> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  Animation<double>? _op, _dy, _dx;

  @override
  void initState() {
    super.initState();
    final c = AnimationController(vsync:this, duration:const Duration(milliseconds:650));
    _c  = c;
    _op = CurvedAnimation(parent:c, curve:Curves.easeOut);
    _dy = Tween<double>(begin:widget.fromY, end:0)
        .animate(CurvedAnimation(parent:c, curve:Curves.easeOutCubic));
    _dx = Tween<double>(begin:widget.fromX, end:0)
        .animate(CurvedAnimation(parent:c, curve:Curves.easeOutCubic));
    c.value = 0;
    _scrollNotifier.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }
  @override void dispose() {
    _scrollNotifier.removeListener(_check);
    _c?.dispose();
    super.dispose();
  }
  void _check() {
    if (!mounted) return;
    final c=_c; if(c==null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box==null||!box.hasSize) return;
    final top    = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;
    final sh     = MediaQuery.of(context).size.height;
    final inView = top < sh*0.90 && bottom > 0;
    if (inView  && c.status==AnimationStatus.dismissed)
      Future.delayed(widget.delay, (){ if(mounted) c.forward(); });
    else if (!inView && c.status==AnimationStatus.completed) c.value=0;
  }
  @override
  Widget build(BuildContext context) {
    final c=_c; final op=_op; final dy=_dy; final dx=_dx;
    if (c==null||op==null||dy==null||dx==null) return widget.child;
    return AnimatedBuilder(
      animation: c,
      builder: (_,child) => Opacity(opacity:op.value,
        child: Transform.translate(offset:Offset(dx.value,dy.value), child:child)),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Pulsing dot
// ══════════════════════════════════════════════════════════════════
class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override State<_PulseDot> createState() => _PDState();
}
class _PDState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync:this, duration:const Duration(milliseconds:1600))
      ..repeat(reverse:true);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation:_c,
    builder:(_,__) => Stack(alignment:Alignment.center, children:[
      Container(width:14, height:14, decoration:BoxDecoration(
          shape:BoxShape.circle, color:kEmerald.withOpacity(0.13+0.18*_c.value))),
      Container(width:7, height:7, decoration:const BoxDecoration(
          shape:BoxShape.circle, color:kEmerald)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Gold shimmer text (hero name only)
// ══════════════════════════════════════════════════════════════════
class _GoldShimmer extends StatefulWidget {
  final String text; final double size; final TextAlign align;
  const _GoldShimmer(this.text, {this.size=56, this.align=TextAlign.start});
  @override State<_GoldShimmer> createState() => _GSState();
}
class _GSState extends State<_GoldShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync:this, duration:const Duration(seconds:6))..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => RepaintBoundary(child: AnimatedBuilder(
    animation:_c,
    builder:(_,__) => ShaderMask(
      shaderCallback:(b) => LinearGradient(
        colors:const[kGold,kGoldSoft,Color(0xFFFFECA0),kGold,kGoldSoft,kGold],
        stops:const[0,0.2,0.4,0.6,0.8,1.0],
        begin:Alignment(_c.value*4-2,-0.3),
        end:Alignment(_c.value*4,0.3),
        tileMode:TileMode.mirror,
      ).createShader(b),
      child:Text(widget.text, textAlign:widget.align,
        style:GoogleFonts.playfairDisplay(
          color:Colors.white, fontSize:widget.size,
          fontWeight:FontWeight.w700, height:1.05, letterSpacing:-1.5)),
    ),
  ));
}

// ══════════════════════════════════════════════════════════════════
//  Avatar with gradient ring
// ══════════════════════════════════════════════════════════════════
class _Avatar extends StatelessWidget {
  final double size;
  const _Avatar({this.size=220});
  @override
  Widget build(BuildContext context) => Stack(alignment:Alignment.center, children:[
    Container(width:size+24, height:size+24,
      decoration:BoxDecoration(shape:BoxShape.circle,
        boxShadow:[BoxShadow(color:kGold.withOpacity(0.14),
            blurRadius:34, spreadRadius:3)])),
    Container(width:size+10, height:size+10,
      decoration:const BoxDecoration(shape:BoxShape.circle,
        gradient:SweepGradient(colors:[
          kGold, kGoldSoft, Color(0xFF6366F1), kGold]))),
    Container(width:size+2, height:size+2,
      decoration:const BoxDecoration(shape:BoxShape.circle, color:kNight)),
    CircleAvatar(radius:size/2,
      backgroundImage:const AssetImage('assets/profile.jpeg'),
      backgroundColor:kNavy),
    Positioned(top:6, right:6,
      child:Container(width:15, height:15,
        decoration:BoxDecoration(shape:BoxShape.circle, color:kEmerald,
          border:Border.all(color:kNight, width:2),
          boxShadow:[BoxShadow(color:kEmerald.withOpacity(0.55), blurRadius:7)]))),
  ]);
}

// ══════════════════════════════════════════════════════════════════
//  Hover card
// ══════════════════════════════════════════════════════════════════
class _Card extends StatefulWidget {
  final Widget child; final Color glowColor;
  final EdgeInsets padding; final double radius;
  const _Card({required this.child, this.glowColor=kGold,
      this.padding=const EdgeInsets.all(26), this.radius=18});
  @override State<_Card> createState() => _CardState();
}
class _CardState extends State<_Card> {
  bool _h=false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter:(_)=>setState(()=>_h=true),
    onExit:(_)=>setState(()=>_h=false),
    child:AnimatedContainer(
      duration:const Duration(milliseconds:240),
      curve:Curves.easeOutCubic,
      transform:_h?(Matrix4.identity()..translate(0.0,-5.0)):Matrix4.identity(),
      padding:widget.padding,
      decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(widget.radius),
        color:_h?kCardHov:kCard,
        border:Border.all(
          color:_h?widget.glowColor.withOpacity(0.45):kBorder, width:1.5),
        boxShadow:_h?[
          BoxShadow(color:widget.glowColor.withOpacity(0.12),
              blurRadius:26, offset:const Offset(0,10)),
          BoxShadow(color:Colors.black.withOpacity(0.38),
              blurRadius:14, offset:const Offset(0,5)),
        ]:[BoxShadow(color:Colors.black.withOpacity(0.28),
              blurRadius:10, offset:const Offset(0,4))],
      ),
      child:widget.child,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Project card (with GitHub + optional Demo link)
// ══════════════════════════════════════════════════════════════════
class _ProjCard extends StatefulWidget {
  final _Proj p; final Future<void> Function(String) open;
  const _ProjCard({required this.p, required this.open});
  @override State<_ProjCard> createState() => _PCState();
}
class _PCState extends State<_ProjCard> {
  bool _h=false;
  @override
  Widget build(BuildContext context) {
    final p=widget.p;
    return MouseRegion(
      onEnter:(_)=>setState(()=>_h=true),
      onExit:(_)=>setState(()=>_h=false),
      child:AnimatedContainer(
        duration:const Duration(milliseconds:250),
        curve:Curves.easeOutCubic,
        transform:_h?(Matrix4.identity()..translate(0.0,-5.0)):Matrix4.identity(),
        padding:const EdgeInsets.all(22),
        decoration:BoxDecoration(
          borderRadius:BorderRadius.circular(18),
          color:_h?kCardHov:kCard,
          border:Border.all(
            color:_h?p.color.withOpacity(0.48):kBorder, width:1.5),
          boxShadow:_h?[
            BoxShadow(color:p.color.withOpacity(0.13),
                blurRadius:28, offset:const Offset(0,10)),
            BoxShadow(color:Colors.black.withOpacity(0.38),
                blurRadius:14, offset:const Offset(0,5)),
          ]:[BoxShadow(color:Colors.black.withOpacity(0.28),
                blurRadius:10, offset:const Offset(0,4))],
        ),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Row(children:[
            Container(
              padding:const EdgeInsets.all(10),
              decoration:BoxDecoration(
                color:p.color.withOpacity(_h?0.18:0.1),
                borderRadius:BorderRadius.circular(11),
                border:Border.all(color:p.color.withOpacity(0.28))),
              child:_ico(p.icon, p.color, 19),
            ),
            const Spacer(),
            // GitHub
            _linkChip(FontAwesomeIcons.github, 'Code',
                p.githubUrl, p.color, _h),
            // Demo (shows only when demoUrl is set)
            if (p.demoUrl != null) ...[
              const SizedBox(width:7),
              _linkChip(Icons.open_in_new_rounded, 'Demo',
                  p.demoUrl!, kGold, _h),
            ],
          ]),
          const SizedBox(height:14),
          // Featured badge
          if (p.featured)
            Padding(padding:const EdgeInsets.only(bottom:7),
              child:Container(
                padding:const EdgeInsets.symmetric(horizontal:9, vertical:3),
                decoration:BoxDecoration(
                  color:kGold.withOpacity(0.1),
                  borderRadius:BorderRadius.circular(20),
                  border:Border.all(color:kGold.withOpacity(0.28))),
                child:Text('Featured', style:GoogleFonts.dmMono(
                    color:kGold, fontSize:10, fontWeight:FontWeight.w600,
                    letterSpacing:1.2)),
              ),
            ),
          Text(p.title, style:GoogleFonts.playfairDisplay(
              color:kCream, fontSize:16, fontWeight:FontWeight.w700)),
          const SizedBox(height:6),
          Text(p.desc, style:GoogleFonts.dmSans(
              color:kCreamMid, fontSize:13, height:1.65)),
          const SizedBox(height:13),
          Wrap(spacing:6, runSpacing:6,
            children:p.tags.map((t)=>Container(
              padding:const EdgeInsets.symmetric(horizontal:9, vertical:4),
              decoration:BoxDecoration(
                color:p.color.withOpacity(0.09),
                borderRadius:BorderRadius.circular(20),
                border:Border.all(color:p.color.withOpacity(0.22))),
              child:Text(t, style:GoogleFonts.dmMono(
                  color:p.color, fontSize:11, fontWeight:FontWeight.w600)),
            )).toList()),
        ]),
      ),
    );
  }

  Widget _linkChip(IconData ic, String lbl, String url, Color c, bool hov) =>
    GestureDetector(
      onTap:()=>widget.open(url),
      child:Container(
        padding:const EdgeInsets.symmetric(horizontal:9, vertical:5),
        decoration:BoxDecoration(
          color:hov?c.withOpacity(0.12):Colors.transparent,
          borderRadius:BorderRadius.circular(20),
          border:Border.all(color:hov?c.withOpacity(0.38):kBorderHov)),
        child:Row(mainAxisSize:MainAxisSize.min, children:[
          _ico(ic, hov?c:kCreamDim, 11),
          const SizedBox(width:4),
          Text(lbl, style:GoogleFonts.dmMono(
              color:hov?c:kCreamDim, fontSize:10, fontWeight:FontWeight.w600)),
        ]),
      ),
    );
}

// ══════════════════════════════════════════════════════════════════
//  Skill chip
// ══════════════════════════════════════════════════════════════════
class _SkillChip extends StatefulWidget {
  final _Sk s; final Color c;
  const _SkillChip({required this.s, required this.c});
  @override State<_SkillChip> createState() => _SCState();
}
class _SCState extends State<_SkillChip> {
  bool _h=false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor:SystemMouseCursors.click,
    onEnter:(_)=>setState(()=>_h=true),
    onExit:(_)=>setState(()=>_h=false),
    child:AnimatedContainer(
      duration:const Duration(milliseconds:180),
      transform:_h?(Matrix4.identity()..translate(0.0,-2.0)):Matrix4.identity(),
      padding:const EdgeInsets.symmetric(horizontal:13, vertical:8),
      decoration:BoxDecoration(
        color:_h?widget.c.withOpacity(0.09):kNavy,
        borderRadius:BorderRadius.circular(30),
        border:Border.all(color:_h?widget.c.withOpacity(0.42):kBorder)),
      child:Row(mainAxisSize:MainAxisSize.min, children:[
        _ico(widget.s.icon, _h?widget.c:kCreamDim, 13),
        const SizedBox(width:8),
        Text(widget.s.name, style:GoogleFonts.dmSans(
            color:_h?kCream:kCreamMid, fontSize:13, fontWeight:FontWeight.w500)),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Nav link
// ══════════════════════════════════════════════════════════════════
class _NavLink extends StatefulWidget {
  final String label; final VoidCallback onTap;
  const _NavLink(this.label, this.onTap);
  @override State<_NavLink> createState() => _NLState();
}
class _NLState extends State<_NavLink> {
  bool _h=false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor:SystemMouseCursors.click,
    onEnter:(_)=>setState(()=>_h=true),
    onExit:(_)=>setState(()=>_h=false),
    child:GestureDetector(onTap:widget.onTap,
      child:Padding(
        padding:const EdgeInsets.symmetric(horizontal:12, vertical:8),
        child:Column(mainAxisSize:MainAxisSize.min, children:[
          Text(widget.label, style:GoogleFonts.dmSans(
              color:_h?kGold:kCreamMid,
              fontSize:14, fontWeight:FontWeight.w500)),
          const SizedBox(height:2),
          AnimatedContainer(duration:const Duration(milliseconds:170),
            width:_h?18:0, height:2, color:kGold),
        ]),
      ),
    ),
  );
}

// ─── Icon helper ──────────────────────────────────────────────────
Widget _ico(IconData ic, Color c, double sz) {
  if (ic==FontAwesomeIcons.github||ic==FontAwesomeIcons.linkedin||
      ic==FontAwesomeIcons.gitAlt) return FaIcon(ic, color:c, size:sz);
  return Icon(ic, color:c, size:sz);
}

// ══════════════════════════════════════════════════════════════════
//  Buttons
// ══════════════════════════════════════════════════════════════════
class _GoldBtn extends StatefulWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _GoldBtn(this.label, this.icon, this.onTap);
  @override State<_GoldBtn> createState() => _GBState();
}
class _GBState extends State<_GoldBtn> {
  bool _h=false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor:SystemMouseCursors.click,
    onEnter:(_)=>setState(()=>_h=true),
    onExit:(_)=>setState(()=>_h=false),
    child:GestureDetector(onTap:widget.onTap,
      child:AnimatedContainer(
        duration:const Duration(milliseconds:190),
        transform:_h?(Matrix4.identity()..translate(0.0,-2.0)):Matrix4.identity(),
        padding:const EdgeInsets.symmetric(horizontal:24, vertical:13),
        decoration:BoxDecoration(
          gradient:LinearGradient(
            colors:_h?[kGoldSoft,kGold]:[kGold,const Color(0xFFB8902E)],
            begin:Alignment.topLeft, end:Alignment.bottomRight),
          borderRadius:BorderRadius.circular(40),
          boxShadow:[BoxShadow(
              color:kGold.withOpacity(_h?0.38:0.2),
              blurRadius:_h?20:10, offset:const Offset(0,5))]),
        child:Row(mainAxisSize:MainAxisSize.min, children:[
          _ico(widget.icon, kNight, 15),
          const SizedBox(width:9),
          Text(widget.label, style:GoogleFonts.dmSans(
              color:kNight, fontSize:14, fontWeight:FontWeight.w700)),
        ]),
      ),
    ),
  );
}

class _GhostBtn extends StatefulWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _GhostBtn(this.label, this.icon, this.onTap);
  @override State<_GhostBtn> createState() => _GhState();
}
class _GhState extends State<_GhostBtn> {
  bool _h=false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor:SystemMouseCursors.click,
    onEnter:(_)=>setState(()=>_h=true),
    onExit:(_)=>setState(()=>_h=false),
    child:GestureDetector(onTap:widget.onTap,
      child:AnimatedContainer(
        duration:const Duration(milliseconds:190),
        transform:_h?(Matrix4.identity()..translate(0.0,-2.0)):Matrix4.identity(),
        padding:const EdgeInsets.symmetric(horizontal:24, vertical:13),
        decoration:BoxDecoration(
          color:_h?kGold.withOpacity(0.07):Colors.transparent,
          borderRadius:BorderRadius.circular(40),
          border:Border.all(
            color:_h?kGold.withOpacity(0.45):kBorderHov, width:1.5)),
        child:Row(mainAxisSize:MainAxisSize.min, children:[
          _ico(widget.icon, _h?kGold:kCreamMid, 14),
          const SizedBox(width:9),
          Text(widget.label, style:GoogleFonts.dmSans(
              color:_h?kGold:kCreamMid,
              fontSize:14, fontWeight:FontWeight.w500)),
        ]),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Bouncing scroll arrow
// ══════════════════════════════════════════════════════════════════
class _ScrollArrow extends StatefulWidget {
  @override State<_ScrollArrow> createState() => _SAState();
}
class _SAState extends State<_ScrollArrow> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _dy;
  @override void initState() {
    super.initState();
    _c  = AnimationController(vsync:this,
        duration:const Duration(milliseconds:900))..repeat(reverse:true);
    _dy = Tween<double>(begin:0, end:7)
        .animate(CurvedAnimation(parent:_c, curve:Curves.easeInOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation:_c,
    builder:(_,__) => Transform.translate(
      offset:Offset(0,_dy.value),
      child:Icon(Icons.keyboard_arrow_down_rounded,
          color:kGold.withOpacity(0.4), size:26)),
  );
}

// ══════════════════════════════════════════════════════════════════
//  PORTFOLIO PAGE
// ══════════════════════════════════════════════════════════════════
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  @override State<PortfolioPage> createState() => _PPState();
}

class _PPState extends State<PortfolioPage> {
  final _scroll = ScrollController();
  bool _scrolled = false;

  final _heroKey    = GlobalKey();
  final _aboutKey   = GlobalKey();
  final _expKey     = GlobalKey();
  final _projKey    = GlobalKey();
  final _skillsKey  = GlobalKey();
  final _eduKey     = GlobalKey();
  final _contactKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scroll.addListener((){
      final s = _scroll.offset>50;
      if(s!=_scrolled) setState(()=>_scrolled=s);
      _scrollNotifier.value = _scroll.offset;
    });
  }
  @override void dispose() { _scroll.dispose(); super.dispose(); }

  void _to(GlobalKey k) {
    final c=k.currentContext;
    if(c!=null) Scrollable.ensureVisible(c,
        duration:const Duration(milliseconds:680),
        curve:Curves.easeInOutCubic);
  }
  Future<void> _open(String url) async {
    final u=Uri.parse(url);
    if(await canLaunchUrl(u)) await launchUrl(u, mode:LaunchMode.externalApplication);
  }

  // ── Shared helpers ─────────────────────────────────────────────
  Widget _bubble(IconData ic, Color c, {double sz=18}) => Container(
    padding:const EdgeInsets.all(10),
    decoration:BoxDecoration(
      color:c.withOpacity(0.11),
      borderRadius:BorderRadius.circular(12),
      border:Border.all(color:c.withOpacity(0.24))),
    child:_ico(ic,c,sz),
  );

  Widget _goldLine() => Container(width:42, height:2.5,
    decoration:BoxDecoration(
      gradient:const LinearGradient(colors:[kGold,kGoldSoft]),
      borderRadius:BorderRadius.circular(2)));

  Widget _secHead(String num, String title) => Column(
    crossAxisAlignment:CrossAxisAlignment.start,
    children:[
      Text(num, style:GoogleFonts.dmMono(
          color:kGold.withOpacity(0.32), fontSize:12, letterSpacing:3)),
      const SizedBox(height:6),
      Text(title, style:GoogleFonts.playfairDisplay(
          color:kCream, fontSize:34, fontWeight:FontWeight.w700, letterSpacing:-0.5)),
      const SizedBox(height:8),
      _goldLine(),
    ],
  );

  Widget _divider() => Container(height:1,
    decoration:BoxDecoration(gradient:LinearGradient(
        colors:[Colors.transparent,kBorderHov,Colors.transparent])));

  EdgeInsets _pad(bool mob) =>
      EdgeInsets.symmetric(horizontal:mob?22:88, vertical:mob?56:84);

  Widget _socialPill(IconData ic, String lbl, String url) {
    bool h=false;
    return StatefulBuilder(builder:(_,set)=>MouseRegion(
      cursor:SystemMouseCursors.click,
      onEnter:(_)=>set(()=>h=true),
      onExit:(_)=>set(()=>h=false),
      child:GestureDetector(onTap:()=>_open(url),
        child:AnimatedContainer(
          duration:const Duration(milliseconds:160),
          padding:const EdgeInsets.symmetric(horizontal:13, vertical:8),
          decoration:BoxDecoration(
            color:h?kGold.withOpacity(0.08):kCard.withOpacity(0.8),
            borderRadius:BorderRadius.circular(30),
            border:Border.all(color:h?kGold.withOpacity(0.38):kBorder)),
          child:Row(mainAxisSize:MainAxisSize.min, children:[
            _ico(ic, h?kGold:kCreamDim, 14),
            const SizedBox(width:7),
            Text(lbl, style:GoogleFonts.dmSans(
                color:h?kGold:kCreamMid, fontSize:13)),
          ]),
        ),
      ),
    ));
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final mob = w < 720;
    final nav = [
      ('About',_aboutKey),('Experience',_expKey),
      ('Projects',_projKey),('Skills',_skillsKey),
      ('Education',_eduKey),('Contact',_contactKey),
    ];

    return Scaffold(
      backgroundColor:kNight,
      appBar:PreferredSize(
        preferredSize:const Size.fromHeight(64),
        child:AnimatedContainer(
          duration:const Duration(milliseconds:280),
          decoration:BoxDecoration(
            color:_scrolled?kNavy.withOpacity(0.97):Colors.transparent,
            border:_scrolled
                ?Border(bottom:BorderSide(color:kBorder.withOpacity(0.7))):null,
            boxShadow:_scrolled
                ?[BoxShadow(color:Colors.black.withOpacity(0.22),blurRadius:18)]:[]
          ),
          child:SafeArea(child:Padding(
            padding:EdgeInsets.symmetric(horizontal:mob?20:52),
            child:Row(children:[
              Container(
                padding:const EdgeInsets.symmetric(horizontal:11,vertical:6),
                decoration:BoxDecoration(
                  color:kGold.withOpacity(0.1),
                  borderRadius:BorderRadius.circular(8),
                  border:Border.all(color:kGold.withOpacity(0.26))),
                child:RichText(text:TextSpan(children:[
                  TextSpan(text:'PJ', style:GoogleFonts.playfairDisplay(
                      color:kGold, fontSize:17, fontWeight:FontWeight.w700)),
                  TextSpan(text:'.dev', style:GoogleFonts.dmMono(
                      color:kCreamDim, fontSize:11)),
                ])),
              ),
              const Spacer(),
              if(!mob) ...nav.map((e)=>_NavLink(e.$1,()=>_to(e.$2))),
              if(!mob) const SizedBox(width:16),
              if(!mob) _GoldBtn('Resume', Icons.open_in_new_rounded,
                  ()=>_open(kResumeUrl)),
              if(mob) PopupMenuButton<int>(
                color:kCard,
                icon:Icon(Icons.menu_rounded, color:kCream),
                itemBuilder:(_)=>nav.asMap().entries.map((e)=>
                  PopupMenuItem(value:e.key, onTap:()=>_to(e.value.$2),
                    child:Text(e.value.$1,
                        style:GoogleFonts.dmSans(color:kCream)))).toList(),
              ),
            ]),
          )),
        ),
      ),
      body:SingleChildScrollView(
        controller:_scroll,
        child:Column(children:[
          _buildHero(mob),
          _buildAbout(mob),
          _buildExperience(mob),
          _buildProjects(mob),
          _buildSkills(mob),
          _buildEducation(mob),
          _buildContact(mob),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HERO
  // ══════════════════════════════════════════════════════════════
  Widget _buildHero(bool mob) => _MeshBg(child:Container(
    key:_heroKey,
    width:double.infinity,
    constraints:BoxConstraints(minHeight:MediaQuery.of(context).size.height),
    padding:EdgeInsets.fromLTRB(
        mob?22:88, mob?100:130, mob?22:88, mob?56:80),
    child:mob?_heroMob():_heroDesk(),
  ));

  Widget _heroDesk() => Row(
    crossAxisAlignment:CrossAxisAlignment.center,
    children:[
      Expanded(flex:11, child:_heroContent()),
      const SizedBox(width:52),
      Expanded(flex:7, child:ScrollReveal(
        delay:const Duration(milliseconds:350),
        fromY:0, fromX:18,
        child:Center(child:_Avatar(size:230)),
      )),
    ],
  );

  Widget _heroMob() => Column(
    crossAxisAlignment:CrossAxisAlignment.start,
    children:[
      Center(child:ScrollReveal(child:_Avatar(size:165))),
      const SizedBox(height:34),
      _heroContent(),
    ],
  );

  Widget _heroContent() => Column(
    crossAxisAlignment:CrossAxisAlignment.start,
    children:[
      // Achievement badges
      ScrollReveal(child:Wrap(spacing:10, runSpacing:8, children:[
        _badgePill('🏆','Elite Her Hackathon · Top 200 / 7000+ Teams'),
        _badgePill('🎖️','Campus Rep · Elite Coders SoC 2026'),
      ])),
      const SizedBox(height:16),

      // Available
      ScrollReveal(delay:const Duration(milliseconds:80), child:Container(
        padding:const EdgeInsets.symmetric(horizontal:13, vertical:6),
        decoration:BoxDecoration(
          color:kEmerald.withOpacity(0.08),
          borderRadius:BorderRadius.circular(30),
          border:Border.all(color:kEmerald.withOpacity(0.26))),
        child:Row(mainAxisSize:MainAxisSize.min, children:[
          const _PulseDot(),
          const SizedBox(width:9),
          Text('Open to Software Development Roles',
              style:GoogleFonts.dmSans(
                  color:kEmerald, fontSize:13, fontWeight:FontWeight.w500)),
        ]),
      )),
      const SizedBox(height:24),

      // Name
      ScrollReveal(delay:const Duration(milliseconds:150),
          child:_GoldShimmer('Prajakta\nGanesh Jadhav.', size:54)),
      const SizedBox(height:12),

      // Subtitle
      ScrollReveal(delay:const Duration(milliseconds:220),
        child:Row(children:[
          Container(width:24, height:2.5, decoration:const BoxDecoration(
              gradient:LinearGradient(colors:[kGold,kGoldSoft]))),
          const SizedBox(width:12),
          Flexible(child:Text(
            'Flutter Developer  ·  Mobile App Engineer  ·  AI Integration',
            style:GoogleFonts.dmSans(
                color:kGoldSoft, fontSize:14, fontWeight:FontWeight.w500),
          )),
        ]),
      ),
      const SizedBox(height:16),

      // Bio
      ScrollReveal(delay:const Duration(milliseconds:290),
        child:ConstrainedBox(
          constraints:const BoxConstraints(maxWidth:510),
          child:Text(
            'Final-year CSE student at SITS Pune. I build products that combine '
            'clean UI with meaningful functionality — especially AI-assisted systems '
            'and mobile productivity tools. Currently deepening expertise in '
            'LLM integration and scalable app architecture.',
            style:GoogleFonts.dmSans(color:kCreamMid, fontSize:15, height:1.8),
          ),
        ),
      ),
      const SizedBox(height:18),

      // Tech stack chips
      ScrollReveal(delay:const Duration(milliseconds:340),
        child:Wrap(spacing:7, runSpacing:6,
          children:['Flutter','Firebase','Dart','Java',
                    'Python','SQL','MongoDB','Gemini API']
            .map((t)=>Container(
              padding:const EdgeInsets.symmetric(horizontal:10, vertical:5),
              decoration:BoxDecoration(
                color:kGold.withOpacity(0.07),
                borderRadius:BorderRadius.circular(6),
                border:Border.all(color:kGold.withOpacity(0.18))),
              child:Text(t, style:GoogleFonts.dmMono(
                  color:kGoldSoft.withOpacity(0.82), fontSize:12)),
            )).toList()),
      ),
      const SizedBox(height:30),

      // CTA buttons
      ScrollReveal(delay:const Duration(milliseconds:400),
        child:Wrap(spacing:12, runSpacing:12, children:[
          _GoldBtn('View Projects', Icons.rocket_launch_outlined,
              ()=>_to(_projKey)),
          _GhostBtn('Download CV', Icons.download_outlined,
              ()=>_open(kResumeUrl)),
        ]),
      ),
      const SizedBox(height:24),

      // Socials
      ScrollReveal(delay:const Duration(milliseconds:460),
        child:Wrap(spacing:10, runSpacing:10, children:[
          _socialPill(FontAwesomeIcons.github,  'GitHub',   kGithubUrl),
          _socialPill(FontAwesomeIcons.linkedin,'LinkedIn', kLinkedinUrl),
          _socialPill(Icons.mail_outline,       'Email',    kEmailUrl),
        ]),
      ),
      const SizedBox(height:44),

      // Scroll hint
      ScrollReveal(delay:const Duration(milliseconds:520),
        child:Column(children:[
          Text('scroll to explore', style:GoogleFonts.dmMono(
              color:kCreamDim, fontSize:11, letterSpacing:2.5)),
          const SizedBox(height:6),
          _ScrollArrow(),
        ]),
      ),
    ],
  );

  Widget _badgePill(String emoji, String text) => Container(
    padding:const EdgeInsets.symmetric(horizontal:13, vertical:8),
    decoration:BoxDecoration(
      gradient:LinearGradient(colors:[
        const Color(0xFF78350F).withOpacity(0.42),
        const Color(0xFF92400E).withOpacity(0.16)]),
      borderRadius:BorderRadius.circular(30),
      border:Border.all(color:kGold.withOpacity(0.28))),
    child:Row(mainAxisSize:MainAxisSize.min, children:[
      Text(emoji, style:const TextStyle(fontSize:13)),
      const SizedBox(width:7),
      Flexible(child:Text(text,
          style:GoogleFonts.dmSans(
              color:kGoldSoft, fontSize:12, fontWeight:FontWeight.w600),
          overflow:TextOverflow.ellipsis, maxLines:1)),
    ]),
  );

  // ══════════════════════════════════════════════════════════════
  //  ABOUT
  // ══════════════════════════════════════════════════════════════
  Widget _buildAbout(bool mob) {
    const cards = [
      (Icons.phone_android_outlined, kGold,
          'Mobile App Development',
          'Flutter & Firebase — scalable, performant cross-platform apps with polished, responsive UI.'),
      (Icons.psychology_outlined, Color(0xFF8B5CF6),
          'AI-Assisted Systems',
          'Integrating Gemini API and ML pipelines into real products — from sentiment scoring to document fraud detection.'),
      (Icons.design_services_outlined, Color(0xFF22D3EE),
          'UI / UX Engineering',
          'Clean, accessible interfaces built with attention to motion, spacing, and usability across screen sizes.'),
    ];

    return Container(
      key:_aboutKey,
      color:kNavyMid,
      padding:_pad(mob),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        ScrollReveal(child:_secHead('01 — ABOUT','Who I Am')),
        const SizedBox(height:50),
        mob
          ?Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
              ScrollReveal(child:_whoCard()),
              const SizedBox(height:16),
              ...cards.asMap().entries.map((e)=>Padding(
                padding:const EdgeInsets.only(bottom:14),
                child:ScrollReveal(delay:Duration(milliseconds:80*(e.key+1)),
                    child:_hCard(e.value.$1,e.value.$2,e.value.$3,e.value.$4)))),
            ])
          :Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
              Expanded(flex:5, child:ScrollReveal(child:_whoCard())),
              const SizedBox(width:22),
              Expanded(flex:5, child:Column(children:
                cards.asMap().entries.map((e)=>Padding(
                  padding:const EdgeInsets.only(bottom:14),
                  child:ScrollReveal(delay:Duration(milliseconds:80*(e.key+1)),
                      child:_hCard(e.value.$1,e.value.$2,e.value.$3,e.value.$4)),
                )).toList())),
            ]),
      ]),
    );
  }

  Widget _whoCard() => _Card(
    child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      Text('THE STORY', style:GoogleFonts.dmMono(
          color:kGold.withOpacity(0.52), fontSize:11, letterSpacing:3)),
      const SizedBox(height:13),
      Text('Building Products\nThat Matter.',
          style:GoogleFonts.playfairDisplay(
              color:kCream, fontSize:23, fontWeight:FontWeight.w700, height:1.2)),
      const SizedBox(height:12),
      Text(
        'I enjoy building products that sit at the intersection of clean UI and '
        'meaningful functionality — especially AI-assisted tools and productivity '
        'apps. With 6 months of internship experience and 8+ shipped projects, '
        'I focus on maintainable, efficient code that solves real problems.',
        style:GoogleFonts.dmSans(color:kCreamMid, fontSize:14, height:1.85),
      ),
      const SizedBox(height:20),
      _divider(),
      const SizedBox(height:17),
      Row(children:[
        Expanded(child:_statTile('8+','Projects')),
        Container(width:1, height:40, color:kBorderHov),
        Expanded(child:_statTile('6 mo','Exp.')),
        Container(width:1, height:40, color:kBorderHov),
        Expanded(child:_statTile('9.8','SGPA')),
      ]),
    ]),
  );

  Widget _statTile(String n, String l) => Column(children:[
    ShaderMask(
      shaderCallback:(b) => const LinearGradient(
          colors:[kGold,kGoldSoft]).createShader(b),
      child:Text(n, style:GoogleFonts.playfairDisplay(
          color:Colors.white, fontSize:23, fontWeight:FontWeight.w700)),
    ),
    const SizedBox(height:3),
    Text(l, textAlign:TextAlign.center,
        style:GoogleFonts.dmSans(color:kCreamDim, fontSize:11)),
  ]);

  Widget _hCard(IconData ic, Color c, String title, String desc) =>
    _Card(glowColor:c, padding:const EdgeInsets.all(18),
      child:Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
        _bubble(ic,c),
        const SizedBox(width:14),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text(title, style:GoogleFonts.dmSans(
              color:kCream, fontSize:14, fontWeight:FontWeight.w700)),
          const SizedBox(height:5),
          Text(desc, style:GoogleFonts.dmSans(
              color:kCreamMid, fontSize:13, height:1.55)),
        ])),
      ]),
    );

  // ══════════════════════════════════════════════════════════════
  //  EXPERIENCE
  // ══════════════════════════════════════════════════════════════
  Widget _buildExperience(bool mob) => Container(
    key:_expKey,
    color:kNight,
    padding:_pad(mob),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      ScrollReveal(child:_secHead('02 — EXPERIENCE',"Where I've Worked")),
      const SizedBox(height:50),
      ScrollReveal(delay:const Duration(milliseconds:80),
        child:_expCard(Icons.work_outline, kGold,
          'Software Engineering Intern','Intern Labs','Jun 2025 – Sep 2025',[
          'Built and maintained cross-platform features in Flutter & Dart for a live production app.',
          'Integrated Firebase Auth, Firestore, and Cloud Functions with clean state management.',
          'Participated in code reviews, systematically reducing bug count through structured testing.',
        ])),
      const SizedBox(height:20),
      ScrollReveal(delay:const Duration(milliseconds:160),
        child:_expCard(Icons.developer_mode_outlined, const Color(0xFF22D3EE),
          'Flutter Developer Intern','Incubators System Pvt. Ltd','Aug 2024 – Oct 2024',[
          'Developed 3 pixel-accurate screens from Figma designs using Flutter & Dart.',
          'Implemented Firebase Authentication with secure login flows and session management.',
          'Collaborated on GitLab with a team of 5 using branching and merge-request workflow.',
        ])),
    ]),
  );

  Widget _expCard(IconData ic, Color c, String role, String company,
      String period, List<String> pts) => _Card(glowColor:c,
    child:Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
      _bubble(ic,c,sz:20),
      const SizedBox(width:20),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text(role, style:GoogleFonts.playfairDisplay(
            color:kCream, fontSize:18, fontWeight:FontWeight.w700)),
        const SizedBox(height:8),
        Wrap(spacing:10, runSpacing:6,
          crossAxisAlignment:WrapCrossAlignment.center,
          children:[
            Text(company, style:GoogleFonts.dmSans(
                color:c, fontSize:14, fontWeight:FontWeight.w600)),
            Container(
              padding:const EdgeInsets.symmetric(horizontal:10, vertical:3),
              decoration:BoxDecoration(
                color:c.withOpacity(0.09),
                borderRadius:BorderRadius.circular(20),
                border:Border.all(color:c.withOpacity(0.26))),
              child:Text(period, style:GoogleFonts.dmMono(
                  color:c.withOpacity(0.85), fontSize:11))),
          ]),
        const SizedBox(height:16),
        ...pts.map((p)=>Padding(
          padding:const EdgeInsets.only(bottom:8),
          child:Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
            Padding(padding:const EdgeInsets.only(top:8),
              child:Container(width:5,height:5,
                  decoration:BoxDecoration(shape:BoxShape.circle,color:c))),
            const SizedBox(width:12),
            Expanded(child:Text(p, style:GoogleFonts.dmSans(
                color:kCreamMid, fontSize:14, height:1.65))),
          ]),
        )),
      ])),
    ]),
  );

  // ══════════════════════════════════════════════════════════════
  //  PROJECTS — all 8, featured flagged, deploy-ready
  // ══════════════════════════════════════════════════════════════
  Widget _buildProjects(bool mob) {
    // To add a deployed link later: replace null with the URL string
    final projects = [
      _Proj(
        title:'TruthLens AI', featured:true,
        desc:'AI platform scoring social media content on effort, authenticity & context '
             'using Gemini API and sentiment analysis, with a decision-assistant chatbot '
             'for digital well-being and emotional awareness.',
        githubUrl:kGithubUrl, demoUrl:null,
        icon:Icons.remove_red_eye_outlined, color:const Color(0xFF22D3EE),
        tags:['Flutter','Firebase','Gemini API','Sentiment Analysis'],
      ),
      _Proj(
        title:'DocShield', featured:true,
        desc:'OCR-based document fraud detection pipeline automating authenticity '
             'validation, plagiarism detection, and real-time anomaly flagging — '
             'reducing manual verification effort significantly.',
        githubUrl:kGithubUrl, demoUrl:null,
        icon:Icons.verified_user_outlined, color:const Color(0xFFF43F5E),
        tags:['Python','AI/ML','OCR','Firebase'],
      ),
      _Proj(
        title:'PocketPilot', featured:true,
        desc:'Personal finance tracker with offline-first Sqflite storage, spending '
             'category analytics, interactive chart visualisations, dark mode, and '
             'personalised budgeting insights.',
        githubUrl:kGithubUrl, demoUrl:null,
        icon:Icons.auto_graph_outlined, color:kGold,
        tags:['Flutter','Sqflite','Charts','SharedPrefs'],
      ),
      _Proj(
        title:'SoulSync', featured:true,
        desc:'Matrimony platform with real-time chat, WebRTC video & voice calls, '
             'profile compatibility matching, and Firebase Authentication — serving '
             'a complete relationship-lifecycle feature set.',
        githubUrl:'https://github.com/prajaktajadhav177/soulsync', demoUrl:null,
        icon:Icons.favorite_border, color:const Color(0xFFEC4899),
        tags:['Flutter','Firebase','WebRTC','Firestore'],
      ),
      _Proj(
        title:'TaskFlow', featured:false,
        desc:'Collaborative project management platform with Kanban boards, sprint '
             'planning, real-time task assignment, priority management, and deadline '
             'tracking. Inspired by Jira.',
        githubUrl:kGithubUrl, demoUrl:null,
        icon:Icons.dashboard_outlined, color:const Color(0xFF818CF8),
        tags:['Flutter','Firebase','Real-time DB'],
      ),
      _Proj(
        title:'RentRider', featured:false,
        desc:'Vehicle booking app with Firebase Authentication, real-time booking '
             'management, smooth UI animations, and a clean multi-step booking flow.',
        githubUrl:'https://github.com/prajaktajadhav177/rent-rider', demoUrl:null,
        icon:Icons.directions_bike_outlined, color:const Color(0xFF4F46E5),
        tags:['Flutter','Firebase'],
      ),
      _Proj(
        title:'Expense Tracker', featured:false,
        desc:'Budget tracking web app with savings goals, category analytics, '
             'interactive visualisations, and dark mode toggle. Built with local storage.',
        githubUrl:'https://github.com/prajaktajadhav177/web-app-expence-tracker',
        demoUrl:null,
        icon:Icons.account_balance_wallet_outlined, color:const Color(0xFF10B981),
        tags:['Flutter','SQLite'],
      ),
      _Proj(
        title:'ToDo App', featured:false,
        desc:'Minimalist task manager with priority levels, categories, completion '
             'tracking, and daily progress overview. Built with Sqflite for offline use.',
        githubUrl:'https://github.com/prajaktajadhav177/Basic-todo-app', demoUrl:null,
        icon:Icons.check_circle_outline, color:const Color(0xFF6366F1),
        tags:['Flutter','Sqflite'],
      ),
    ];

    // Split: 4 featured + 4 more
    final featured = projects.where((p)=>p.featured).toList();
    final more     = projects.where((p)=>!p.featured).toList();

    return Container(
      key:_projKey,
      color:kNavyMid,
      padding:_pad(mob),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        ScrollReveal(child:_secHead('03 — PROJECTS','Featured Work')),
        const SizedBox(height:6),
        ScrollReveal(delay:const Duration(milliseconds:60),
          child:Text('Featured projects · all code & upcoming demos on GitHub',
              style:GoogleFonts.dmSans(
                  color:kCreamDim, fontSize:13, fontStyle:FontStyle.italic))),
        const SizedBox(height:46),

        // ── Featured 2×2 grid ──────────────────────────────────
        LayoutBuilder(builder:(_,bc){
          final cols = bc.maxWidth>760?2:1;
          final cw   = (bc.maxWidth-(cols-1)*20.0)/cols;
          return Wrap(spacing:20, runSpacing:20,
            children:featured.asMap().entries.map((e)=>ScrollReveal(
              delay:Duration(milliseconds:70*e.key),
              child:SizedBox(width:cw,
                  child:_ProjCard(p:e.value, open:_open)))).toList());
        }),

        const SizedBox(height:40),
        _divider(),
        const SizedBox(height:28),

        // ── More projects label ────────────────────────────────
        ScrollReveal(delay:const Duration(milliseconds:100),
          child:Row(children:[
            Container(width:3, height:16,
                color:kGold.withOpacity(0.5)),
            const SizedBox(width:10),
            Text('More Projects', style:GoogleFonts.playfairDisplay(
                color:kCream, fontSize:20, fontWeight:FontWeight.w700)),
          ]),
        ),
        const SizedBox(height:6),
        ScrollReveal(delay:const Duration(milliseconds:120),
          child:Text('Deployed links will appear here as apps go live',
              style:GoogleFonts.dmSans(
                  color:kCreamDim, fontSize:12, fontStyle:FontStyle.italic))),
        const SizedBox(height:20),

        // ── More 2×2 grid ─────────────────────────────────────
        LayoutBuilder(builder:(_,bc){
          final cols = bc.maxWidth>760?2:1;
          final cw   = (bc.maxWidth-(cols-1)*20.0)/cols;
          return Wrap(spacing:20, runSpacing:20,
            children:more.asMap().entries.map((e)=>ScrollReveal(
              delay:Duration(milliseconds:70*e.key),
              child:SizedBox(width:cw,
                  child:_ProjCard(p:e.value, open:_open)))).toList());
        }),

        const SizedBox(height:32),
        ScrollReveal(delay:const Duration(milliseconds:200),
          child:Center(child:_GhostBtn('View All Repositories',
              FontAwesomeIcons.github, ()=>_open(kGithubUrl)))),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SKILLS
  // ══════════════════════════════════════════════════════════════
  Widget _buildSkills(bool mob) {
    const groups = [
      _SGroup('Mobile & Frontend', kGold, [
        _Sk(Icons.flutter_dash,           'Flutter & Dart'),
        _Sk(Icons.phone_android_outlined, 'Cross-platform Dev'),
        _Sk(Icons.animation,              'Animations'),
        _Sk(Icons.web_outlined,           'Responsive UI/UX'),
      ]),
      _SGroup('Backend & Database', Color(0xFF22D3EE), [
        _Sk(Icons.cloud_outlined,         'Firebase'),
        _Sk(Icons.storage_outlined,       'SQL / SQLite / Sqflite'),
        _Sk(Icons.dataset_outlined,       'MongoDB'),
        _Sk(Icons.api_outlined,           'REST APIs'),
        _Sk(Icons.lock_outline,           'Auth & Security'),
        _Sk(Icons.save_outlined,          'SharedPreferences'),
      ]),
      _SGroup('AI & Emerging Tech', Color(0xFF8B5CF6), [
        _Sk(Icons.psychology_outlined,       'Gemini API'),
        _Sk(Icons.auto_awesome_outlined,     'LLM Integration'),
        _Sk(Icons.manage_search_outlined,    'Sentiment Analysis'),
        _Sk(Icons.document_scanner_outlined, 'OCR & Document AI'),
      ]),
      _SGroup('Languages', Color(0xFF10B981), [
        _Sk(Icons.code,              'Dart'),
        _Sk(Icons.terminal_outlined, 'Java'),
        _Sk(Icons.terminal_outlined, 'C++'),
        _Sk(Icons.code_outlined,     'Python'),
      ]),
      _SGroup('Tools & Workflow', Color(0xFFF59E0B), [
        _Sk(FontAwesomeIcons.gitAlt,        'Git / GitHub / GitLab'),
        _Sk(Icons.bug_report_outlined,      'Testing & Debugging'),
        _Sk(Icons.speed_outlined,           'Performance Tuning'),
        _Sk(Icons.design_services_outlined, 'UI/UX Design'),
      ]),
    ];

    return Container(
      key:_skillsKey,
      color:kNight,
      padding:_pad(mob),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        ScrollReveal(child:_secHead('04 — SKILLS','What I Work With')),
        const SizedBox(height:50),
        ...groups.asMap().entries.map((e)=>ScrollReveal(
          delay:Duration(milliseconds:70*e.key),
          child:Padding(padding:const EdgeInsets.only(bottom:28),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
              Row(children:[
                Container(width:3, height:15,
                  decoration:BoxDecoration(
                    gradient:LinearGradient(colors:[
                      e.value.color, e.value.color.withOpacity(0.12)],
                      begin:Alignment.topCenter, end:Alignment.bottomCenter),
                    borderRadius:BorderRadius.circular(2))),
                const SizedBox(width:10),
                Text(e.value.name, style:GoogleFonts.dmSans(
                    color:kCream, fontSize:14, fontWeight:FontWeight.w700)),
              ]),
              const SizedBox(height:12),
              Wrap(spacing:8, runSpacing:8,
                children:e.value.skills
                    .map((s)=>_SkillChip(s:s, c:e.value.color)).toList()),
            ]),
          ),
        )),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  EDUCATION & RECOGNITION — combined, no repetition
  // ══════════════════════════════════════════════════════════════
  Widget _buildEducation(bool mob) => Container(
    key:_eduKey,
    color:kNavyMid,
    padding:_pad(mob),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      ScrollReveal(child:_secHead('05 — EDUCATION & RECOGNITION','Background')),
      const SizedBox(height:50),

      // Degree
      ScrollReveal(delay:const Duration(milliseconds:80),
        child:_Card(child:Row(
          crossAxisAlignment:CrossAxisAlignment.start, children:[
          _bubble(Icons.school_outlined, kGold, sz:20),
          const SizedBox(width:20),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            Text('B.E. in Computer Science & Engineering',
                style:GoogleFonts.playfairDisplay(
                    color:kCream, fontSize:18, fontWeight:FontWeight.w700)),
            const SizedBox(height:5),
            Text('Sinhgad Institute of Technology & Science, Pune',
                style:GoogleFonts.dmSans(
                    color:kGoldSoft, fontSize:14, fontWeight:FontWeight.w600)),
            const SizedBox(height:3),
            Text('2022 – 2026',
                style:GoogleFonts.dmMono(color:kCreamDim, fontSize:12)),
            const SizedBox(height:12),
            Container(
              padding:const EdgeInsets.symmetric(horizontal:12, vertical:6),
              decoration:BoxDecoration(
                color:kEmerald.withOpacity(0.09),
                borderRadius:BorderRadius.circular(8),
                border:Border.all(color:kEmerald.withOpacity(0.26))),
              child:Text('SGPA: 9.8 / 10',
                  style:GoogleFonts.dmSans(
                      color:kEmerald, fontSize:13, fontWeight:FontWeight.w700)),
            ),
          ])),
        ])),
      ),
      const SizedBox(height:20),

      // Hackathon
      ScrollReveal(delay:const Duration(milliseconds:150),
        child:_achCard('🏆', kGold,
          'Elite Her Hackathon — Finalist',
          'Ranked Top 200 out of 7000+ participating teams nationally. '
          'Built TruthLens AI — an AI platform combating unhealthy social media '
          'comparison using Gemini API, sentiment analysis, and a context-aware chatbot.',
          null, null)),
      const SizedBox(height:16),

      // Campus Rep — with badge image link
      ScrollReveal(delay:const Duration(milliseconds:210),
        child:_achCard('🎖️', const Color(0xFF818CF8),
          'Campus Representative — Elite Coders SoC 2026',
          'Officially selected as Verified Campus Leader for SITS Pune. '
          'Responsible for onboarding students into open-source culture, '
          'managing campus registrations, and representing the college throughout the programme.',
          'View Badge', kBadgeUrl)),
    ]),
  );

  Widget _achCard(String emoji, Color c, String title, String desc,
      String? btnLabel, String? btnUrl) =>
    _Card(glowColor:c,
      child:Row(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Container(
          padding:const EdgeInsets.all(12),
          decoration:BoxDecoration(
            color:c.withOpacity(0.11),
            borderRadius:BorderRadius.circular(13),
            border:Border.all(color:c.withOpacity(0.26))),
          child:Text(emoji, style:const TextStyle(fontSize:22))),
        const SizedBox(width:18),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text(title, style:GoogleFonts.playfairDisplay(
              color:kCream, fontSize:17, fontWeight:FontWeight.w700)),
          const SizedBox(height:8),
          Text(desc, style:GoogleFonts.dmSans(
              color:kCreamMid, fontSize:13, height:1.7)),
          // Badge / link button
          if (btnLabel!=null && btnUrl!=null) ...[
            const SizedBox(height:14),
            GestureDetector(
              onTap:()=>_open(btnUrl),
              child:Container(
                padding:const EdgeInsets.symmetric(horizontal:14, vertical:7),
                decoration:BoxDecoration(
                  color:c.withOpacity(0.1),
                  borderRadius:BorderRadius.circular(20),
                  border:Border.all(color:c.withOpacity(0.35))),
                child:Row(mainAxisSize:MainAxisSize.min, children:[
                  Icon(Icons.open_in_new_rounded, color:c, size:14),
                  const SizedBox(width:6),
                  Text(btnLabel, style:GoogleFonts.dmSans(
                      color:c, fontSize:13, fontWeight:FontWeight.w600)),
                ]),
              ),
            ),
          ],
        ])),
      ]),
    );

  // ══════════════════════════════════════════════════════════════
  //  CONTACT
  // ══════════════════════════════════════════════════════════════
  Widget _buildContact(bool mob) => _MeshBg(child:Container(
    key:_contactKey,
    color:kNight.withOpacity(0.82),
    padding:EdgeInsets.symmetric(
        horizontal:mob?22:88, vertical:mob?60:92),
    child:Column(children:[
      ScrollReveal(child:Text("Let's Work\nTogether.",
        textAlign:TextAlign.center,
        style:GoogleFonts.playfairDisplay(
          color:kCream, fontSize:mob?40:54,
          fontWeight:FontWeight.w700, height:1.1, letterSpacing:-1.5),
      )),
      const SizedBox(height:16),
      ScrollReveal(delay:const Duration(milliseconds:80),
        child:Container(
          constraints:const BoxConstraints(maxWidth:640),
          padding:const EdgeInsets.symmetric(horizontal:24, vertical:18),
          decoration:BoxDecoration(
            color:kCard,
            borderRadius:BorderRadius.circular(14),
            border:Border.all(color:kBorderHov)),
          child:Text(
            'I am actively looking for software development and Flutter engineering '
            'opportunities where I can contribute to impactful products and grow as '
            'an engineer. Open to full-time roles, internships, and freelance collaborations.',
            textAlign:TextAlign.center,
            style:GoogleFonts.dmSans(color:kCreamMid, fontSize:15, height:1.72),
          ),
        ),
      ),
      const SizedBox(height:34),
      ScrollReveal(delay:const Duration(milliseconds:160),
        child:Wrap(spacing:13, runSpacing:13,
            alignment:WrapAlignment.center, children:[
          _GoldBtn('Email Me', Icons.email_outlined, ()=>_open(kEmailUrl)),
          _GhostBtn('LinkedIn', FontAwesomeIcons.linkedin, ()=>_open(kLinkedinUrl)),
          _GhostBtn('GitHub',   FontAwesomeIcons.github,   ()=>_open(kGithubUrl)),
        ]),
      ),
      const SizedBox(height:56),
      Container(height:1, decoration:BoxDecoration(gradient:LinearGradient(
          colors:[Colors.transparent,kGold.withOpacity(0.18),Colors.transparent]))),
      const SizedBox(height:22),
      Text('© 2025 Prajakta Ganesh Jadhav  ·  Built with Flutter',
          textAlign:TextAlign.center,
          style:GoogleFonts.dmMono(color:kCreamDim, fontSize:12)),
    ]),
  ));
}

// ─── Data models ──────────────────────────────────────────────────
class _Proj {
  final String title, desc, githubUrl;
  final String? demoUrl;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final bool featured;
  const _Proj({
    required this.title, required this.desc,
    required this.githubUrl, required this.demoUrl,
    required this.icon, required this.color,
    required this.tags, this.featured=false,
  });
}

class _SGroup {
  final String name;
  final Color color;
  final List<_Sk> skills;
  const _SGroup(this.name, this.color, this.skills);
}

class _Sk {
  final IconData icon;
  final String name;
  const _Sk(this.icon, this.name);
}