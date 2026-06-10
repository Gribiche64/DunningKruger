# DunningKruger (Kreugerizer-5000)

Multi-platform SwiftUI app for placing people on a Dunning-Kruger curve —
drag named markers along the confidence/competence arc and watch them sit
where they deserve. Runs on iOS, macOS, and visionOS 2.0.

## Build

Open `DunningKruger.xcodeproj` in Xcode 16+ and build the target for your
platform. The project file is generated from `project.yml` with
[XcodeGen](https://github.com/yonaskolb/XcodeGen) — if you change project
structure, edit `project.yml` and re-run `xcodegen`, don't hand-edit the
xcodeproj.

## Structure

- `DunningKruger/Views/` — chart, markers, splash, responsive layout
  (`markerScale()` scales markers with window size)
- `DunningKruger/Models/` — people/placement model
- `DunningKruger/Theme/` — colours and typography
- `DunningKruger/Utilities/`

## Dependencies

None beyond Xcode. No tests yet (see QC_REPORT.md for the standing audit
notes).
