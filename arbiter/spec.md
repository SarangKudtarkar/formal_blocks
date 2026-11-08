# Arbiter - spec
Purpose : grant one of N requesters per cycle (RR / fixed priority).
Interface : req[N] -> gnt[N]
Requirements
- ARB-1 req[i] => gnt[i] within LAT cycles (no starvation)   (forward)
- ARB-2 gnt[i] => req[i];  req==0 => gnt==0                  (spurious)
- ARB-3 $onehot0(gnt)                                        (integrity)
Assumes : requester holds req until granted.
Abstraction : parameter reduction (N=4 proof, symmetry via color_id).
Data coloring: color_id = symbolic requester; one proof stands for all N.
UNEARTH log : simultaneous req, req dropped on grant cycle, pointer wrap.
