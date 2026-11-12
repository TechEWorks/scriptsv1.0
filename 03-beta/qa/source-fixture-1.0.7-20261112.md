# ServOS scripts-only runtime 1.0.7 — source fixture

**Current result: source and draft public-branch fixtures PASS; installed public-main D09 remains OPEN.** This record qualifies tested runtime-source revision `7e20f12014ef63ddf47951622536c643e5d63739` and four-file runtime revision `31b9d4ab66441fe72f2f9379d1721d95a5569a0b` for local fixture review only. They are [scripts source PR #2](https://github.com/TechEWorks/scriptsv1.0/pull/2) and [public release PR #7](https://github.com/TechEWorks/release/pull/7), both draft and unmerged. This record grants no rights, independent review, ISO QA or production approval.

## Current exact checks — 2026-11-12

Disposable Debian 13.7 QEMU VM275 assembled the S4 source under `/tmp/teche-servos-only-lock-20261112`. Bash syntax passed for bootstrap, dispatcher, packager and fixture. `assemble-runtime.sh` produced exactly `VERSION`, `bootstrap/teche`, `bin/teche` and generated `SHA256SUMS.txt`; `sha256sum -c` returned OK for all three content files.

The local pull fixture returned exit 0 with `fixture_pull=pass aliases=pass help=pass version=pass scripts_only=pass exact_inventory=pass two_valid_commits=pass concurrent_update=pass retention=pass rollback=pass failed_activation_retains_prior=pass source_commit=pass tamper_rejected=pass`. It exercised two valid public commits, concurrent update through a root-owned lock, extra manifested-file rejection, retention, explicit rollback, active-link source-commit reporting, and an injected current-link activation failure that left the prior rollback mapping intact. Fixture evidence is `/tmp/teche-pull-fixture.kmh1W153`. The fixture's Git commits are synthetic, not product source or public release commits.

A second check freshly sparse-cloned **both actual PR branches** on VM275 into `/tmp/teche-servos-pr-clone-7e20f12-31b9d4a`. S4 assembly from the source clone was byte-identical to the four-file tree in the public runtime clone. Bash syntax, file count, scripts-only scan and all three SHA-256 manifest checks passed. GitHub Actions [run 43236501627](https://github.com/TechEWorks/scriptsv1.0/actions/runs/43236501627) completed successfully for this exact source-code revision.

| Runtime path | SHA-256 in manifest |
| --- | --- |
| `VERSION` | `6d6b9230dd8b8aac527f8929b7c2fc1fa0365deccca856216de979d6f5c6a6fe` |
| `bootstrap/teche` | `1d161cef2402a86cfb24ed24fc37c58629d42d0ec88b164cc77f03aa5a8af1aa` |
| `bin/teche` | `5184721beceb4c447f2847bc35e32e6f1fb18e6edb2a99d5ad96bf9c95b6cf5f` |

## ISO and installed D09 boundary

The previous exact ServOS ISO SHA-256 `9269b7641117b963986a4c6f5e157a41486fc84c5283fe8cf4fc96180617c097` embeds older bootstrap SHA-256 `253e4dca50ec055c5290fc368afcf41f3999913c599b26f2c3e50f3d852bd78e`. It does not qualify the new rollback, lock, inventory or metadata behavior. A new ISO must embed bootstrap SHA-256 `1d161cef2402a86cfb24ed24fc37c58629d42d0ec88b164cc77f03aa5a8af1aa`, receive its own ISO SHA-256 and full release-specific QA. No earlier ISO result transfers.

Public `TechEWorks/release/main` still lacks the approved `scriptsv1.0/` runtime. After rights, privacy, version and independent review gates, D09 must be rerun on the exact new installed ISO against public main: unauthenticated fetch, exact four-file inventory, help/version/aliases, two revisions, concurrent update, retention, rollback, failed activation/tamper rejection and active source-commit reporting.

## Historical checks retained for traceability

Source revision `255e593d76d179faed7203425a458df3d46dea6b` and runtime revision `f9fde69350964ef46dd9fab6f5b77978b3ec7212` passed the sequential rollback fixture but predate the lock and exact inventory. Earlier source `c6f005338acb80d8c2d79cfe208e93d6d379133e` and public branch `12c930c280bd334297f6da545192bcf2ebf30989` passed a six-marker fixture before rollback. The first 1.0.7 public-branch commit `7812b9e60a379115a53d175f74df8edbac1e70fc` failed Linux manifest verification because hashes came from Windows working-copy line endings; `12c930c` corrected committed LF hashes and added path-specific LF checkout rules. Those results do not qualify the current runtime or a new ISO.
