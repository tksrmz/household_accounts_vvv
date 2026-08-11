---
allowed-tools: Bash(gh issue view:*), Bash(gh search:*), Bash(gh issue list:*), Bash(gh pr comment:*), Bash(gh pr diff:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh api:*), mcp__github_inline_comment__create_inline_comment
argument-hint: "<owner>/<repo>/pull/<number> [--comment] [--since <sha>]"
description: Code review a pull request, incrementally on re-runs
---

Provide a code review for the given pull request.

> This command is vendored from the upstream `code-review@claude-code-plugins` plugin
> (`plugins/code-review/commands/code-review.md` in anthropics/claude-code). The upstream
> version stops as soon as Claude has commented on a PR once, which means a push to an
> open PR is never reviewed. This copy reviews the newly pushed commits instead. It does
> not track upstream automatically -- re-sync it deliberately.

`gh api` is in the allowed tools because scoping a review to a commit range needs the
compare endpoint, which `gh pr diff` cannot express. It is bounded by the `permissions:`
block of the workflow that runs this command, not by the tool list.

**Agent assumptions (applies to all agents and subagents):**
- All tools are functional and will work without error. Do not test tools or make exploratory calls. Make sure this is clear to every subagent that is launched.
- Only call a tool if it is required to complete the task. Every tool call should have a clear purpose.

To do this, follow these steps precisely:

1. Launch a haiku agent to check if any of the following are true:
   - The pull request is closed
   - The pull request is a draft
   - The pull request does not need code review (e.g. automated PR, trivial change that is obviously correct)

   If any condition is true, stop and do not proceed.

   Note: "Claude has already commented on this PR" is deliberately NOT a stop condition.
   Resolving the review scope below is what keeps a re-run from repeating itself.

Note: Still review Claude generated PR's.

## Review scope

Resolve the scope once, before step 2, and give it to every subagent you launch.

- Check whether Claude has already reviewed this PR with `gh pr view <PR> --comments`.
- Use **full scope** -- the whole PR diff from `gh pr diff <PR>` -- when either:
  - no `--since <sha>` argument was provided, or `<sha>` is empty; or
  - Claude has not commented on this PR yet. The first review always covers everything.
- Otherwise use **incremental scope** -- only the commits pushed since `<sha>`:
  - Resolve the head with `gh pr view <PR> --json headRefOid --jq .headRefOid`.
  - Get the changes with `gh api repos/<owner>/<repo>/compare/<sha>...<head-sha>`.
  - If that call fails, `<sha>` is no longer reachable. That is what a force push or a
    rebase looks like, and there is no usable range. Fall back to full scope.
  - If it succeeds but reports no changed files, stop. There is nothing new to review.

Every mention of "the changes" or "the diff" below means the resolved scope, not
necessarily the whole PR. Under incremental scope the rest of the PR, the PR title and
the PR description are still fair context for judging a change -- they are just not
themselves under review.

2. Launch a haiku agent to return a list of file paths (not their contents) for all relevant CLAUDE.md files including:
   - The root CLAUDE.md file, if it exists
   - Any CLAUDE.md files in directories containing files modified by the changes

3. Launch a sonnet agent to view the pull request and return a summary of the changes

4. Launch 4 agents in parallel to independently review the changes. Each agent should return the list of issues, where each issue includes a description and the reason it was flagged (e.g. "CLAUDE.md adherence", "bug"). The agents should do the following:

   Agents 1 + 2: CLAUDE.md compliance sonnet agents
   Audit changes for CLAUDE.md compliance in parallel. Note: When evaluating CLAUDE.md compliance for a file, you should only consider CLAUDE.md files that share a file path with the file or parents.

   Agent 3: Opus bug agent (parallel subagent with agent 4)
   Scan for obvious bugs. Focus only on the diff itself without reading extra context. Flag only significant bugs; ignore nitpicks and likely false positives. Do not flag issues that you cannot validate without looking at context outside of the git diff.

   Agent 4: Opus bug agent (parallel subagent with agent 3)
   Look for problems that exist in the introduced code. This could be security issues, incorrect logic, etc. Only look for issues that fall within the changed code.

   **CRITICAL: We only want HIGH SIGNAL issues.** Flag issues where:
   - The code will fail to compile or parse (syntax errors, type errors, missing imports, unresolved references)
   - The code will definitely produce wrong results regardless of inputs (clear logic errors)
   - Clear, unambiguous CLAUDE.md violations where you can quote the exact rule being broken

   Do NOT flag:
   - Code style or quality concerns
   - Potential issues that depend on specific inputs or state
   - Subjective suggestions or improvements

   If you are not certain an issue is real, do not flag it. False positives erode trust and waste reviewer time.

   In addition to the above, each subagent should be told the PR title and description. This will help provide context regarding the author's intent.

