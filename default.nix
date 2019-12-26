{ pkgs ? import <nixpkgs> {}}:

with pkgs;

mkShell rec {
  buildInputs = [
    mecab git gnumake curl lzma patch python3
  ];
}
