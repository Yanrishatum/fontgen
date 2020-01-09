import haxe.io.Path;
using StringTools;

@:keep
class Charset {
	// Absolutely gross JS script to pull charset blocks:
	// https://en.wikipedia.org/wiki/Unicode_block
	// Array.from(document.querySelectorAll("table.wikitable tbody tr:not(.sortbottom)"))
	//   .map( (el) => el.children[0].textContent.charAt(0) != "U" ? [el.children[1], el.children[2]] : [el.children[0], el.children[1]] )
	//   .map( (el) => el[0].textContent.replace(/U\+/g, "0x").split("..")
	//     .map((v) => parseInt(v))
	//     .concat([el[1].textContent.replace(/-([A-F])/g, "_$1").replace(/(\[.*\]|[\-])/g, "").replace(/ /g, "_").toUpperCase()]) )
	//   .map( (d) => `\tpublic static var ${d[2]} : Charset = new Charset(0x${d[0].toString(16)}, 0x${d[1].toString(16)});` )
	//   .join("\r\n");
	public static var BASIC_LATIN:Charset = new Charset(0x20, 0x7e); // Does not include non-printing characters, see NONPRINTING
	public static var LATIN1_SUPPLEMENT:Charset = new Charset(0x80, 0xff);
	public static var LATIN_EXTENDED_A:Charset = new Charset(0x100, 0x17f);
	public static var LATIN_EXTENDED_B:Charset = new Charset(0x180, 0x24f);
	public static var IPA_EXTENSIONS:Charset = new Charset(0x250, 0x2af);
	public static var SPACING_MODIFIER_LETTERS:Charset = new Charset(0x2b0, 0x2ff);
	public static var COMBINING_DIACRITICAL_MARKS:Charset = new Charset(0x300, 0x36f);
	public static var GREEK_AND_COPTIC:Charset = new Charset(0x370, 0x3ff);
	public static var CYRILLIC:Charset = new Charset(0x400, 0x4ff);
	public static var CYRILLIC_SUPPLEMENT:Charset = new Charset(0x500, 0x52f);
	public static var ARMENIAN:Charset = new Charset(0x530, 0x58f);
	public static var HEBREW:Charset = new Charset(0x590, 0x5ff);
	public static var ARABIC:Charset = new Charset(0x600, 0x6ff);
	public static var SYRIAC:Charset = new Charset(0x700, 0x74f);
	public static var ARABIC_SUPPLEMENT:Charset = new Charset(0x750, 0x77f);
	public static var THAANA:Charset = new Charset(0x780, 0x7bf);
	public static var NKO:Charset = new Charset(0x7c0, 0x7ff);
	public static var SAMARITAN:Charset = new Charset(0x800, 0x83f);
	public static var MANDAIC:Charset = new Charset(0x840, 0x85f);
	public static var SYRIAC_SUPPLEMENT:Charset = new Charset(0x860, 0x86f);
	public static var ARABIC_EXTENDED_A:Charset = new Charset(0x8a0, 0x8ff);
	public static var DEVANAGARI:Charset = new Charset(0x900, 0x97f);
	public static var BENGALI:Charset = new Charset(0x980, 0x9ff);
	public static var GURMUKHI:Charset = new Charset(0xa00, 0xa7f);
	public static var GUJARATI:Charset = new Charset(0xa80, 0xaff);
	public static var ORIYA:Charset = new Charset(0xb00, 0xb7f);
	public static var TAMIL:Charset = new Charset(0xb80, 0xbff);
	public static var TELUGU:Charset = new Charset(0xc00, 0xc7f);
	public static var KANNADA:Charset = new Charset(0xc80, 0xcff);
	public static var MALAYALAM:Charset = new Charset(0xd00, 0xd7f);
	public static var SINHALA:Charset = new Charset(0xd80, 0xdff);
	public static var THAI:Charset = new Charset(0xe00, 0xe7f);
	public static var LAO:Charset = new Charset(0xe80, 0xeff);
	public static var TIBETAN:Charset = new Charset(0xf00, 0xfff);
	public static var MYANMAR:Charset = new Charset(0x1000, 0x109f);
	public static var GEORGIAN:Charset = new Charset(0x10a0, 0x10ff);
	public static var HANGUL_JAMO:Charset = new Charset(0x1100, 0x11ff);
	public static var ETHIOPIC:Charset = new Charset(0x1200, 0x137f);
	public static var ETHIOPIC_SUPPLEMENT:Charset = new Charset(0x1380, 0x139f);
	public static var CHEROKEE:Charset = new Charset(0x13a0, 0x13ff);
	public static var UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS:Charset = new Charset(0x1400, 0x167f);
	public static var OGHAM:Charset = new Charset(0x1680, 0x169f);
	public static var RUNIC:Charset = new Charset(0x16a0, 0x16ff);
	public static var TAGALOG:Charset = new Charset(0x1700, 0x171f);
	public static var HANUNOO:Charset = new Charset(0x1720, 0x173f);
	public static var BUHID:Charset = new Charset(0x1740, 0x175f);
	public static var TAGBANWA:Charset = new Charset(0x1760, 0x177f);
	public static var KHMER:Charset = new Charset(0x1780, 0x17ff);
	public static var MONGOLIAN:Charset = new Charset(0x1800, 0x18af);
	public static var UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED:Charset = new Charset(0x18b0, 0x18ff);
	public static var LIMBU:Charset = new Charset(0x1900, 0x194f);
	public static var TAI_LE:Charset = new Charset(0x1950, 0x197f);
	public static var NEW_TAI_LUE:Charset = new Charset(0x1980, 0x19df);
	public static var KHMER_SYMBOLS:Charset = new Charset(0x19e0, 0x19ff);
	public static var BUGINESE:Charset = new Charset(0x1a00, 0x1a1f);
	public static var TAI_THAM:Charset = new Charset(0x1a20, 0x1aaf);
	public static var COMBINING_DIACRITICAL_MARKS_EXTENDED:Charset = new Charset(0x1ab0, 0x1aff);
	public static var BALINESE:Charset = new Charset(0x1b00, 0x1b7f);
	public static var SUNDANESE:Charset = new Charset(0x1b80, 0x1bbf);
	public static var BATAK:Charset = new Charset(0x1bc0, 0x1bff);
	public static var LEPCHA:Charset = new Charset(0x1c00, 0x1c4f);
	public static var OL_CHIKI:Charset = new Charset(0x1c50, 0x1c7f);
	public static var CYRILLIC_EXTENDED_C:Charset = new Charset(0x1c80, 0x1c8f);
	public static var GEORGIAN_EXTENDED:Charset = new Charset(0x1c90, 0x1cbf);
	public static var SUNDANESE_SUPPLEMENT:Charset = new Charset(0x1cc0, 0x1ccf);
	public static var VEDIC_EXTENSIONS:Charset = new Charset(0x1cd0, 0x1cff);
	public static var PHONETIC_EXTENSIONS:Charset = new Charset(0x1d00, 0x1d7f);
	public static var PHONETIC_EXTENSIONS_SUPPLEMENT:Charset = new Charset(0x1d80, 0x1dbf);
	public static var COMBINING_DIACRITICAL_MARKS_SUPPLEMENT:Charset = new Charset(0x1dc0, 0x1dff);
	public static var LATIN_EXTENDED_ADDITIONAL:Charset = new Charset(0x1e00, 0x1eff);
	public static var GREEK_EXTENDED:Charset = new Charset(0x1f00, 0x1fff);
	public static var GENERAL_PUNCTUATION:Charset = new Charset(0x2000, 0x206f);
	public static var SUPERSCRIPTS_AND_SUBSCRIPTS:Charset = new Charset(0x2070, 0x209f);
	public static var CURRENCY_SYMBOLS:Charset = new Charset(0x20a0, 0x20cf);
	public static var COMBINING_DIACRITICAL_MARKS_FOR_SYMBOLS:Charset = new Charset(0x20d0, 0x20ff);
	public static var LETTERLIKE_SYMBOLS:Charset = new Charset(0x2100, 0x214f);
	public static var NUMBER_FORMS:Charset = new Charset(0x2150, 0x218f);
	public static var ARROWS:Charset = new Charset(0x2190, 0x21ff);
	public static var MATHEMATICAL_OPERATORS:Charset = new Charset(0x2200, 0x22ff);
	public static var MISCELLANEOUS_TECHNICAL:Charset = new Charset(0x2300, 0x23ff);
	public static var CONTROL_PICTURES:Charset = new Charset(0x2400, 0x243f);
	public static var OPTICAL_CHARACTER_RECOGNITION:Charset = new Charset(0x2440, 0x245f);
	public static var ENCLOSED_ALPHANUMERICS:Charset = new Charset(0x2460, 0x24ff);
	public static var BOX_DRAWING:Charset = new Charset(0x2500, 0x257f);
	public static var BLOCK_ELEMENTS:Charset = new Charset(0x2580, 0x259f);
	public static var GEOMETRIC_SHAPES:Charset = new Charset(0x25a0, 0x25ff);
	public static var MISCELLANEOUS_SYMBOLS:Charset = new Charset(0x2600, 0x26ff);
	public static var DINGBATS:Charset = new Charset(0x2700, 0x27bf);
	public static var MISCELLANEOUS_MATHEMATICAL_SYMBOLS_A:Charset = new Charset(0x27c0, 0x27ef);
	public static var SUPPLEMENTAL_ARROWS_A:Charset = new Charset(0x27f0, 0x27ff);
	public static var BRAILLE_PATTERNS:Charset = new Charset(0x2800, 0x28ff);
	public static var SUPPLEMENTAL_ARROWS_B:Charset = new Charset(0x2900, 0x297f);
	public static var MISCELLANEOUS_MATHEMATICAL_SYMBOLS_B:Charset = new Charset(0x2980, 0x29ff);
	public static var SUPPLEMENTAL_MATHEMATICAL_OPERATORS:Charset = new Charset(0x2a00, 0x2aff);
	public static var MISCELLANEOUS_SYMBOLS_AND_ARROWS:Charset = new Charset(0x2b00, 0x2bff);
	public static var GLAGOLITIC:Charset = new Charset(0x2c00, 0x2c5f);
	public static var LATIN_EXTENDED_C:Charset = new Charset(0x2c60, 0x2c7f);
	public static var COPTIC:Charset = new Charset(0x2c80, 0x2cff);
	public static var GEORGIAN_SUPPLEMENT:Charset = new Charset(0x2d00, 0x2d2f);
	public static var TIFINAGH:Charset = new Charset(0x2d30, 0x2d7f);
	public static var ETHIOPIC_EXTENDED:Charset = new Charset(0x2d80, 0x2ddf);
	public static var CYRILLIC_EXTENDED_A:Charset = new Charset(0x2de0, 0x2dff);
	public static var SUPPLEMENTAL_PUNCTUATION:Charset = new Charset(0x2e00, 0x2e7f);
	public static var CJK_RADICALS_SUPPLEMENT:Charset = new Charset(0x2e80, 0x2eff);
	public static var KANGXI_RADICALS:Charset = new Charset(0x2f00, 0x2fdf);
	public static var IDEOGRAPHIC_DESCRIPTION_CHARACTERS:Charset = new Charset(0x2ff0, 0x2fff);
	public static var CJK_SYMBOLS_AND_PUNCTUATION:Charset = new Charset(0x3000, 0x303f);
	public static var HIRAGANA:Charset = new Charset(0x3040, 0x309f);
	public static var KATAKANA:Charset = new Charset(0x30a0, 0x30ff);
	public static var BOPOMOFO:Charset = new Charset(0x3100, 0x312f);
	public static var HANGUL_COMPATIBILITY_JAMO:Charset = new Charset(0x3130, 0x318f);
	public static var KANBUN:Charset = new Charset(0x3190, 0x319f);
	public static var BOPOMOFO_EXTENDED:Charset = new Charset(0x31a0, 0x31bf);
	public static var CJK_STROKES:Charset = new Charset(0x31c0, 0x31ef);
	public static var KATAKANA_PHONETIC_EXTENSIONS:Charset = new Charset(0x31f0, 0x31ff);
	public static var ENCLOSED_CJK_LETTERS_AND_MONTHS:Charset = new Charset(0x3200, 0x32ff);
	public static var CJK_COMPATIBILITY:Charset = new Charset(0x3300, 0x33ff);
	public static var CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A:Charset = new Charset(0x3400, 0x4dbf);
	public static var YIJING_HEXAGRAM_SYMBOLS:Charset = new Charset(0x4dc0, 0x4dff);
	public static var CJK_UNIFIED_IDEOGRAPHS:Charset = new Charset(0x4e00, 0x9fff);
	public static var YI_SYLLABLES:Charset = new Charset(0xa000, 0xa48f);
	public static var YI_RADICALS:Charset = new Charset(0xa490, 0xa4cf);
	public static var LISU:Charset = new Charset(0xa4d0, 0xa4ff);
	public static var VAI:Charset = new Charset(0xa500, 0xa63f);
	public static var CYRILLIC_EXTENDED_B:Charset = new Charset(0xa640, 0xa69f);
	public static var BAMUM:Charset = new Charset(0xa6a0, 0xa6ff);
	public static var MODIFIER_TONE_LETTERS:Charset = new Charset(0xa700, 0xa71f);
	public static var LATIN_EXTENDED_D:Charset = new Charset(0xa720, 0xa7ff);
	public static var SYLOTI_NAGRI:Charset = new Charset(0xa800, 0xa82f);
	public static var COMMON_INDIC_NUMBER_FORMS:Charset = new Charset(0xa830, 0xa83f);
	public static var PHAGSPA:Charset = new Charset(0xa840, 0xa87f);
	public static var SAURASHTRA:Charset = new Charset(0xa880, 0xa8df);
	public static var DEVANAGARI_EXTENDED:Charset = new Charset(0xa8e0, 0xa8ff);
	public static var KAYAH_LI:Charset = new Charset(0xa900, 0xa92f);
	public static var REJANG:Charset = new Charset(0xa930, 0xa95f);
	public static var HANGUL_JAMO_EXTENDED_A:Charset = new Charset(0xa960, 0xa97f);
	public static var JAVANESE:Charset = new Charset(0xa980, 0xa9df);
	public static var MYANMAR_EXTENDED_B:Charset = new Charset(0xa9e0, 0xa9ff);
	public static var CHAM:Charset = new Charset(0xaa00, 0xaa5f);
	public static var MYANMAR_EXTENDED_A:Charset = new Charset(0xaa60, 0xaa7f);
	public static var TAI_VIET:Charset = new Charset(0xaa80, 0xaadf);
	public static var MEETEI_MAYEK_EXTENSIONS:Charset = new Charset(0xaae0, 0xaaff);
	public static var ETHIOPIC_EXTENDED_A:Charset = new Charset(0xab00, 0xab2f);
	public static var LATIN_EXTENDED_E:Charset = new Charset(0xab30, 0xab6f);
	public static var CHEROKEE_SUPPLEMENT:Charset = new Charset(0xab70, 0xabbf);
	public static var MEETEI_MAYEK:Charset = new Charset(0xabc0, 0xabff);
	public static var HANGUL_SYLLABLES:Charset = new Charset(0xac00, 0xd7af);
	public static var HANGUL_JAMO_EXTENDED_B:Charset = new Charset(0xd7b0, 0xd7ff);
	public static var HIGH_SURROGATES:Charset = new Charset(0xd800, 0xdb7f);
	public static var HIGH_PRIVATE_USE_SURROGATES:Charset = new Charset(0xdb80, 0xdbff);
	public static var LOW_SURROGATES:Charset = new Charset(0xdc00, 0xdfff);
	public static var PRIVATE_USE_AREA:Charset = new Charset(0xe000, 0xf8ff);
	public static var CJK_COMPATIBILITY_IDEOGRAPHS:Charset = new Charset(0xf900, 0xfaff);
	public static var ALPHABETIC_PRESENTATION_FORMS:Charset = new Charset(0xfb00, 0xfb4f);
	public static var ARABIC_PRESENTATION_FORMS_A:Charset = new Charset(0xfb50, 0xfdff);
	public static var VARIATION_SELECTORS:Charset = new Charset(0xfe00, 0xfe0f);
	public static var VERTICAL_FORMS:Charset = new Charset(0xfe10, 0xfe1f);
	public static var COMBINING_HALF_MARKS:Charset = new Charset(0xfe20, 0xfe2f);
	public static var CJK_COMPATIBILITY_FORMS:Charset = new Charset(0xfe30, 0xfe4f);
	public static var SMALL_FORM_VARIANTS:Charset = new Charset(0xfe50, 0xfe6f);
	public static var ARABIC_PRESENTATION_FORMS_B:Charset = new Charset(0xfe70, 0xfeff);
	public static var HALFWIDTH_AND_FULLWIDTH_FORMS:Charset = new Charset(0xff00, 0xffef);
	public static var SPECIALS:Charset = new Charset(0xfff0, 0xffff);
	public static var LINEAR_B_SYLLABARY:Charset = new Charset(0x10000, 0x1007f);
	public static var LINEAR_B_IDEOGRAMS:Charset = new Charset(0x10080, 0x100ff);
	public static var AEGEAN_NUMBERS:Charset = new Charset(0x10100, 0x1013f);
	public static var ANCIENT_GREEK_NUMBERS:Charset = new Charset(0x10140, 0x1018f);
	public static var ANCIENT_SYMBOLS:Charset = new Charset(0x10190, 0x101cf);
	public static var PHAISTOS_DISC:Charset = new Charset(0x101d0, 0x101ff);
	public static var LYCIAN:Charset = new Charset(0x10280, 0x1029f);
	public static var CARIAN:Charset = new Charset(0x102a0, 0x102df);
	public static var COPTIC_EPACT_NUMBERS:Charset = new Charset(0x102e0, 0x102ff);
	public static var OLD_ITALIC:Charset = new Charset(0x10300, 0x1032f);
	public static var GOTHIC:Charset = new Charset(0x10330, 0x1034f);
	public static var OLD_PERMIC:Charset = new Charset(0x10350, 0x1037f);
	public static var UGARITIC:Charset = new Charset(0x10380, 0x1039f);
	public static var OLD_PERSIAN:Charset = new Charset(0x103a0, 0x103df);
	public static var DESERET:Charset = new Charset(0x10400, 0x1044f);
	public static var SHAVIAN:Charset = new Charset(0x10450, 0x1047f);
	public static var OSMANYA:Charset = new Charset(0x10480, 0x104af);
	public static var OSAGE:Charset = new Charset(0x104b0, 0x104ff);
	public static var ELBASAN:Charset = new Charset(0x10500, 0x1052f);
	public static var CAUCASIAN_ALBANIAN:Charset = new Charset(0x10530, 0x1056f);
	public static var LINEAR_A:Charset = new Charset(0x10600, 0x1077f);
	public static var CYPRIOT_SYLLABARY:Charset = new Charset(0x10800, 0x1083f);
	public static var IMPERIAL_ARAMAIC:Charset = new Charset(0x10840, 0x1085f);
	public static var PALMYRENE:Charset = new Charset(0x10860, 0x1087f);
	public static var NABATAEAN:Charset = new Charset(0x10880, 0x108af);
	public static var HATRAN:Charset = new Charset(0x108e0, 0x108ff);
	public static var PHOENICIAN:Charset = new Charset(0x10900, 0x1091f);
	public static var LYDIAN:Charset = new Charset(0x10920, 0x1093f);
	public static var MEROITIC_HIEROGLYPHS:Charset = new Charset(0x10980, 0x1099f);
	public static var MEROITIC_CURSIVE:Charset = new Charset(0x109a0, 0x109ff);
	public static var KHAROSHTHI:Charset = new Charset(0x10a00, 0x10a5f);
	public static var OLD_SOUTH_ARABIAN:Charset = new Charset(0x10a60, 0x10a7f);
	public static var OLD_NORTH_ARABIAN:Charset = new Charset(0x10a80, 0x10a9f);
	public static var MANICHAEAN:Charset = new Charset(0x10ac0, 0x10aff);
	public static var AVESTAN:Charset = new Charset(0x10b00, 0x10b3f);
	public static var INSCRIPTIONAL_PARTHIAN:Charset = new Charset(0x10b40, 0x10b5f);
	public static var INSCRIPTIONAL_PAHLAVI:Charset = new Charset(0x10b60, 0x10b7f);
	public static var PSALTER_PAHLAVI:Charset = new Charset(0x10b80, 0x10baf);
	public static var OLD_TURKIC:Charset = new Charset(0x10c00, 0x10c4f);
	public static var OLD_HUNGARIAN:Charset = new Charset(0x10c80, 0x10cff);
	public static var HANIFI_ROHINGYA:Charset = new Charset(0x10d00, 0x10d3f);
	public static var RUMI_NUMERAL_SYMBOLS:Charset = new Charset(0x10e60, 0x10e7f);
	public static var OLD_SOGDIAN:Charset = new Charset(0x10f00, 0x10f2f);
	public static var SOGDIAN:Charset = new Charset(0x10f30, 0x10f6f);
	public static var ELYMAIC:Charset = new Charset(0x10fe0, 0x10fff);
	public static var BRAHMI:Charset = new Charset(0x11000, 0x1107f);
	public static var KAITHI:Charset = new Charset(0x11080, 0x110cf);
	public static var SORA_SOMPENG:Charset = new Charset(0x110d0, 0x110ff);
	public static var CHAKMA:Charset = new Charset(0x11100, 0x1114f);
	public static var MAHAJANI:Charset = new Charset(0x11150, 0x1117f);
	public static var SHARADA:Charset = new Charset(0x11180, 0x111df);
	public static var SINHALA_ARCHAIC_NUMBERS:Charset = new Charset(0x111e0, 0x111ff);
	public static var KHOJKI:Charset = new Charset(0x11200, 0x1124f);
	public static var MULTANI:Charset = new Charset(0x11280, 0x112af);
	public static var KHUDAWADI:Charset = new Charset(0x112b0, 0x112ff);
	public static var GRANTHA:Charset = new Charset(0x11300, 0x1137f);
	public static var NEWA:Charset = new Charset(0x11400, 0x1147f);
	public static var TIRHUTA:Charset = new Charset(0x11480, 0x114df);
	public static var SIDDHAM:Charset = new Charset(0x11580, 0x115ff);
	public static var MODI:Charset = new Charset(0x11600, 0x1165f);
	public static var MONGOLIAN_SUPPLEMENT:Charset = new Charset(0x11660, 0x1167f);
	public static var TAKRI:Charset = new Charset(0x11680, 0x116cf);
	public static var AHOM:Charset = new Charset(0x11700, 0x1173f);
	public static var DOGRA:Charset = new Charset(0x11800, 0x1184f);
	public static var WARANG_CITI:Charset = new Charset(0x118a0, 0x118ff);
	public static var NANDINAGARI:Charset = new Charset(0x119a0, 0x119ff);
	public static var ZANABAZAR_SQUARE:Charset = new Charset(0x11a00, 0x11a4f);
	public static var SOYOMBO:Charset = new Charset(0x11a50, 0x11aaf);
	public static var PAU_CIN_HAU:Charset = new Charset(0x11ac0, 0x11aff);
	public static var BHAIKSUKI:Charset = new Charset(0x11c00, 0x11c6f);
	public static var MARCHEN:Charset = new Charset(0x11c70, 0x11cbf);
	public static var MASARAM_GONDI:Charset = new Charset(0x11d00, 0x11d5f);
	public static var GUNJALA_GONDI:Charset = new Charset(0x11d60, 0x11daf);
	public static var MAKASAR:Charset = new Charset(0x11ee0, 0x11eff);
	public static var TAMIL_SUPPLEMENT:Charset = new Charset(0x11fc0, 0x11fff);
	public static var CUNEIFORM:Charset = new Charset(0x12000, 0x123ff);
	public static var CUNEIFORM_NUMBERS_AND_PUNCTUATION:Charset = new Charset(0x12400, 0x1247f);
	public static var EARLY_DYNASTIC_CUNEIFORM:Charset = new Charset(0x12480, 0x1254f);
	public static var EGYPTIAN_HIEROGLYPHS:Charset = new Charset(0x13000, 0x1342f);
	public static var EGYPTIAN_HIEROGLYPH_FORMAT_CONTROLS:Charset = new Charset(0x13430, 0x1343f);
	public static var ANATOLIAN_HIEROGLYPHS:Charset = new Charset(0x14400, 0x1467f);
	public static var BAMUM_SUPPLEMENT:Charset = new Charset(0x16800, 0x16a3f);
	public static var MRO:Charset = new Charset(0x16a40, 0x16a6f);
	public static var BASSA_VAH:Charset = new Charset(0x16ad0, 0x16aff);
	public static var PAHAWH_HMONG:Charset = new Charset(0x16b00, 0x16b8f);
	public static var MEDEFAIDRIN:Charset = new Charset(0x16e40, 0x16e9f);
	public static var MIAO:Charset = new Charset(0x16f00, 0x16f9f);
	public static var IDEOGRAPHIC_SYMBOLS_AND_PUNCTUATION:Charset = new Charset(0x16fe0, 0x16fff);
	public static var TANGUT:Charset = new Charset(0x17000, 0x187ff);
	public static var TANGUT_COMPONENTS:Charset = new Charset(0x18800, 0x18aff);
	public static var KANA_SUPPLEMENT:Charset = new Charset(0x1b000, 0x1b0ff);
	public static var KANA_EXTENDED_A:Charset = new Charset(0x1b100, 0x1b12f);
	public static var SMALL_KANA_EXTENSION:Charset = new Charset(0x1b130, 0x1b16f);
	public static var NUSHU:Charset = new Charset(0x1b170, 0x1b2ff);
	public static var DUPLOYAN:Charset = new Charset(0x1bc00, 0x1bc9f);
	public static var SHORTHAND_FORMAT_CONTROLS:Charset = new Charset(0x1bca0, 0x1bcaf);
	public static var BYZANTINE_MUSICAL_SYMBOLS:Charset = new Charset(0x1d000, 0x1d0ff);
	public static var MUSICAL_SYMBOLS:Charset = new Charset(0x1d100, 0x1d1ff);
	public static var ANCIENT_GREEK_MUSICAL_NOTATION:Charset = new Charset(0x1d200, 0x1d24f);
	public static var MAYAN_NUMERALS:Charset = new Charset(0x1d2e0, 0x1d2ff);
	public static var TAI_XUAN_JING_SYMBOLS:Charset = new Charset(0x1d300, 0x1d35f);
	public static var COUNTING_ROD_NUMERALS:Charset = new Charset(0x1d360, 0x1d37f);
	public static var MATHEMATICAL_ALPHANUMERIC_SYMBOLS:Charset = new Charset(0x1d400, 0x1d7ff);
	public static var SUTTON_SIGNWRITING:Charset = new Charset(0x1d800, 0x1daaf);
	public static var GLAGOLITIC_SUPPLEMENT:Charset = new Charset(0x1e000, 0x1e02f);
	public static var NYIAKENG_PUACHUE_HMONG:Charset = new Charset(0x1e100, 0x1e14f);
	public static var WANCHO:Charset = new Charset(0x1e2c0, 0x1e2ff);
	public static var MENDE_KIKAKUI:Charset = new Charset(0x1e800, 0x1e8df);
	public static var ADLAM:Charset = new Charset(0x1e900, 0x1e95f);
	public static var INDIC_SIYAQ_NUMBERS:Charset = new Charset(0x1ec70, 0x1ecbf);
	public static var OTTOMAN_SIYAQ_NUMBERS:Charset = new Charset(0x1ed00, 0x1ed4f);
	public static var ARABIC_MATHEMATICAL_ALPHABETIC_SYMBOLS:Charset = new Charset(0x1ee00, 0x1eeff);
	public static var MAHJONG_TILES:Charset = new Charset(0x1f000, 0x1f02f);
	public static var DOMINO_TILES:Charset = new Charset(0x1f030, 0x1f09f);
	public static var PLAYING_CARDS:Charset = new Charset(0x1f0a0, 0x1f0ff);
	public static var ENCLOSED_ALPHANUMERIC_SUPPLEMENT:Charset = new Charset(0x1f100, 0x1f1ff);
	public static var ENCLOSED_IDEOGRAPHIC_SUPPLEMENT:Charset = new Charset(0x1f200, 0x1f2ff);
	public static var MISCELLANEOUS_SYMBOLS_AND_PICTOGRAPHS:Charset = new Charset(0x1f300, 0x1f5ff);
	public static var EMOTICONS:Charset = new Charset(0x1f600, 0x1f64f);
	public static var ORNAMENTAL_DINGBATS:Charset = new Charset(0x1f650, 0x1f67f);
	public static var TRANSPORT_AND_MAP_SYMBOLS:Charset = new Charset(0x1f680, 0x1f6ff);
	public static var ALCHEMICAL_SYMBOLS:Charset = new Charset(0x1f700, 0x1f77f);
	public static var GEOMETRIC_SHAPES_EXTENDED:Charset = new Charset(0x1f780, 0x1f7ff);
	public static var SUPPLEMENTAL_ARROWS_C:Charset = new Charset(0x1f800, 0x1f8ff);
	public static var SUPPLEMENTAL_SYMBOLS_AND_PICTOGRAPHS:Charset = new Charset(0x1f900, 0x1f9ff);
	public static var CHESS_SYMBOLS:Charset = new Charset(0x1fa00, 0x1fa6f);
	public static var SYMBOLS_AND_PICTOGRAPHS_EXTENDED_A:Charset = new Charset(0x1fa70, 0x1faff);
	public static var CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B:Charset = new Charset(0x20000, 0x2a6df);
	public static var CJK_UNIFIED_IDEOGRAPHS_EXTENSION_C:Charset = new Charset(0x2a700, 0x2b73f);
	public static var CJK_UNIFIED_IDEOGRAPHS_EXTENSION_D:Charset = new Charset(0x2b740, 0x2b81f);
	public static var CJK_UNIFIED_IDEOGRAPHS_EXTENSION_E:Charset = new Charset(0x2b820, 0x2ceaf);
	public static var CJK_UNIFIED_IDEOGRAPHS_EXTENSION_F:Charset = new Charset(0x2ceb0, 0x2ebef);
	public static var CJK_COMPATIBILITY_IDEOGRAPHS_SUPPLEMENT:Charset = new Charset(0x2f800, 0x2fa1f);
	public static var TAGS:Charset = new Charset(0xe0000, 0xe007f);
	public static var VARIATION_SELECTORS_SUPPLEMENT:Charset = new Charset(0xe0100, 0xe01ef);
	public static var SUPPLEMENTARY_PRIVATE_USE_AREA_A:Charset = new Charset(0xf0000, 0xfffff);
	public static var SUPPLEMENTARY_PRIVATE_USE_AREA_B:Charset = new Charset(0x100000, 0x10ffff);

