 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#231a21',
    base01 = '#3b2b37',
    base02 = '#352732',
    base03 = '#72636e',
    base04 = '#b6afb4',
    base05 = '#f3f2f3',
    base06 = '#f3f2f3',
    base07 = '#f3f2f3',
    base08 = '#fd4663',
    base09 = '#ad8f85',
    base0A = '#be7481',
    base0B = '#c18bb3',
    base0C = '#d0b7af',
    base0D = '#d3acc9',
    base0E = '#d6a8b0',
    base0F = '#e7cbd0',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#f3f2f3',          bg = '#231a21' })
  hi('TelescopeBorder',         { fg = '#72636e',             bg = '#231a21' })
  hi('TelescopePromptNormal',   { fg = '#f3f2f3',          bg = '#231a21' })
  hi('TelescopePromptBorder',   { fg = '#72636e',             bg = '#231a21' })
  hi('TelescopePromptPrefix',   { fg = '#c18bb3',             bg = '#231a21' })
  hi('TelescopePromptCounter',  { fg = '#b6afb4',  bg = '#231a21' })
  hi('TelescopePromptTitle',    { fg = '#231a21',             bg = '#c18bb3' })
  hi('TelescopePreviewTitle',   { fg = '#231a21',             bg = '#be7481' })
  hi('TelescopeResultsTitle',   { fg = '#231a21',             bg = '#ad8f85' })
  hi('TelescopeSelection',      { fg = '#f3f2f3',          bg = '#352732' })
  hi('TelescopeSelectionCaret', { fg = '#c18bb3',             bg = '#352732' })
  hi('TelescopeMatching',       { fg = '#c18bb3',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
