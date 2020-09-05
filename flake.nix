{
  description = "Dreyri's emacs configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    emacs.url = "github:nix-community/emacs-overlay/master";
  };

  outputs = { self, nixpkgs, emacs }:
    let
      allSystems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f system);
      extraPackages = epkgs: (with epkgs.elpaPackages; [
        delight
      ]) ++ (with epkgs.orgPackages; [
        org-plus-contrib
      ]) ++ (with epkgs.melpaPackages; [
        format-all
		build-farm
		company-nixos-options
		nix-mode
		nix-update
		nixos-options
		nixpkgs-fmt
		use-package
		which-key
		paredit
		evil-paredit
		lispy
		evil
		evil-collection
		evil-escape
		general
		golden-ratio
		org-journal
		org-bullets
		evil-org
		modern-cpp-font-lock
		magit
		forge
		magit-gh-pulls
		magit-gitflow
		evil-magit
		git-commit
		git-timemachine
		gitignore-mode
		ivy
		ivy-xref
		ivy-rich
		swiper
		avy
		ace-window
		ace-jump-mode
		projectile
		all-the-icons
		all-the-icons-ivy
		geiser
		powerline
		moe-theme
		company
		company-quickhelp
		company-box
		company-lsp
		lsp-mode
		lsp-ui
		ccls
		cquery
		dap-mode
		rust-mode
		cargo
		flycheck
		flycheck-popup-tip
		flycheck-rust
		yasnippet
		gitconfig-mode	
		lua-mode
		yaml-mode
		cmake-mode
		meson-mode
      ]);

      emacsPackages = emacs: final: final.emacsPackagesFor emacs;
      emacsWithPackages = emacs: final: (emacsPackages emacs final).emacsWithPackages;
    in rec {
      overlay = final: prev: {
        emacs-dreyri = emacs: (emacsWithPackages emacs final) extraPackages;
      };

      defaultPackage = 
        let pkgsForSystem = system: import emacs { inherit system; overlays = [ self.overlay emacs.overlay ]; };
      in
        forAllSystems (system: ((pkgsForSystem system).emacs-dreyri (pkgsForSystem system).emacs)); 

    };
}
