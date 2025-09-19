/*
 * YACC Parser File - lab5.y
 * This file defines the GRAMMAR RULES and SYNTAX for our simple compiler
 * 
 * What is a Parser?
 * - Takes tokens from the lexer (like IDENTIFIER, NUMBER, +, =, etc.)
 * - Checks if they follow correct grammar rules (like "a = 5 + 3;")
 * - Generates intermediate code and assembly code
 * 
 * Think of it like checking if an English sentence follows proper grammar,
 * then translating it to another language
 */

%{
// Header section - includes and declarations needed for the parser

#include<bits/stdc++.h>
#include "SymbolTable.h"
using namespace std;

#define YYSTYPE SymbolInfo  // This tells YACC what type our tokens will be

// Function declarations
int yylex(void);                    // Function that gets tokens from lexer
int t_count = 1;                    // Counter for temporary variables (t1, t2, t3...)
char *str;                          // String to hold temporary variable names
SymbolInfo asmc;                    // Object to store assembly code
extern SymbolTable Tb;              // Symbol table from lexer (stores variables)
extern FILE *yyin;                  // Input file pointer

// Output files for generated code
ofstream fir("code.ir");            // File for intermediate representation (like: t1 = a + b)
ofstream fasm("code.asm");          // File for assembly language code

// Error handling function - called when grammar rules are broken
void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);     // Print error message to screen
    return;
}

// Function to create new temporary variable names (t1, t2, t3...)
// This is needed when we do operations like addition: a + b gets stored in t1
char* newTemp(int i)
{
    char *tvar = (char*)malloc(15);  // Allocate memory for variable name
    sprintf(tvar, "t%d", i);         // Create name like "t1", "t2", etc.
    return tvar;
}
%}

/*
 * DECLARATIONS SECTION
 * Here we declare all the tokens (word types) that our lexer can send to us
 */

%error-verbose  // This gives us detailed error messages when something goes wrong

// TOKEN DECLARATIONS
// These are like "word types" that the lexer recognizes and sends to us
%token NUMBER       // Numbers like 5, 3.14, 100
%token INT          // The keyword "int" 
%token IDENTIFIER   // Variable names like "a", "x", "myVariable"
%token MAIN         // The keyword "main"
%token NEWLINE      // End of line character
%token SEMICOLON    // The semicolon ";" character
%token LCURLY       // Left curly brace "{"
%token RCURLY       // Right curly brace "}"

/*
 * OPERATOR PRECEDENCE RULES
 * These tell the parser which operations to do first (like math order of operations)
 * 
 * %left means the operator is left-associative (a + b + c = (a + b) + c)
 * %right means the operator is right-associative (a = b = c means a = (b = c))
 * 
 * Lower lines have HIGHER precedence (done first)
 * Think: PEMDAS - Parentheses, Exponents, Multiplication/Division, Addition/Subtraction
 */
%right ASSOP        // Assignment operator "=" (right associative: a = b = 5)
%left LOR           // Logical OR "||" 
%left LAND          // Logical AND "&&"
%left ADD SUB       // Addition "+" and Subtraction "-"
%left MUL DIV MOD   // Multiplication "*", Division "/", Modulus "%"
%left LPARAN RPARAN // Parentheses "(" and ")" - highest precedence

%%

/*
 * GRAMMAR RULES SECTION
 * These rules define what constitutes valid syntax in our language
 * 
 * Format: rule_name : pattern { action }
 * 
 * When the parser sees the pattern, it executes the action in { }
 * $1, $2, $3 refer to the 1st, 2nd, 3rd parts of the pattern
 * $$ refers to the result of this rule
 */

// PROGRAM RULE: Defines what a complete program looks like
// Pattern: main ( ) { <newline> <statements> }
// This is like saying "A program must have main() with statements inside curly braces"
program : MAIN LPARAN RPARAN LCURLY NEWLINE stmt RCURLY    
          { 
              // When we finish parsing the whole program, add ending to assembly code
              asmc.code = asmc.code + "MAIN ENDP\nEND";  // End the main procedure
              fasm << asmc.code;                          // Write all assembly code to file
          }
;

// STATEMENTS RULE: Handles multiple lines of code
// This allows us to have many statements one after another
// Pattern 1: stmt line  (add another line to existing statements)
// Pattern 2: line       (just one line)
stmt: stmt line    { /* Just combine statements together - no special action needed */ }
    | line          { /* Single statement - no special action needed */ }
;


// LINE RULE: Defines what one line of code looks like
// Pattern: <expression_declaration> <newline>
// This is like saying "Each line must be a statement followed by enter/newline"
line: expr_decl NEWLINE    
      {    
          t_count = 1;        // Reset temporary variable counter for next line
          printf("\t\n");     // Print a tab and newline (for formatting output)
      }
