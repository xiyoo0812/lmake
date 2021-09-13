<?xml version="1.0" encoding="utf-8"?>
{{% local ALL_LIBS = {} %}}
{{% for _, def_lib in pairs(LIBS or {}) do %}}
{{%   table.insert(ALL_LIBS, def_lib .. ".lib") %}}
{{% end %}}
{{% for _, def_lib in pairs(WIN32_LIBS or {}) do %}}
{{%   table.insert(ALL_LIBS, def_lib .. ".lib") %}}
{{% end %}}
{{% local FMT_LIBS = table.concat(ALL_LIBS, ";") %}}
{{% local FMT_INCLUDES = table.concat(INCLUDES or {}, ";") %}}
{{% local FMT_DEFINES = table.concat(DEFINES or {}, ";") %}}
{{% local FMT_WIN_DEFINES = table.concat(WIN32_DEFINES or {}, ";") %}}
{{% local FMT_LIBRARY_DIR = table.concat(LIBRARY_DIR or {}, ";") %}}
<Project DefaultTargets="Build" ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="ReleaseDebug|Win32">
      <Configuration>ReleaseDebug</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="ReleaseDebug|x64">
      <Configuration>ReleaseDebug</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <ItemGroup>
    <ClInclude Include="mimalloc\include\mimalloc-atomic.h" />
    <ClInclude Include="mimalloc\include\mimalloc-internal.h" />
    <ClInclude Include="mimalloc\include\mimalloc-types.h" />
    <ClInclude Include="mimalloc\include\mimalloc.h" />
    <ClInclude Include="mimalloc\src\bitmap.h" />
  </ItemGroup>
  <ItemGroup>
    <ClCompile Include="mimalloc\src\alloc-aligned.c" />
    <ClCompile Include="mimalloc\src\alloc-posix.c" />
    <ClCompile Include="mimalloc\src\alloc.c" />
    <ClCompile Include="mimalloc\src\arena.c" />
    <ClCompile Include="mimalloc\src\bitmap.c" />
    <ClCompile Include="mimalloc\src\heap.c" />
    <ClCompile Include="mimalloc\src\init.c" />
    <ClCompile Include="mimalloc\src\options.c" />
    <ClCompile Include="mimalloc\src\os.c" />
    <ClCompile Include="mimalloc\src\page.c" />
    <ClCompile Include="mimalloc\src\random.c" />
    <ClCompile Include="mimalloc\src\region.c" />
    <ClCompile Include="mimalloc\src\segment.c" />
    <ClCompile Include="mimalloc\src\stats.c" />
  </ItemGroup>
  <PropertyGroup Label="Globals">
    <ProjectGuid>{ {{%= GUID_NEW(PROJECT_NAME) %}} }</ProjectGuid>
    <RootNamespace>{{%= PROJECT_NAME }}</RootNamespace>
    <Keyword>Win32Proj</Keyword>
    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
    <ProjectName>{{%= PROJECT_NAME }}</ProjectName>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='ReleaseDebug|Win32'" Label="Configuration">
    {{% if PROJECT_TYPE == "dynamic" then %}}
    <ConfigurationType>DynamicLibrary</ConfigurationType>
    {{% elseif PROJECT_TYPE == "static" then %}}
    <ConfigurationType>StaticLibrary</ConfigurationType>
    {{% else %}}
    <ConfigurationType>Application</ConfigurationType>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    {{% end %}}
    <PlatformToolset>v142</PlatformToolset>
    <CharacterSet>MultiByte</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='ReleaseDebug|x64'" Label="Configuration">
    {{% if PROJECT_TYPE == "dynamic" then %}}
    <ConfigurationType>DynamicLibrary</ConfigurationType>
    {{% elseif PROJECT_TYPE == "static" then %}}
    <ConfigurationType>StaticLibrary</ConfigurationType>
    {{% else %}}
    <ConfigurationType>Application</ConfigurationType>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    {{% end %}}
    <PlatformToolset>v142</PlatformToolset>
    <CharacterSet>MultiByte</CharacterSet>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />
  <ImportGroup Label="ExtensionSettings">
  </ImportGroup>
  <ImportGroup Condition="'$(Configuration)|$(Platform)'=='ReleaseDebug|Win32'" Label="PropertySheets">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <ImportGroup Condition="'$(Configuration)|$(Platform)'=='ReleaseDebug|x64'" Label="PropertySheets">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <PropertyGroup Label="UserMacros" />
  <PropertyGroup>
    <_ProjectFileVersion>11.0.50727.1</_ProjectFileVersion>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='ReleaseDebug|Win32'">
    <OutDir>$(SolutionDir)temp\bin\$(Platform)\</OutDir>
    <IntDir>$(SolutionDir)temp\$(ProjectName)\$(Platform)\</IntDir>
    <LinkIncremental>true</LinkIncremental>
    <TargetName>{{%= TARGET_NAME %}}</TargetName>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='ReleaseDebug|x64'">
    <LinkIncremental>true</LinkIncremental>
    <TargetName>{{%= TARGET_NAME %}}</TargetName>
    <OutDir>$(SolutionDir)temp\bin\$(Platform)\</OutDir>
    <IntDir>$(SolutionDir)temp\$(ProjectName)\$(Platform)\</IntDir>
  </PropertyGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='ReleaseDebug|Win32'">
    <ClCompile>
      <Optimization>Disabled</Optimization>
      <AdditionalIncludeDirectories>{{%= FMT_INCLUDES %}};%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
      <PreprocessorDefinitions>RELEASEDEBUG;WIN32;NDEBUG;_WINDOWS;{{%= FMT_DEFINES %}};{{%= FMT_WIN_DEFINES %}};%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <MinimalRebuild>true</MinimalRebuild>
      <BasicRuntimeChecks>Default</BasicRuntimeChecks>
      <RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
      <PrecompiledHeader>
      </PrecompiledHeader>
      <WarningLevel>Level3</WarningLevel>
      <DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
      <CompileAs>Default</CompileAs>
    </ClCompile>
    {{% if PROJECT_TYPE == "static" then %}}
    <Lib>
      <AdditionalLibraryDirectories>
      </AdditionalLibraryDirectories>
      <AdditionalDependencies>
      </AdditionalDependencies>
    </Lib>
    {{% else %}}
    <Link>
      <OutputFile>$(OutDir)$(TargetName)$(TargetExt)</OutputFile>
      <AdditionalLibraryDirectories>{{%= FMT_LIBRARY_DIR %}};$(SolutionDir)library;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <SubSystem>Console</SubSystem>      
      {{% if PROJECT_TYPE == "dynamic" then %}}
      <ImportLibrary>$(SolutionDir)library/$(Platform)/$(TargetName).lib</ImportLibrary>
      {{% end %}}
      <TargetMachine>MachineX86</TargetMachine>
      <ProgramDatabaseFile>$(SolutionDir)temp\$(ProjectName)\$(Platform)\$(TargetName).pdb</ProgramDatabaseFile>
      <AdditionalDependencies>{{%= FMT_LIBS %}};%(AdditionalDependencies)</AdditionalDependencies>
      <ForceFileOutput>
      </ForceFileOutput>
    </Link>
    {{% end %}}
    <PreBuildEvent>
      {{% for _, re_build_lib in pairs(WIN32_PREBUILDS or {}) do %}}
      <Command>copy /y {{%= re_build_lib %}} $(SolutionDir)bin</Command>
      {{% end %}}
    </PostBuildEvent>
    <PostBuildEvent>
      {{% if PROJECT_TYPE == "static" then %}}
      <Command>copy /y $(TargetPath) $(SolutionDir)library</Command>
      {{% else %}}
      <Command>copy /y $(TargetPath) $(SolutionDir)bin</Command>
      {{% end %}}
    </PostBuildEvent>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='ReleaseDebug|x64'">
    <ClCompile>
      <Optimization>Disabled</Optimization>
      <AdditionalIncludeDirectories>{{%= FMT_INCLUDES %}};%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
      <PreprocessorDefinitions>RELEASEDEBUG;WIN32;NDEBUG;_WINDOWS;{{%= FMT_DEFINES %}};{{%= FMT_WIN_DEFINES %}};%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <BasicRuntimeChecks>Default</BasicRuntimeChecks>
      <RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
      <PrecompiledHeader>
      </PrecompiledHeader>
      <WarningLevel>Level3</WarningLevel>
      <DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
      <CompileAs>Default</CompileAs>
    </ClCompile>
    {{% if PROJECT_TYPE == "static" then %}}
    <Lib>
      <AdditionalLibraryDirectories>
      </AdditionalLibraryDirectories>
      <AdditionalDependencies>
      </AdditionalDependencies>
    </Lib>
    {{% else %}}
    <Link>
      <OutputFile>$(OutDir)$(TargetName)$(TargetExt)</OutputFile>
      <AdditionalLibraryDirectories>{{%= FMT_LIBRARY_DIR %}};$(SolutionDir)library;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <SubSystem>Windows</SubSystem>
      <ImportLibrary>$(SolutionDir)library/$(Platform)/$(TargetName).lib</ImportLibrary>
      <ProgramDatabaseFile>$(SolutionDir)temp\$(ProjectName)\$(Platform)\$(TargetName).pdb</ProgramDatabaseFile>
      <AdditionalDependencies>{{%= FMT_LIBS %}};%(AdditionalDependencies)</AdditionalDependencies>
      <ForceFileOutput>
      </ForceFileOutput>
    </Link>
    {{% end %}}
    <PreBuildEvent>
      {{% for _, re_build_lib in pairs(WIN32_PREBUILDS or {}) do %}}
      <Command>copy /y {{%= re_build_lib %}} $(SolutionDir)bin</Command>
      {{% end %}}
    </PostBuildEvent>
    <PostBuildEvent>
      {{% if PROJECT_TYPE == "static" then %}}
      <Command>copy /y $(TargetPath) $(SolutionDir)library</Command>
      {{% else %}}
      <Command>copy /y $(TargetPath) $(SolutionDir)bin</Command>
      {{% end %}}
    </PostBuildEvent>
  </ItemDefinitionGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets">
  </ImportGroup>
</Project>