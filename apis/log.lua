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
    success=4,
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

local function writeWrapped(termObj,str,bg,title)
    local width,height = termObj.getSize()
    local strings,maxLen = {},math.ceil(#str/width)
    local last = 0
    for i=1,maxLen do
        local _,y = termObj.getCursorPos()
        if y > height then
            termObj.scroll(1)
            termObj.setCursorPos(1,y-1)
            y = y - 1
        end
        termObj.write(str:sub(last+1,i*width))
        termObj.setCursorPos(1,y+1)
        last=i*width
    end
    return maxLen
end

local function getLineLen(termObj,str)
    local width = termObj.getSize()
    local strings,maxLen = {},math.ceil(#str/width)
    local last = 0
    local strLen
    for i=1,maxLen do
        local strs = str:sub(last+1,i*width)
        last=i*width
        strLen = #strs
    end
    return strLen
end

function index:dump(path)
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
    if type(path) == "string" then
        local file = fs.open(path..".log","w")
        file.write(str)
        file.close()
    end
    return str
end

local function write_to_log_internal(self,str,type)
    local width,height = self.term.getSize()
    local x,y = self.term.getCursorPos()
    local str = tostring(str)
    type = type or "info"
    if self.lastLog == str..type then
        self.nstr = self.nstr + 1
        local yid = y-self.maxln
        self.term.setCursorPos(x,yid)
    else
        self.nstr = 1
    end
    self.lastLog = str..type
    local timeStr = "["..textutils.formatTime(os.time()).."] "
    local tb,tt = self.term.getBackgroundColor(),self.term.getTextColor()
    local lFg,lBg = unpack(typeList[type] or {})
    self.term.setBackgroundColor(lBg or tb);self.term.setTextColor(lFg or colors.gray)
    local strse = timeStr..str.."("..tostring(self.nstr)..")"
    local len = #strse
    if len < 1 then len = 1 end
    local wlen = width-len
    if wlen < 1 then wlen = 1 end
    wlen = width-(getLineLen(self.term,strse))
    local strWrt = timeStr..str..(" "):rep(wlen)
    table.insert(self.history,{
        str=strWrt,
        type=type
    })
    self.maxln = writeWrapped(self.term,strWrt.."("..tostring(self.nstr)..")",tb,self.title)
    local x,y = self.term.getCursorPos()
    self.term.setBackgroundColor(self.sbg);self.term.setTextColor(self.sfg) 
    if self.title then
        self.term.setCursorPos(1,1)
        self.term.write((self.tsym):rep(width))
        self.term.setCursorPos(math.ceil((width / 2) - (#self.title / 2)), 1)
        self.term.write(self.title)
        self.term.setCursorPos(x,y)
    end
    self.term.setBackgroundColor(tb);self.term.setTextColor(tt) 
end

local function createLogInternal(termObj,title,titlesym,auto_dump,file)
    titlesym = titlesym or "-"
    local width,height = termObj.getSize()
    local log = setmetatable({
        lastLog="",
        nstr=1,
        maxln=1,
        term=termObj,
        history={},
        title = title,
        tsym=(#titlesym < 4) and titlesym or "-",
        sbg=termObj.getBackgroundColor(),
        sfg=termObj.getTextColor(),
        auto_dump=auto_dump
    },{
        __index=index,
        __call=write_to_log_internal
    })
    if log.title then
        log.term.setCursorPos(1,1)
        log.term.write((log.tsym):rep(width))
        log.term.setCursorPos(math.ceil((width / 2) - (#log.title / 2)), 1)
        log.term.write(log.title)
        log.term.setCursorPos(1,2)
    end
    log.lastLog = nil
    return log
end

return {create_log=createLogInternal}
