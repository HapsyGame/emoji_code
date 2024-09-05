%{
	#include "emoji_compilator.tab.h"
	#include <stdbool.h>

	bool debug = 0;
	int line_num = 1;
%}

%option noyywrap

%%

["][^"\n]*["] { if(debug) printf("DEBUG TOKEN STRING -> %s\n", yytext); yylval.value = strdup(yytext); return STRING; }

[0-9]+([.][0-9]+)? { if(debug) printf("DEBUG TOKEN FLOAT -> %s\n",yytext); yylval.value = strdup(yytext); return FLOAT; }

[A-Za-z0-9_]+	{ if(debug) printf("DEBUG TOKEN VARIABLE -> %s\n",yytext); yylval.text = strdup(yytext); return VARIABLE; }

[:][ ]*["]([^{"\n]+)?([^{])? { if(debug) printf("DEBUG TOKEN TEXT_PRINT -> %s\n", yytext);
								int count = 0;
								for(int i=1; i <= yyleng; i++) { if (yytext[i] == ' ') count++; else break; }
								if ( yytext[yyleng-1] == '"' ) yytext[yyleng - 1] = '\0';
								yylval.text = strdup(yytext+count+2);
								return TEXT_PRINT; }

[}][^{"\n]*[{] { if(debug) printf("DEBUG TOKEN TEXT_PRINT_MIDDLE -> %s\n", yytext);
				yytext[yyleng - 1] = '\0'; yylval.text = strdup(yytext + 1);
				return TEXT_PRINT_MIDDLE; }

[}][^{"\n]*["] { if(debug) printf("DEBUG TOKEN TEXT_PRINT_END -> %s\n", yytext);
				if ( yytext[yyleng-1] == '"' ) yytext[yyleng - 1] = '\0'; yylval.text = strdup(yytext + 1);
				return TEXT_PRINT_END; }

[=]	{ if(debug) printf("DEBUG TOKEN EQUAL -> =\n"); return EQUAL; }

[+]	{ if(debug) printf("DEBUG TOKEN PLUS -> +\n"); return PLUS; }

[-]	{ if(debug) printf("DEBUG TOKEN MINUS -> +\n"); return MINUS; }

[*]	{ if(debug) printf("DEBUG TOKEN TIMES -> +\n"); return TIMES; }

[/]	{ if(debug) printf("DEBUG TOKEN OVER -> +\n"); return OVER; }

[{] { if(debug) printf("DEBUG TOKEN BRACKET_OPEN -> {\n"); return BRACKET_OPEN; }

[}] { if(debug) printf("DEBUG TOKEN BRACKET_CLOSE -> }\n"); return BRACKET_CLOSE; }

[(] { if(debug) printf("DEBUG TOKEN PAREN_OPEN -> (\n"); return PAREN_OPEN; }

[)] { if(debug) printf("DEBUG TOKEN PAREN_CLOSE -> )\n"); return PAREN_CLOSE; }

[,]	{ if(debug) printf("DEBUG TOKEN COMMA -> ,\n"); return COMMA; }

[\n]	{ if(debug) printf("DEBUG TOKEN EOL\n"); line_num++; return EOL; }

[ \t]	;

[.]		{ if(debug) printf("DEBUG TOKEN QUOTE\n"); line_num++; return QUOTE; }

📨 { if(debug) printf("DEBUG TOKEN PRINT_EMOJI -> 📨\n"); return PRINT_EMOJI; }

➕ { if(debug) printf("DEBUG TOKEN PLUS_EMOJI -> ➕\n"); return PLUS_EMOJI; }

➖ { if(debug) printf("DEBUG TOKEN MINUS_EMOJI -> ➖\n"); return MINUS_EMOJI; }

🔓 { if(debug) printf("DEBUG TOKEN OPEN_EMOJI -> 🔓\n"); return OPEN_EMOJI; }

🔒 { if(debug) printf("DEBUG TOKEN CLOSE_EMOJI -> 🔒\n"); return CLOSE_EMOJI; }

🤔 { if(debug) printf("DEBUG TOKEN IF_EMOJI -> 🤔\n"); return IF_EMOJI; }

🙃 { if(debug) printf("DEBUG TOKEN ELSE_EMOJI -> 🙃\n"); return ELSE_EMOJI; }

🟰 { if(debug) printf("DEBUG TOKEN EQUAL_EMOJI -> 🟰\n"); return EQUAL_EMOJI; }

💪 { if(debug) printf("DEBUG TOKEN SUP_EMOJI -> 💪\n"); return SUP_EMOJI; }

🤏 { if(debug) printf("DEBUG TOKEN INF_EMOJI -> 🤏\n"); return INF_EMOJI; }

🔁 { if(debug) printf("DEBUG TOKEN WHILE_EMOJI -> 🔁\n"); return WHILE_EMOJI; }

↪️ { if(debug) printf("DEBUG TOKEN FOR_EMOJI -> ↪️\n"); return FOR_EMOJI; }

🔗 { if(debug) printf("DEBUG TOKEN LINK_EMOJI -> 🔗\n"); return LINK_EMOJI; }

🎲 { if(debug) printf("DEBUG TOKEN RANDOM_EMOJI -> 🎲\n"); return RANDOM_EMOJI; }

📩 { if(debug) printf("DEBUG TOKEN TAKE_EMOJI -> 📩\n"); return TAKE_EMOJI; }

🔢 { if(debug) printf("DEBUG TOKEN FLOAT_EMOJI -> 🔢\n"); return FLOAT_EMOJI; }

🔡 { if(debug) printf("DEBUG TOKEN STRING_EMOJI -> 🔡\n"); return STRING_EMOJI; }

%%
