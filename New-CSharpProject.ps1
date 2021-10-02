param(
    [Parameter(Mandatory=$true)][string]$ProjectName
)

if (Test-Path -Path $ProjectName) {
    throw "'$ProjectName' already exists!"
}

$CurrentYear = "2021"
$GitUser = "my0n"
$ProjectPaths = @("src\$ProjectName\$ProjectName.csproj"; "tests\$ProjectName.Tests\$ProjectName.Tests.csproj")
$SolutionItemPaths = @(".gitignore"; "README.md"; "LICENSE"; ".github\dependabot.yml"; ".github\workflows\build.yml")

function GenerateNewGuid()
{
    (New-Guid).Guid.ToUpper()
}

function GenerateSlnFileContents()
{
    $ProjectDeclarationSection = @()
    $ProjectConfigurationPlatformsSection = @()
    $NestedProjectsSection = @()
    $SolutionItemsDeclarationSection = @()
    $SrcFolderGuid = GenerateNewGuid
    $TestsFolderGuid = GenerateNewGuid

    foreach ($ProjectPath in $ProjectPaths)
    {
        $ProjectGuid = GenerateNewGuid
        $ProjectName = $ProjectPath.Split("\")[-1].Replace(".csproj","")
        $NestedFolderPath = $ProjectPath.Split("\")[0]
        if ($NestedFolderPath -eq "src")
        {
            $NestedProjectsSection += "		{$ProjectGuid} = {$SrcFolderGuid}"
        }
        elseif ($NestedFolderPath -eq "tests")
        {
            $NestedProjectsSection += "		{$ProjectGuid} = {$TestsFolderGuid}"
        }
        $ProjectDeclarationSection += "Project(`"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}`") = `"$ProjectName`", `"$ProjectPath`", `"{$ProjectGuid}`""
        $ProjectDeclarationSection += "EndProject"
        $ProjectConfigurationPlatformsSection += "		{$ProjectGuid}.Debug|Any CPU.ActiveCfg = Debug|Any CPU"
        $ProjectConfigurationPlatformsSection += "		{$ProjectGuid}.Debug|Any CPU.Build.0 = Debug|Any CPU"
        $ProjectConfigurationPlatformsSection += "		{$ProjectGuid}.Debug|x64.ActiveCfg = Debug|Any CPU"
        $ProjectConfigurationPlatformsSection += "		{$ProjectGuid}.Debug|x64.Build.0 = Debug|Any CPU"
        $ProjectConfigurationPlatformsSection += "		{$ProjectGuid}.Debug|x86.ActiveCfg = Debug|Any CPU"
        $ProjectConfigurationPlatformsSection += "		{$ProjectGuid}.Debug|x86.Build.0 = Debug|Any CPU"
    }

    $SolutionItemsGuid = GenerateNewGuid
    $SolutionItemsDeclarationSection += "Project(`"{2150E333-8FDC-42A3-9474-1A3956D46DE8}`") = `"Solution Items`", `"Solution Items`", `"{$SolutionItemsGuid}`""
    $SolutionItemsDeclarationSection += "	ProjectSection(SolutionItems) = preProject"
    foreach ($SolutionItemPath in $SolutionItemPaths)
    {
        $SolutionItemsDeclarationSection += "		$SolutionItemPath = $SolutionItemPath"
    }
    $SolutionItemsDeclarationSection += "	EndProjectSection"
    $SolutionItemsDeclarationSection += "EndProject"

    "Microsoft Visual Studio Solution File, Format Version 12.00"
    "# Visual Studio Version 16"
    "VisualStudioVersion = 16.0.30114.105"
    "MinimumVisualStudioVersion = 10.0.40219.1"
    "Project(`"{2150E333-8FDC-42A3-9474-1A3956D46DE8}`") = `"src`", `"src`", `"{$SrcFolderGuid}`""
    "EndProject"
    "Project(`"{2150E333-8FDC-42A3-9474-1A3956D46DE8}`") = `"tests`", `"tests`", `"{$TestsFolderGuid}`""
    "EndProject"
    $ProjectDeclarationSection
    $SolutionItemsDeclarationSection
    "Global"
    "	GlobalSection(SolutionConfigurationPlatforms) = preSolution"
    "		Debug|Any CPU = Debug|Any CPU"
    "		Debug|x64 = Debug|x64"
    "		Debug|x86 = Debug|x86"
    "		Release|Any CPU = Release|Any CPU"
    "		Release|x64 = Release|x64"
    "		Release|x86 = Release|x86"
    "	EndGlobalSection"
    "	GlobalSection(ProjectConfigurationPlatforms) = postSolution"
    $ProjectConfigurationPlatformsSection
    "	EndGlobalSection"
    "	GlobalSection(SolutionProperties) = preSolution"
    "		HideSolutionNode = FALSE"
    "	EndGlobalSection"
    "	GlobalSection(ExtensibilityGlobals) = postSolution"
    "		SolutionGuid = {5AFE336F-4241-41B8-946B-A2D5489C4569}"
    "	EndGlobalSection"
	"	GlobalSection(NestedProjects) = preSolution"
	$NestedProjectsSection
	"	EndGlobalSection"
    "EndGlobal"
}

