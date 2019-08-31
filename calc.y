%{

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "ftypes.h"

extern int yylex();
extern int yyparse();
extern FILE* yyin;

#define BOOLEVAL(X) printf("\tResult: %s\n", X == TRUE ? "TRUE" : "FALSE")
#define INTEVAL(X) printf("\tResult: %i\n", X)
#define FLOATEVAL(X) printf("\tResult: %f\n", X)

void yyerror(const char* s);
float sym[26];
%}

%union {
    int ival;
    float fval;
    BOOL bval;
}
%token<ival> T_INT
%token<fval> T_FLOAT
%token<bval> T_BOOL
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_LEFT T_RIGHT 
%token T_OR T_AND T_EQUALITY T_NOTEQUAL T_NOT T_IF T_ELSE
%token T_ASMNT T_NEWLINE T_QUIT T_OPENBLOCK T_CLOSEBLOCK
%token<ival> T_VAR
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE
%right T_EXPO

%type<ival> expression
%type<fval> mixed_expression
%type<bval> bool_expression
%start calculation

%%

calculation: 
       | calculation line
;

line: T_NEWLINE
    | mixed_expression T_NEWLINE { FLOATEVAL($1);}
    | expression T_NEWLINE { INTEVAL($1); } 
    | bool_expression T_NEWLINE { BOOLEVAL($1);}
    | if_expression T_NEWLINE {printf("done\n");}
    | T_QUIT T_NEWLINE { printf("bye!\n"); exit(0); }
;

if_expression : T_IF
    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  expression       T_CLOSEBLOCK    {  if($3) INTEVAL($6);}
    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  mixed_expression T_CLOSEBLOCK    {  if($3) FLOATEVAL($6);}
    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  bool_expression  T_CLOSEBLOCK    {  if($3) BOOLEVAL($6);}

    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  expression       T_CLOSEBLOCK T_ELSE T_OPENBLOCK  expression T_CLOSEBLOCK    {  if($3) { INTEVAL($6);  } else {INTEVAL($10);} }
    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  mixed_expression T_CLOSEBLOCK T_ELSE T_OPENBLOCK  expression T_CLOSEBLOCK    {  if($3) { FLOATEVAL($6);} else {INTEVAL($10);} }
    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  bool_expression  T_CLOSEBLOCK T_ELSE T_OPENBLOCK  expression T_CLOSEBLOCK    {  if($3) { BOOLEVAL($6); } else {INTEVAL($10);} }

    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  expression       T_CLOSEBLOCK T_ELSE T_OPENBLOCK  mixed_expression T_CLOSEBLOCK  {  if($3) { INTEVAL($6);  } else {FLOATEVAL($10);} }
    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  mixed_expression T_CLOSEBLOCK T_ELSE T_OPENBLOCK  mixed_expression T_CLOSEBLOCK  {  if($3) { FLOATEVAL($6);} else {FLOATEVAL($10);} }
    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  bool_expression  T_CLOSEBLOCK T_ELSE T_OPENBLOCK  mixed_expression T_CLOSEBLOCK  {  if($3) { BOOLEVAL($6); } else {FLOATEVAL($10);} }

    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  expression       T_CLOSEBLOCK T_ELSE T_OPENBLOCK  bool_expression  T_CLOSEBLOCK  {  if($3) { INTEVAL($6);  } else {BOOLEVAL($10);} }
    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  mixed_expression T_CLOSEBLOCK T_ELSE T_OPENBLOCK  bool_expression  T_CLOSEBLOCK  {  if($3) { FLOATEVAL($6);} else {BOOLEVAL($10);} }
    | T_IF T_LEFT bool_expression T_RIGHT T_OPENBLOCK  bool_expression  T_CLOSEBLOCK T_ELSE T_OPENBLOCK  bool_expression  T_CLOSEBLOCK  {  if($3) { BOOLEVAL($6); } else {BOOLEVAL($10);} }
;

