return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "filemention" },
      providers = {
        filemention = {
          name = "filemention",
          module = "filemention.sources.blink",
        },
      },
    },
    keymap = {
      ["<C-y>"] = { "select_and_accept" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
    },
  },
}
