# charpar

plop2's per-character programs don't depend on each other, so they can run at the same time. charpar schedules the character jobs onto W workers (longest job first, Graham's LPT rule), runs each worker's scheduled jobs on its own thread, and gives the same output as running them one by one. A job is Cost-Goal, where Goal is called as call(Goal, Input, Char).

## Use

```prolog
?- use_module(prolog/charpar).
?- schedule([5,3,3,2,2,2], 2, A), makespan([5,3,3,2,2,2], A, M).   % M = 9 (optimal)
?- run_sequential([succ_char(0), succ_char(1)], [1,5], Out).        % Out = [2,6]
?- run_parallel([succ_char(0), succ_char(1)], 2, [1,5], Out).       % the same, on 2 threads
?- plan([5-succ_char(0), 3-succ_char(1), 3-copy_char(0)], 2, P).     % P = [[1], [2,3]]: what each thread runs
```

## Proofs

`proofs/theorems.pl` proves 6 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every list of 1..5 job costs from 1..4, on 1..3 workers.

1. Every job is given to exactly one worker, and every worker named exists.
2. No work is lost or made up: the loads add up to the total cost.
3. Graham's bound: the schedule is never worse than 4/3 - 1/(3W) of the best possible.
4. ... and never better than possible: at least the longest job, and at least the average load.
5. Running the character programs on threads gives the same output as running them one by one.
6. The parallel run follows the schedule: each worker's thread runs exactly its scheduled jobs, every job once.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
