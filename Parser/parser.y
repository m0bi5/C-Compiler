%left '<' '>' '=' GE_OP LE_OP EQ_OP NE_OP
%left  '+'  '-'
%left  '*'  '/' '%'
%left  '|'
%left  '&'
%token IDENTIFIER STRING_CONSTANT CHAR_CONSTANT INT_CONSTANT FLOAT_CONSTANT HEX_CONSTANT SIZEOF 
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOID

%token VOLATILE UNION TYPEDEF SWITCH STRUCT STATIC SIGNED RESTRICT REGISTER INLINE EXTERN ENUM
%token ELSE_IF DO DEFAULT CASE AUTO SIGNED

%token IF ELSE WHILE CONTINUE BREAK RETURN FOR GOTO 
%start start_state
%glr-parser
%nonassoc NO_ELSE
%nonassoc ELSE

%{
#include<string.h>
char type[100];
char temp[100];
%}


%%

start_state
	: global_declaration
	| start_state global_declaration
	;

global_declaration
	: function_definition
	| declaration
	;

declaration
	: declaration_specifiers init_declarator_list ';'
	| error
	;

function_definition
	: declaration_specifiers declarator compound_statement
	| declarator compound_statement
    ;

declaration_specifiers
	: type_specifier	{ strcpy(type, $1); }
	| type_specifier declaration_specifiers	{ strcpy(temp, $1); strcat(temp, " "); strcat(temp, type); strcpy(type, temp); }
    ;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

declarator
	: direct_declarator
	;

compound_statement
	: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	| '{' declaration_list statement_list declaration_list statement_list '}'
	| '{' declaration_list statement_list declaration_list '}'
	| '{' statement_list declaration_list statement_list '}'
    ;

type_specifier
	: VOID			{ $$ = "void"; }
	| CHAR			{ $$ = "char"; }
	| SHORT			{ $$ = "short"; }
	| INT			{ $$ = "int"; }
	| LONG			{ $$ = "long"; }
	| SIGNED		{ $$ = "signed"; }
	| UNSIGNED	    { $$ = "unsigned"; }
	| FLOAT			{ $$ = "float"; }
	| DOUBLE		{ $$ = "double"; }
	| CONST	        { $$ = "constant"; }
    ;

init_declarator
	: declarator
	| declarator '=' init
    ;

direct_declarator
	: IDENTIFIER								{ symbolInsert($1, type); }
	| '(' declarator ')'
	| direct_declarator '[' constant_expression ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' identifier_list ')'
	| direct_declarator '(' ')'
	;

statement_list
	: statement
	| statement_list statement
    ;

declaration_list
	: declaration
	| declaration_list declaration
    ;

declarator
	: direct_declarator
    ;

init
	: assignment_expression
	| '{' init_list '}'
	| '{' init_list ',' '}'
	;

constant_expression
	: conditional_expression
	;

parameter_type_list
	: parameter_list
    ;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
    ;

statement
	: compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
    ;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
    ;

init_list
	: init
	| init_list ',' init
    ;


conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
    ;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
    ;

compound_statement
	: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	| '{' declaration_list statement_list declaration_list statement_list '}'
	| '{' declaration_list statement_list declaration_list '}'
	| '{' statement_list declaration_list statement_list '}'
    ;

expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement %prec NO_ELSE
	| IF '(' expression ')' statement ELSE statement
    ;

iteration_statement
	: WHILE '(' expression ')' statement
    | FOR '(' assignment_expression ';' expression  ';' ')' statement
    ;

jump_statement
	: CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
    | GOTO IDENTIFIER ';'
	;

unary_expression
	: secondary_exp
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator typecast_exp
    ;   

assignment_operator
	: '='
    ;

init
	: assignment_expression
	| '{' init_list '}'
	| '{' init_list ',' '}'
    ;


logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
    ;

expression
	: assignment_expression
	| expression ',' assignment_expression
    ;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
    ;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
    ;

secondary_exp
	: fundamental_exp
	| secondary_exp '[' expression ']'
	| secondary_exp '(' ')'
	| secondary_exp '(' arg_list ')'
	| secondary_exp '.' IDENTIFIER
	| secondary_exp INC_OP
	| secondary_exp DEC_OP
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
    ;

