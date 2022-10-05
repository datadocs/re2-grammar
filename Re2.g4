/*
 * Copyright (c) 2022 by David Litwin
 *
 * The MIT license.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Project          : An ANTLR 4 grammar for Re2
 * Developed by     : David Litwin, david@datadocs.com
 * Grammar from     : https://github.com/google/re2/wiki/Syntax/
 * Inspiration from : Bart Kiers' https://github.com/bkiers/pcre-parser/blob/master/src/main/antlr4/nl/bigo/pcreparser/PCRE.g4
 */

 // Note: Single-line comments after "//" are author comments.
 //       Multi-line comments between "/* ... */" are copy-pasted from Re2 Syntax
grammar Re2;

root
    : regex EOF
    ;

/*     Composition
 *     The operator precedence, from weakest to strongest binding, is first alternation,
 *     then concatenation, and finally the repetition operators. Explicit parentheses can be used
 *     to force different meanings, just as in arithmetic expressions.
 *     Some examples: ab|cd is equivalent to (ab)|(cd); ab* is equivalent to a(b*).
 *
 *      xy      x followed by y
 *      x|y     x or y (prefer x)
*/
regex
    : (atom repetition?)*                                           # RegexUnit
    | regex (Pipe regex)+                                           # RegexAlternation
    ;


/*      Repetitions
 *      x*      zero or more x, prefer more
 *      x+      one or more x, prefer more
 *      x?      zero or one x, prefer one
 *      x{n,m}  n or n+1 or ... or m x, prefer more
 *      x{n,}   n or more x, prefer more
 *      x{n}    exactly n x
 *      x*?     zero or more x, prefer fewer
 *      x+?     one or more x, prefer fewer
 *      x??     zero or one x, prefer zero
 *      x{n,m}? n or n+1 or ... or m x, prefer fewer
 *      x{n,}?  n or more x, prefer fewer
 *      x{n}?   exactly n x
*/
repetition
    : QuestionMark QuestionMark?                                    # OptionalQuanitifier
    | Plus QuestionMark?                                            # OneOrMoreQuantifier
    | Star QuestionMark?                                            # ZeroOrMoreQuantifier
    | OpenBrace number (Comma number?)? CloseBrace QuestionMark?    # NumericQuantifier
    ;


/*      kinds of Atoms/Expressions                      example
 *      any character                                   .
 *      character class                                 [xyz]
 *      negated character class                         [^xyz]
 *      Perl character class                            \d
 *      negated Perl character class                    \D
 *      ASCII character class (link)                    [[:alpha:]]
 *      negated ASCII character class                   [[:^alpha:]]
 *      Unicode character class (one-letter)            \pN
 *      Unicode character class                         \p{Greek}
 *      negated Unicode character class (one-letter)    \PN
 *      negated Unicode character class                 \P{Greek}
*/
// Note: literals and metacharacters are often different within and
//       outside of character classes, so we handle them separately.
//       Example: [$]$ --> A literal '$' followed by end of string.
atom
    : literal_outside_character_class
    | meta_outside_character_class
    | grouping
    | character_class
    ;

// Example: r'a9{}<>:,-é'
literal_outside_character_class
    : letter
    | Digit
    | OpenBrace
    | CloseBrace
    | LessThan
    | GreaterThan
    | Colon
    | Comma
    | Dash
    | SingleSpace
    | OtherChar
    | OtherPunctuation
    ;

// Example: r'^\d\n\Cd.\pL\b$'
meta_outside_character_class
    : dot_matches_all
    | perl_character_class
    | other_escape_sequence
    | other_escape_sequence_quoted
    | anchor_char
    | anchor_escape
    | unicode_class
    ;

dot_matches_all
    : Dot
    ;

/*      Perl character classes (all ASCII-only)
 *      \d      digits (≡ [0-9])
 *      \D      not digits (≡ [^0-9])
 *      \s      whitespace (≡ [\t\n\f\r ])
 *      \S      not whitespace (≡ [^\t\n\f\r ])
 *      \w      word characters (≡ [0-9A-Za-z_])
 *      \W      not word characters (≡ [^0-9A-Za-z_])
 */
perl_character_class
    : DecimalDigit
    | NotDecimalDigit
    | Space
    | NotSpace
    | WordChar
    | NotWordChar
    ;

DecimalDigit:                           '\\d';
NotDecimalDigit:                        '\\D';
Space:                                  '\\s';
NotSpace:                               '\\S';
WordChar:                               '\\w';
NotWordChar:                            '\\W';


