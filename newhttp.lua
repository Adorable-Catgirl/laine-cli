local http = {}
http.curl = false
http.tested = false
local httpc = {}
http.newConnection = function()
	local c = {}
	if (not http.tested) then
		http.curl = os.execute("curl --version > /dev/null")
		if (not http.curl) then
			print("\27[1;33mWarning:\27[0m curl not found or not working. Falling back to wget.")
		end
	end
	c.url = ""
	c.payload = {}
	c.type = "GET"
	c.headers = {
		["User-Agent"] = _VERSION
	}
	setmetatable(c, {__index=httpc})
	return c
end

function httpc:send()
  local com = "curl -s "
  local headers = io.open(".headers", "w")
  for k, v in pairs(self.headers) do
    if (k ~= "Content-Length") then
      headers:write(k..": "..v.."\r\n")
    else
      print("\27[1;33mWarning:\27[0m Content-Length is automatically set! This value should not be written manually!")
    end
  end
	headers:close()
	com = com .. "--header @.headers "
  --We don't actually set Content-Length. curl does that for us.
  if (self.headers["User-Agent"]) then
    com = com .. "-A '"..self.headers["User-Agent"] .. "' "
  end
  if (self.type == "POST") then
    for k, v in pairs(self.payload) do
      com = com .. "-F \""..k.."="..v.."\" "
    end
  end
  com = com .. "'" .. self.url.. "'"
  --print(com)
  local data = io.popen(com)
	local s = data:read("*a")
	data:close()
	return s
end

return http
