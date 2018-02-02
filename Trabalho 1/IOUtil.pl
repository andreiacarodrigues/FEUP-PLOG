%=======================================================================================================================%
% IOUtil.pl - Module with predicates for writing and reading from the console and files.
%=======================================================================================================================%

%===================================%
% Reading and writing to the console
%===================================%

% clearScreen.
% Clears the screen.
clearScreen:- write('\33\[2J').	

% clearBuffer.
% Clears the input buffer.
clearBuffer:-
	repeat,
		get_char(C),
		C = '\n'.

% pressEnterToContinue.
% Waits for the user to press the ENTER key to continue. 
pressEnterToContinue:- write('Press ENTER to continue.'), nl, clearBuffer.

% getChar(+Char).
% Reads a char from the keyboard.
getChar(C):-
	get_char(C),
	clearBuffer.
	
% getInt(+Integer).
% Reads an integer from the keyboard.
getInt(A):-
	get_code(Input),
	A is Input - 48,
	clearBuffer.

% getIntPair(+A-B).
% Reads a pair of integers, separated by a '-', from the keyboard.
getIntPair(A-B):-
	get_code(InputA),
	A is InputA - 48,
	get_char(_),
	get_code(InputB),
	B is InputB - 48,
	clearBuffer.