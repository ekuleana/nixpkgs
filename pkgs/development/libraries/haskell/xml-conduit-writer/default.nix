# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, dlist, mtl, text, xmlConduit, xmlTypes }:

cabal.mkDerivation (self: {
  pname = "xml-conduit-writer";
  version = "0.1.1.1";
  sha256 = "1ibiqxjr63gb3v0h9fdfzm205sqjixb5vm5y6413yn4scbf7qm2b";
  buildDepends = [ dlist mtl text xmlConduit xmlTypes ];
  testDepends = [ text ];
  meta = {
    homepage = "https://bitbucket.org/dpwiz/xml-conduit-writer";
    description = "Warm and fuzzy creation of XML documents";
    license = self.stdenv.lib.licenses.mit;
    platforms = self.ghc.meta.platforms;
  };
})
