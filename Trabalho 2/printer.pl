%=======================================================================================================================%
% printer.pl - User interface module, with predicates that print the generated / solved Clouds board.
%=======================================================================================================================%

%=======================%
% Displaying the board
%=======================%

% printClouds(+LineClues, +ColClues, +Lines).
% Displays the generated / solved Clouds board.
printClouds([],[],[]).
printClouds(LineClues, ColClues, Lines):-
	printLinesClouds(LineClues, Lines),nl,
	printColClues(ColClues).
	
% printLinesClouds(+LineClues, +Lines)
% Displays board's lines and respective clue.
printLinesClouds([],[]).
printLinesClouds([LC1|LC2], [L1|L2]):-
	printLine(L1),
	write(' '),
	printClue(LC1), nl,
	printLinesClouds(LC2, L2).
	
% printClue(+Clue).
% Displays line / column clue.
printClue(none):- write(' ').
printClue(N):- write(N).

% printColClues(+ColClues)
% Displays board's column clues.
printColClues([]).
printColClues([CC1|CC2]):-
	printClue(CC1), 
	write(' '), 
	printColClues(CC2).

% printLine(+Line)
% Displays one line from the board's matrix.
printLine([]).
printLine([L1|L2]):-
	printElem(L1),
	write(' '),
	printLine(L2).

% printElem(+Elem).
% Displays one element / cell of the board.
printElem(0):- write('.').
printElem(1):- write('X').