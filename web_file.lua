local extmap={
  txt="text/plain",
  js="application/javascript",
  ico="image/x-icon",
  lc="text/html",
  css="text/css",
  html="text/html",
  jpeg = "image/jpeg",
  jpg = "image/jpeg"
}
local function executeCode (s,p)
 for v in s:gmatch(p) do
  local _,c=pcall(loadstring(v))
  s=s:gsub(p,tostring(c==nil and "" or c),1)
 end return s
end
local function header(c,t,g)
 local s="HTTP/1.0 "..c .."\r\nServer: web-server\r\nContent-Type: "..t.."\r\n"
 if g then s=s.."Cache-Control: private, max-age=2592000\r\nContent-Encoding: gzip\r\n" end
 s=s.."Connection: close\r\n\r\n"
 return s
end
return function(conn,filename,args,cookie)
 local line
 local gzip=filename:match(".gz")
 local ftype=filename:gsub(".gz",""):match("%.([%a%d]+)$")
 if s.auth=="ON"then
 if not cookie or cookie.id~=tostring((string.byte(s.auth_pass))*s.token) then
--  if ftype=="html"then filename="login.html"end
if ftype=="lc"
	then
		filename="web_login.lc"
	elseif ftype=="html"
		then
			filename="login.html"
end

 end
 end
 local fd=file.open(filename,"r")
 print ("[ WEB_FILE ] "..filename)
 if fd then
  conn:send(header("200 OK",extmap[ftype or "txt"],gzip))
 else
  conn:send(header("404 Not Found","text/html"))
  conn:send("<h1>Page not found</h1>") return
 end
 if ftype=="html"then
  arg=args
  local buf=""
  repeat
   line=fd:readline()
    if line then
     if line:find("<%?lua(.-)%?>")then
      buf=buf..executeCode(line,"<%?lua(.-)%?>")
     else
      buf=buf..line
     end
    end
    if buf:len()>1024  or not line then
     conn:send(buf)
     if line then coroutine.yield()end
     buf=""
   end
  until not line
  fd:close() fd=nil arg=nil
  elseif ftype=="lc"then
  local k, c = pcall(dofile(filename),args)
  conn:send(type(c)=="string"and c or"error")
  else
  local data=0
  local all=file.open(filename,"r")
   repeat
    all:seek("set",data)
    line=all:read(1024)
    if line then
     conn:send(line)
     data=data+1024
     coroutine.yield()
     collectgarbage()
    end
   until not string.len(line)
   all:close() 
   end  
  all,line,gzip,ftype,buf,data=nil
end

