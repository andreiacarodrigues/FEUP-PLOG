%=======================================================================================================================%
% Player.pl - Module with predicates for manipulation and access to the player/4 data structure.
%=======================================================================================================================%

%player(+points,+toids,+pincers,+legs).

%=======================%
% Getters
%=======================%

% getPoints(+Player,-Points).
% Retrieves the player's number of points.
getPoints(player(Points,_,_,_),Points).

% getToidPieces(+Player,-Toids).
% Retrieves the player's number of toid pieces.
getToidPieces(player(_,Toids,_,_),Toids).

% getPincerPieces(+Player,-Pincers).
% Retrieves the player's number of pincer pieces.
getPincerPieces(player(_,_,Pincers,_),Pincers).

% getLegPieces(+Player,-Legs).
% Retrieves the player's number of leg pieces.
getLegPieces(player(_,_,_,Legs),Legs).

%=======================%
% Setters
%=======================%

% incPoints(+Player,-NewPlayer).
% Adds a point to the given player.
incPoints(player(Points,Toids,Pincers,Legs),player(NewPoints,Toids,Pincers,Legs)):-
	NewPoints is Points + 1.
	
% incToidPieces(+Player,-NewPlayer).
% Adds a toid piece to the given player.
incToidPieces(player(Points,Toids,Pincers,Legs),player(Points,NewToids,Pincers,Legs)):-
	NewToids is Toids + 1.
	
% decToidPieces(+Player,-NewPlayer).
% Removes a toid piece from the given player.
decToidPieces(player(Points,Toids,Pincers,Legs),player(Points,NewToids,Pincers,Legs)):-
	NewToids is Toids - 1.
	
% addPincerPieces(+Player,+NumPieces,-NewPlayer).
% Adds pincer pieces to the given player.
addPincerPieces(player(Points,Toids,Pincers,Legs),NumPieces,player(Points,Toids,NewPincers,Legs)):-
	NewPincers is Pincers + NumPieces.

% decPincerPieces(+Player,-NewPlayer).
% Removes a pincer piece from the given player.
decPincerPieces(player(Points,Toids,Pincers,Legs),player(Points,Toids,NewPincers,Legs)):-
	NewPincers is Pincers - 1.
	
% addLegPieces(+Player,+NumPieces,-NewPlayer).
% Adds leg pieces to the given player.
addLegPieces(player(Points,Toids,Pincers,Legs),NumPieces,player(Points,Toids,Pincers,NewLegs)):-
	NewLegs is Legs + NumPieces.
	
% decLegPieces(+Player,-NewPlayer).
% Removes a leg piece from the given player.
decLegPieces(player(Points,Toids,Pincers,Legs),player(Points,Toids,Pincers,NewLegs)):-
	NewLegs is Legs - 1.
	
%=======================%
% Misc. predicates
%=======================%
	
% hasToidPieces(+Player).
% Checks if a player has available toid pieces.
hasToidPieces(player(_,Toids,_,_)):- Toids > 0.

% hasPincerPieces(+Player).
% Checks if a player has available pincer pieces.
hasPincerPieces(player(_,_,Pincers,_)):- Pincers > 0.

% hasLegPieces(+Player).
% Checks if a player has available leg pieces.
hasLegPieces(player(_,_,_,Legs)):- Legs > 0.