{ pkgs ? import <nixpkgs> { } }:
let
  linuxPkgs = with pkgs; lib.optional stdenv.isLinux (
    inotify-tools
  );
  macosPkgs = with pkgs; lib.optional stdenv.isDarwin (
    with darwin.apple_sdk.frameworks; [
      CoreFoundation
      CoreServices
    ]
  );
in
with pkgs;
mkShell {
  nativeBuildInputs = [
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    kubectl
    kubeseal
    kubetail
    k9s

    # custom pkg groups
    linuxPkgs
    macosPkgs
  ];
}
