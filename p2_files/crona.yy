%skeleton "lalr1.cc"
%require "3.0"
%debug
%defines
%define api.namespace {crona}
 /*
 If your bison install has trouble with the
 line %define api.parser.class {Parser} try
 using the older %define parser_class_name {Parser}
 instead
 */
%define api.parser.class {Parser}
%define parse.assert
%define parse.error verbose
%output "parser.cc"
%token-table

%code requires{
	#include <list>
	#include "tokens.hpp"
	namespace crona {
		class Scanner;
	}

//The following definition is required when
// we don't use the %locations directive (which we won't)
# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

//End "requires" code
}

%parse-param { crona::Scanner &scanner }

%code{
   // C std code for utility functions
   #include <iostream>
   #include <cstdlib>
   #include <fstream>

   // Our code for interoperation between scanner/parser
   #include "scanner.hpp"
   //#include "tokens.hpp"

  //Request tokens from our scanner member, not
  // from a global function
  #undef yylex
  #define yylex scanner.yylex
}

/*
The %union directive is a way to specify the
set of possible types that might be used as
translation attributes that a symbol might take.
For this project, only terminals have types (we'll
have translation attributes for non-terminals in the next
project)
*/
%union {
   crona::Token*                         lexeme;
   crona::Token*                         transToken;
}

%token                   END	   0 "end file"
%token	<transToken>     AND
%token	<transToken>     ARRAY
%token	<transToken>     ASSIGN
%token	<transToken>     BOOL
%token	<transToken>     BYTE
%token	<transToken>     COLON
%token	<transToken>     COMMA
%token	<transToken>     CROSS
%token	<transToken>     CROSSCROSS
%token	<transToken>     DASH
%token	<transToken>     DASHDASH
%token	<transToken>     ELSE
%token	<transToken>     EQUALS
%token	<transToken>     FALSE
%token	<transToken>     READ
%token	<transToken>     HAVOC
%token	<transIDToken>   ID
%token	<transToken>     IF
%token	<transToken>     INT
%token	<transIntToken>  INTLITERAL
%token	<transToken>     GREATER
%token	<transToken>     GREATEREQ
%token	<transToken>     LBRACE
%token	<transToken>     LCURLY
%token	<transToken>     LESS
%token	<transToken>     LESSEQ
%token	<transToken>     LPAREN
%token	<transToken>     NOT
%token	<transToken>     NOTEQUALS
%token	<transToken>     OR
%token	<transToken>     RBRACE
%token	<transToken>     RCURLY
%token	<transToken>     RETURN
%token	<transToken>     RPAREN
%token	<transToken>     SEMICOLON
%token	<transToken>     SLASH
%token	<transToken>     STRING
%token	<transToken>     STAR
%token	<transStrToken>  STRLITERAL
%token	<transToken>     TRUE
%token	<transToken>     VOID
%token	<transToken>     WHILE
%token	<transToken>     WRITE

/* NOTE: Make sure to add precedence and associativity
 * declarations
*/

%%

/* TODO: add productions for the other nonterminals in the
   grammar and make sure that all of the productions of the
   given nonterminals are complete
*/
program 	: globals
		  {
		  }

globals 	: globals decl
	  	  {
	  	  }
		| /* epsilon */
		  {
		  }

decl 		: varDecl SEMICOLON
		  {
                  /*
                  For this project, you don't need to put in any actions
                  here, but you might find it helpful to print something
                  when a rule is matched while debugging (so you know
                  which productions are being matched
		  */
		  // std::cout << "Var decl matched"
                  }
  | funcDecl scope
    {
    }
  | caseDecl
    {
    }
  | iterDecl
    {
    }

funcDecl  : id RPAREN params LPAREN VOID
      {
      }
    | id type
      {
      }

scope : LCURLY globals RCURLY
      {
      }

params : conditional
      {
      }
    | /* epsilon */
      {
      }

iterDecl : WHILE LPAREN conditional RPAREN scope
      {
      }

caseDecl  : IF LPAREN conditional RPAREN caseDecl scope
      {
      }
    | ELSE IF LPAREN conditional RPAREN caseDecl scope
      {
      }
    | ELSE scope
      {
      }

conditional : TRUE
      {
      }

varDecl 	: id COMMA varDecl
      {
      }
    | id COLON type
  		{
  		}

type 		: INT
	  	  {
		  }
		| ARRAY INT
	  	  {
		  }
    | BOOL
        {
      }
		| ARRAY BOOL
	  	  {
		  }
    | BYTE
        {
      }
		| ARRAY BYTE
	  	  {
		  }
		/* TODO: add the rest of the types */

id		: ID
		  {
		  }

 /* TODO: add productions for the entire grammar of the language */

%%

void crona::Parser::error(const std::string& err_message){
   /* For project grading, only report "syntax error"
      if a program has bad syntax. However, you will
      probably want better output for debugging. Thus,
      this error function prints a verbose message to
      stdout, but only prints "syntax error" to stderr
   */
	std::cout << err_message << std::endl;
	std::cerr << "syntax error" << std::endl;
}
