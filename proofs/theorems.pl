% Theorems about charpar, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module('../prolog/charpar').
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).

% Domain: every list of 1..5 job costs from 1..4, on 1..3 workers.
costs(Cs) :- between(1, 5, N), length(Cs, N), maplist([C]>>between(1, 4, C), Cs).

% 1. Every job is given to exactly one worker, and every worker named exists.
theorem(each_job_one_worker) :-
    forall(( costs(Cs), between(1, 3, W) ), ( schedule(Cs, W, A), length(A, L), length(Cs, L), forall(member(X, A), between(1, W, X)) )).

% 2. No work is lost or made up: the loads add up to the total cost.
theorem(loads_add_up) :-
    forall(( costs(Cs), between(1, 3, W) ), ( schedule(Cs, W, A), loads(Cs, A, W, L), sum_list(L, T), sum_list(Cs, T) )).

% 3. Graham's bound: the schedule is never worse than 4/3 - 1/(3W) of the best possible.
theorem(within_grahams_bound) :-
    forall(( costs(Cs), length(Cs, N), N =< 4, between(1, 3, W) ),
           ( schedule(Cs, W, A), makespan(Cs, A, M), optimal_makespan(Cs, W, Opt), 3 * W * M =< (4 * W - 1) * Opt )).

% 4. ... and never better than possible: at least the longest job, and at least the average load.
theorem(at_least_the_lower_bounds) :-
    forall(( costs(Cs), between(1, 3, W) ), ( schedule(Cs, W, A), makespan(Cs, A, M), max_list(Cs, Mx), sum_list(Cs, T), M >= Mx, W * M >= T )).

% 5. Running the character programs on threads gives the same output as running them one by one.
theorem(parallel_equals_sequential) :-
    forall(( between(1, 3, N), length(In, N), maplist([X]>>between(0, 2, X), In), Top is N - 1, numlist(0, Top, Is) ),
           ( maplist([I, G]>>(I mod 2 =:= 0 -> G = succ_char(I) ; G = sum_chars(Is)), Is, Gs),
             run_sequential(Gs, In, S), run_parallel(Gs, 2, In, P), S == P )).
