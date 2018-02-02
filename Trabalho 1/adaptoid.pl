%=======================================================================================================================%
% Adaptoid.pl - User interface module, with high-level predicates that interact with the user to play the game Adaptoid.
%=======================================================================================================================%

:- use_module(library(system)).

:-include('Bot.pl').
:-include('IOUtil.pl').

:-dynamic(game/4).

%=======================%
% Displaying the game
%=======================%

% display_game(+Game). 
% Displays the game's state.
display_game(Game):-
	%Display the turn number
	getTurnNo(Game,TurnNo),
	write('Turn No.'),write(TurnNo),nl,
	
	%Display the active player
	getActivePlayerColor(Game,ActivePlayerColor),
	display_active_player(ActivePlayerColor), nl,
	
	%Display each player
	write('White player: '), 
	display_player(Game,0), nl,
	write('Black player: '), 
	display_player(Game,1), nl, 
	
	%Display the game board
	getBoard(Game,Board),
	nl, display_board(Board), nl, nl.

% display_active_player(+ActivePlayerColor).	
% Prints out a line to indicate the who's turn it is.
display_active_player(0):-
	write('It\'s the white player\'s turn!').
display_active_player(1):-
	write('It\'s the black player\'s turn!'). 

% display_player(+Game,+PlayerColor).
% Displays the player's info
display_player(Game,PlayerColor):-
	getPlayerElem(Game,PlayerColor,Player),
	
	%Display the points.
	getPoints(Player,Points),
	write(Points), write(' points.'), nl,
	
	%Display the inventory
	getToidPieces(Player,Toids),
	getPincerPieces(Player,Pincers),
	getLegPieces(Player,Legs),
	
	write('Inventory:'), nl,
	write('[Toids: '), write(Toids), write(']'),
	write('[Pincers: '), write(Pincers), write(']'),
	write('[Legs: '), write(Legs), write(']').

% display_board(+Board).
% Displays the board								
display_board([L1|Ls]):- display_cols_idxs, nl, display_lines([L1|Ls]), display_cols_idxs.

% display_cols_idxs.
% Displays the first four column indexes
display_cols_idxs:- write('             1     2     3     4').

% display_lines(+RemainingBoard).
% Displays all the board's lines
display_lines([]).
display_lines([L1|Ls]):- 
	length([L1|Ls], NLines), length(L1, NCols), LineNum is 8 - NLines,
	write(' '), display_topbot_border(NCols), nl, 
	spaces_before_board(NCols,X), write(X), write(LineNum), display_top_line(L1), nl,
	write(X), write(' '), display_bot_line(L1), nl, 
	write(' '), display_topbot_border(NCols), display_col_idx(LineNum), nl,
	display_lines(Ls).

% display_col_idx.
% Displays the remaining three column indexes
display_col_idx(1):-write('5').	
display_col_idx(2):-write('6').	
display_col_idx(3):-write('7').	
display_col_idx(5):-write('6').	
display_col_idx(6):-write('5').	
display_col_idx(_).								

% display_top_line(+Line).
% Displays a single line (top portion of the cells)		
display_top_line([]).		
display_top_line([C1|Cs]):-write('|'), display_cell_top(C1), write('|'), display_top_line(Cs).

% display_bot_line(+Line).
% Displays a single line (bottom portion of the cells)		
display_bot_line([]).		
display_bot_line([C1|Cs]):-write('|'), display_cell_bot(C1), write('|'), display_bot_line(Cs).

% display_topbot_border(+NCols).
% Displays a line of symbols for the top and bottom of each cell.							
display_topbot_border(NCols):-spaces_before_board(NCols,X), write(X), display_top_bot_cells(NCols).

% display_top_bot_cells(+CellsLeft).
% Display the '-' symbols for the top and bottom of each cell.
display_top_bot_cells(0).
display_top_bot_cells(CellsLeft):-CellsLeft>0,write(' ---- '), N is CellsLeft-1,display_top_bot_cells(N).

