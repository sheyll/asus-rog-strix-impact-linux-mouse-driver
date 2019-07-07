let
  pkgs = import ./nix/pkgs.nix;
    # cabal generates some directories and files that confuse nix
    # ignore them
  project-sources = pkgs.lib.cleanSourceWith {
      filter = (path: type:
        let base = baseNameOf (toString path);
        in !(pkgs.lib.hasPrefix ".ghc.environment." base) &&
          !(pkgs.lib.hasSuffix ".nix" base)
      );
      src = pkgs.lib.cleanSource ./.;
   };

  asusThingie = 
   pkgs.haskellPackages.callCabal2nix "asus-rog-strix-impact-linux-mouse-driver"  project-sources 
     {hidapi-native = pkgs.hidapi; };

in
  with pkgs.haskell.lib;

  overrideCabal asusThingie (drv:
     { 
       executableSystemDepends = (drv.executableSystemDepends or []) ++ [pkgs.hidapi];
       executableHaskellDepends = (drv.executableHaskellDepends or []) ++ [pkgs.haskellPackages.hidapi];
     }
  )
