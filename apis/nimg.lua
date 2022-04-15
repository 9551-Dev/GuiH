--------------------NIMG LOADER API--------------------
---------------API FOR LOADING NIMG IMAGES-------------
--------------------by 9551 DEV------------------------
---Copyright (c) 2021-2022 9551------------9551#0001---
---using this code in your project is fine!------------
---as long as you dont claim you made it---------------
---im cool with it, feel free to include---------------
---in your projects!   discord: 9551#0001--------------
---you dont have to but giving credits is nice :)------
-------------------------------------------------------
-------------------------------------------------------
local expect = require("cc.expect").expect
local index = {}
local indexAnimate = {}
local indexBuffer = {}
local chars = "0123456789abcdef"
local saveCols, loadCols = {}, {}
for i = 0, 15 do
  saveCols[2^i] = chars:sub(i + 1, i + 1)
  loadCols[chars:sub(i + 1, i + 1)] = 2^i
end
local decode = function(tbl)
  local output = setmetatable({},{
      __index=function(t,k)
      local new = {}
      t[k]=new
      return new
    end
  })
  output["offset"] = tbl["offset"]
  for k,v in pairs(tbl) do
     for ko,vo in pairs(v) do
        if type(vo) == "table" then
            output[k][ko] = {}
            if vo then
                output[k][ko].t = loadCols[vo.t]
                output[k][ko].b = loadCols[vo.b]
                output[k][ko].s = vo.s 
            end
        end
     end
  end
  return setmetatable(output,getmetatable(tbl))
end
local encode = function(tbl)
  local output = setmetatable({},{
      __index=function(t,k)
      local new = {}
      t[k]=new
      return new
    end
  })
  output["offset"] = tbl["offset"]
  for k,v in pairs(tbl) do
    for ko,vo in pairs(v) do
        if type(vo) == "table" then
            output[k][ko] = {}
            if vo then
                output[k][ko].t = saveCols[vo.t]
                output[k][ko].b = saveCols[vo.b]
                output[k][ko].s = vo.s 
            end
        end
     end
  end
  return setmetatable(output,getmetatable(tbl))
end
local function strech(tbl, x, y)
    if type(x) == "number" and type(y) == "number" then
        local strechmap = {}
        local strechmapy = {}
        local final
        local mulx = 1
        local muly = 1
        strechmap["offset"] = tbl.offset
        strechmapy["offset"] = tbl.offset
        for k, v in pairs(tbl) do
            if type(k) == "number" then
                for k2, v2 in pairs(v) do
                    for i = 1, x do
                        if x > 1 then
                            mulx = x
                        end
                        if not strechmap[k * mulx + i] then
                            strechmap[k * mulx + i] = {}
                        end
                        if not strechmap[k * mulx + i][k2] then
                            strechmap[k * mulx + i][k2] = {}
                        end
                        strechmap[k * mulx + i][k2] = tbl[k][k2]
                    end
                end
            end
        end
        if y > 1 then
            for k, v in pairs(strechmap) do
                if type(k) == "number" then
                    for k2, v2 in pairs(v) do
                        for i = 1, y do
                            if y > 1 then
                                muly = y
                            end
                            if not strechmapy[k] then
                                strechmapy[k] = {}
                            end
                            if not strechmapy[k][k2 * muly + i] then
                                strechmapy[k][k2 * muly + i] = {}
                            end
                            strechmapy[k][k2 * muly + i] = strechmap[k][k2]
                        end
                    end
                end
            end
        end
        if not next(strechmap) then
            strechmap = tbl
        end
        if y > 1 then
            final = strechmapy
        else
            final = strechmap
        end
        return setmetatable(final, getmetatable(tbl))
    else
        return tbl
    end
end
function index:strech(x, y)
    local tbl = self
    if not self then
        error("try using : instead of .", 0)
    end
    if type(x) == "number" and type(y) == "number" then
        local strechmap = {}
        local strechmapy = {}
        local final
        local mulx = 1
        local muly = 1
        strechmap["offset"] = tbl.offset
        strechmapy["offset"] = tbl.offset
        for k, v in pairs(tbl) do
            if type(k) == "number" then
                for k2, v2 in pairs(v) do
                    for i = 1, x do
                        if x > 1 then
                            mulx = x
                        end
                        if not strechmap[k * mulx + i] then
                            strechmap[k * mulx + i] = {}
                        end
                        if not strechmap[k * mulx + i][k2] then
                            strechmap[k * mulx + i][k2] = {}
                        end
                        strechmap[k * mulx + i][k2] = tbl[k][k2]
                    end
                end
            end
        end
        if y > 1 then
            for k, v in pairs(strechmap) do
                if type(k) == "number" then
                    for k2, v2 in pairs(v) do
                        for i = 1, y do
                            if y > 1 then
                                muly = y
                            end
                            if not strechmapy[k] then
                                strechmapy[k] = {}
                            end
                            if not strechmapy[k][k2 * muly + i] then
                                strechmapy[k][k2 * muly + i] = {}
                            end
                            strechmapy[k][k2 * muly + i] = strechmap[k][k2]
                        end
                    end
                end
            end
        end
        if not next(strechmap) then
            strechmap = tbl
        end
        if y > 1 then
            final = strechmapy
        else
            final = strechmap
        end
        return setmetatable(final, getmetatable(tbl))
    else
        return tbl
    end
