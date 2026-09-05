-- full border
require("full-border"):setup()

-- no status bar
-- require("no-status"):setup()
--
require("starship"):setup()

require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}
