%=====================================================================================================%
% Game.pl - Implements the Game abstraction, that contains the information about the game's state.
%=====================================================================================================%

:-include('Toid.pl').
:-include('Player.pl').
:-include('ListUtil.pl').

%game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove).

%Getters

%getTurnNo(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),-TurnNo).
% Retrieves the game's turn number 
getTurnNo(game(TurnNo,_,_,_,_),TurnNo).

%getActivePlayerColor(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),-ActivePlayerColor).
% Retrieves the game's active player color 
getActivePlayerColor(game(_,ActivePlayerColor,_,_,_),ActivePlayerColor).

%getPlayerElem(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),+PlayerColor,-Elem).
% Retrieves the game's active player  
getPlayerElem(game(_,_,Players,_,_),PlayerColor,Elem):-
	getListElem(PlayerColor,Elem,Players).
	
%getBoard(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),-Board).
% Retrieves the game's board
getBoard(game(_,_,_,Board,_),Board).

%getBoardElem(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),+Line-Col,-Elem).
% Retrieves an element from the game's board
getBoardElem(game(_,_,_,Board,_),Line-Col,Elem):-
	LineI is Line - 1, ColI is Col - 1,
	getList2dElem(LineI-ColI,Elem,Board).
	
%getLastMove(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),-LastFirstMove-LastSecondMove).
% Retrieves the game's last move 
getLastMove(game(_,_,_,_,LastFirstMove-LastSecondMove),LastFirstMove-LastSecondMove).

%Setters

%setActivePlayerColor(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),+NewActivePlayerColor,game(+TurnNo,-NewActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove)).
% Sets the game's active player color.
setActivePlayerColor(game(TurnNo,_,Players,Board,LastFirstMove-LastSecondMove),NewActivePlayerColor,game(TurnNo,NewActivePlayerColor,Players,Board,LastFirstMove-LastSecondMove)).

%setPlayerElem(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),+PlayerColor,+NewElem,game(+TurnNo,+ActivePlayerColor,-NewPlayers,+Board,+LastFirstMove-LastSecondMove)).
% Sets the game's active player.
setPlayerElem(game(TurnNo,ActivePlayerColor,Players,Board,LastFirstMove-LastSecondMove),PlayerColor,NewElem,game(TurnNo,ActivePlayerColor,NewPlayers,Board,LastFirstMove-LastSecondMove)):-
	setListElem(PlayerColor,NewElem,Players,NewPlayers).

%setBoardElem(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),+Line-Col,+NewElem,game(-TurnNo,-ActivePlayerColor,-Players,-NewBoard,+LastFirstMove-LastSecondMove)).
% Sets the game's board.
setBoardElem(game(TurnNo,ActivePlayerColor,Players,Board,LastFirstMove-LastSecondMove),Line-Col,NewElem,game(TurnNo,ActivePlayerColor,Players,NewBoard,LastFirstMove-LastSecondMove)):-
	LineI is Line - 1, ColI is Col - 1,
	setList2dElem(LineI-ColI,NewElem,Board,NewBoard).

%incTurnNo(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),game(-NewTurnNo,-ActivePlayerColor,-Players,-Board,+LastFirstMove-LastSecondMove)).
% Increments the game's turn number.
incTurnNo(game(TurnNo,ActivePlayerColor,Players,Board,LastFirstMove-LastSecondMove),game(NewTurnNo,ActivePlayerColor,Players,Board,LastFirstMove-LastSecondMove)):-
	NewTurnNo is TurnNo + 1.
	
%setLastFirstMove(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),+NewLastFirstMove,game(-TurnNo,-ActivePlayerColor,-Players,-Board,-NewLastFirstMove-LastSecondMove)).
% Sets the game's last first move.
setLastFirstMove(game(TurnNo,ActivePlayerColor,Players,Board,_-LastSecondMove),NewLastFirstMove,game(TurnNo,ActivePlayerColor,Players,Board,NewLastFirstMove-LastSecondMove)).

%setLastSecondMove(game(+TurnNo,+ActivePlayerColor,+Players,+Board,+LastFirstMove-LastSecondMove),+NewLastSecondMove,game(-TurnNo,-ActivePlayerColor,-Players,-Board,-LastFirstMove-NewLastSecondMove)).
% Sets the game's last second move.
setLastSecondMove(game(TurnNo,ActivePlayerColor,Players,Board,LastFirstMove-_),NewLastSecondMove,game(TurnNo,ActivePlayerColor,Players,Board,LastFirstMove-NewLastSecondMove)).
	
