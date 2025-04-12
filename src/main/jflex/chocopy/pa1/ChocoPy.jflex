package chocopy.pa1;
import java_cup.runtime.*;

%%

/*** Do not change the flags below unless you know what you are doing. ***/

%unicode
%line
%column

%class ChocoPyLexer
%public

%cupsym ChocoPyTokens
%cup
%cupdebug

%eofclose false

/*** Do not change the flags above unless you know what you are doing. ***/

/* The following code section is copied verbatim to the
 * generated lexer class. */
%{
    /* The code below includes some convenience methods to create tokens
     * of a given type and optionally a value that the CUP parser can
     * understand. Specifically, a lot of the logic below deals with
     * embedded information about where in the source code a given token
     * was recognized, so that the parser can report errors accurately.
     * (It need not be modified for this project.) */

    /** Producer of token-related values for the parser. */
    final ComplexSymbolFactory symbolFactory = new ComplexSymbolFactory();

    /** Return a terminal symbol of syntactic category TYPE and no
     *  semantic value at the current source location. */
    private Symbol symbol(int type) {
        return symbol(type, yytext());
    }

    /** Return a terminal symbol of syntactic category TYPE and semantic
     *  value VALUE at the current source location. */
    private Symbol symbol(int type, Object value) {
        return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[type], type,
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn + 1),
            new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
            value);
    }

%}

/* Macros (regexes used in rules below) */

    /* ----Velho--- */
    /* 1. WhiteSpace */
    /* Padrão: [ t] Representa os espaços e tabulações */
WhiteSpace = [ \t]
    /* 2. LineBreak */
    /* Padrão: r|n|rn Representa vários formatos de quebra de linha, incluindo Unix (n), Windows (rn) e Mac clássico (r). */
LineBreak  = \r|\n|\r\n
    /* 3. IntegerLiteral */
    /* Padrão: 0|[1-9][0-9]* Representa inicialiar com 0 ou inteiros começando com um dígito diferente de zero seguido por dígitos. Vários zeros à esquerda não são permitidos. */
IntegerLiteral = 0 | [1-9][0-9]*

/* ----Novo--- */
    /* 4.Identifiers */
    /* Um identificador começa com um sublinhado (_) ou qualquer letra (a-z, A-Z), seguido por zero ou mais sublinhados, letras ou dígitos (0-9). */
Identifiers = (_|[a-z]|[A-Z])(_|[a-z]|[A-Z]|[0-9])*
    /* 5. StringLiteral */
    /* Padrão: ([^"]|( ")|(t)|(r)|(n)|())+ Strings entre aspas, permite caracteres de escape, como ", , n, r ou t. */
StringLiteral = ([^\"\\]|(\\\")|(\\t)|(\\r)|(\\n)|(\\\\))+
    /* 6. Comments */
    /* Padrão: #[^]* São os comentários que começam com #, e vai até o final da linha. */
Comments = #[^\r\n]*
/*---FIM---*/

%%


<YYINITIAL> {

  /* Delimiters. */
  {LineBreak}                 { return symbol(ChocoPyTokens.NEWLINE); }

  /* Literals. */
  {IntegerLiteral}            { return symbol(ChocoPyTokens.NUMBER,
                                                 Integer.parseInt(yytext())); }

  /* Operators. */
  "+"                         { return symbol(ChocoPyTokens.PLUS, yytext()); }

  /* Whitespace. */
  {WhiteSpace}                { /* ignore */ }
}

<<EOF>>                       { return symbol(ChocoPyTokens.EOF); }

/* Error fallback. */
[^]                           { return symbol(ChocoPyTokens.UNRECOGNIZED); }
