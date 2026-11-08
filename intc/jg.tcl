# JasperGold FPV - intc
clear -all
analyze -sv12 ../common/color_trk.sv
analyze -sv12 ../rtl/intc.sv            ;# <-- your DUT (top module: intc)
analyze -sv12 intc_props.sv             ;# checker + bind
elaborate -top intc
clock clk
reset -expression {!rst_n}

# ---- abstraction hooks (enable as needed) ------------------------------------
# abstract -counter   {<cnt_reg>}                 ;# counter abstraction
# abstract -memory    {<mem_array>}               ;# memory abstraction
# blackbox -module    {<submodule>}               ;# black-box a sub-block
# assume  -bound 1 {<free_color_sig> == <const>}  ;# optional: pin a color

set_prove_time_limit 1h
# ---- UNEARTH flow: 1) covers first (reachability / no over-constraint) -------
prove -property {*cov_*}
# ---- 2) assumes sanity, then asserts ------------------------------------------
prove -property {*ast_*}
# ---- 3) bounded exploration for hard properties --------------------------------
# prove -property {*ast_fwd_*} -engine_mode {Hp Ht}
report -summary
# coverage (needs the JG coverage app/license; catch keeps the run alive without it)
catch {check_cov -init -model {functional}}
catch {check_cov -measure -type {coi proof bound}}
catch {check_cov -report -force -file cov_report.txt}
