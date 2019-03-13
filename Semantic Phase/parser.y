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
	#include <stdlib.h>
	#include <stdio.h>
	int yyerror(char *msg);
	#include "symboltable.h"
	int temp=0;
	#define SYMBOL_TABLE symbol_table_list[current_scope].symbol_table
	entry_t** constant_table;
	entry_t* stack[11];
	entry_t* search_entry=NULL;
	int stack_pointer=0;
	int function_call=0;
	char identifier_name[100];
	int current_dtype;
	table_t symbol_table_list[NUM_TABLES];
	int is_declaration = 0;
	int is_loop = 0;
	char latest_int[100];
	int is_function = 0;
	int parameter_types[10]={0};
	int parameter_count=0;
	int argument_types[10]={0};
	int operand_types[10]={0};
	int operand_count=0;
	int argument_count=0;
	int func_type;
	int empty_subs=0;
	int param_list[10];
	int p_idx = 0;
	int p=0;
	int rhs = 0;
	int rhs_array=0;
	int lhs_array=0;
	void type_check(int[],int);
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
	: IDENTIFIER		{
							search_entry=search_recursive($1);
							if(search_entry==NULL)
								yyerror("Identifier not declared");
							else{
								operand_types[operand_count++]=search_entry->data_type;
							}
							

						}
	| STRING_CONSTANT	{ insert(constant_table, $1,INT_MAX, STRING_CONSTANT); operand_types[operand_count++]=STRING_CONSTANT;}
	| HEX_CONSTANT		{ insert(constant_table, $1,INT_MAX, HEX_CONSTANT); operand_types[operand_count++]=HEX_CONSTANT;}
	| CHAR_CONSTANT     { insert(constant_table, $1,INT_MAX, CHAR_CONSTANT); operand_types[operand_count++]=CHAR;}
	| FLOAT_CONSTANT	{ insert(constant_table, $1,INT_MAX, FLOAT); operand_types[operand_count++]=FLOAT;}
	| INT_CONSTANT		{ insert(constant_table, $1,INT_MAX, INT); operand_types[operand_count++]=INT;}
	| '(' expression ')'
	;

secondary_exp
	: fundamental_exp
	| secondary_exp '[' expression ']'	{check_array(identifier_name);}
	| secondary_exp '(' ')'				{check_parameter_list($1,argument_types,argument_count);argument_count=0;}	
	| secondary_exp '(' arg_list ')'	{check_parameter_list($1,argument_types,argument_count);argument_count=0;}
	| secondary_exp INC_OP
	| secondary_exp DEC_OP
	;

arg_list
	: assignment_expression					{argument_types[argument_count++]=search(SYMBOL_TABLE,identifier_name)->data_type;}
	| arg_list ',' assignment_expression	{argument_types[argument_count++]=search(SYMBOL_TABLE,identifier_name)->data_type;}
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
	: conditional_expression						{type_check(operand_types,operand_count);operand_count=0;}
	| unary_expression '=' assignment_expression
	;

expression
	: assignment_expression						
	| expression ',' assignment_expression		{type_check(operand_types,operand_count);operand_count=0;}
	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers init_declarator_list ';'	{	}
	| error
	;

declaration_specifiers
	: type_specifier						{}
	| type_specifier declaration_specifiers	{}
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator					{if(empty_subs){yyerror("Initializer not used for array with undeclared size");}lhs_array=0;rhs_array=0;}
	| declarator '=' init			{
										if(empty_subs && lhs_array && rhs_array==0){
											yyerror("Initializer not used for array with undeclared size");
										}
										if(rhs_array && lhs_array==0){
											yyerror("Cannot store pointer in non pointer variable");
										}
										rhs_array=0;
										lhs_array=0;
									}
	;

type_specifier
	: VOID		{ $$ = VOID; current_dtype=VOID;}
	| AUTO 		{ $$ = AUTO; }
	| TYPEDEF	{ $$ = TYPEDEF; }
	| EXTERN	{ $$ = EXTERN; }
	| REGISTER	{ $$ = REGISTER; }
	| STATIC	{ $$ = STATIC; }
	| CHAR		{ $$ = CHAR; current_dtype=CHAR;}
	| SHORT		{ $$ = SHORT;}
	| CONST		{ $$ = CONST; }
	| FLOAT		{ $$ = FLOAT;current_dtype=FLOAT;}
	| DOUBLE	{ $$ = DOUBLE;current_dtype=DOUBLE;}
	| INT		{ $$ = INT;current_dtype=INT;}
	| INLINE	{ $$ = INLINE; }
	| LONG		{ $$ = LONG; }
	| SIGNED	{ $$ = SIGNED; }
	| UNSIGNED	{ $$ = UNSIGNED; }
	;

