package chocopy.pa1;
import java_cup.runtime.*;
import java.util.ArrayList; // A bibllioteca ArrayList será utilizada para realizar a pilha de indentação.
import java.util.Iterator; // A biblioteca Iterator será usada para percorrer a pilha (usado em 'find').

%%


%unicode
%line
%column

%class ChocoPyLexer
%public

%cupsym ChocoPyTokens
%cup
%cupdebug

%eofclose false


%{
    private int currIndent = 0; // Variável utilizada para guardar o número de espaços de indentação contados no início da linha atual.
    private String currString = ""; // Variável utilizada para acumular o conteúdo de uma string literal (usado no estado STRING).
    private int str_l = 0, str_c = 0; // Variável utilizada para guardar a linha (l) e coluna (c) de início de uma string literal (para casos de mensagens de erro).
    
    /* Para manter o registro dos níveis de indentação (número de espaços de cada bloco ativo), foi implementado uma pilha usando ArrayList
    com o topo sendo o nível atual. */
    private ArrayList<Integer> stack = new ArrayList<Integer>(20); // Inicializa com capacidade 20.

    // Flag para controlar erros de indentação
    private boolean indentErrorUnchecked = true;

    /** Retorna um símbolo terminal da categoria sintática TYPE sem
     * valor semântico, usando a localização atual do código fonte. */
    private Symbol symbol(int type) {
        // Chama a outra versão de 'symbol' passando o texto reconhecido ('yytext()') como valor.
        return symbol(type, yytext());
    }

    // --- Métodos Auxiliares para a Pilha de Indentação ---

    /** Retorna o valor no topo da pilha de indentação (nível de indentação esperado)
     * sem removê-lo. Retorna 0 se a pilha estiver vazia (nível base). */
    private int top(){
        if(stack.isEmpty()) return 0;
        return stack.get(stack.size() - 1);
    }

    /** Remove e retorna o valor do topo da pilha de indentação.
     * Usado ao finalizar um bloco (DEDENT). Retorna 0 se a pilha estiver vazia. */
    private int pop(){
        if(stack.isEmpty()) return 0;
        return stack.remove(stack.size() - 1);
    }

    /** Adiciona um novo nível de indentação (`indent`) ao topo da pilha.
     * Usado ao iniciar um novo bloco (INDENT). */
    private void push(int indent){
        stack.add(indent);
    }

    /** O método find faz a verificação de um nível de indentação específico ('indent') existe na pilha.
     * Ele irá retornar true se encontrar, false caso não encontre.
     * É necessário para validar se um DEDENT retorna a um nível anterior válido. */
    private boolean find(int indent){
      // Caso especial: indentação 0 sempre é válida (nível base).
      if(indent == 0) return true;
      Iterator<Integer> it = stack.iterator();
      while(it.hasNext()){
         if(it.next() == indent)
            return true; // Encontrou o nível na pilha.
      }
      return false; // Não encontrou o nível na pilha.
    }

    /** Produtor de tokens (símbolos) com informações detalhadas de localização
     * para uso pelo parser CUP. */
    final ComplexSymbolFactory symbolFactory = new ComplexSymbolFactory();
    

    /** Retorna um símbolo terminal da categoria sintática TYPE com um
     * valor semântico VALUE, incluindo informações precisas de localização
     * (linha/coluna inicial e final) usando a symbolFactory. */
    private Symbol symbol(int type, Object value) {
        return symbolFactory.newSymbol(
            ChocoPyTokens.terminalNames[type], // Nome textual do token (para debug).
            type, // ID numérico do token (definido em ChocoPyTokens).
            // Localização inicial (linha + 1 e coluna + 1 porque JFlex é 0-based).
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn + 1),
            // Localização final.
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn + yylength()), value); 
            // O valor semântico associado ao token (ex: o número em si, o nome do identificador).
    }
%}

%%

// --- Regras Léxicas ---

