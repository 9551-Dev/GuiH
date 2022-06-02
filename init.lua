--* check for emulators
if config then
    if config.get("standardsMode") == false then
        print("WARNING: standardsMode is set to false, this is not supported by the GuiH API")
        print("Enter Y to enable standards mode, this will reboot the computer")
        local input = read()
        if input:lower():match("y") then
            config.set("standardsMode", true)
            os.reboot()
        else
            error("GuiH cannot run without standards mode",0)
        end
    end
end

--* sets the package path to GuiH's path
local selfDir = fs.getDir(select(2,...)) or ""

local old_path = package.path

package.path = string.format(
    "%s;/%s/?.lua;/%s/?/init.lua",
    package.path, selfDir,selfDir
)

local GuiH = require "main"

--* restores package path
package.path = old_path
return setmetatable(GuiH,{__tostring=function() return "GuiH.API" end})
