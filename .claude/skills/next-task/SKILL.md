# next-task

Pick and start the next task card from the backlog.

## Steps

1. Read `docs/tasks/backlog.md`.
2. Find the first card whose dependencies are all marked done.
3. Read the card file in `docs/tasks/`.
4. Read the FRD sections and ADRs the card cites.
5. Create a branch: `task/<card-id>-<short-name>`.
6. Write a short plan as the first comment in the PR draft:
   - What the card asks for
   - Which files you expect to create or change
   - Which tests you will write first
7. Start working: tests first, then implementation.
