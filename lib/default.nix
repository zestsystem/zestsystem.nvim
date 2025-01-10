{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in rec {
  mkCopilotChat = {system}: let
    inherit (pkgs) vimUtils;
    inherit (vimUtils) buildVimPlugin;
    pkgs = legacyPackages.${system};
  in
    buildVimPlugin {
      name = "CopilotChat";
      src = inputs.copilotchat;
    };

  mkVimPlugin = {system}: let
    inherit (pkgs) vimUtils;
    inherit (vimUtils) buildVimPlugin;
    pkgs = legacyPackages.${system};
  in
    buildVimPlugin {
      name = "zestsystem";
      postInstall = ''
        rm -rf $out/.envrc
        rm -rf $out/.gitignore
        rm -rf $out/LICENSE
        rm -rf $out/README.md
        rm -rf $out/flake.lock
        rm -rf $out/flake.nix
        rm -rf $out/justfile
        rm -rf $out/lib
      '';
      src = ../.;
    };

  mkNeovimPlugins = {system}: let
    inherit (pkgs) vimPlugins;
    CopilotChat-nvim = mkCopilotChat {inherit system;};
    pkgs = legacyPackages.${system};
    zestsystem-nvim = mkVimPlugin {inherit system;};
    vim-just = pkgs.vimUtils.buildVimPlugin {
      name = "vim-just";
      nativeBuildInputs = with pkgs; [pkg-config readline];
      src = pkgs.fetchFromGitHub {
        owner = "NoahTheDuke";
        repo = "vim-just";
        rev = "927b41825b9cd07a40fc15b4c68635c4b36fa923";
        sha256 = "sha256-BmxYWUVBzTowH68eWNrQKV1fNN9d1hRuCnXqbEagRoY=";
      };
    };
  in [
    # languages
    vim-just
    vimPlugins.nvim-lspconfig
    vimPlugins.nvim-treesitter.withAllGrammars
    vimPlugins.null-ls-nvim
    vimPlugins.rust-tools-nvim
    vimPlugins.purescript-vim
    vimPlugins.haskell-tools-nvim

    # telescope
    vimPlugins.plenary-nvim
    vimPlugins.popup-nvim
    vimPlugins.telescope-nvim

    # theme
    vimPlugins.rose-pine

    # extras
    vimPlugins.ChatGPT-nvim
    vimPlugins.copilot-lua
    vimPlugins.gitsigns-nvim
    vimPlugins.lualine-nvim
    vimPlugins.nerdcommenter
    vimPlugins.noice-nvim
    vimPlugins.nui-nvim
    vimPlugins.nvim-colorizer-lua
    vimPlugins.nvim-notify
    vimPlugins.nvim-treesitter-context
    vimPlugins.rainbow-delimiters-nvim
    vimPlugins.vim-fugitive
    vimPlugins.harpoon

    vimPlugins.luasnip
    # autocomplete
    vimPlugins.nvim-cmp
    vimPlugins.cmp-nvim-lsp
    vimPlugins.cmp-buffer
    vimPlugins.cmp-path
    vimPlugins.friendly-snippets
    vimPlugins.cmp_luasnip
    #vimPlugins.nvim-web-devicons # https://github.com/intel/intel-one-mono/issues/9

    # configuration
    zestsystem-nvim
  ];

  mkExtraPackages = {system}: let
    inherit (pkgs) nodePackages python3Packages;
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
    with pkgs; [
      # languages
      nodejs
      python314
      rustc

      # language servers
      gopls
      haskell-language-server
      lua-language-server
      nil
      nodePackages."bash-language-server"
      nodePackages."coc-clangd"
      nodePackages."diagnostic-languageserver"
      nodePackages."dockerfile-language-server-nodejs"
      nodePackages."purescript-language-server"
      nodePackages."svelte-language-server"
      nodePackages."typescript"
      nodePackages."typescript-language-server"
      nodePackages."vscode-langservers-extracted"
      nodePackages."@tailwindcss/language-server"
      nodePackages."yaml-language-server"
      ocamlPackages.lsp
      pyright
      rust-analyzer
      terraform-ls

      # formatters
      gofumpt
      golines
      alejandra
      python314Packages.black
      rustfmt
      terraform

      # tools
      cargo
      clang-tools
      gcc
      ghc
      yarn
    ];

  mkExtraConfig = ''
    lua << EOF
      require 'zestsystem'.init()
    EOF
  '';

  mkNeovim = {system}: let
    inherit (pkgs) lib neovim;
    extraPackages = mkExtraPackages {inherit system;};
    pkgs = legacyPackages.${system};
    start = mkNeovimPlugins {inherit system;};
  in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = {inherit start;};
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${lib.makeBinPath extraPackages}"'';
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

  mkHomeManager = {system}: let
    extraConfig = mkExtraConfig;
    extraPackages = mkExtraPackages {inherit system;};
    plugins = mkNeovimPlugins {inherit system;};
  in {
    inherit extraConfig extraPackages plugins;
    defaultEditor = true;
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}
