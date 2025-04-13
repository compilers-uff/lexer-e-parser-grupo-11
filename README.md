[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/4nHL7_6-)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=18893975&assignment_repo_type=AssignmentRepo)
# Trabalho #1: Lexer e Parser - Compiladores UFF 2025.1 - Grupo 11

[PA1 Specification]: https://drive.google.com/open?id=1oYcJ5iv7Wt8oZNS1bEfswAklbMxDtwqB
[ChocoPy Specification]: https://drive.google.com/file/d/1mrgrUFHMdcqhBYzXHG24VcIiSrymR6wt

Atenção: Para executar os códigos no Windows, é necessário substituir os 2 pontos (`:`) por um ponto e vírgula (`;`) em todos os comandos listados abaixo.


## Como executar os códigos

Execute o comando abaixo para gerar e compilar seu parser, e depois rode o comando seguinte para realizar todos os testes do programa:

    mvn clean package

    java -cp "chocopy-ref.jar:target/assignment.jar" chocopy.ChocoPy --pass=s --test --dir src/test/data/pa1/sample/

Caso queira observar a saída do parser quando rodar um programa específico, rode o comando abaixo:

    java -cp "chocopy-ref.jar:target/assignment.jar" chocopy.ChocoPy --pass=s src/test/data/pa1/sample/expr_plus.py


## Grupo de Trabalho

Membro 1: Guilherme França Moreira

Membro 2: Luiz Gustavo Pereira

Membro 3: Rodrigo Barroso Rodrigues, 12 horas alocadas para o desenvolvimento do projeto


## Respostas sobre a implementação
1. ***Que estratégia você usou para emitir tokens INDENT e DEDENT corretamente? Mencione o nome do arquivo e o(s) número(s) da(s) linha(s) para a parte principal da sua solução.***

    R: ```A estratégia utilizada para emitir corretamente os tokens INDENT e DEDENT foi utilizar uma pilha através de
um ArrayList no arquivo ChocoPy.jflex, para controlar os níveis de indentação, simulando o comportamento esperado da linguagem ChocoPy. No início de cada linha, quando no estado YYINITIAL, os espaços e tabulações são incrementados na variável currIndent (presente nas linhas 200 a 206). Quando um caractere que não é um espaço em branco, quebra de linha ou comentário é encontrado, currIndent é comparado com o topo da pilha no método top(), declarado na linha 47 e utilizado na linha 149. Se currIndent for maior, um novo bloco se inicia e o novo nível é empilhado com push(currIndent), declarado na linha 61 e utilizado na linha 187, e um token INDENT é retornado.
   Se currIndent for menor que o topo da pilha, os blocos anteriores estão sendo finalizados. Nesse caso, a pilha é desempilhada com o método pop(), declarado na linha 54 e utilizado na linha 137 até que o nível atual seja atingido. No caso de currIndent não corresponder a nenhum nível existente encontrado pelo método find(), declarado na linha 68, um erro de indentação é lançado, com token UNRECOGNIZED, na linha 153, e caso o nível seja válido, é retornado um token DEDENT. ```

<br>

2. ***Como sua solução ao item 1 se relaciona ao descrito na seção 3.1 do manual de referência de ChocoPy? (Arquivo chocopy_language_reference.pdf.)***
    
    R: ```A solução do item 1 está relacionado diretamente com a especificação da estrutura de linhas na seção 3.1.5 sobre indentação. Tanto nossa solução quanto a seção do manual de referência enfatizam o uso de uma pilha para rastrear os níveis de indentação. No início de cada linha lógica, a indentação atual é comparada com o topo desta pilha. Se a indentação aumenta, um token INDENT é gerado e o novo nível é adicionado à pilha. Se a indentação diminui, tokens DEDENT são emitidos para cada nível maior na pilha até que o nível atual seja alcançado. A inicialização da pilha com um zero e a lógica de níveis estritamente crescentes também estão implicitamente presentes na lógica descrita.
      Além da mecânica de INDENT e DEDENT, ele também se relaciona na questão da contagem da indentação inicial de cada linha lógica (relacionando-se com o início das linhas lógicas mencionadas na seção 3.1.2) e o tratamento do final do arquivo com a emissão dos DEDENTs pendentes (conforme especificado no final da seção 3.1.5).```