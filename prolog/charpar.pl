% charpar: plop2's per-character programs don't depend on each other, so they can run at the
% same time. charpar schedules the character jobs onto W workers (longest job first, Graham's
% LPT rule), runs them on threads, and gives the same output as running them one by one.
% A job is Cost-Goal, where Goal is called as call(Goal, Input, Char).
%?- schedule([5,3,3,2,2,2], 2, A), makespan([5,3,3,2,2,2], A, M).   % M = 9 (optimal)
%?- run_sequential([succ_char(0), succ_char(1)], [1,5], Out).        % Out = [2,6]
%?- run_parallel([succ_char(0), succ_char(1)], 2, [1,5], Out).       % the same, on 2 threads
:- module(charpar, [schedule/3, makespan/3, loads/4, optimal_makespan/3, run_sequential/3, run_parallel/4, succ_char/3, copy_char/3, sum_chars/3]).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(thread)).

% schedule(+Costs, +Workers, -Assignment): Assignment lists the worker (1..W) for each job, in job order.
schedule(Costs, W, A) :-
    length(Costs, N), numlist(1, N, Js), pairs_keys_values(P0, Costs, Js),
    sort(1, @>=, P0, Sorted),                      % longest first (stable for ties)
    length(L0, W), maplist(=(0), L0),
    foldl(place, Sorted, L0-[], _-Placed),
    msort(Placed, ByJob), pairs_values(ByJob, A0), A = A0.
place(C-J, L0-P0, L-[J-Wk|P0]) :- min_list(L0, Min), nth1(Wk, L0, Min), !, nth1(Wk, L0, Old, Rest), New is Old + C, nth1(Wk, L, New, Rest).

loads(Costs, A, W, Loads) :- numlist(1, W, Ws), maplist([Wk, S]>>( findall(C, ( nth1(J, A, Wk), nth1(J, Costs, C) ), Cs), sum_list(Cs, S) ), Ws, Loads).
makespan(Costs, A, M) :- ( A == [] -> M = 0 ; max_list(A, W), loads(Costs, A, W, L), max_list(L, M) ).

% optimal_makespan(+Costs, +W, -M): by trying every assignment (for checking small cases).
optimal_makespan(Costs, W, M) :- length(Costs, N), length(A, N),
    aggregate_all(min(S), ( maplist([X]>>between(1, W, X), A), loads(Costs, A, W, L), max_list(L, S) ), M0),
    ( var(M0) -> M = 0 ; M = M0 ).

% A few character programs (a real run gets them from plop2).
succ_char(I, In, C) :- nth0(I, In, X), C is X + 1.
copy_char(I, In, C) :- nth0(I, In, C).
sum_chars(Is, In, C) :- maplist([I, X]>>nth0(I, In, X), Is, Xs), sum_list(Xs, C).

run_sequential(Goals, In, Out) :- maplist([G, C]>>call(G, In, C), Goals, Out0), Out = Out0.
run_parallel(Goals, W, In, Out) :- concurrent_maplist([G, C]>>call(G, In, C), Goals, Out0), W >= 1, Out = Out0.
