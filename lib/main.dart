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

// ══════════════════════════════════════════════════════════════════
//  Global scroll notifier
// ══════════════════════════════════════════════════════════════════
final _scrollNotifier = ValueNotifier<double>(0);

// ══════════════════════════════════════════════════════════════════
//  App
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
//  Subtle mesh bg — single slow drift, no dot grid (perf)
// ══════════════════════════════════════════════════════════════════
class _MeshPainter extends CustomPainter {
  final double t;
  const _MeshPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final pts = [
      Offset(size.width  * (0.18 + 0.06 * math.sin(t * 0.5)),
             size.height * (0.22 + 0.05 * math.cos(t * 0.4))),
      Offset(size.width  * (0.78 + 0.05 * math.cos(t * 0.45)),
             size.height * (0.18 + 0.06 * math.sin(t * 0.6))),
      Offset(size.width  * (0.55 + 0.07 * math.sin(t * 0.35)),
             size.height * (0.72 + 0.05 * math.cos(t * 0.5))),
    ];
    final colors  = [kGold, const Color(0xFF6366F1), const Color(0xFF0891B2)];
    final radii   = [size.width * 0.35, size.width * 0.28, size.width * 0.25];
    final opacity = [0.05, 0.04, 0.04];
    for (int i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], radii[i], Paint()
        ..shader = RadialGradient(colors: [
          colors[i].withOpacity(opacity[i]), colors[i].withOpacity(0)
        ]).createShader(Rect.fromCircle(center: pts[i], radius: radii[i])));
    }
  }
  @override
  bool shouldRepaint(_MeshPainter o) => o.t != t;
}

