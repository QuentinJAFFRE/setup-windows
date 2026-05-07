-- %APPDATA%\yazi\config\init.lua

require("mime-ext.local"):setup {
	fallback_file1 = false, -- skip `file(1)` fallback (broken on Windows scoop build)
}
