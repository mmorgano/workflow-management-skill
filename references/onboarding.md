# First-Run Introduction

Read this reference when no workflow context resolves (the last step of the
resolution order in `CORE.md`), before proposing to create one. It is a short,
friendly, skippable introduction followed by the language choice. It is for
people of every technical level: be warm, plain, and brief.

Also read it, for the "Later questions" section only, when the user asks what
a folder in the context is for, what else the skill can do, or how working by
tasks differs from a long project.

## When it runs

- **Only when no context resolves.** Never when a context is found.
- **Not when a context exists but cannot be used.** A `.workflow-config.json`
  that is present but unreadable, or that does not point back to its own
  directory, is a problem to report and ask about, not a reason to introduce
  the skill again.
- **No workspace open.** Resolve that first (`references/sessions.md` § "No
  workspace at all"): the introduction is offered only after the user has chosen
  to open a workspace folder or has given an explicit path, never before.
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

If the user chose an explicit path because no workspace is open, say one line
first: opening a real project folder as the workspace gives the best experience,
because the notebook is then attached to it and found by itself in every later
session.

Greet, say in one sentence what you are, and offer the introduction:

> Hi, I'm your workflow assistant. I help keep your work organized across
> sessions, so nothing depends on what a single chat remembers. Would you like a
> one-minute introduction, or shall we skip it and get started?

If the user skips, go to Step 3.

## Step 2 — The introduction

Say the text below, translated faithfully into the user's language. Keep the
structure and the plain words: do not add technical terms, and do not explain
the optional features until the user asks. The word *context* is introduced once, on
purpose, only after the picture that explains it.

> Here's the short version.
>
> **The problem.** AI chats have a short memory: tomorrow I won't remember what
> we did today.
>
> **The idea.** I keep a small notebook for your work. It is just a folder of
> ordinary text files on your computer, and you can open and edit them like any
> other document. This notebook is called a *context*. In it I write down what
> we did, what is still to do, and what we decided.
>
> **What you gain.** Every new session starts by reading the notebook, so we
> continue from where we left off, even days later. The notebook is plain
> files, so another assistant can pick it up too, as long as it has this same
> skill installed.
>
> **What it looks like.**
> - You say "start a session": I read the notebook, tell you where we left off
>   and ask what you want to do today.
> - You say "add a task: ...": I write it down in your task list.
> - You say "close the session": I save what happened and what comes next.
>
> **A few good habits.** Close the session before you stop. Describe a task by
> the result you want. Glance at what I write: it is your notebook. Keep it
> private.
>
> There is more (plans by period, meeting notes, decision records), but you do
> not need any of it to begin.

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

## Later questions

Answer these on request, in the user's language and in plain words. Do not
volunteer them beyond the one-line invitation in the setup report.

### "What is this folder for?"

Explain only the folder asked about, in one or two sentences:

- `sessions/` — one note per working day: what happened and what comes next.
- `tasks/` — what is open (`todo/`) and what is finished (`done/`).
- `sprints/` — optional plans by period (for example two weeks).
- `focus/` — notes while you explore a topic, before it becomes a decision.
- `meetings/` — outcomes of meetings you want to keep.
- `roadmap/` — the bigger picture: goals, phases, and decisions.

Say that most of these stay empty until they are needed, and that only
`sessions/` and `tasks/` are used from the first day.

### "Working by tasks or a long project?"

> **Working by tasks** is enough for most things: you list what to do, tick it
> off, and I keep the notebook short.
> **A long project** (many phases, months, several people or parts) benefits
> from a bit more structure: dated status snapshots, a small list of risks and
> open problems, and a check at each phase.
> You don't have to choose now. If your work grows into that, I'll suggest it
> and you decide.

Do not activate anything because of this answer. The `long-vision` tier is only
proposed and confirmed as described in `references/tracking.md`.

### "What else can you do?"

Name two or three things that fit what the user is doing now (for example
"start each day where you left off", "keep the open work short", "record why
you chose something"), and offer to explain one. Do not list every feature.
