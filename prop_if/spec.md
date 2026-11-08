# Proprietary interface (4-phase req/ack) - spec  [REPLACE with your protocol]
Purpose : request/ack handshake carrying payload; req held until ack, ack drops before next req.
Interface : req,payload_in -> ack,payload_out
Requirements
- PIF-1 req => ack within LAT                               (forward)
- PIF-2 ack => req was asserted (no ack without req)        (spurious)
- PIF-3 payload stable while req && !ack; out == in at ack  (data integrity)
Abstraction : payload width reduced; protocol checked in isolation from payload logic.
Data coloring: symbolic color payload through the handshake.
UNEARTH log : req drop before ack, ack stuck, back-to-back transactions.
