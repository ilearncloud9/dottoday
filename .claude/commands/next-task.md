Pick up the next piece of work.

1. Open `docs/09-implementation-plan.md`. Find the first task whose checkbox is `[ ]` whose milestone's prerequisites are all `[x]`.
2. Print the task ID, its one-line goal, and the docs sections + `R-xx` IDs it references.
3. Read those sections. Restate the task in one sentence and list the files you expect to touch.
4. If the task is >50 lines, touches the schema, or adds a dependency: show the plan in your reply, then continue unless it hits a CLAUDE.md §10 "must ask" item.
5. Otherwise implement following CLAUDE.md §4–§7, run `flutter analyze && flutter test`, tick the checkbox, add a CHANGELOG line, and report a short changelog.

$ARGUMENTS
