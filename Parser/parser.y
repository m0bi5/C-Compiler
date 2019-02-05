%nonassoc NO_ELSE
%nonassoc ELSE
%nonassoc ELSE_IF
%left '<' '>' '=' GE_OP LE_OP EQ_OP NE_OP
%left  '+'  '-'
%left  '*'  '/' '%'
%left  '|'
%left  '&'
%token IDENTIFIER STRING_CONSTANT CHAR_CONSTANT INT_CONSTANT FLOAT_CONSTANT HEX_CONSTANT SIZEOF
%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP 
%token TYPE_NAME DEF
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT VOID AUTO CONST DOUBLE EXTERN REGISTER STATIC INLINE TYPEDEF
%token IF ELSE WHILE CONTINUE BREAK RETURN ELSE_IF GOTO DO FOR
%token CASE DEFAULT SWITCH 
%start start_state
%nonassoc UNARY
%glr-parser

%{
#include<string.h>
#include "symboltable.h"
char type[100];
char temp[100];

entry_t** symbol_table;
entry_t** constant_table; 
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
	| STRING_CONSTANT	{ insert(constant_table, $1, "string"); }
	| HEX_CONSTANT		{ insert(constant_table, $1, "hexadecimal"); }
	| CHAR_CONSTANT     { insert(constant_table, $1, "char"); }
	| FLOAT_CONSTANT	{ insert(constant_table, $1, "float"); }
	| INT_CONSTANT		{ insert(constant_table, $1, "int"); }
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
	: IDENTIFIER	{ insert(symbol_table, $1, type); }
	| '(' declarator ')'
	| declarator '[' constant_expression ']'
	| declarator '[' ']'
	| declarator '(' parameter_type_list ')'
	| declarator '(' identifier_list ')'
	| declarator '(' ')'
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
	| case_statement
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

else_list
	: ELSE_IF '(' expression ')' statement else_list
	| ELSE statement
	;

case_statement
	: CASE CHAR_CONSTANT ':' statement 
	| CASE INT_CONSTANT ':' statement 
	| DEFAULT ':'
	;

selection_statement
	: IF '(' expression ')' statement %prec NO_ELSE
	| IF '(' expression ')' statement else_list 
	| SWITCH '(' IDENTIFIER ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| FOR '(' expression ';' expression ';' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	;

jump_statement
	: CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	| GOTO IDENTIFIER ':'	 
	;
%%
#include"lex.yy.c"
#include <ctype.h>
#include <stdio.h>
#include <string.h>

int err=0;
int main(int argc, char *argv[])
{
	symbol_table=create_table();
  	constant_table=create_table();
	yyin = fopen(argv[1], "r");
	yyparse();
	if(err==0)
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	fclose(yyin);
	printf("\n\n");
	printf("\n****************************************");
	printf("\n\tSymbol table");
	display(symbol_table);
	printf("\n\n");
	printf("\n****************************************");
	printf("\n\tConstants Table");
	display(constant_table);
	printf("\n\n");
	return 0;
}
extern char *yytext;
yyerror(char *s)
{
	err=1;
	printf("\nLine %d : %s\n", (yylineno), s);
	printf("\n\n");
	printf("\n****************************************");
	printf("\n\tSymbol table");
	display(symbol_table);
	printf("\n\n");
	printf("\n****************************************");
	printf("\n\tConstants Table");
	display(constant_table);
	printf("\n\n");
	exit(0);
}