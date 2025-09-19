%option noyywrap
%{
#include<stdio.h>
#include<string.h>

int line_num = 1;
int up = 0;
int low = 0;
int par = 0;
int logical = 0;
int assignment = 0;
int bitwise = 0;
int rel = 0;
int key = 0;
int ide = 0;
int num = 0;
int hexa = 0;
int punc = 0;
int func = 0;
int lit = 0;

FILE *yyin;
FILE *yyoutkey;
FILE *yyoutfunc;
FILE *yyoutid;
FILE *yyoutrelop;
FILE *yyoutassop;
FILE *yyoutbitop;
FILE *yyoutlogop;
FILE *yyoutnum;
FILE *yyoutlit;
FILE *yyoutupdown;
FILE *yyouterr;
FILE *yyouthexa;
FILE *yyoutpunc;
FILE *yyoutparen;
FILE *arithop;


%}


digit         [0-9]
digits        [0-9]+
letters       [a-zA-Z_]
keyword       "if"|"else"|"else if"|"for"|"while"|"do"|"break"|"int"|"char"|"float"|"double"|"unsigned"|"const"|"return"|"include"
id            {letters}({letters}|{digit})*
number        [+\-]?{digits}(\.{digits})?([Ee][+\-]?{digits})?
function      {id}\(.*\)
assignmentop  =|<<=|>>=|&=|\^=|\|=

relop         >=|<=|==|!=|>|<
logicalop     &&|\||!
bitwiseop     &|\||<<|>>|\^|~|>>
arithmeticop  \+|-|\*|/|%|\*\*
uppercase     [A-Z]
lowercase     [a-z]
hex           [a-fA-F0-9]
hexanum       0[xX]{hex}+
punctuation   [;,.?!]
parenthesis   [\(\)\[\]\{\}]
literal       \"([^\\\n]|\\.)*\"
singleline    "//".*
multiline     "/*"(.|\n)*?"*/"
delim         [ \t]
lineend		  \n


%%
{delim}         {}
{lineend}		{line_num++;}
{singleline}    {line_num++;}
{multiline}     {
                 for(int i = 0; yytext[i] != '\0'; i++)
				  if(yytext[i] == '\n') line_num++;
				  }
{uppercase}      {up++;}
{lowercase}     {low++;}
{keyword}        {fprintf(yyoutkey,"<keyword,%s> line number %d\n", yytext,line_num);
                  key++;
				 }
{id}             {fprintf(yyoutid,"<identifier,%s> line number %d\n", yytext,line_num);
                  ide++;
				 }
{number}        {fprintf(yyoutnum,"<number,%s> line number %d\n", yytext,line_num);
                  num++;
				 }
{parenthesis}        {fprintf(yyoutparen,"<parenthesis,%s> line number %d\n", yytext,line_num);
                 par++;
				 }
{punctuation}        {fprintf(yyoutpunc,"<punctuation,%s> line number %d\n", yytext,line_num);
                       punc++;
				 }
{hexanum}        {fprintf(yyouthexa,"<hexadecimal,%s> line number %d\n", yytext,line_num);
                   hexa++;
				 }
{logicalop}        {fprintf(yyoutlogop,"<logical operator,%s> line number %d\n", yytext,line_num);
                   logical++;
				 }
{assignmentop}   {
                  fprintf(yyoutassop, "<assignment operator,%s> line number %d\n", yytext, line_num);
                   assignment++;
                 }
{relop}        {fprintf(yyoutrelop,"<relational operator,%s> line number %d\n", yytext,line_num);
                 rel++;
				 }
{bitwiseop}        {fprintf(yyoutbitop,"<bitwise operator,%s> line number %d\n", yytext,line_num);
                   bitwise++;
				 }
{function}        {fprintf(yyoutfunc,"<function,%s> line number %d\n", yytext,line_num);
                   func++;
				 }
{literal}        {fprintf(yyoutlit,"<string literal,%s> line number %d\n", yytext,line_num);
                    lit++;
				 }
.              { fprintf(yyouterr,"<lexical error,%s> line number %d\n", yytext,line_num); }

		
%%

int main(){
    yyin = fopen("input.txt","r");
	if(!yyin) {
	perror("Cannot open input file");
	return 1;
	}
	
	
	yyoutassop = fopen("assignmentOperator.txt","w");
	if(!yyoutassop) {
	perror("Cannot open output file");
	fclose(yyin);
	return 1;
	}
	yyoutbitop = fopen("bitwiseOperator.txt","w");
	if(!yyoutbitop) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyouterr = fopen("error.txt","w");
	if(!yyouterr) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutfunc = fopen("Function.txt","w");
	if(!yyoutfunc) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyouthexa = fopen("Hexa.txt","w");
	if(!yyouthexa) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutid = fopen("id.txt","w");
	if(!yyoutid) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutkey = fopen("Keyword.txt","w");
	if(!yyoutkey) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutlit = fopen("Literal.txt","w");
	if(!yyoutlit) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutlogop = fopen("LogicalOperator.txt","w");
	if(!yyoutlogop) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutnum = fopen("Number.txt","w");
	if(!yyoutnum) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutparen = fopen("PParenthesis.txt","w");
	if(!yyoutparen) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutpunc = fopen("Punctuation.txt","w");
	if(!yyoutpunc) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutrelop = fopen("RelationalOperator.txt","w");
	if(!yyoutrelop) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	yyoutupdown = fopen("UppercaseLowecase.txt","w");
	if(!yyoutupdown) {
	perror("Cannot open output file");
		fclose(yyin);

	return 1;
	}
	
	
	yylex();
	
	fprintf(yyoutassop,"No of ass is %d\n",assignment);
	fprintf(yyoutbitop,"No of bitwise is %d\n",bitwise);
	fprintf(yyoutfunc,"No of function is %d\n",func);
	fprintf(yyouthexa,"No of hexadecimal is %d\n",hexa);
	fprintf(yyoutid,"No of id is %d\n",ide);
	fprintf(yyoutkey,"No of keyword is %d\n",key);
	fprintf(yyoutlit,"No of literal is %d\n",lit);
	fprintf(yyoutlogop,"No of op is %d\n",logical);
	fprintf(yyoutnum,"No of num is %d\n",num);
	fprintf(yyoutparen,"No of paren is %d\n",par);
	fprintf(yyoutpunc,"No of ounc is %d\n",punc);
	fprintf(yyoutrelop,"No of relop is %d\n",rel);
	fprintf(yyoutupdown,"No of upper is %d\n",up);
	fprintf(yyoutupdown,"No of lower is %d\n",low);
			
			
	fclose(yyin);
	fclose(yyoutassop);
	fclose(yyoutbitop);
	fclose(yyouterr);
	fclose(yyoutfunc);
	fclose(yyouthexa);
	fclose(yyoutid);
	fclose(yyoutkey);
	fclose(yyoutlit);
	fclose(yyoutlogop);
	fclose(yyoutnum);
	fclose(yyoutparen);
	fclose(yyoutpunc);
	fclose(yyoutrelop);
	fclose(yyoutupdown);

    return 0;
	}








	
		
				 