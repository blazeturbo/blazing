# Yazi: minimal 3-pane setup on the Stylix palette.
#
# How theming works here: init.lua and theme.toml are GENERATED below from
# config.lib.stylix.colors (change wallpaper, rebuild, yazi follows), so
# the static init.lua/theme.toml files are gone. yazi.toml, keymap.toml,
# package.toml, flavors/ and plugins/ stay plain sources.
# Deliberately dropped for the minimal look: full-border rounded boxes,
# yatline githead + task widgets, status counts/percentages/extensions,
# and the catppuccin flavor (replaced by the stylix theme below).
{ config, lib, ... }:
let
  c = config.lib.stylix.colors;
  hex = h: "#${h}";
in {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    shellWrapperName = "yy";
  };

  xdg.configFile = {
    "yazi/yazi.toml".source = ./yazi.toml;
    "yazi/keymap.toml".source = ./keymap.toml;
    "yazi/package.toml".source = ./package.toml;

    "yazi/flavors".source = ./flavors;
    "yazi/plugins".source = ./plugins;

    # Minimal stylix theme: white names, blue folder icons, subtle hover.
    # No flavor (flavors override all of this).
    # Icon rules: yazi matches globs -> named dirs/files/exts -> conds,
    # so generic conds alone LOSE to the built-in per-name devicons
    # (that mixed mess was the "broken" look). Empty tables replace the
    # built-ins, leaving ONLY the two generic conds: every folder gets
    # the same blue folder glyph, every file the same white file glyph.
    "yazi/theme.toml".text = ''
      [mgr]
      hovered = { bg = "${hex c.base02}" }
      preview_hovered = { bg = "${hex c.base02}" }
      find_keyword = { fg = "${hex c.base0A}", bold = true }
      find_position = { fg = "${hex c.base0D}", bold = true }
      marker_selected = { fg = "${hex c.base0A}", bg = "${hex c.base0A}" }
      marker_copied = { fg = "${hex c.base0B}", bg = "${hex c.base0B}" }
      marker_cut = { fg = "${hex c.base08}", bg = "${hex c.base08}" }
      border_style = { fg = "${hex c.base03}" }

      [icon]
      globs = []
      dirs = {}
      files = {}
      exts = {}
      conds = [
        { if = "dir", text = "", fg = "${hex c.base0D}" },
        { if = "!dir", text = "", fg = "${hex c.base05}" },
      ]

      [filetype]
      rules = [
        { url = "*/", fg = "${hex c.base05}" },
        { url = "*", fg = "${hex c.base05}" },
      ]
    '';

    # yatline setup: tabs + path breadcrumb on top; mode, size, name on
    # the left of the status bar, position + permissions on the right.
    # Palette keys keep their names so every reference below just works —
    # only the hex values follow Stylix.
    "yazi/init.lua".text = ''
      local stylix_palette = {
        rosewater = "${hex c.base05}",
        flamingo = "${hex c.base05}",
        pink = "${hex c.base0E}",
        mauve = "${hex c.base0E}",
        red = "${hex c.base08}",
        maroon = "${hex c.base08}",
        peach = "${hex c.base0A}",
        yellow = "${hex c.base0A}",
        green = "${hex c.base0B}",
        teal = "${hex c.base0C}",
        sky = "${hex c.base0C}",
        sapphire = "${hex c.base0C}",
        blue = "${hex c.base0D}",
        lavender = "${hex c.base0E}",
        text = "${hex c.base05}",
        subtext1 = "${hex c.base05}",
        subtext0 = "${hex c.base04}",
        overlay2 = "${hex c.base03}",
        overlay1 = "${hex c.base03}",
        overlay0 = "${hex c.base03}",
        surface2 = "${hex c.base02}",
        surface1 = "${hex c.base01}",
        surface0 = "${hex c.base01}",
        base = "${hex c.base00}",
        mantle = "${hex c.base00}",
        crust = "${hex c.base00}",
      }
      local catppuccin_palette = stylix_palette

      -- Plugins
      require("zoxide"):setup({
        update_db = true,
      })

      require("session"):setup({
        sync_yanked = true,
      })

      require("yatline"):setup({
        section_separator = { open = "", close = "" },
        inverse_separator = { open = "", close = "" },
        part_separator = { open = "", close = "" },

        style_a = {
          fg = catppuccin_palette.mantle,
          bg_mode = {
            normal = catppuccin_palette.blue,
            select = catppuccin_palette.mauve,
            un_set = catppuccin_palette.red,
          },
        },
        style_b = { bg = catppuccin_palette.surface0, fg = catppuccin_palette.text },
        style_c = { bg = catppuccin_palette.base, fg = catppuccin_palette.text },

        permissions_t_fg = catppuccin_palette.green,
        permissions_r_fg = catppuccin_palette.yellow,
        permissions_w_fg = catppuccin_palette.red,
        permissions_x_fg = catppuccin_palette.sky,
        permissions_s_fg = catppuccin_palette.lavender,

        selected = { icon = "", fg = catppuccin_palette.yellow },
        copied = { icon = "", fg = catppuccin_palette.green },
        cut = { icon = "", fg = catppuccin_palette.red },

        total = { icon = "", fg = catppuccin_palette.yellow },
        succ = { icon = "", fg = catppuccin_palette.green },
        fail = { icon = "", fg = catppuccin_palette.red },
        found = { icon = "", fg = catppuccin_palette.blue },
        processed = { icon = "", fg = catppuccin_palette.green },

        tab_width = 20,
        tab_use_inverse = true,

        show_background = false,

        display_header_line = true,
        display_status_line = true,

        header_line = {
          left = {
            section_a = {
              { type = "line", custom = false, name = "tabs", params = { "left" } },
            },
            section_b = {},
            section_c = {},
          },
          right = {
            section_a = {
              { type = "string", custom = false, name = "tab_path" },
            },
            section_b = {},
            section_c = {},
          },
        },

        status_line = {
          left = {
            section_a = {
              { type = "string", custom = false, name = "tab_mode" },
            },
            section_b = {
              { type = "string", custom = false, name = "hovered_size" },
            },
            section_c = {
              { type = "string", custom = false, name = "hovered_name" },
            },
          },
          right = {
            section_a = {
              { type = "string", custom = false, name = "cursor_position" },
            },
            section_b = {
              { type = "coloreds", custom = false, name = "permissions" },
            },
            section_c = {},
          },
        },
      })
    '';
  };
}
