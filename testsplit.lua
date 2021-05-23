local standstr = "2000:"
local points = "12_13"

for i = 1,40 do
    standstr = standstr..points..";"
end
standstr = string.sub(standstr,0,string.len(standstr) - 1)




function Split(str,sep)
    local s = {}
    local sub = string.sub
    local add = string.add
    local find = string.find
    local stringlen = string.len
    local first = 1
    local i = find(str,sep,first,true)
    while i do
        if i == first then
            table.insert(s,"")
        else
            table.insert(s,sub(str,first,i-1))
        end
        first = i + 1
        i = find(str,sep,first,true)
    end
    table.insert(s,sub(str,first,stringlen(str)))
    return s


end
require "os"
local time = os.clock()
local str = Split(standstr,"_")
local gap = os.clock()-time
print(gap)