%Game State	
	  
%gameOver(+Game, -Winner).
% Checks if the game ends in the current turn and retrieves the winner.
%White player wins with 5 points 
gameOver(Game,0):-
	getPlayerElem(Game,0,WhitePlayer),
	getPlayerElem(Game,1,BlackPlayer),
	
	getPoints(WhitePlayer,WhitePoints),
	getPoints(BlackPlayer,BlackPoints),
	
	WhitePoints >= 5,
	WhitePoints > BlackPoints.
	
%Black player wins with 5 points 
gameOver(Game,1):-
	getPlayerElem(Game,0,WhitePlayer),
	getPlayerElem(Game,1,BlackPlayer),
	
	getPoints(WhitePlayer,WhitePoints),
	getPoints(BlackPlayer,BlackPoints),
	
	BlackPoints >= 5,
	WhitePoints < BlackPoints.

%Draw between white and black players (both have 5 points) 
gameOver(Game,ActivePlayerColor):-
	getPlayerElem(Game,0,WhitePlayer),
	getPlayerElem(Game,1,BlackPlayer),
	
	getPoints(WhitePlayer,WhitePoints),
	getPoints(BlackPlayer,BlackPoints),
	
	WhitePoints >= 5,
	WhitePoints =:= BlackPoints,
	
	getActivePlayerColor(Game,ActivePlayerColor).

%White player wins because black player ran out of toid pieces on the board 
gameOver(Game,0):-	
	getPlayerElem(Game,1,BlackPlayer),
	
	getToidPieces(BlackPlayer,Toids),
	
	Toids =:= 12.

%Black player wins because white player ran out of toid pieces on the board  
gameOver(Game,1):-
	getPlayerElem(Game,0,WhitePlayer),
	
	getToidPieces(WhitePlayer,Toids),
	
	Toids =:= 12.
	
gameOver(_,none).
	

%=======================%
% Game movements
%=======================%

% Heads of the predicates that define the legal movements.
%Note: a piece on the position [i][j] can move to up 6 spaces: [i][j-1], [i][j+1], [i-1][j-1], [i-1][j], [i+1][j-1], [i+1][j]

%firstMove(+Decision, +Game, +Line-Col, +DestLine-DestCol, -NewGame).
% Executes the first move of a turn, taking into account the decision made by the player
firstMove(1,Game,Line-Col,DestLine-DestCol,NewGame):-
	moveToid(Game,Line-Col,DestLine-DestCol,NewGame).
firstMove(2,Game,_,_,NewGame):-
	skipFirstMove(Game,NewGame).

% Checks if the decision made regarding the first move is valid
validFirstMoveDecision(1).
validFirstMoveDecision(2).

