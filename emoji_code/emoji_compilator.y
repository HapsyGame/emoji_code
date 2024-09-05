%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdbool.h>

	#define MAX_VARIABLES 100 
	struct { char *name; char *value; int type; } variables[MAX_VARIABLES];
	struct { char *name; } list_print[MAX_VARIABLES]; struct { char *name; } list_print_middle[MAX_VARIABLES];
	int var_count = 0; int var_print_count = 0;
	int type;
	bool first = 0; bool take = 0;

	char *random_a, *random_b;

	extern int yylex(void);
	extern FILE *yyin;

	void set_variable(const char *name, const char *value, int type), set_print_variable(const char *name), set_print_middle_variable(const char *name);
	char *get_variable(const char *name); int get_type(const char *name);
	char* remove_trailing_quote(char *str); char* remove_leading_quote(char *str);

	void verif_string(char *name); void verif_float(char *name);

	char calculator[10000]; char line[10000] = "";

	void yyerror(const char *s);
	short error;

	extern int line_num; char msg_error[100] = "Unknow";

	void eval_code();
%}

%union 
{
	char *variable, *value, *text;
	int line_num;
}

/*
//* ----- TOKEN -----
*/

%token <variable> VARIABLE
%token <value> STRING FLOAT
%token <text> TEXT_PRINT TEXT_PRINT_END TEXT_PRINT_MIDDLE TAKE_EMOJI
%token EQUAL PLUS MINUS TIMES OVER COMMA BRACKET_OPEN BRACKET_CLOSE PAREN_OPEN PAREN_CLOSE EOL QUOTE FLOAT_EMOJI STRING_EMOJI

%token PRINT_EMOJI PLUS_EMOJI MINUS_EMOJI EQUAL_EMOJI RANDOM_EMOJI OPEN_EMOJI CLOSE_EMOJI
%token IF_EMOJI ELSE_EMOJI WHILE_EMOJI FOR_EMOJI SUP_EMOJI INF_EMOJI LINK_EMOJI

%type <value> print print_follow calcul comparaison

%left PLUS MINUS
%left TIMES OVER

/*
//* ----- RULE SECTION -----
*/

%%

code 	:
		| code line
		;

line 	: EOL
		| VARIABLE EQUAL calcul
			{	
				if (first == 1) printf(";\n");
				set_variable($1,$3, type);
				if (first == 1) {
									if(type == 0) { printf("%s = temp_8008_0;\n",$1); }
									if(type == 1) { printf("strcpy(%s,temp_8008_1);\n",$1); }
									first=0;
								}
				else {
					if (take == 0)
					{
						if (type == 0 && get_type($1) == 0) printf("%s = %s;\n",$1,$3); 
						else if (type == 1 && get_type($1) == 1) printf("strcpy(%s,%s);\n",$1,$3);
						else if (type == 5 && get_type($1) == 0) printf("%s = rand() %% %s + %s;\n",$1,random_b,random_a);
						// printf("%s = %s + (float)rand() / RAND_MAX * (%s - %s);\n",$1,random_a,random_b,random_a);
						else {snprintf(msg_error,sizeof(msg_error),"🫥  Variable \"%s\" already define",$1); yyerror(msg_error); exit(0);}
					} else
					{
						if (type == 0 && get_type($1) == 0)
							{
								printf("%s = strtof(temp_8008_take_input, &temp_8008_take_endptr);\n",$1);
								printf("if(*temp_8008_take_endptr != \'\\0\') {printf(\"\\n➥ ⛔ PROGRAM ERROR at line %d : 🤬 Need float !\\n\");printf(\"\\n\");exit(0);}\n",line_num-1);
							}
						else if (type == 1 && get_type($1) == 1) 
							{
								printf("strcpy(%s,temp_8008_take_input);\n",$1);
							}
						else {snprintf(msg_error,sizeof(msg_error),"🫥  Variable \"%s\" already define",$1); yyerror(msg_error); exit(0);}
						take = 0;
					}
				}
			} EOL
		| VARIABLE PLUS_EMOJI
			{
				snprintf(calculator, sizeof(calculator), "%f", atof(get_variable($1)) + 1);
				set_variable($1,calculator, type); printf("%s++;\n",$1);
			} EOL
		| VARIABLE MINUS_EMOJI
			{
				snprintf(calculator, sizeof(calculator), "%f", atof(get_variable($1)) - 1);
				set_variable($1,calculator, type); printf("%s--;\n",$1);
			} EOL
        | PRINT_EMOJI print { snprintf(line,sizeof(line),"%s",""); } EOL
		| IF_EMOJI {printf("if(");} PAREN_OPEN comparaison PAREN_CLOSE {printf(")\n");} EOL if_block else_block 
		| WHILE_EMOJI {printf("while(");} while_block
		| FOR_EMOJI {printf("for(");} for_block
		;

