import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(const PortfolioApp());

// ─── Palette ──────────────────────────────────────────────────────
const kBg       = Color(0xFF060918);
const kSurface  = Color(0xFF0D1226);
const kCard     = Color(0xFF111827);
const kCardAlt  = Color(0xFF0A0F1E);
const kIndigo   = Color(0xFF6366F1);
const kViolet   = Color(0xFF8B5CF6);
const kCyan     = Color(0xFF22D3EE);
const kPink     = Color(0xFFEC4899);
const kGreen    = Color(0xFF10B981);
const kAmber    = Color(0xFFF59E0B);
const kRed      = Color(0xFFF43F5E);
const kTeal     = Color(0xFF14B8A6);
const kText     = Color(0xFFF1F5F9);
const kTextMid  = Color(0xFF94A3B8);
const kTextDim  = Color(0xFF475569);
const kBorder   = Color(0xFF1E293B);

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Prajakta · Portfolio',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(primary: kIndigo, surface: kSurface),
    ),
    home: const PortfolioPage(),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Floating particle background
// ══════════════════════════════════════════════════════════════════
class _Particle {
  late double x, y, radius, speed, opacity;
  late Color color;
  _Particle(math.Random r, double w, double h) {
    x       = r.nextDouble() * w;
    y       = r.nextDouble() * h;
    radius  = 1 + r.nextDouble() * 2.5;
    speed   = 0.2 + r.nextDouble() * 0.5;
    opacity = 0.15 + r.nextDouble() * 0.5;
    color   = [kIndigo, kCyan, kViolet, kPink, kTeal][r.nextInt(5)];
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double tick;
  _ParticlePainter(this.particles, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dy = (p.y - p.speed * tick) % size.height;
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(p.x, dy < 0 ? dy + size.height : dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class _ParticleBg extends StatefulWidget {
  const _ParticleBg();
  @override
  State<_ParticleBg> createState() => _ParticleBgState();
}

class _ParticleBgState extends State<_ParticleBg> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  List<_Particle> _pts = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
    if (_pts.isEmpty) {
      final rng = math.Random(42);
      _pts = List.generate(60, (_) => _Particle(rng, c.maxWidth, c.maxHeight));
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _ParticlePainter(_pts, _ctrl.value * 2000),
        size: Size(c.maxWidth, c.maxHeight),
      ),
    );
  });
}

// ══════════════════════════════════════════════════════════════════
//  Fade + slide entrance
// ══════════════════════════════════════════════════════════════════
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset from;
  const FadeSlideIn({super.key, required this.child,
      this.delay = Duration.zero, this.from = const Offset(0, 30)});
  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>  _fade;
  late Animation<Offset>  _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: widget.from, end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, child) => Opacity(
      opacity: _fade.value,
      child: Transform.translate(offset: _slide.value, child: child),
    ),
    child: widget.child,
  );
}

// ══════════════════════════════════════════════════════════════════
//  Pulsing dot
// ══════════════════════════════════════════════════════════════════
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({this.color = kGreen});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}
class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Stack(alignment: Alignment.center, children: [
      Container(width: 16, height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: widget.color.withOpacity(0.2 * _ctrl.value))),
      Container(width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color,
              boxShadow: [BoxShadow(color: widget.color.withOpacity(0.6), blurRadius: 6)])),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Shimmer gradient text
// ══════════════════════════════════════════════════════════════════
class _ShimmerText extends StatefulWidget {
  final String text;
  final double fontSize;
  final List<Color> colors;
  const _ShimmerText(this.text,
      {this.fontSize = 50,
       this.colors = const [kIndigo, kCyan, kViolet, kPink, kCyan, kIndigo]});
  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}
class _ShimmerTextState extends State<_ShimmerText> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: widget.colors,
        stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
        begin: Alignment(_ctrl.value * 4 - 2, 0),
        end:   Alignment(_ctrl.value * 4,     0),
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: Text(widget.text,
          style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontSize: widget.fontSize,
              fontWeight: FontWeight.w800, letterSpacing: -1.5, height: 1.05)),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Glow card (hover lift + border glow)
