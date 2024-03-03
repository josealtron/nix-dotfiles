{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "josealtron";
  home.homeDirectory = "/home/josealtron";
  targets.genericLinux.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.btop
    pkgs.tree

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/josealtron/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = rec {
     DOTLOCAL = "$HOME/.local";
     LOCAL_APPS = "${DOTLOCAL}/applications";
     CARGO_HOME="${LOCAL_APPS}/cargo";
     RUSTUP_HOME="${LOCAL_APPS}/rustup";
     GOPATH="${LOCAL_APPS}/prebuilt/go";

     XDG_CONFIG_HOME="$HOME/.config";
     XDG_CACHE_HOME="$HOME/.cache";
     XDG_DATA_HOME="$HOME/.local/share";
     XDG_STATE_HOME="$HOME/.local/state";
     GNUPGHOME="${XDG_CONFIG_HOME}/gnupg";
     GRADLE_USER_HOME="${XDG_CONFIG_HOME}/gradle";
     LESSHSTFILE="${XDG_CONFIG_HOME}/less/lesshst";

     EDITOR="hx";
     VISUAL="hx";

     KEYTIMEOUT=1;


     ZDOTDIR="${XDG_CONFIG_HOME}/zsh";
     ZSHRC="${ZDOTDIR}/.zshrc";

     LC_ALL="en_US.UTF-8";
     LANG="en_US.UTF-8";
     LC_CTYPE="en_US.UTF-8";
     LANGUAGE="en_US.UTF-8";
  };

# Programs with custom configuration
  programs = {
    home-manager = {
      enable = true;
      path = lib.mkForce "$HOME/dotfiles";
    };

    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      initExtraFirst = "source $ZDOTDIR/.zshrc_pre_nix";
      initExtra = ''
        setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
        bindkey -v
        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char
        bindkey -M menuselect 'j' vi-down-line-or-history
        bindkey -M vicmd 'v' edit-command-line
        bindkey '^ ' autosuggest-accept
        bindkey '^a' autosuggest-execute
        bindkey '^X' run-previous-cmd
      '';
      history = {
        ignoreAllDups = true;
        extended = true;
        path = "$ZDOTDIR/.zhistory";
      };
      autocd = true;
      syntaxHighlighting.enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      completionInit = ''
        autoload -Uz edit-command-line
        zle -N edit-command-line

        autoload -U compinit; compinit
        zmodload zsh/complist

        __comp_options+=(globdots) # With hidden files
        setopt ALWAYS_TO_END AUTO_PARAM_SLASH 

        ## completers

        zstyle ':completion:*' completer _extensions _complete _approximate 

        ## completion cache

        zstyle ':completion:*' use-cache on
        zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

        ## completion menu

        zstyle ':completion:*' menu select

        ## Groupings
        zstyle ':completion:*' group-name ''' # group by type of match
        zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

        ## Display descriptions for correction types
        zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %d --%f'
        zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d -!%f'

        zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}

        # Matching control
        ## Case Insensitive completions if case sensitive fails
        zstyle ':completion:*' matcher-list ''' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

        ## Try to complete partial words
        zstyle ':completion:*' matcher-list ''' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      '';

      zplug = {
        enable = true;
        plugins = [
          { name = "Tarrasch/zsh-bd"; }
        ];
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    helix = {
      enable = true;
      extraPackages = [ pkgs.nil ];
    };

    git = {
      enable = true;
      userName = "Jose Castejon";
      userEmail = "josealtron@gmail.com";
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    atuin = {
      enable = true;
    };

    zoxide = {
      enable = true;
    };
  }; # programs
}
