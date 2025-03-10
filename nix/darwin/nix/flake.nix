{
  description = "Xentatt Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.alacritty
          pkgs.kitty
          pkgs.mkalias
          pkgs.neovim
          pkgs.emacs
          pkgs.libgccjit
          pkgs.tmux
          pkgs.btop
          pkgs.curl
          pkgs.fzf
          pkgs.gnupg
          pkgs.go
          pkgs.gopls
          pkgs.speedtest-cli
          pkgs.smartmontools
          pkgs.tree
          pkgs.wget
          pkgs.pass
          pkgs.fastfetch
          pkgs.b2sum
          pkgs.rfc
          pkgs.opam
        ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "zsh-syntax-highlighting"
          "podman"
        ];
        casks = [
          "hammerspoon"
          "firefox"
          "google-chrome"
          "iina"
          "vlc"
          "audacity"
          "signal"
          "djview"
          "yacreader"
          "dotnet-sdk"
          "mono-mdk"
          "qbittorrent"
          "calibre"
          "utm"
          "obsidian"
          "monitorcontrol"
          "hot"
        ];
        masApps = {
          "Telegram" = 747648890;
          "Windows RDP" = 1295203466;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';

      system.defaults = {
        dock.autohide = true;
        dock.persistent-apps = [
          "/Applications/Google\ Chrome.app"
          "/Applications/iTerm.app"
          #"${pkgs.obsidian}/Applications/Obsidian.app"
          "/System/Applications/Launchpad.app"
        ];

        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.KeyRepeat = 2;
        NSGlobalDomain.InitialKeyRepeat = 15;
      };

      system.keyboard = {
        #enableKeyMapping = true;
        #remapCapsLockToControl = true;
      };

      # Auto upgrade nix package and the daemon service.
      #services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # For more changes description check this PR
      # https://github.com/LnL7/nix-darwin/pull/1313/files
      nix.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."m1" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # Apple Silicon Only
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = "xentatt";
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."m1".pkgs;
  };
}