// ══════════════════════════════════════════════════════════════════
class _GlowCard extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsets padding;
  final double radius;
  const _GlowCard({required this.child,
      this.glowColor = kIndigo,
      this.padding   = const EdgeInsets.all(24),
      this.radius    = 20});
  @override
  State<_GlowCard> createState() => _GlowCardState();
}
class _GlowCardState extends State<_GlowCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit:  (_) => setState(() => _hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      transform: _hovered
          ? (Matrix4.identity()..translate(0.0, -6.0))
          : Matrix4.identity(),
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        color: kCard,
        border: Border.all(
          color: _hovered
              ? widget.glowColor.withOpacity(0.55)
              : kBorder.withOpacity(0.6),
        ),
        gradient: LinearGradient(
          colors: [
            widget.glowColor.withOpacity(_hovered ? 0.12 : 0.04),
            kCard,
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withOpacity(_hovered ? 0.28 : 0.06),
            blurRadius: _hovered ? 36 : 14,
            spreadRadius: _hovered ? 2 : 0,
          ),
          BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: widget.child,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Hover button
// ══════════════════════════════════════════════════════════════════
class _HoverBtn extends StatefulWidget {
  final Widget child;
  final Color color;
  final VoidCallback onTap;
  final bool ghost;
  final bool small;
  const _HoverBtn({required this.child, required this.color,
      required this.onTap, this.ghost = false, this.small = false});
  @override
  State<_HoverBtn> createState() => _HoverBtnState();
}
class _HoverBtnState extends State<_HoverBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _h ? (Matrix4.identity()..translate(0.0, -2.0)) : Matrix4.identity(),
        padding: widget.small
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          gradient: widget.ghost ? null : LinearGradient(
            colors: _h
                ? [widget.color, widget.color.withOpacity(0.7)]
                : [widget.color.withOpacity(0.9), widget.color.withOpacity(0.6)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: widget.ghost
              ? Border.all(color: _h ? kBorder : kBorder.withOpacity(0.5))
              : null,
          boxShadow: widget.ghost ? [] : [
            BoxShadow(
              color: widget.color.withOpacity(_h ? 0.45 : 0.2),
              blurRadius: _h ? 20 : 8, spreadRadius: _h ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.child,
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Nav item
// ══════════════════════════════════════════════════════════════════
class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavItem(this.label, this.onTap);
  @override
  State<_NavItem> createState() => _NavItemState();
}
class _NavItemState extends State<_NavItem> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _h ? kIndigo.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(widget.label, style: GoogleFonts.plusJakartaSans(
            color: _h ? kText : kTextMid, fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Animated logo
// ══════════════════════════════════════════════════════════════════
class _AnimLogo extends StatefulWidget {
  @override
  State<_AnimLogo> createState() => _AnimLogoState();
}
class _AnimLogoState extends State<_AnimLogo> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kIndigo, kCyan, kViolet, kIndigo],
          stops: [0, 0.3 + _ctrl.value * 0.4, 0.7 + _ctrl.value * 0.3, 1],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: kIndigo.withOpacity(0.4), blurRadius: 14, spreadRadius: 1)],
      ),
      child: Text('PJ', style: GoogleFonts.plusJakartaSans(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Rotating ring avatar
// ══════════════════════════════════════════════════════════════════
class _RingAvatar extends StatefulWidget {
  @override
  State<_RingAvatar> createState() => _RingAvatarState();
}
class _RingAvatarState extends State<_RingAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 280, height: 280,
    child: Stack(alignment: Alignment.center, children: [
      // Rotating gradient ring
      AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.rotate(
          angle: _ctrl.value * 2 * math.pi,
          child: Container(width: 260, height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: [kIndigo, kCyan, kViolet, kPink, kIndigo]),
            ),
          ),
        ),
      ),
      // Dark gap ring
      Container(width: 248, height: 248,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: kBg)),
      // Photo
      Container(width: 236, height: 236,
        decoration: BoxDecoration(shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: kIndigo.withOpacity(0.4), blurRadius: 30, spreadRadius: 4)]),
        child: CircleAvatar(radius: 118,
            backgroundImage: const AssetImage('assets/profile.jpeg'),
            backgroundColor: kSurface),
      ),
      // Orbiting dot 1
      AnimatedBuilder(animation: _ctrl, builder: (_, __) {
        final a = _ctrl.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(math.cos(a) * 130, math.sin(a) * 130),
          child: Container(width: 14, height: 14,
            decoration: BoxDecoration(shape: BoxShape.circle, color: kCyan,
              boxShadow: [BoxShadow(color: kCyan.withOpacity(0.8), blurRadius: 10, spreadRadius: 2)])),
        );
      }),
      // Orbiting dot 2
      AnimatedBuilder(animation: _ctrl, builder: (_, __) {
        final a = (_ctrl.value + 0.5) * 2 * math.pi;
        return Transform.translate(
          offset: Offset(math.cos(a) * 130, math.sin(a) * 130),
          child: Container(width: 10, height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: kPink,
              boxShadow: [BoxShadow(color: kPink.withOpacity(0.8), blurRadius: 8, spreadRadius: 2)])),
        );
      }),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════
//  Project card (animated hover)
// ══════════════════════════════════════════════════════════════════
class _ProjectCard extends StatefulWidget {
  final _ProjData data;
  final Future<void> Function(String) onOpen;
  const _ProjectCard({required this.data, required this.onOpen});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}
