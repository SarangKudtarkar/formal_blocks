#!/usr/bin/env bash
# Run JasperGold FPV on every block (batch mode).
for d in */ ; do
  d=${d%/}; [ -f "$d/jg.tcl" ] || continue
  (cd "$d" && jg -fpv -batch -tcl jg.tcl -allow_unsupported_OS > jg.log 2>&1 \
     && echo "[$d] done" || echo "[$d] FAILED (see $d/jg.log)")
done
