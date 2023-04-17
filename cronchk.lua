#!/usr/bin/lua
-- opkg install luasocket
-- https://github.com/QuoInsight/admin-tools/blob/master/bzbox.lua

_,_,Ver1,Ver2 = string.find(_VERSION, "Lua (%d+)%.(%d+)")
_LuaVersionNumber = tonumber(Ver1.."."..Ver2);
_,_,_LuaScriptSource = debug.getinfo(1).source:find("^@?(.+)")
_SupportedFunctions = {"cronchk"}
_UnsupportedFunctions = {
  "[, [[, ar, arp, ash, awk, base64, basename, beep, ...",
  "\n    ..., whoami, whois, xargs, xz, xzcat, yes, zcat"
}

--[[
ln -s /root/bzbx.lua /usr/bin/cronchk
--]]

function _about()
  print(string.format([[

A simple Lua script emulating some BusyBox functions/commands

Usage: bzbx.lua [function [arguments]...]
   or: bzbx.lua --list[-full]
   or: bzbx.lua --install [-s] [DIR]
   or: function [arguments]...

BusyBox is a multi-call binary that combines many common Unix
utilities into a single executable.  Most people will create a
link to busybox for each function they wish to use and BusyBox
will act like whatever it was invoked as.

Currently defined functions:
  %s

  below functions are not (yet) implemented:
    %s
]],
    table.concat(_SupportedFunctions, ", "),
    table.concat(_UnsupportedFunctions, ", ")
  ))
  print(_VERSION.." ["..arg[-1].."] "..debug.getinfo(1).source)
  for i = 0, #arg do
    print(i .. ": " .. arg[i])
  end
  print()
end

function _exeCmd(cmdln)
  local file = assert(io.popen(cmdln, 'r'))
  local output = file:read('*all')
  file:close()
  output = string.gsub(output, "^%s*(.-)%s*$", "%1") --trim
  return output
end

function _realpath(filepath)
  if package.config:sub(1,1)=="/" then -- https://stackoverflow.com/a/14425862
    -- https://stackoverflow.com/a/31605674
    if filepath==nil or filepath=="" or filepath=="." then
      return _exeCmd("pwd")
    elseif filepath==".." then
      return _exeCmd('echo "$(cd ..; pwd)"')
    else
      cmdln = 'echo "$(cd "$(dirname "'..filepath..'")"; pwd)/$(basename "'..filepath..'")"'
      return _exeCmd(cmdln)
    end
  else
    return filepath
  end
end

function install(arg)
  print(">> creating symlinks ...")
  src = _realpath(_LuaScriptSource)
  for i = 1, #_SupportedFunctions do
    fnc = _SupportedFunctions[i]
    if fnc ~= "install" then
      cmd = 'ln -s '..src..' /usr/bin/'..fnc
      print(i..": "..cmd)
      --os.execute(cmd)
    end
  end
  print(">> Done\n")
end

function cronchk(arg)
  function _roundMinutes(t, m)
    intInterval = 60 * m
    return math.floor(t/intInterval + 0.5) * intInterval;
  end

  function _matchCronParam(cfgParam, actVal)
    if cfgParam==nil or cfgParam==''
     or cfgParam=='*' or cfgParam=='a' or cfgParam=='x'
    then return true end
    for s in string.gmatch(cfgParam, '([^,]+)') do
      p = string.find(s, "-")
      if p==nil then
        s = tonumber(s) -- tostring()
        if (s~=nul and actVal==s) then return true end
      else
        s1 = tonumber(string.sub(s,1,p-1))
        s2 = tonumber(string.sub(s,p+1,#s))
        if (s1~=nil and s2~=nil and actVal>=s1 and actVal<=s2)
         then return true end
      end
    end
    return false
  end

  local t = os.time() -- print( os.date("%c", t) )
  t = os.date("*t", _roundMinutes(t, 5))
  print( t.year.."-"..t.month.."-"..t.day.." ("..(t.wday-1)..") "..t.hour..":"..t.min..":"..t.sec )

  local f1 = nil; if arg[1]~=nil then f1 = io.open(arg[1],"r") end
  if f1~=nil then
    repeat
      line = f1:read()
      if line==nil then break end
      if line:match('[^ -~\n\t]') then break end -- non-printable ascii characters
      line = line:gsub("^%s*(.-)%s*$", "%1") -- trim
      if string.len(line) < 1 then line="#" end
      local l_arg = {};
      for s in string.gmatch(line, '([^ ]+)') do
        table.insert(l_arg, s)
      end
      if ( l_arg[1]~="#"
       and _matchCronParam(l_arg[1], t.min)
       and _matchCronParam(l_arg[2], t.hour)
       and _matchCronParam(l_arg[3], t.day)
       and _matchCronParam(l_arg[4], t.month)
       and _matchCronParam(l_arg[5], t.wday-1)
      ) then
        print("OK")
        os.exit(0)
      end
    until (line==nil)
    io.close(f1)
  else
    if ( _matchCronParam(arg[1], t.min)
     and _matchCronParam(arg[2], t.hour)
     and _matchCronParam(arg[3], t.day)
     and _matchCronParam(arg[4], t.month)
     and _matchCronParam(arg[5], t.wday-1)
    ) then
      print("OK")
      os.exit(0)
    end
  end
  os.exit(1)
end

-- main() --

_,_,arg[0] = string.find(arg[0], "([^\\/]+)$")
supportedFunctions = ","..table.concat(_SupportedFunctions, ",")..","
if supportedFunctions:find(","..arg[0]..",") == nil then
--if string.find(arg[0], "[\\/]?"..(_LuaScriptSource:gsub("%.","%%.")).."$") ~= nil then
  -- table.remove(arg, 1) -- this not working correctly for arg[0] !!
  for i = 0, (#arg-1) do arg[i]=arg[i+1] end; table.remove(arg, #arg)
  _,_,arg[0] = string.find(arg[0], "([^\\/]+)$")
end
if supportedFunctions:find(","..arg[0]..",") ~= nil then
  _G[arg[0]](arg);  os.exit()
end

_about()
