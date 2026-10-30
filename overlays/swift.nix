# Nixpkgs builds Swift from source, which pulls in a large compiler build
# closure. Use Swift.org's pinned macOS binary toolchain while keeping the
# familiar pkgs.swift and pkgs.swiftpm interface for the rest of the config.

{ nixpkgs }:
final: _prev:
let
  swiftVersion = "6.4.1";
  swiftToolchain = final.stdenvNoCC.mkDerivation {
    pname = "swift-toolchain";
    version = swiftVersion;

    src = final.fetchurl {
      url = "https://download.swift.org/swift-${swiftVersion}-release/xcode/swift-${swiftVersion}-RELEASE/swift-${swiftVersion}-RELEASE-osx.pkg";
      hash = "sha256-w05+X7C+S81h3s/UDbF2ZDTYlS1o43rtkLz/ToVHlRw=";
    };

    nativeBuildInputs = [
      final.xar
      final.cpio
    ];

    # Reuse nixpkgs' SwiftPM helpers and disable its nested sandbox. Nix already
    # provides the build sandbox, and the upstream toolchain cannot start another.
    setupHook = final.writeText "swiftpm-setup-hook.sh" ''
      source ${nixpkgs}/pkgs/development/compilers/swift/swiftpm/setup-hook.sh
      swiftpmFlagsArray+=(
        --disable-sandbox
        -Xlinker
        -L${final.libcxx}/lib
      )
    '';

    sourceRoot = ".";
    unpackPhase = ''
      runHook preUnpack
      xar -xf "$src"
      payload=$(find . -type f -name Payload -print -quit)
      test -n "$payload"
      cd "$(dirname "$payload")"
      gzip -dc Payload | cpio -idm
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      toolchain="$out/Library/Developer/Toolchains/swift-${swiftVersion}-RELEASE.xctoolchain"
      mkdir -p "$toolchain" "$out/bin"
      cp -R Developer System usr Info.plist _CodeSignature "$toolchain/"
      for executable in "$toolchain"/usr/bin/*; do
        if [ -x "$executable" ] && [ ! -d "$executable" ]; then
          wrapper="$out/bin/''${executable##*/}"
          cat > "$wrapper" <<EOF
      #!/bin/sh
      exec "$executable" "\$@"
      EOF
          chmod +x "$wrapper"
        fi
      done
      runHook postInstall
    '';
  };
in
{
  swift = swiftToolchain;
  swiftpm = swiftToolchain;
}
