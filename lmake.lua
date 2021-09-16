--lmake.lua
local lstdfs        = require('lstdfs')

local ldir          = lstdfs.dir
local lstem         = lstdfs.stem
local lappend       = lstdfs.append
local lconcat       = lstdfs.concat
local labsolute     = lstdfs.absolute
local lextension    = lstdfs.extension
local lcurdir       = lstdfs.current_path
local lrelativedir  = lstdfs.relative_path
local lrepextension = lstdfs.replace_extension
local sgsub         = string.gsub
local sformat       = string.format
local tinsert       = table.insert
local tsort         = table.sort

local projects      = {}

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

--
local function path_fmt(paths)
    for i, path in pairs(paths) do
        paths[i] = sgsub(path, "/", "\\")
    end
    return paths
end

--路径剪裁
local function path_cut(fullname, basename)
    local cutname = sgsub(fullname, basename, "")
    local relapath = lrelativedir(cutname)
    return relapath
end

--初始化solution环境变量
local function init_solution_env(env)
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

--收集文件
local function collect_files(collect_dir, project_dir, source_dir, args, group, collects, is_hfile)
    local dir_files = ldir(collect_dir)
    for _, file in pairs(dir_files) do
        local fullname = file.name
        if file.type ~= "regular" then
            goto continue
        end
        local ext_name = lextension(fullname)
        local fmt_name = path_cut(fullname, project_dir)
        if is_hfile then
            if ext_name == ".h" then
                tinsert(collects, {fmt_name, group, false, false})
            end
            goto continue
        end
        if ext_name == ".c" or ext_name == ".cc" or ext_name == ".cpp" then
            local cmp_name = path_cut(fullname, source_dir)
            local is_obj = tcontain(args.OBJS, cmp_name)
            local is_exclude = tcontain(path_fmt(args.EXCLUDE_FILE), cmp_name)
            tinsert(collects, {fmt_name, group, is_exclude, is_obj})
        end
        :: continue ::
    end
end

--vs工程收集源文件
local function collect_sources(project_dir, src_dir, args)
    local includes, sources = {}, {}
    local source_dir = lappend(project_dir, src_dir)
    collect_files(source_dir, project_dir, source_dir, args, "inc", includes, true)
    collect_files(source_dir, project_dir, source_dir, args, "src", sources, false)
    for _, sub_dir in ipairs(args.SUB_DIR) do
        collect_files(lappend(source_dir, sub_dir), project_dir, source_dir, args, sub_dir, includes, true)
        collect_files(lappend(source_dir, sub_dir), project_dir, source_dir, args, sub_dir, sources, false)
    end
    return includes, sources
end

--初始化项目环境变量
local function init_project_env(project_dir, bmimalloc)
    local lguid = require("lguid")
    return {
        WORK_DIR    = project_dir,
        GUID_NEW    = lguid.guid,
        MIMALLOC    = bmimalloc,
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
--project_dir：项目目录
--lmake_dir：项目目录相对于lmake的路径
local function build_projfile(solution_dir, project_dir, lmake_dir, bmimalloc)
    local lguid = require("lguid")
    local ltmpl = require("ltemplate.ltemplate")
    local dir_files = ldir(project_dir)
    for _, file in pairs(dir_files) do
        local fullname = file.name
        if file.type == "directory" then
            build_projfile(solution_dir, fullname, lmake_dir, bmimalloc)
            goto continue
        end
        if lextension(fullname) == ".lmak" then
            local env = init_project_env(project_dir, bmimalloc)
            if not load_env_file(lappend(lmake_dir, "share.lua"), env) then
                error("load share lmake file failed")
                return
            end
            local mak_dir = path_cut(project_dir, solution_dir)
            ltmpl.render_file(lappend(lmake_dir, "tmpl/make.tpl"),  lrepextension(fullname, ".mak"), env, fullname)
            ltmpl.render_file(lappend(lmake_dir, "tmpl/vcxproj.tpl"),  lrepextension(fullname, ".vcxproj"), env, fullname)
            ltmpl.render_file(lappend(lmake_dir, "tmpl/filters.tpl"),  lrepextension(fullname, ".vcxproj.filters"), env, fullname)
            tinsert(projects, {
                DIR = mak_dir,
                DEPS = env.DEPS,
                GROUP = env.GROUP,
                NAME = env.PROJECT_NAME,
                FILE = lstem(fullname),
                GUID = lguid.guid(env.PROJECT_NAME)
            })
        end
        :: continue ::
    end
end

--生成项目文件
local function build_lmak(solution_dir)
    local env = {}
    print(sformat("build_lmak: solution_dir %s", solution_dir))
    if not load_env_file(lappend(solution_dir, "lmake"), env) then
        error("load main lmake file failed")
        return
    end
    local solution = env.SOLUTION
    if not solution or not env.LMAKE_DIR then
        error(sformat("lmake solution or dir not config"))
        return
    end
    local lmake_dir = labsolute(lappend(solution_dir, env.LMAKE_DIR))
    print(sformat("build_lmak: lmake_dir %s", lmake_dir))
    package.path = sformat("%s;%s/?.lua", package.path, lmake_dir)
    local dir_files = ldir(solution_dir)
    for _, file in pairs(dir_files) do
        if file.type == "directory" then
            build_projfile(solution_dir, file.name, lmake_dir, env.USE_MIMALLOC)
        end
    end
    init_solution_env(env)
    local ltmpl = require("ltemplate.ltemplate")
    ltmpl.render_file(lappend(lmake_dir, "tmpl/makefile.tpl"), lappend(solution_dir, "Makefile"), env)
    ltmpl.render_file(lappend(lmake_dir, "tmpl/Solution.tpl"), lappend(solution_dir, lconcat(solution, ".sln")), env)
    print(sformat("build solution %s success!", solution))
end

local solution_dir = lcurdir()
if select("#", ...) == 1 then
    solution_dir = select(1, ...)
end
--生成工程
--solution_dir：工程路径
build_lmak(labsolute(solution_dir))

--工具用法
--usage
--lmake_file: lmake.lua文件路径
--solution_dir：工程路径，不传则当前路径
--bin/lua.exe ../lmake/lmake.lua ./
