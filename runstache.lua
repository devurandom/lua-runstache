#!/usr/bin/lua

local stache = require "lustache"
local argparse = require "argparse"

local insert = require "std.table".insert
local remove = require "std.table".remove
local slurp = require "std.io".slurp

local function runstache(args)
	local context = args.context
	local preprocess = args.preprocess

	if preprocess then
		context = preprocess(context)
	end

	local template_file = args.template
	local template = template_file:read("*a")
	template_file:close()

	local partials = setmetatable({}, {__index = function(table, key) return slurp(key) end})
	local text = assert(stache:render(template, context, partials))

	local output_file = args.output
	assert(output_file:write(text))
	output_file:close()
end

local function open_string(filename)
	if filename == "STDIN" then
		return io.stdin
	elseif filename == "STDOUT" then
		return io.stdout
	end

	return io.open(filename)
end

local function safe_dofile(filename)
	local results = {pcall(dofile, filename)}
	local success = remove(results, 1)
	if not success then
		return nil, results[1]
	end
	return results
end

local script_filename = arg[0]

local parser = argparse()
	:description("Parse file as a template, reading template parameters from another file")
parser:argument "config"
	:description("Configuration file")
	:args(1)
	:default(script_filename:gsub(".lua$", ".cfg"))
	:convert(safe_dofile)
parser:argument "template"
	:description("Template file")
	:args(1)
	:default("STDIN")
	:convert(open_string)
parser:argument "output"
	:description("Output file")
	:args(1)
	:default("STDOUT")
	:convert(open_string)
parser:option "-e" "--env"
	:description("Additional context")
	:argname("<key[=value]>")
	:args("*")

local args = parser:parse()

local context = args.config[1]
for _,e in ipairs(args.env) do
	local k, v = e:match("^([^=]*)=([^=]*)$")
	if k and v then
		context[k] = v
	else
		insert(context, e)
	end
end
args.context = context
args.preprocess = args.config[2]

runstache(args)