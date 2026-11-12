# TechE scripts v1.0

Read [ReadMeFirst.md](ReadMeFirst.md) and the [TechE scripts client policy](https://github.com/TechEWorks/standards/blob/main/TechE%20scripts%20client%20policy.md). The Debian client package destination is `/teche.scripts/v1.0/`, while `/usr/bin/teche` remains the native full-path command. The public package is not yet published; this source change needs QA on an installed ServOS client.

The `TechEWorks/scriptsv1.0` repository is the editable source. After QA, its approved files are copied to the public `TechEWorks/release/scriptsv1.0/` folder. No credential is included in either package.

ServOS installs only `bootstrap/teche` as `/usr/bin/teche`. This path is already on the standard OS PATH. The first `sudo teche get scriptsv1.0` downloads the public scripts, checks every file against `SHA256SUMS.txt`, checks the v1.0 version line and shell syntax, and activates them at `/teche.scripts/v1.0/current/`. The full `bin/teche` command is then reached through the same `/usr/bin/teche` entry point.

`teche get scripts`, `teche update scripts`, and `teche update scriptsv1.0` perform exactly the same refresh as `teche get scriptsv1.0`. A previous revision remains in `/teche.scripts/v1.0/releases/`. Existing legacy WorkDesk helper files outside the scripts package are left untouched. The WorkDesk package catalog is not overwritten; its URL and SHA-256 must be configured separately before installing WorkDesk.

The bootstrap reads only the public release repository. This means a user of ServOS or WorkDesk needs no private GitHub access to obtain scripts. On first use, the bootstrap installs Git through Debian APT if Git is absent. It needs network access, a working APT mirror for that case, and trusted CA certificates.

## Files

- `bootstrap/teche`: the only TechE utility shipped in a new ServOS base.
- `bin/teche`: full TechE command dispatcher downloaded from the public release.
- `lib/`: WorkDesk helper scripts downloaded with the dispatcher.
- `VERSION`: same-major version gate.
- `SHA256SUMS.txt`: hashes of every published file except the manifest itself.
- `qa/`: component checks kept in the source repository.

`teche help`, `teche --help`, `teche -help`, `teche -h`, and bare `teche` show the available commands. Before activation they show the bootstrap commands; after activation they show the full installed command set and script version. `teche ver` or `teche --version` shows platform, scripts, source commit, Debian base and WorkDesk install status. The WorkDesk ZIP cache is root-private: an unprivileged `teche status wd1.0` reports that limit and directs the administrator to `sudo teche status wd1.0` for verified cache state. `teche build` lists registered build routes. The current QA build catalog lists WD(txt) network and WD(gui) offline only; WD(gui) network remains withheld. A build command is not a release approval.

## Updating an installed system

The private source is tested first, then the approved **v1.0** package and its regenerated hash manifest are published under `TechEWorks/release/scriptsv1.0/`. On a machine already running ServOS, run `sudo teche update scriptsv1.0` (or `sudo teche update scripts`). The same command works for a first download with `get` in place of `update`. The bootstrap downloads the public package, verifies it, retains the previous revision, and switches `current` only after verification succeeds. `teche ver` shows the active version and source commit; `teche help` shows its commands. Existing WorkDesk data and package catalog are separate from this script refresh. Updating the scripts alone does not reinstall WorkDesk or rebuild the ServOS ISO.

To build a WorkDesk ISO, obtain the private WorkDesk source and its pinned inputs, then use the appropriate `teche build wd1.0iso ...` command from that checkout on Debian 13. Build instructions and exact hashes live in the WorkDesk repository. `teche install wd1.0` provisions the current machine and is a different operation.

## Publish and verify

1. Review and test changes in the private scripts repository.
2. Regenerate `SHA256SUMS.txt` after every content change.
3. Copy the approved runtime files to `release/scriptsv1.0/` without changing their bytes.
4. Verify the public files and a clean ServOS machine: `teche get scriptsv1.0`, `teche ver`, `teche help`, and the aliases.
5. Build a new ServOS ISO from the minimal bootstrap source, install on a disposable VM, and repeat the public fetch and command checks before release.

