# YACC = byacc

# link -ly -ll, not -ll -ly so that main()
# is provided by yacc and not lex
roman : roman.tab.c roman.lex.c
	$(CC) -std=c99 -pedantic -Wall -Wextra -o roman \
		roman.tab.c roman.lex.c -ly -ll

roman.tab.c roman.tab.h : roman.y
	$(YACC) -t -d -b roman roman.y

roman.lex.c : roman.l roman.tab.h
	$(LEX) -t roman.l > roman.lex.c

clean :
	rm roman.{lex,tab}.[ch]