for_block	: PAREN_OPEN VARIABLE EQUAL calcul
				{
					set_variable($2,$4, 4); printf("int %s = %s",$2,$4); 
				}
			  LINK_EMOJI {printf(";");} comparaison LINK_EMOJI {printf(";");} for_calcul PAREN_CLOSE {printf(")");} EOL {printf("\n");}
			  OPEN_EMOJI {printf("{\n");} code CLOSE_EMOJI {printf("}\n");} EOL
			;

for_calcul	: VARIABLE EQUAL calcul
				{ 
					set_variable($1,$3, type); // ATTENTION SI NOUVELLE VARIABLE ALORS FAUX !
				}
			| VARIABLE PLUS_EMOJI
				{
					snprintf(calculator, sizeof(calculator), "%f", atof(get_variable($1)) + 1);
					set_variable($1,calculator, type); printf("%s++",$1);
				}
			| VARIABLE MINUS_EMOJI
				{
					snprintf(calculator, sizeof(calculator), "%f", atof(get_variable($1)) - 1);
					set_variable($1,calculator, type); printf("%s--",$1);
				}
			;

while_block	: PAREN_OPEN comparaison PAREN_CLOSE {printf(")");} EOL {printf("\n");}
			  OPEN_EMOJI {printf("{\n");} code CLOSE_EMOJI {printf("}\n");} EOL
			;


if_block	: OPEN_EMOJI {printf("{\n");} code CLOSE_EMOJI EOL {printf("}\n");}
			;

else_block	:
			| ELSE_EMOJI {printf("else\n");} EOL OPEN_EMOJI {printf("{\n");} code CLOSE_EMOJI {printf("}\n");} EOL
			;

print   : TEXT_PRINT { printf("printf(\"%s\\n\");\n",$1); }
		| TEXT_PRINT BRACKET_OPEN VARIABLE print_follow TEXT_PRINT_END  
			{
				char *value = get_variable($3);
				if (value) {
					
					// if (get_type ($3) == 0) printf("printf(\"%s%%f%s%s\\n\", %s);\n", $1, $4, $5, $3);
					// if (get_type ($3) == 1) printf("printf(\"%s%%s%s%s\\n\", %s);\n", $1, $4, $5, $3);

					if (get_type ($3) == 0) printf("printf(\"%s%%g\", (float) %s);", $1, $3);
					if (get_type ($3) == 1) printf("printf(\"%s%%s\", %s);", $1, $3);

					for (int i = 0; i < var_print_count; i++)
					{
						// printf(" <%s> (%d) ",list_print_middle[i].name,var_print_count);
						printf("printf(\"%s\");", list_print_middle[i].name);
						if (get_type (list_print[i].name) == 0) printf("printf(\"%%g\", (float) %s);", list_print[i].name);
						if (get_type (list_print[i].name) == 1) printf("printf(\"%%s\", %s);", list_print[i].name);
					}
					printf("printf(\"%s\\n\");\n", $5);

				} else {
					// printf("printf(\"%s(undefined variable: %s)%s%s\\n\");\n", $1, $3, $4, $5);
				}
				var_print_count=0;
			}
        ;

print_follow	: { $$ = strdup(""); }
				| print_follow TEXT_PRINT_MIDDLE VARIABLE 
					{ 
						set_print_middle_variable($2);
						set_print_variable($3);
					}
				;