%moveToid(+Game, +Line-Col, +DestLine-DestCol, -NewGame).
% Moves the toid on [Line][Column] to [DestLine][DestCol] if possible (checks if there's an adaptoid on [Line][Col] whose color matches the active player, if it has enough legs and free spaces to complete the movement).
moveToid(Game, Line-Col, DestLine-DestCol, NewGame):-
	%Get the board element
	getBoardElem(Game,Line-Col,Elem),
	
	%Check that the board element is a toid
	isToid(Elem),
	
	%Check that the toid is of the same color as the active player
	getActivePlayerColor(Game,ActivePlayerColor),
	getColor(Elem,ElemColor),
	ElemColor = ActivePlayerColor,
	
	%Get the toid's number of legs
	getLegs(Elem,Legs),

	%Check that the toid can move to DestLine-DestCol
	canMove(Game,Line-Col,DestLine-DestCol,Legs),
	
	%Attempt to capture the cell at [NewLine][NewCol]
	getBoardElem(Game,DestLine-DestCol,DestElem), 
	toidCapture(Game,Elem,DestElem,Winner,NewGame1),
	setBoardElem(NewGame1,Line-Col,none,NewGame2),
	setBoardElem(NewGame2,DestLine-DestCol,Winner,NewGame3),
	
	%Update the last first move
	setLastFirstMove(NewGame3,moveToid(Line-Col,DestLine-DestCol),NewGame).
	
%skipFirstMove(+Game,-NewGame).
% Skips the first move of the current turn
skipFirstMove(Game,NewGame):-
	%Update the last first move
	setLastFirstMove(Game,none,NewGame).

%secondMove(+Decision, +Game, +Line-Col, -NewGame).
% Executes the second move of a turn, taking into account the decision made by the player
secondMove(1,Game,Line-Col,NewGame):-
	addToid(Game,Line-Col,NewGame).
secondMove(2,Game,Line-Col,NewGame):-
	addPincer(Game,Line-Col,NewGame).	
secondMove(3,Game,Line-Col,NewGame):-
	addLeg(Game,Line-Col,NewGame).
secondMove(4,Game,_,NewGame):-
	skipSecondMove(Game,NewGame).

% Checks if the decision made regarding the first move is valid
validSecondMoveDecision(1).
validSecondMoveDecision(2).
validSecondMoveDecision(3).
validSecondMoveDecision(4).

%addToid(+Game, +Line-Col, -NewGame).
% Creates a new adaptoid which matches the active player's color and places it on on [Line][Col] if possible (check's for an adjacent toid of the same color, and if the player has an available toid piece).
addToid(Game, Line-Col, NewGame):- 
	%Get the board element
	getBoardElem(Game,Line-Col,Elem), 
	
	%Check that the board element is not a toid
	\+isToid(Elem),
	
	%Get the player element
	getActivePlayerColor(Game,PlayerColor),
	getPlayerElem(Game,PlayerColor,Player),
	
	%Check that the player has an available toid piece
	hasToidPieces(Player),
	
	%Check that an adjacent toid of the same color exists
	areAdjacent(Line-Col,Line2-Col2),
	getBoardElem(Game,Line2-Col2,Elem2),
	isToid(Elem2),
	getColor(Elem2,Elem2Color),
	Elem2Color = PlayerColor,
	
	%Place the toid on the board
	setBoardElem(Game,Line-Col,toid(PlayerColor,0,0),NewGame1),
	
	%Update the active player number of toid pieces
	decToidPieces(Player,NewPlayer),
	setPlayerElem(NewGame1,PlayerColor,NewPlayer,NewGame2),
	
	%Kill the hungry toids
	killHungryToids(NewGame2,NewGame3),
	
	%Update the last second move
	setLastSecondMove(NewGame3,addToid(Line-Col),NewGame).
	

%addPincer(+Game, +Line-Col, -NewGame).
% Adds a pincer to a toid at [Line][Col] if possible (checks if there's a toid on [Line][Col] of the active player's color with less than 6 members and if the player has an available pincer piece).
addPincer(Game,Line-Col,NewGame):-
	%Get the board element
	getBoardElem(Game,Line-Col,Elem), 
	
	%Check that the board element is a toid
	isToid(Elem),
	%Check that the toid has free slots
	hasFreeSlots(Elem),
	%Check that the toid is of the same color as the active player
	getActivePlayerColor(Game,PlayerColor),
	getColor(Elem,PlayerColor),
	
	%Get the player element
	getPlayerElem(Game,PlayerColor,Player),
	
	%Check that the player has an available pincer piece
	hasPincerPieces(Player),
	
	%Update the toid number of pincers
	incPincers(Elem,NewElem),
	setBoardElem(Game,Line-Col,NewElem,NewGame1),
	
	%Update the active player number of pincer pieces
	decPincerPieces(Player,NewPlayer),
	setPlayerElem(NewGame1,PlayerColor,NewPlayer,NewGame2),
	
	%Kill the hungry toids
	killHungryToids(NewGame2,NewGame3),
	
	%Update the last second move
	setLastSecondMove(NewGame3,addPincer(Line-Col),NewGame).
	
%addLeg(+Game, +Line-Col, -NewGame).
% Adds a leg to a toid at [Line][Col] if possible (checks if there's a toid on [Line][Col] of the active player's color with less than 6 members and if the player has an available leg piece).
addLeg(Game,Line-Col,NewGame):-
	%Get the board element
	getBoardElem(Game,Line-Col,Elem), 
	
	%Check that the board element is a toid
	isToid(Elem),
	%Check that the toid has free slots
	hasFreeSlots(Elem),
	%Check that the toid is of the same color as the active player
	getActivePlayerColor(Game,PlayerColor),
	getColor(Elem,ElemColor),
	ElemColor = PlayerColor,
	
	%Get the player element
	getPlayerElem(Game,PlayerColor,Player),
	
	%Check that the player has an available leg piece
	hasLegPieces(Player),
	
	%Update the toid number of legs
	incLegs(Elem,NewElem),
	setBoardElem(Game,Line-Col,NewElem,NewGame1),
	
	%Update the active player number of leg pieces
	decLegPieces(Player,NewPlayer),
	setPlayerElem(NewGame1,PlayerColor,NewPlayer,NewGame2),
	
	%Kill the hungry toids
	killHungryToids(NewGame2,NewGame3),
	
	%Update the last second move
	setLastSecondMove(NewGame3,addLeg(Line-Col),NewGame).
	
