<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  {{% local GROUPS = {} %}}
  {{% local STDAFX = nil %}}
  {{% local ARGS = {SUB_DIR = SUB_DIR, OBJS = OBJS, EXCLUDE_FILE = EXCLUDE_FILE } %}}
  {{% local CINCLUDES, CSOURCES = COLLECT(WORK_DIR, SRC_DIR, ARGS) %}}
  <ItemGroup>
  {{% for _, CINC in pairs(CINCLUDES or {}) do %}}
    {{% if string.match(CINC[1], "stdafx.h") then %}}
      {{% STDAFX = CINC[1] %}}
    {{% else %}}
    <ClInclude Include="{{%= CINC[1] %}}">
      {{% GROUPS[CINC[2]] = true %}}
      <Filter>{{%= CINC[2] %}}</Filter>
    </ClInclude>
    {{% end %}}
  {{% end %}}
  </ItemGroup>
  <ItemGroup>
  {{% for _, CSRC in pairs(CSOURCES or {}) do %}}
    <ClCompile Include="{{%= CSRC[1] %}}">
      {{% GROUPS[CSRC[2]] = true %}}
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
  {{% for GROUP in pairs(GROUPS or {}) do %}}
    <Filter Include="{{%= GROUP %}}">
      <UniqueIdentifier >{{{%= GUID_NEW(GROUP) %}}}</UniqueIdentifier>
    </Filter>
  {{% end %}}
  </ItemGroup>
</Project>