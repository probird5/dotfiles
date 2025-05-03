return {
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended version
  lazy = false,   -- This plugin is already lazy
  ["rust-analyzer"] = {
    cargo = {
      allFeatures = true, -- Enable all features for Cargo
    },
  },
}

