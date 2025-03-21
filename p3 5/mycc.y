/* TODO: TO BE COMPLETED */

%{

#include "lex.yy.h"
#include "global.h"
static struct ClassFile cf;

%}

/* declares YYSTYPE type of attribute for all tokens and nonterminals */
%union
{ Symbol *sym;  /* token value yylval.sym is the symbol table entry of an ID */
  unsigned num; /* token value yylval.num is the value of an int constant */
  float flt;    /* token value yylval.flt is the value of a float constant */
  char *str;    /* token value yylval.str is the value of a string constant */
  unsigned loc; /* location of instruction to backpatch */
}

/* Declare ID token and its attribute type 'sym' */
%token <sym> ID

/* Declare INT tokens (8 bit, 16 bit, 32 bit) and their attribute type 'num' */
%token <num> INT8 INT16 INT32

/* Declare FLT token (not used in this assignment) */
%token <flt> FLT

/* Declare STR token (not used in this assignment) */
%token <str> STR

/* Declare tokens for keywords */
/* Note: install_id() returns Symbol* for both keywords and identifiers */
%token <sym> BREAK DO ELSE FOR IF RETURN WHILE

/* Declare operator tokens */
/* TODO: TO BE COMPLETED WITH ASSOCIATIVITY AND PRECEDENCE DECLARATIONS */
%token PA NA TA DA MA AA XA OA LA RA OR AN EQ NE LE GE LS RS AR PP NN

/* Declare attribute types for marker nonterminals, such as L M and N */
/* TODO: TO BE COMPLETED WITH ADDITIONAL NONMARKERS AS NECESSARY */
%type <loc> L M N

%%

stmts   : stmts stmt
        | /* empty */
        ;

stmt    : ';'
        | expr ';'      { emit(pop); /* do not leave a value on the stack */ }
        | IF '(' expr ')' stmt
                        { /* TODO: TO BE COMPLETED */ error("if-then not implemented"); }
        | IF '(' expr ')' stmt ELSE stmt
                        { /* TODO: TO BE COMPLETED */ error("if-then-else not implemented"); }
        | WHILE '(' expr ')' stmt
                        { /* TODO: TO BE COMPLETED */ error("while-loop not implemented"); }
        | DO stmt WHILE '(' expr ')' ';'
                        { /* TODO: TO BE COMPLETED */ error("do-while-loop not implemented"); }
        | FOR '(' expr ';' expr ';' expr ')' stmt
                        { /* TODO: TO BE COMPLETED */ error("for-loop not implemented"); }
        | RETURN expr ';'
                        { emit(istore_2); /* return val goes in local var 2 */ }
        | BREAK ';'
                        { /* TODO: BONUS!!! */ error("break not implemented"); }
        | '{' stmts '}'
        | error ';'     { yyerrok; }
        ;

expr    : ID   '=' expr { emit(dup); emit2(istore, $1->localvar); }
        | ID   PA  expr { /* TODO: TO BE COMPLETED */ error("+= operator not implemented"); }
        | ID   NA  expr { /* TODO: TO BE COMPLETED */ error("-= operator not implemented"); }
        | ID   TA  expr { /* TODO: TO BE COMPLETED */ error("*= operator not implemented"); }
        | ID   DA  expr { /* TODO: TO BE COMPLETED */ error("/= operator not implemented"); }
        | ID   MA  expr { /* TODO: TO BE COMPLETED */ error("%= operator not implemented"); }
        | ID   AA  expr { /* TODO: TO BE COMPLETED */ error("&= operator not implemented"); }
        | ID   XA  expr { /* TODO: TO BE COMPLETED */ error("^= operator not implemented"); }
        | ID   OA  expr { /* TODO: TO BE COMPLETED */ error("|= operator not implemented"); }
        | ID   LA  expr { /* TODO: TO BE COMPLETED */ error("<<= operator not implemented"); }
        | ID   RA  expr { /* TODO: TO BE COMPLETED */ error(">>= operator not implemented"); }
        | expr OR  expr { /* TODO: TO BE COMPLETED */ error("|| operator not implemented"); }
        | expr AN  expr { /* TODO: TO BE COMPLETED */ error("&& operator not implemented"); }
        | expr '|' expr { /* TODO: TO BE COMPLETED */ error("| operator not implemented"); }
        | expr '^' expr { /* TODO: TO BE COMPLETED */ error("^ operator not implemented"); }
        | expr '&' expr { /* TODO: TO BE COMPLETED */ error("& operator not implemented"); }
        | expr EQ  expr { /* TODO: TO BE COMPLETED */ error("== operator not implemented"); }
        | expr NE  expr { /* TODO: TO BE COMPLETED */ error("!= operator not implemented"); }
        | expr '<' expr { /* TODO: TO BE COMPLETED */ error("< operator not implemented"); }
        | expr '>' expr { /* TODO: TO BE COMPLETED */ error("> operator not implemented"); }
        | expr LE  expr { /* TODO: TO BE COMPLETED */ error("<= operator not implemented"); }
        | expr GE  expr { /* TODO: TO BE COMPLETED */ error(">= operator not implemented"); }
        | expr LS  expr { /* TODO: TO BE COMPLETED */ error("<< operator not implemented"); }
        | expr RS  expr { /* TODO: TO BE COMPLETED */ error(">> operator not implemented"); }
        | expr '+' expr { /* TODO: TO BE COMPLETED */ error("+ operator not implemented"); }
        | expr '-' expr { /* TODO: TO BE COMPLETED */ error("- operator not implemented"); }
        | expr '*' expr { /* TODO: TO BE COMPLETED */ error("* operator not implemented"); }
        | expr '/' expr { /* TODO: TO BE COMPLETED */ error("/ operator not implemented"); }
        | expr '%' expr { /* TODO: TO BE COMPLETED */ error("% operator not implemented"); }
        | '!' expr      { /* TODO: TO BE COMPLETED */ error("! operator not implemented"); }
        | '~' expr      { /* TODO: TO BE COMPLETED */ error("~ operator not implemented"); }
        | '+' expr %prec '!' /* '+' at same precedence level as '!' */
                        { /* TODO: TO BE COMPLETED */ error("unary + operator not implemented"); }
        | '-' expr %prec '!' /* '-' at same precedence level as '!' */
                        { /* TODO: TO BE COMPLETED */ error("unary - operator not implemented"); }
        | '(' expr ')'
        | '$' INT8      { emit(aload_1); emit2(bipush, $2); emit(iaload); }
        | PP ID         { /* TODO: TO BE COMPLETED */ error("pre ++ operator not implemented"); }
        | NN ID         { /* TODO: TO BE COMPLETED */ error("pre -- operator not implemented"); }
        | ID PP         { /* TODO: TO BE COMPLETED */ error("post ++ operator not implemented"); }
        | ID NN         { /* TODO: TO BE COMPLETED */ error("post -- operator not implemented"); }
        | ID            { emit2(iload, $1->localvar); }
        | INT8          { emit2(bipush, $1); }
        | INT16         { emit3(sipush, $1); }
        | INT32         { emit2(ldc, constant_pool_add_Integer(&cf, $1)); }
	| FLT		{ error("float constant not supported in Pr3"); }
	| STR		{ error("string constant not supported in Pr3"); }
        ;

