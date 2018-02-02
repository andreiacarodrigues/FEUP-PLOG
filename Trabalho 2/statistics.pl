:- use_module(library(clpfd)).

reset_timer :- statistics(walltime,_).	
print_time :-
	statistics(walltime,[_,T]),
	TS is ((T//10)*10)/1000,
	nl, write('Time: '), write(TS), write('s'), nl, nl.
get_time(TS):-
	statistics(walltime,[_,T]),
	TS is ((T//10)*10)/1000.

