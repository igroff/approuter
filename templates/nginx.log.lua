function escape(string)
  return string:gsub("\"", "\\\"")
end
function log_request_to(file, url, headers, body, resp_status)
  local log = io.open(file, "a")
  log:write("Request:\n")
  log:write(string.format("  Url: \"%s\"\n", escape(url)))
  if headers then
    log:write("  Headers:\n")
    log:write("    Request:\n")
    log:write("      -\n")
    for key, value in pairs(headers) do
      log:write(string.format("        %s: \"%s\"\n", key, escape(value)))
    end
    log:write("    Response:\n")
    log:write("      -\n")
    -- because the ngx.header table isn\"t a normal lua table we can\"t 
    -- enumerate it... so fail
    log:write(string.format("        %s: \"%s\"\n", "Location", ngx.header.location))
    log:write(string.format("        %s: \"%s\"\n", "Content-Type", ngx.header.content_type))
  end
  if body then
    log:write(string.format("  Body:\n\"%s\"\n",escape(body)))
  end
  log:write(string.format("  Status: %s\n", resp_status))
  log:write("\n")
  log:close()
end

local args = ngx.var.args or ""
local url = string.format("%s://%s%s%s%s",
      ngx.var.scheme,
      ngx.var.http_host,
      ngx.var.uri,
      ngx.var.is_args,
      args)
log_request_to( ngx.var.my_log, url, ngx.req.get_headers(), ngx.var.my_request_body, ngx.status)