% spaces_before_board(+Line,-String).
% Determines how many ' ' to draw on each line to properly align the board.
spaces_before_board(4,'          ').
spaces_before_board(5,'       ').
spaces_before_board(6,'    ').
spaces_before_board(7,' ').

% display_cell_top(+CellContent).
% Displays the content of the upper part of a cell.
display_cell_top(none):-write('    ').
display_cell_top(toid(0,_,_)):- write('W   ').
display_cell_top(toid(1,_,_)):- write('B   ').

% display_cell_bot(+CellContent).
% Displays the content of the lower part of a cell.
display_cell_bot(none):-write('    ').
display_cell_bot(toid(_,P,L)):- write(' '), write(P), write('/'), write(L).

%=======================%
% Printing the last move
%=======================%

% printLastMove(+Game).
% Displays information about last turn's moves.
printLastMove(Game):-
	write('Turn summary:'), nl,
	
	getLastMove(Game,LastFirstMove-LastSecondMove),
	printLastFirstMove(LastFirstMove), nl,
	printLastSecondMove(LastSecondMove), nl.

%printLastFirstMove(+LastFirstMove).
% Displays information about last turn's first move.
printLastFirstMove(moveToid(Line-Col,DestLine-DestCol)):-
	write('   Moved the toid at '), write(Line-Col), write(' to '), write(DestLine-DestCol), write('.').
printLastFirstMove(none):-
	write('   Skipped the first move.').
	
%printLastSecondMove(+LastSecondMove).
% Displays information about last turn's second move.
printLastSecondMove(addToid(Line-Col)):-
	write('   Added a toid at '), write(Line-Col), write('.').
printLastSecondMove(addPincer(Line-Col)):-
	write('   Added a pincer at '), write(Line-Col), write('.').
printLastSecondMove(addLeg(Line-Col)):-
	write('   Added a leg at '), write(Line-Col), write('.').
printLastSecondMove(none):-
	write('   Skipped the second move.').

%=======================%
% Initializing the game
%=======================%

% gameInit(+Player1)
% Sets the game's initial state (for the players, board, etc) and the type (human/bot/greedy) of the first player.
gameInit(Player1):-
	assert((gameState:- game(1, 0, [player(0, 11, 12, 12), player(0, 11, 12, 12)],
	[[none, none, none, none],
	  [none, none, none, none, none],
	  [none, none, none, none, none, none],
	  [none, toid(0,0,0), none, none, none, toid(1,0,0), none],
	  [none, none, none, none, none, none],
	  [none, none, none, none, none],
	  [none, none, none, none]],
	  none-none))),
	assert((curPlayerType:- Player1)).

%=======================%
% Playing a turn
%=======================%

% playTurn(+PlayerType)
% Plays a turn, acoording to the type (human/bot/greedy) of the active player.
playTurn(human):- 
	% Loop for the first move
	clause(gameState,Game),
	repeat,
		once(clearScreen),
		once(write('Currently playing: human player.')), once(nl),
		once(display_game(Game)),
		
		once(readFirstMoveDecision(Decision)),
		once(readFirstMoveCoords(Decision, Line-Col, DestLine-DestCol)),
		firstMove(Decision,Game,Line-Col,DestLine-DestCol,NewGame1),
	retract((gameState :- Game)),
	asserta((gameState :- NewGame1)),
	
	% Loop for the second move
	repeat,
		once(clearScreen),
		once(write('Currently playing: human player.')), once(nl),
		once(display_game(NewGame1)), 
		
		once(readSecondMoveDecision(Decision2)),
		once(readSecondMoveCoords(Decision2, Line2-Col2)),
		secondMove(Decision2,NewGame1,Line2-Col2,NewGame2),
	retract((gameState :- NewGame1)),
	asserta((gameState :- NewGame2)),
		
	% Display the board after having executed the move
	clearScreen,
	write('Currently playing: human player.'), nl,
	display_game(NewGame2), 
	printLastMove(NewGame2),
	pressEnterToContinue,
	
	% Prepare and update the game for the next player
	switchActivePlayer(NewGame2,NewGame3),
	incTurnNo(NewGame3,NewGame),
	retract((gameState :- NewGame2)),
	asserta((gameState :- NewGame)).
