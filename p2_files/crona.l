%{
/*
 *
 *      PLEASE NOTE: This starter file is a temporary solution 
 *      and will be replaced with a more complete lexer. 
 *  
 *      If you want to get started on P2 
 */


#include <string>
#include <limits.h>

/* Get our custom yyFlexScanner subclass */
#include "scanner.hpp"
#include "tokens.hpp"
#undef  YY_DECL
#define YY_DECL int crona::Scanner::yylex( crona::Parser::semantic_type * const lval )

/* define yyterminate as this instead of NULL */
#define yyterminate() return( TokenKind::END )

/* Exclude unistd.h for Visual Studio compatability. */
#define YY_NO_UNISTD_H

/* typedef to make the reference to token kinds shorter */
using TokenKind = crona::Parser::token;

%}

%option debug
%option nodefault
%option yyclass="crona::Scanner"
%option noyywrap
%option c++

DIGIT [0-9]

%%
%{          /** Code executed at the beginning of yylex **/
            yylval = lval;
%}


"int"		{
		int tokenKind = TokenKind::INT;
		Token * token = new Token(lineNum, colNum, tokenKind);
		this->yylval->lexeme = token;
		colNum++;
		return tokenKind;
		}

[a-zA-Z_][a-zA-Z0-9_]* {
		int tokenKind = TokenKind::ID;
		this->yylval->lexeme = new Token(lineNum, colNum, tokenKind);
		colNum += yyleng;
		return TokenKind::ID;
		}

":"		{
		int tokenKind = TokenKind::COLON;
		Token * token = new Token(lineNum, colNum, tokenKind);
		this->yylval->lexeme = token;
		colNum++;
		return tokenKind;
		}

";" {
		int tokenKind = TokenKind::SEMICOLON;
		this->yylval->lexeme = new Token(lineNum, colNum, tokenKind);
		colNum++;
		return tokenKind;
		}

[ ]		{ colNum++; }

{DIGIT}+	{
		int intVal = atoi(yytext);
		yylval->lexeme = new IntLitToken(lineNum, colNum, intVal);
		return TokenKind::INTLITERAL;
		}

\n		{
		lineNum++;
		colNum = 1;
		}


.   {
		std::string msg = "Illegal character ";
		msg += yytext;
		error(lineNum,colNum,msg);
		colNum += yyleng;
    }
%%