logical_and_expression
	: unary_or_expression
	| logical_and_expression AND_OP unary_or_expression
	;

abstract_declarator
	: direct_abstract_declarator
    ;

fundamental_exp
	: IDENTIFIER
	| STRING_CONSTANT		{ constantInsert($1, "string"); }
	| CHAR_CONSTANT         { constantInsert($1, "char"); }
	| FLOAT_CONSTANT	    { constantInsert($1, "float"); }
	| HEX_CONSTANT	        { constantInsert($1, "hexadecimal"); }
	| INT_CONSTANT			{ constantInsert($1, "int"); }
	| '(' expression ')'
	;

secondary_exp
	: fundamental_exp
	| secondary_exp '[' expression ']'
	| secondary_exp '(' ')'
	| secondary_exp '(' arg_list ')'
	| secondary_exp '.' IDENTIFIER
	| secondary_exp INC_OP
	| secondary_exp DEC_OP
	;

arg_list
	: assignment_expression
	| arg_list ',' assignment_expression
	;


unary_or_expression
	: unary_or_expression
	| unary_or_expression '|' exor_expression
    ;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' constant_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' constant_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
    ;

exor_expression
	: and_expression
	| exor_expression '^' and_expression
	;


and_expression
	: equality_expression
	| and_expression '&' equality_expression
    ;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
    ;

relational_expression
	: addsub_exp
	| relational_expression '<' addsub_exp
	| relational_expression '>' addsub_exp
	| relational_expression LE_OP addsub_exp
	| relational_expression GE_OP addsub_exp
    ;

addsub_exp
	: multdivmod_exp
	| addsub_exp '+' multdivmod_exp
	| addsub_exp '-' multdivmod_exp
    ;


multdivmod_exp
	: typecast_exp
	| multdivmod_exp '*' typecast_exp
	| multdivmod_exp '/' typecast_exp
	| multdivmod_exp '%' typecast_exp
    ;

typecast_exp
	: unary_expression
	| '(' type_name ')' typecast_exp
    ;


type_name
	: type_specifier_list
	| type_specifier_list abstract_declarator
    ;

type_specifier_list
	: type_specifier type_specifier_list
	| type_specifier
	;
%%

#include "lex.yy.c"
#include <ctype.h>
#include <stdio.h>
#include <string.h>
struct symbol
{
	char token[100];	// Name of the token
	char dataType[100];		// Date type: int, short int, long int, char etc
}symbolTable[100000], constantTable[100000];
int i=0; // Number of symbols in the symbol table
int c=0;
//Insert function for symbol table
void symbolInsert(char* tokenName, char* DataType)
{
  strcpy(symbolTable[i].token, tokenName);
  strcpy(symbolTable[i].dataType, DataType);
  i++;
}
void constantInsert(char* tokenName, char* DataType)
{
	for(int j=0; j<c; j++)
	{
		if(strcmp(constantTable[j].token, tokenName)==0)
			return;
	}
  strcpy(constantTable[c].token, tokenName);
  strcpy(constantTable[c].dataType, DataType);
  c++;
}


void showSymbolTable()
{
	printf("\n------------Symbol Table---------------------\n\nSNo\tToken\t\tDatatype\n\n");
	for(int j=0;j<i;j++)
		printf("%d\t%s\t\t< %s >\t\t\n",j+1,symbolTable[j].token,symbolTable[j].dataType);
}
void showConstantTable()
{
	printf("\n------------Constant Table---------------------\n\nSNo\tConstant\t\tDatatype\n\n");
	for(int j=0;j<c;j++)
		printf("%d\t%s\t\t< %s >\t\t\n",j+1,constantTable[j].token,constantTable[j].dataType);
}
int err=0;
int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");
	yyparse();
	if(err==0)
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	fclose(yyin);
	showSymbolTable();
	showConstantTable();
	return 0;
}
extern char *yytext;
yyerror(char *s)
{
	err=1;
	printf("\nLine %d : %s\n", (yylineno), s);
	showSymbolTable();
	showConstantTable();
	exit(0);
}
