%option noyywrap

%{
    #include <stdio.h>
%}

AssignmentOp "<<="|">>="|"&="|"^="
BitwiseOp   ">>"|"<<"|"&"|"^"
digit       [0-9]
ID          [a-zA-Z_][a-zA-Z0-9_]*
number      [+-]?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?
OP          =
SEMICOLON   ;
%%

"int"           {printf("\n<KEYWORD, %s>", yytext);}
{AssignmentOp}  {printf("\n<ASSIGNMENT_OP, %s>", yytext);}
{BitwiseOp}     {printf("\n<BITWISE_OP, %s>", yytext);}
{number}        {printf("\n<NUMBER, %s>", yytext);}
{ID}            {printf("\n<IDENTIFIER, %s>", yytext);}
{OP}            {printf("\n<OP, %s>", yytext);}
{SEMICOLON}     {printf("\n<SEMICOLON, %s>", yytext);}

%%

int main()
{
    yylex(); // triggers flex scanner
}
