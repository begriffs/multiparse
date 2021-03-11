## Multiparse

This is an experiment to see how to include multiple reentrant (pure) parsers
and lexers into the same static library. That way a program could parse both,
say, a network protocol and a configuration file.

Lex and Yacc are traditionally designed to output standalone programs, so this
project uses Flex and Byacc extensions.
