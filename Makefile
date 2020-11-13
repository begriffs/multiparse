.POSIX:

CFLAGS = -std=c99 -g -pedantic -Wall -Wextra -D_POSIX_C_SOURCE=200112L
YFLAGS += -Wno-yacc

# yes, sorry, need extensions beyond POSIX lex/yacc
LEX = flex
YACC = bison

COMBOS = lisp
LEXO     = $(COMBOS:=.lex.o) words.o
YACCO    = $(COMBOS:=.tab.o)

.SUFFIXES :
.SUFFIXES : .a .o .c .l .y

drivers : driver_words driver_lisp

# for the drivers:
.o:
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< parsers.a

include config.mk

parsers.a : $(LEXO) $(YACCO) parsers.o
	ar r $@ $?

$(LEXO) $(YACCO) : parsers.h vendor/queue.h

clean :
	rm -f *.[ao] *.lex.c *.tab.[ch]
