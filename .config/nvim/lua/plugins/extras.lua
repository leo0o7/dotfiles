return {
	-- keep indent guides available via <leader>ug, but off on startup
	-- Saturn dashboard header
	{
		"folke/snacks.nvim",
		opts = {
			indent = {
				enabled = false,
			},
			dashboard = {
				preset = {
					header = [[






                                                   
                                              ___  
                                           ,o88888 
                                        ,o8888888' 
                  ,:o:o:oooo.        ,8O88Pd8888"  
              ,.::.::o:ooooOoOoO. ,oO8O8Pd888'"    
            ,.:.::o:ooOoOoOO8O8OOo.8OOPd8O8O"      
           , ..:.::o:ooOoOOOO8OOOOo.FdO8O8"        
          , ..:.::o:ooOoOO8O888O8O,COCOO"          
         , . ..:.::o:ooOoOOOO8OOOOCOCO"            
          . ..:.::o:ooOoOoOO8O8OCCCC"o             
             . ..:.::o:ooooOoCoCCC"o:o             
             . ..:.::o:o:,cooooCo"oo:o:            
          `   . . ..:.:cocoooo"'o:o:::'            
          .`   . ..::ccccoc"'o:o:o:::'             
         :.:.    ,c:cccc"':.:.:.:.:.'              
       ..:.:"'`::::c:"'..:.:.:.:.:.'               
     ...:.'.:.::::"'    . . . . .'                 
    .. . ....:."' `   .  . . ''                    
  . . . ...."'                                     
  .. . ."'                                         
 .                                                 
                ]],
				},
			},
		},
	},
	-- surround with motions (updated keymaps)
	{
		"nvim-mini/mini.surround",
		opts = {
			mappings = {
				add = "sa", -- Add surrounding in Normal and Visual modes
				delete = "sd", -- Delete surrounding
				find = "sf", -- Find surrounding (to the right)
				find_left = "sF", -- Find surrounding (to the left)
				highlight = "sh", -- Highlight surrounding
				replace = "sr", -- Replace surrounding
				update_n_lines = "sn", -- Update `n_lines`
			},
		},
	},
	-- flash search (updated keymaps)
	{
		"folke/flash.nvim",
		keys = {
			-- disable default search with s
			{
				"s",
				mode = { "n", "x", "o" },
				false,
			},
			-- disable default treesitter search with S
			{
				"S",
				mode = { "n", "o", "x" },
				false,
			},
			-- disable <c-s> search
			{
				"<c-s>",
				mode = { "c" },
				false,
			},
			-- move default search to S
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			-- move treesitter search to <c-s>
			{
				"<C-s>",
				mode = { "n", "o", "x" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
		},
	},
	-- floating filename
	{
		"b0o/incline.nvim",
		dependencies = {},
		event = "BufReadPre",
		priority = 1200,
		config = function()
			local helpers = require("incline.helpers")
			require("incline").setup({
				window = {
					padding = 0,
					margin = { horizontal = 0 },
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
					local modified = vim.bo[props.buf].modified
					local buffer = {
						ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) }
							or "",
						" ",
						{ filename, gui = modified and "bold,italic" or "bold" },
						" ",
						guibg = "#363944",
					}
					return buffer
				end,
			})
		end,
	},
}
