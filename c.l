%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

enum FG
{
	fgRED      = 31,   fgGREEN    = 32,
	fgORANGE   = 33,   fgCYAN     = 36,   
	fgDARKGREY = 90,   fgYELLOW   = 93
};

void set_color(enum FG);
void reset_color(void);
void color_print(enum FG, const char *);

void consume_comment(void);
%}

/* http://www.quut.com/c/ANSI-C-grammar-l.html */

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%%

"/*"      {
	set_color(fgDARKGREY);
	fputs(yytext, stdout);
	consume_comment();
	reset_color();
}
"//".*    {
	color_print(fgDARKGREY, yytext);
}

^[ \t]*#.*      {
	color_print(fgRED, yytext);
}

"auto"     |
"bool"     |
"char"     |
"const"    |
"double"   |
"enum"     |
"extern"   |
"float"    |
"inline"   |
"int"      |
"long"     |
"register" |
"restrict" |
"short"    |
"size_t"   |
"signed"   |
"static"   |
"struct"   |
"typedef"  |
"union"    |
"unsigned" |
"void"     |
"volatile" |
"_Bool"    |
"_Complex" {
	color_print(fgGREEN, yytext);
}

"break"    |
"case"     |
"continue" |
"default"  |
"do"       |
"else"     |
"for"      |
"goto"     |
"if"       |
"return"   |
"sizeof"   |
"switch"   |
"while"    {
	color_print(fgYELLOW, yytext);
}

{L}{A}*    {
	/* note how this prevents in-word keyword matches */
	fputs(yytext, stdout);
}

{HP}{H}+{IS}?               |
{NZ}{D}*{IS}?               |
"0"{O}*{IS}?                |
{CP}?"'"([^'\\\n]|{ES})+"'" |
{D}+{E}{FS}?                |
{D}*"."{D}+{E}?{FS}?        |
{D}+"."{E}?{FS}?            |
{HP}{H}+{P}{FS}?            |
{HP}{H}*"."{H}+{P}{FS}?     |
{HP}{H}+"."{P}{FS}?         {
	color_print(fgCYAN, yytext);
}

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+ {
	color_print(fgORANGE, yytext);
}

. ECHO;

%%

void set_color(enum FG c)
{
	printf("\033[%d;1m", c);
}

void reset_color(void)
{
	fputs("\033[0m", stdout);
}

void color_print(enum FG c, const char *s)
{
	set_color(c);
	fputs(s, stdout);
	reset_color();
}

void consume_comment(void)
{
	int c;

	/* 0 is EOF in lex */
	while ((c = input()) != 0)
	{
		putchar(c);
		if (c == '*')
		{
			while ((c = input()) == '*')
				putchar(c);
			if (c == 0) break;
			putchar(c);
			if (c == '/') return;
		}
	}
}

int main(void)
{
	if (!isatty(fileno(stdout)))
	{
		fputs("Stdout is not a terminal\n", stderr);
		return EXIT_FAILURE;
	}
	atexit(reset_color);

	yylex();
	return EXIT_SUCCESS;
}
