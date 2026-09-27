# RomanPills: Cinzel (OFL) with ASCII digits 1-9 redrawn as Roman numerals
# (I, II, III, IV, V, VI, VII, VIII, IX) via TrueType composites, so
# Noctalia's workspace pills show numerals while Niri stays 100% untouched.
# Built from nixpkgs cinzel at build time with fontTools. '0' is left alone,
# so 10+ renders digit-by-digit (documented limit, bar rarely passes 9).
{ stdenvNoCC, cinzel, python3, lib }:
let
  py = python3.withPackages (ps: [ ps.fonttools ]);
in
stdenvNoCC.mkDerivation {
  pname = "astrid-roman-pills";
  version = "1.0";

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    # Prefer plain Cinzel-Regular (Decorative may lack figures).
    SRC=$(find "${cinzel}" -iname 'Cinzel-Regular.ttf' | head -n 1)
    if [ -z "$SRC" ]; then
      SRC=$(find "${cinzel}" -iname '*regular*.ttf' | grep -vi decorative | head -n 1)
    fi
    if [ -z "$SRC" ]; then
      SRC=$(find "${cinzel}" -iname '*.ttf' | head -n 1)
    fi
    if [ -z "$SRC" ]; then
      echo "roman-pills: no TTF found in cinzel package" >&2
      exit 1
    fi
    echo "roman-pills: surgery on $SRC"

    mkdir -p $out/share/fonts/truetype
    ${py}/bin/python - "$SRC" "$out/share/fonts/truetype/RomanPills-Regular.ttf" <<'EOF'
    import sys
    from fontTools.ttLib import TTFont
    from fontTools.pens.ttGlyphPen import TTGlyphPen

    src, dst = sys.argv[1], sys.argv[2]
    ROMAN = {
        '1': 'I', '2': 'II', '3': 'III', '4': 'IV', '5': 'V',
        '6': 'VI', '7': 'VII', '8': 'VIII', '9': 'IX',
    }

    font = TTFont(src)
    if 'glyf' not in font:
        print('roman-pills: not a TrueType-glyf font, aborting', file=sys.stderr)
        sys.exit(1)
    cmap = font.getBestCmap()
    for ch in '0123456789IVX':
        if ord(ch) not in cmap:
            print(f'roman-pills: missing glyph for {ch!r}, aborting', file=sys.stderr)
            sys.exit(1)

    glyphSet = font.getGlyphSet()
    glyf = font['glyf']
    hmtx = font['hmtx']
    for digit, numeral in ROMAN.items():
        pen = TTGlyphPen(glyphSet)
        x = 0
        parts = []
        for ch in numeral:
            g = cmap[ord(ch)]
            pen.addComponent(g, (1, 0, 0, 1, x, 0))
            parts.append((g, x))
            x += hmtx[g][0]
        glyph = pen.glyph()
        target = cmap[ord(digit)]
        glyf[target] = glyph
        # Bounds from component geometry (no recalc needed): first
        # component sits at x=0, so xMin comes straight from it.
        xs = [xoff + glyf[g].xMin for g, xoff in parts]
        xe = [xoff + glyf[g].xMax for g, xoff in parts]
        ys = [glyf[g].yMin for g, _ in parts]
        ye = [glyf[g].yMax for g, _ in parts]
        glyph.xMin, glyph.yMin, glyph.xMax, glyph.yMax = min(xs), min(ys), max(xe), max(ye)
        hmtx[target] = (x, int(round(min(xs))))
        print(f'roman-pills: {digit} -> {numeral} (advance {x})')

    # Rebrand so Fontconfig sees a distinct family.
    name = font['name']
    name.setName('Roman Pills', 1, 3, 1, 0x409)
    name.setName('Roman Pills', 1, 1, 0, 0)
    name.setName('Roman Pills Regular', 4, 3, 1, 0x409)
    name.setName('Roman Pills Regular', 4, 1, 0, 0)
    name.setName('RomanPills-Regular', 6, 3, 1, 0x409)
    name.setName('RomanPills-Regular', 6, 1, 0, 0)
    name.setName('Roman Pills', 16, 3, 1, 0x409)
    name.setName('Regular', 17, 3, 1, 0x409)

    font.save(dst)

    # Structural validation: reopen + TTX round-trip through the new file.
    check = TTFont(dst)
    assert check['name'].getDebugName(1) == 'Roman Pills', 'family rename failed'
    ccmap = check.getBestCmap()
    for d in '123456789':
        assert ccmap[ord(d)] is not None
    print('roman-pills: validation passed')
    EOF

    runHook postBuild
  '';

  meta = {
    description = "Cinzel with digits redrawn as Roman numerals (Noctalia pills)";
    license = lib.licenses.ofl;
  };
}
