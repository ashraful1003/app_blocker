# Branch Protection for `main`

Set these rules in GitHub → Settings → Branches → Branch protection rules
for the `main` branch:

1. **Require a pull request before merging**
   - Required approvals: 1 (your review)
   - Dismiss stale reviews when new commits are pushed: Yes

2. **Require status checks to pass before merging**
   - Required checks:
     - `Dart checks` (from pr.yml)
     - `Kotlin checks` (from pr.yml)
     - `Build debug APK` (from pr.yml)

3. **Require conversation resolution before merging**: Yes

4. **Do not allow bypassing the above settings**: Yes

5. **Restrict who can push to matching branches**: Only through PRs

6. **Allow squash merging only**
   - Each task becomes one commit in history.

These settings ensure no code reaches main without passing all checks.
