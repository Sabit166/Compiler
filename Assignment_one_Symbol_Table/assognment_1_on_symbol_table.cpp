#include <bits/stdc++.h>
using namespace std;

const string student_ID = "202314104";
const int table_size = 20;

class Symbol_Info
{
public:
    string symbol, symbol_Type;
    Symbol_Info(string symbol, string symbol_Type)
    {
        this->symbol = symbol;
        this->symbol_Type = symbol_Type;
    }
};

class Symbol_Table
{
    vector<Symbol_Info>table[table_size];
public:

    int hashValue(string symbol)
    {
        int sum = 0;
        if(symbol.size() > 3)
        {
            sum = symbol[0] + symbol[1] + symbol[symbol.size() - 1] + symbol[symbol.size() - 2];
        }
        else
        {
            for(int i=0; i<symbol.size(); i++) sum += symbol[i];
        }

        int idSum = 0;
        for(int i=0; i<student_ID.size(); i++) idSum += student_ID[i] - '0';

        int last_digit = student_ID.back() - '0';
        sum<<=last_digit;
        //cout << "Hashing successful\n";
        return (sum*idSum)%table_size;
    }

    void Insert(string symbol, string type, ofstream &out)
    {
        int hsh = hashValue(symbol);

        for(int i=0; i<table[hsh].size(); i++)
        {
            if(table[hsh][i].symbol == symbol)
            {
                out << "Symbol already exists.\n";
                return;
            }
        }

        table[hsh].push_back(Symbol_Info(symbol, type));
        out << "Symbol inserted at position " << hsh << ',' << (table[hsh].size() - 1) << endl;

    }

    void Lookup(string symbol, ofstream &out)
    {
        int hsh = hashValue(symbol);

        for(int i=0; i<table[hsh].size(); i++)
        {
            if(table[hsh][i].symbol == symbol)
            {
                out << "Found symbol at " << hsh << ',' << i << endl;
                return;
            }
        }
        out << "Not found.\n";
    }

    void Delete(string symbol, ofstream &out)
    {
        int hsh = hashValue(symbol);
        for(int i=0; i<table[hsh].size(); i++)
        {
            if(table[hsh][i].symbol == symbol)
            {
                table[hsh].erase(table[hsh].begin() + i);
                out << "Deleted from " << hsh << ',' << i << endl;
                return;
            }
        }
        out << "Not found.\n";
    }

    void Print(ofstream &out)
    {
        for(int i=0; i<table_size; i++)
        {
            if(!table[i].empty())
            {
                out << i << "--> ";
                for(int j=0; j < table[i].size(); j++)
                {
                    out << "<" << table[i][j].symbol << ", " << table[i][j].symbol_Type << "> ";
                }
                out << endl;
            }
        }
    }

};

int main()
{
    Symbol_Table table;
    char operation;
    string name, type;
    ifstream input("C:\\Users\\sabit\\OneDrive\\Desktop\\Compiler\\Assignment_one_Symbol_Table\\input.txt");
    ofstream output("C:\\Users\\sabit\\OneDrive\\Desktop\\Compiler\\Assignment_one_Symbol_Table\\output.txt");

    if (!input || !output)
    {
        cerr << "Error opening files.\n";
        return 1;
    }


    while(input >> operation)
    {
        if(operation == 'I')
        {
            input >> name >> type;
            table.Insert(name, type, output);
        }

        else if(operation == 'P')
        {
            table.Print(output);
        }

        else if(operation == 'L')
        {
            input >> name;
            table.Lookup(name, output);
        }

        else if(operation == 'D')
        {
            input >> name;
            table.Delete(name, output);
        }
    }
    input.close();
    output.close();
}