calcul	: calcul PLUS calcul { 
								if(type == 0) {
									if(first==0) {printf("temp_8008_0 = %s",$1);first=1;} printf(" + %s",$3);
									verif_float($1); verif_float($3);
								}
								if(type == 1) {
									if(first==0) {printf("strcpy(temp_8008_1,%s);",$1);first=1;} printf("strcat(temp_8008_1,%s);",$3);
									verif_string($1); verif_string($3);
								}

							 }
		| calcul MINUS calcul { if(first==0) {printf("temp_8008_0 = %s",$1);first=1;} printf(" - %s",$3); }
		| calcul TIMES calcul { if(first==0) {printf("temp_8008_0 = %s",$1);first=1;} printf(" * %s",$3); }
		| calcul OVER calcul { if(first==0) {printf("temp_8008_0 = %s",$1);first=1;} printf(" / %s",$3); }
		| FLOAT { $$ = strdup($1); type = 0; }
		| STRING { $$ = strdup($1); type = 1; }
		| VARIABLE { $$ = strdup($1); }
		| RANDOM_EMOJI PAREN_OPEN FLOAT COMMA FLOAT PAREN_CLOSE { $$ = strdup($3); random_a = strdup($3); random_b = strdup($5); type = 5; }
		| TAKE_EMOJI FLOAT_EMOJI PAREN_OPEN STRING PAREN_CLOSE
			{
				take = 1;
				printf("printf(%s);",$4);
				printf("scanf(\"%%s\", temp_8008_take_input);"); type = 0;
			}
		| TAKE_EMOJI STRING_EMOJI PAREN_OPEN STRING PAREN_CLOSE
			{
				take = 1;
				printf("printf(%s);",$4);
				printf("scanf(\"%%s\", temp_8008_take_input);"); type = 1;
			}
		;

comparaison	: VARIABLE EQUAL_EMOJI calcul
				{
					// type = 
					if (get_type($1) == 0 && get_type($3) == 0) printf("%s == %s",$1,$3);
					else if (get_type($1) == 1 && get_type($3) == 1) printf("strcmp(%s,%s) == 0",$1,$3);
					else {snprintf(msg_error,sizeof(msg_error),"Cannot compare 🟰"); yyerror(msg_error); exit(0);}
					get_variable($1);
				}
			| VARIABLE SUP_EMOJI calcul
				{
					if(get_type($1) != 0) {snprintf(msg_error,sizeof(msg_error),"Cannot compare 💪 with string"); yyerror(msg_error); exit(0);}
					if(get_type($3) != 0) {snprintf(msg_error,sizeof(msg_error),"Cannot compare 💪 with string"); yyerror(msg_error); exit(0);}
					printf("%s > %s",$1,$3);get_variable($1);
				}
			| VARIABLE INF_EMOJI calcul
				{
					if(get_type($1) != 0) {snprintf(msg_error,sizeof(msg_error),"Cannot compare 🤏 with string"); yyerror(msg_error); exit(0);}
					if(get_type($3) != 0) {snprintf(msg_error,sizeof(msg_error),"Cannot compare 🤏 with string"); yyerror(msg_error); exit(0);}
					printf("%s < %s",$1,$3);get_variable($1);
				}
			| VARIABLE SUP_EMOJI EQUAL_EMOJI calcul
				{
					if(get_type($1) != 0) {snprintf(msg_error,sizeof(msg_error),"Cannot compare 💪🟰  with string"); yyerror(msg_error); exit(0);}
					if(get_type($4) != 0) {snprintf(msg_error,sizeof(msg_error),"Cannot compare 💪🟰  with string"); yyerror(msg_error); exit(0);}
					printf("%s >= %s",$1,$4);get_variable($1);
				}
			| VARIABLE INF_EMOJI EQUAL_EMOJI calcul
				{
					if(get_type($1) != 0) {snprintf(msg_error,sizeof(msg_error),"Cannot compare 🤏🟰  with string"); yyerror(msg_error); exit(0);}
					if(get_type($4) != 0) {snprintf(msg_error,sizeof(msg_error),"Cannot compare 🤏🟰  with string"); yyerror(msg_error); exit(0);}
					printf("%s <= %s",$1,$4);get_variable($1);
				}
			;

%%

