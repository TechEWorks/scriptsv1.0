# ServOS scripts-only runtime 1.0.7 — source fixture

**Result: source fixture PASS; installed public-main D09 still FAIL / not retested.** The editable source is commit `c6f005338acb80d8c2d79cfe208e93d6d379133e` in [scripts source PR #2](https://github.com/TechEWorks/scriptsv1.0/pull/2). The proposed four-file public runtime is commit `7812b9e60a379115a53d175f74df8edbac1e70fc` in [release PR #7](https://github.com/TechEWorks/release/pull/7). Both PRs remain draft and unmerged; this record grants no rights, independent review or production approval.

On 2026-11-12, disposable Debian 13.7 QEMU VM275 cloned the exact source commit into `/tmp/teche-servos-scripts-1.0.7-c6f0053`. Bash syntax passed for both runtime scripts, the packager and fixture test. `assemble-runtime.sh` produced exactly `VERSION`, `bootstrap/teche`, `bin/teche` and generated `SHA256SUMS.txt`; `sha256sum -c` returned `OK` for all three manifest entries. `pull-fixture-test.sh` returned exit 0 with `fixture_pull=pass aliases=pass help=pass version=pass scripts_only=pass tamper_rejected=pass`; its isolated evidence directory is `/tmp/teche-pull-fixture.S9Dzdqls`. The fixture source commit is `f67556b15d399280e0f0d64936d9dcaa7f074da9` (local test fixture, not the product source or public release head).

| Relative runtime path | SHA-256 in generated manifest | Source/public Git blob |
| --- | --- | --- |
| `VERSION` | `6d6b9230dd8b8aac527f8929b7c2fc1fa0365deccca856216de979d6f5c6a6fe` | `238d6e882a08cec91c9bf37bd210147a0c968798` |
| `bootstrap/teche` | `a0e05f1b5f48d23a7168d0cf96e2d8561dc5647c44c629d9e0142fb3a18d758f` | `24f6205b71a1ae8a1bd66fe9d58f7b5de68e34e3` |
| `bin/teche` | `eea97a3b75df883aa225db1643017a386702c0b7abe282c276176845ccd3be07` | `8011a489d7f9d4a5de70d886cbde2d40f58cae1b` |

The same three blob IDs were observed in source and public runtime worktrees. The generated manifest's SHA-256 is `0f15cfd6aa9560ca5bb4062425645616962e993cd3fa11243f3d5f759c1e4cd4`. The runtime contains no WorkDesk library or command. The exact ServOS ISO SHA-256 `9269b7641117b963986a4c6f5e157a41486fc84c5283fe8cf4fc96180617c097` embeds the same bootstrap bytes (`253e4dca50ec055c5290fc368afcf41f3999913c599b26f2c3e50f3d852bd78e`) as this proposed runtime; the version change is in the separately fetched package and does not change the ISO.

**Remaining D09 path:** Rights/version review and approval of the four-file package; merge to public `release/main`; then rerun installed ServOS public fetch, manifest/no-extras, version/help/aliases, update, tamper rejection and prior-revision retention on the exact ISO. The earlier installed ISO returned exit 65 while `scriptsv1.0/` was absent from public main. A local fixture cannot pass that public delivery gate.