class _MeshBg extends StatefulWidget {
  final Widget child;
  const _MeshBg({required this.child});
  @override State<_MeshBg> createState() => _MeshBgState();
}
class _MeshBgState extends State<_MeshBg> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Stack(children: [
      Positioned.fill(child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
            painter: _MeshPainter(_c.value * 2 * math.pi)),
      )),
      widget.child,
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════
//  ScrollReveal — bidirectional, replay on scroll
// ══════════════════════════════════════════════════════════════════
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double fromY;
  final double fromX;
  const ScrollReveal({super.key, required this.child,
      this.delay = Duration.zero, this.fromY = 32, this.fromX = 0});
  @override State<ScrollReveal> createState() => _ScrollRevealState();
}
class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Animation<double>?   _op, _dy, _dx;

  @override
  void initState() {
    super.initState();
    final c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 650));
    _ctrl = c;
    _op   = CurvedAnimation(parent: c, curve: Curves.easeOut);
    _dy   = Tween<double>(begin: widget.fromY, end: 0)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    _dx   = Tween<double>(begin: widget.fromX, end: 0)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    c.value = 0;
    _scrollNotifier.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override void dispose() {
    _scrollNotifier.removeListener(_check);
    _ctrl?.dispose();
    super.dispose();
  }

  void _check() {
    if (!mounted) return;
    final c = _ctrl; if (c == null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final top    = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;
    final sh     = MediaQuery.of(context).size.height;
    final inView = top < sh * 0.90 && bottom > 0;
    if (inView  && c.status == AnimationStatus.dismissed) {
      Future.delayed(widget.delay, () { if (mounted) c.forward(); });
    } else if (!inView && c.status == AnimationStatus.completed) {
      c.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _ctrl; final op = _op; final dy = _dy; final dx = _dx;
    if (c == null || op == null || dy == null || dx == null) return widget.child;
    return AnimatedBuilder(
      animation: c,
      builder: (_, child) => Opacity(opacity: op.value,
        child: Transform.translate(
            offset: Offset(dx.value, dy.value), child: child)),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Pulsing availability dot
// ══════════════════════════════════════════════════════════════════
class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override State<_PulseDot> createState() => _PulseDotState();
}
class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Stack(alignment: Alignment.center, children: [
      Container(width: 14, height: 14, decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kEmerald.withOpacity(0.15 + 0.18 * _c.value))),
      Container(width: 7, height: 7, decoration: const BoxDecoration(
          shape: BoxShape.circle, color: kEmerald)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Gold shimmer text (hero name only)
// ══════════════════════════════════════════════════════════════════
class _GoldShimmer extends StatefulWidget {
  final String text;
  final double size;
  final TextAlign align;
  const _GoldShimmer(this.text,
      {this.size = 56, this.align = TextAlign.start});
  @override State<_GoldShimmer> createState() => _GoldShimmerState();
}
class _GoldShimmerState extends State<_GoldShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(seconds: 6))..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, __) => ShaderMask(
        shaderCallback: (b) => LinearGradient(
          colors: const [kGold, kGoldSoft,
              Color(0xFFFFECA0), kGold, kGoldSoft, kGold],
          stops: const [0, 0.2, 0.4, 0.6, 0.8, 1.0],
          begin: Alignment(_c.value * 4 - 2, -0.3),
          end:   Alignment(_c.value * 4,      0.3),
          tileMode: TileMode.mirror,
        ).createShader(b),
        child: Text(widget.text,
          textAlign: widget.align,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white, fontSize: widget.size,
            fontWeight: FontWeight.w700, height: 1.05, letterSpacing: -1.5)),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Clean avatar — static ring (no rotation for perf & clean look)
// ══════════════════════════════════════════════════════════════════
class _Avatar extends StatelessWidget {
  final double size;
  const _Avatar({this.size = 220});
  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      // Outer soft glow ring
      Container(
        width: size + 24, height: size + 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: kGold.withOpacity(0.15),
                blurRadius: 36, spreadRadius: 4),
          ],
        ),
      ),
      // Gold gradient border ring
      Container(
        width: size + 12, height: size + 12,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(colors: [
            kGold, kGoldSoft, Color(0xFF6366F1), kGold,
          ]),
        ),
      ),
      // Dark gap
      Container(
        width: size + 4, height: size + 4,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: kNight),
      ),
      // Photo
      CircleAvatar(
        radius: size / 2,
        backgroundImage: const AssetImage('assets/profile.jpeg'),
        backgroundColor: kNavy,
      ),
      // Small accent dot at top-right
      Positioned(
        top: 8, right: 8,
        child: Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: kEmerald,
            border: Border.all(color: kNight, width: 2),
            boxShadow: [BoxShadow(
                color: kEmerald.withOpacity(0.6), blurRadius: 8)],
          ),
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════
//  Hover lift card
// ══════════════════════════════════════════════════════════════════
class _Card extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsets padding;
  final double radius;
  const _Card({required this.child,
      this.glowColor = kGold,
      this.padding   = const EdgeInsets.all(26),
      this.radius    = 18});
  @override State<_Card> createState() => _CardState();
}
class _CardState extends State<_Card> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      transform: _h
          ? (Matrix4.identity()..translate(0.0, -5.0))
          : Matrix4.identity(),
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        color: _h ? kCardHov : kCard,
        border: Border.all(
          color: _h ? widget.glowColor.withOpacity(0.45) : kBorder,
          width: 1.5,
        ),
        boxShadow: _h
            ? [
                BoxShadow(color: widget.glowColor.withOpacity(0.14),
                    blurRadius: 28, offset: const Offset(0, 10)),
                BoxShadow(color: Colors.black.withOpacity(0.4),
                    blurRadius: 16, offset: const Offset(0, 6)),
              ]
            : [BoxShadow(color: Colors.black.withOpacity(0.3),
                  blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: widget.child,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Project card
// ══════════════════════════════════════════════════════════════════
class _ProjCard extends StatefulWidget {
  final _Proj p;
  final Future<void> Function(String) open;
  const _ProjCard({required this.p, required this.open});
  @override State<_ProjCard> createState() => _ProjCardState();
}
class _ProjCardState extends State<_ProjCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit:  (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        transform: _h
            ? (Matrix4.identity()..translate(0.0, -6.0))
            : Matrix4.identity(),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: _h ? kCardHov : kCard,
          border: Border.all(
            color: _h ? p.color.withOpacity(0.5) : kBorder, width: 1.5),
          boxShadow: _h
              ? [
                  BoxShadow(color: p.color.withOpacity(0.15),
                      blurRadius: 32, offset: const Offset(0, 12)),
                  BoxShadow(color: Colors.black.withOpacity(0.4),
                      blurRadius: 16, offset: const Offset(0, 6)),
                ]
              : [BoxShadow(color: Colors.black.withOpacity(0.3),
                    blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: p.color.withOpacity(_h ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.color.withOpacity(0.3)),
              ),
              child: _ico(p.icon, p.color, 20),
            ),
            const Spacer(),
            // GitHub link
            _linkBtn(FontAwesomeIcons.github, 'Code', p.url, p.color, _h),
            if (p.demoUrl != null) ...[
              const SizedBox(width: 8),
              _linkBtn(Icons.open_in_new_rounded, 'Demo', p.demoUrl!, kGold, _h),
            ],
          ]),
          const SizedBox(height: 16),
          Text(p.title, style: GoogleFonts.playfairDisplay(
              color: kCream, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(p.desc, style: GoogleFonts.dmSans(
              color: kCreamMid, fontSize: 13, height: 1.65)),
          const SizedBox(height: 14),
          Wrap(spacing: 6, runSpacing: 6, children: p.tags.map((t) =>
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: p.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.color.withOpacity(0.25)),
              ),
              child: Text(t, style: GoogleFonts.dmMono(
                  color: p.color, fontSize: 11, fontWeight: FontWeight.w600)),
            )).toList()),
        ]),
      ),
    );
  }

  Widget _linkBtn(IconData ic, String lbl, String url, Color c, bool hov) =>
    GestureDetector(
      onTap: () => widget.open(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: hov ? c.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: hov ? c.withOpacity(0.4) : kBorderHov),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _ico(ic, hov ? c : kCreamDim, 11),
          const SizedBox(width: 4),
          Text(lbl, style: GoogleFonts.dmMono(
              color: hov ? c : kCreamDim, fontSize: 10,
              fontWeight: FontWeight.w600)),
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
  @override State<_SkillChip> createState() => _SkillChipState();
}
class _SkillChipState extends State<_SkillChip> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      transform: _h
          ? (Matrix4.identity()..translate(0.0, -2.0))
          : Matrix4.identity(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _h ? widget.c.withOpacity(0.1) : kNavy,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: _h ? widget.c.withOpacity(0.45) : kBorder),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _ico(widget.s.icon, _h ? widget.c : kCreamDim, 13),
        const SizedBox(width: 8),
        Text(widget.s.name, style: GoogleFonts.dmSans(
            color: _h ? kCream : kCreamMid, fontSize: 13,
            fontWeight: FontWeight.w500)),
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
  @override State<_NavLink> createState() => _NavLinkState();
}
class _NavLinkState extends State<_NavLink> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.label, style: GoogleFonts.dmSans(
              color: _h ? kGold : kCreamMid,
              fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            width: _h ? 18 : 0, height: 2,
            color: kGold,
          ),
        ]),
      ),
    ),
  );
}

