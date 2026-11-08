# Scheduler - spec
Purpose : pick one ready task per cycle by priority/age; issue_id identifies it.
Interface : task_rdy[N],issue_ready -> issue_valid,issue_id
Requirements
- SCH-1 task_rdy[i] => issued within LAT (no starvation)   (forward)
- SCH-2 issue_valid => task_rdy[issue_id]; none ready => no issue (spurious)
- SCH-3 issue_id stable while issue_valid && !issue_ready    (integrity)
Abstraction : N reduced to 4; symmetric color_id replaces per-task loops.
Data coloring: color_id (task id) - proves fairness for all tasks in one run.
UNEARTH log : all-ready, single-ready, task withdrawn mid-arbitration.
