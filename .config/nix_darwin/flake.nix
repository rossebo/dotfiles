{
  description = "Elveblest nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

      system.primaryUser = "elveblest";

      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap"; 
        };
        brews = [
          "aom"
          "azure-cli"
          "azure-functions-core-tools@4"
          "bat"
          "borders"
          "brotli"
          "btop"
          "ca-certificates"
          "cmatrix"
          "curl"
          "docker"
          "docker-completion"
          "docker-compose"
          "eza"
          "fd"
          "fontconfig"
          "freetype"
          "fzf"
          "gettext"
          "giflib"
          "git-delta"
          "glib"
          "go"
          "golangci-lint"
          "highway"
          "imagemagick"
          "imath"
          "jasper"
          "jpeg-turbo"
          "jpeg-xl"
          "jq"
          "lazygit"
          "libde265"
          "libdeflate"
          "libevent"
          "libgit2"
          "libheif"
          "libidn2"
          "liblqr"
          "libnghttp2"
          "libnghttp3"
          "libngtcp2"
          "libomp"
          "libpng"
          "libraw"
          "libsodium"
          "libssh2"
          "libtiff"
          "libtool"
          "libunistring"
          "libuv"
          "libvmaf"
          "libyaml"
          "libzip"
          "little-cms2"
          "lpeg"
          "lua"
          "luajit"
          "luarocks"
          "luv"
          "lz4"
          "m4"
          "mpdecimal"
          "ncurses"
          "neovim"
          "nvm"
          "oniguruma"
          "openexr"
          "openjpeg"
          "openjph"
          "openssl@3"
          "pcre2"
          "pnpm"
          "podman"
          "python@3.13"
          "readline"
          "ripgrep"
          "rtmpdump"
          "shared-mime-info"
          "sketchybar"
          "skhd"
          "sqlite"
          "starship"
          "stow"
          "terraform"
          "tlrc"
          "tmux"
          "tree-sitter"
          "unibilium"
          "utf8proc"
          "webp"
          "wget"
          "x265"
          "xz"
          "yabai"
          "yarn"
          "yazi"
          "zoxide"
          "zstd"
        ];
        casks = [
          "alfred"
          "bazecor"
          "blender"
          "discord"
          "dotnet-sdk"
          "firefox"
          "font-cascadia-code"
          "font-hack-nerd-font"
          "font-sf-pro"
          "kitty"
          "microsoft-auto-update"
          "microsoft-teams"
          "obsidian"
          "orbstack"
          "powershell"
          "qutebrowser"
          "rider"
          "sf-symbols"
          "slack"
          "steam"
          "visual-studio-code"
          "xnviewmp"
        ];
        masApps = {
        };
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#m3
    darwinConfigurations."m3" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew 
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "elveblest";

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
