.POSIX:

CFLAGS = -std=c99 -g -pedantic -Wall -Wextra -D_POSIX_C_SOURCE=200112L
YFLAGS += -Dparse.trace -Wno-yacc -Wempty-rule

# yes, sorry, need extensions beyond POSIX lex/yacc
LEX = flex
YACC = bison

COMBOS = adif csv lisp morse irc
LEXO     = $(COMBOS:=.lex.o) words.o
YACCO    = $(COMBOS:=.tab.o)

.SUFFIXES :
.SUFFIXES : .a .o .c .l .y

drivers : driver_words driver_lisp driver_csv driver_adif \
	driver_morse driver_irc

# for the drivers:
.o:
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< parsers.a

race_test_csv : race_test_csv.c parsers.a csv.h
	clang $(CFLAGS) -fsanitize=thread $(LDFLAGS) -o $@ \
		race_test_csv.c parsers.a -lpthread

include config.mk

parsers.a : $(LEXO) $(YACCO) parsers.o
	ar r $@ $?

clean :
	rm -f *.[ao] *.lex.c *.tab.[ch]
