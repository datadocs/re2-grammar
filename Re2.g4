grammar Re2;
// Based off re2 grammar from:                      https://github.com/google/re2/wiki/Syntax/
// Overall top-level guidance and inspiration from: https://github.com/bkiers/pcre-parser/blob/master/src/main/antlr4/nl/bigo/pcreparser/PCRE.g4

root
    : regex EOF
    ;

regex
    : (atom quantifier?) *                          # SingularExpr
    | regex (Or regex)+                    # AlternationExpr
    ;


atom
    : character_class
    | escape_sequence
    | anchor
    | grouping
    | literal
    ;

character_class
    : OpenBracket Caret? character_class_type+ CloseBracket
    ;

quantifier
    : Question Question?                                    # OptionalQuanitifier
    | Plus Question?                                    # OneOrMoreQuantifier
    | Star Question?                                    # ZeroOrMoreQuantifier
    | OpenBrace number (Comma number?)? CloseBrace Question?          # FixedNumberQuantifier
    ;



grouping
    : OpenParen Question (P_Upper LessThan name GreaterThan)? regex CloseParen               # CaptureGroup
    | OpenParen Question flags (Colon regex)? CloseParen                  # FlagGroup
    ;



character_class_type
    : ascii_class                         # ASCII
    | unicode_class                       # Unicode
    | literal Dash literal                           # LiteralRange
    | literal                                       # LiteralChar
    ;

number
    : Digit+
    ;

flags
    : option_flags? Dash option_flags
    | option_flags
    ;

option_flags
    : (I_Lower | M_Lower | S_Lower U_Upper)+
    ;
//name: literal;
//literal
//    : ANY
//    ;

DecimalDigit: '\\d';
NotDecimalDigit: '\\D';
Space: '\\s';
NotSpace: '\\S';
WordChar                : '\\w';
NotWordChar             : '\\W';
Dot                     : '.';
OneDataUnit             : '\\C';
WordBoundary                   : '\\b';
NotWordBoundary                : '\\B';
EndOfString : '\\Z';
AbsoluteEndOfString                   : '\\z';
StartOfString                : '\\A';
EndOfLine             : '$';
Caret                : '^';
Quoted      : '\\' NonAlphaNumeric;
BlockQuoted : '\\Q' .*? '\\E';

BellChar       : '\\a';
FormFeed       : '\\f';
Tab            : '\\t';
CarriageReturn : '\\r';
NewLine        : '\\n';
VerticalWhiteSpace      : '\\v';
HexChar        : '\\x' ( HexDigit HexDigit| '{' HexDigit HexDigit HexDigit+'}');
OctalChar: '\\' OctDigit OctDigit OctDigit;

literal: letter|Digit|OtherChar|punctuation_safe;
name: name_char;
name_char: letter|Digit|OtherChar;
escape_sequence: DecimalDigit|NotDecimalDigit|Space|NotSpace|WordChar|NotWordChar|Dot|OneDataUnit|WordBoundary|NotWordBoundary|EndOfString|AbsoluteEndOfString|Quoted|BlockQuoted|BellChar|FormFeed|Tab|CarriageReturn|Newline|VerticalWhiteSpace|HexChar|OctalChar;
anchor: Caret|EndOfLine;
ascii_class: OpenBrace Colon Caret? ('alnum'|'alpha'|'ascii'|'blank'|'cntrl'|'digit'|'graph'|'lower'|'print'|'punct'|'space'|'upper'|'word'|'xdigit') Colon CloseBrace;
unicode_class: (Escape (P_Upper | P_Lower)) ('C'|'L'|'M'|'N'|'P'|'S'|'Z'|'Adlam'|'Ahom'|'Anatolian_Hieroglyphs'|'Arabic'|'Armenian'|'Avestan'|'Balinese'|'Bamum'|'Bassa_Vah'|'Batak'|'Bengali'|'Bhaiksuki'|'Bopomofo'|'Brahmi'|'Braille'|'Buginese'|'Buhid'|'Canadian_Aboriginal'|'Carian'|'Caucasian_Albanian'|'Chakma'|'Cham'|'Cherokee'|'Chorasmian'|'Common'|'Coptic'|'Cuneiform'|'Cypriot'|'Cypro_Minoan'|'Cyrillic'|'Deseret'|'Devanagari'|'Dives_Akuru'|'Dogra'|'Duployan'|'Egyptian_Hieroglyphs'|'Elbasan'|'Elymaic'|'Ethiopic'|'Georgian'|'Glagolitic'|'Gothic'|'Grantha'|'Greek'|'Gujarati'|'Gunjala_Gondi'|'Gurmukhi'|'Han'|'Hangul'|'Hanifi_Rohingya'|'Hanunoo'|'Hatran'|'Hebrew'|'Hiragana'|'Imperial_Aramaic'|'Inherited'|'Inscriptional_Pahlavi'|'Inscriptional_Parthian'|'Javanese'|'Kaithi'|'Kannada'|'Katakana'|'Kawi'|'Kayah_Li'|'Kharoshthi'|'Khitan_Small_Script'|'Khmer'|'Khojki'|'Khudawadi'|'Lao'|'Latin'|'Lepcha'|'Limbu'|'Linear_A'|'Linear_B'|'Lisu'|'Lycian'|'Lydian'|'Mahajani'|'Makasar'|'Malayalam'|'Mandaic'|'Manichaean'|'Marchen'|'Masaram_Gondi'|'Medefaidrin'|'Meetei_Mayek'|'Mende_Kikakui'|'Meroitic_Cursive'|'Meroitic_Hieroglyphs'|'Miao'|'Modi'|'Mongolian'|'Mro'|'Multani'|'Myanmar'|'Nabataean'|'Nag_Mundari'|'Nandinagari'|'New_Tai_Lue'|'Newa'|'Nko'|'Nushu'|'Nyiakeng_Puachue_Hmong'|'Ogham'|'Ol_Chiki'|'Old_Hungarian'|'Old_Italic'|'Old_North_Arabian'|'Old_Permic'|'Old_Persian'|'Old_Sogdian'|'Old_South_Arabian'|'Old_Turkic'|'Old_Uyghur'|'Oriya'|'Osage'|'Osmanya'|'Pahawh_Hmong'|'Palmyrene'|'Pau_Cin_Hau'|'Phags_Pa'|'Phoenician'|'Psalter_Pahlavi'|'Rejang'|'Runic'|'Samaritan'|'Saurashtra'|'Sharada'|'Shavian'|'Siddham'|'SignWriting'|'Sinhala'|'Sogdian'|'Sora_Sompeng'|'Soyombo'|'Sundanese'|'Syloti_Nagri'|'Syriac'|'Tagalog'|'Tagbanwa'|'Tai_Le'|'Tai_Tham'|'Tai_Viet'|'Takri'|'Tamil'|'Tangsa'|'Tangut'|'Telugu'|'Thaana'|'Thai'|'Tibetan'|'Tifinagh'|'Tirhuta'|'Toto'|'Ugaritic'|'Vai'|'Vithkuqi'|'Wancho'|'Warang_Citi'|'Yezidi'|'Yi'|'Zanabazar_Square');
//Alpha_Numeric: [a-zA-Z_0-9];


