/*	Project 1 - Compiler Design 
	Lexical Analyser

	Jay Satish Shinde - 16CO118
	Mohit Bhasi - 16CO126
	Anshul Pinto - 16CO101	


	Main Lex file
*/

%{
#include<stdio.h>
#include <stdlib.h>
#include "symboltable.h"
#include "tokens.h" 
int comment = 0;
int beginning=0;
entry_t** symbol_table;
entry_t** constant_table; 
%}

letter 		[a-zA-Z]
digit 		[0-9]
whitespace	[ \t\r\f\v]+
identifier 	(_|{letter})({letter}|{digit}|_)*
hex 		[0-9a-f]

%x comment

%%

"auto"				{ printf("Keyword: %s\n",yytext); }
"break"				{ printf("Keyword: %s\n",yytext); }
"case"				{ printf("Keyword: %s\n",yytext); }
"char"				{ printf("Keyword: %s\n",yytext); }
"const"				{ printf("Keyword: %s\n",yytext); }
"continue"			{ printf("Keyword: %s\n",yytext); }
"default"			{ printf("Keyword: %s\n",yytext); }
"do"				{ printf("Keyword: %s\n",yytext); }
"double"			{ printf("Keyword: %s\n",yytext); }
"else if"			{ printf("Keyword: %s\n",yytext); }
"else"				{ printf("Keyword: %s\n",yytext); }
"enum"				{ printf("Keyword: %s\n",yytext); }
"extern"			{ printf("Keyword: %s\n",yytext); }
"float"				{ printf("Keyword: %s\n",yytext); }
"for"				{ printf("Keyword: %s\n",yytext); }
"goto"				{ printf("Keyword: %s\n",yytext); }
"if"				{ printf("Keyword: %s\n",yytext); }
"inline"			{ printf("Keyword: %s\n",yytext); }
"int"				{ printf("Keyword: %s\n",yytext); }
"long"				{ printf("Keyword: %s\n",yytext); }
"register"			{ printf("Keyword: %s\n",yytext); }
"restrict"			{ printf("Keyword: %s\n",yytext); }
"return"			{ printf("Keyword: %s\n",yytext); }
"short"				{ printf("Keyword: %s\n",yytext); }
"signed"			{ printf("Keyword: %s\n",yytext); }
"sizeof"			{ printf("Keyword: %s\n",yytext); }
"static"			{ printf("Keyword: %s\n",yytext); }
"struct"			{ printf("Keyword: %s\n",yytext); }
"switch"			{ printf("Keyword: %s\n",yytext); }
"typedef"			{ printf("Keyword: %s\n",yytext); }
"union"				{ printf("Keyword: %s\n",yytext); }
"unsigned"			{ printf("Keyword: %s\n",yytext); }
"void"				{ printf("Keyword: %s\n",yytext); }
"volatile"			{ printf("Keyword: %s\n",yytext); }
"while" 			{ printf("Keyword: %s\n",yytext); } 


{identifier} { printf("Identifier: %s\n",yytext); insert( symbol_table,yytext,IDENTIFIER );}


#(include(" ")*<[a-zA-Z\.]*>|define) {printf("Pre Processor: %s\n",yytext);}


"//".* 						{printf("Single line comment: %s \n",yytext);}
"/*"                        {beginning = yylineno; BEGIN comment;}
<comment>.|{whitespace}     {}                 ;
<comment>\n                 {yylineno++;}
<comment>"*/"               {BEGIN INITIAL;}
<comment>"/*"               {printf("Line %3d: Nested comments are not valid!\n",yylineno);}
<comment><<EOF>> 			{printf("Line %3d: Unterminated comment\n", beginning); yyterminate();}

{whitespace}				{}
[+\-]?[0][x|X]{hex}+		{printf("Hex: %s\n", yytext); insert( constant_table,yytext,HEX_CONSTANT);}				
[+\-]?{digit}+				{printf("Constant: %s\n", yytext); insert( constant_table,yytext,DEC_CONSTANT);}
\"(\\.|[^"\\])*\"			{printf("String literal :%s\n",yytext);}
		
\n 		{yylineno++;}

"--"	{printf("Punctuator: %s\n",yytext);}
"++"	{printf("Punctuator: %s\n",yytext);}
"->"	{printf("Punctuator: %s\n",yytext);}
"&&"	{printf("Punctuator: %s\n",yytext);}
"||"	{printf("Punctuator: %s\n",yytext);}
"<="	{printf("Punctuator: %s\n",yytext);}
">="	{printf("Punctuator: %s\n",yytext);}
"=="	{printf("Punctuator: %s\n",yytext);}
"!="	{printf("Punctuator: %s\n",yytext);}
";"		{printf("Punctuator: %s\n",yytext);}
"{"     {printf("Punctuator: %s\n",yytext);}
"}"     {printf("Punctuator: %s\n",yytext);}
","		{printf("Punctuator: %s\n",yytext);}
"="		{printf("Punctuator: %s\n",yytext);}
"("		{printf("Punctuator: %s\n",yytext);}
")"		{printf("Punctuator: %s\n",yytext);}
"["     {printf("Punctuator: %s\n",yytext);}
"]"     {printf("Punctuator: %s\n",yytext);}
"-"		{printf("Punctuator: %s\n",yytext);}
"+"		{printf("Punctuator: %s\n",yytext);}
"*"		{printf("Punctuator: %s\n",yytext);}
"/"		{printf("Punctuator: %s\n",yytext);}
"%"		{printf("Punctuator: %s\n",yytext);}
"<"		{printf("Punctuator: %s\n",yytext);}
">"		{printf("Punctuator: %s\n",yytext);}


.	{printf("Line %3d: Illegal character %s\n",yylineno,yytext);}

%%

/*
int yywrap()
{
	return 0;
}
*/


int main(int argc,char **argv)
{
	
	if(argc>1)
	{
		yyin = fopen(argv[1],"r");
		
	}
	else
	{
		printf("Please enter an input file!\n");
	}
	symbol_table=create_table();
  	constant_table=create_table();
  	yylex();
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
	//fclose(yyin);

}