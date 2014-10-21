
// Everything following // is a "comment".
// Comments are ignored when evaluating code.

/*
Everything between a pair of /* and */
is also a comment.
*/

// A line of code is evaluated using
// Apple+Return on Mac (Ctrl+Return otherwise).
1 + 2 + 3

// "Regions" are enclosed in ().
// Entire code inside a region is evaluated at once.
(
1 + 1;
2 + 2;
3 + 3;
// Only the result of the last evaluated line is posted in the Post Window.
)



//// MATH ///

1 + 2 * 3 // In SuperCollider there is no operator precedence
1 + (2 * 3) // Order of execution must be defined using round brackets
10 / 0
inf // inf stands for 'infinity' - an infinitly large number
inf / 10000 // Any operation with infinity still restuls in infinity



//// VARIABLES ////

a = 2 // Store 2 into variable "a"
a + 3 // Recall 2 from "a" and add 3

b // a variable without a value assigned equals 'nil'
b + 2; // ERROR: Can not calculate with 'nil'

x = 0;
x = x + 1; // Recursive use of a variable



//// OBJECTS AND METHODS ////

// Everything is an object, even a number.
// Objects have methods, which are "called"
// with the syntax "object.method"

10.neg // Negation
-3.abs // Absolute value
5.9.round // Rounding to closest integer
10.rand // Random number

// Method arguments

2.pow(3) // Two to the power of three.
2.pow(1+2) // Expression in place of an argument.
2.pow(2.pow(2)) // Nested method execution

// Alternative method call syntax, object as first argument:
rand(10);



//// FUNCTIONS ////

// A function stores code to be evaluated later, possibly multiple times:
f = { 10.rand }
f
f.value

// In contrast:
a = 10.rand
a.value

// Function arguments:
f = { arg x, y; (x + y) / 2 }; // Computes average of 2 values
f.value(5,10);

// Local variables are distinct from global variables
// and exclusive to the function in which they are defined:
x = 3;
{ var x = 10; x + 1 }.value;
x // remains unchanged after function is evaluted.

// Global variables can only be single letters.
// Local variables can have any name:
{ var variableWithLongName = 999; variableWithLongName + 1 }.value



//// CONDITIONALS, LOOPS ////

// "if" evaluates one or another function, based on condition:
x = 0;
if(x > 5, { x = 0 }, { x = x + 1 })

// The result of "if" is the result of selected function,
// that's why it appear in the Post Window.

// Alternative form of "if":
if (x > 5) { x = 0 } { x = x + 1 };


// "do" on an integer evaluates a function
// as many times as the integer value.
// passing the current iteration number as argument:
5.do({ arg index; (index * 2).postln })

// The result of "do" is the object on which it is called,
// that's why it appears in the Post Window.

// Alternative form of "do":
5.do { arg index; (index * 2).postln };

