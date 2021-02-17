%{
#include <string>
#include <limits.h>

/* Get our custom yyFlexScanner subclass */
#include "scanner.hpp"
#include "tokens.hpp"
using namespace std;
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
WHITESPACE [\040\t]
LETTER [a-zA-Z]
ESCAPEE [nt'"\\]

 /* */
BADESC [\\][^nt"\\\n]?
STRELT ([\\][nt"\\])|([^\\\n"])

/*
"write"	  	    { return makeBareToken(TokenKind::WRITE); }
"havoc"	 	   { return makeBareToken(TokenKind::HAVOC); }

 yylval->transToken = new StrToken(lineNum, colNum, yytext);
 // yylval->transToken = yylval->lexeme
*/

%%
%{
	this->yylval = lval;
%}

int    		       { return makeBareToken(TokenKind::INT); }
bool 		      { return makeBareToken(TokenKind::BOOL); }
byte 		      { return makeBareToken(TokenKind::BYTE); }
array		      { return makeBareToken(TokenKind::ARRAY); }
string		      { return makeBareToken(TokenKind::STRING); }
void 		      { return makeBareToken(TokenKind::VOID); }
if  		      { return makeBareToken(TokenKind::IF); }
else		      { return makeBareToken(TokenKind::ELSE); }
while		      { return makeBareToken(TokenKind::WHILE); }
return		    { return makeBareToken(TokenKind::RETURN); }
false  		    { return makeBareToken(TokenKind::FALSE); }
true 		    { return makeBareToken(TokenKind::TRUE); }
read		    { return makeBareToken(TokenKind::READ);}
"write"	  	    { return makeBareToken(TokenKind::WRITE); }
"["		        { return makeBareToken(TokenKind::LBRACE); }
"]"		        { return makeBareToken(TokenKind::RBRACE); }
"{"		        { return makeBareToken(TokenKind::LCURLY); }
"}"		        { return makeBareToken(TokenKind::RCURLY); }
"("		        { return makeBareToken(TokenKind::LPAREN); }
")"		        { return makeBareToken(TokenKind::RPAREN); }
";"		        { return makeBareToken(TokenKind::SEMICOLON); }
":"		        { return makeBareToken(TokenKind::COLON); }
","		        { return makeBareToken(TokenKind::COMMA); }
"++"          { return makeBareToken(TokenKind::CROSSCROSS); }
"+"           { return makeBareToken(TokenKind::CROSS); }
"--"          { return makeBareToken(TokenKind::DASHDASH); }
"-"		        { return makeBareToken(TokenKind::DASH); }
"*"		        { return makeBareToken(TokenKind::STAR); }
"/"		        { return makeBareToken(TokenKind::SLASH); }
"!"	 	        { return makeBareToken(TokenKind::NOT); }
"&&"          { return makeBareToken(TokenKind::AND); }
"||"          { return makeBareToken(TokenKind::OR); }
"=="          { return makeBareToken(TokenKind::EQUALS); }
"!="          { return makeBareToken(TokenKind::NOTEQUALS); }
"<"		        { return makeBareToken(TokenKind::LESS); }
"<="          { return makeBareToken(TokenKind::LESSEQ); }
">"		        { return makeBareToken(TokenKind::GREATER); }
">="          { return makeBareToken(TokenKind::GREATEREQ); }
"="		        { return makeBareToken(TokenKind::ASSIGN); }

({LETTER}|_)({LETTER}|{DIGIT}|_)* {
		            yylval->lexeme = new IDToken(lineNum, colNum, yytext);
		            colNum += yyleng;
		            return TokenKind::ID; }

{DIGIT}+	    { double asDouble = std::stod(yytext);
			          int intVal = atoi(yytext);
			          bool overflow = false;
			          if (asDouble > INT_MAX){ overflow = true; }

				  string str = yytext;
				  string suffix = "";
				  for(int i = 0 ; i < str.length(); i++){
					if (str[i] != '0'){
						suffix = str.substr(i, std::string::npos);
						break;
					}
				  }
			          if (suffix.length() > 10){ overflow = true; }

			          if (overflow){
				            errIntOverflow(lineNum, colNum);
				            intVal = INT_MAX;
			          }
			          yylval->lexeme = new IntLitToken(lineNum, colNum, intVal);
			          colNum += yyleng;
			          return TokenKind::INTLITERAL; }

\"{STRELT}*\" {
   		          yylval->lexeme = new StrToken(lineNum, colNum, yytext);
		            this->colNum += yyleng;
		            return TokenKind::STRLITERAL; }

\"{STRELT}* {
		            errStrUnterm(lineNum, colNum);
		            colNum += yyleng; /*Upcoming \n resets lineNum */
			    #if EXIT_ON_ERR
			    exit(1);
			    #endif
		            }

["]([^"\n]*{BADESC}[^"\n]*)+(\\["])? {
                // Bad, unterm string lit
		errStrEscAndUnterm(lineNum, colNum);
                colNum += yyleng;
        }

["]([^"\n]*{BADESC}[^"\n]*)+(\\)? {
                // Bad, unterm string lit
		errStrEscAndUnterm(lineNum, colNum);
                colNum += yyleng;
        }


["]([^"\n]*{BADESC}[^"\n]*)+["] {
                // Bad string lit
		errStrEsc(lineNum, colNum);
                colNum += yyleng;
        }

\n|(\r\n)     { lineNum++; colNum = 1; }


[ \t]+	      { colNum += yyleng; }

([/][/])[^\n]*	  { /* Comment. No token, but update the
                   char num in the very specific case of
                   getting the correct EOF position */
		   colNum += yyleng;
		  }

.		          {
				errIllegal(lineNum, colNum, yytext);
			    #if EXIT_ON_ERR
			    exit(1);
			    #endif
		            this->colNum += yyleng; }
%%
