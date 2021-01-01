%option noyywrap noinput nounput
%option noyyalloc noyyrealloc noyyfree
%option prefix="morse"
%option reentrant bison-bridge

%{
#include "morse.tab.h"

#define YY_EXIT_FAILURE ((void)yyscanner, EXIT_FAILURE)

#define YYSTYPE MORSESTYPE
%}

LF_RE   (\r\n)|(\r)|(\n)|(\x0c) 

%%

".-"    { *yylval = 'a'; return LETTER; }
"-..."  { *yylval = 'b'; return LETTER; }
"-.-."  { *yylval = 'c'; return LETTER; }
"-.."   { *yylval = 'd'; return LETTER; }
"."     { *yylval = 'e'; return LETTER; }
"..-."  { *yylval = 'f'; return LETTER; }
"--."   { *yylval = 'g'; return LETTER; }
"...."  { *yylval = 'h'; return LETTER; }
".."    { *yylval = 'i'; return LETTER; }
".---"  { *yylval = 'j'; return LETTER; }
"-.-"   { *yylval = 'k'; return LETTER; }
".-.."  { *yylval = 'l'; return LETTER; }
"--"    { *yylval = 'm'; return LETTER; }
"-."    { *yylval = 'n'; return LETTER; }
"---"   { *yylval = 'o'; return LETTER; }
".--."  { *yylval = 'p'; return LETTER; }
"--.-"  { *yylval = 'p'; return LETTER; }
".-."   { *yylval = 'r'; return LETTER; }
"-"     { *yylval = 't'; return LETTER; }
"..-"   { *yylval = 'u'; return LETTER; }
"...-"  { *yylval = 'v'; return LETTER; }
".--"   { *yylval = 'w'; return LETTER; }
"-..-"  { *yylval = 'x'; return LETTER; }
"-.--"  { *yylval = 'y'; return LETTER; }
"--.."  { *yylval = 'z'; return LETTER; }

[ \t]+|{LF_RE} { return SPACE; }
{LF_RE}        { return EOS; }

%%