;

		
// EXPRESSION DECLARATION RULE: Handles assignment statements
// Pattern: <variable> = <expression> ;
// This handles statements like: a = 5 + 3;
expr_decl: term ASSOP expr SEMICOLON 
           {
               // Generate code for assignment operation
               
               t_count -= 1;                              // Adjust temp variable counter
               str = newTemp(t_count);                    // Create temp variable name
               SymbolInfo obj1(string(str), "");          // Create symbol object
               $$ = obj1;                                 // Set result of this rule
               
               // Generate INTERMEDIATE CODE (human-readable)
               // Example: if input is "a = 5 + 3", this writes "a = t1" to code.ir file
               fir << $1.getSymbol() << " = " << $3.getSymbol() << endl;
        
               // Generate ASSEMBLY CODE (machine-level instructions)
               // MOV ax, <expression_result>  - Move expression result to AX register
               // MOV <variable>, ax           - Move AX register value to variable
               asmc.code = asmc.code + "MOV ax, " + $3.getSymbol() + "\nMOV " + $1.getSymbol() + ", ax\n";
               
               t_count = 1;  // Reset counter for next statement      
           }
;	
	
	
// EXPRESSION RULE: Handles mathematical expressions
// This defines what valid expressions look like in our language

expr: expr ADD expr   // Pattern: <expression> + <expression>         
      { 
          // Handle addition operation (like: 5 + 3 or a + b)
          
          str = newTemp(t_count);                        // Create new temp variable (t1, t2, etc.)
          SymbolInfo obj1(string(str), "");              // Create symbol object for temp variable
          $$ = obj1;                                     // Set this rule's result to temp variable
          
          // Generate INTERMEDIATE CODE
          // Example: if input is "5 + 3", this writes "t1 = 5 + 3" to code.ir file
          fir << $$.getSymbol() << " = " << $1.getSymbol() << " + " << $3.getSymbol() << endl;                                
          
          // Generate ASSEMBLY CODE for addition
          // MOV ax, <first_operand>   - Move first number to AX register
          // MOV bx, <second_operand>  - Move second number to BX register  
          // ADD ax, bx                - Add BX to AX (result in AX)
          // MOV <temp_var>, ax        - Store result in temporary variable
          asmc.code = asmc.code + "MOV ax, " + $1.getSymbol() + "\nMOV bx, " + $3.getSymbol() + "\nADD ax, bx\nMOV " + $$.getSymbol() + ", ax\n";
          
          t_count++;  // Increment counter for next temporary variable
      }
    | NUMBER          // Pattern: just a number (like 5, 3.14)        
      {
          // If it's just a number, pass it through unchanged
          $$ = $1;  // The result of this rule is just the number itself
      }                            
    | term            // Pattern: just a variable (like 'a', 'x')        
      {
          // If it's just a variable, pass it through unchanged  
          $$ = $1;  // The result of this rule is just the variable itself
      }
;

// TERM RULE: Defines what a "term" is (basic building block)
// In our language, a term is just a variable name (identifier)
term: IDENTIFIER        
      {
          // Just pass the identifier through unchanged
          // Example: if we see variable 'a', just return 'a'
          $$ = $1;  // The result is the identifier itself
      }
;

%%

/*
 * MAIN FUNCTION - This is where our compiler starts running
 * 
 * What happens here:
 * 1. Set up assembly code template (like preparing a document template)
 * 2. Open input file to read our source code
 * 3. Start the parsing process
 * 4. Close files and print results
 */
int main(void)
{
    // STEP 1: Initialize assembly code with required header and data section
    // This is like setting up the "skeleton" of our assembly program
    
    // .MODEL SMALL     - tells assembler this is a small program
    // .STACK 100H      - allocates 256 bytes for the stack  
    // .DATA            - start of data section (where variables are stored)
    // a DW ?           - declare variable 'a' as a word (16 bits), uninitialized
    // t1, t2, etc      - declare temporary variables for calculations
    asmc.code = asmc.code + ".MODEL SMALL\n.STACK 100H\n.DATA\na DW ?\nt1 DW ?\nt2 DW ?\nt3 DW ?\nt4 DW ?\n";
    
    // .CODE            - start of code section (where instructions go)
    // MAIN PROC        - start of main procedure
    // MOV AX,@DATA     - load data segment address into AX register
    // MOV DS,AX        - set DS register to point to our data segment
    asmc.code = asmc.code + ".CODE\nMAIN PROC\nMOV AX,@DATA\nMOV DS,AX \n";
    
    // STEP 2: Open input file and start parsing
    yyin = fopen("input.txt", "r");  // Open "input.txt" for reading our source code
    yyparse();                       // Start the parsing process (this calls our grammar rules)
    fclose(yyin);                    // Close the input file
    
    // STEP 3: Close output files
    fir.close();                     // Close intermediate representation file
    fasm.close();                    // Close assembly code file
    
    // STEP 4: Print symbol table (shows all variables we found)
    Tb.print();                      // Display all identifiers and numbers we encountered
    
    return 0;  // Program finished successfully
}