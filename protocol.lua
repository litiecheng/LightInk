
local typedef = {
	bool = "LightInkTypeDef__.T_Bool",
	int = "LightInkTypeDef__.T_Integer",
	float = "LightInkTypeDef__.T_Float",
	double = "LightInkTypeDef__.T_Double",
	string = "LightInkTypeDef__.T_String",
	array = {"LightInkTypeDef__.T_ArrayStart", "LightInkTypeDef__.T_ArrayEnd"},
	map = {"LightInkTypeDef__.T_MapStart", "LightInkTypeDef__.T_MapEnd"},
}
local serverType = {
	Control = 1,
	Loader = 2,
	Client = 3,
	Gateway = 4,
}
local tabStr = "\t\t\t\t\t\t\t\t\t"




function convert_protocol(srcPath, destPath)
	local fp = io.open(srcPath, "r")
	local data = fp:read("*a")
	io.close(fp);
	fp = nil
	data = trim_str(data)

	local protocolList = {}
	local structList = {}
	for s in string.gfind(data, "(.-%}$-)") do
		local result = create_def(s)
		if result.protocol then
			protocolList[result.name] = result
		elseif result.struct then
			structList[result.name] = result

		end
	end

	local opcodeList = {}
	local protocolStr = {}
	local get_opcode = function()
		local opcode = math.random(1025, 1000000)
		while opcodeList[opcode] do
			opcode = math.random(1025, 1000000)
		end
		opcodeList[opcode] = true
		return opcode
	end
	for k, v in pairs(protocolList) do
		for kp, vp in ipairs(v.data) do
			if not serverType[vp.route] then
				error("not this serverType " .. vp.route)
			end
			table.insert(protocolStr,
				string.format("-- %s\nLightInkDef__:register_def_message(%d, %d, \"%s\",\n",
				v.comment, serverType[vp.route], get_opcode(), v.name))

			for kt, vt in ipairs(vp) do
				get_user_type(protocolStr, structList, vt)
			end
			table.insert(protocolStr, tabStr)
			table.insert(protocolStr, "nil)\n\n")
		end

	end

	fp = io.open(destPath, "wb")
	fp:write(table.concat(protocolStr))
	fp:close()
	fp = nil

end