end
function index:draw(termobj, x, y, ix, iy)
    expect(1, termobj, "table", "nil")
    expect(2, x, "number", "nil")
    expect(3, y, "number", "nil")
    local self = strech(self, ix, iy)
    local terms = termobj or term
    local x = x or 0
    local y = y or 0
    local obc = terms.getBackgroundColor()
    local otc = terms.getTextColor()
    for k, v in pairs(self) do
        if type(k) == "number" then
            for k2, v2 in pairs(v) do
                terms.setCursorPos(k - (self.offset[1]) + x, k2 - (self.offset[2] / 2) + y)
                terms.setBackgroundColor(v2.b)
                terms.setTextColor(v2.t)
                terms.write(v2.s)
            end
        end
    end
    terms.setBackgroundColor(obc)
    terms.setTextColor(otc)
end
function indexAnimate:drawImage(termobj, frame, x, y, ix, iy)
    expect(1, termobj, "table", "nil")
    expect(2, frame, "number")
    expect(3, x, "number", "nil")
    expect(4, y, "number", "nil")
    if not self then
        return false
    end
    local frame = frame or 1
    local frameToLoad = self[1][math.min(frame, #self[1])]
    local frameToLoad = strech(frameToLoad, ix, iy)
    if frameToLoad then
        local terms = termobj or term
        if not x then
            x = 0
        end
        if not y then
            y = 0
        end
        local obc = terms.getBackgroundColor()
        local otc = terms.getTextColor()
        for k, v in pairs(frameToLoad) do
            if type(k) == "number" then
                for k2, v2 in pairs(v) do
                    terms.setCursorPos(k - (frameToLoad.offset[1]) + x, k2 - (frameToLoad.offset[2] / 2) + y)
                    terms.setBackgroundColor(v2.b)
                    terms.setTextColor(v2.t)
                    terms.write(v2.s)
                end
            end
        end
        terms.setBackgroundColor(obc)
        terms.setTextColor(otc)
    end
end
function indexAnimate:animate(termobj, x, y, speed, buffer, clears, ix, iy)
    expect(1, termobj, "table")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, speed, "number")
    expect(5, buffer, "boolean")
    expect(6, clears, "boolean")
    local terms = termobj or term.current()
    local tx, ty = terms.getSize()
    if buffer then
        terms = window.create(terms, 1, 1, tx, ty)
    end
    local x = x or 0
    local y = y or 0
    if not speed then
        speed = 1
    end
    if clears == nil then
        clears = false
    end
    if buffer == nil then
        buffer = false
    end
    local obc = terms.getBackgroundColor()
    local otc = terms.getTextColor()
    for k1, v1 in ipairs(self[1]) do
        local v1 = strech(v1, ix, iy)
        if buffer then
            terms.setVisible(false)
        end
        terms.setBackgroundColor(obc)
        terms.setTextColor(otc)
        if clears then
            terms.clear()
        end
        local count = 0
        local curcount = 0
        for k, v in pairs(v1) do
            count = count + 1
        end
        for k, v in pairs(v1) do
            if type(k) == "number" then
                for k2, v2 in pairs(v) do
                    terms.setCursorPos(k - (v1.offset[1]) + x, k2 - (v1.offset[2] / 2) + y)
                    terms.setBackgroundColor(v2.b)
                    terms.setTextColor(v2.t)
                    terms.write(v2.s)
                end
            end
        end
        if buffer then
            terms.setVisible(true)
        end
        curcount = curcount + 1
        if curcount < #self[1] then
            sleep(speed)
        end
    end
    terms.setBackgroundColor(obc)
    terms.setTextColor(otc)
end
function indexAnimate:slide(termobj, x, y, ix, iy)
    expect(1, termobj, "table")
    expect(2, x, "number")
    expect(3, y, "number")
    local animation = self[1]
    local loadFrame = self[2] + 1
    if not animation[loadFrame] then
        return setmetatable({animation, 0, false}, {__index = indexAnimate})
    end
    local terms = termobj or term
    local x = x or 0
    local y = y or 0
    local obc = terms.getBackgroundColor()
    local otc = terms.getTextColor()
    animation[loadFrame] = strech(animation[loadFrame], ix, iy)
    for k, v in pairs(animation[loadFrame]) do
        if type(k) == "number" then
            for k2, v2 in pairs(v) do
                terms.setCursorPos(
                    k - (animation[loadFrame].offset[1]) + x,
                    k2 - (animation[loadFrame].offset[2] / 2) + y
                )
                terms.setBackgroundColor(v2.b)
                terms.setTextColor(v2.t)
                terms.write(v2.s)
            end
        end
    end
    terms.setBackgroundColor(obc)
    terms.setTextColor(otc)
    return setmetatable({animation, loadFrame, true}, {__index = indexAnimate})
end
function indexAnimate:iterate()
    local currentImage = 0
    local allFramesRaw = self[1]
    return function()
        currentImage = currentImage + 1
        if allFramesRaw[currentImage] then
            return setmetatable(allFramesRaw[currentImage], {__index = index}), allFramesRaw, currentImage
        end
    end
end
local function loadImage(name)
    expect(1, name, "string")
    local name = name or ""
    if not fs.exists(name .. ".nimg") then
        error("not found. try using file name wihnout .nimg note that all files need to have .nimg extension to work", 2)
    end
    local file = fs.open(name .. ".nimg", "r")
    local image = textutils.unserialize(file.readAll())
	local decoded = decode(image)
    file.close()
    return setmetatable(decoded, {__index = index})
end
local function loadImageSet(name)
    local frames = {}
    expect(1, name, "string")
    local name = name or ""
    if not fs.isDir(name .. ".animg") then
        error("not found. try using file name wihnout .animg note that all image sets need to have .animg as extension to work!", 2)
    end
    for k, v in pairs(fs.list(name .. ".animg")) do
        local fn, ext = v:match("^(%d+).+(%..-)$")
        if ext == ".nimg" then
            local file = fs.open(name .. ".animg/" .. v, "r")
            frames[tonumber(fn)] = textutils.unserialise(file.readAll())
			frames[tonumber(fn)] = decode(frames[tonumber(fn)])
            file.close()
        end
    end
    return setmetatable({frames, 0}, {__index = indexAnimate})
end
function indexBuffer:startBuffer(noclear)
    expect(1, noclear, "boolean", "nil")
    self.setVisible(false)
    if not noclear then
        buffer.clear()
    end
end
function indexBuffer:endBuffer()
    self.setVisible(true)
end
local function createBuffer(termObj)
    expect(1, termObj, "table")
    local terms = termObj or term.current()
    local xs, ys = terms.getSize()
    return setmetatable(window.create(terms, 1, 1, xs, ys), {__index = indexBuffer})
end
local function getButtonH()
    return require("ButtonH")
end
local function downloadPastekage(pasteCode)
    --pasteges are packages for pastes:
    --they allow downloading a set of images by putting into an paste
    --pastekage format:
    --l1: **PASTEKAGE**
    --l2: [NAME]:PASTEBINCODE
    --l3: [NAME]:PASTEBINCODE
    --l4: etc...
    local pastecage, err = http.get("https://pastebin.com/raw/" .. pasteCode)
    if err then
        error(err, 0)
    end
    local rand = tostring(math.random(1, 1000000))
    local temp = fs.open("9551_NIMG_MAIN_API_TEMP_PASTKAGE_" .. rand, "w")
    temp.write(pastecage.readAll())
    temp.close()
    pastecage.close()
    local lc = 0
    for l in io.lines("9551_NIMG_MAIN_API_TEMP_PASTKAGE_" .. rand) do
        lc = lc + 1
        if lc == 1 then
            if l ~= "**PASTEKAGE**" then
                error("not an pastekage!", 0)
            end
        end
        if lc > 1 then
            local name, code = l:match("^%[(.+)%]:(.+)")
            local web, err = http.get("https://pastebin.com/raw/" .. code)
            if err then
                error(err, 0)
            end
            local file = fs.open(name, "w")
            file.write(web.readAll())
            file.close()
            web.close()
        end
    end
    fs.delete("9551_NIMG_MAIN_API_TEMP_PASTKAGE_" .. rand)
end
return {
    loadImage = loadImage,
    loadImageSet = loadImageSet,
    getButtonH = getButtonH,
    createBuffer = createBuffer,
    stretch2DMap = strech,
    downloadPastekage = downloadPastekage,
    encode = encode,
	decode = decode
}

