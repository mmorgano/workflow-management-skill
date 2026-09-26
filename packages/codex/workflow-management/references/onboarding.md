# First-Run Introduction

Read this reference when no workflow context resolves (the last step of the
resolution order in `CORE.md`), before proposing to create one. It is a short,
friendly, skippable introduction followed by the language choice. It is for
people of every technical level: be warm, plain, and brief.

## When it runs

- **Only when no context resolves.** Never when a context is found.
- **Not when a context exists but cannot be used.** A `.workflow-config.json`
  that is present but unreadable, or that does not point back to its own
  directory, is a problem to report and ask about, not a reason to introduce
  the skill again.
- **Nothing is remembered between workspaces.** In a second workspace with no
  context the offer appears again; the first question makes it a one-word skip.
  Do not write a "seen" marker; it would need the machine-wide pointer, which
  workspace-local setup deliberately leaves alone.

## Rules

- Ask **one question at a time**, each with a sensible default the user can
  accept in a word.
- Use the language the user is writing in until they choose another.
- The introduction is informational only. It changes no file.
- Declining is always fine. If the user skips everything, continue to the
  existing no-context flow in `references/sessions.md` and, if they refuse
  setup, proceed without workflow records for this request.

## Step 1 — Offer

Greet, say in one sentence what you are, and offer the introduction:

> Hi, I'm your workflow assistant. I help keep your work organized across
> sessions, so nothing depends on what a single chat remembers. Would you like a
> one-minute introduction, or shall we skip it and get started?

If the user skips, go to Step 3.

## Step 2 — The introduction

Keep it to what fits on one screen. Cover, in plain words:

- **What it is:** a small folder of ordinary text files (the *context*) where
  the assistant keeps your work state. You can read, edit, and back it up with
  any tool.
- **Why it exists:** AI chats forget. With a context, a new session starts by
  reading where you left off instead of from zero, and it works across
  assistants and computers.
- **What it keeps:** *sessions* (what happened each day), *tasks* (what is
  open, in progress, done), a short *RECAP* of open work, and optionally
  sprints, notes, meetings, and decisions.
- **How you use it:** ask to start a session, create a task, close the session.
  The assistant does the bookkeeping and asks before anything risky.
- **A few good habits:**
  - close a session before you stop, so the next one can pick up;
  - keep tasks small and describe the result you want;
  - skim what the assistant writes; it is your record;
  - keep your personal context private, and version it in a private place if
    you use Git.

End by asking if they want to continue.

## Step 3 — Language of the records

Confirm the language for the records the assistant writes, offering the
language the user has been writing in as the default. Accept any language as
free text. If the assistant cannot write it well, say so and fall back to
English, stating that fallback. The answer becomes `record_language` in
`.workflow-config.json`; without an answer the value is `English`, and say so.

## Step 4 — Personal and shared contexts

Explain in two sentences, without asking anything yet:

> The suggested use is a **personal** context: your own sessions, notes, and
> tasks. A **shared team** context, if one exists, holds only what the team
> agrees on and is written in English unless the team says otherwise.

This edition creates a personal context only. An adapter that ships team support
adds its own question here (whether to also create a team context and how to
name it); this reference does not prescribe one.

## Step 5 — Continue

Continue with the existing no-context flow in `references/sessions.md`: propose
a name and location, create the context with the workspace-local setup
(`references/setup-guided.md`), and initialize the first records. Pass along the
language chosen in Step 3 so the project-intake conversation reuses it.

## Reporting

After the flow, state what was created, the `record_language` chosen (and
whether it was a default or a fallback), and that the introduction was shown or
skipped.
