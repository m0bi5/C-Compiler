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

int comment = 0;
int beginning=0;

%}

letter 		[a-zA-Z]
digit 		[0-9]
whitespace	[ \t\r\f\v]+
identifier 	(_|{letter})({letter}|{digit}|_)* 
hex 		[0-9a-f]

%x comment string

%%


#(include(" ")*<[a-zA-Z\.]*>|define) {printf("Pre Processor: %s\n",yytext);}

"auto"				{ printf("Keyword: %s\n",yytext); return AUTO;}
"break"				{ printf("Keyword: %s\n",yytext); return BREAK;}
"case"				{ printf("Keyword: %s\n",yytext); return CASE;}
"char"				{ printf("Keyword: %s\n",yytext); return CHAR;}
"const"				{ printf("Keyword: %s\n",yytext); return CONST;}
"continue"			{ printf("Keyword: %s\n",yytext); return CONTINUE;}
"default"			{ printf("Keyword: %s\n",yytext); return DEFAULT;}
"do"				{ printf("Keyword: %s\n",yytext); return DO;}
"double"			{ printf("Keyword: %s\n",yytext); return DOUBLE;}
"else if"			{ printf("Keyword: %s\n",yytext); return ELSE_IF;}
"else"				{ printf("Keyword: %s\n",yytext); return ELSE;}
"enum"				{ printf("Keyword: %s\n",yytext); return ENUM;}
"extern"			{ printf("Keyword: %s\n",yytext); return EXTERN;}
"float"				{ printf("Keyword: %s\n",yytext); return FLOAT;}
"for"				{ printf("Keyword: %s\n",yytext); return FOR;}
"goto"				{ printf("Keyword: %s\n",yytext); return GOTO;}
"if"				{ printf("Keyword: %s\n",yytext); return IF;}
"inline"			{ printf("Keyword: %s\n",yytext); return INLINE;}
"int"				{ printf("Keyword: %s\n",yytext); return INT;}
"long"				{ printf("Keyword: %s\n",yytext); return LONG;}
"register"			{ printf("Keyword: %s\n",yytext); return REGISTER;}
"restrict"			{ printf("Keyword: %s\n",yytext); return RESTRICT;}
"return"			{ printf("Keyword: %s\n",yytext); return RETURN;}
"short"				{ printf("Keyword: %s\n",yytext); return SHORT;}
"signed"			{ printf("Keyword: %s\n",yytext); return SIGNED;}
"sizeof"			{ printf("Keyword: %s\n",yytext); return SIZEOF;}
"static"			{ printf("Keyword: %s\n",yytext); return STATIC;}
"struct"			{ printf("Keyword: %s\n",yytext); return STRUCT;}
"switch"			{ printf("Keyword: %s\n",yytext); return SWITCH;}
"typedef"			{ printf("Keyword: %s\n",yytext); return TYPEDEF;}
"union"				{ printf("Keyword: %s\n",yytext); return UNION;}
"unsigned"			{ printf("Keyword: %s\n",yytext); return UNSIGNED;}
"void"				{ printf("Keyword: %s\n",yytext); return VOID;}
"volatile"			{ printf("Keyword: %s\n",yytext); return VOLATILE;}
"while" 			{ printf("Keyword: %s\n",yytext); return WHILE;} 


{identifier} {
	if (strlen(yytext)>32)
		printf("Error: Identifier too long\n"); 
		else
		{	
		printf("Identifier: %s\n",yytext ); 
	}
	return IDENTIFIER;
}




"//".* 						{printf("Single line comment: %s \n",yytext);}
"/*"                        {beginning = yylineno; BEGIN comment;}
<comment>.|{whitespace}     {}                 ;
<comment>\n                 {yylineno++;}
<comment>"*/"               {BEGIN INITIAL;}
<comment>"/*"               {printf("Line %d: Nested comments are not valid!\n",yylineno);}
<comment><<EOF>> 			{printf("Line %d: Unterminated comment\n", beginning); yyterminate();}

{whitespace}					{}
[+\-]?[0][x|X]{hex}+			{printf("Hex: %s\n", yytext); return HEX_CONSTANT;}	
[+\-]?({digit}+[.]){1}{digit}+  {printf("Decimal Constant: %s\n", yytext); return FLOAT_CONSTANT;}
[+\-]?{digit}+					{printf("Integer Constant: %s\n", yytext); return INT_CONSTANT;}

\"([^"\\\n]|\\.)*\"			{printf("String constant : %s\n",yytext); return STRING_CONSTANT;}
\"							{printf("Line %d: Unterminated string constant\n",yylineno);yyterminate();}


'([^'\\\n]|\\.)'			{printf("Character constant : %s\n",yytext);return CHAR_CONSTANT;}
'([^'\\\n]|\\.)+'			{printf("Line %d: Character constant length exceeded\n",yylineno);yyterminate();}
'							{printf("Line %d: Unterminated character constant\n",yylineno);yyterminate();}

\n 		{yylineno++;}

"--"	{printf("Punctuator: %s\n",yytext); return DEC_OP;}
"++"	{printf("Punctuator: %s\n",yytext); return INC_OP;}
"&&"	{printf("Punctuator: %s\n",yytext); return AND_OP;}
"||"	{printf("Punctuator: %s\n",yytext); return OR_OP;}
"<="	{printf("Punctuator: %s\n",yytext); return LE_OP;} 
">="	{printf("Punctuator: %s\n",yytext); return GE_OP;}
"=="	{printf("Punctuator: %s\n",yytext); return EQ_OP;}
"!="	{printf("Punctuator: %s\n",yytext); return NE_OP;}
";"		{printf("Punctuator: %s\n",yytext); return (';');} 
"{"     {printf("Punctuator: %s\n",yytext); return ('{');}  
"}"     {printf("Punctuator: %s\n",yytext); return ('}');}
","		{printf("Punctuator: %s\n",yytext); return (',');}
"="		{printf("Punctuator: %s\n",yytext); return ('=');}
"("		{printf("Punctuator: %s\n",yytext); return ('(');}
")"		{printf("Punctuator: %s\n",yytext); return (')');}  
"["     {printf("Punctuator: %s\n",yytext); return ('[');}
"]"     {printf("Punctuator: %s\n",yytext); return (']');}
"-"		{printf("Punctuator: %s\n",yytext); return ('-');}
"+"		{printf("Punctuator: %s\n",yytext); return ('+');}
"*"		{printf("Punctuator: %s\n",yytext); return ('*');}
"/"		{printf("Punctuator: %s\n",yytext); return ('/');}
"%"		{printf("Punctuator: %s\n",yytext); return ('%');}
"<"		{printf("Punctuator: %s\n",yytext); return ('<');}
">"		{printf("Punctuator: %s\n",yytext); return ('>');} 
"^"		{printf("Punctuator: %s\n",yytext); return ('^');} 
"|"		{printf("Punctuator: %s\n",yytext); return ('|');} 
"&"		{printf("Punctuator: %s\n",yytext); return ('&');} 


.	{printf("Line %3d: Illegal character %s\n",yylineno,yytext);}

%%

