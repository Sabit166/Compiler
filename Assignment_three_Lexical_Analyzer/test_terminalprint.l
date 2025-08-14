%option noyywrap

%{
    #include <stdio.h>
%}

AssignmentOp "<<="|">>="|"&="|"^="|"|="|"+="|"-="|"*="|"/="
BitwiseOp    ">>"|"<<"|"&"|"^"|"|"
Curly_Brace  "{"|"}"
Function     "printf"|"scanf"|"main"
digit        [0-9]
Variable     [a-zA-Z_][a-zA-Z0-9_]*
KeyWord      "if"|"else"|"while"|"for"|"int"|"float"|"double"|"break"|"default"|"void"|"return"|"continue"|"switch"|"case"|"struct"|"typedef"
number       [+-]?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?
OP           "="|"=="|"<"|"<="|">"|">="|"!="|"++"|"--"|"+"|"-"|"*"|"/"|"%"|"+="|"-="|"*="|"/="|"&&"|"||"|"!"
Parenthesis  \(|\)
Seperator    ';'|','|':'
Comment      "//".*
MComment     "/*"([^*]|\*+[^*/])*\*+"/"
String       \"([^"\\]|\\.)*\"

%%
{AssignmentOp}  {printf("\n<ASSIGNMENT_OP, %s>", yytext);}
{BitwiseOp}     {printf("\n<BITWISE_OP, %s>", yytext);}
{Curly_Brace}   {printf("\n<CURLY_BRACE, %s>", yytext);}
{Function}      {printf("\n<FUNCTION, %s>", yytext);}
{KeyWord}       {printf("\n<KEYWORD, %s>", yytext);}
{number}        {printf("\n<NUMBER, %s>", yytext);}
{OP}            {printf("\n<OP, %s>", yytext);}
{Parenthesis}   {printf("\n<PARENTHESIS, %s>", yytext);}
{Seperator}     {printf("\n<SEPERATOR, %s>", yytext);}
{Comment}       {printf("\n<COMMENT, %s>", yytext);}
{MComment}      {printf("\n<MULTI_LINE_COMMENT, %s>", yytext);}
{String}        {printf("\n<STRING_LITERAL, %s>", yytext);}
{Variable}      {printf("\n<VARIABLE, %s>", yytext);}
%%

int main() {
    yyin = fopen("input.c", "r");
    if (!yyin) {
        perror("Error opening input file");
        return 1;
    }

    yylex();

    fclose(yyin);
    return 0;
}