# Bootstrap Traps

Read this reference when a new repository or component is about to exist, as
a companion to the "When no context resolves" branch in `references/sessions.md`.
It does not replace the project intake in `references/steering.md` (what/why/
success criteria/scope) — use that for framing. This file covers the
non-code decisions an assistant otherwise tends to skip: the ones that do not
show up in a code review and are expensive to fix once the first commit, or
the first sibling component, already exists.

Do not run this as a fixed sequence. Ask only what the project's shape
actually raises, propose sensible defaults, and scaffold what the user
confirms.

## Folder layout and naming

- **Multi-component projects: use an umbrella folder from day one.** A flat
  pile of sibling repos becomes hard to navigate and back up once there are
  more than two or three. Group them under one parent folder, with each
  component as a sibling inside it.
- **Folder name = repo name = package name** where possible. Verbose beats
  clever, so a folder is unambiguous on its own.
- **Reserve the bare project name.** If one component will later *be* "the
  project" (a core or platform package), do not also name the umbrella folder
  that — it produces `<project>/<project>/`. Give that component a distinct
  name, or prefix the umbrella instead.
- **Don't collide with future components.** Pick names now for components you
  can already foresee, so an early one does not grab a name a later one needs.
- **Naming that outlives the folder:** if the project could ever be
  published, check the name is free before committing to it — package
  registry, code-host org/repo, domain, and trademark in the relevant classes
  if it matters. A rename after a public release is expensive.

## Git and identity

- **Set the commit identity per-repo**, not globally, whenever different
  identities are used in different contexts. A common trap: a host requires a
  noreply email for pushes, but the machine's global `user.email` is a
  different address the host rejects. Set `git config user.email
  <per-repo value>` right after `git init` / `git clone`, and rely on the
  repo's own config for merges and amends rather than passing `-c` flags each
  time.
- Add a language-appropriate `.gitignore` (virtual environments, build
  output, secrets, editor cruft) and a `.gitattributes` (line endings) from
  the start, not after the first accidental commit.
- Decide the branch flow before the first PR (trunk with short-lived branches
  is a safe default) and write it down once, rather than re-deciding per PR.
- Create a remote only when the user asks. If it will be private by default,
  say so explicitly.

## Legal and IP

Skip this section for a purely personal project unconnected to any employer
or client. Otherwise, resolve it **before the first commit**, not after:

- **Employment or contractor clauses.** Check for an IP-assignment clause
  (does it cover only in-scope work, or anything created during the
  engagement?) and an exclusivity or secondary-activity clause (must outside
  work be declared or authorized?). If a clause is broad or ambiguous, get
  written confirmation before making anything public — private development is
  usually fine, publication is the actual risk.
- **Clean-room discipline.** Personal machine, personal time, personal
  network. No employer resources, internal hostnames, proxies, credentials,
  dataset names, or product names in code, tests, comments, docs, or **git
  history**.
- **Importing code written elsewhere.** Sanitize file-by-file at copy time,
  not after the fact, with a checklist run before each commit. Anything that
  identifies an internal system must not travel with it.

## Dependencies between your own components

When component B depends on component A and neither is published yet:

- Install A into B **by relative path** (an editable install pointing at a
  relative path, a workspace protocol, a path dependency) — never an
  absolute path. An absolute path breaks the moment either folder moves.
- **Recreate virtual environments rather than moving them.** Their activation
  scripts and editable-install records hardcode absolute paths at creation
  time, so a moved venv silently keeps pointing at the old location.
- Record the intended real dependency (e.g. `component-a>=x,<y`) in the
  manifest even while using the local override, so switching to the
  published version later is a small change, not a rediscovery.

## Licensing and visibility

- State visibility explicitly: public, private, or private-for-now.
  "Private for now, publish decision pending X" is a valid, written position
  — silence is not.
- A license can be deferred, but say so where a reader would look for it
  ("license: TBD before any public release"). Decide on a CLA/DCO early if
  outside contributions are expected, or relicensing freedom is lost later.
- If a component must be embeddable in someone else's proprietary work, its
  license has to be permissive — never copyleft for that component.

## Lessons learned

Add to this list whenever a project hits a problem that a bootstrap decision
would have prevented.

- **Flat layout of many sibling repos.** Five or more related repos loose
  under one parent folder became hard to navigate and back up. An umbrella
  folder from the start costs nothing; retrofitting it later means
  recreating every virtual environment and repatching workspace and context
  configuration. → Folder layout above.
- **Absolute paths in editable installs.** An editable install wrote an
  absolute source path into the package's install records, so nothing could
  be moved afterward without a full reinstall. → Dependencies above.
- **A work context shared by two workspaces.** One durable work context got
  attached to two editor workspaces at once; splitting it apart later was
  fiddly. One context per workspace from the start avoids the split
  entirely.
- **Moving repos an running agent already has open fails on Windows.**
  Retrofitting an umbrella folder mid-session failed: the agent's own
  process and the editor's language servers hold handles on the folder
  roots, so a move gets "permission denied". Scaffold a *new* repo in place
  (nothing has it open yet), but do any *move* of existing repos from
  outside the running session — a script the user runs in a plain terminal
  with the editor closed. Delete virtual environments before moving; they
  lock the interpreter binary and hardcode absolute paths anyway.
