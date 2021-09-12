--lmake.lua
local lfs           = require("lfs")

local ldir          = lfs.dir
local lcurdir       = lfs.currentdir
local lattributes   = lfs.attributes
local ssub          = string.sub
local sgsub         = string.gsub
local sfind         = string.find
local sformat       = string.format
local smatch        = string.match
local tinsert       = table.insert
local tsort         = table.sort

local slash         = "/"
local vcxprojs      = {}
local makefiles     = {}
local work_dir      = lfs.currentdir() .. slash
local main_make     = work_dir .. "lmake"

local function tcontain(tab, val)
    for i, v in pairs(tab) do
        if v == val then
            return true
        end
    end
    return false
end

local function proj_sort(a, b)
    if tcontain(a.deps, b.name) then
        return false
    end
    if tcontain(b.deps, a.name) then
        return true
    end
    return #(a.deps) < #(b.deps)
end

--获取路径
function stripfilename(filename)
    return smatch(filename, "(.+)/[^/]*%.%w+$")
end

--获取文件名
function strippath(filename)
    return smatch(filename, ".+/([^/]*%.%w+)$")
end

--获取文件名
function strippathentension(filename)
    return smatch(filename, ".+/([^/]*)(%.%w+)$")
end

--去除扩展名
function stripextension(filename)
    local idx = smatch(filename, ".+()%.%w+$")
    if idx then
        return ssub(filename, 1, idx-1)
    end
    return filename
end

--获取扩展名
function getextension(filename)
    return smatch(filename, ".+%.(%w+)$")
end

local function lmak_file_title(filename)
    if getextension(filename) == "lmak" then
        return stripextension(filename)
    end
end

--生成项目文件
--proj_dir：项目目录
--lmake_dir：项目目录相对于lmake的路径
local function build_projfile(proj_dir, lmake_dir)
    local ltmpl = require("ltemplate.ltemplate")
    for file in ldir(proj_dir) do
        if file == "." or file == ".." then
            goto continue
        end
        local file_name = proj_dir .. slash .. file
        local attr = lattributes(file_name)
        if attr.mode == "directory" then
            build_projfile(file_name, lmake_dir)
            goto continue
        end
        local title = lmak_file_title(file_name)
        if title then
            local mak_dir = sgsub(proj_dir, work_dir, "")
            local makfile = stripextension(file_name) .. ".mak"
            local vcxproj = stripextension(file_name) .. ".vcxproj"
            local env = ltmpl.render_file(lmake_dir .. slash .. "tmpl/make.tpl", makfile, file_name)
            --ltmpl.render_file("./tmpl/vcxproj.tpl", vcxproj, file_name)
            tinsert(vcxprojs, {dir = mak_dir, file = strippath(vcxproj), deps = env.DEPS, guid = env.GUID})
            tinsert(makefiles, {dir = mak_dir, file = strippath(makfile), name = env.PROJECT_NAME, deps = env.DEPS })
        end
        :: continue ::
    end
end


--生成项目文件
local function build_lmak()
    local env = { }
    local func, err = loadfile(main_make, "bt", env)
    if not func then
        error(sformat("load main lmake file failed :%s", err))
        return
    end
    local ok, res = pcall(func)
    if not ok then
        error(sformat("load main lmake file failed :%s", res))
        return
    end
    local solution, lmake_dir = env.SOLUTION, env.LMAKE_DIR
    if not solution or not lmake_dir then
        error(sformat("lmake solution or dir not config"))
        return
    end
    package.path = sformat("%s;%s/?.lua", package.path, env.LMAKE_DIR)
    for file in ldir(work_dir) do
        if file == "." or file == ".." then
            goto continue
        end
        local sub_name = work_dir .. file
        local attr = lattributes(sub_name)
        if attr.mode == "directory" then
            build_projfile(sub_name, lmake_dir)
        end
        :: continue ::
    end
    tsort(makefiles, proj_sort)
    env.PROJECTS = makefiles
    local ltmpl = require("ltemplate.ltemplate")
    ltmpl.render_file(lmake_dir .. slash .. "tmpl/makefile.tpl", "Makefile", env)
    --env.PROJECTS = vcxprojs
    --ltmpl.render_file(lmake_dir .. slash .. "tmpl/Solution.tpl", solution .. ".sln", env)
    print(sformat("build solution %s success!", solution))
end

--工具用法
build_lmak()

--usage
--bin/lua.exe ../lmake/lmake.lua
