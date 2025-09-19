/*
 * LEX Lexical Analyzer File - lab5.l
 * This file defines the LEXICAL RULES for our simple compiler
 * 
 * What is a Lexical Analyzer (Lexer)?
 * - Reads raw text input character by character
 * - Groups characters into meaningful "tokens" (like words in a sentence)
 * - Identifies what type each token is (number, variable name, operator, etc.)
 * - Sends these tokens to the parser
 * 
 * Example: Input "a = 5 + 3;" becomes tokens:
 * IDENTIFIER(a), ASSOP(=), NUMBER(5), ADD(+), NUMBER(3), SEMICOLON(;)
 * 
 * Think of it like reading a sentence and identifying each word as a noun, verb, etc.
 */

%option noyywrap  // Tell lex we don't need to handle multiple input files

%{
// Header section - includes and declarations needed for the lexer

#include<bits/stdc++.h>
#include "SymbolTable.h"
#define YYSTYPE SymbolInfo      // Define the type for token values
#include "lab5.tab.h"           // Include parser-generated header file

using namespace std;

void yyerror(const char* msg);  // Function to handle errors
SymbolTable Tb;                 // Symbol table to store identifiers and numbers we find
%}

/*
 * PATTERN DEFINITIONS SECTION
 * Here we define patterns (regular expressions) that describe different types of tokens
 * These are like "templates" that help us recognize different kinds of text
 */

GAP         [ \t]+                    // Matches one or more spaces or tabs
DIGITS      [0-9]+                    // Matches one or more digits (0-9)
NUMBER      {DIGITS}(\.{DIGITS})?     // Matches integers (123) or decimals (123.45)
IDENTIFIER  [_A-Za-z][_A-Za-z0-9]*   // Matches variable names (must start with letter/underscore)

/*
 * Pattern explanation:
 * [_A-Za-z]        - First character must be underscore or letter (a-z, A-Z)
 * [_A-Za-z0-9]*    - Following characters can be letters, digits, or underscore
 * Examples: a, myVar, _temp, x1, MY_CONSTANT
 */

%%
/*
 * LEXICAL RULES SECTION
 * Format: pattern { action }
 * When the lexer sees a pattern, it executes the corresponding action
 * 
 * The variable 'yytext' contains the actual text that matched the pattern
 * We return token types (like IDENTIFIER, NUMBER) to the parser
 */

// WHITESPACE HANDLING
{GAP}        { 
                /* Ignore whitespace completely - don't send anything to parser */
                /* This is like ignoring spaces between words when reading */ 
             }

// NEWLINE HANDLING  
[\n]+        { 
                /* When we see one or more newlines, send NEWLINE token to parser */
                /* This helps parser know when a line of code ends */
                return NEWLINE;
             }

// KEYWORD RECOGNITION
"main"       { 
                /* When we see the exact word "main", send MAIN token */
                /* Keywords are special reserved words in our language */
                return MAIN;
             }
             
"int"        { 
                /* When we see the exact word "int", send INT token */
                /* This would be used for declaring integer variables */
                return INT;
             }
		 
// IDENTIFIER RECOGNITION (Variable Names)
{IDENTIFIER} { 
                /* When we find a variable name like "a", "myVar", "x1" */
                
                // Create a SymbolInfo object to store information about this identifier
                SymbolInfo ob(string(yytext), "IDENTIFIER");
                
                // Set yylval so parser can access the identifier's information
                yylval = (YYSTYPE)ob;
                
                // Add this identifier to our symbol table for tracking
                // yytext contains the actual text (like "a" or "myVar")
                Tb.INSERT(string(yytext), "IDENTIFIER");
                
                // Send IDENTIFIER token to parser
                return IDENTIFIER;
             }

// NUMBER RECOGNITION             
{NUMBER}     { 
                /* When we find a number like "5", "123", "3.14" */
                
                // Create a SymbolInfo object to store information about this number
                SymbolInfo ob(string(yytext), "NUMBER");
                
                // Set yylval so parser can access the number's value
                yylval = (YYSTYPE)ob;
                
                // Add this number to our symbol table  
                // yytext contains the actual number (like "5" or "3.14")
                Tb.INSERT(string(yytext), "NUMBER");
                
                // Send NUMBER token to parser
                return NUMBER;
             }
		 
// ARITHMETIC OPERATORS
"+"          { 
                /* Addition operator - when we see '+' */
                return ADD;
             }
             
"-"          { 
                /* Subtraction operator - when we see '-' */
                return SUB;
             }

"*"          { 
                /* Multiplication operator - when we see '*' */
                return MUL;
             }

"/"          { 
                /* Division operator - when we see '/' */
                return DIV;
             }

"%"          { 
                /* Modulus operator - when we see '%' (remainder after division) */
                return MOD;
             }

// ASSIGNMENT OPERATOR        
"="          { 
                /* Assignment operator - when we see '=' */
                /* Used in statements like: a = 5 */
                return ASSOP;
             }
		 
// PUNCTUATION AND DELIMITERS
"("          { 
                /* Left parenthesis - used for grouping expressions like (a + b) */
                return LPARAN;
             }
             
")"          { 
                /* Right parenthesis - closes grouping started by ( */
                return RPARAN;
             }

"{"          { 
                /* Left curly brace - starts a block of code */
                /* Used in: main() { <code here> } */
                return LCURLY;
             }
             
"}"          { 
                /* Right curly brace - ends a block of code */
                return RCURLY;
             }
             
";"          { 
                /* Semicolon - marks the end of a statement */
                /* Every statement in our language must end with ; */
                return SEMICOLON;
             }

// LOGICAL OPERATORS (for future use)    
"&&"         { 
                /* Logical AND operator - both conditions must be true */
                /* Example: (a > 0) && (b < 10) */
                return LAND;
             }        

"||"         { 
                /* Logical OR operator - at least one condition must be true */
                /* Example: (a == 0) || (b == 0) */
                return LOR;
             }

// ERROR HANDLING - catches any character we don't recognize
.            { 
                /* The dot '.' matches any single character not matched above */
                /* This catches invalid/unexpected characters */
                
                char msg[25];
                sprintf(msg, " <%s>", "invalid character", yytext);
                yyerror(msg);  // Report error with the invalid character
             }
%%

/*
 * END OF LEXICAL RULES
 * 
 * HOW THE LEXER WORKS - Step by Step Example:
 * 
 * Input text: "a = 5 + 3;"
 * 
 * 1. Lexer reads 'a' -> matches {IDENTIFIER} pattern -> returns IDENTIFIER token
 * 2. Lexer reads ' ' -> matches {GAP} pattern -> ignores it (no return)
 * 3. Lexer reads '=' -> matches "=" pattern -> returns ASSOP token  
 * 4. Lexer reads ' ' -> matches {GAP} pattern -> ignores it
 * 5. Lexer reads '5' -> matches {NUMBER} pattern -> returns NUMBER token
 * 6. Lexer reads ' ' -> matches {GAP} pattern -> ignores it
 * 7. Lexer reads '+' -> matches "+" pattern -> returns ADD token
 * 8. Lexer reads ' ' -> matches {GAP} pattern -> ignores it
 * 9. Lexer reads '3' -> matches {NUMBER} pattern -> returns NUMBER token
 * 10. Lexer reads ';' -> matches ";" pattern -> returns SEMICOLON token
 * 
 * Result: IDENTIFIER ASSOP NUMBER ADD NUMBER SEMICOLON
 * These tokens are sent to the parser to check grammar and generate code.
 */
