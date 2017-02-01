#!/usr/bin/lua

local stache = require "lustache"
local argparse = require "argparse"

local insert = require "std.table".insert
local remove = require "std.table".remove
local slurp = require "std.io".slurp
local splitdir = require "std.io".splitdir

local function runstache(args)
	local context = args.context
	local preprocess = args.preprocess

	if preprocess then
		context = assert(preprocess(context))
	end

	local template = assert(slurp(args.template))
	local partials = setmetatable({}, {__index = function(table, key) return slurp(key) end})
	local text = assert(stache:render(template, context, partials))

	local output_file = args.output
	assert(output_file:write(text))
	output_file:close()
end

local function open_string(mode)
	return function (filename)
		if filename == "STDIN" then
			return io.stdin
		elseif filename == "STDOUT" then
			return io.stdout
		end

		return io.open(filename, mode)
	end
end

local function safe_dofile(filename)
	local results = {pcall(dofile, filename)}
	local success = remove(results, 1)
	if not success then
		return nil, results[1]
	end
	return results
end

function basename(filename)
	local parts = splitdir(filename)
	return parts[#parts]
end

local script_filename = basename(arg[0])
local config_filename = script_filename:gsub(".lua$", ".cfg")
if not config_filename:match(".cfg$") then
	config_filename = config_filename .. ".cfg"
end

local parser = argparse()
	:description("Parse file as a template, reading template parameters from another file")
parser:argument "config"
	:description("Configuration file")
	:args(1)
	:default(config_filename)
	:convert(safe_dofile)
parser:argument "template"
	:description("Template file")
	:args(1)
	:default("STDIN")
	:convert(open_string("r"))
parser:argument "output"
	:description("Output file")
	:args(1)
	:default("STDOUT")
	:convert(open_string("w"))
parser:option "-e" "--env"
	:description("Additional context")
	:argname("<key[=value]>")
	:args("*")

local args = parser:parse()

local context = args.config[1]
if args.env then
	for _,e in ipairs(args.env) do
		local k, v = e:match("^([^=]*)=([^=]*)$")
		if k and v then
			context[k] = v
		else
			insert(context, e)
		end
	end
end
args.context = context
args.preprocess = args.config[2]

runstache(args)
