.POSIX:

CFLAGS = -std=c99 -g -pedantic -Wall -Wextra -D_POSIX_C_SOURCE=200112L
YFLAGS += -Wno-yacc

COMBOS = lisp
LEXO     = $(COMBOS:=.lex.o) words.o
YACCO    = $(COMBOS:=.tab.o)

.SUFFIXES :
.SUFFIXES : .a .o .c .l .y

drivers : driver_words driver_lisp

include config.mk

parsers.a : $(LEXO) $(YACCO) parsers.o
	ar r $@ $?

$(LEXO) $(YACCO) : parsers.h

clean :
	rm -f *.[ao]
