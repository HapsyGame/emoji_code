#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void main() {
float Variable;
Variable = 7;
float float_test;
float_test = 5.26;
char String_2[1000];
strcpy(String_2,"piece");
strcpy(String_2,"piecess");
float New_Variable;
New_Variable = 7.260000;
strcpy(String_2,"piecessss");
printf("%g", Variable);printf("\n");
printf("%g", float_test);printf("\n");
printf("%s", String_2);printf("\n");
Variable--;
float_test++;
printf(" PASS %g", New_Variable);printf(" \n");
if(strcmp(String_2,"piecessss") == 0)
{
printf("good %g", Variable);printf("\n");
Variable--;
if(Variable == 5)
{
printf("bad %g", Variable);printf(" \n");
Variable--;
if(Variable == 5)
{
printf("if if if\n");
}
else
{
printf("ok\n");
}
}
}
printf("Il a %g", Variable);printf(" euros en ");printf("%s", String_2);printf(" sur lui ! aaa\n");
float var;
var = 15;
while(var >= 1)
{
printf("Var : %g", var);printf(" + ");printf("%g", Variable);printf("\n");
var--;
while(Variable < 10)
{
printf("AHHH : %g", Variable);printf("\n");
Variable++;
}
}
for(int i = 1;i <= 5;i++)
{
printf("hello\n");
}
if(strcmp(String_2,"piece") == 0)
{
printf("VRAI\n");
}
float variable;
variable = 1;
char text[1000];
strcpy(text,"hapsint");
variable++;
for(int i = 0;i < 100;i++)
{
printf("Il y a %g", variable);printf(" de ");printf("%s", text);printf("\n");
variable++;
}
printf("\n➥ ✅ PROGRAM VALIDE\n");printf("\n");}