playTurn(random):-
	% Execute the moves
	clause(gameState,Game),
	pickRandomNewGame(Game,NewGame1),
	
	% Display the board after having executed the move
	clearScreen,
	write('Currently playing: random computer player.'), nl,
	display_game(NewGame1), 
	printLastMove(NewGame1),
	pressEnterToContinue,
	
	% Prepare and update the game for the next player
	switchActivePlayer(NewGame1,NewGame2),
	incTurnNo(NewGame2,NewGame),
	retract((gameState :- Game)),
	assert((gameState :- NewGame)).
playTurn(greedy):-
	% Execute the moves
	clause(gameState,Game),
	pickGreedyNewGame(Game,NewGame1),
	
	% Display the board after having executed the move
	clearScreen,
	write('Currently playing: greedy computer player.'), nl,
	display_game(NewGame1), 
	printLastMove(NewGame1),
	pressEnterToContinue,
	
	% Prepare and update the game for the next player
	switchActivePlayer(NewGame1,NewGame2),
	incTurnNo(NewGame2,NewGame),
	retract((gameState :- Game)),
	assert((gameState :- NewGame)).	

% readFirstMoveDecision(+Decision).
% Asks and reads the user's decision for the first move.
readFirstMoveDecision(Decision):- 
	write('What you would like to do?'), nl,
	write('1 - Move an adaptoid.'), nl,
	write('2 - Dont move an adaptoid.'), nl,
	getInt(Decision).

% readFirstMoveCoords(+Decision, -Line-Col, -DestLine-DestCol)
% Asks and reads the user's coordinates for the first move.	
readFirstMoveCoords(1, Line-Col, DestLine-DestCol):- 
	write('Where is the piece to be moved (Line-Column)?'), nl,
	getIntPair(Line-Col),
	write('Where would you like to move the piece (Line-Column)?'), nl, 
	getIntPair(DestLine-DestCol).
readFirstMoveCoords(2,_,_).

% readSecondMoveDecision(+Decision).
% Asks and reads the user's decision for the second move.	
readSecondMoveDecision(Decision):- 
	write('What you would like to do?'), nl,
	write('1 - Place a new adaptoid on the board.'), nl,
	write('2 - Add a pincer to an existing adaptoid.'), nl,
	write('3 - Add a leg to an existing adaptoid.'), nl,
	write('4 - End the turn without doing anything.'), nl,
	getInt(Decision).

% readSecondMoveCoords(+Decision, -Line-Col)
% Asks and reads the user's coordinates for the second move.	
readSecondMoveCoords(1, Line-Col):- 
	write('Where would you like to place the new adaptoid (Line-Column)?'), nl,
	getIntPair(Line-Col).
readSecondMoveCoords(2, Line-Col):- 
	write('Where is the adaptoid that will receive the new pincer (Line-Column)?'), nl,
	getIntPair(Line-Col).
readSecondMoveCoords(3, Line-Col):- 
	write('Where is the adaptoid that will receive the new leg (Line-Column)?'), nl,
	getIntPair(Line-Col).
readSecondMoveCoords(4,_).

%================================%
% Testing for the end of the game
%================================%

% testEnd(-Winner).
% Tests if the game has reached its end.
testEnd(Winner):- clause(gameState,Game), gameOver(Game,Winner), !, Winner \= none.
	
%============================================%
% Printing the results of the end of the game
%============================================%

% showResults(+Winner).
% Prints the game's final results.
showResults(0):-
	write('The white player has won the game!'), nl, pressEnterToContinue, nl.
