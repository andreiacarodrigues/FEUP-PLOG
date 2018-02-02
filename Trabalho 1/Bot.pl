%=======================================================================================================================%
% Bot.pl - Module that implements the computer player.
%=======================================================================================================================%

:-include('Game.pl').
:-include(library(random)).

%============================%
% Getting all the valid moves
%============================%

% getAllValidFirstMoveNewGames(+Game,-AllValidFirstMoveNewGames).
% Retrives all of the valid first moves on a given turn.
getAllValidFirstMoveNewGames(Game,AllValidFirstMoveNewGames):-
	%Game if first move is skipped
	skipFirstMove(Game,SkipMoveNewGame),

	%Games obtained with moveToid
	findall(NewGame,
	(
	getAllValidCells(Cells),
	member(Line-Col,Cells),
	moveToid(Game, Line-Col, _, NewGame)
	),
	AllValidMoveToidNewGames),
	
	append([SkipMoveNewGame],AllValidMoveToidNewGames,AllValidFirstMoveNewGames).
	
% getAllValidSecondMoveNewGames(+Game,-AllValidSecondMoveNewGames).
% Retrives all of the valid second moves on a given turn.
getAllValidSecondMoveNewGames(Game,AllValidSecondMoveNewGames):-
	%Game if second move is skipped
	skipSecondMove(Game,SkipMoveNewGame),

	%Games obtained with addToid
	findall(NewGame,
	(
	getAllValidCells(Cells),
	member(Line-Col,Cells),
	addToid(Game, Line-Col, NewGame)
	),
	AllValidAddToidNewGames),
	
	append([SkipMoveNewGame],AllValidAddToidNewGames,AllValidSecondMoveNewGames1),
	
	%Games obtained with addPincer
	findall(NewGame,
	(
	getAllValidCells(Cells),
	member(Line-Col,Cells),
	addPincer(Game, Line-Col, NewGame)
	),
	AllValidAddPincerNewGames),
	
	append(AllValidSecondMoveNewGames1,AllValidAddPincerNewGames,AllValidSecondMoveNewGames2),
	
	%Games obtained with addLeg
	findall(NewGame,
	(
	getAllValidCells(Cells),
	member(Line-Col,Cells),
	addLeg(Game, Line-Col, NewGame)
	),
	AllValidAddLegNewGames),
	
	append(AllValidSecondMoveNewGames2,AllValidAddLegNewGames,AllValidSecondMoveNewGames).

%============================%
% Random bot
%============================%

% pickRandomNewGame(+Game,-NewGame).
% Retrieves the new game, after the random bot plays.
pickRandomNewGame(Game,NewGame):-
	%First move
	getAllValidFirstMoveNewGames(Game,AllValidFirstMoveNewGames),
	getListLength(AllValidFirstMoveNewGames,NumMoves1),
	random(0, NumMoves1, Rand1),
	getListElem(Rand1,NewGame1,AllValidFirstMoveNewGames),
	
	%Second move
	getAllValidSecondMoveNewGames(NewGame1,AllValidSecondMoveNewGames),
	getListLength(AllValidSecondMoveNewGames,NumMoves2),
	random(0, NumMoves2, Rand2),
	getListElem(Rand2,NewGame,AllValidSecondMoveNewGames).
	
%============================%
% Greedy bot
%============================%

% pickGreedyNewGame(+Game,-NewGame).
% Retrieves the new game, after the greedy bot plays.
pickGreedyNewGame(Game,NewGame):-
	%First move
	getAllValidFirstMoveNewGames(Game,AllValidFirstMoveNewGames),
	getAllBestNewGames(AllValidFirstMoveNewGames,AllBestFirstMoveNewGames),
	getListLength(AllBestFirstMoveNewGames,NumMoves1),
	random(0, NumMoves1, Rand1),
	getListElem(Rand1,NewGame1,AllBestFirstMoveNewGames),
	
	%Second move
	getAllValidSecondMoveNewGames(NewGame1,AllValidSecondMoveNewGames),
	getAllBestNewGames(AllValidSecondMoveNewGames,AllBestSecondMoveNewGames),
	getListLength(AllBestSecondMoveNewGames,NumMoves2),
	random(0, NumMoves2, Rand2),
	getListElem(Rand2,NewGame,AllBestSecondMoveNewGames).
	
	
