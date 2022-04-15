local bits = {
    normal={
        1021,1007,1021,881,2,925,893,894,1021,325,2,1017,877,879,1021,
        size=3,
        conversion={}
    }
}

if not fs.exists("GuiH/apis/fonts.7sh") then fs.makeDir("GuiH/apis/fonts.7sh") end
for k,v in pairs(fs.list("GuiH/apis/fonts.7sh")) do
    local data = dofile("GuiH/apis/fonts.7sh/"..v)
    if next(data or {}) then
        for k,vdat in pairs(data) do
            bits[v.."."..k] = vdat
        end
    end
end

local index = {}

function index:update()
    local ob,ot = self.term.getBackgroundColor(),self.term.getTextColor()
    for k,v in ipairs(bits[self.font]) do
        local value = self.value
        local state = bit32.band(bit32.rshift(v,(bits[self.font].conversion or {})[value] or value),1)
        self.term.setCursorPos(((k-1)%bits[self.font].size)+1+self.pos.x,math.ceil(k/bits[self.font].size)+self.pos.y)
        if state == 1 then
            self.term.setBackgroundColor(self.bg)
            self.term.setTextColor(self.tg)
            self.term.write(self.symbol)
        else
            self.term.setBackgroundColor(ob)
            self.term.setTextColor(ot)
            self.term.write(" ")
        end
    end
    self.term.setTextColor(ot)
    self.term.setBackgroundColor(ob)
end

function index:reposition(x,y)
    self.pos = vector.new(x or 0,y or 0)
end

function index:set_background(col)
    self.bg = col or colors.white
end

function index:set_color(col)
    self.tg = col or colors.black
end

function index:set_symbol(sym)
    self.symbol = sym or " "
end

function index:set_value(val)
    self.value = val or 0
end

function index:set_font(font)
    if bits[font or "normal"] then
        self.font = font or "normal"
    end
end

function index:set_term(termt)
    if type(termt) == "table" then
        self.term = termt
    end
end

local function create_display(canv,x,y,value,font,bg,symbol,tg)
    if type(canv) ~= "table" then error("create_display needs an term object as its argument input to work!",2) end
    return setmetatable({
        pos=vector.new(x,y),
        value=value or 0,
        symbol=symbol or " ",
        bg=bg or colors.white,
        tg=tg or colors.black,
        font=font or "normal",
        term=canv
    },{
        __index=index
    })
end

return {
    create_display = create_display
} 
