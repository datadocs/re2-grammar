grammar Re2;
// Based off re2 grammar from:                      https://github.com/google/re2/wiki/Syntax/
// Overall top-level guidance and inspiration from: https://github.com/bkiers/pcre-parser/blob/master/src/main/antlr4/nl/bigo/pcreparser/PCRE.g4

root
    : alternation EOF
    ;

alternation
    : expr ('|' expr)*
    ;

expr
    : (atom quantifier?) *
    ;

atom
    : '[' '^'? character_class+ ']'                 # Class
    | Perl_Character_Class                          # Perl
    | Escape_Sequence                               # Escape
    | Empty_String                                  # Anchor
    | grouping                                      # Group
    | literal                                       # Characters
    ;

quantifier
    : '?' ('?')?                                    # OptionalQuanitifier
    | '+' ('?')?                                    # OneOrMoreQuantifier
    | '*' ('?')?                                    # ZeroOrMoreQuantifier
    | '{' number (',' number?)? '}' ('?')?          # FixedNumberQuantifier
    ;

grouping
    : '(?' ('P<' name '>')? alternation ')'         # CaptureGroup
    | '(?' flags (':' alternation)? ')'             # FlagGroup
    ;

character_class
    : ASCII_Character_Class                         # ASCII
    | Unicode_Character_Class                       # Unicode
    | Perl_Character_Class                          # PerlClass
    | literal '-' literal                           # LiteralRange
    | literal                                       # LiteralChar
    ;

name
    : Alpha_numeric | literal
    ;

number
    : Digit+
    ;

flags
    : option_flags? '-' option_flags
    | option_flags
    ;

option_flags
    : ('i' | 'm' | 's' | 'U')+
    ;

literal
    : Alpha_Numeric
    | Other
    ;

Digit: [0-9];
Perl_Character_Class: '\\d'|'\\D'|'\\s'|'\\S'|'\\w'|'\\W';
Empty_String: '^'|'$'|'\\A'|'\\b'|'\\B'|'\\g'|'\\G'|'\\Z'|'\\z';
Escape_Sequence: '\\a'|'\\f'|'\\t'|'\\n'|'\\r'|'\\v'|'\\*'|'\\' OctDigit OctDigit OctDigit|'\\x' HexDigit HexDigit|'\\x{' HexDigit HexDigit HexDigit HexDigit HexDigit HexDigit '}'|'\\C'|'\\Q' .+? '\\E';
ASCII_Character_Class: '[:' '^'? ('alnum'|'alpha'|'ascii'|'blank'|'cntrl'|'digit'|'graph'|'lower'|'print'|'punct'|'space'|'upper'|'word'|'xdigit') ':]';
Unicode_Character_Class: ('\\p'|'\\P') ('C'|'L'|'M'|'N'|'P'|'S'|'Z'|'Adlam'|'Ahom'|'Anatolian_Hieroglyphs'|'Arabic'|'Armenian'|'Avestan'|'Balinese'|'Bamum'|'Bassa_Vah'|'Batak'|'Bengali'|'Bhaiksuki'|'Bopomofo'|'Brahmi'|'Braille'|'Buginese'|'Buhid'|'Canadian_Aboriginal'|'Carian'|'Caucasian_Albanian'|'Chakma'|'Cham'|'Cherokee'|'Chorasmian'|'Common'|'Coptic'|'Cuneiform'|'Cypriot'|'Cypro_Minoan'|'Cyrillic'|'Deseret'|'Devanagari'|'Dives_Akuru'|'Dogra'|'Duployan'|'Egyptian_Hieroglyphs'|'Elbasan'|'Elymaic'|'Ethiopic'|'Georgian'|'Glagolitic'|'Gothic'|'Grantha'|'Greek'|'Gujarati'|'Gunjala_Gondi'|'Gurmukhi'|'Han'|'Hangul'|'Hanifi_Rohingya'|'Hanunoo'|'Hatran'|'Hebrew'|'Hiragana'|'Imperial_Aramaic'|'Inherited'|'Inscriptional_Pahlavi'|'Inscriptional_Parthian'|'Javanese'|'Kaithi'|'Kannada'|'Katakana'|'Kawi'|'Kayah_Li'|'Kharoshthi'|'Khitan_Small_Script'|'Khmer'|'Khojki'|'Khudawadi'|'Lao'|'Latin'|'Lepcha'|'Limbu'|'Linear_A'|'Linear_B'|'Lisu'|'Lycian'|'Lydian'|'Mahajani'|'Makasar'|'Malayalam'|'Mandaic'|'Manichaean'|'Marchen'|'Masaram_Gondi'|'Medefaidrin'|'Meetei_Mayek'|'Mende_Kikakui'|'Meroitic_Cursive'|'Meroitic_Hieroglyphs'|'Miao'|'Modi'|'Mongolian'|'Mro'|'Multani'|'Myanmar'|'Nabataean'|'Nag_Mundari'|'Nandinagari'|'New_Tai_Lue'|'Newa'|'Nko'|'Nushu'|'Nyiakeng_Puachue_Hmong'|'Ogham'|'Ol_Chiki'|'Old_Hungarian'|'Old_Italic'|'Old_North_Arabian'|'Old_Permic'|'Old_Persian'|'Old_Sogdian'|'Old_South_Arabian'|'Old_Turkic'|'Old_Uyghur'|'Oriya'|'Osage'|'Osmanya'|'Pahawh_Hmong'|'Palmyrene'|'Pau_Cin_Hau'|'Phags_Pa'|'Phoenician'|'Psalter_Pahlavi'|'Rejang'|'Runic'|'Samaritan'|'Saurashtra'|'Sharada'|'Shavian'|'Siddham'|'SignWriting'|'Sinhala'|'Sogdian'|'Sora_Sompeng'|'Soyombo'|'Sundanese'|'Syloti_Nagri'|'Syriac'|'Tagalog'|'Tagbanwa'|'Tai_Le'|'Tai_Tham'|'Tai_Viet'|'Takri'|'Tamil'|'Tangsa'|'Tangut'|'Telugu'|'Thaana'|'Thai'|'Tibetan'|'Tifinagh'|'Tirhuta'|'Toto'|'Ugaritic'|'Vai'|'Vithkuqi'|'Wancho'|'Warang_Citi'|'Yezidi'|'Yi'|'Zanabazar_Square');
fragment HexDigit: [0-9a-fA-F];
fragment OctDigit: [0-7];
Alpha_Numeric: [a-zA-Z_0-9];
Other: .;