	// Nonprinting characters are technically part of the BASIC_LATIN
	// but they aren't printed, and usually not even present in the font file
	// Another reason to separate is so `LATIN` charset won't complain about 32 missing characters.
	public static var NONPRINTING:Charset = exactRange(0x0, 0x1f).appendChar(0x7F); // 0x7F = DEL
	// Covers all currently supported unicode blocks
	public static var EVERYTHING:Charset = new Charset(0x000000, 0x1fffff);
	
	public static var _ALIAS:Map<String, Array<Charset>> = [
		"LATIN" => [BASIC_LATIN, LATIN1_SUPPLEMENT],
		"ANSI" => [BASIC_LATIN, LATIN1_SUPPLEMENT],
		"ASCII" => [NONPRINTING, BASIC_LATIN],
		"LATIN_EXTENDED" => [
			LATIN_EXTENDED_A,
			LATIN_EXTENDED_B,
			LATIN_EXTENDED_C,
			LATIN_EXTENDED_D,
			LATIN_EXTENDED_E,
			LATIN_EXTENDED_ADDITIONAL
		],
		"CYRILLIC_EXTENDED" => [
			CYRILLIC,
			CYRILLIC_SUPPLEMENT,
			CYRILLIC_EXTENDED_A,
			CYRILLIC_EXTENDED_B,
			CYRILLIC_EXTENDED_C
		],
		"POLISH" => [exactChars("ĄĆĘŁŃÓŚŹŻąćęłńóśźż")],
		"TURKISH" => [exactChars("ÂÇĞIİÎÖŞÜÛâçğıİîöşüû")],
		"JP_KANA" => [
			KATAKANA,
			KATAKANA_PHONETIC_EXTENSIONS,
			HIRAGANA,
			KANA_EXTENDED_A,
			KANA_SUPPLEMENT,
			HALFWIDTH_AND_FULLWIDTH_FORMS,
			CJK_SYMBOLS_AND_PUNCTUATION,
			GENERAL_PUNCTUATION,
			exactChars("・ー「」、。『』“”！：？％＆（）－０１２３４５６７８９")
		], // Exact chars just in case I didn't cover something
		"UNICODE_SPECIALS" => [exactChars("�□")]
	];