// ═══ Shared icon helper ════════════════════════════════════════════
Widget _ico(IconData ic, Color c, double sz) {
  if (ic == FontAwesomeIcons.github ||
      ic == FontAwesomeIcons.linkedin ||
      ic == FontAwesomeIcons.gitAlt) return FaIcon(ic, color: c, size: sz);
  return Icon(ic, color: c, size: sz);
}

// ══════════════════════════════════════════════════════════════════
//  Buttons
// ══════════════════════════════════════════════════════════════════
class _GoldBtn extends StatefulWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _GoldBtn(this.label, this.icon, this.onTap);
  @override State<_GoldBtn> createState() => _GoldBtnState();
}
class _GoldBtnState extends State<_GoldBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        transform: _h ? (Matrix4.identity()..translate(0.0, -2.0)) : Matrix4.identity(),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _h ? [kGoldSoft, kGold] : [kGold, const Color(0xFFB8902E)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(
              color: kGold.withOpacity(_h ? 0.4 : 0.22),
              blurRadius: _h ? 22 : 12, offset: const Offset(0, 5))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _ico(widget.icon, kNight, 16),
          const SizedBox(width: 9),
          Text(widget.label, style: GoogleFonts.dmSans(
              color: kNight, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
  );
}

class _GhostBtn extends StatefulWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _GhostBtn(this.label, this.icon, this.onTap);
  @override State<_GhostBtn> createState() => _GhostBtnState();
}
class _GhostBtnState extends State<_GhostBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        transform: _h ? (Matrix4.identity()..translate(0.0, -2.0)) : Matrix4.identity(),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          color: _h ? kGold.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
              color: _h ? kGold.withOpacity(0.5) : kBorderHov, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _ico(widget.icon, _h ? kGold : kCreamMid, 15),
          const SizedBox(width: 9),
          Text(widget.label, style: GoogleFonts.dmSans(
              color: _h ? kGold : kCreamMid,
              fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Bouncing scroll arrow
// ══════════════════════════════════════════════════════════════════
class _ScrollArrow extends StatefulWidget {
  @override State<_ScrollArrow> createState() => _ScrollArrowState();
}
class _ScrollArrowState extends State<_ScrollArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _dy;
  @override void initState() {
    super.initState();
    _c  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _dy = Tween<double>(begin: 0, end: 7)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Transform.translate(
      offset: Offset(0, _dy.value),
      child: Icon(Icons.keyboard_arrow_down_rounded,
          color: kGold.withOpacity(0.45), size: 26),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  MAIN PAGE
// ══════════════════════════════════════════════════════════════════
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  @override State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
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
    _scroll.addListener(() {
      final s = _scroll.offset > 50;
      if (s != _scrolled) setState(() => _scrolled = s);
      _scrollNotifier.value = _scroll.offset;
    });
  }
  @override void dispose() { _scroll.dispose(); super.dispose(); }

  void _to(GlobalKey k) {
    final c = k.currentContext;
    if (c != null) Scrollable.ensureVisible(c,
        duration: const Duration(milliseconds: 680),
        curve: Curves.easeInOutCubic);
  }

  Future<void> _open(String url) async {
    final u = Uri.parse(url);
    if (await canLaunchUrl(u)) await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  // ── Shared helpers ─────────────────────────────────────────────
  Widget _bubble(IconData ic, Color c, {double sz = 18}) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.25)),
    ),
    child: _ico(ic, c, sz),
  );

  Widget _goldLine() => Container(
    width: 44, height: 2.5,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [kGold, kGoldSoft]),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _secHead(String num, String title) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(num, style: GoogleFonts.dmMono(
          color: kGold.withOpacity(0.35), fontSize: 12, letterSpacing: 3)),
      const SizedBox(height: 6),
      Text(title, style: GoogleFonts.playfairDisplay(
          color: kCream, fontSize: 36, fontWeight: FontWeight.w700,
          letterSpacing: -0.5)),
      const SizedBox(height: 8),
      _goldLine(),
    ],
  );

  Widget _divider() => Container(height: 1,
    decoration: BoxDecoration(gradient: LinearGradient(
        colors: [Colors.transparent, kBorderHov, Colors.transparent])));

  EdgeInsets _pad(bool mob) =>
      EdgeInsets.symmetric(horizontal: mob ? 22 : 88, vertical: mob ? 56 : 84);

  Widget _socialPill(IconData ic, String lbl, String url) {
    bool h = false;
    return StatefulBuilder(builder: (_, set) => MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => set(() => h = true),
      onExit:  (_) => set(() => h = false),
      child: GestureDetector(
        onTap: () => _open(url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: h ? kGold.withOpacity(0.08) : kCard.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: h ? kGold.withOpacity(0.4) : kBorder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _ico(ic, h ? kGold : kCreamDim, 14),
            const SizedBox(width: 7),
            Text(lbl, style: GoogleFonts.dmSans(
                color: h ? kGold : kCreamMid, fontSize: 13)),
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
      ('About', _aboutKey), ('Experience', _expKey),
      ('Projects', _projKey), ('Skills', _skillsKey),
      ('Education', _eduKey), ('Contact', _contactKey),
    ];

    return Scaffold(
      backgroundColor: kNight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          decoration: BoxDecoration(
            color: _scrolled ? kNavy.withOpacity(0.97) : Colors.transparent,
            border: _scrolled
                ? Border(bottom: BorderSide(color: kBorder.withOpacity(0.7)))
                : null,
            boxShadow: _scrolled
                ? [BoxShadow(color: Colors.black.withOpacity(0.25),
                      blurRadius: 20)]
                : [],
          ),
          child: SafeArea(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mob ? 20 : 52),
            child: Row(children: [
              // Logo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kGold.withOpacity(0.28)),
                ),
                child: RichText(text: TextSpan(children: [
                  TextSpan(text: 'PJ', style: GoogleFonts.playfairDisplay(
                      color: kGold, fontSize: 17, fontWeight: FontWeight.w700)),
                  TextSpan(text: '.dev', style: GoogleFonts.dmMono(
                      color: kCreamDim, fontSize: 11)),
                ])),
              ),
              const Spacer(),
              if (!mob) ...nav.map((e) => _NavLink(e.$1, () => _to(e.$2))),
              if (!mob) const SizedBox(width: 16),
              if (!mob) _GoldBtn('Resume', Icons.open_in_new_rounded,
                  () => _open('https://drive.google.com/file/d/1E8RWsutVJJildojM9LvyOBeyFZSnWuOr/view?usp=drive_link')),
              if (mob) PopupMenuButton<int>(
                color: kCard,
                icon: Icon(Icons.menu_rounded, color: kCream),
                itemBuilder: (_) => nav.asMap().entries.map((e) =>
                  PopupMenuItem(value: e.key, onTap: () => _to(e.value.$2),
                    child: Text(e.value.$1,
                        style: GoogleFonts.dmSans(color: kCream)))).toList(),
              ),
            ]),
          )),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scroll,
        child: Column(children: [
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
  Widget _buildHero(bool mob) => _MeshBg(
    child: Container(
      key: _heroKey,
      width: double.infinity,
      constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height),
      padding: EdgeInsets.fromLTRB(
          mob ? 22 : 88, mob ? 100 : 130,
          mob ? 22 : 88, mob ? 56 : 80),
      child: mob ? _heroMob() : _heroDesk(),
    ),
  );

  Widget _heroDesk() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(flex: 11, child: _heroContent()),
      const SizedBox(width: 52),
      Expanded(flex: 7, child: ScrollReveal(
        delay: const Duration(milliseconds: 350),
        fromY: 0, fromX: 18,
        child: Center(child: _Avatar(size: 240)),
      )),
    ],
  );

  Widget _heroMob() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(child: ScrollReveal(child: _Avatar(size: 170))),
      const SizedBox(height: 36),
      _heroContent(),
    ],
  );

  Widget _heroContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Achievement badges
      ScrollReveal(child: Wrap(spacing: 10, runSpacing: 8, children: [
        _badgePill('🏆', 'Elite Her Hackathon · Top 200 / 7000+ Teams'),
        _badgePill('🎖️', 'Campus Rep · Elite Coders SoC 2026'),
      ])),
      const SizedBox(height: 18),

      // Available pill
      ScrollReveal(delay: const Duration(milliseconds: 80), child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: kEmerald.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: kEmerald.withOpacity(0.28)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const _PulseDot(),
          const SizedBox(width: 9),
          Text('Open to Software Development Roles',
              style: GoogleFonts.dmSans(
                  color: kEmerald, fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      )),
      const SizedBox(height: 26),

      // Name
      ScrollReveal(delay: const Duration(milliseconds: 150),
          child: _GoldShimmer('Prajakta\nGanesh Jadhav.', size: 56)),
      const SizedBox(height: 14),

      // Title
      ScrollReveal(delay: const Duration(milliseconds: 220), child: Row(children: [
        Container(width: 24, height: 2.5,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [kGold, kGoldSoft]))),
        const SizedBox(width: 12),
        Flexible(child: Text(
          'Flutter Developer  ·  Mobile App Engineer  ·  AI Integration',
          style: GoogleFonts.dmSans(
              color: kGoldSoft, fontSize: 15, fontWeight: FontWeight.w500),
        )),
      ])),
      const SizedBox(height: 18),

      // Bio — personal & specific
      ScrollReveal(delay: const Duration(milliseconds: 290),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Final-year CSE student at SITS Pune. I enjoy building products that '
            'combine clean UI with meaningful functionality — especially in '
            'AI-assisted systems and mobile productivity tools. Currently '
            'deepening expertise in LLM integration and scalable app architecture.',
            style: GoogleFonts.dmSans(
                color: kCreamMid, fontSize: 15, height: 1.8),
          ),
        ),
      ),
      const SizedBox(height: 20),

      // Tech stack strip
      ScrollReveal(delay: const Duration(milliseconds: 340),
        child: Wrap(spacing: 8, runSpacing: 6, children: [
          'Flutter', 'Firebase', 'Dart', 'Java',
          'Python', 'SQL', 'MongoDB', 'Gemini API',
        ].map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: kGold.withOpacity(0.07),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kGold.withOpacity(0.2)),
          ),
          child: Text(t, style: GoogleFonts.dmMono(
              color: kGoldSoft.withOpacity(0.85), fontSize: 12)),
        )).toList()),
      ),
      const SizedBox(height: 32),

      // CTA buttons
      ScrollReveal(delay: const Duration(milliseconds: 400),
        child: Wrap(spacing: 12, runSpacing: 12, children: [
          _GoldBtn('View Projects', Icons.rocket_launch_outlined,
              () => _to(_projKey)),
          _GhostBtn('Download CV', Icons.download_outlined,
              () => _open('https://drive.google.com/file/d/1E8RWsutVJJildojM9LvyOBeyFZSnWuOr/view?usp=drive_link')),
        ]),
      ),
      const SizedBox(height: 26),

      // Social links
      ScrollReveal(delay: const Duration(milliseconds: 470),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          _socialPill(FontAwesomeIcons.github, 'GitHub',
              'https://github.com/prajaktajadhav177'),
          _socialPill(FontAwesomeIcons.linkedin, 'LinkedIn',
              'https://www.linkedin.com/in/prajakta-jadhav-37484a260/'),
          _socialPill(Icons.mail_outline, 'Email',
              'mailto:prajaktajadhav177@gmail.com'),
        ]),
      ),
      const SizedBox(height: 48),

      // Scroll hint
      ScrollReveal(delay: const Duration(milliseconds: 540),
        child: Column(children: [
          Text('scroll to explore', style: GoogleFonts.dmMono(
              color: kCreamDim, fontSize: 11, letterSpacing: 2.5)),
          const SizedBox(height: 6),
          _ScrollArrow(),
        ]),
      ),
    ],
  );

  Widget _badgePill(String emoji, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        const Color(0xFF78350F).withOpacity(0.45),
        const Color(0xFF92400E).withOpacity(0.18),
      ]),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: kGold.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 8),
      Flexible(child: Text(text, style: GoogleFonts.dmSans(
          color: kGoldSoft, fontSize: 12, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis, maxLines: 1)),
    ]),
  );

  // ══════════════════════════════════════════════════════════════
  //  ABOUT
  // ══════════════════════════════════════════════════════════════
  Widget _buildAbout(bool mob) {
    const cards = [
      (Icons.phone_android_outlined, kGold,
          'Mobile App Development',
          'Specialising in Flutter & Firebase to build scalable, performant cross-platform apps with polished UI.'),
      (Icons.psychology_outlined, Color(0xFF8B5CF6),
          'AI-Assisted Systems',
          'Integrating LLMs (Gemini API) and ML pipelines into real products — from sentiment scoring to document fraud detection.'),
      (Icons.design_services_outlined, Color(0xFF22D3EE),
          'UI / UX Engineering',
          'Clean, accessible, responsive interfaces built with attention to motion, spacing, and usability.'),
    ];

    return Container(
      key: _aboutKey,
      color: kNavyMid,
      padding: _pad(mob),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ScrollReveal(child: _secHead('01 — ABOUT', 'Who I Am')),
        const SizedBox(height: 52),
        mob
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ScrollReveal(child: _whoCard()),
              const SizedBox(height: 16),
              ...cards.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ScrollReveal(
                    delay: Duration(milliseconds: 80 * (e.key + 1)),
                    child: _hCard(e.value.$1, e.value.$2,
                        e.value.$3, e.value.$4)))),
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: ScrollReveal(child: _whoCard())),
              const SizedBox(width: 22),
              Expanded(flex: 5, child: Column(children:
                cards.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ScrollReveal(
                      delay: Duration(milliseconds: 80 * (e.key + 1)),
                      child: _hCard(e.value.$1, e.value.$2,
                          e.value.$3, e.value.$4)),
                )).toList())),
            ]),
      ]),
    );
  }

  Widget _whoCard() => _Card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('THE STORY', style: GoogleFonts.dmMono(
          color: kGold.withOpacity(0.55), fontSize: 11, letterSpacing: 3)),
      const SizedBox(height: 14),
      Text('Building Products\nThat Matter.',
          style: GoogleFonts.playfairDisplay(
              color: kCream, fontSize: 24,
              fontWeight: FontWeight.w700, height: 1.2)),
      const SizedBox(height: 12),
      Text(
        'I enjoy building products that sit at the intersection of clean UI and '
        'meaningful functionality — especially AI-assisted tools and productivity '
        'apps. With 6 months of internship experience and 8+ shipped projects, '
        'I focus on writing maintainable, efficient code that solves real problems.',
        style: GoogleFonts.dmSans(color: kCreamMid, fontSize: 14, height: 1.85),
      ),
      const SizedBox(height: 22),
      _divider(),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: _statTile('8+', 'Projects')),
        Container(width: 1, height: 40, color: kBorderHov),
        Expanded(child: _statTile('6 mo', 'Exp.')),
        Container(width: 1, height: 40, color: kBorderHov),
        Expanded(child: _statTile('9.8', 'SGPA')),
      ]),
    ]),
  );

  Widget _statTile(String n, String l) => Column(children: [
    ShaderMask(
      shaderCallback: (b) => const LinearGradient(
          colors: [kGold, kGoldSoft]).createShader(b),
      child: Text(n, style: GoogleFonts.playfairDisplay(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
    ),
    const SizedBox(height: 3),
    Text(l, textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(color: kCreamDim, fontSize: 11)),
  ]);

  Widget _hCard(IconData ic, Color c, String title, String desc) =>
      _Card(glowColor: c, padding: const EdgeInsets.all(18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _bubble(ic, c),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.dmSans(
                color: kCream, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(desc, style: GoogleFonts.dmSans(
                color: kCreamMid, fontSize: 13, height: 1.55)),
          ])),
        ]),
      );

  // ══════════════════════════════════════════════════════════════
  //  EXPERIENCE
  // ══════════════════════════════════════════════════════════════
  Widget _buildExperience(bool mob) => Container(
    key: _expKey,
    color: kNight,
    padding: _pad(mob),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ScrollReveal(child: _secHead('02 — EXPERIENCE', 'Where I\'ve Worked')),
      const SizedBox(height: 52),
      ScrollReveal(delay: const Duration(milliseconds: 80),
        child: _expCard(
          Icons.work_outline, kGold,
          'Software Engineering Intern', 'Intern Labs',
          'Jun 2025 – Sep 2025',
          [
            'Built and maintained cross-platform features in Flutter & Dart for a live production app.',
            'Integrated Firebase Auth, Firestore, and Cloud Functions with clean state management.',
            'Reduced bug count by 30% through systematic testing and code review participation.',
          ],
        )),
      const SizedBox(height: 20),
      ScrollReveal(delay: const Duration(milliseconds: 160),
        child: _expCard(
          Icons.developer_mode_outlined, const Color(0xFF22D3EE),
          'Flutter Developer Intern', 'Incubators System Pvt. Ltd',
          'Aug 2024 – Oct 2024',
          [
            'Developed 3 cross-platform screens from Figma designs with pixel-accurate layouts.',
            'Implemented Firebase Authentication with secure login flows and session management.',
            'Collaborated on GitLab with a team of 5 using branching and merge-request workflow.',
          ],
        )),
    ]),
  );

  Widget _expCard(IconData ic, Color c, String role, String company,
      String period, List<String> pts) => _Card(glowColor: c,
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _bubble(ic, c, sz: 20),
      const SizedBox(width: 20),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(role, style: GoogleFonts.playfairDisplay(
            color: kCream, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(company, style: GoogleFonts.dmSans(
                color: c, fontSize: 14, fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: c.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.withOpacity(0.28)),
              ),
              child: Text(period, style: GoogleFonts.dmMono(
                  color: c.withOpacity(0.85), fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...pts.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(top: 8),
              child: Container(width: 5, height: 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: c))),
            const SizedBox(width: 12),
            Expanded(child: Text(p, style: GoogleFonts.dmSans(
                color: kCreamMid, fontSize: 14, height: 1.65))),
          ]),
        )),
      ])),
    ]),
  );

  // ══════════════════════════════════════════════════════════════
  //  PROJECTS — 4 featured + "more on GitHub" button
  // ══════════════════════════════════════════════════════════════
  Widget _buildProjects(bool mob) {
    final projects = [
      _Proj(
        'TruthLens AI',
        'AI platform that scores social media content on effort, authenticity & context using Gemini API and sentiment analysis — with a decision-assistant chatbot for digital well-being.',
        'https://github.com/prajaktajadhav177/truthlens-ai',
        null,
        Icons.remove_red_eye_outlined,
        const Color(0xFF22D3EE),
        ['Flutter', 'Firebase', 'Gemini API', 'Sentiment Analysis'],
      ),
      _Proj(
        'DocShield',
        'OCR-based document fraud detection pipeline that automates authenticity validation, plagiarism detection, and anomaly flagging — reducing manual verification effort significantly.',
        'https://github.com/prajaktajadhav177',
        null,
        Icons.verified_user_outlined,
        const Color(0xFFF43F5E),
        ['Python', 'AI/ML', 'OCR', 'Firebase'],
      ),
      _Proj(
        'PocketPilot',
        'Personal finance tracker supporting offline-first storage via Sqflite, category analytics, interactive visualisations, and spending trend insights for smarter budgeting.',
        'https://github.com/prajaktajadhav177/PocketPilot',
        null,
        Icons.auto_graph_outlined,
        kGold,
        ['Flutter', 'Sqflite', 'Charts', 'SharedPrefs'],
      ),
      _Proj(
        'SoulSync',
        'Matrimony platform with real-time chat, WebRTC video & voice calls, profile compatibility matching, and Firebase Authentication — serving complete relationship lifecycle features.',
        'https://github.com/prajaktajadhav177/soulsync',
        null,
        Icons.favorite_border,
        const Color(0xFFEC4899),
        ['Flutter', 'Firebase', 'WebRTC', 'Firestore'],
      ),
    ];

    return Container(
      key: _projKey,
      color: kNavyMid,
      padding: _pad(mob),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ScrollReveal(child: _secHead('03 — PROJECTS', 'Featured Work')),
        const SizedBox(height: 6),
        ScrollReveal(delay: const Duration(milliseconds: 60),
          child: Text('Four selected projects  ·  all code on GitHub',
              style: GoogleFonts.dmSans(
                  color: kCreamDim, fontSize: 14,
                  fontStyle: FontStyle.italic))),
        const SizedBox(height: 48),
        LayoutBuilder(builder: (_, bc) {
          final cols = bc.maxWidth > 860 ? 2 : 1;
          final cw   = (bc.maxWidth - (cols - 1) * 20.0) / cols;
          return Wrap(spacing: 20, runSpacing: 20,
            children: projects.asMap().entries.map((e) =>
              ScrollReveal(delay: Duration(milliseconds: 70 * e.key),
                child: SizedBox(width: cw,
                    child: _ProjCard(p: e.value, open: _open)))).toList(),
          );
        }),
        const SizedBox(height: 36),
        // More projects row
        ScrollReveal(delay: const Duration(milliseconds: 300),
          child: Center(child: Column(children: [
            _divider(),
            const SizedBox(height: 24),
            Text('+ 4 more projects including TaskFlow, RentRider, Expense Tracker & ToDo App',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    color: kCreamDim, fontSize: 13)),
            const SizedBox(height: 16),
            _GhostBtn('View All on GitHub', FontAwesomeIcons.github,
                () => _open('https://github.com/prajaktajadhav177')),
          ])),
        ),
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
        _Sk(Icons.psychology_outlined,        'Gemini API'),
        _Sk(Icons.auto_awesome_outlined,      'LLM Integration'),
        _Sk(Icons.manage_search_outlined,     'Sentiment Analysis'),
        _Sk(Icons.document_scanner_outlined,  'OCR & Document AI'),
      ]),
      _SGroup('Languages', Color(0xFF10B981), [
        _Sk(Icons.code,              'Dart'),
        _Sk(Icons.terminal_outlined, 'Java'),
        _Sk(Icons.terminal_outlined, 'C++'),
        _Sk(Icons.code_outlined,     'Python'),
      ]),
      _SGroup('Tools & Workflow', Color(0xFFF59E0B), [
        _Sk(FontAwesomeIcons.gitAlt,          'Git / GitHub / GitLab'),
        _Sk(Icons.bug_report_outlined,        'Testing & Debugging'),
        _Sk(Icons.speed_outlined,             'Performance Tuning'),
        _Sk(Icons.design_services_outlined,   'UI/UX Design'),
      ]),
    ];

    return Container(
      key: _skillsKey,
      color: kNight,
      padding: _pad(mob),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ScrollReveal(child: _secHead('04 — SKILLS', 'What I Work With')),
        const SizedBox(height: 52),
        ...groups.asMap().entries.map((e) => ScrollReveal(
          delay: Duration(milliseconds: 70 * e.key),
          child: Padding(padding: const EdgeInsets.only(bottom: 30),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 3, height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      e.value.color, e.value.color.withOpacity(0.15)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(e.value.name, style: GoogleFonts.dmSans(
                    color: kCream, fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 9, runSpacing: 9,
                children: e.value.skills.map((s) =>
                    _SkillChip(s: s, c: e.value.color)).toList()),
            ]),
          ),
        )),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  EDUCATION & ACHIEVEMENTS (combined — no repetition)
  // ══════════════════════════════════════════════════════════════
  Widget _buildEducation(bool mob) => Container(
    key: _eduKey,
    color: kNavyMid,
    padding: _pad(mob),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ScrollReveal(child: _secHead('05 — EDUCATION & RECOGNITION', 'Background')),
      const SizedBox(height: 52),

      // Degree card
      ScrollReveal(delay: const Duration(milliseconds: 80),
        child: _Card(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _bubble(Icons.school_outlined, kGold, sz: 20),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('B.E. in Computer Science & Engineering',
                  style: GoogleFonts.playfairDisplay(
                      color: kCream, fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text('Sinhgad Institute of Technology & Science, Pune',
                  style: GoogleFonts.dmSans(
                      color: kGoldSoft, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text('2022 – 2026', style: GoogleFonts.dmMono(
                  color: kCreamDim, fontSize: 12)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kEmerald.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kEmerald.withOpacity(0.28)),
                ),
                child: Text('SGPA: 9.8 / 10',
                    style: GoogleFonts.dmSans(
                        color: kEmerald, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ])),
          ]),
        ),
      ),
      const SizedBox(height: 20),

      // Achievements (one strong mention each)
      ScrollReveal(delay: const Duration(milliseconds: 160),
        child: _achCard(
          '🏆', kGold, 'Elite Her Hackathon — Finalist',
          'Ranked Top 200 out of 7000+ participating teams nationally. '
          'Built TruthLens AI — an AI platform combating unhealthy social media comparison '
          'using Gemini API, sentiment analysis, and a context-aware chatbot.',
        )),
      const SizedBox(height: 16),
      ScrollReveal(delay: const Duration(milliseconds: 220),
        child: _achCard(
          '🎖️', const Color(0xFF818CF8),
          'Campus Representative — Elite Coders SoC 2026',
          'Officially selected as the Verified Campus Leader for SITS Pune. '
          'Responsible for onboarding students into open-source culture, '
          'managing registrations, and representing the campus throughout the programme.',
        )),
    ]),
  );

  Widget _achCard(String emoji, Color c, String title, String desc) =>
    _Card(glowColor: c,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withOpacity(0.28)),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.playfairDisplay(
              color: kCream, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(desc, style: GoogleFonts.dmSans(
              color: kCreamMid, fontSize: 13, height: 1.7)),
        ])),
      ]),
    );

  // ══════════════════════════════════════════════════════════════
  //  CONTACT — strong CTA
  // ══════════════════════════════════════════════════════════════
  Widget _buildContact(bool mob) => _MeshBg(
    child: Container(
      key: _contactKey,
      color: kNight.withOpacity(0.82),
      padding: EdgeInsets.symmetric(
          horizontal: mob ? 22 : 88, vertical: mob ? 64 : 96),
      child: Column(children: [
        ScrollReveal(child: Text("Let's Work\nTogether.",
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
              color: kCream, fontSize: mob ? 40 : 56,
              fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -1.5),
        )),
        const SizedBox(height: 16),
        ScrollReveal(delay: const Duration(milliseconds: 80),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorderHov),
            ),
            child: Text(
              'I am actively looking for software development and Flutter engineering '
              'opportunities where I can contribute to impactful products and grow as '
              'an engineer. Open to full-time roles, internships, and freelance collaborations.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  color: kCreamMid, fontSize: 15, height: 1.7),
            ),
          ),
        ),
        const SizedBox(height: 36),
        ScrollReveal(delay: const Duration(milliseconds: 160),
          child: Wrap(spacing: 14, runSpacing: 14,
              alignment: WrapAlignment.center, children: [
            _GoldBtn('Email Me', Icons.email_outlined,
                () => _open('mailto:prajaktajadhav177@gmail.com'
                    '?subject=Opportunity for Prajakta')),
            _GhostBtn('LinkedIn', FontAwesomeIcons.linkedin,
                () => _open('https://www.linkedin.com/in/prajakta-jadhav-37484a260/')),
            _GhostBtn('GitHub', FontAwesomeIcons.github,
                () => _open('https://github.com/prajaktajadhav177')),
          ]),
        ),
        const SizedBox(height: 60),
        Container(height: 1,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [
            Colors.transparent,
            kGold.withOpacity(0.2),
            Colors.transparent,
          ])),
        ),
        const SizedBox(height: 24),
        Text('© 2025 Prajakta Ganesh Jadhav  ·  Built with Flutter',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmMono(
                color: kCreamDim, fontSize: 12)),
      ]),
    ),
  );
}

// ─── Data models ──────────────────────────────────────────────────
class _Proj {
  final String title, desc, url;
  final String? demoUrl;
  final IconData icon;
  final Color color;
  final List<String> tags;
  const _Proj(this.title, this.desc, this.url, this.demoUrl,
      this.icon, this.color, this.tags);
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