5. For each issue found in the previous step by agents 3 and 4, launch parallel subagents to validate the issue. These subagents should get the PR title and description along with a description of the issue. The agent's job is to review the issue to validate that the stated issue is truly an issue with high confidence. For example, if an issue such as "variable is not defined" was flagged, the subagent's job would be to validate that is actually true in the code. Another example would be CLAUDE.md issues. The agent should validate that the CLAUDE.md rule that was violated is scoped for this file and is actually violated. Use Opus subagents for bugs and logic issues, and sonnet agents for CLAUDE.md violations.

6. Filter out any issues that were not validated in step 5. This step will give us our list of high signal issues for our review.

7. Output a summary of the review findings to the terminal:
   - If issues were found, list each issue with a brief description.
   - If no issues were found, state: "No issues found. Checked for bugs and CLAUDE.md compliance."

   If `--comment` argument was NOT provided, stop here. Do not post any GitHub comments.

   If `--comment` argument IS provided and NO issues were found:
   - Under full scope, post a summary comment using `gh pr comment` and stop.
   - Under incremental scope, post nothing and stop. A clean re-review does not earn a
     comment on every push; the terminal summary is enough.

   If `--comment` argument IS provided and issues were found, continue to step 8.

8. Create a list of all comments that you plan on leaving. This is only for you to make sure you are comfortable with the comments. Do not post this list anywhere.

   Drop from that list any issue Claude has already raised on this PR. Read the existing
   review comments with `gh api repos/<owner>/<repo>/pulls/<number>/comments`. An
   unaddressed finding stays on the PR as its original comment -- repeating it on every
   subsequent push is the noise this command exists to avoid.

9. Post inline comments for each issue using `mcp__github_inline_comment__create_inline_comment` with `confirmed: true`. For each comment:
   - Provide a brief description of the issue
   - For small, self-contained fixes, include a committable suggestion block
   - For larger fixes (6+ lines, structural changes, or changes spanning multiple locations), describe the issue and suggested fix without a suggestion block
   - Never post a committable suggestion UNLESS committing the suggestion fixes the issue entirely. If follow up steps are required, do not leave a committable suggestion.

   **IMPORTANT: Only post ONE comment per unique issue. Do not post duplicate comments.**

Use this list when evaluating issues in Steps 4 and 5 (these are false positives, do NOT flag):

- Pre-existing issues
- Anything outside the resolved review scope
- Something that appears to be a bug but is actually correct
- Pedantic nitpicks that a senior engineer would not flag
- Issues that a linter will catch (do not run the linter to verify)
- General code quality concerns (e.g., lack of test coverage, general security issues) unless explicitly required in CLAUDE.md
- Issues mentioned in CLAUDE.md but explicitly silenced in the code (e.g., via a lint ignore comment)

Notes:

- Use gh CLI to interact with GitHub (e.g., fetch pull requests, create comments). Do not use web fetch.
- Create a todo list before starting.
- You must cite and link each issue in inline comments (e.g., if referring to a CLAUDE.md, include a link to it).
- If no issues are found under full scope and `--comment` argument is provided, post a comment with the following format:

---

## Code review

No issues found. Checked for bugs and CLAUDE.md compliance.

---

- When linking to code in inline comments, follow the following format precisely, otherwise the Markdown preview won't render correctly: https://github.com/anthropics/claude-code/blob/c21d3c10bc8e898b7ac1a2d745bdc9bc4e423afe/package.json#L10-L15
  - Requires full git sha
  - You must provide the full sha. Commands like `https://github.com/owner/repo/blob/$(git rev-parse HEAD)/foo/bar` will not work, since your comment will be directly rendered in Markdown.
  - Repo name must match the repo you're code reviewing
  - # sign after the file name
  - Line range format is L[start]-L[end]
  - Provide at least 1 line of context before and after, centered on the line you are commenting about (eg. if you are commenting about lines 5-6, you should link to `L4-7`)
