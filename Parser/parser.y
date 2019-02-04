%nonassoc NO_ELSE
%nonassoc ELSE
%left '<' '>' '=' GE_OP LE_OP EQ_OP NE_OP
%left  '+'  '-'
%left  '*'  '/' '%'
%left  '|'
%left  '&'
%token IDENTIFIER STRING_CONSTANT CHAR_CONSTANT INT_CONSTANT FLOAT_CONSTANT SIZEOF
%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP 
%token TYPE_NAME DEF
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT VOID AUTO CONST DOUBLE EXTERN REGISTER STATIC INLINE TYPEDEF
%token IF ELSE WHILE CONTINUE BREAK RETURN
%token HEX_CONSTANT CASE DEFAULT DO ELSE_IF FOR GOTO SWITCH /*Grammar to be added*/
%start start_state
%nonassoc UNARY
%glr-parser

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

function_definition
	: declaration_specifiers declarator compound_statement
	| declarator compound_statement
	;

fundamental_exp
	: IDENTIFIER
	| STRING_CONSTANT	{ constantInsert($1, "string"); }
	| CHAR_CONSTANT     { constantInsert($1, "char"); }
	| FLOAT_CONSTANT	{ constantInsert($1, "float"); }
	| INT_CONSTANT		{ constantInsert($1, "int"); }
	| '(' expression ')'
	;

secondary_exp
	: fundamental_exp
	| secondary_exp '[' expression ']'
	| secondary_exp '(' ')'
	| secondary_exp '(' arg_list ')'
	| secondary_exp INC_OP
	| secondary_exp DEC_OP
	;

arg_list
	: assignment_expression
	| arg_list ',' assignment_expression
	;

unary_expression
	: secondary_exp
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator typecast_exp
	;

unary_operator
	: '*'
	| '+'
	| '-'
	;

typecast_exp
	: unary_expression
	| '(' type_name ')' typecast_exp
	;

multdivmod_exp
	: typecast_exp
	| multdivmod_exp '*' typecast_exp
	| multdivmod_exp '/' typecast_exp
	| multdivmod_exp '%' typecast_exp
	;

addsub_exp
	: multdivmod_exp
	| addsub_exp '+' multdivmod_exp
	| addsub_exp '-' multdivmod_exp
	;

relational_expression
	: addsub_exp
	| relational_expression '<' addsub_exp
	| relational_expression '>' addsub_exp
	| relational_expression LE_OP addsub_exp
	| relational_expression GE_OP addsub_exp
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exor_expression
	: and_expression
	| exor_expression '^' and_expression
	;

unary_or_expression
	: exor_expression
	| unary_or_expression '|' exor_expression
	;

logical_and_expression
	: unary_or_expression
	| logical_and_expression AND_OP unary_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression '=' assignment_expression
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers init_declarator_list ';'
	| error
	;

declaration_specifiers
	: type_specifier						{ strcpy(type, $1); }
	| type_specifier declaration_specifiers	{ strcpy(temp, $1); strcat(temp, " "); strcat(temp, type); strcpy(type, temp); }
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator
	| declarator '=' init
	;

type_specifier
	: VOID		{ $$ = "void"; }
	| AUTO 		{ $$ = "auto"; }
	| TYPEDEF	{ $$ = "typedef"; }
	| EXTERN	{ $$ = "extern"; }
	| REGISTER	{ $$ = "register"; }
	| STATIC	{ $$ = "static"; }
	| CHAR		{ $$ = "char"; }
	| SHORT		{ $$ = "short"; }
	| CONST		{ $$ = "const"; }
	| FLOAT		{ $$ = "float"; }
	| DOUBLE	{ $$ = "double"; }
	| INT		{ $$ = "int"; }
	| INLINE	{ $$ = "inline"; }
	| LONG		{ $$ = "long"; }
	| SIGNED	{ $$ = "signed"; }
	| UNSIGNED	{ $$ = "unsigned"; }
	;

type_specifier_list
	: type_specifier type_specifier_list
	| type_specifier
	;

declarator
	: direct_declarator
	;

direct_declarator
	: IDENTIFIER	{ symbolInsert($1, type); }
	| '(' declarator ')'
	| direct_declarator '[' constant_expression ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' identifier_list ')'
	| direct_declarator '(' ')'
	;


parameter_type_list
	: parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: type_specifier_list
	| type_specifier_list abstract_declarator
	;

abstract_declarator
	: direct_abstract_declarator
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

init
	: assignment_expression
	| '{' init_list '}'
	| '{' init_list ',' '}'
	;

init_list
	: init
	| init_list ',' init
	;

statement
	: compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
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

declaration_list
	: declaration
	| declaration_list declaration
	;

statement_list
	: statement
	| statement_list statement
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
	;

jump_statement
	: CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;
%%
#include"lex.yy.c"
#include <ctype.h>
#include <stdio.h>
#include <string.h>
struct symbol
{
	char token[100];	
	char dataType[100];		
}symbolTable[100000], constantTable[100000];
int i=0; 
int c=0;

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