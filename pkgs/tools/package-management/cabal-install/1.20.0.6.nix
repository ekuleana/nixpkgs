# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, Cabal, filepath, HTTP, HUnit, mtl, network, networkUri
, QuickCheck, random, stm, testFramework, testFrameworkHunit
, testFrameworkQuickcheck2, time, zlib
}:

cabal.mkDerivation (self: {
  pname = "cabal-install";
  version = "1.20.0.6";
  sha256 = "1hc187yzl59518cswk25xzsabn9dvm4wqpq817hmclrvkf4zr3pl";
  isLibrary = false;
  isExecutable = true;
  buildDepends = [
    Cabal filepath HTTP mtl network networkUri random stm time zlib
  ];
  testDepends = [
    Cabal filepath HTTP HUnit mtl network networkUri QuickCheck stm
    testFramework testFrameworkHunit testFrameworkQuickcheck2 time zlib
  ];
  doCheck = false;
  postInstall = ''
    mkdir $out/etc
    mv bash-completion $out/etc/bash_completion.d
  '';
  meta = {
    homepage = "http://www.haskell.org/cabal/";
    description = "The command-line interface for Cabal and Hackage";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
