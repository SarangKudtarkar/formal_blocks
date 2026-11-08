# Interrupt controller - spec
Purpose : latch sources, mask, prioritize, present irq_out/irq_id, clear on ack.
Interface : irq_src[N],mask[N],ack -> irq_out,irq_id
Requirements
- INT-1 unmasked source => irq_out within L                  (forward)
- INT-2 irq_out => an unmasked pending source exists         (spurious)
- INT-3 irq_id == highest-priority pending source            (data integrity)
Abstraction : N reduced; edge/level source modeled as free input.
Data coloring: color_id = symbolic source id; vector identity preserved to irq_id.
UNEARTH log : src pulse during ack, mask toggle, simultaneous sources.
