local pretty = require("cc.pretty")

local function fuzzy_match(str, pattern)
    local part = 100/math.max(#str,#pattern)
    local str_len = string.len(str)
    local pattern_len = string.len(pattern)
    local dp = {}
    for i = 0, str_len do
        dp[i] = {}
        dp[i][0] = i
    end
    for j = 0, pattern_len do
        dp[0][j] = j
    end
    for i = 1, str_len do
        for j = 1, pattern_len do
            local cost = 0
            if string.sub(str, i, i) ~= string.sub(pattern, j, j) then
                cost = 1
            end
            dp[i][j] = math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost)
        end
    end
    return 100-dp[str_len][pattern_len]*part
end

local function sort_strings(str_array, pattern)
    local result,out = {},{}
    for k, str in pairs(str_array) do
        table.insert(result,{fuzzy_match(k, pattern),k,str})
    end
    table.sort(result, function(a, b) return a[1] > b[1] end)
    for k,v in ipairs(result) do
        out[k] = {match=v[1],str=v[2],data=v[3]}
    end
    return out
end

return {
    fuzzy_match=fuzzy_match,
    sort_strings=sort_strings,
}