//anyChar: punctuation|Digit|letter|Other;
punctuation_safe: CloseBracket|Escape|CloseBracket|OpenBrace|CloseBrace|Colon|Dash|Comma|LessThan|GreaterThan;
Question: '?';
Star: '*';
Plus: '+';
Or: '|';
OpenBracket: '[';
Escape: '\\';
CloseBracket: ']';
OpenBrace: '{';
CloseBrace: '}';
OpenParen: '(';
CloseParen: ')';
LessThan: '<';
GreaterThan: '>';
Colon: ':';
Comma: ',';
Dash: '-';

Digit: [0-9];

// lowercase and uppercase letters
letter: A_Lower|B_Lower|C_Lower|D_Lower|E_Lower|F_Lower|G_Lower|H_Lower|I_Lower|J_Lower|K_Lower|L_Lower|M_Lower|N_Lower|O_Lower|P_Lower|Q_Lower|R_Lower|S_Lower|T_Lower|U_Lower|V_Lower|W_Lower|X_Lower|Y_Lower|Z_Lower|A_Upper|B_Upper|C_Upper|D_Upper|E_Upper|F_Upper|G_Upper|H_Upper|I_Upper|J_Upper|K_Upper|L_Upper|M_Upper|N_Upper|O_Upper|P_Upper|Q_Upper|R_Upper|S_Upper|T_Upper|U_Upper|V_Upper|W_Upper|X_Upper|Y_Upper|Z_Upper;
A_Lower : 'a';
B_Lower : 'b';
C_Lower : 'c';
D_Lower : 'd';
E_Lower : 'e';
F_Lower : 'f';
G_Lower : 'g';
H_Lower : 'h';
I_Lower : 'i';
J_Lower : 'j';
K_Lower : 'k';
L_Lower : 'l';
M_Lower : 'm';
N_Lower : 'n';
O_Lower : 'o';
P_Lower : 'p';
Q_Lower : 'q';
R_Lower : 'r';
S_Lower : 's';
T_Lower : 't';
U_Lower : 'u';
V_Lower : 'v';
W_Lower : 'w';
X_Lower : 'x';
Y_Lower : 'y';
Z_Lower : 'z';
A_Upper : 'A';
B_Upper : 'B';
C_Upper : 'C';
D_Upper : 'D';
E_Upper : 'E';
F_Upper : 'F';
G_Upper : 'G';
H_Upper : 'H';
I_Upper : 'I';
J_Upper : 'J';
K_Upper : 'K';
L_Upper : 'L';
M_Upper : 'M';
N_Upper : 'N';
O_Upper : 'O';
P_Upper : 'P';
Q_Upper : 'Q';
R_Upper : 'R';
S_Upper : 'S';
T_Upper : 'T';
U_Upper : 'U';
V_Upper : 'V';
W_Upper : 'W';
X_Upper : 'X';
Y_Upper : 'Y';
Z_Upper : 'Z';
OtherChar : . ;
fragment UnderscoreAlphaNumerics : ('_' | AlphaNumeric)+;
fragment AlphaNumerics           : AlphaNumeric+;
fragment AlphaNumeric            : [a-zA-Z0-9];
fragment NonAlphaNumeric         : ~[a-zA-Z0-9];
fragment HexDigit: [0-9a-fA-F];
fragment OctDigit: [0-7];
fragment ASCII                   : [\u0000-\u007F];
