.POSIX:

CFLAGS = -std=c99 -g -pedantic -Wall -Wextra -D_POSIX_C_SOURCE=200112L

COMBOS = lisp
LEXO     = $(COMBOS:=.lex.o) words.o
YACCO    = $(COMBOS:=.tab.o)

.SUFFIXES :
.SUFFIXES : .a .o .c .l .y

driver : driver.o parsers.a
driver.o : driver.c parsers.h

include config.mk

parsers.a : $(LEXO) $(YACCO) parsers.o
	ar r $@ $?

$(LEXO) $(YACCO) : parsers.h

clean :
	rm -f *.[ao]