type_specifier_list
	: type_specifier type_specifier_list
	| type_specifier
	;

declarator
	: IDENTIFIER		{	
							stack[stack_pointer]=insert(SYMBOL_TABLE,$1,INT_MAX,current_dtype);
							if(stack[stack_pointer]==NULL){
								yyerror("Identifier redeclaration");
								stack_pointer=0;
							}
							else{
								stack_pointer++;
							}
						}
	| '(' declarator ')'						
	| declarator '[' constant_expression ']'	{
													temp=inter($3);
													if(temp<1){
														yyerror("Array size has to be atleast 1");
													}
													else{
														search(SYMBOL_TABLE,identifier_name)->array_dimension=1;
													}
													lhs_array=1;
												}
	| declarator '[' ']'						{
													lhs_array=1;
													empty_subs=1;
												}
	| declarator '(' 							{is_function=1;func_type=current_dtype;}
		parameter_type_list 
		')'										{stack_pointer=0;parameter_count=0;}							
	| declarator '(' 							{is_function=1;func_type=current_dtype;}
		identifier_list 
		')'										{stack_pointer=0;parameter_count=0;}
	| declarator '(' 							{is_function=1;func_type=current_dtype;}
		')'										{stack_pointer=0;parameter_count=0;}
	;


parameter_type_list
	: parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator				{
														if($1!=VOID){
															parameter_types[parameter_count++]=$1;
															if(stack[0]){
																stack[0]->num_params=parameter_count;
																stack[0]->parameter_list=parameter_types;	
															}
														}
														else
															yyerror("Parameter of type VOID not allowed");
													}	
	| declaration_specifiers abstract_declarator	{
														if($1!=VOID){
															parameter_types[parameter_count++]=$1;	
															if(stack[0]){
																stack[0]->num_params=parameter_count;
																stack[0]->parameter_list=parameter_types;	
															}
														}
														else
															yyerror("Parameter of type VOID not allowed");
													}
	| declaration_specifiers						{parameter_types[parameter_count++]=$1;}
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
	: assignment_expression		{}
	| '{' init_list '}'			{rhs_array=1;}
	| '{' init_list ',' '}'		{rhs_array=1;}
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
	: '{'					{current_scope=create_new_scope();}
		statement_types
		'}'					{current_scope=exit_scope();}
	;

statement_types
	: statement_list 
	| declaration_list 
	| declaration_list statement_list 
	| declaration_list statement_list declaration_list statement_list 
	| declaration_list statement_list declaration_list 
	| statement_list declaration_list statement_list
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
	| DO '{' statement '}' WHILE '(' expression ')' ';'
	;

jump_statement
	: CONTINUE ';'				{}
	| BREAK ';'					{}
	| RETURN ';'				{if(func_type!=VOID)yyerror("Function cannot return NULL");}
	| RETURN expression ';'		{if(func_type==VOID)yyerror("VOID function cannot return INT");}
	| GOTO IDENTIFIER ':'	 
	;
%%

void type_check(int arr[], int n)
{
	for(int i=0;i<n;i+=1){
		if(arr[i]==STRING_CONSTANT){
			yyerror("Invalid use of string");
		}
		if(arr[i]==CHAR){
			yyerror("Warning : Invalid use of character");
		}
	}
}

#include "lex.yy.c"
int error=0;
int main(int argc, char *argv[])
{
	 int i;
	 for(i=0; i<NUM_TABLES;i++)
	 {
		symbol_table_list[i].symbol_table = NULL;
		symbol_table_list[i].parent = -1;
	 }

	constant_table = create_table();
	symbol_table_list[0].symbol_table = create_table();
	yyin = fopen(argv[1], "r");

	if(!yyparse())
	{
		if(!error)
			printf("\nPARSING COMPLETE\n\n\n");
		else
			printf("\nPARSING FAILED!\n\n\n");
	}
	else
	{
		printf("\nPARSING FAILED!\n\n\n");
	}
	if(!error){

		printf("SYMBOL TABLES\n\n");
		display_all();
		printf("Current scope:%d",current_scope);
		printf("CONSTANT TABLE");
		display_constant_table(constant_table);
	}
	fclose(yyin);
	return 0;
}
int yyerror(char *msg)
{
	error=1;
	printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);

}