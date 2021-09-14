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

--table包含
local function tcontain(tab, val)
    for i, v in pairs(tab) do
        if v == val then
            return true
        end
    end
    return false
end

--项目排序
local function project_sort(a, b)
    if tcontain(a.DEPS, b.NAME) then
        return false
    end
    if tcontain(b.DEPS, a.NAME) then
        return true
    end
    return #(a.DEPS) < #(b.DEPS)
end

--分组排序
local function group_sort(a, b)
    return a.INDEX < b.INDEX
end

--初始化solution环境变量
local function init_solution_env(env, projects)
    local groups = {}
    local fmt_groups = ""
    tsort(projects, project_sort)
    local lguid = require("lguid")
    for i = #projects, 1, -1 do
        local proj = projects[i]
        local gname = proj.GROUP
        if not groups[gname] then
            fmt_groups = gname .. " " .. fmt_groups
            groups[gname] = { NAME = gname, PROJECTS = {} }
        end
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

--是否lmak文件
local function is_lmak_file(filename)
    if get_file_ext(filename) == "lmak" then
        return true
    end
    return false
end

--收集文件
local function collect_files(collect_dir, root_dir, source_dir, args, group, collects, is_hfile)
    for file in ldir(collect_dir) do
        if file == "." or file == ".." then
            goto continue
        end
        local filename = collect_dir .. file
        local attr = lattributes(filename)
        if attr.mode ~= "file" then
            goto continue
        end
        local ext_name = get_file_ext(filename)
        local fmt_name = sgsub(filename, root_dir, "")
        if is_hfile then
            if ext_name == "h" then
                tinsert(collects, {fmt_name, group, false, false})
            end
            goto continue
        end
        if ext_name == "c" or ext_name == "cc" or ext_name == "cpp" then
            local cmp_name = sgsub(filename, source_dir, "")
            local is_obj = tcontain(args.OBJS, cmp_name)
            local is_exclude = tcontain(args.EXCLUDE_FILE, cmp_name)
            tinsert(collects, {fmt_name, group, is_exclude, is_obj})
        end
        :: continue ::
    end
end

--vs工程收集源文件
local function collect_sources(proj_dir, source_dir, args)
    local includes, sources = {}, {}
    local root_dir = proj_dir .. slash
    local source_dir = root_dir .. source_dir .. slash
    collect_files(source_dir, root_dir, source_dir, args, "inc", includes, true)
    collect_files(source_dir, root_dir, source_dir, args, "src", sources, false)
    for _, sub_dir in ipairs(args.SUB_DIR) do
        collect_files(source_dir .. sub_dir .. slash, root_dir, source_dir, args, sub_dir, includes, true)
        collect_files(source_dir .. sub_dir .. slash, root_dir, source_dir, args, sub_dir, sources, false)
    end
    return includes, sources
end

--初始化项目环境变量
local function init_project_env(proj_dir)
    local lguid = require("lguid")
    return {
        WORK_DIR    = proj_dir,
        GUID_NEW    = lguid.guid,
        COLLECT     = collect_sources,
    }
end

--加载环境变量文件
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
            local env = init_project_env(proj_dir)
            local mak_dir = sgsub(proj_dir, work_dir, "")
            local file_root = get_file_root(file_name)
            if not load_env_file(lmake_dir .. slash .. "share.lua", env) then
                error("load share lmake file failed")
                return
            end
            ltmpl.render_file(lmake_dir .. slash .. "tmpl/make.tpl", file_root .. ".mak", env, file_name)
            ltmpl.render_file(lmake_dir .. slash .. "tmpl/vcxproj.tpl", file_root .. ".vcxproj", env, file_name)
            ltmpl.render_file(lmake_dir .. slash .. "tmpl/filters.tpl", file_root .. ".vcxproj.filters", env, file_name)
            tinsert(projects, {
                DIR = mak_dir,
                DEPS = env.DEPS,
                GROUP = env.GROUP,
                NAME = env.PROJECT_NAME,
                FILE = get_file_title(file_name),
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
    init_solution_env(env, projects)
    local ltmpl = require("ltemplate.ltemplate")
    ltmpl.render_file(lmake_dir .. slash .. "tmpl/makefile.tpl", "Makefile", env)
    ltmpl.render_file(lmake_dir .. slash .. "tmpl/Solution.tpl", solution .. ".sln", env)
    print(sformat("build solution %s success!", solution))
end

--工具用法
build_lmak()

--usage
--bin/lua.exe ../lmake/lmake.lua
