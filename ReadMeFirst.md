# Read me first — TechE scripts v1.0

Read the [TechE scripts Debian client policy](https://github.com/TechEWorks/standards/blob/main/TechE%20scripts%20client%20policy.md) before changing bootstrap, package paths or ServOS integration.

On each new ServOS Debian client, `/usr/bin/teche` is the native bootstrap and root's stable full-path command. An authorized administrator runs `sudo /usr/bin/teche get scriptsv1.0`. The approved scripts package belongs at `/teche.scripts/v1.0/`, with `current/` pointing to the active verified revision and `releases/` retaining earlier revisions. The full dispatcher path is `/teche.scripts/v1.0/current/bin/teche`.

Edit and test this repository as source. Publish only approved runtime files and a regenerated `SHA256SUMS.txt` to `TechEWorks/release/scriptsv1.0/`; installed clients pull from that public location. Fetching scripts does not install WorkDesk.

The source bootstrap, dispatcher and pull fixture target this path. The ServOS installer source must carry the matching bootstrap. Public availability and installed-machine QA are separate release gates. Verify both on the exact published runtime and ServOS ISO before describing the pull as deployed.