function GenerateReadmeContents()
{
    "# $ProjectName"
}

function GenerateLicenseContents()
{
    "MIT License"
    "Copyright (c) $CurrentYear $GitUser"
    ""
    "Permission is hereby granted, free of charge, to any person obtaining a copy"
    "of this software and associated documentation files (the `"Software`"), to deal"
    "in the Software without restriction, including without limitation the rights"
    "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell"
    "copies of the Software, and to permit persons to whom the Software is"
    "furnished to do so, subject to the following conditions:"
    ""
    "The above copyright notice and this permission notice shall be included in all"
    "copies or substantial portions of the Software."
    ""
    "THE SOFTWARE IS PROVIDED `"AS IS`", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR"
    "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"
    "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"
    "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"
    "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"
    "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE"
    "SOFTWARE."
}

function GenerateDependabotConfig()
{
    "version: 2"
    "updates:"
    "- package-ecosystem: nuget"
    "  directory: `"/`""
    "  schedule:"
    "    interval: daily"
    "  open-pull-requests-limit: 10"
    "  reviewers:"
    "  - `"$GitUser`""
}

function GenerateBuildWorkflow()
{
"name: .NET"
""
"on:"
"  push:"
"    branches: [ master ]"
"  pull_request:"
"    branches: [ master ]"
""
"jobs:"
"  build:"
"    runs-on: ubuntu-latest"
""
"    steps:"
"    - uses: actions/checkout@v2"
""
"    - name: Setup .NET"
"      uses: actions/setup-dotnet@v1"
"      with:"
"        dotnet-version: 5.0.x"
""
"    - name: Restore dependencies"
"      run: dotnet restore"
""
"    - name: Build"
"      run: dotnet build --configuration Release --no-restore"
""
"    - name: Test"
"      run: dotnet test --configuration Release --no-build"
""
"    - name: Version and Tag"
"      if: github.ref == 'refs/heads/master'"
"      id: bump_version"
"      uses: mathieudutour/github-tag-action@v5.6"
"      with:"
"        github_token: `${{ secrets.GITHUB_TOKEN }}"
""
"    - name: Create Release"
"      if: github.ref == 'refs/heads/master'"
"      uses: actions/create-release@v1"
"      env:"
"        GITHUB_TOKEN: `${{ secrets.GITHUB_TOKEN }}"
"      with:"
"        tag_name: `${{ steps.bump_version.outputs.new_tag }}"
"        release_name: Release `${{ steps.bump_version.outputs.new_tag }}"
"        body: `${{ steps.bump_version.outputs.changelog }}"
}

# create sln
md $ProjectName
pushd $ProjectName
GenerateSlnFileContents | Add-Content -Path "$ProjectName.sln"

# basic project setup
git init
dotnet new gitignore
GenerateReadmeContents | Add-Content -Path "README.md"
GenerateLicenseContents | Add-Content -Path "LICENSE"

# create src
md src
pushd src
dotnet new classlib --name $ProjectName
popd

# create tests
md tests
pushd tests
dotnet new xunit --name "$ProjectName.Tests"
pushd "$ProjectName.Tests"
dotnet add reference "../../src/$ProjectName"
dotnet add package "FluentAssertions"
dotnet add package "NSubstitute"
popd
popd

# create ci
md ".github"
pushd ".github"
GenerateDependabotConfig | Add-Content -Path "dependabot.yml"
md "workflows"
pushd "workflows"
GenerateBuildWorkflow | Add-Content -Path "build.yml"
popd
popd

# done
popd
