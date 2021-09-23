<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  {{% local STDAFX = nil %}}
  {{% local TEMPS, GROUPS = {}, {} %}}
  {{% local ARGS = {SUB_DIR = SUB_DIR, OBJS = OBJS, EXCLUDE_FILE = EXCLUDE_FILE } %}}
  {{% local C_SRC_DIR = string.gsub(SRC_DIR, '/', '\\') %}}
  {{% local CINCLUDES, CSOURCES = COLLECT(WORK_DIR, C_SRC_DIR, ARGS) %}}
  <ItemGroup>
  {{% for _, CINC in pairs(CINCLUDES or {}) do %}}
    {{% if string.match(CINC[1], "stdafx.h") then %}}
      {{% STDAFX = CINC[1] %}}
    {{% else %}}
    <ClInclude Include="{{%= CINC[1] %}}">
      {{% TEMPS[CINC[2]] = true %}}
      <Filter>{{%= CINC[2] %}}</Filter>
    </ClInclude>
    {{% end %}}
  {{% end %}}
  </ItemGroup>
  <ItemGroup>
  {{% for _, CSRC in pairs(CSOURCES or {}) do %}}
    <ClCompile Include="{{%= CSRC[1] %}}">
      {{% TEMPS[CSRC[2]] = true %}}
      <Filter>{{%= CSRC[2] %}}</Filter>
    </ClCompile>
  {{% end %}}
  </ItemGroup>
  {{% if STDAFX then %}}
  <ItemGroup>
    <CustomBuild Include="{{%= STDAFX %}}" />
  </ItemGroup>
  {{% end %}}
  <ItemGroup>
  {{% for GROUP in pairs(TEMPS or {}) do %}}
    {{% table.insert(GROUPS, GROUP) %}}
  {{% end %}}
  {{% table.sort(GROUPS, function(a, b) return a < b end) %}}
  {{% for _, GROUP in pairs(GROUPS or {}) do %}}
    <Filter Include="{{%= GROUP %}}">
      <UniqueIdentifier >{{{%= GUID_NEW(GROUP) %}}}</UniqueIdentifier>
    </Filter>
  {{% end %}}
  </ItemGroup>
</Project>