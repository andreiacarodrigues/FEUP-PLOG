:-use_module(library(lists)).
:-use_module(library(random)).

% getList2dElem(+LinI-ColI,-Value,+List).
% Retrieves an element from a 2D list.
getList2dElem(1-ColI,Value,[H|_]):- nth1(ColI,H,Value).
getList2dElem(LinI-ColI,Value,[_|T]):-
	LinI > 1,
	%write('LinI = '),
	%fd_dom(LinI,D1), write(D1), nl,
	%write('ColI = '),
	%fd_dom(ColI,D2), write(D2), nl,
	LinI1 is LinI - 1,
	getList2dElem(LinI1-ColI,Value,T).

rand2(L,U,R):-
	random(L,U,R).
rand2(L,U,R):-
	!, rand2(L,U,R).