	inline static function transformName(name:String):String {
		return ~/-([A-F])/g.replace(name.toUpperCase(), "_$1").replace(" ", "_").replace("-", "");
	}

	public static function findOne(name:String):Array<Charset> {
		name = transformName(name);
		var aliased = _ALIAS.get(name);
		if (aliased != null)
			return aliased;
		var cset:Charset = Reflect.field(Charset, name);
		return cset != null ? [cset] : [];
	}

	public static function find(names:Array<String>):Array<Charset> {
		var sets = [];
		for (n in names) {
			n = transformName(n);
			var aliased = _ALIAS.get(n);
			if (aliased != null) {
				for (c in aliased)
					sets.push(c);
				continue;
			}
			var cset:Charset = Reflect.field(Charset, n);
			if (cset != null)
				sets.push(cset);
		}
		return sets;
	}

	public static function parse(charsets:Array<Dynamic>):Array<Charset> {
		var sets = [];
		for (val in charsets) {
			if (Std.is(val, String)) {
				var name:String = transformName(val);
				var aliased = _ALIAS.get(name);
				if (aliased != null) {
					for (c in aliased)
						sets.push(c);
					continue;
				}
				var cset:Charset = Reflect.field(Charset, name);
				if (cset != null)
					sets.push(cset);
				else {
					var fpath:String = val;
					if (sys.FileSystem.exists(fpath)) {
						var txt = sys.io.File.getContent(fpath);
						try {
							var xml:Xml = Xml.parse(txt);
							var cset = new Charset(0, 0);
							cset.exact = [];
							buildXmlChars(cset, xml);
							sets.push(cset);
						} catch (e:Dynamic) {
							sets.push(exactChars(txt));
						}
					} else {
						sets.push(exactChars(fpath));
					}
				}
			} else if (Std.is(val, Array)) {
				var sub = parse(val);
				for (c in sub) {
					sets.push(c);
				}
			} else {
				// ???
			}
		}
		return sets;
	}
	
