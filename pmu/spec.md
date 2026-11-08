# Power Management Unit - spec
Purpose : sequence power domain up/down: isolate -> save -> switch off; reverse on wake.
Interface : pwr_down_req,pwr_up_req,dom_idle,sw_ack -> iso_en,sw_en,ret_save,pwr_on
Requirements
- PMU-1 down_req && idle => domain off within T             (forward)
- PMU-2 sw off only after iso_en (ordering); iso_en => a request existed (spurious)
- PMU-3 retention save pulse before switch off              (integrity)
Abstraction : black-box the power domain; model sw_ack as nondeterministic delay.
Data coloring: N/A (control block) - color the domain id if multi-domain.
UNEARTH log : down/up request collision, request during sequence, abort.
