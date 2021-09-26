-- Copyright 2017-2021 Jeff Foley. All rights reserved.
-- Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.

local json = require("json")

name = "HackerTarget"
type = "api"

function start()
    set_rate_limit(1)
end

function vertical(ctx, domain)
    scrape(ctx, {['url']=build_url(domain)})
end

function build_url(domain)
    return "http://api.hackertarget.com/hostsearch/?q=" .. domain
end

function asn(ctx, addr, asn)
    if addr == "" then
        return
    end

    local resp, err = request(ctx, {['url']=asn_url(addr)})
    if (err ~= nil and err ~= "") then
        log(ctx, "asn request to service failed: " .. err)
        return
    end

    local j = json.decode("{\"results\": [" .. resp .. "]}")
    if (j == nil or #(j.results) < 4) then
        return
    end

    new_asn(ctx, {
        ['addr']=addr,
        ['asn']=tonumber(j.results[2]),
        prefix=j.results[3],
        desc=j.results[4],
    })
end

function asn_url(addr)
    return "https://api.hackertarget.com/aslookup/?q=" .. addr
end