showResults(1):-
	write('The black player has won the game!'), nl, pressEnterToContinue, nl.

%=======================%
% Main game loop
%=======================%

% getOtherPairElement(+A-B,+Elem,-OtherElem).
% Returns the other element of a pair (used to switch between players).
getOtherPairElement(A-B,A,B).
getOtherPairElement(A-B,B,A).

% playGame(+Player1-Player2).
% Implements the main loop for playing the game. Player1 and Player2 are the respective types of each player (human/random/greedy).
playGame(Player1-Player2):- 
	% Retract all dynamic clauses from a previous game (in case the previous game was interrupted)
	retractall(gameState),
	retractall(curPlayerType),
	
	% Initialize the game
	gameInit(Player1),
	
	% Main loop
	repeat,
		% Get the current player type (human/random/greedy).
		once(clause(curPlayerType,CurrentPlayer)),
		
		% Play the turn
		once(playTurn(CurrentPlayer)),
		
		% Switch to the other player
		once(getOtherPairElement(Player1-Player2,CurrentPlayer,OtherPlayer)),
		once(retract((curPlayerType:- CurrentPlayer))),
		once(assert((curPlayerType:- OtherPlayer))),
		
		% Test if the game is over
		once(testEnd(Winner)),
		
	% Show the end game results
	showResults(Winner),
	
	% Retract all dynamic clauses
	retract((gameState :- _)),
	retract((curPlayerType:- _)).

%=======================%
% Main menu
%=======================%

% displayGameHeader.
% Displays a header with information about game.
displayGameHeader:-
	write('Adaptoid Game'), nl,
	write('By: '), nl,
	write('     Andreia Cristina de Almeida Rodrigues - up201404691'), nl,
	write('     Gonçalo da Mota Laranjeira Torres Leão - up201406036'), nl,
	write('Group: Adaptoid_1'), nl,
	write('MIEIC - PLOG - 2016/2017'), nl.

% displayMainMenuOptions.
% Displays the main menu options.
displayMainMenuOptions:-
	write('Choose an option:' ), nl,
	write('a - Human vs Human'), nl,
	write('b - Random vs Human'), nl,
	write('c - Human vs Random'), nl,
	write('d - Greedy vs Human'), nl,
	write('e - Human vs Greedy'), nl,
	write('f - Random vs Random'), nl,
	write('g - Random vs Greedy'), nl,
	write('h - Greedy vs Random'), nl,
	write('i - Greedy vs Greedy'), nl,
	write('j - Exit'), nl.

% processGameDecision(+Decision).
% Executes the apropriate action taking into account the option at the main menu.
processGameDecision('a'):-once(playGame(human-human)), fail.
processGameDecision('b'):-once(playGame(random-human)), fail.
processGameDecision('c'):-once(playGame(human-random)), fail.
processGameDecision('d'):-once(playGame(greedy-human)), fail.
processGameDecision('e'):-once(playGame(human-greedy)), fail.
processGameDecision('f'):-once(playGame(random-random)), fail.
processGameDecision('g'):-once(playGame(random-greedy)), fail.
processGameDecision('h'):-once(playGame(greedy-random)), fail.
processGameDecision('i'):-once(playGame(greedy-greedy)), fail.
processGameDecision('j').

% setRandomSeed.
% Initializes the random number generator with a seed based on the current time.
setRandomSeed:-
	%Use the current time to compute the random seed
	now(Usec), Seed is Usec mod 30269,
	
	%Set the random seed
	getrand(random(X, Y, Z, _)),
	setrand(random(Seed, X, Y, Z)).
	
% adaptoid.
% Main predicate of the game.
adaptoid:- 
	setRandomSeed,
	repeat,
		once(clearScreen),
		once(displayGameHeader),
		once(displayMainMenuOptions),
		once(getChar(Decision)),
		processGameDecision(Decision).