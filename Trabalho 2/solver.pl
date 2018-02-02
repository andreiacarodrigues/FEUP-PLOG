:-use_module(library(lists)).
:-use_module(library(clpfd)).

:-include('utilities.pl').
:-include('statistics.pl').
	
solveClouds(LineClues,ColClues,Lines,Opts):-
	%Define the matrix dimensions and the variables
	length(LineClues,NLines),
	length(ColClues,NCols),
	length(Lines,NLines),
	defineMatrix(Lines,NCols),
	
	%Define that the number of shaded cells in each line must respect the line clues
	checkLines(LineClues,Lines),
	
	%Define that the number of shaded cells in each column must respect the column clues
	transpose(Lines,Cols),
	checkLines(ColClues,Cols),
	
	%Define that the shaded cells must be organized into disjoint clouds
	checkClouds(Lines,Cols,NLines,NCols,1-1),
	
	append(Lines,Vars),

	reset_timer,
	labeling(Opts,Vars).
	
%%
	
defineMatrix([],_).
defineMatrix([Line|Ls],NCols):-
	length(Line,NCols),
	domain(Line,0,1),
	defineMatrix(Ls,NCols).

%%
	
checkLines([],[]).
checkLines([Clue|Cs],[Line|Ls]):-
	checkClue(Line,Clue),
	checkLines(Cs,Ls).
	
checkClue(_,none):- !.
checkClue(Line,Clue):-
	Clue \= none, !,
	sum(Line,#=,Clue).	
	
%%

checkClouds(_,_,NLines,_,LineIdx-_):-
	LineIdx > NLines.
checkClouds(Lines,Cols,NLines,NCols,LineIdx-ColIdx):-
	LineIdx =< NLines,
	ColIdx > NCols,
	
	L1 is LineIdx + 1,
	checkClouds(Lines,Cols,NLines,NCols,L1-1).
checkClouds(Lines,Cols,NLines,NCols,LineIdx-ColIdx):-
	LineIdx =< NLines, 
	ColIdx =< NCols,
		
	checkCloudULC(Lines,LineIdx-ColIdx,IsCloudULC),
	IsCorrectCloud #<= IsCloudULC,
	checkCorrectCloud(Lines,Cols,NLines,NCols,LineIdx-ColIdx,IsCorrectCloud),
	
	C1 is ColIdx + 1,
	checkClouds(Lines,Cols,NLines,NCols,LineIdx-C1).
	
checkColor(Lines,LineIdx-ColIdx,Color):-
	getList2dElem(LineIdx-ColIdx,Color,Lines), !.
checkColor(Lines,LineIdx-ColIdx,0):-
	\+getList2dElem(LineIdx-ColIdx,_,Lines).

checkCloudULC(Lines,LineIdx-ColIdx,IsCloudULC):-
	LineIdx > 0, ColIdx > 0,
	L1 is LineIdx - 1, C1 is ColIdx - 1,
	
	checkColor(Lines,LineIdx-ColIdx,Color),
	checkColor(Lines,L1-ColIdx,ColorUp),
	checkColor(Lines,LineIdx-C1,ColorLeft),
	
	((Color #= 1) #/\ (ColorUp #= 0) #/\ (ColorLeft #= 0)) #<=> IsCloudULC.

%
	
checkCorrectCloud(Lines,Cols,NLines,NCols,LineIdx-ColIdx,IsCorrectCloud):-
	countShadedLine(Lines,NCols,LineIdx-ColIdx,CloudWidth),
	countShadedLine(Cols,NLines,ColIdx-LineIdx,CloudHeight),
	
	L1 is LineIdx - 1, C1 is ColIdx - 1,
	countUnshadedLine(Lines,NCols,L1-C1,CloudTopWidth),
	countUnshadedLine(Cols,NLines,C1-L1,CloudSideHeight),
	checkRectHeight(Lines,NLines,NCols,LineIdx-ColIdx,CloudWidth,RectHeight),
	checkRectHeight(Cols,NCols,NLines,ColIdx-LineIdx,CloudHeight,RectWidth),
	
	((CloudWidth #>= 2) #/\ (CloudHeight #>= 2) #/\ (CloudTopWidth #>= CloudWidth + 2) #/\ (CloudSideHeight #>= CloudHeight + 2) #/\ (CloudHeight #= RectHeight) #/\ (CloudWidth #= RectWidth)) #<=> IsCorrectCloud.
	
countShadedLine(_,NCols,_-ColIdx,0):-
	ColIdx > NCols.
countShadedLine(Lines,NCols,LineIdx-ColIdx,Width):-
	ColIdx =< NCols,
	checkColor(Lines,LineIdx-ColIdx,Color),
	
	(Width #= 0) #<= (Color #= 0),
	(Width #= W1 + 1) #<= (Color #= 1),
	
	C1 is ColIdx + 1,
	countShadedLine(Lines,NCols,LineIdx-C1,W1).

countUnshadedLine(_,NCols,_-ColIdx,1):-
	ColIdx > NCols.
countUnshadedLine(Lines,NCols,LineIdx-ColIdx,Width):-
	ColIdx =< NCols,
	checkColor(Lines,LineIdx-ColIdx,Color),
	
	(Width #= 0) #<= (Color #= 1),
	(Width #= W1 + 1) #<= (Color #= 0),
	
	C1 is ColIdx + 1,
	countUnshadedLine(Lines,NCols,LineIdx-C1,W1).
	

checkRectHeight(_,NLines,_,LineIdx-_,_,0):-
	LineIdx > NLines.
checkRectHeight(Lines,NLines,NCols,LineIdx-ColIdx,CloudWidth,Height):-
	LineIdx =< NLines,
	countShadedLine(Lines,NCols,LineIdx-ColIdx,Width),
	
	(Height #= 0) #<= (CloudWidth #\= Width),
	(Height #= H1 + 1) #<= (CloudWidth #= Width),
	
	L1 is LineIdx + 1,
	checkRectHeight(Lines,NLines,NCols,L1-ColIdx,CloudWidth,H1).
	