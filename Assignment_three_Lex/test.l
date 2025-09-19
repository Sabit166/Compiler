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
{AssignmentOp}  {fprintf(yyout, "\n<ASSIGNMENT_OP, %s>", yytext);}
{BitwiseOp}     {fprintf(yyout, "\n<BITWISE_OP, %s>", yytext);}
{Curly_Brace}   {fprintf(yyout, "\n<CURLY_BRACE, %s>", yytext);}
{Function}      {fprintf(yyout, "\n<FUNCTION, %s>", yytext);}
{KeyWord}       {fprintf(yyout, "\n<KEYWORD, %s>", yytext);}
{number}        {fprintf(yyout, "\n<NUMBER, %s>", yytext);}
{OP}            {fprintf(yyout, "\n<OP, %s>", yytext);}
{Parenthesis}   {fprintf(yyout, "\n<PARENTHESIS, %s>", yytext);}
{Seperator}     {fprintf(yyout, "\n<SEPERATOR, %s>", yytext);}
{Comment}       {fprintf(yyout, "\n<COMMENT, %s>", yytext);}
{MComment}      {fprintf(yyout, "\n<MULTI_LINE_COMMENT, %s>", yytext);}
{String}        {fprintf(yyout, "\n<STRING_LITERAL, %s>", yytext);}
{Variable}      {fprintf(yyout, "\n<VARIABLE, %s>", yytext);}
%%

int main() {
    yyin = fopen("input.c", "r");
    if (!yyin) {
        perror("Error opening input file");
        return 1;
    }

    yyout = fopen("output.txt", "w");
    if (!yyout) {
        perror("Error opening output file");
        fclose(yyin);
        return 1;
    }

    yylex();

    fclose(yyin);
    fclose(yyout);

    return 0;
}