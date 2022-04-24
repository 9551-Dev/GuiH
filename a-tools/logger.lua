--! modified version of my log api for purpose of file logging

local typeList = {
    {colors.red},
    {colors.yellow},
    {colors.white,colors.red},
    {colors.white,colors.lime},
    {colors.white,colors.lime},
    {colors.white},
    {colors.green},
    {colors.gray},
}

local index = {
    error=1,
    warn=2,
    fatal=3,
    sucess=4,
    success=5,
    message=6,
    update=7,
    info=8
}

local revIndex = {}
for k,v in pairs(index) do
    revIndex[v] = k
end

local function remove_time(str)
    local str = str:gsub("^%[%d-%:%d-% %a-]","")
    return str
end

function index:dump()
    local lastLog = ""
    local nstr = 1
    local outputInternal = {}
    local str = ""
    for k,v in ipairs(self.history) do
        if lastLog == remove_time(v.str)..v.type then
            nstr = nstr + 1
            table.remove(outputInternal,#outputInternal)
        else
            nstr = 1
        end
        outputInternal[#outputInternal+1] = v.str.."("..tostring(nstr)..") type: "..(revIndex[v.type] or "info")
        lastLog = remove_time(v.str)..v.type
    end
    for k,v in ipairs(outputInternal) do
        str = str .. v .. "\n"
    end
    local file = fs.open("GuiH/log.log","w")
    file.write(str)
    file.close()
    return str
end

local function write_to_log_internal(self,str,type)
    local width,height = math.huge,math.huge
    local str = tostring(str)
    type = type or "info"
    if self.lastLog == str..type then
        self.nstr = self.nstr + 1
    else
        self.nstr = 1
    end
    self.lastLog = str..type
    local timeStr = "["..textutils.formatTime(os.time("local")).."] "
    local lFg,lBg = unpack(typeList[type] or {})
    local strWrt = timeStr..str..(" "):rep(math.max(100-(#timeStr+#str),3))
    table.insert(self.history,{
        str=strWrt,
        type=type
    })
end

local function createLogInternal(title,titlesym,auto_dump,file)
    titlesym = titlesym or "-"
    local log = setmetatable({
        lastLog="",
        nstr=1,
        maxln=1,
        history={},
        title = title,
        tsym=(#titlesym < 4) and titlesym or "-",
        auto_dump=auto_dump
    },{
        __index=index,
        __call=write_to_log_internal
    })
    log.lastLog = nil
    return log
end

return {create_log=createLogInternal}