/* (Other) Escape sequences
 *      \a          bell (≡ \007)
 *      \f          form feed (≡ \014)
 *      \t          horizontal tab (≡ \011)
 *      \n          newline (≡ \012)
 *      \r          carriage return (≡ \015)
 *      \v          vertical tab character (≡ \013)
 *      \*          literal *, for any punctuation character *
 *      \123        octal character code (up to three digits)
 *      \x7F        hex character code (exactly two digits)
 *      \x{10FFFF}  hex character code -- (DL note: in practice, can be 1-6 digits), but here just allow 1 or more
 *      \C          match a single byte even in UTF-8 mode
 *      \Q...\E     literal text ... even if ... has punctuation
 */
other_escape_sequence
    : BellChar
    | FormFeed
    | Tab
    | Newline
    | CarriageReturn
    | VerticalTab
    | Quoted        // this covers many of the special metachars, such as \(
    | OctalChar
    | HexChar
    ;

BellChar:                               '\\a';
FormFeed:                               '\\f';
Tab:                                    '\\t';
Newline:                                '\\n';
CarriageReturn:                         '\\r';
VerticalTab:                            '\\v';
Quoted:                                 '\\' NonAlphaNumeric;

OctalChar:                              '\\' OctalDigit OctalDigit OctalDigit?;
HexChar:                                HexCharTwo | HexCharExtended;
fragment HexCharTwo:                    '\\x' HexDigit HexDigit;
fragment HexCharExtended:               '\\x' OpenBrace HexDigit+ CloseBrace;

// Note: the following two escape sequences may not be used within a
//       character classes, so we are separating them into its own rule.
other_escape_sequence_quoted
    : OneDataUnit
    | BlockQuoted
    ;
OneDataUnit:                        '\\C';
BlockQuoted :                       '\\Q' .*? '\\E';


/*
* Empty strings
* ^ at beginning of text or line (m=true)
* $ at end of text (like \z not \Z) or line (m=true)
* \A    at beginning of text
* \b    at ASCII word boundary (\w on one side and \W, \A, or \z on the other)
* \B    not at ASCII word boundary
* \z    at end of text
*/
anchor_char
    : Caret
    | Dollar
    ;

// Note: the following are not supported within a character class
anchor_escape
    : BeginningOfText
    | WordBoundary
    | NotWordBoundary
    | EndOfText
    ;

BeginningOfText:                        '\\A';
WordBoundary:                           '\\b';
NotWordBoundary:                        '\\B';
EndOfText:                              '\\z';


/*
 *      Unicode character expressions:
 *      Unicode character class (one-letter name)           \pN
 *      Unicode character class                             \p{Greek}
 *      negated Unicode character class (one-letter name)   \PN
 *      negated Unicode character class                     \P{Greek}
 *      ------- one char ----------
 *      C       other
 *      L       letter
 *      M       mark
 *      N       number
 *      P       punctuation
 *      S       symbol
 *      Z       separator
 *      ------- two chars ---------
 *      Cc      control
 *      Cf      format
 *      Co      private use
 *      Cs      surrogate
 *      Ll      lowercase letter
 *      Lm      modifier letter
 *      Lo      other letter
 *      Lt      titlecase letter
 *      Lu      uppercase letter
 *      Mc      spacing mark
 *      Me      enclosing mark
 *      Mn      non-spacing mark
 *      Nd      decimal number
 *      Nl      letter number
 *      No      other number
 *      Pc      connector punctuation
 *      Pd      dash punctuation
 *      Pe      close punctuation
 *      Pf      final punctuation
 *      Pi      initial punctuation
 *      Po      other punctuation
 *      Ps      open punctuation
 *      Sc      currency symbol
 *      Sk      modifier symbol
 *      Sm      math symbol
 *      So      other symbol
 *      Zl      line separator
 *      Zp      paragraph separator
 *      Zs      space separator
 *      -------------------------------
 *      [script names should be self explanatory]
 */
unicode_class
    : UnicodeClass
    | NegatedUnicodeClass
    ;

UnicodeClass:                           UnicodeClassOne | UnicodeClassExtended;
NegatedUnicodeClass:                    NegatedUnicodeClassOne | NegatedUnicodeClassExtended;

