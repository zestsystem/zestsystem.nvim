{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in rec {
  mkVimPlugin = {system}: let
    inherit (pkgs) vimUtils;
    inherit (vimUtils) buildVimPlugin;
    pkgs = legacyPackages.${system};
  in
    buildVimPlugin {
      buildInputs = with pkgs; [doppler nodejs];

      dependencies = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        rust-tools-nvim
        purescript-vim
        haskell-tools-nvim
        conform-nvim


        # telescope
        plenary-nvim
        popup-nvim
        telescope-nvim

        # theme
        rose-pine

        # extras
        ChatGPT-nvim
        copilot-lua
        gitsigns-nvim
        undotree
        lualine-nvim
        nerdcommenter
        noice-nvim
        nui-nvim
        nvim-colorizer-lua
        nvim-notify
        nvim-treesitter-context
        rainbow-delimiters-nvim
        vim-fugitive
        harpoon

        luasnip
        # autocomplete
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        friendly-snippets
        cmp_luasnip
      ];

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
    pkgs = legacyPackages.${system};
    zestsystem-nvim = mkVimPlugin {inherit system;};
  in
    with vimPlugins; [
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
      nodePackages."typescript"
      nodePackages."typescript-language-server"
      nodePackages."vscode-langservers-extracted"
      nodePackages."@tailwindcss/language-server"
      nodePackages."yaml-language-server"
      ocamlPackages.lsp
      pyright
      rust-analyzer
      svelte-language-server
      terraform-ls

      # formatters
      prettierd
      gofumpt
      golines
      alejandra
      python3Packages.black
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
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}