L       : /* empty */   { $$ = pc; }
        ;

M       : /* empty */   { $$ = pc;	/* location of inst. to backpatch */
			  emit3(ifeq, 0);
			}
        ;

N       : /* empty */   { $$ = pc;	/* location of inst. to backpatch */
			  emit3(goto_, 0);
			}
        ;

/* TODO: TO BE COMPLETED WITH ADDITIONAL NONMARKERS AS NEEDED */

%%

int main(int argc, char **argv)
{
	int index1, index2, index3;
	int label1, label2;

	// set up new class file structure
	init_ClassFile(&cf);

	// class has public access
	cf.access = ACC_PUBLIC;

	// class name is "Code"
	cf.name = "Code";

	// no fields
	cf.field_count = 0;

	// one method
	cf.method_count = 1;

	// allocate array of methods (just one "main" in our example)
	cf.methods = (struct MethodInfo*)malloc(cf.method_count * sizeof(struct MethodInfo));

	if (!cf.methods)
		error("Out of memory");

	// method has public access and is static
	cf.methods[0].access = (enum access_flags)(ACC_PUBLIC | ACC_STATIC);

	// method name is "main"
	cf.methods[0].name = "main";

	// method descriptor of "void main(String[] arg)"
	cf.methods[0].descriptor = "([Ljava/lang/String;)V";

	// max operand stack size of this method
	cf.methods[0].max_stack = 100;

	// the number of local variables in the local variable array
	//   local variable 0 contains "arg"
	//   local variable 1 contains "val"
	//   local variable 2 contains "i" and "result"
	cf.methods[0].max_locals = 100;

	// set up new bytecode buffer
	init_code();
	
	// generate prologue code

/*LOC*/ /*CODE*/			/*SOURCE*/
/*000*/	emit(aload_0);
/*001*/	emit(arraylength);		// arg.length
/*002*/	emit2(newarray, T_INT);
/*004*/	emit(astore_1);			// val = new int[arg.length]
/*005*/	emit(iconst_0);
/*006*/	emit(istore_2);			// i = 0
	label1 = pc;			// label1:
/*007*/	emit(iload_2);
/*008*/	emit(aload_0);
/*009*/	emit(arraylength);
	label2 = pc;
/*010*/	emit3(if_icmpge, PAD);		// if i >= arg.length then goto label2
/*013*/	emit(aload_1);
/*014*/	emit(iload_2);
/*015*/	emit(aload_0);
/*016*/	emit(iload_2);
/*017*/	emit(aaload);			// push arg[i] parameter for parseInt
	index1 = constant_pool_add_Methodref(&cf, "java/lang/Integer", "parseInt", "(Ljava/lang/String;)I");
/*018*/	emit3(invokestatic, index1);	// invoke Integer.parseInt(arg[i])
/*021*/	emit(iastore);			// val[i] = Integer.parseInt(arg[i])
/*022*/	emit32(iinc, 2, 1);		// i++
/*025*/	emit3(goto_, label1 - pc);	// goto label1
	backpatch(label2, pc - label2);	// label2:

	// end of prologue code

	init();

	if (argc > 1)
		if (!(yyin = fopen(argv[1], "r")))
			error("Cannot open file for reading");

	if (yyparse() || errnum > 0)
		error("Compilation errors: class file not saved");

	fprintf(stderr, "Compilation successful: saving %s.class\n", cf.name);

	// generate epilogue code

	index2 = constant_pool_add_Fieldref(&cf, "java/lang/System", "out", "Ljava/io/PrintStream;");
/*036*/	emit3(getstatic, index2);	// get static field System.out of type PrintStream
/*039*/	emit(iload_2);			// push parameter for println()
	index3 = constant_pool_add_Methodref(&cf, "java/io/PrintStream", "println", "(I)V");
/*040*/	emit3(invokevirtual, index3);	// invoke System.out.println(result)
/*043*/	emit(return_);			// return

	// end of epilogue code

	// length of bytecode is in the emitter's pc variable
	cf.methods[0].code_length = pc;
	
	// must copy code to make it persistent
	cf.methods[0].code = copy_code();

	if (!cf.methods[0].code)
		error("Out of memory");

	// save class file to "Calc.class"
	save_classFile(&cf);

	return 0;
}