fragment UnicodeClassOne:               '\\p' UnicodeClassNameOneChar;
fragment NegatedUnicodeClassOne:        '\\P' UnicodeClassNameOneChar;
fragment UnicodeClassExtended:          '\\p' OpenBrace (UnicodeClassNameOneChar | UnicodeClassNameTwoChar | UnicodeClassNameScript) CloseBrace
                                      | '\\P' OpenBrace '^' (UnicodeClassNameOneChar | UnicodeClassNameTwoChar | UnicodeClassNameScript) CloseBrace;
fragment NegatedUnicodeClassExtended:   '\\P' OpenBrace (UnicodeClassNameOneChar | UnicodeClassNameTwoChar | UnicodeClassNameScript) CloseBrace
                                      | '\\p' OpenBrace '^' (UnicodeClassNameOneChar | UnicodeClassNameTwoChar | UnicodeClassNameScript) CloseBrace;

// Note: the below is not comprehensive, and it's worth noting that RE2 can build against ICU for
// full Unicode properties support, which means that things like \p{Emoji} work as well
// For a simpler match we could do (UnderscoreAlphaNumeric+ | UnicodeClassNameOneChar)
fragment UnicodeClassNameOneChar:       'C'|'L'|'M'|'N'|'P'|'S'|'Z';
fragment UnicodeClassNameTwoChar:       'Cc'|'Cf'|'Co'|'Cs'|'Ll'|'Lm'|'Lo'|'Lt'|'Lu'|'Mc'|'Me'|'Mn'|'Nd'|'Nl'|'No'|
                                        'Pc'|'Pd'|'Pe'|'Pf'|'Pi'|'Po'|'Ps'|'Sc'|'Sk'|'Sm'|'So'|'Zl'|'Zp'|'Zs';
fragment UnicodeClassNameScript:        'Any' | 'Adlam'|'Ahom'|'Anatolian_Hieroglyphs'|'Arabic'|'Armenian'|'Avestan'|'Balinese'|
                                        'Bamum'|'Bassa_Vah'|'Batak'|'Bengali'|'Bhaiksuki'|'Bopomofo'|'Brahmi'|'Braille'|'Buginese'|'Buhid'|
                                        'Canadian_Aboriginal'|'Carian'|'Caucasian_Albanian'|'Chakma'|'Cham'|'Cherokee'|'Chorasmian'|'Common'|
                                        'Coptic'|'Cuneiform'|'Cypriot'|'Cypro_Minoan'|'Cyrillic'|'Deseret'|'Devanagari'|'Dives_Akuru'|'Dogra'|
                                        'Duployan'|'Egyptian_Hieroglyphs'|'Elbasan'|'Elymaic'|'Ethiopic'|'Georgian'|'Glagolitic'|'Gothic'|'Grantha'|
                                        'Greek'|'Gujarati'|'Gunjala_Gondi'|'Gurmukhi'|'Han'|'Hangul'|'Hanifi_Rohingya'|'Hanunoo'|'Hatran'|'Hebrew'|
                                        'Hiragana'|'Imperial_Aramaic'|'Inherited'|'Inscriptional_Pahlavi'|'Inscriptional_Parthian'|'Javanese'|'Kaithi'|
                                        'Kannada'|'Katakana'|'Kawi'|'Kayah_Li'|'Kharoshthi'|'Khitan_Small_Script'|'Khmer'|'Khojki'|'Khudawadi'|'Lao'|
                                        'Latin'|'Lepcha'|'Limbu'|'Linear_A'|'Linear_B'|'Lisu'|'Lycian'|'Lydian'|'Mahajani'|'Makasar'|'Malayalam'|'Mandaic'|
                                        'Manichaean'|'Marchen'|'Masaram_Gondi'|'Medefaidrin'|'Meetei_Mayek'|'Mende_Kikakui'|'Meroitic_Cursive'|
                                        'Meroitic_Hieroglyphs'|'Miao'|'Modi'|'Mongolian'|'Mro'|'Multani'|'Myanmar'|'Nabataean'|'Nag_Mundari'|'Nandinagari'|
                                        'New_Tai_Lue'|'Newa'|'Nko'|'Nushu'|'Nyiakeng_Puachue_Hmong'|'Ogham'|'Ol_Chiki'|'Old_Hungarian'|'Old_Italic'|
                                        'Old_North_Arabian'|'Old_Permic'|'Old_Persian'|'Old_Sogdian'|'Old_South_Arabian'|'Old_Turkic'|'Old_Uyghur'|
                                        'Oriya'|'Osage'|'Osmanya'|'Pahawh_Hmong'|'Palmyrene'|'Pau_Cin_Hau'|'Phags_Pa'|'Phoenician'|'Psalter_Pahlavi'|
                                        'Rejang'|'Runic'|'Samaritan'|'Saurashtra'|'Sharada'|'Shavian'|'Siddham'|'SignWriting'|'Sinhala'|'Sogdian'|
                                        'Sora_Sompeng'|'Soyombo'|'Sundanese'|'Syloti_Nagri'|'Syriac'|'Tagalog'|'Tagbanwa'|'Tai_Le'|'Tai_Tham'|'Tai_Viet'|
                                        'Takri'|'Tamil'|'Tangsa'|'Tangut'|'Telugu'|'Thaana'|'Thai'|'Tibetan'|'Tifinagh'|'Tirhuta'|'Toto'|'Ugaritic'|
                                        'Vai'|'Vithkuqi'|'Wancho'|'Warang_Citi'|'Yezidi'|'Yi'|'Zanabazar_Square';


