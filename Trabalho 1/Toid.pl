%=======================================================================================================================%
% Toid.pl - Module with predicates for manipulation and access to the toid/3 data structure.
%=======================================================================================================================%

%toid(Color,Pincers,Legs).

%=======================%
% Getters
%=======================%

% getColor(+Toid,-Color).
% Retrieves the toid's color.
getColor(toid(Color,_,_),Color).

% getPincers(+Toid,-Pincers).
% Retrieves the toid's number of pieces.
getPincers(toid(_,Pincers,_),Pincers).

% getLegs(+Toid,-Legs).
% Retrieves the toid's number of legs.
getLegs(toid(_,_,Legs),Legs).

% getNumMembers(+Toid,-NumMembers).
% Retrieves the toid's total number of members (pincers and legs).
getNumMembers(toid(_,Pincers,Legs),NumMembers):- 
	NumMembers is Pincers + Legs.

%=======================%
% Setters
%=======================%

% incPincers(+Toid,-NewToid).
% Adds a pincer to the given toid.
incPincers(toid(Color,Pincers,Legs),toid(Color,NewPincers,Legs)):-
	NewPincers is Pincers + 1.
	
% incLegs(+Toid,-NewToid).
% Adds a leg to the given toid.
incLegs(toid(Color,Pincers,Legs),toid(Color,Pincers,NewLegs)):-
	NewLegs is Legs + 1.
	
%=======================%
% Misc. predicates
%=======================%

% isToid(+Object).
% Checks if its argument is a toid (used for checking if a board cell is not empty).
isToid(toid(_,_,_)).
	
% hasFreeSlots(+Toid).
% Checks if the toid has free slots, in order to insert an additional pincer or leg.
hasFreeSlots(toid(_,Pincers,Legs)):- 
	NumSlots is Pincers + Legs, NumSlots < 6.	
	
% toidFight(+Toid1,+Toid2,-Winner).
% Returns the winner (if any) of the fight between two toids.
toidFight(Toid1,Toid2,Toid1):-
	getPincers(Toid1,Pincers1),
	getPincers(Toid2,Pincers2),
	Pincers1 > Pincers2.
toidFight(Toid1,Toid2,Toid2):-
	getPincers(Toid1,Pincers1),
	getPincers(Toid2,Pincers2),
	Pincers1 < Pincers2.
toidFight(Toid1,Toid2,none):-
	getPincers(Toid1,Pincers1),
	getPincers(Toid2,Pincers2),
	Pincers1 =:= Pincers2.