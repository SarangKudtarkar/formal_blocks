# Credit manager - spec
Purpose : gate sender by available credits; receiver returns credits.
Interface : send_req,credit_ret -> send_grant,credits
Requirements
- CRD-1 send_req with credits>0 => send_grant              (forward)
- CRD-2 send_grant => credits>0; credits never > INIT       (spurious)
- CRD-3 credits + inflight == INIT (conservation)           (data integrity)
Abstraction : COUNTER ABSTRACTION - INIT reduced to small value; inflight modeled in checker.
Data coloring: N/A (count-based).
UNEARTH log : return at INIT (overflow), send at 0, simultaneous send+return.