/*      Grouping
 *      (?:re)          non-capturing group
 *      (re)            numbered capturing group (submatch)
 *      (?P<name>re)    named & numbered capturing group (submatch)
 *      (?flags)        set flags within current group; non-capturing
 *      (?flags:re)     set flags during re; non-capturing
 */
grouping
    : OpenParen QuestionMark Colon regex CloseParen                 # NonCapturingGroup
    | OpenParen regex CloseParen                                    # CapturingGroup
    | OpenParen QuestionMark P_Upper
         LessThan name GreaterThan regex CloseParen                 # NamedCapturingGroup
    | OpenParen QuestionMark flags CloseParen                       # FlagGroup
    | OpenParen QuestionMark flags Colon regex CloseParen           # FlagGroupWithinRegex
    ;

/*      Flags
 *      i   case-insensitive (default false)
 *      m   multi-line mode: ^ and $ match begin/end line in addition to begin/end text (default false)
 *      s   let . match \n (default false)
 *      U   ungreedy: swap meaning of x* and x*?, x+ and x+?, etc (default false)
 *
 *      Flag syntax is xyz (set) or -xyz (clear) or xy-z (set xy, clear z).
 */
flags
    : option_flags? Dash option_flags
    | option_flags
    ;

option_flags
    : option_flag+
    ;

option_flag
    : I_Lower
    | M_Lower
    | S_Lower
    | U_Upper
    ;

// NAMES for use in capturing group of the form (?P<name>regex)
// Valid names include: (?P<x>abc), (?P<1>abc), (?P<é>abc), ...
// Can basically be any non-punctuation / non-escape literal
name
    : name_char+
    ;

name_char
    : letter
    | Digit
    | OtherChar
    ;


/*      Named character classes as character class elements
 *      [\d]        digits (≡ \d)
 *      [^\d]       not digits (≡ \D)
 *      [\D]        not digits (≡ \D)
 *      [^\D]       not not digits (≡ \d)
 *      [[:name:]]  named ASCII class inside character class (≡ [:name:])
 *      [^[:name:]] named ASCII class inside negated character class (≡ [:^name:])
 *      [\p{Name}]  named Unicode property inside character class (≡ \p{Name})
 *      [^\p{Name}] named Unicode property inside negated character class (≡ \P{Name})
 */
character_class
    : OpenBracket Caret character_class_element+ CloseBracket       # NegatedCharacterClass
    | OpenBracket character_class_element+ CloseBracket             # CharacterClass
    ;


/* Character class elements
 *      x           single character
 *      A-Z         character range (inclusive)
 *      \d          Perl character class
 *      [:foo:]     ASCII character class foo
 *      \p{Foo}     Unicode character class Foo
 *      \pF         Unicode character class F (one-letter name)
 */
character_class_element
    : character_range                                           # ClassRange
    | meta_inside_character_class                               # ClassMeta
    | literal_inside_character_class                            # ClassLiteral
    ;

character_range
    : character_range_atom Dash character_range_atom
    ;

// It is difficult to determine whether a range is valid or not
// For example:   [a-b[:ascii:]c-d]   valid, [:ascii:] not used in range
//                [a-b[:ascii:]-d]    invalid, cannot be used in range
//
// We want to 'catch' the invalid range and deal with it in the Listener
// or other method, as otherwise it will fall-through to its next alternation
// where it would come out as a valid non-character range.
character_range_atom
    : literal_inside_character_class                            # RangeLiteral
    | (HexChar|OctalChar)                                       # RangeEscape
    | (perl_character_class|ascii_class|unicode_class)          # RangeInvalid
    ;

