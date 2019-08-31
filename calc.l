%{
#include <stdio.h>
#include "ftypes.h"

#define YY_DECL int yylex()

#include "calc.tab.h"

#define YY_NULL 0
#ifndef _WIN32
#include <editline/readline.h>
#include <readline/history.h>
#undef YY_INPUT
#define YY_INPUT(buf, result, max_size) result = getInput(buf, max_size);

static int getInput(char *buf, int size) 
  {
    char *line;
    if (feof(yyin))
    {  
        return YY_NULL;
    }

    line = readline("> ");

    if(!line)
    {
        return YY_NULL;
    }

    if(strlen(line) > size-2)
    {
       fprintf(stderr,"input line too long\n"); 
       return YY_NULL; 
    }

    sprintf(buf,"%s\n",line);

    add_history(line);
    free(line);
    return strlen(buf);
  }
#endif 

%}
%option nounput
%option noinput
%option noyywrap
%%
[a-z] {yylval.ival = *yytext - 'a';return T_VAR;}
[ \t]   ; // ignore all whitespace
[0-9]+\.[0-9]+  {yylval.fval = atof(yytext); return T_FLOAT;}
[0-9]+      {yylval.ival = atoi(yytext); return T_INT;}
true    {yylval.bval = TRUE; return T_BOOL;}
false   {yylval.bval = FALSE; return T_BOOL;}
\n      {return T_NEWLINE;}
"if"    {return T_IF;}
"else"  {return T_ELSE;}
"**"    {return T_EXPO;}
"+"     {return T_PLUS;}
"-"     {return T_MINUS;}
"*"     {return T_MULTIPLY;}
"/"     {return T_DIVIDE;}
"("     {return T_LEFT;}
")"     {return T_RIGHT;}
"{"     { return T_OPENBLOCK;}
"}"     { return T_CLOSEBLOCK;}
"||"    {return T_OR;}
"&&"    {return T_AND;}
"!"     {return T_NOT;}
"=" {return T_ASMNT;}
"=="    {return T_EQUALITY;}
"!="    {return T_NOTEQUAL;}
"exit"  {return T_QUIT;}
"quit"  {return T_QUIT;}
%%
