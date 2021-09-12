--lmake.lua
local lfs           = require("lfs")
local ltmpl         = require("ltemplate.ltemplate")

local ldir          = lfs.dir
local lmkdir        = lfs.mkdir
local lcurdir       = lfs.currentdir
local lattributes   = lfs.attributes
local ssub          = string.sub
local sfind         = string.find
local sformat       = string.format
local tinsert       = table.insert

local slash         = "/"
local vcxprojs      = {}
local makefiles     = {}
local work_dir      = lfs.currentdir()
local main_make     = work_dir .. slash .. "lmake"

local function lmak_file_title(file)
    local pos = sfind(file, "%.lmak")
    if pos then
        return ssub(file, 1, pos - 1)
    end
    return false
end

--生成项目文件
--proj_root：项目根目录
--lmake_dir：项目目录相对于lmake的路径
local function build_projfile(proj_root, lmake_dir)
    for file in ldir(proj_root) do
        if file == "." or file == ".." then
            goto continue
        end
        local file_name = proj_root .. slash .. file
        local attr = lattributes(file_name)
        if attr.mode == "directory" then
            build_projfile(file_name, lmake_dir)
            goto continue
        end
        local title = lmak_file_title(file_name)
        if title then
            local makfile = title .. ".mak"
            local vcxproj = title .. ".vcxproj"
            ltmpl.render_file(lmake_dir .. slash .. "tmpl/make.tpl", makfile, file_name)
            --ltmpl.render_file("./tmpl/vcxproj.tpl", vcxproj, file_name)
            tinsert(vcxprojs, {proj_root, vcxproj})
            tinsert(makefiles, {proj_root, makfile})
            print(sformat("render template file %s success!", proj_root))
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
    if not env.SOLUTION or not env.LMAKE_DIR then
        error(sformat("lmake solution or dir not config"))
        return
    end 
    for file in ldir(work_dir) do
        if file == "." or file == ".." then
            goto continue
        end
        local sub_name = work_dir .. slash .. file
        local attr = lattributes(sub_name)
        if attr.mode == "directory" then
            build_projfile(sub_name, env.LMAKE_DIR)
        end
        :: continue ::
    end
    local solution = env.SOLUTION .. ".sln"
    local makfile = env.SOLUTION .. ".Makefile"
    ltmpl.render_file(lmake_dir .. slash .. "tmpl/Makefile.tpl", work_dir, main_make)
    ltmpl.render_file(lmake_dir .. slash .. "tmpl/Solution.tpl", solution, main_make)
    print(sformat("build solution %s success!", env.SOLUTION))
end

--工具用法
build_lmak()
--bin/lua.exe -e "package.cpath=package.cpath..[[;./bin/?.so]]; package.path=package.path..[[;../lmake/?.lua]]" ../lmake/lmake.lua . ../lmake