%skipSecondMove(+Game,-NewGame).
% Skips the second move of the current turn
skipSecondMove(Game,NewGame):-
	%Kill the hungry toids
	killHungryToids(Game,NewGame1),
	
	%Update the last second move
	setLastSecondMove(NewGame1,none,NewGame).
	
%restoreAllToidPieces(+Game,+Toid,-NewGame).
% Restores the toid pieces back to the player's inventory, when a toid from the said player is killed
restoreAllToidPieces(Game,Toid,NewGame):-
	%Get the toid's attributes
	getColor(Toid,Color),
	getPincers(Toid,Pincers),
	getLegs(Toid,Legs),
	
	%Get the toid's owner
	getPlayerElem(Game,Color,Player),
	
	%Update the player
	incToidPieces(Player,NewPlayer1),
	addPincerPieces(NewPlayer1,Pincers,NewPlayer2),
	addLegPieces(NewPlayer2,Legs,NewPlayer),
	setPlayerElem(Game,Color,NewPlayer,NewGame).
	
	
%toidCapture(+Game,+Toid1,+Toid2,-Winner,-NewGame).
% Toid from the active player tries to capture another toid, restoring the defeated toid pieces back to the owner's inventory and giving 1 point to the winning player 
toidCapture(Game,Toid1,none,Toid1,Game).
toidCapture(Game,Toid1,Toid2,Toid1,NewGame):-
	%Get both toid colors
	getColor(Toid1,Color1),
	getColor(Toid2,Color2),
	
	%Check that the toids have diferent colors
	Color1 \= Color2,
	
	%Check that one of the toids wins and get the winner's color
	toidFight(Toid1,Toid2,Toid1),
	
	%Get the winning player
	getPlayerElem(Game,Color1,WinnerPlayer),
	
	%Update the winning player
	incPoints(WinnerPlayer,NewWinnerPlayer),
	setPlayerElem(Game,Color1,NewWinnerPlayer,NewGame1),
		
	%Update the losing player
	restoreAllToidPieces(NewGame1,Toid2,NewGame).
toidCapture(Game,Toid1,Toid2,Toid2,NewGame):-
	%Get both toid colors
	getColor(Toid1,Color1),
	getColor(Toid2,Color2),
	
	%Check that the toids have diferent colors
	Color1 \= Color2,
	
	%Check that one of the toids wins and get the winner's color
	toidFight(Toid1,Toid2,Toid2),
	
	%Get the winning player
	getPlayerElem(Game,Color2,WinnerPlayer),
	
	%Update the winning player
	incPoints(WinnerPlayer,NewWinnerPlayer),
	setPlayerElem(Game,Color2,NewWinnerPlayer,NewGame1),
	
	%Update the losing player
	restoreAllToidPieces(NewGame1,Toid1,NewGame).
toidCapture(Game,Toid1,Toid2,none,NewGame):-
	%Get both toid colors
	getColor(Toid1,Color1),
	getColor(Toid2,Color2),
	
	%Check that the toids have diferent colors
	Color1 \= Color2,
	
	%Check that one of the toids wins and get the winner's color
	toidFight(Toid1,Toid2,none),
	
	%Update Toid1Player
	getPlayerElem(Game,Color1,Toid1Player),
	incPoints(Toid1Player,NewToid1Player),
	setPlayerElem(Game,Color1,NewToid1Player,NewGame1),
	restoreAllToidPieces(NewGame1,Toid1,NewGame2),
	
	%Update Toid2Player
	getPlayerElem(NewGame2,Color2,Toid2Player),
	incPoints(Toid2Player,NewToid2Player),
	setPlayerElem(NewGame2,Color2,NewToid2Player,NewGame3),
	restoreAllToidPieces(NewGame3,Toid2,NewGame).
	
