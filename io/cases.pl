:- module(cases, [title/1, case/3]).
:- use_module('../prolog/charpar').
:- use_module(engine).
title('charpar').
costs_g(Cs) :- rnd_int(1, 8, N), length(Cs, N), maplist([C]>>rnd_int(1, 9, C), Cs).
goals_g(N, Gs) :- Top is N - 1, numlist(0, Top, Is), maplist([I, G]>>( rnd_pick([s, c, m], K), ( K == s -> G = succ_char(I) ; K == c -> G = copy_char(I) ; G = sum_chars(Is) ) ), Is, Gs).
in_g(N, In) :- length(In, N), maplist([X]>>rnd_int(0, 25, X), In).
case(schedule, [Cs, W], schedule) :- costs_g(Cs), rnd_int(1, 4, W).
case(makespan, [Cs, A], makespan) :- costs_g(Cs), rnd_int(1, 3, W), schedule(Cs, W, A).
case(run_parallel, [Gs, W, In], run_parallel) :- rnd_int(1, 5, N), goals_g(N, Gs), rnd_int(1, 4, W), in_g(N, In).
case(speedup, [Cs, W], speedup) :- costs_g(Cs), rnd_int(1, 4, W).
% the speed-up the schedule gives: total work over makespan, and the makespan
speedup(Cs, W, sum_over_makespan(T, M)) :- schedule(Cs, W, A), makespan(Cs, A, M), sum_list(Cs, T).