bool_expression : T_BOOL                        { $$ = $1; }
    | T_VAR                                     { $$ = sym[$1]; }
    | T_VAR T_ASMNT bool_expression             { sym[$1] = $3 ? 1 : 0; $$ = sym[$1];};
    | T_LEFT bool_expression T_RIGHT            { $$ = $2; }
    | bool_expression  T_OR bool_expression     { $$ = $1 || $3; }
    | bool_expression  T_OR expression          { $$ = $1 || $3; }
    | bool_expression  T_OR mixed_expression    { $$ = $1 || $3; }
    | mixed_expression T_OR mixed_expression    { $$ = $1 || $3; }
    | mixed_expression T_OR expression          { $$ = $1 || $3; }
    | mixed_expression T_OR bool_expression     { $$ = $1 || $3; }
    | expression       T_OR expression          { $$ = $1 || $3; }
    | expression       T_OR mixed_expression    { $$ = $1 || $3; }
    | expression       T_OR bool_expression     { $$ = $1 || $3; }
    
    
    | bool_expression  T_AND bool_expression    { $$ = $1 && $3; }
    | bool_expression  T_AND expression         { $$ = $1 && $3; }
    | bool_expression  T_AND mixed_expression   { $$ = $1 && $3; }
    | mixed_expression T_AND mixed_expression   { $$ = $1 == $3; }
    | mixed_expression T_AND expression         { $$ = $1 && $3; }
    | mixed_expression T_AND bool_expression    { $$ = $1 && $3; }
    | expression       T_AND expression         { $$ = $1 == $3; }
    | expression       T_AND mixed_expression   { $$ = $1 && $3; }
    | expression       T_AND bool_expression    { $$ = $1 && $3; }
    
    | bool_expression  T_EQUALITY bool_expression   { $$ = $1 == $3; }
    | bool_expression  T_EQUALITY expression        { $$ = $1 == $3; }
    | bool_expression  T_EQUALITY mixed_expression  { $$ = $1 == $3; }
    | mixed_expression T_EQUALITY mixed_expression  { $$ = $1 == $3; }
    | mixed_expression T_EQUALITY expression        { $$ = $1 == $3; }
    | mixed_expression T_EQUALITY bool_expression   { $$ = $1 == $3; }
    | expression       T_EQUALITY expression        { $$ = $1 == $3; }
    | expression       T_EQUALITY mixed_expression  { $$ = $1 == $3; }
    | expression       T_EQUALITY bool_expression   { $$ = $1 == $3; }
    
    | bool_expression  T_NOTEQUAL bool_expression   { $$ = $1 != $3; }
    | bool_expression  T_NOTEQUAL expression        { $$ = $1 != $3; }
    | bool_expression  T_NOTEQUAL mixed_expression  { $$ = $1 != $3; }
    | mixed_expression T_NOTEQUAL mixed_expression  { $$ = $1 != $3; }
    | mixed_expression T_NOTEQUAL expression        { $$ = $1 != $3; }
    | mixed_expression T_NOTEQUAL bool_expression   { $$ = $1 != $3; }
    | expression       T_NOTEQUAL expression        { $$ = $1 != $3; }
    | expression       T_NOTEQUAL mixed_expression  { $$ = $1 != $3; }
    | expression       T_NOTEQUAL bool_expression   { $$ = $1 != $3; }
    

    | T_NOT mixed_expression                        { $$ = !$2; }
    | T_NOT expression                              { $$ = !$2; }
    | T_NOT bool_expression                         { $$ = !$2; }
;



mixed_expression : T_FLOAT                           { $$ = $1; }
      | T_VAR                                        { $$ = sym[$1]; }
      | T_VAR T_ASMNT mixed_expression               { sym[$1] = $3; $$ = sym[$1];};
      | T_MINUS mixed_expression                     { $$ = -$2; }
      | mixed_expression T_PLUS mixed_expression     { $$ = $1 + $3; }
      | mixed_expression T_MINUS mixed_expression    { $$ = $1 - $3; }
      | mixed_expression T_MULTIPLY mixed_expression { $$ = $1 * $3; }
      | mixed_expression T_DIVIDE mixed_expression   { $$ = $1 / $3; }
      | mixed_expression T_EXPO mixed_expression     { $$= pow($1, $3); }
      | T_LEFT mixed_expression T_RIGHT              { $$ = $2; }
      | expression T_PLUS mixed_expression           { $$ = $1 + $3; }
      | expression T_MINUS mixed_expression          { $$ = $1 - $3; }
      | expression T_MULTIPLY mixed_expression       { $$ = $1 * $3; }
      | expression T_DIVIDE mixed_expression         { $$ = $1 / $3; }
      | expression T_EXPO mixed_expression           { $$ = pow($1, $3); }
      | mixed_expression T_PLUS expression           { $$ = $1 + $3; }
      | mixed_expression T_MINUS expression          { $$ = $1 - $3; }
      | mixed_expression T_MULTIPLY expression       { $$ = $1 * $3; }
      | mixed_expression T_DIVIDE expression         { $$ = $1 / $3; }
      | mixed_expression T_EXPO expression           { $$ = pow($1, (float) $3);}
      | expression T_DIVIDE expression               { $$ = $1 / (float)$3; }
      | expression T_EXPO expression                 { $$ = pow((float) $1, (float) $3); }
;


expression: T_INT                        { $$ = $1; }
      | T_VAR                            { $$ = (int) sym[$1]; }
      | T_VAR T_ASMNT expression         { sym[$1] = (float) $3; $$ = (int) sym[$1];};
      | T_MINUS expression               { $$ = -$2; }
      | expression T_PLUS expression     { $$ = $1 + $3; }
      | expression T_MINUS expression    { $$ = $1 - $3; }
      | expression T_MULTIPLY expression { $$ = $1 * $3; }
      | T_LEFT expression T_RIGHT        { $$ = $2; }
;

%%

int main() {
    yyin = stdin;

    do { 
        yyparse();
    } while(!feof(yyin));

    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
