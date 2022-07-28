--* sets the package path to GuiH's path
local selfDir = fs.getDir(select(2,...) or "")

local old_path = package.path

package.path = string.format(
    "%s;/%s/?.lua;/%s/?/init.lua",
    package.path, selfDir,selfDir
)

local GuiH = require "main"

--* restores package path
package.path = old_path
return setmetatable(GuiH,{__tostring=function() return "GuiH.API" end})
