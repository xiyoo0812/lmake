<?xml version="1.0" encoding="utf-8"?>
{{% local ALIBS = {} %}}
{{% local STDAFX = nil %}}
{{% for _, CLIB in pairs(LIBS or {}) do %}}
{{% table.insert(ALIBS, CLIB .. ".lib") %}}
{{% end %}}
{{% for _, WLIB in pairs(WINDOWS_LIBS or {}) do %}}
{{% table.insert(ALIBS, WLIB) %}}
{{% end %}}
{{% for _, DDEF in pairs(WINDOWS_DEFINES or {}) do %}}
{{% table.insert(DEFINES, DDEF) %}}
{{% end %}}
{{% for _, WINC in pairs(WINDOWS_INCLUDES or {}) do %}}
{{% table.insert(INCLUDES, WINC) %}}
{{% end %}}
{{% for _, WLDIR in pairs(WINDOWS_LIBRARY_DIR or {}) do %}}
{{% table.insert(LIBRARY_DIR, WLDIR) %}}
{{% end %}}
{{% if MIMALLOC and MIMALLOC_DIR then %}}
{{% table.insert(ALIBS, "mimalloc.lib") %}}
{{% table.insert(INCLUDES, MIMALLOC_DIR) %}}
{{% end %}}
{{% local FMT_LIBS = table.concat(ALIBS, ";") %}}
{{% local FMT_DEFINES = table.concat(DEFINES or {}, ";") %}}
{{% local FMT_INCLUDES = table.concat(INCLUDES or {}, ";") %}}
{{% local FMT_LIBRARY_DIR = table.concat(LIBRARY_DIR or {}, ";") %}}
{{% local ARGS = {SUB_DIR = SUB_DIR, OBJS = OBJS, EXCLUDE_FILE = EXCLUDE_FILE } %}}
{{% local CINCLUDES, CSOURCES = COLLECT(WORK_DIR, SRC_DIR, ARGS) %}}
<Project DefaultTargets="Build" ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Develop|x64">
      <Configuration>Develop</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <ItemGroup>
  {{% for _, CINC in pairs(CINCLUDES or {}) do %}}
    {{% if string.match(CINC[1], "stdafx.h") then %}}
      {{% STDAFX = CINC[1] %}}
    {{% else %}}
    <ClInclude Include="{{%= CINC[1] %}}" />
    {{% end %}}
  {{% end %}}
  </ItemGroup>
  <ItemGroup>
  {{% for _, CSRC in pairs(CSOURCES or {}) do %}}
  {{% if string.match(CSRC[1], "stdafx.cpp") then %}}
    <ClCompile Include="{{%= CSRC[1] %}}" >
      <PrecompiledHeader Condition="'$(Configuration)|$(Platform)'=='Develop|x64'">Create</PrecompiledHeader>
    </ClCompile>
  {{% else %}}
    {{% if CSRC[4] or (#OBJS == 0 and not CSRC[3]) then %}}
    <ClCompile Include="{{%= CSRC[1] %}}" />
    {{% else %}}
    <ClCompile Include="{{%= CSRC[1] %}}" >
      <ExcludedFromBuild Condition="'$(Configuration)|$(Platform)'=='Develop|x64'">true</ExcludedFromBuild>
    </ClCompile>
    {{% end %}}
  {{% end %}}
  {{% end %}}
  </ItemGroup>
  {{% if STDAFX then %}}
  <ItemGroup>
    <CustomBuild Include="{{%= STDAFX %}}" />
  </ItemGroup>
  {{% end %}}
  <PropertyGroup Label="Globals">
    <ProjectGuid>{{{%= GUID_NEW(PROJECT_NAME) %}}}</ProjectGuid>
    <RootNamespace>{{%= PROJECT_NAME %}}</RootNamespace>
    <Keyword>Win32Proj</Keyword>
    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
    <ProjectName>{{%= PROJECT_NAME %}}</ProjectName>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Develop|x64'" Label="Configuration">
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
  <ImportGroup Condition="'$(Configuration)|$(Platform)'=='Develop|x64'" Label="PropertySheets">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <PropertyGroup Label="UserMacros" />
  <PropertyGroup>
    <_ProjectFileVersion>11.0.50727.1</_ProjectFileVersion>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Develop|x64'">
    <TargetName>{{%= TARGET_NAME %}}</TargetName>
    <OutDir>$(SolutionDir)temp\bin\$(Platform)\</OutDir>
    <IntDir>$(SolutionDir)temp\$(ProjectName)\$(Platform)\</IntDir>
  </PropertyGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Develop|x64'">
    <ClCompile>
      <Optimization>Disabled</Optimization>
      <AdditionalIncludeDirectories>{{%= FMT_INCLUDES %}};%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
      <PreprocessorDefinitions>WIN32;NDEBUG;_WINDOWS;_CRT_SECURE_NO_WARNINGS;{{%= FMT_DEFINES %}};%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <BasicRuntimeChecks>Default</BasicRuntimeChecks>
      <RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
      {{% if STDAFX then %}}
      <PrecompiledHeader>Use</PrecompiledHeader>
      {{% else %}}
      <PrecompiledHeader></PrecompiledHeader>
      {{% end %}}
      <WarningLevel>Level3</WarningLevel>
      <DebugInformationFormat>ProgramDatabase</DebugInformationFormat>
      <CompileAs>Default</CompileAs>
      {{% if MIMALLOC and MIMALLOC_DIR then %}}
      <ForcedIncludeFiles>../../mimalloc-ex.h</ForcedIncludeFiles>
      {{% end %}}
      {{% if STDCPP == "c++17" then %}}
      <LanguageStandard>stdcpp17</LanguageStandard>
      {{% end %}}
      {{% if STDCPP == "c++20" then %}}
      <LanguageStandard>stdcpp20</LanguageStandard>
      {{% end %}}
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
      <AdditionalLibraryDirectories>$(SolutionDir)library/$(Platform);{{%= FMT_LIBRARY_DIR %}};%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <SubSystem>Console</SubSystem>
      <ImportLibrary>$(SolutionDir)library/$(Platform)/$(TargetName).lib</ImportLibrary>
      <ProgramDatabaseFile>$(SolutionDir)temp\$(ProjectName)\$(Platform)\$(TargetName).pdb</ProgramDatabaseFile>
      <AdditionalDependencies>{{%= FMT_LIBS %}};%(AdditionalDependencies)</AdditionalDependencies>
      <ForceFileOutput>
      </ForceFileOutput>
    </Link>
    {{% end %}}
    <PreBuildEvent>
      {{% for _, re_build_lib in pairs(WINDOWS_PREBUILDS or {}) do %}}
      <Command>copy /y {{%= re_build_lib %}} $(SolutionDir)bin</Command>
      {{% end %}}
    </PreBuildEvent>
    <PostBuildEvent>
      {{% if PROJECT_TYPE == "static" then %}}
      <Command>copy /y $(TargetPath) $(SolutionDir)library\$(Platform)</Command>
      {{% else %}}
      <Command>copy /y $(TargetPath) $(SolutionDir)bin</Command>
      {{% end %}}
    </PostBuildEvent>
  </ItemDefinitionGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets">
  </ImportGroup>
</Project>