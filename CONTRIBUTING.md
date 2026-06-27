Every push and pull request runs [`.github/workflows/ci.yml`](.github/workflows/ci.yml):
formatting (`dart format`), static analysis (`flutter analyze`), a Pigeon
drift check, the unit/widget tests (against the minimum and latest stable
Flutter), a publish dry-run, and Android + iOS example builds.

Releases publish to pub.dev automatically from
[`.github/workflows/publish.yml`](.github/workflows/publish.yml). Required setup:

1. **pub.dev → package Admin → Automated publishing:** enable publishing from
   GitHub Actions, repository `carp-dk/carp_debug_flutter`, tag pattern
   `v{{version}}`.
2. **GitHub → Settings → Environments:** create an environment named `pub.dev`
   with *Required reviewers* so each release waits for human approval.

To cut a release: bump `version:` in `pubspec.yaml`, add a matching
`CHANGELOG.md` entry, then push the tag:

```sh
git tag v0.1.2 && git push origin v0.1.2
```

A job verifies the tag matches the pubspec version and the CHANGELOG
before the (irreversible) publish runs.