% getAllBestNewGames(+AllValidNewGames,-AllBestNewGames).
% Retrives all of the best valid games (from the active player's perspective) from a list valid games.
getAllBestNewGames(AllValidNewGames,AllBestNewGames):-
	getAllBestNewGames_(AllValidNewGames,-200,[],AllBestNewGames).

% getAllBestNewGames_(+AllValidNewGames,+BestValue,+Acc,-AllBestNewGames).
% Auxiliary predicate for getAllBestNewGames/2.
getAllBestNewGames_([],_,AllBestNewGames,AllBestNewGames).
getAllBestNewGames_([ValidNewGame|OtherValidNewGames],BestValue,_,AllBestNewGames):-
	%Test if ValidNewGame is better than the other best games.
	value(ValidNewGame,Value),
	write('Value: '), write(Value), nl,
	Value > BestValue,
	!,
	write('Best: '), getAllBestNewGames_(OtherValidNewGames,Value,[ValidNewGame],AllBestNewGames).
getAllBestNewGames_([ValidNewGame|OtherValidNewGames],BestValue,OtherBestNewGames,AllBestNewGames):-
	%Test if ValidNewGame is as good as the other best games.
	value(ValidNewGame,BestValue),
	write('Value: '), write(BestValue), nl,
	!,
	write(BestValue), nl,
	getAllBestNewGames_(OtherValidNewGames,BestValue,[ValidNewGame|OtherBestNewGames],AllBestNewGames).
getAllBestNewGames_([ValidNewGame|OtherValidNewGames],BestValue,OtherBestNewGames,AllBestNewGames):-
	%Test if ValidNewGame is not as good as the other best games.
	value(ValidNewGame,Value),
	write('Value: '), write(Value), nl,
	Value < BestValue,
	!,
	write(BestValue), nl,
	getAllBestNewGames_(OtherValidNewGames,BestValue,OtherBestNewGames,AllBestNewGames).


% value(+Game,-Value).
% Gives a value to the given game, from the active player's perspective (the higher the value, the better).
value(Game,Value):-
	valueGameOver(Game,0,Value1),
	valuePoints(Game,Value1,Value2),
	valueUnfedActiveToids(Game, Value2, Value).
	
% valueGameOver(+Game, +OldValue, -Value).
% Updates the game value, taking into account that the new game may already be over.
valueGameOver(Game, OldValue, Value):- %Active Player wins after the current turn
	getActivePlayerColor(Game, ActivePlayerColor),
	gameOver(Game,ActivePlayerColor),

    Value is OldValue + 100.
valueGameOver(Game, OldValue, Value):- %Active Player loses after the current turn
	getActivePlayerColor(Game, ActivePlayerColor),
	getEnemyPlayerColor(ActivePlayerColor,EnemyPlayerColor),
	gameOver(Game,EnemyPlayerColor),
	
    Value is OldValue - 100.
valueGameOver(Game, OldValue, Value):-
	gameOver(Game,none),
    Value is OldValue.
 
% valuePoints(+Game, +OldValue, -Value).
% Updates the game value, taking into account the scores of both players.
valuePoints(Game, OldValue, Value):-
	%Get the active player points
	getActivePlayerColor(Game, ActivePlayerColor),
	getPlayerElem(Game, ActivePlayerColor, ActivePlayer),
	getPoints(ActivePlayer, ActivePlayerPoints),
	
	%Get the enemy player points
	getEnemyPlayerColor(ActivePlayerColor,EnemyPlayerColor),
	getPlayerElem(Game, EnemyPlayerColor, EnemyPlayer),
	getPoints(EnemyPlayer, EnemyPlayerPoints),
	
	Value is (OldValue + 20*(ActivePlayerPoints - EnemyPlayerPoints)).
	
% valueUnfedActiveToids(+Game, +OldValue, -Value).
% Updates the game value, taking into account the unfed toid pieces.
valueUnfedActiveToids(Game, OldValue, Value):-
	countUnfedActiveToids(Game,NumUnfed),
	write('Num Unfed: '), write(NumUnfed), nl,
	Value is (OldValue - NumUnfed).