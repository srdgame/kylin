#!/usr/bin/env luajit

package.path = "../web/?/init.lua;../web/?.lua;./?.lua;./?/init.lua"..package.path

local socketHandler = require('web').socketHandler
local createServer = require('uv').createServer
local luv = require('luv')
local logc = require('logging.console')()
local app = require('moonslice')()
local edoc = require('utils.error-document')
local loader = require('kylin.loader')
local config = require('kylin.config')()

logc:info(config.apps())

local host = os.getenv("KYLINK_IP") or "0.0.0.0"
local port = os.getenv("KYLINK_PORT") or 8081

loader.load(app)

app = require('kylin.post')(app)
app = require('kylin.query')(app)
app = require('kylin.session').web(app, config.settings().session)
app = require('kylin.cookies').web(app)

app = require('error-document')(app, {
	--[404] = edoc.text("Bam! 404"),
	[404] = edoc.file('404.html'),
})

app = require('kylin.url')(app)

app = require('autoheaders')(app)
app = require('log')(app)

createServer(host, port, socketHandler(app))

repeat
--	count = count + 1
--	logc:debug('tick...')
until luv.run('once') == 0

