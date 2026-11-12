# 03-beta — active scripts source

The sole editable runtime source is `src/`: `bootstrap/teche`, `bin/teche`, and `VERSION`. Keep these paths relative to `src/` so they become the flat approved runtime tree at `release/scriptsv1.0/`. The ServOS package has no WorkDesk command or helper.

`packaging/assemble-runtime.sh <empty-output-directory>` copies only those three runtime files and generates `SHA256SUMS.txt` from their exact bytes, for exactly four published files. The generated manifest is an output, not an editable source file. Repository documents, tests, CI files, and QA records are excluded from the client package.

`tests/pull-fixture-test.sh` exercises a local Git fixture. `qa/source-fixture-1.0.7-20261112.md` records the exact 1.0.7 source and four-file runtime candidate checks; it is not an installed public-main D09 PASS. The two 2026-11-10 records describe 1.0.6-qa and remain historical.

`Code provenance.txt` maps both TechE.Works runtime code files to source version 1.0.7 and the 2026-11-12 candidate preparation date. The production release date remains pending.

Before public publication: make this source repository private; pass current Beta source and installed ServOS QA; approve an exact source commit and generated runtime hashes. The public `TechEWorks/release/scriptsv1.0/` folder is the future distribution output, not an editable source or QA store.