class _ProjectCardState extends State<_ProjectCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.data;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit:  (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        transform: _h
            ? (Matrix4.identity()..translate(0.0, -8.0)..scale(1.015))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: p.color.withOpacity(_h ? 0.38 : 0.08),
              blurRadius: _h ? 44 : 16,
              spreadRadius: _h ? 4 : 0,
              offset: const Offset(0, 12),
            ),
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: kCard,
            border: Border.all(
              color: _h ? p.color.withOpacity(0.55) : kBorder.withOpacity(0.5),
            ),
            gradient: LinearGradient(
              colors: [p.color.withOpacity(_h ? 0.13 : 0.04), kCard, kCard],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header row
            Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [p.color.withOpacity(_h ? 0.35 : 0.2), p.color.withOpacity(0.05)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.color.withOpacity(0.4)),
                  boxShadow: _h
                      ? [BoxShadow(color: p.color.withOpacity(0.35), blurRadius: 14)]
                      : [],
                ),
                child: Icon(p.icon, color: p.color, size: 22),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => widget.onOpen(p.url),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _h ? p.color.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: p.color.withOpacity(_h ? 0.55 : 0.2)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    FaIcon(FontAwesomeIcons.github, color: p.color, size: 13),
                    const SizedBox(width: 5),
                    Text('Code', style: GoogleFonts.plusJakartaSans(
                        color: p.color, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 18),
            Text(p.title, style: GoogleFonts.plusJakartaSans(
                color: kText, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
            const SizedBox(height: 8),
            Text(p.desc, style: GoogleFonts.plusJakartaSans(
                color: kTextMid, fontSize: 13, height: 1.65)),
            const SizedBox(height: 16),
            Wrap(spacing: 6, runSpacing: 6,
              children: p.tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [p.color.withOpacity(0.18), p.color.withOpacity(0.04)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.color.withOpacity(0.35)),
                ),
                child: Text(t, style: GoogleFonts.plusJakartaSans(
                    color: p.color, fontSize: 11, fontWeight: FontWeight.w700)),
              )).toList(),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Skill chip (hover glow)
// ══════════════════════════════════════════════════════════════════
class _SkillChip extends StatefulWidget {
  final _Skill s;
  final Color color;
  const _SkillChip({required this.s, required this.color});
  @override
  State<_SkillChip> createState() => _SkillChipState();
}
class _SkillChipState extends State<_SkillChip> {
  bool _h = false;
  Widget _fa(IconData ic, Color c, double sz) {
    if (ic == FontAwesomeIcons.gitAlt) return FaIcon(ic, color: c, size: sz);
    return Icon(ic, color: c, size: sz);
  }
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: _h ? (Matrix4.identity()..translate(0.0, -3.0)) : Matrix4.identity(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _h
            ? [widget.color.withOpacity(0.2), widget.color.withOpacity(0.06)]
            : [kSurface, kSurface]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _h ? widget.color.withOpacity(0.55) : kBorder),
        boxShadow: _h
            ? [BoxShadow(color: widget.color.withOpacity(0.22), blurRadius: 14)]
            : [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _fa(widget.s.icon, _h ? widget.color : kTextMid, 14),
        const SizedBox(width: 8),
        Text(widget.s.name, style: GoogleFonts.plusJakartaSans(
            color: _h ? kText : kTextMid, fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
//  MAIN PAGE
// ══════════════════════════════════════════════════════════════════
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
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
      final s = _scroll.offset > 60;
      if (s != _scrolled) setState(() => _scrolled = s);
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  void _to(GlobalKey k) {
    final c = k.currentContext;
    if (c != null) Scrollable.ensureVisible(c,
        duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
  }

  Future<void> _open(String url) async {
    final u = Uri.parse(url);
    if (await canLaunchUrl(u)) await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  Widget _fa(IconData ic, Color c, double sz) {
    if (ic == FontAwesomeIcons.gitAlt || ic == FontAwesomeIcons.github || ic == FontAwesomeIcons.linkedin)
      return FaIcon(ic, color: c, size: sz);
    return Icon(ic, color: c, size: sz);
  }

  Widget _iconBox(IconData ic, Color c, {double size = 18}) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [c.withOpacity(0.25), c.withOpacity(0.06)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.3)),
    ),
    child: _fa(ic, c, size),
  );

  Widget _secTitle(String t, {Color accent = kIndigo}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Container(width: 4, height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [accent, kCyan],
                begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 14),
        Text(t, style: GoogleFonts.plusJakartaSans(
            color: kText, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1)),
      ]),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.only(left: 18),
        child: Container(width: 60, height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [accent.withOpacity(0.6), Colors.transparent]),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    ],
  );

  EdgeInsets _pad(bool mob) =>
      EdgeInsets.symmetric(horizontal: mob ? 20 : 80, vertical: mob ? 52 : 80);

  Widget _glowBtn(String lbl, IconData ic, VoidCallback fn, {Color c = kIndigo}) =>
      _HoverBtn(color: c, onTap: fn,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _fa(ic, Colors.white, 15),
          const SizedBox(width: 10),
          Text(lbl, style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _ghostBtn(String lbl, IconData ic, VoidCallback fn) =>
      _HoverBtn(color: kIndigo, onTap: fn, ghost: true,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _fa(ic, kTextMid, 15),
          const SizedBox(width: 10),
          Text(lbl, style: GoogleFonts.plusJakartaSans(
              color: kTextMid, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      );

  // ════════════════ BUILD ══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final mob = w < 700;

    final navItems = [
      ('About', _aboutKey), ('Experience', _expKey),
      ('Projects', _projKey), ('Skills', _skillsKey),
      ('Education', _eduKey), ('Contact', _contactKey),
    ];

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _scrolled ? kSurface.withOpacity(0.92) : Colors.transparent,
            border: _scrolled ? Border(bottom: BorderSide(color: kBorder.withOpacity(0.8))) : null,
            boxShadow: _scrolled
                ? [BoxShadow(color: kIndigo.withOpacity(0.08), blurRadius: 30)]
                : [],
          ),
          child: SafeArea(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mob ? 20 : 52),
            child: Row(children: [
              _AnimLogo(),
              const Spacer(),
              if (!mob) ...navItems.map((e) => _NavItem(e.$1, () => _to(e.$2))),
              if (!mob) const SizedBox(width: 16),
              if (!mob)
                _HoverBtn(color: kIndigo, onTap: () => _open(
                    'https://drive.google.com/file/d/1Fnc0uhd03yXKEj46LbF-Rrf6wsM2geXL/view?usp=drive_link'),
                  small: true,
                  child: Text('Resume', style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              if (mob)
                PopupMenuButton<int>(
                  color: kSurface,
                  icon: const Icon(Icons.menu_rounded, color: kText),
                  itemBuilder: (_) => navItems.asMap().entries.map((e) =>
                    PopupMenuItem(value: e.key, onTap: () => _to(e.value.$2),
                      child: Text(e.value.$1, style: GoogleFonts.plusJakartaSans(
                          color: kText, fontSize: 14)))).toList(),
                ),
            ]),
          )),
        ),
      ),
      body: Stack(children: [
        // Particle canvas
        const Positioned.fill(child: _ParticleBg()),
        // Ambient blobs
        Positioned(top: -200, right: -200,
          child: Container(width: 600, height: 600,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [kIndigo.withOpacity(0.12), Colors.transparent])))),
        Positioned(top: 400, left: -150,
          child: Container(width: 500, height: 500,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [kCyan.withOpacity(0.07), Colors.transparent])))),
        SingleChildScrollView(
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
      ]),
    );
  }

  // ─── HERO ──────────────────────────────────────────────────────
  Widget _buildHero(bool mob) => Container(
    key: _heroKey,
    width: double.infinity,
    constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
    child: Padding(
      padding: EdgeInsets.fromLTRB(mob ? 20 : 80, mob ? 110 : 130, mob ? 20 : 80, mob ? 60 : 80),
      child: mob ? _heroMob() : _heroDesk(),
    ),
  );

  Widget _heroDesk() => Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
    Expanded(flex: 6, child: _heroText()),
    const SizedBox(width: 60),
    Expanded(flex: 4, child: Center(child: FadeSlideIn(
      delay: const Duration(milliseconds: 500),
      from: const Offset(30, 0),
      child: _RingAvatar()))),
  ]);

  Widget _heroMob() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(child: FadeSlideIn(delay: const Duration(milliseconds: 200), child: _RingAvatar())),
    const SizedBox(height: 36),
    _heroText(),
  ]);

  Widget _heroText() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    FadeSlideIn(delay: const Duration(milliseconds: 100), child: _hackBadge()),
    const SizedBox(height: 16),
    FadeSlideIn(delay: const Duration(milliseconds: 200), child: _availPill()),
    const SizedBox(height: 22),
    FadeSlideIn(delay: const Duration(milliseconds: 300),
        child: _ShimmerText('Prajakta\nGanesh Jadhav', fontSize: 52)),
    const SizedBox(height: 14),
    FadeSlideIn(delay: const Duration(milliseconds: 380),
      child: Text('Flutter Dev  ·  Java Dev  ·  Tech Enthusiast',
          style: GoogleFonts.plusJakartaSans(
              color: kCyan, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    ),
    const SizedBox(height: 18),
    FadeSlideIn(delay: const Duration(milliseconds: 440),
      child: Text(
        'Final-year CSE student crafting impactful cross-platform apps '
        'with Flutter, Firebase, AI/ML integrations and polished UI/UX.',
        style: GoogleFonts.plusJakartaSans(color: kTextMid, fontSize: 16, height: 1.75),
      ),
    ),
    const SizedBox(height: 34),
    FadeSlideIn(delay: const Duration(milliseconds: 530),
      child: Wrap(spacing: 14, runSpacing: 12, children: [
        _glowBtn('View Projects', Icons.rocket_launch_outlined, () => _to(_projKey)),
        _ghostBtn('Download Resume', Icons.download_outlined, () => _open(
            'https://drive.google.com/file/d/1Fnc0uhd03yXKEj46LbF-Rrf6wsM2geXL/view?usp=drive_link')),
      ]),
    ),
    const SizedBox(height: 28),
    FadeSlideIn(delay: const Duration(milliseconds: 620),
      child: Wrap(spacing: 10, runSpacing: 10, children: [
        _socialChip(FontAwesomeIcons.github,   'GitHub',   'https://github.com/prajaktajadhav177'),
        _socialChip(FontAwesomeIcons.linkedin, 'LinkedIn', 'https://www.linkedin.com/in/prajakta-jadhav-37484a260/'),
        _socialChip(Icons.mail_outline,        'Email',    'mailto:prajaktajadhav177@gmail.com'),
      ]),
    ),
  ]);

  Widget _hackBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [kAmber.withOpacity(0.15), kPink.withOpacity(0.08)]),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: kAmber.withOpacity(0.4)),
      boxShadow: [BoxShadow(color: kAmber.withOpacity(0.12), blurRadius: 12)],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Text('🏆', style: TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Flexible(child: Text('Elite Her Hackathon Finalist · Top 200 / 7000+ teams',
          style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis, maxLines: 2)),
    ]),
  );

  Widget _availPill() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: kGreen.withOpacity(0.08),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: kGreen.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const _PulseDot(color: kGreen),
      const SizedBox(width: 9),
      Text('Available for opportunities',
          style: GoogleFonts.plusJakartaSans(color: kGreen, fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _socialChip(IconData icon, String label, String url) => InkWell(
    onTap: () => _open(url),
    borderRadius: BorderRadius.circular(30),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kBorder.withOpacity(0.8)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _fa(icon, kTextMid, 14),
        const SizedBox(width: 7),
        Text(label, style: GoogleFonts.plusJakartaSans(color: kTextMid, fontSize: 13)),
      ]),
    ),
  );

  // ─── ABOUT ─────────────────────────────────────────────────────
  Widget _buildAbout(bool mob) {
    final cards = [
      (Icons.phone_android_outlined,  kIndigo,  'Mobile App Dev',  'Flutter & Firebase — smooth, scalable cross-platform apps.'),
      (Icons.storage_outlined,         kCyan,   'Backend & DB',     'Firebase, SQL, MongoDB & REST APIs for reliable data.'),
      (Icons.design_services_outlined, kViolet, 'UI/UX Design',     'Clean, responsive, delightful interfaces.'),
    ];

    return Container(
      key: _aboutKey,
      width: double.infinity,
      padding: _pad(mob),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kBg, kSurface],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FadeSlideIn(child: _secTitle('About Me')),
        const SizedBox(height: 48),
        mob
          ? Column(children: [
              FadeSlideIn(child: _whoCard()),
              const SizedBox(height: 16),
              ...cards.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: FadeSlideIn(delay: Duration(milliseconds: 100 + e.key * 80),
                    child: _highlightCard(e.value.$1, e.value.$2, e.value.$3, e.value.$4)))),
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: FadeSlideIn(child: _whoCard())),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: Column(children: cards.asMap().entries.map((e) =>
                Padding(padding: const EdgeInsets.only(bottom: 14),
                  child: FadeSlideIn(delay: Duration(milliseconds: 100 + e.key * 80),
                    child: _highlightCard(e.value.$1, e.value.$2, e.value.$3, e.value.$4)))).toList())),
            ]),
      ]),
    );
  }

  Widget _whoCard() => _GlowCard(glowColor: kIndigo,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _iconBox(Icons.person_outline, kIndigo),
        const SizedBox(width: 12),
        Text('Who I Am', style: GoogleFonts.plusJakartaSans(
            color: kText, fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 16),
      Text(
        'Final-year Computer Science student passionate about building impactful '
        'mobile and web applications. With 6 months of hands-on internship experience, '
        'I love creating smooth, engaging, and visually rich user experiences while '
        'sharpening my skills across Flutter, Firebase, SQL, and AI/ML.',
        style: GoogleFonts.plusJakartaSans(color: kTextMid, fontSize: 14, height: 1.8),
      ),
      const SizedBox(height: 20),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _statBadge('6+',  'Projects',   kIndigo),
        _statBadge('6mo', 'Experience', kCyan),
        _statBadge('9.8', 'SGPA',       kGreen),
      ]),
    ]),
  );

  Widget _statBadge(String num, String label, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [c.withOpacity(0.15), c.withOpacity(0.05)]),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.3)),
    ),
    child: Column(children: [
      Text(num,   style: GoogleFonts.plusJakartaSans(color: c, fontSize: 20, fontWeight: FontWeight.w800)),
      Text(label, style: GoogleFonts.plusJakartaSans(color: kTextMid, fontSize: 11, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _highlightCard(IconData ic, Color c, String title, String desc) =>
      _GlowCard(glowColor: c, padding: const EdgeInsets.all(18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _iconBox(ic, c),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.plusJakartaSans(
                color: kText, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(desc, style: GoogleFonts.plusJakartaSans(
                color: kTextMid, fontSize: 13, height: 1.5)),
          ])),
        ]),
      );

  // ─── EXPERIENCE ────────────────────────────────────────────────
  Widget _buildExperience(bool mob) => Container(
    key: _expKey,
    width: double.infinity,
    padding: _pad(mob),
    color: kCardAlt,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FadeSlideIn(child: _secTitle('Experience', accent: kCyan)),
      const SizedBox(height: 48),
      FadeSlideIn(delay: const Duration(milliseconds: 100),
        child: _expCard(Icons.work_outline, kIndigo, 'Software Engineering Intern',
          'Intern Labs', 'Jun 2025 – Sep 2025', [
          'Cross-platform app development using Flutter & Dart.',
          'Implementing clean UI/UX, Firebase integration, and state management.',
          'Contributing to testing, debugging, and performance optimization.',
        ])),
      const SizedBox(height: 20),
      FadeSlideIn(delay: const Duration(milliseconds: 200),
        child: _expCard(Icons.developer_mode_outlined, kTeal, 'Flutter Developer Intern',
          'Incubators System Pvt. Ltd', 'Aug 2024 – Oct 2024', [
          'Developed cross-platform mobile apps using Flutter & Dart.',
          'Implemented animations, login screens, and Firebase authentication.',
          'Worked with GitLab for collaborative development.',
        ])),
    ]),
  );

  Widget _expCard(IconData ic, Color c, String role, String company, String period, List<String> pts) =>
      _GlowCard(glowColor: c,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _iconBox(ic, c, size: 20),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(role, style: GoogleFonts.plusJakartaSans(
                color: kText, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(spacing: 10, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(company, style: GoogleFonts.plusJakartaSans(
                  color: c, fontSize: 14, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.withOpacity(0.2), c.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.withOpacity(0.35)),
                ),
                child: Text(period, style: GoogleFonts.plusJakartaSans(
                    color: c, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 16),
            ...pts.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: const EdgeInsets.only(top: 7),
                  child: Container(width: 5, height: 5,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: c.withOpacity(0.6), blurRadius: 4)]))),
                const SizedBox(width: 12),
                Expanded(child: Text(p, style: GoogleFonts.plusJakartaSans(
                    color: kTextMid, fontSize: 14, height: 1.6))),
              ]),
            )),
          ])),
        ]),
      );

  // ─── PROJECTS ──────────────────────────────────────────────────
  Widget _buildProjects(bool mob) {
    final projects = [
      _ProjData('RentRider',
          'Vehicle booking app with Firebase auth, smooth UI and real-time booking management.',
          'https://github.com/prajaktajadhav177/rent-rider',
          Icons.directions_bike_outlined, kIndigo, ['Flutter', 'Firebase']),
      _ProjData('SoulSync',
          'Matrimony platform — profile matching, chat, video & voice calls with Firebase.',
          'https://github.com/prajaktajadhav177/soulsync',
          Icons.favorite_border, kPink, ['Flutter', 'Firebase']),
      _ProjData('Expense Tracker',
          'Track spending, set savings goals, and visualize budget analytics. Dark mode included.',
          'https://github.com/prajaktajadhav177/web-app-expence-tracker',
          Icons.account_balance_wallet_outlined, kGreen, ['Flutter', 'SQLite']),
      _ProjData('ToDo App',
          'Smart task manager with priorities, categories, and daily progress tracking.',
          'https://github.com/prajaktajadhav177/Basic-todo-app',
          Icons.check_circle_outline, kViolet, ['Flutter', 'SQLite']),
      _ProjData('TruthLens AI',
          'AI platform reducing unhealthy social comparison — reality scores on effort, authenticity & context, with chatbot for emotional awareness.',
          'https://github.com/prajaktajadhav177',
          Icons.remove_red_eye_outlined, kCyan,
          ['Flutter', 'Firebase', 'Gemini API', 'Sentiment Analysis']),
      _ProjData('PocketPilot',
          'Smart expense tracker with categorization, interactive charts, dark mode & personalized budgeting.',
          'https://github.com/prajaktajadhav177',
          Icons.auto_graph_outlined, kAmber,
          ['Flutter', 'SQLite', 'Sqflite', 'Charts']),
      _ProjData('TaskFlow',
          'Collaborative PM platform — Kanban boards, sprint planning, task assignment & real-time updates.',
          'https://github.com/prajaktajadhav177',
          Icons.dashboard_outlined, const Color(0xFF818CF8),
          ['Flutter', 'Firebase', 'Real-time DB']),
      _ProjData('DocShield',
          'Intelligent document verification — OCR, authenticity checks, plagiarism detection & AI anomaly detection.',
          'https://github.com/prajaktajadhav177',
          Icons.verified_user_outlined, kRed,
          ['Python', 'AI/ML', 'OCR', 'Firebase']),
    ];

    return Container(
      key: _projKey,
      width: double.infinity,
      padding: _pad(mob),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kSurface, kBg],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FadeSlideIn(child: _secTitle('Projects', accent: kViolet)),
        const SizedBox(height: 8),
        FadeSlideIn(delay: const Duration(milliseconds: 80),
            child: Text('Highlighted works & side projects',
                style: GoogleFonts.plusJakartaSans(color: kTextDim, fontSize: 15))),
        const SizedBox(height: 48),
        LayoutBuilder(builder: (_, bc) {
          final cols = bc.maxWidth > 900 ? 3 : bc.maxWidth > 560 ? 2 : 1;
          final cw = (bc.maxWidth - (cols - 1) * 20) / cols;
          return Wrap(spacing: 20, runSpacing: 20,
            children: projects.asMap().entries.map((e) =>
              FadeSlideIn(
                delay: Duration(milliseconds: 60 * e.key),
                child: SizedBox(width: cw,
                    child: _ProjectCard(data: e.value, onOpen: _open)),
              )).toList(),
          );
        }),
      ]),
    );
  }

  // ─── SKILLS ────────────────────────────────────────────────────
  Widget _buildSkills(bool mob) {
    final groups = [
      _SkillGroup('Mobile & Frontend', kIndigo, [
        _Skill(Icons.flutter_dash,             'Flutter & Dart'),
        _Skill(Icons.phone_android_outlined,   'Cross-platform Dev'),
        _Skill(Icons.web_outlined,             'Responsive UI/UX'),
        _Skill(Icons.animation,                'Animations'),
      ]),
      _SkillGroup('Backend & Database', kCyan, [
        _Skill(Icons.cloud_outlined,           'Firebase'),
        _Skill(Icons.storage_outlined,         'SQL / SQLite / Sqflite'),
        _Skill(Icons.dataset_outlined,         'MongoDB'),
        _Skill(Icons.api_outlined,             'REST APIs'),
        _Skill(Icons.lock_outline,             'Firebase Auth'),
        _Skill(Icons.save_outlined,            'SharedPreferences'),
      ]),
      _SkillGroup('AI & Emerging Tech', kViolet, [
        _Skill(Icons.psychology_outlined,      'Gemini API'),
        _Skill(Icons.auto_awesome_outlined,    'AI/ML Integration'),
        _Skill(Icons.manage_search_outlined,   'Sentiment Analysis'),
        _Skill(Icons.document_scanner_outlined,'OCR & Document AI'),
      ]),
      _SkillGroup('Languages', kGreen, [
        _Skill(Icons.code,                     'Dart'),
        _Skill(Icons.terminal_outlined,        'Java'),
        _Skill(Icons.terminal_outlined,        'C++'),
        _Skill(Icons.code_outlined,            'Python'),
      ]),
      _SkillGroup('Tools & Workflow', kAmber, [
        _Skill(FontAwesomeIcons.gitAlt,        'Git & GitHub / GitLab'),
        _Skill(Icons.bug_report_outlined,      'Testing & Debugging'),
        _Skill(Icons.speed_outlined,           'Performance Optimization'),
        _Skill(Icons.design_services_outlined, 'UI/UX Design'),
      ]),
    ];

    return Container(
      key: _skillsKey,
      width: double.infinity,
      padding: _pad(mob),
      color: kCardAlt,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FadeSlideIn(child: _secTitle('Skills', accent: kCyan)),
        const SizedBox(height: 48),
        ...groups.asMap().entries.map((e) => FadeSlideIn(
          delay: Duration(milliseconds: 80 * e.key),
          child: Padding(padding: const EdgeInsets.only(bottom: 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 3, height: 18,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [e.value.color, e.value.color.withOpacity(0.2)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(e.value.name, style: GoogleFonts.plusJakartaSans(
                    color: kText, fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 14),
              Wrap(spacing: 10, runSpacing: 10,
                children: e.value.skills
                    .map((s) => _SkillChip(s: s, color: e.value.color)).toList()),
            ]),
          ),
        )),
      ]),
    );
  }

  // ─── EDUCATION ─────────────────────────────────────────────────
  Widget _buildEducation(bool mob) => Container(
    key: _eduKey,
    width: double.infinity,
    padding: _pad(mob),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [kBg, kSurface],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FadeSlideIn(child: _secTitle('Education', accent: kGreen)),
      const SizedBox(height: 48),
      FadeSlideIn(delay: const Duration(milliseconds: 100),
        child: _GlowCard(glowColor: kIndigo,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _iconBox(Icons.school_outlined, kIndigo, size: 22),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('B.E. in Computer Science & Engineering',
                  style: GoogleFonts.plusJakartaSans(
                      color: kText, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Sinhgad Institute of Technology & Science, Pune',
                  style: GoogleFonts.plusJakartaSans(
                      color: kIndigo, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('2022 – 2026', style: GoogleFonts.plusJakartaSans(
                  color: kTextDim, fontSize: 13)),
              const SizedBox(height: 18),
              Wrap(spacing: 12, runSpacing: 10, children: [
                _glowBadge('🏅  SGPA: 9.8 / 10', kGreen),
                _glowBadge('🏆  Elite Her Hackathon — Top 200 / 7000+ teams', kAmber),
              ]),
            ])),
          ])),
      ),
    ]),
  );

  Widget _glowBadge(String text, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [c.withOpacity(0.14), c.withOpacity(0.04)]),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: c.withOpacity(0.35)),
      boxShadow: [BoxShadow(color: c.withOpacity(0.14), blurRadius: 10)],
    ),
    child: Text(text, style: GoogleFonts.plusJakartaSans(
        color: c, fontSize: 13, fontWeight: FontWeight.w600)),
  );

  // ─── CONTACT ───────────────────────────────────────────────────
  Widget _buildContact(bool mob) => Container(
    key: _contactKey,
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: mob ? 20 : 80, vertical: mob ? 64 : 90),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [kSurface, kBg],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ),
    ),
    child: Stack(children: [
      Positioned(top: -80, right: -60,
        child: Container(width: 300, height: 300,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [kIndigo.withOpacity(0.10), Colors.transparent])))),
      Positioned(bottom: -60, left: -80,
        child: Container(width: 280, height: 280,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [kCyan.withOpacity(0.08), Colors.transparent])))),
      Column(children: [
        FadeSlideIn(child: _ShimmerText("Let's Connect",
            fontSize: mob ? 32 : 46,
            colors: [kIndigo, kCyan, kViolet, kPink, kCyan, kIndigo])),
        const SizedBox(height: 16),
        FadeSlideIn(delay: const Duration(milliseconds: 100),
          child: Text(
            'Have a project in mind, a collaboration idea, or just want to say hi?',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: kTextMid, fontSize: 16, height: 1.6),
          ),
        ),
        const SizedBox(height: 40),
        FadeSlideIn(delay: const Duration(milliseconds: 200),
          child: Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center, children: [
            _glowBtn('Email Me', Icons.email_outlined,
                () => _open('mailto:prajaktajadhav177@gmail.com?subject=Portfolio Contact')),
            _glowBtn('LinkedIn', FontAwesomeIcons.linkedin,
                () => _open('https://www.linkedin.com/in/prajakta-jadhav-37484a260/'),
                c: const Color(0xFF0A66C2)),
            _ghostBtn('GitHub', FontAwesomeIcons.github,
                () => _open('https://github.com/prajaktajadhav177')),
          ]),
        ),
        const SizedBox(height: 60),
        Container(height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent, kBorder.withOpacity(0.8), Colors.transparent]),
          ),
        ),
        const SizedBox(height: 24),
        Text('© 2025 Prajakta Ganesh Jadhav  ·  Built with Flutter & ❤️',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: kTextDim, fontSize: 13)),
      ]),
    ]),
  );
}

// ─── Data models ─────────────────────────────────────────────────
class _ProjData {
  final String title, desc, url;
  final IconData icon;
  final Color color;
  final List<String> tags;
  const _ProjData(this.title, this.desc, this.url, this.icon, this.color, this.tags);
}

class _SkillGroup {
  final String name;
  final Color color;
  final List<_Skill> skills;
  const _SkillGroup(this.name, this.color, this.skills);
}

class _Skill {
  final IconData icon;
  final String name;
  const _Skill(this.icon, this.name);
}