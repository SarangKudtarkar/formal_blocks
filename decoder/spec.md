# Decoder - spec
Purpose : map {en, addr} to a one-hot select vector (pure combinational).
Interface (inputs left / outputs right): en, addr[AW-1:0] -> sel[N-1:0]
Requirements
- DEC-1 en && addr==i  => sel[i]                  (forward)
- DEC-2 sel[i]         => en && addr==i           (spurious)
- DEC-3 en => $onehot(sel);  !en => sel==0        (integrity)
Abstraction : none needed; color_addr symbolic => ONE proof covers all N lines.
Data coloring: symbolic color_addr instead of looping over every index.
UNEARTH log : out-of-range addr, en glitch, multi-hot on illegal addr.
