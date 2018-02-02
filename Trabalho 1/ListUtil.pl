%=======================================================================================================================%
% ListUtil.pl - Module with predicates for manipulating and accessing uni and bidimensional lists.
%=======================================================================================================================%

%=======================%
% For 1D lists
%=======================%

% getListElem(+I,-Value,+List).
% Retrieves an element from a 1D list.
getListElem(0,H,[H|_]).
getListElem(I,Value,[_|T]):-
	I > 0,
	I1 is I - 1,
	getListElem(I1,Value,T).

% setListElem(+I,+NewValue,+List,-NewList).
% Sets an element from a 1D list.
setListElem(0,NewValue,[_|T],[NewValue|T]).
setListElem(I,NewValue,[H|T],[H|NewT]):-
	I > 0,
	I1 is I - 1,
	setListElem(I1,NewValue,T,NewT).
	
% getListLength(+List,-Length).
% Retrieves a 1D list's length.
getListLength(L,Len):- getListLength_(L,0,Len).

% getListLength_(+List,+Acc,-Length).
% Auxiliary predicate for getListLength/2.
getListLength_([],Len,Len).
getListLength_([_|T],Acc,Len):-
	NewAcc is Acc + 1,
	getListLength_(T,NewAcc,Len).
	

%=======================%
% For 2D lists
%=======================%

% getList2dElem(+LinI-ColI,-Value,+List).
% Retrieves an element from a 2D list.
getList2dElem(0-ColI,Value,[H|_]):-getListElem(ColI,Value,H).
getList2dElem(LinI-ColI,Value,[_|T]):-
	LinI > 0,
	LinI1 is LinI - 1,
	getList2dElem(LinI1-ColI,Value,T).
	
% setList2dElem(+LinI-ColI,+NewValue,+List,-NewList).
% Sets an element from a 2D list.
setList2dElem(0-ColI,NewValue,[H|T],[NewH|T]):-setListElem(ColI,NewValue,H,NewH).
setList2dElem(LinI-ColI,Value,[H|T],[H|NewT]):-
	LinI > 0,
	LinI1 is LinI - 1,
	setList2dElem(LinI1-ColI,Value,T,NewT).