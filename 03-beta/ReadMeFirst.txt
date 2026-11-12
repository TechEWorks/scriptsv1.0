# 03-beta — active scripts source

The sole editable runtime source is `src/`: `bootstrap/teche`, `bin/teche`, `lib/*.sh`, and `VERSION`. Keep these paths relative to `src/` so they become the flat approved runtime tree at `release/scriptsv1.0/`.

`packaging/assemble-runtime.sh <empty-output-directory>` copies only those five runtime files and generates `SHA256SUMS.txt` from their exact bytes. The generated manifest is an output, not an editable source file. Repository documents, tests, CI files, and QA records are excluded from the client package.

`tests/pull-fixture-test.sh` exercises a local Git fixture. `qa/` holds dated results and their exact candidate scope. The two 2026-11-10 records describe 1.0.6-qa; they are historical evidence, not acceptance of the current 1.0.7-qa source.

Before public publication: make this source repository private; pass current Beta source and installed ServOS QA; approve an exact source commit and generated runtime hashes. The public `TechEWorks/release/scriptsv1.0/` folder is the future distribution output, not an editable source or QA store.