function get_user_type(protocolStr, structList, typeinfo)

	if typedef[typeinfo.type] then -- raw type
		table.insert(protocolStr, tabStr)
		table.insert(protocolStr,
			string.format("%s, -- %s %s //%s\n",
			typedef[typeinfo.type], typeinfo.type, typeinfo.var, typeinfo.comment))
	elseif structList[typeinfo.type] then -- struct
		table.insert(protocolStr, tabStr)
		table.insert(protocolStr, string.format("-- %s %s //%s//%s\n",
			typeinfo.type, typeinfo.var, typeinfo.comment, structList[typeinfo.type].comment))
		for k, v in ipairs(structList[typeinfo.type].data) do
			get_user_type(protocolStr, structList, v)
		end
		table.insert(protocolStr, tabStr)
		table.insert(protocolStr, string.format("-- %s %s //%s//%s\n",
			typeinfo.type, typeinfo.var, typeinfo.comment, structList[typeinfo.type].comment))
	else --map or array
		if not string.find(typeinfo.type, "<") then
			error("this type " .. typeinfo.type .. " is not a type!!!")
		end
		string.gsub(typeinfo.type, "(.-)<(.*)>", function(w1, w2)
			if not typedef[w1] then
				error("this type " .. w1 .. " is not a type!!!")
			end
			table.insert(protocolStr, tabStr)
			table.insert(protocolStr,
				string.format("%s, -- %s %s //%s\n",
				typedef[w1][1], typeinfo.type, typeinfo.var, typeinfo.comment))

			local typelist = {}
			string.gsub(w2, "([^,]+)", function(wt) table.insert(typelist, wt) end)
			local typeflag = 0
			local idx = nil
			for k, v in ipairs(typelist) do
				if string.find(v, "<") then
					if typeflag == 0 then
						idx = k
					end
					typeflag = typeflag + 1
				elseif string.find(v, ">") then
					typeflag = typeflag - 1
					if typeflag == 0 then
						local typetemp = {}
						for ki = idx, k do
							table.insert(typetemp, typelist[ki])
							table.insert(typetemp, ",")
						end
						typetemp[#typetemp] = nil
						get_user_type(protocolStr, structList, {type = table.concat(typetemp), var = "", comment = ""})
						idx = nil
					end
				elseif typeflag == 0 then
					get_user_type(protocolStr, structList, {type = v, var = "", comment = ""})
				end
			end

			table.insert(protocolStr, tabStr)
			table.insert(protocolStr,
				string.format("%s, -- %s %s //%s\n",
				typedef[w1][2], typeinfo.type, typeinfo.var, typeinfo.comment))
		end)
	end
end


function trim_str(str)
	return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

function replace_trim(str)
	return string.gsub(str, "%s", "")
end

function create_def(str)
	str = trim_str(str)
	local result = {data = {}}
	result.name = string.gsub(str, "%{(.-)%}", "")
	if string.find(result.name, "//") then
		result.comment = trim_str(string.gsub(result.name, "(.-/+)", ""))
	else
		result.comment = ""
	end
	result.name = replace_trim(string.gsub(result.name, "(/+.+)", ""))
	local data = string.gsub(str, "(.+)%{(.-)%}", "%2")

	for s in string.gfind(data, "(%w*)%s-:") do
		table.insert(result.data, {route = s})
	end
	if #result.data > 0 then --协议
		result.protocol = true
		local temp = nil
		for k, v in ipairs(result.data) do
			local modeStr = string.format("(.*)%s:(.+)", v.route)
			if k+1 <= #result.data then
				modeStr = modeStr .. result.data[k+1].route .. ":(.*)"
			end
			local routeStr = string.gsub(data, modeStr, "%2")
			string.gsub(routeStr, "(.-\n$-)", function(w)
				w = trim_str(w)
				if #w > 0 then
					local typevar = trim_str(string.gsub(w, "(/+.+)", ""))
					if string.find(typevar, "<") then
						string.gsub(typevar, "(.*>$*)(.*)", function(tw1, tw2)
							if temp then
								table.insert(v, temp)
							end
							temp = {type = replace_trim(tw1), var = trim_str(tw2), comment = ""}
						end)
					else
						string.gsub(typevar, "([%w<>,]+)", function(tw)
							if not temp then
								temp = {type = nil, var = nil, comment = ""}
							end
							if temp.type == nil then
								temp.type = tw
							elseif temp.var == nil then
								temp.var = tw
							else
								table.insert(v, temp)
								temp = {type = tw, var = nil, comment = ""}
							end
						end)
					end
					if string.find(w, "//") then
						if temp then
							temp.comment = temp.comment .. string.gsub(w, "(.-/+)", "")
						else
							temp = {type = nil, var = nil, comment = string.gsub(w, "(.-/+)", "")}
						end

					end
				end
			end)
			if temp then
				table.insert(v, temp)
				temp = nil
			end
		end
	else --结构
		result.struct = true
		local temp = nil
		string.gsub(data, "(.-\n$-)", function(w)
			w = trim_str(w)
			if #w > 0 then

				local typevar = trim_str(string.gsub(w, "(/+.+)", ""))
				if string.find(typevar, "<") then
					string.gsub(typevar, "(.*>$*)(.*)", function(tw1, tw2)
						if temp then
							table.insert(v, temp)
						end
						temp = {type = replace_trim(tw1), var = trim_str(tw2), comment = ""}
					end)
				else
					string.gsub(typevar, "([%w<>,]+)", function(tw)
						if not temp then
							temp = {type = nil, var = nil, comment = ""}
						end
						if temp.type == nil then
							temp.type = tw
						elseif temp.var == nil then
							temp.var = tw
						else
							table.insert(result.data, temp)
							temp = {type = tw, var = nil, comment = ""}
						end
					end)
				end

				if string.find(w, "//") then
					if temp then
						temp.comment = temp.comment .. string.gsub(w, "(.-/+)", "")
					else
						temp = {type = nil, var = nil, comment = string.gsub(w, "(.-/+)", "")}
					end

				end

			end
		end)
		if temp then
			table.insert(result.data, temp)
			temp = nil
		end
	end

	return result
end

math.randomseed(os.time())
math.random()
convert_protocol("E:/LightInk/def.li", "E:/LightInk/Def.lua")

