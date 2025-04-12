package chocopy.pa1;
import java_cup.runtime.*;

%%

/*** Do not change the flags below unless you know what you are doing. ***/

%unicode
%line
%column
%state AFTER, STRING /*Linha adicionada, conforme manual Jflex para ESTADOS INCLUSIVOS */

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

    /* Vai inicializar uma cadeia de caracteres privada chamada currentString (String Atual).
    Vamos usar para armazenar o conteúdo de literais da cadeia de caracteres que estão sendo processados pelo léxico. */
    private String currentString = "";
    /*Esses dois inteiros (str_line e str_column) representam a linha (line) e a coluna (column) em que um literal da cadeia
    de caracteres começa na entrada. Vai rastrear locais no código-fonte onde há erros ou depuração.
    private int str_line = 0, str_column = 0; //Ponto inicial de uma string.

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

    /* ----Já definido--- */
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
  
  yybegin(AFTER);
}

<STRING> {
    /*Esse trecho indica que quando um caracter do StringLiteral é reconhecido,
    o texto correspondente por yytext é adicionado à variável currentString.
    A variável currentString é usada para armazenar o conteúdo completo da string que está sendo processada */
    {StringLiteral}              { currentString += yytext(); }


    "\""                         { yybegin(AFTER); /*altera o estado do lexer para AFTER, passando para a próxima tarefa.*/
                                   return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[ChocoPyTokens.STRING] /* cria e retorna
                                        um símbolo representando o token STRING. O símbolo contém informações sobre sua localização no código-fonte (line e column)
                                        O array contém as representações de cadeia de caracteres ou nomes de todos os tipos de token usados no ChocoPy*/,
                                   ChocoPyTokens.STRING /* Essa linha se refere ao tipo de token específico para um literal da cadeia de caracteres na linguagem ChocoPy.
                                        Pode ser um valor inteiro ou enumeração que representa o token no analisador léxico */,
                                   new ComplexSymbolFactory.Location(str_line, str_column) /*Essa linha representa a criação de um objeto de localização usando a classe ComplexSymbolFactory */,
                                   new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()) /*Este trecho de código está criando um objeto de localização para representar a posição de um token no código-fonte. */,
                                   currentString) /* Enquanto o lexer processa, ele acumula o conteúdo */; }


    /* Tratar o caractere \ como uma continuação de linha. */
    \\$                          { /*'\' quando colocado no fim da linha, nada a fazer */ }

}

/* o ESTADO AFTER É USADO PARA CLASSIFICAR OS TOKENS ENCONTRADOS. 
A FUNÇÃO SYMBOL() CONSTRÓI OBJETOS REPRESENTANDO OS ELEMENTOS LÉXICOS DO CÓDIGO.*/
<AFTER>{

 /* Boolean keywords */
  "None"                         { return symbol(ChocoPyTokens.NONE); }
  "True"                         { return symbol(ChocoPyTokens.BOOL, true); }
  "False"                        { return symbol(ChocoPyTokens.BOOL, false); }

  /*Keywords*/
  "if"                           { return symbol(ChocoPyTokens.IF); }
  "else"                         { return symbol(ChocoPyTokens.ELSE); }
  "elif"                         { return symbol(ChocoPyTokens.ELIF); }
  "for"                          { return symbol(ChocoPyTokens.FOR); }
  "while"                        { return symbol(ChocoPyTokens.WHILE); }
  "class"                        { return symbol(ChocoPyTokens.CLASS); }
  "def"                          { return symbol(ChocoPyTokens.DEF); }
  "in"                           { return symbol(ChocoPyTokens.IN); }
  "global"                       { return symbol(ChocoPyTokens.GLOBAL); }
  "nonlocal"                     { return symbol(ChocoPyTokens.NONLOCAL); }
  "pass"                         { return symbol(ChocoPyTokens.PASS); }
  "return"                       { return symbol(ChocoPyTokens.RETURN); }
  "assert"                       { return symbol(ChocoPyTokens.ASSERT); }
  "await"                        { return symbol(ChocoPyTokens.AWAIT); }
  "break"                        { return symbol(ChocoPyTokens.BREAK); }
  "continue"                     { return symbol(ChocoPyTokens.CONTINUE); }
  "del"                          { return symbol(ChocoPyTokens.DEL); }
  "lambda"                       { return symbol(ChocoPyTokens.LAMBDA); }
  "as"                           { return symbol(ChocoPyTokens.AS); }
  "except"                       { return symbol(ChocoPyTokens.EXCEPT); }
  "finally"                      { return symbol(ChocoPyTokens.FINALLY); }
  "from"                         { return symbol(ChocoPyTokens.FROM); }
  "import"                       { return symbol(ChocoPyTokens.IMPORT); }
  "raise"                        { return symbol(ChocoPyTokens.RAISE); }
  "try"                          { return symbol(ChocoPyTokens.TRY); }
  "with"                         { return symbol(ChocoPyTokens.WITH); }
  "yield"                        { return symbol(ChocoPyTokens.YIELD); }


  /* Operators. */
  "+"                            { return symbol(ChocoPyTokens.PLUS); }
  "-"                            { return symbol(ChocoPyTokens.MINUS); }
  "*"                            { return symbol(ChocoPyTokens.MUL); }
  "//"                           { return symbol(ChocoPyTokens.DIV); }
  "/"                            { return symbol(ChocoPyTokens.DIV); }
  "%"                            { return symbol(ChocoPyTokens.MOD); }
  ">"                            { return symbol(ChocoPyTokens.GT); }
  ">="                           { return symbol(ChocoPyTokens.GEQ); }
  "->"                           { return symbol(ChocoPyTokens.ARROW); }
  "<"                            { return symbol(ChocoPyTokens.LT); }
  "<="                           { return symbol(ChocoPyTokens.LEQ); }
  "="                            { return symbol(ChocoPyTokens.ASSIGN); }
  "=="                           { return symbol(ChocoPyTokens.EQUAL); }
  "!="                           { return symbol(ChocoPyTokens.NEQ); }
  "and"                          { return symbol(ChocoPyTokens.AND); }
  "or"                           { return symbol(ChocoPyTokens.OR); }
  "not"                          { return symbol(ChocoPyTokens.NOT); }
  "is"                           { return symbol(ChocoPyTokens.IS); }
  "("                            { return symbol(ChocoPyTokens.LPAR); }
  ")"                            { return symbol(ChocoPyTokens.RPAR); }
  "["                            { return symbol(ChocoPyTokens.LBR); }
  "]"                            { return symbol(ChocoPyTokens.RBR); }
  "."                            { return symbol(ChocoPyTokens.DOT); }

 /* Whitespace. */
   {WhiteSpace}                   { /* ignore */ }

 /* Comment. */
   {Comments}                     { /* ignore */ }
}

<<EOF>>                       { return symbol(ChocoPyTokens.EOF); }

/* Error fallback. */
[^]                           { return symbol(ChocoPyTokens.UNRECOGNIZED); }
