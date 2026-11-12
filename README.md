# TechE scripts v1.0

Read [ReadMeFirst.txt](ReadMeFirst.txt), the [active Beta packet](03-beta/ReadMeFirst.txt), and the [TechE scripts client policy](https://github.com/TechEWorks/standards/blob/main/TechE%20scripts%20client%20policy.md).

This repository contains the editable Beta source. GitHub still reports this repository as public; its visibility must be changed to private before the private-source policy is satisfied. The public `TechEWorks/release/scriptsv1.0/` package has not been published.

## Layout

- `03-beta/src/` — sole editable runtime source: `bootstrap/teche`, `bin/teche`, and `VERSION`.
- `03-beta/packaging/assemble-runtime.sh` — creates an allowlisted runtime tree and its SHA-256 manifest.
- `03-beta/tests/pull-fixture-test.sh` — source fixture test.
- `03-beta/qa/` — historical candidate evidence; the 2026-11-10 results cover 1.0.6-qa.
- `.github/workflows/scripts-fixture-qa.yml` — assembles and checks the current source candidate.

The generated runtime package contains exactly `bootstrap/teche`, `bin/teche`, `VERSION`, and `SHA256SUMS.txt`. The source packet and QA records never belong in the public runtime folder.

## Debian client contract

ServOS installs `03-beta/src/bootstrap/teche` as `/usr/bin/teche`. An authorized administrator can run `sudo /usr/bin/teche get scriptsv1.0`. After publication, that command pulls the public `release/scriptsv1.0/` package, verifies every file and shell syntax, and activates it at `/teche.scripts/v1.0/current/`. Earlier verified revisions remain under `/teche.scripts/v1.0/releases/`.

`teche get scripts`, `teche update scripts`, and `teche update scriptsv1.0` use the same refresh path. `teche help` and `teche ver` show the available commands and active version. Fetching scripts does not install WorkDesk. The WorkDesk package catalog and its URL/hash are separate.

The bootstrap reads only the public release repository, so clients need no private GitHub access to install an approved package. It installs Git through Debian APT if Git is absent, requiring network access, a working APT mirror, and trusted CA certificates.

## Current qualification

The source fixture checks assembly, hashes, aliases, help, version, scripts-only scope, two-revision update/retention, explicit rollback, failed activation, active source-commit reporting, and tamper rejection. It does not prove an HTTPS pull from `release/main`, a newly built ServOS ISO, or installed-machine acceptance for proposed production runtime 1.0.7. After rights, review and release approval, publish the generated runtime bytes to `release/scriptsv1.0/` and test on a disposable installed ServOS machine before release.
