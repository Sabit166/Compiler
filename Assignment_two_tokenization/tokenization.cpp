// Lexical Analyzer (Tokenizer) for C++ Code
// This program reads C++ source code and breaks it down into tokens
// It identifies keywords, identifiers, operators, numbers, literals, and functions

#include <bits/stdc++.h>
using namespace std;

/// Hash table size is 12 (mod value for hash function)
/// Global output file for symbol table operations
ofstream fileout("output.txt", ios_base ::out);
// Function to check if a character is valid for identifiers or keywords
// Valid characters: alphanumeric (a-z, A-Z, 0-9) and underscore (_)
bool idOrKey(char ch)
{
    if ((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_')
    {
        return true; // Character can be part of identifier/keyword
    }
    return false; // Character cannot be part of identifier/keyword
}

// Function to check if a string represents a valid number
// Supports integers (123), negative numbers (-45), and floating point (12.34, .5)
bool digit(string a)
{
    int cnt = 0; // Counter for decimal points
    int n = a.size();

    // First character validation: must be digit, negative sign, or decimal point
    if (a[0] != '-' && !(a[0] >= '0' && a[0] <= '9') && a[0] != '.')
        return false;

    // Count decimal point if first character is one
    if (a[0] == '.')
        cnt++;

    // Check remaining characters
    for (int i = 1; i < n; i++)
    {
        // Each character must be digit or decimal point
        if (!(a[i] >= '0' && a[i] <= '9') && a[i] != '.')
            return false;
        // Count decimal points
        if (a[i] == '.')
            cnt++;
    }

    // Only one decimal point allowed
    if (cnt > 1)
        return false;
    return true; // Valid number format
}

// Function to check if a string is a valid identifier
// Rules: 1) Can contain alphanumeric and underscore only
//        2) Cannot be empty
//        3) Cannot start with a digit
bool id(string s) /// identifier
{
    // Check if all characters are valid for identifiers
    for (int i = 0; i < s.size(); i++)
    {
        if (!idOrKey(s[i]))
            return false; // Invalid character found
    }

    // Identifier cannot be empty
    if (s.empty())
        return false;

    // Identifier cannot start with a digit
    if (s[0] >= '0' && s[0] <= '9')
        return false;

    return true; // Valid identifier
}

// Function to check if a string is a valid operator
// Supports both single and multi-character operators
bool op(string ch)
{
    // List of all supported operators in C++
    vector<string> op = {"+", "-", "*", "%", "&&", "||", "&", "|", "<<", ">>", "=", "+=", "/=",
                         "%=", "!", "!=", "-=", "==", ">", "<", "!"};

    // Check if the input string matches any operator
    if (find(op.begin(), op.end(), ch) != op.end())
        return true; // Found matching operator
    return false;    // Not an operator
}

// Function to check if a character is whitespace
// Recognizes space, newline, and tab characters
bool space(char ch)
{
    if (ch == ' ' || ch == '\n' || ch == '\t')
        return true; // Whitespace character
    return false;    // Not whitespace
}

// Function to check if a character is punctuation
// Used for punctuation marks that are not operators
bool punc(char ch)
{
    vector<char> punc = {',', '.', ';', '?', ':'}; // Punctuation characters
    if (find(punc.begin(), punc.end(), ch) != punc.end())
        return true; // Found punctuation
    return false;    // Not punctuation
}

// Function to check if a string is a C++ keyword
// Contains all major C++ keywords used in basic programming
bool keyword(string a)
{
    // List of C++ keywords to recognize
    vector<string> key = {"if", "else", "else if", "for", "while", "do", "break", "int", "void",
                          "char", "float", "double", "unsigned", "const", "return", "include"};

    // Check if input string matches any keyword
    if (find(key.begin(), key.end(), a) != key.end())
        return true; // Found keyword
    return false;    // Not a keyword
}

// Function to check if a character interrupts token building
// These characters signal the end of a token (brackets, punctuation)
bool interrupt(char ch)
{
    // Characters that separate tokens
    vector<char> bracket = {'(', ')', '{', '}', '[', ']', ',', '.', ';', '?', ':'};
    if (find(bracket.begin(), bracket.end(), ch) != bracket.end())
        return true; // Character interrupts token building
    return false;    // Character doesn't interrupt token building
}

void lexicalError(string line, char errorChar)
{
    // Function to handle lexical errors
    // Prints error message with line number and problematic character
    cout << "Lexical error at line " << line << " and error is: " << errorChar << endl;
}

// Class to store information about each symbol (token)
// Each symbol has a name and its type (keyword, identifier, etc.)
class SymbolInfo
{
    string symbol, symbolType; // Symbol name and its classification

public:
    // Constructor to create a new symbol with its type
    SymbolInfo(string symbol, string symbolType)
    {
        this->symbol = symbol;
        this->symbolType = symbolType;
    }

    // Getter method to retrieve symbol name
    string getSymbol()
    {
        return symbol;
    }

    // Getter method to retrieve symbol type
    string getSymbolType()
    {
        return symbolType;
    }

    // Setter method to update symbol name
    void setSymbol(string symbol)
    {
        this->symbol = symbol;
    }

    // Setter method to update symbol type
    void setSymbolType(string symbolType)
    {
        this->symbolType = symbolType;
    }
};

// Symbol Table class using Hash Table for efficient storage and retrieval
// Uses chaining (vector) to handle hash collisions
// Hash table size is 12 (indices 0-11)
class SymbolTable
{
    vector<SymbolInfo> table[12]; // Array of vectors for chaining

public:
    // Insert a new symbol into the symbol table
    void insertVal(string symbol, string symbolType)
    {
        bool b = lookup(symbol); // Check if symbol already exists
        if (b == false)          // Symbol doesn't exist, safe to insert
        {
            SymbolInfo obj = SymbolInfo(symbol, symbolType); // Create new symbol
            int hashVal = hashFunc(symbol);                  // Calculate hash value
            table[hashVal].push_back(obj);                   // Add to appropriate bucket
            int pos = table[hashVal].size();                 // Get position in bucket
            fileout << "Inserted at position " << hashVal << "," << pos - 1 << endl;
            print(); // Display updated table
        }
        else // Symbol already exists
        {
            fileout << "Value already exists" << endl;
        }
    }

    // Search for a symbol in the symbol table
    bool lookup(string symbol)
    {
        int hashVal = hashFunc(symbol); // Calculate hash value
        bool b = false;                 // Flag to track if symbol is found

        // Search through the bucket at calculated hash index
        for (int j = 0; j < table[hashVal].size(); j++)
        {
            if (table[hashVal][j].getSymbol() == symbol) // Symbol found
            {
                fileout << "Found at " << hashVal << "," << j << endl;
                b = true; // Mark as found
            }
        }
        return b; // Return whether symbol was found
        /// if(b==false) cout<<"Symbol not found in the Table."<<endl;
    }

    // Delete a symbol from the symbol table
    void del(string symbol)
    {
        int pos = 0;                    // Position tracker in the bucket
        int hashVal = hashFunc(symbol); // Calculate hash value
        bool b = false;                 // Flag to track if symbol is found and deleted

        // Iterate through the bucket using iterator for safe deletion
        for (auto it = table[hashVal].begin(); it != table[hashVal].end(); it++)
        {
            if (it->getSymbol() == symbol) // Symbol found
            {
                fileout << "Deleted from " << hashVal << "," << pos << endl;
                table[hashVal].erase(it); // Remove symbol
                b = true;                 // Mark as deleted
                break;                    // Exit loop after deletion
            }
            pos++; // Move to next position
        }

        if (b == false) // Symbol not found
            fileout << "Symbol not found in the Table." << endl;
    }

    // Print the entire symbol table for debugging/visualization
    void print()
    {
        // Iterate through all 12 buckets
        for (int i = 0; i < 12; i++)
        {
            fileout << i << " -> "; // Print bucket index
            // Print all symbols in current bucket
            for (int j = 0; j < table[i].size(); j++)
            {
                fileout << "<" << table[i][j].getSymbol() << ","
                        << table[i][j].getSymbolType() << "> ";
            }
            fileout << endl; // New line after each bucket
        }
    }

    // Hash function to calculate index for symbol storage
    // Uses sum of first 3 characters multiplied by 2, modulo 12
    int hashFunc(string symbol)
    {
        /*
        // Alternative simpler hash function (commented out)
        int a = ((symbol[0]+symbol[1]+symbol[2])*2)% 12;
        return a;
        */

        int sum = 0; // Sum of ASCII values
        // Add ASCII values of first 3 characters (if they exist)
        if (symbol.length() >= 1)
            sum += symbol[0];
        if (symbol.length() >= 2)
            sum += symbol[1];
        if (symbol.length() >= 3)
            sum += symbol[2];

        return ((sum * 2) % 12); // Multiply by 2 and take modulo 12
    }
};

// MAIN FUNCTION - Entry point of the lexical analyzer
int main()
{
    string symbol, symbolType; // Variables for symbol processing
    SymbolTable ob;            // Create symbol table object

    // File handles for input and different types of output
    ifstream input;                        // Input file stream
    ofstream key("output1_keyword.txt");   // Keywords output
    ofstream func("output1_function.txt"); // Functions output
    ofstream identifier("output1_id.txt"); // Identifiers output
    ofstream operat("output1_oper.txt");   // Operators output
    ofstream num("output1_number.txt");    // Numbers output
    ofstream liter("output1_literal.txt"); // String literals output

    input.open("sample_input2.txt"); // Open source code file for reading

    string s = ""; // String to store each line from input file
    int line = 1;  // Line number counter for error reporting

    // MAIN TOKENIZATION LOOP - Process each line of the source code
    while (getline(input, s))
    {
        int n = s.size(); // Length of current line

        // Token building variables
        string token = "", temp = "", lit = ""; // token: identifier/keyword builder
                                                // temp: single char operator handler
                                                // lit: string literal accumulator

        // State tracking flags
        bool literal = false,   // Currently inside string literal
            op_pattern = true,  // Current character formed valid operator
            str_pattern = true; // Current token formed valid string pattern

        // CHARACTER-BY-CHARACTER PROCESSING
        for (int i = 0; i < n; i++)
        {
            temp = ""; // Reset temp for each character

            // STRING LITERAL HANDLING - Check for quotation marks
            if (s[i] == '"')
            {
                if (literal) // End of string literal
                {
                    lit += s[i]; // Add closing quote
                    liter << lit << " " << line << endl; // Write to literals file
                    lit = "";
                    literal = false; // Exit literal mode
                }
                else // Start of string literal
                {
                    literal = true; // Enter literal mode
                    lit = s[i]; // Start with opening quote
                }
                continue; // Skip to next character after handling literal
            }

            // If inside string literal, add all characters to lit
            if (literal)
            {
                lit += s[i];
                continue; // Skip further processing for literal characters
            }

            // TOKEN BUILDING - Add valid identifier/keyword characters
            if (idOrKey(s[i]))
            {
                token += s[i]; // Build token character by character
            }
            else //(!idorkey(s[i])) - Token building stops here
            {
                // OPERATOR HANDLING - Process non-identifier characters
                if (!interrupt(s[i]) && !space(s[i]))
                {
                    temp = s[i];  // Store current character
                    if (op(temp)) // Check if it's a valid operator
                    {
                        // Check for two-character operators (==, <=, ++, etc.)
                        string y = temp + s[i + 1]; // Combine with next character
                        if (op(y))                  // Two-character operator found
                        {
                            operat << y << " " << line << endl; // Write to operators file
                            i++;                                // Skip next character (already processed)
                            ob.insertVal(y, "Operator");        // Add to symbol table
                        }
                        else // Single-character operator
                        {
                            operat << temp << " " << line << endl; // Write to operators file
                            ob.insertVal(temp, "Operator");        // Add to symbol table
                        }
                        op_pattern = true;
                    }
                    else
                        op_pattern = false; // Not an operator
                }

                // TOKEN CLASSIFICATION - Determine what type of token we have
                if (keyword(token)) // Check if token is a keyword
                {
                    key << token << " " << line << endl; // Write to keywords file
                    ob.insertVal(token, "Keyword");      // Add to symbol table
                    str_pattern = true;
                }
                else if (id(token)) // Check if token is a valid identifier
                {
                    // FUNCTION vs IDENTIFIER - Check what follows the identifier
                    if (s[i] == '(') // Opening parenthesis indicates function
                    {
                        func << token << " " << line << endl; // Write to functions file
                        ob.insertVal(token, "Function");      // Add as function to symbol table
                    }
                    else // Regular identifier (variable, etc.)
                    {
                        identifier << token << " " << line << endl; // Write to identifiers file
                        ob.insertVal(token, "Identifier");          // Add as identifier to symbol table
                    }
                    str_pattern = true;
                }
                else if (digit(token)) // Check if token is a number
                {
                    num << token << " " << line << endl; // Write to numbers file
                    ob.insertVal(token, "Number");       // Add to symbol table
                    str_pattern = true;
                }
                else if (!token.empty())
                {
                    str_pattern = false; // Token doesn't match any pattern
                }

                // ERROR DETECTION - Check for lexical errors
                if (((token.size() && str_pattern == false) || 
                    (temp.size() && op_pattern == false)) && interrupt(s[i]))
                {
                    if (!token.empty() && str_pattern == false)
                    {
                        cout << "Lexical error at line " << line << " and error is: " << token << endl;
                    }
                    else if (!temp.empty() && op_pattern == false)
                    {
                        cout << "Lexical error at line " << line << " and error is: " << s[i] << endl;
                    }
                }

                token = ""; // Reset token for next iteration
            }
            // Reset pattern flags for next iteration
            str_pattern = op_pattern = false;
        }
        line++; // Move to next line
    }

    input.close(); // Close input file

    return 0; // Program executed successfully
}
