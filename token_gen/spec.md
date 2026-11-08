# Token generator - spec
Purpose : generate tokens at a configured rate; consumers take tokens.
Interface : tick,consume -> token_valid,token_cnt
Requirements
- TOK-1 tick (enabled) => token_cnt increments (until MAX)  (forward)
- TOK-2 token_valid => token_cnt>0; no token without a tick (spurious)
- TOK-3 token_cnt <= MAX; tokens in == out + cnt             (data integrity)
Abstraction : COUNTER ABSTRACTION - reference counter in checker, MAX reduced.
Data coloring: N/A (count-based); color a token id if tokens carry payload.
UNEARTH log : consume at 0, tick at MAX, simultaneous tick+consume.
