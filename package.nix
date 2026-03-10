{
  lib,
  stdenv,
  darwinMinVersionHook,
  meson,
  ninja,
  pkg-config,
  libllvm,
  libxml2,
  vapoursynth,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "akarin";
  version = "1.2.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.intersection (lib.fileset.fromSource (lib.sources.cleanSource ./.)) (
      lib.fileset.unions [
        ./banding
        ./expr
        ./expr2
        ./ngx
        ./text
        ./vfx
        ./meson_options.txt
        ./meson.build
        ./plugin.cpp
        ./plugin.h
        ./version.h.in
      ]
    );
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs =
    [
      libllvm
      libxml2
      vapoursynth
    ]
    # `std::to_chars()` for floating-point types was introduced in macOS 13.3.
    ++ lib.optional stdenv.hostPlatform.isDarwin (darwinMinVersionHook "13.3");

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "vapoursynth_dep.get_pkgconfig_variable('libdir')" "get_option('libdir')"
  '';

  meta = {
    homepage = "https://github.com/Jaded-Encoding-Thaumaturgy/akarin-vapoursynth-plugin";
    license = lib.licenses.lgpl3;
    platforms = lib.platforms.all;
  };
})
