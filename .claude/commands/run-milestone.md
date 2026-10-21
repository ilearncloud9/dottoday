Run the current milestone autonomously, task after task, until it is done or a stop condition is hit.

Loop:
1. Open `docs/09-implementation-plan.md`. Find the current milestone (the first with an unchecked task). Take its first `[ ]` task.
2. Execute it exactly as `/next-task` would (read the referenced spec sections and R-xx IDs, implement, `flutter analyze && flutter test`, tick the box, CHANGELOG line, commit on a `type/short-desc` branch, fast-forward merge into main, push).
3. Decide locally using CLAUDE.md §10 "Autonomy rules". Do NOT pause for anything §10 says you may decide yourself — decide it, record it in one line in the commit body and (if it changes a spec) in the plan or ADR, and keep going.
4. After each task, print a 3–5 line status: task id, what changed, decisions taken, tests count, CI status of the last push.
5. When every task in the milestone is `[x]`, run `/ship-check`. If it passes, tick the milestone's gate task and STOP with a milestone summary. If it fails, add the fix tasks it names to the plan and continue the loop.

Stop and ask ONLY when a §10 "must ask" condition is hit. When you stop, state the decision needed in ≤ 5 lines with your recommended option first, and do not start another task until answered.

If the same task fails its checks three times in a row, stop and report rather than looping.

$ARGUMENTS
