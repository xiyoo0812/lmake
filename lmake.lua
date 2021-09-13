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
local sgmatch       = string.gmatch
local tinsert       = table.insert
local tsort         = table.sort

local slash         = "/"
local projects      = {}
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

local function project_sort(a, b)
    if tcontain(a.DEPS, b.NAME) then
        return false
    end
    if tcontain(b.DEPS, a.NAME) then
        return true
    end
    return #(a.DEPS) < #(b.DEPS)
end

local function group_sort(a, b)
    return a.INDEX < b.INDEX
end

local function init_projects(env, projects)
    local groups = {}
    local fmt_groups = ""
    tsort(projects, project_sort)
    local lguid = require("lguid")
    for i = #projects, 1, -1 do
        local proj = projects[i]
        local gname = proj.GROUP or "proj"
        if not groups[gname] then
            fmt_groups = gname .. " " .. fmt_groups
            groups[gname] = { NAME = gname, GUID = lguid.guid(gname), PROJECTS = {} }
        end
        proj.GROUP = gname
        groups[gname].INDEX = i
        tinsert(groups[gname].PROJECTS, 1, proj)
    end
    tsort(groups, group_sort)
    env.GUID_NEW = lguid.guid
    env.FMT_GROUPS = fmt_groups
    env.GROUPS = groups
end

--获取路径
local function get_file_path(filename)
    return smatch(filename, "(.+)/[^/]*%.%w+$")
end

--获取文件名
local function get_file_name(filename)
    return smatch(filename, ".+/([^/]*%.%w+)$")
end

--获取文件名
local function get_file_title(filename)
    return smatch(filename, ".+/([^/]*)(%.%w+)$")
end

--去除扩展名
local function get_file_root(filename)
    local idx = smatch(filename, ".+()%.%w+$")
    if idx then
        return ssub(filename, 1, idx-1)
    end
    return filename
end

--获取扩展名
local function get_file_ext(filename)
    return smatch(filename, ".+%.(%w+)$")
end

local function is_lmak_file(filename)
    if get_file_ext(filename) == "lmak" then
        return true
    end
    return false
end

local function init_env(work_dir)
    local lguid = require("lguid")
    return {
        LFS_DIR     = ldir,
        WORK_DIR    = work_dir,
        LFS_ATTR    = lattributes,
        FILE_EXT    = get_file_ext,
        FILE_TIT    = get_file_title,
        GUID_NEW    = lguid.guid,
    }
end

local function load_env_file(file, env)
    local func, err = loadfile(file, "bt", env)
    if not func then
        error(sformat("load lmake file failed :%s", err))
        return false
    end
    local ok, res = pcall(func)
    if not ok then
        error(sformat("load lmake file failed :%s", res))
        return false
    end
    return true
end

--生成项目文件
--proj_dir：项目目录
--lmake_dir：项目目录相对于lmake的路径
local function build_projfile(proj_dir, lmake_dir)
    local lguid = require("lguid")
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
        if is_lmak_file(file_name) then
            local env = init_env(proj_dir .. slash)
            local mak_dir = sgsub(proj_dir, work_dir, "")
            local file_title = get_file_title(file_name)
            if not load_env_file(lmake_dir .. slash .. "share.lua", env) then
                error("load share lmake file failed")
                return
            end
            ltmpl.render_file(lmake_dir .. slash .. "tmpl/make.tpl", file_title .. ".mak", env, file_name)
            --ltmpl.render_file("./tmpl/vcxproj.tpl", file_title .. ".vcxproj", file_name)
            tinsert(projects, {
                DIR = mak_dir,
                FILE = file_title,
                DEPS = env.DEPS,
                NAME = env.PROJECT_NAME,
                GUID = lguid.guid(env.PROJECT_NAME)
            })
        end
        :: continue ::
    end
end


--生成项目文件
local function build_lmak()
    local env = {}
    if not load_env_file(main_make, env) then
        error("load main lmake file failed")
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
    init_projects(env, projects)
    local ltmpl = require("ltemplate.ltemplate")
    ltmpl.render_file(lmake_dir .. slash .. "tmpl/makefile.tpl", "Makefile", env)
    ltmpl.render_file(lmake_dir .. slash .. "tmpl/Solution.tpl", solution .. ".sln", env)
    print(sformat("build solution %s success!", solution))
end

--工具用法
build_lmak()

--usage
--bin/lua.exe ../lmake/lmake.lua
