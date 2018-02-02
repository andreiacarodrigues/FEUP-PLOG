:-use_module(library(lists)).

:-include('printer.pl').
:-include('solver.pl').

%Printing version

generatePuzzlePrintMe(NLines,NCols,NClouds,NLineClues,NColClues,LineClues,ColClues):-
	generateClouds(NLines,NCols,NClouds,Lines),
	print_time,
	fd_statistics,
	
	getCompleteCluesList(Lines,CompleteLinesClues),
	transpose(Lines,Cols),
	getCompleteCluesList(Cols,CompleteColsClues),
	printClouds(CompleteLinesClues,CompleteColsClues,Lines), nl,
	
	listBetween(1,NLines,HideLines),
	random_permutation(HideLines,HideLines1),
	NHiddenLineClues is NLines - NLineClues,
	prefix_length(HideLines1,HideLines2,NHiddenLineClues),
	createFinalClues(CompleteLinesClues,1,HideLines2,LineClues),
	
	listBetween(1,NCols,HideCols),
	random_permutation(HideCols,HideCols1),
	NHiddenColClues is NCols - NColClues,
	prefix_length(HideCols1,HideCols2,NHiddenColClues),
	createFinalClues(CompleteColsClues,1,HideCols2,ColClues).

generatePuzzle(NLines,NCols,NClouds,NLineClues,NColClues,LineClues,ColClues):-
	generateClouds(NLines,NCols,NClouds,Lines),
	
	getCompleteCluesList(Lines,CompleteLinesClues),
	transpose(Lines,Cols),
	getCompleteCluesList(Cols,CompleteColsClues),
	
	listBetween(1,NLines,HideLines),
	random_permutation(HideLines,HideLines1),
	NHiddenLineClues is NLines - NLineClues,
	prefix_length(HideLines1,HideLines2,NHiddenLineClues),
	createFinalClues(CompleteLinesClues,1,HideLines2,LineClues),
	
	listBetween(1,NCols,HideCols),
	random_permutation(HideCols,HideCols1),
	NHiddenColClues is NCols - NColClues,
	prefix_length(HideCols1,HideCols2,NHiddenColClues),
	createFinalClues(CompleteColsClues,1,HideCols2,ColClues).
	
generateClouds(NLines,NCols,NClouds,Lines):-
	length(CloudsXi,NClouds),
	length(CloudsW,NClouds),
	length(CloudsYi,NClouds),
	length(CloudsH,NClouds),
	
	MaxXi is NCols - 1,
	MaxYi is NLines - 1,
	MaxW is NCols + 1,
	MaxH is NLines + 1,
	domain(CloudsXi,1,MaxXi),
	domain(CloudsW,3,MaxW),
	domain(CloudsYi,1,MaxYi),
	domain(CloudsH,3,MaxH),
	
	makeCloudList(CloudsXi,CloudsW,CloudsYi,CloudsH,Clouds),
	disjoint2(Clouds),
	checkCloudsInBounds(NLines,NCols,Clouds),
	checkCloudsOrdered(Clouds),
		
	getMatrix(1,NLines,NCols,Clouds,Lines),
	
	NoSym #= 1,
	checkNoDiagonalSymetry(1-1,NLines,NCols,Lines,NoSym),
	
	append(CloudsXi,CloudsW,L1),
	append(L1,CloudsYi,L2),
	append(L2,CloudsH,CloudsVars),
	reset_timer,
	labeling([ffc,value(myValueSelector)],CloudsVars).

myValueSelector(Var, _Rest, BB, BB1) :-
    fd_set(Var, Set),
    selectRandValue(Set, Value),
    (   
        first_bound(BB, BB1), Var #= Value
        ;   
        later_bound(BB, BB1), Var #\= Value
    ).

selectRandValue(Set, RandValue):-
    fdset_to_list(Set, Lis),
    length(Lis, Len),
    random(0, Len, RandomIndex),
    nth0(RandomIndex, Lis, RandValue).
	
makeCloudList([],[],[],[],[]).
makeCloudList([Xi|Xis],[W|Ws],[Yi|Yis],[H|Hs],[cloud(Xi,W,Yi,H)|Cs]):-
	makeCloudList(Xis,Ws,Yis,Hs,Cs).

checkCloudsInBounds(_,_,[]).
checkCloudsInBounds(NLines,NCols,[cloud(Xi,W,Yi,H)|Cs]):-
	(Xi + W - 2) #=< NCols,
	(Yi + H - 2) #=< NLines,
	checkCloudsInBounds(NLines,NCols,Cs).
	