	static function buildXmlChars(cset:Charset, node:Xml)
	{
		switch (node.nodeType) {
			case Element, Document:
				for (child in node)
					buildXmlChars(cset, child);
			case Comment, DocType: // skip
			default:
				var str = node.nodeValue;
				for (char in str.iterator()) {
					if (cset.exact.indexOf(char) == -1)
						cset.exact.push(char);
				}
		}
	}

	public var min:Int;
	public var max:Int;

	public var exact:Array<Int>;

	public static function exactChars(list:String):Charset {
		var c = new Charset(0, 0);
		c.exact = [];
		for (i in 0...list.length) {
			c.exact.push(list.charCodeAt(i));
		}
		return c;
	}
	
	public static function exactRange(min:Int, max:Int):Charset {
		var c = new Charset(0, 0);
		c.exact = [];
		for (i in min...max+1) {
			c.exact.push(i);
		}
		return c;
	}

	public function new(min:Int, max:Int) {
		this.min = min;
		this.max = max;
	}
	
	public function contains(char:Int):Bool {
		if (exact != null) return exact.indexOf(char) != -1;
		else return char >= min && char <= max;
	}

	public function iterator():Iterator<Int> {
		return exact != null ? exact.iterator() : new IntIterator(min, max+1);
	}
	
	public function toExact():Charset {
		if (exact == null) {
			exact = [];
			if (min != 0 || max != 0) {
				for (i in min...max+1) {
					exact.push(i);
				}
			}
		}
		return this;
	}
	
	public function appendChar(char:Int):Charset {
		toExact();
		exact.push(char);
		return this;
	}
	
	public function append(other:Charset):Charset {
		toExact();
		for (char in other) {
			if (exact.indexOf(char) != -1) exact.push(char);
		}
		return this;
	}

	public function toString() {
		if (exact != null) {
			var buf = new StringBuf();
			for (c in exact) {
				buf.addChar(c);
			}
			return buf.toString();
		}
		return "U+" + min.hex(4) + "..U+" + max.hex(4);
	}
}