<YYINITIAL>{
  {LineBreak} { currIndent = 0; }
  {Comments}  {} 


  // Reconhece o PRIMEIRO caractere que NÃO é espaço, tabulação, quebra de linha ou início de comentário.
  // Este é o ponto onde a indentação da linha é finalizada e comparada com a pilha.
  [^ \t\r\n#] {
      // Devolve o caractere lido de volta para o buffer de entrada.
      // Isso é crucial porque este caractere pertence ao código real da linha
      // e precisa ser processado pelas regras do estado AFTER.
      // Esta regra serve APENAS para detectar o fim da indentação.
      yypushback(1);

      // --- Lógica de DEDENT ---
      // Se a indentação atual (`currIndent`) for MENOR que a indentação no topo da pilha (`top()`),
      // significa que um ou mais blocos estão sendo fechados.
      if(top() > currIndent)
      {   
          /*
          Se a indentação da linha é menor que o número de espaços esperado
          para o nível atual, continua emitindo DEDENTs até que a indentação
          da linha seja igual ou maior que o topo da pilha.
          */

          pop(); // Remove o nível de indentação anterior do topo da pilha.

          // Se, APÓS remover um nível, a indentação atual AINDA for maior que o
          // NOVO topo da pilha, isso indica um erro: a indentação não corresponde
          // a nenhum nível anterior válido. (Ex: voltar de 8 espaços para 2, quando havia 0 e 4).
          // Correção: A condição deveria ser `if(top() < currIndent || !find(currIndent))`
          // ou similar para verificar se `currIndent` existe na pilha.
          // A lógica atual (`top() < currIndent`) parece detectar um erro se
          // ao desempilhar, o novo topo é *menor* que a indentação atual,
          // o que é a condição de erro padrão para o ChocoPy.
          if(top() < currIndent)
          {
            currIndent = top(); // Define currIndent para o topo atual

            // Retorna um token especial UNRECOGNIZED indicando um erro de indentação.
            // Passa a indentação atual como valor para possível uso na mensagem de erro.
            return symbolFactory.newSymbol("<bad indentation>", ChocoPyTokens.UNRECOGNIZED,
              new ComplexSymbolFactory.Location(yyline + 1, yycolumn - 1),
              new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
              currIndent);
          }

          // Se não houve erro, retorna um token DEDENT.
          // A localização é definida para a coluna -1 ou 0 (início lógico da linha).
          // O valor associado é a indentação atual (`currIndent`), indicando o nível para o qual se está retornando.
          return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[ChocoPyTokens.DEDENT], ChocoPyTokens.DEDENT,
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn - 1),
            new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
            currIndent);
      }

      /* Caso contrário (`top() <= currIndent`), muda para o estado AFTER
      para começar a processar os tokens reais da linha. */
      yybegin(AFTER);

      // --- Lógica de INDENT ---
      // Se a indentação atual (`currIndent`) for MAIOR que a do topo da pilha (`top()`),
      // significa que um novo bloco está começando.
      if(top()< currIndent)
      {   
          /*
          Se a indentação atual é maior que o número de espaços do nível atual,
          inicia um novo nível de bloco com `currIndent` espaços.
          */
          push(currIndent); // Adiciona o novo nível de indentação à pilha.

          // Retorna um token INDENT.
          // A localização é definida para a coluna -1 ou 0 (início lógico da linha).
          // O valor associado é a indentação atual (`currIndent`), indicando o nível do novo bloco.
          return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[ChocoPyTokens.INDENT], ChocoPyTokens.INDENT,
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn - 1),
            new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
            currIndent);
      }
  }

   // Reconhece espaços em branco (espaços ou tabs) no início da linha (estado YYINITIAL).
  {WhiteSpace} { 
      // Se o caractere de espaço em branco for uma tabulação:
      if(yytext() == "\t")
        currIndent += 8; // Assumindo que uma tabulação equivale a 8 espaços.
      else 
        currIndent ++; // Caso seja apenas um espaço simples, incrementa o contador de indentação em 1.
  }
}

/* Macros (regexes used in rules below) */

WhiteSpace = [ \t]
LineBreak  = \r|\n|\r\n

IntegerLiteral = 0 | [1-9][0-9]*

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
