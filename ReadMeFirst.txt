# Read me first — TechE scripts v1.0

Read the [TechE scripts client policy](https://github.com/TechEWorks/standards/blob/main/TechE%20scripts%20client%20policy.md) and [s4](https://github.com/TechEWorks/standards/blob/main/s4.txt) before changing this component.

This repository owns the editable Beta source. The active packet is [03-beta/ReadMeFirst.txt](03-beta/ReadMeFirst.txt). GitHub repository visibility must be private while the source is in Beta. The repository is currently public, so the privacy gate remains open; a stage folder does not restrict access.

The Debian client keeps the native command at `/usr/bin/teche`. Approved downloaded scripts live under `/teche.scripts/v1.0/`, with `current/` and `releases/`. ServOS carries only the bootstrap from `03-beta/src/bootstrap/teche`. Installed clients fetch approved runtime files from the public `TechEWorks/release/scriptsv1.0/` path after release approval.

The current public release path is absent. The Beta fixture test is source QA, not proof of a public HTTPS pull or a newly installed ServOS ISO. Historical 1.0.6-qa records remain in `03-beta/qa/`; they do not qualify 1.0.7-qa.
