-- ============================================================
--  init.lua — Configuración de Neovim
--  oxido-i3-themes: los colores cambian según el tema de i3
-- ============================================================

-- ─── Protocolo de terminal (fix de teclas) ───
-- Al entrar a nvim: envía "CSI > 1 u" para habilitar el modo de
-- keyboard correcto en terminales compatibles (kitty, wezterm)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() io.stdout:write("\027[>1u") end,
})
-- Al salir de nvim: restaura el modo de teclado original
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function() io.stdout:write("\027[<1u") end,
})

-- ─── Apariencia ───
vim.opt.number = true          -- Muestra números de línea a la izquierda
vim.opt.relativenumber = false -- Números absolutos (no relativos)
vim.opt.cursorline = true      -- Resalta la línea donde está el cursor
vim.opt.termguicolors = true   -- Activa colores de 24 bits (true color)

-- ─── Edición ───
vim.opt.wrap = false           -- No corta líneas largas automáticamente
vim.opt.expandtab = false      -- Usa tabs reales (no los convierte a espacios)
vim.opt.tabstop = 4            -- Un tab (→) ocupa 4 posiciones
vim.opt.shiftwidth = 4         -- >> / << / Tab indentan 4 espacios
vim.opt.clipboard = "unnamedplus" -- Comparte portapapeles con el sistema (Ctrl+C/V)

-- ─── Archivos ───
vim.opt.swapfile = false       -- No crea archivos .swp

-- ─── Resaltado de sintaxis ───
vim.cmd('syntax enable')       -- Activa el coloreado de código por palabra clave

-- ─── Tema de colores ───
-- Carga theme.lua (generado por apply-nvim.sh al cambiar tema i3)
-- Si no existe (primera vez), usa "default" como fallback
local ok = pcall(dofile, vim.fn.stdpath('config') .. '/theme.lua')
if not ok then
  vim.cmd('colorscheme default') -- Tema por defecto de nvim
end
