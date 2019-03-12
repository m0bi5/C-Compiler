letter 		[A-Za-z_]

digit 		[0-9]
whitespace	[ \t\r\f\v]+
identifier 	(_|{letter})({letter}|{digit}|_)* 
hex 		[0-9a-f]

%{
int yylineno,beginning;

#include <stdio.h>
%}

%x comment string

%%

"/*"                        {beginning = yylineno; BEGIN comment;}
<comment>.|{whitespace}     {}
<comment>"\n"               {yylineno++;}
<comment>"*/"               {BEGIN INITIAL;}
<comment>"/*"               {printf("Line %d: Nested comments are not valid!\n",yylineno);}
<comment><<EOF>> 			{printf("Line %d: Unterminated comment\n", beginning); }

"//".* 						{printf("Single line comment: %s \n",yytext);}

"#include<"({letter})*".h>" {}
"#define"({whitespace})""({letter})""({letter}|{digit})*""({whitespace})""({digit})+"" 					{}
"#define"({whitespace})""({letter}({letter}|{digit})*)""({whitespace})""(({digit}+)\.({digit}+))"" 		{}
"#define"({whitespace})""({letter}({letter}|{digit})*)""({whitespace})""({letter}({letter}|{digit})*)"" {}

\"[^\n]*\" 									{ yylval = yytext; return STRING_CONSTANT; }
\'{letter}\' 								{ yylval = yytext; return CHAR_CONSTANT; }
{digit}+    								{ yylval = yytext; return INT_CONSTANT; strcpy(latest_int,yytext);}
({digit}+)\.({digit}+) 						{ yylval = yytext; return FLOAT_CONSTANT; }
({digit}+)\.({digit}+)([eE][-+]?[0-9]+)? 	{ yylval = yytext; return FLOAT_CONSTANT; }
[+\-]?[0][x|X]{hex}+						{ yylval = yytext; return HEX_CONSTANT; }

"sizeof"		{ return SIZEOF; }
"char"			{ yylval = yytext; return CHAR; }
"short"			{ yylval = yytext; return SHORT; }
"int"			{ yylval = yytext; return INT; }
"long"			{ yylval = yytext; return LONG; }
"signed"		{ yylval = yytext; return SIGNED; }
"unsigned"		{ yylval = yytext; return UNSIGNED; }
"void"			{ yylval = yytext; return VOID; }
"if"			{ return IF; }
"else"			{ return ELSE; }
"while"			{ return WHILE; }
"break"			{ return BREAK; }
"return"		{ return RETURN; }
"continue"		{ return CONTINUE; }
"float"			{ return FLOAT; }
"auto"			{ return AUTO; }
"const"			{ return CONST; }
"double"		{ return DOUBLE; }
"extern"		{ return EXTERN; }
"register"		{ return REGISTER; }
"static"		{ return STATIC; }
"inline"		{ return INLINE; }
"typedef"		{ return TYPEDEF; }
"else if"		{ return ELSE_IF; }
"goto"			{ return GOTO; }
"do"			{ return DO; }
"for"			{ return FOR; }
"case"			{ return CASE; } 
"switch"		{ return SWITCH; }
"default"		{ return DEFAULT; }

"++"			{  return INC_OP; }
"--"			{  return DEC_OP; }
"<="			{  return LE_OP; }
">="			{  return GE_OP; }
"=="			{  return EQ_OP; }
"!="			{  return NE_OP; }
"&&"			{  return AND_OP; }
"||"			{  return OR_OP; }
";"				{  return(';'); }
("{")			{  return('{'); }
("}")			{  return('}'); }
","				{  return(','); }
":"				{  return(':'); } /*extra added*/
"="				{  return('='); }
"("				{  return('('); }
")"				{  return(')'); }
("["|"<:")		{  return('['); } 
("]"|":>")		{  return(']'); }
"&"				{  return('&'); } /*extra added*/
"-"				{  return('-'); }
"+"				{  return('+'); }
"*"				{  return('*'); }
"/"				{  return('/'); }
"%"				{  return('%'); }
"<"				{  return('<'); }
">"				{  return('>'); }
"^"				{  return('^'); } /*extra added*/
"|"				{  return('|'); } /*extra added*/
"?"				{  return('?'); } /*extra added*/

{identifier} {
	strcpy(identifier_name,yytext);
	if (strlen(yytext)>32)
		printf("Error: Identifier too long\n"); 
	else{	
		printf("Identifier: %s\n",yytext ); 
		yylval = yytext;
		return IDENTIFIER;
	}
}


\n  		{ yylineno++; }
[ \t\v\f]	{}
.			{}
%%
yywrap()
{
	return(1);
}