%getAllValidCells(-ListOfValidCells).
% Retrieves all the valid cells
getAllValidCells([1-1,1-2,1-3,1-4,2-1,2-2,2-3,2-4,2-5,3-1,3-2,3-3,3-4,3-5,3-6,4-1,4-2,4-3,4-4,4-5,4-6,4-7,5-1,5-2,5-3,5-4,5-5,5-6,6-1,6-2,6-3,6-4,6-5,7-1,7-2,7-3,7-4]).
	
%killHungryToids(+Game,-NewGame).
% Kills hungry toids, removing them from the board, back to their owner's inventories. A player gains 1 point every time a toid from it's opponent is captured 
killHungryToids(Game,NewGame):- 
	getAllValidCells(BoardCells),
	killHungryToids_(Game,BoardCells,NewGame).
	
%killHungryToids_(+Game,+CellsToProcess,-NewGame).
killHungryToids_(Game,[],Game). 
killHungryToids_(Game,[Line-Col|T],NewGame):-
	%Get the board element
	getBoardElem(Game,Line-Col,Elem),

	%Check that the cell is empty
	Elem = none,
	
	killHungryToids_(Game,T,NewGame).
killHungryToids_(Game,[Line-Col|T],NewGame):-
	%Get the board element
	getBoardElem(Game,Line-Col,Elem),
	
	%Check that the element belongs to the active player
	getColor(Elem,Color),
	getActivePlayerColor(Game,ActivePlayerColor),
	Color = ActivePlayerColor,
	
	killHungryToids_(Game,T,NewGame).
killHungryToids_(Game,[Line-Col|T],NewGame):-
	%Get the board element
	getBoardElem(Game,Line-Col,Elem),
	
	%Check that the element does not belong to the active player
	getColor(Elem,Color),
	getActivePlayerColor(Game,ActivePlayerColor),
	Color \= ActivePlayerColor,
	
	%Check that the toid is fed
	getNumMembers(Elem,NumMembers),
	countFreeAdjacentSpaces(Game,Line-Col,NumSpaces),
	NumSpaces >= NumMembers,
	
	killHungryToids_(Game,T,NewGame).
killHungryToids_(Game,[Line-Col|T],NewGame):-
	%Get the board element
	getBoardElem(Game,Line-Col,Elem),
	
	%Check that the element does not belong to the active player
	getColor(Elem,Color),
	getActivePlayerColor(Game,ActivePlayerColor),
	Color \= ActivePlayerColor,
	
	%Check that the toid is not fed
	getNumMembers(Elem,NumMembers),
	countFreeAdjacentSpaces(Game,Line-Col,NumSpaces),
	NumSpaces < NumMembers,
	
	%Remove the toid from the game
	setBoardElem(Game,Line-Col,none,NewGame1),
	
	%Give the toid's owner its pieces
	restoreAllToidPieces(NewGame1,Elem,NewGame2),
	
	%Update the active player
	getPlayerElem(NewGame2,ActivePlayerColor,ActivePlayer),
	incPoints(ActivePlayer,NewActivePlayer),
	setPlayerElem(NewGame2,ActivePlayerColor,NewActivePlayer,NewGame3),
	
	killHungryToids_(NewGame3,T,NewGame).
	
	
%switchActivePlayer(+Game,-NewGame).
% Switch the game's active player
switchActivePlayer(Game,NewGame):-
	getActivePlayerColor(Game,ActivePlayerColor),
	getEnemyPlayerColor(ActivePlayerColor,EnemyPlayerColor),
	setActivePlayerColor(Game,EnemyPlayerColor,NewGame).
	
%Other methods

%getEnemyPlayerColor(+PlayerColor,-EnemyPlayerColor).
% Retrieves the enemy player color.
getEnemyPlayerColor(0,1).
getEnemyPlayerColor(1,0).

%getNumberofCols(+Line,-NCols).
% Retrieves the number of columns from each line of the board
getNumberofCols(1,4).
getNumberofCols(2,5).
getNumberofCols(3,6).
getNumberofCols(4,7).
getNumberofCols(5,6).
getNumberofCols(6,5).
getNumberofCols(7,4).

%isValidCell(+Line-Col)
% Checks if it's a valid cell
isValidCell(Line-Col):-
	integer(Line),
	integer(Col),
	Line >= 1,
	Line =< 7,
	Col >= 1,
	getNumberofCols(Line,MaxCol),
	Col =< MaxCol.
	
%areAdjacent(+Line1-Col1,?Line2-Col2).
% Checks if two cells are adjacent 
areAdjacent(Line1-Col1,Line2-Col2):-
	getAdjacentCells(Line1-Col1,Adjs),
	member(Line2-Col2,Adjs),
	isValidCell(Line2-Col2).