//* ----- FUNCTION SECTION -----

void eval_code() {
	yyparse();
}

void set_variable(const char *name, const char *value, int type) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) {
            free(variables[i].value);
            variables[i].value = strdup(value);
            return;
        }
    }
    if (var_count < MAX_VARIABLES) {
        variables[var_count].name = strdup(name);
        variables[var_count].value = strdup(value);
		variables[var_count].type = type;
		if ( type == 0 || type == 5) printf("float %s;\n",name); 
		if ( type == 1 ) printf("char %s[1000];\n",name);
        var_count++;
    } else {
        fprintf(stderr, "Too many variables\n");
    }
}

void set_print_variable(const char *name) {
    if (var_print_count < MAX_VARIABLES) {
        list_print[var_print_count].name = strdup(name);
        var_print_count++;
    } else {
        fprintf(stderr, "Too many variables\n");
    }
}

void set_print_middle_variable(const char *name) {
	list_print_middle[var_print_count].name = strdup(name);
}

char *get_variable(const char *name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) return variables[i].value;
    }
	snprintf(msg_error,sizeof(msg_error),"🫣  Variable \"%s\" does not exist",name); yyerror(msg_error); exit(0);
    return NULL;
}

int get_type(const char *name) {
    for (int i = 0; i < var_count; i++) {
		if (strcmp(variables[i].name, name) == 0) {
			if (variables[i].type == 0 || variables[i].type == 5) return 0;
			else if (variables[i].type == 1) return 1;
		}
    }
    return 0;
}

// --- VERIF ---

void verif_string(char *name) {
    if (name[0] == '"' && name[strlen(name) - 1] == '"') {
        return;
    }

	for (int i = 0; i < var_count; i++) {
		if (strcmp(variables[i].name, name) == 0) {
			if (variables[i].type == 1) return;
		}
	}

    snprintf(msg_error,sizeof(msg_error),"🤯 Impossible"); yyerror(msg_error); exit(0);
}

void verif_float(char *name) {
	for (int i = 0; i < var_count; i++) {
		if (strcmp(variables[i].name, name) == 0) {
			if (variables[i].type == 0 || variables[i].type == 5) return;
		}
	}

    if (atof(name) != 0.0) {
		// printf("\n> PASS : %s\n", name);
        return;
    }

    snprintf(msg_error,sizeof(msg_error),"🤯 Impossible"); yyerror(msg_error); exit(0);
}

char* remove_trailing_quote(char *str) {
    size_t len = strlen(str);
    if (len > 0 && str[len - 1] == '"') {
        str[len - 1] = '\0';
    }
    return str;
}

char* remove_leading_quote(char *str) {
    if (str[0] == '"') {
        return str + 1;
    }
    return str;
}

//*  ----- MAIN -----

int main(int argc, char *argv[]) {

	FILE *file = fopen(argv[1],"r");
	if (!file) {
		perror(argv[1]);
		exit(1);
	}

	error = 0;
	yyin = file;

	printf("#include <stdio.h>\n");
	printf("#include <stdlib.h>\n");
	printf("#include <string.h>\n");
	printf("#include <time.h>\n");

	// printf("char* transform_float(float value);\n");

	printf("void main() {\n");
	printf("srand(time(NULL));\n");
	printf("float temp_8008_0;\n"); printf("char temp_8008_1[1000];\n");
	printf("char temp_8008_take_input[10000];\n"); printf("char *temp_8008_take_endptr;\n");
	// printf("printf(\"\\n📬 CODE OUTPUT\\n\");\n");
	// printf("printf(\"\\n\");");

	yyparse();

	if ( error == 1 ) exit(0);
	printf("printf(\"\\n➥ ✅ PROGRAM VALIDE\\n\");");
	// printf("\n➥ ✅ PROGRAM VALIDE\n");
	printf("printf(\"\\n\");");

	printf("}\n");
	fclose(file);
	exit(0);
}

void yyerror(const char *s) {
	fprintf(stderr,"\n➥ ⛔ PROGRAM ERROR at line %d : %s\n",line_num, s);
	fprintf(stderr,"\n");
	error = 1;
}

int yywrap() { return 1; }