checkCloudsOrdered([_]).
checkCloudsOrdered([cloud(Xi,_,Yi,_),cloud(Xi2,W2,Yi2,H2)|Cs]):-
	(Yi #< Yi2) #\/ ( (Yi #= Yi2) #/\ (Xi #< Xi2) ),
	checkCloudsOrdered([cloud(Xi2,W2,Yi2,H2)|Cs]).
	
checkNoDiagonalSymetry(LineIdx-_,NLines,_,_,0):-
	LineIdx > div(NLines,2).
checkNoDiagonalSymetry(LineIdx-ColIdx,NLines,NCols,Lines,NoSym):-
	LineIdx =< div(NLines,2),
	ColIdx > NCols,
	
	L1 is LineIdx + 1,
	checkNoDiagonalSymetry(L1-1,NLines,NCols,Lines,NoSym).
checkNoDiagonalSymetry(LineIdx-ColIdx,NLines,NCols,Lines,NoSym):-
	LineIdx =< div(NLines,2),
	ColIdx =< NCols,
	
	checkColor(Lines,LineIdx-ColIdx,Color),
	OppLine is NLines - LineIdx + 1,
	OppCol is NCols - ColIdx + 1,
	checkColor(Lines,OppLine-OppCol,OppColor),
	
	NoSym #<=> (NoSym1 #\/ (Color #\= OppColor)),
	
	C1 is ColIdx + 1,
	checkNoDiagonalSymetry(LineIdx-C1,NLines,NCols,Lines,NoSym1).
	
%%
	
getMatrix(LineIdx,NLines,_,_,[]):-
	LineIdx > NLines.
getMatrix(LineIdx,NLines,NCols,Clouds,[Line|Ls]):-
	LineIdx =< NLines,
	getLine(LineIdx-1,NCols,Clouds,Line),
	L1 is LineIdx + 1,
	getMatrix(L1,NLines,NCols,Clouds,Ls).
	
getLine(_-ColIdx,NCols,_,[]):-
	ColIdx > NCols.
getLine(LineIdx-ColIdx,NCols,Clouds,[Cell|Cs]):-
	ColIdx =< NCols,
	setColor(LineIdx-ColIdx,Clouds,Color),
	Cell in 0..1,
	Cell #= Color,
	C1 is ColIdx + 1,
	getLine(LineIdx-C1,NCols,Clouds,Cs).
	
setColor(_,[],0).
setColor(LineIdx-ColIdx,[C|Cs],Color):-
	isInsideCloud(LineIdx-ColIdx,C,IsInside),
	IsInside #=> (Color #= 1),
	#\IsInside #=> (Color #= Color1),
	setColor(LineIdx-ColIdx,Cs,Color1).
	
isInsideCloud(LineIdx-ColIdx,cloud(Xi,W,Yi,H),IsInside):-
	MaxXi #= Xi+W-2,
	MaxYi #= Yi+H-2,
	
	((LineIdx #>= Yi) #/\ (LineIdx #=< MaxYi) #/\ (ColIdx #>= Xi) #/\ (ColIdx #=< MaxXi)) #<=> IsInside. 
	
%%	
	
getCompleteCluesList([],[]).
getCompleteCluesList([Line|Ls],[Clue|Cs]):-
	sumlist(Line,Clue),
	getCompleteCluesList(Ls,Cs).
	
%%
	
listBetween(A,A,[A]).
listBetween(A,B,[A|Ls]):-
	A < B,
	A1 is A + 1,
	listBetween(A1,B,Ls).
	
%%

createFinalClues(CompleteClues,Idx,_,[]):-
	length(CompleteClues,NClues),
	Idx > NClues.
	
createFinalClues(CompleteClues,Idx,ToHide,[none|Fs]):-
	length(CompleteClues,NClues),
	Idx =< NClues,
	member(Idx,ToHide),
	
	Idx1 is Idx + 1,
	createFinalClues(CompleteClues,Idx1,ToHide,Fs).
	
createFinalClues(CompleteClues,Idx,ToHide,[Clue|Fs]):-
	length(CompleteClues,NClues),
	Idx =< NClues,
	\+member(Idx,ToHide),
	
	nth1(Idx,CompleteClues,Clue),
	
	Idx1 is Idx + 1,
	createFinalClues(CompleteClues,Idx1,ToHide,Fs).
	