literal_inside_character_class
    : letter
    | Digit
    | OpenBrace
    | CloseBrace
    | LessThan
    | GreaterThan
    | Colon
    | Comma
    | QuestionMark
    | Star
    | Plus
    | Pipe
    | Dollar
    | Dot
    | OpenBracket
    | CloseBracket // such as ^[]]$
    | Caret     // special when at the beginning of character class, handled in parent rule
    | SingleSpace
    | OtherChar
    | OtherPunctuation
    | Dash
    ;

meta_inside_character_class
    : unicode_class
    | ascii_class
    | perl_character_class
    | other_escape_sequence
    ;

/* ASCII character classes
 *      [[:alnum:]]     alphanumeric (≡ [0-9A-Za-z])
 *      [[:alpha:]]     alphabetic (≡ [A-Za-z])
 *      [[:ascii:]]     ASCII (≡ [\x00-\x7F])
 *      [[:blank:]]     blank (≡ [\t ])
 *      [[:cntrl:]]     control (≡ [\x00-\x1F\x7F])
 *      [[:digit:]]     digits (≡ [0-9])
 *      [[:graph:]]     graphical (≡ [!-~] ≡ [A-Za-z0-9!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~])
 *      [[:lower:]]     lower case (≡ [a-z])
 *      [[:print:]]     printable (≡ [ -~] ≡ [ [:graph:]])
 *      [[:punct:]]     punctuation (≡ [!-/:-@[-`{-~])
 *      [[:space:]]     whitespace (≡ [\t\n\v\f\r ])
 *      [[:upper:]]     upper case (≡ [A-Z])
 *      [[:word:]]      word characters (≡ [0-9A-Za-z_])
 *      [[:xdigit:]]    hex digit (≡ [0-9A-Fa-f])
 */
 ascii_class
     : AsciiClass
     | NegatedAsciiClass
     ;
AsciiClass:                             OpenBracket Colon AsciiClassName Colon CloseBracket;
NegatedAsciiClass:                      OpenBracket Colon AsciiClassName Colon CloseBracket;
fragment AsciiClassName:                'alnum'|'alpha'|'ascii'|'blank'|'cntrl'|'digit'|'graph'|
                                        'lower'|'print'|'punct'|'space'|'upper'|'word'|'xdigit';


// Various punctuation and single characters
OpenParen:                              '(';
CloseParen:                             ')';
OpenBracket:                            '[';
CloseBracket:                           ']';
OpenBrace:                              '{';
CloseBrace:                             '}';
LessThan:                               '<';
GreaterThan:                            '>';

QuestionMark:                           '?';
Star:                                   '*';
Plus:                                   '+';
Pipe:                                   '|';

Dot:                                    '.';

Dollar :                                '$';
Caret :                                 '^';

Colon:                                  ':';
Comma:                                  ',';
Dash:                                   '-';

OtherPunctuation:                       [\p{P}];


// Need to capture specific letters for the use of grouping/flags
letter
    : I_Lower
    | M_Lower
    | P_Upper
    | S_Lower
    | U_Upper
    | Other_Letter
    ;

I_Lower:                                'i';
M_Lower:                                'm';
P_Upper:                                'P';
S_Lower:                                's';
U_Upper:                                'U';
Other_Letter:                           [a-zA-Z];

number
    : Digit+
    ;

Digit:                                  [0-9];

Escape:                                 '\\';
SingleSpace:                            ' ';
OtherChar:                              .;

InvalidEscape:                          InvalidHexChar | InvalidUnicodeEscape | OtherInvalidEscape;

fragment InvalidHexChar:                '\\x' (OpenBrace .*? CloseBrace|.);
fragment InvalidUnicodeEscape:          '\\' [pP] (OpenBrace .*? CloseBrace|.);
fragment OtherInvalidEscape:            '\\' .;

fragment UnderscoreAlphaNumeric:       ('_' | AlphaNumeric);
fragment AlphaNumeric:                  [a-zA-Z0-9];
fragment NonAlphaNumeric:               ~[a-zA-Z0-9];
fragment HexDigit:                      [0-9a-fA-F];
fragment OctalDigit:                    [0-7];


// For test parsing on an input file containing multiple patterns
test_root
    : regex ('\n' regex)* EOF
    ;