% getAdjacentCells(+Line-Col,-Adjs)
% Retrieves a list with every cell adjacent to the argument Line-Col
getAdjacentCells(Line-Col,[LULine-LUCol,RULine-RUCol,LLine-LCol,RLine-RCol,LLLine-LLCol,RLLine-RLCol]):-
	Line < 4,
	
	%Left Upper Cell
	LULine is Line - 1,
	LUCol is Col - 1,
	
	%Right Upper Cell
	RULine is Line - 1,
	RUCol is Col,
	
	%Left Cell
	LLine is Line,
	LCol is Col - 1,
	
	%Right Cell
	RLine is Line,
	RCol is Col + 1,
	
	%Left Lower Cell
	LLLine is Line + 1,
	LLCol is Col,
	
	%Right Lower Cell
	RLLine is Line + 1,
	RLCol is Col + 1.
	
getAdjacentCells(Line-Col,[LULine-LUCol,RULine-RUCol,LLine-LCol,RLine-RCol,LLLine-LLCol,RLLine-RLCol]):-
	Line =:= 4,
	
	%Left Upper Cell
	LULine is Line - 1,
	LUCol is Col - 1,
	
	%Right Upper Cell
	RULine is Line - 1,
	RUCol is Col,
	
	%Left Cell
	LLine is Line,
	LCol is Col - 1,
	
	%Right Cell
	RLine is Line,
	RCol is Col + 1,
	
	%Left Lower Cell
	LLLine is Line + 1,
	LLCol is Col - 1,
	
	%Right Lower Cell
	RLLine is Line + 1,
	RLCol is Col.
	
getAdjacentCells(Line-Col,[LULine-LUCol,RULine-RUCol,LLine-LCol,RLine-RCol,LLLine-LLCol,RLLine-RLCol]):-
	Line > 4,
	
	%Left Upper Cell
	LULine is Line - 1,
	LUCol is Col,
	
	%Right Upper Cell
	RULine is Line - 1,
	RUCol is Col + 1,
	
	%Left Cell
	LLine is Line,
	LCol is Col - 1,
	
	%Right Cell
	RLine is Line,
	RCol is Col + 1,
	
	%Left Lower Cell
	LLLine is Line + 1,
	LLCol is Col - 1,
	
	%Right Lower Cell
	RLLine is Line + 1,
	RLCol is Col.

	
%canMove(+Game,+Line-Col,+DestLine-DestCol,+NumMoves).
% Checks if a toid can move to another cell
canMove(_,Line-Col,DestLine-DestCol,1):-
	areAdjacent(Line-Col,DestLine-DestCol).
canMove(Game,Line-Col,DestLine-DestCol,NumMoves):-
	NumMoves > 1,
	areAdjacent(Line-Col,MidLine-MidCol),
	getBoardElem(Game,MidLine-MidCol,MidElem),
	\+isToid(MidElem),
	NewNumMoves is NumMoves - 1,
	canMove(Game,MidLine-MidCol,DestLine-DestCol,NewNumMoves).
	
%countFreeAdjacentSpaces(+Game,+Line-Col,-NumSpaces).
% Retrieves the number of empty cells adjacent to the cell Line-Col
countFreeAdjacentSpaces(Game,Line-Col,NumSpaces):-
	findall(X-Y,
	(
	areAdjacent(Line-Col,X-Y),
	getBoardElem(Game,X-Y,Elem),
	\+isToid(Elem)
	),
	FreeAdjacentSpaces),
	getListLength(FreeAdjacentSpaces, NumSpaces).
	
%countUnfedActiveToids(+Game,-NumUnfed).
% Retrieves the number of unfed active toids in the current turn
countUnfedActiveToids(Game,NumUnfed):-
	getActivePlayerColor(Game,ActivePlayerColor),

	findall(X-Y,
	(
	getAllValidCells(Cells),
	member(X-Y,Cells),
	getBoardElem(Game,X-Y,Elem),
	isToid(Elem),
	getColor(Elem,ActivePlayerColor),
	
	getNumMembers(Elem,NumMembers),
	countFreeAdjacentSpaces(Game,X-Y,NumSpaces),
	NumMembers > NumSpaces
	),
	UnfedActiveToids),
	
	getListLength(UnfedActiveToids, NumUnfed).
