#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
build_dir="$repo_root/build/swiftbar"
source_dir="$build_dir/source"
app_path="$build_dir/SwiftBar.app"

revision="13f0fd8b3e322c28c95dcfaea47aef41c5705d02"

mkdir -p "$build_dir"
rm -rf "$source_dir"

git clone https://github.com/swiftbar/SwiftBar.git "$source_dir"
git -C "$source_dir" checkout --detach "$revision"
git -C "$source_dir" apply "$repo_root/patches/swiftbar/sort-plugins-deterministically.patch"

xcodebuild \
  -project "$source_dir/SwiftBar.xcodeproj" \
  -scheme SwiftBar \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$build_dir/DerivedData" \
  -clonedSourcePackagesDirPath "$build_dir/SourcePackages" \
  -packageCachePath "$build_dir/PackageCache" \
  CODE_SIGNING_ALLOWED=NO \
  build

app_build_path="$build_dir/DerivedData/Build/Products/Release/SwiftBar.app"

test -d "$app_build_path"
rm -rf "$app_path"
ditto "$app_build_path" "$app_path"

mkdir -p "$HOME/Applications"
ditto "$app_path" "$HOME/Applications/SwiftBar.app"
echo "Built SwiftBar"
