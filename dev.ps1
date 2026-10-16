[CmdletBinding()]
param(
    [ValidateSet('Doctor', 'Configure', 'Build', 'Check', 'Test', 'Status')]
    [string]$Action = 'Check',
    [ValidateRange(1, 16)] [int]$Jobs = 1
)
$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$build = Join-Path $repo 'build/codex'

function Invoke-Checked {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program failed with exit code $LASTEXITCODE" }
}

function Find-CMake {
    $command = Get-Command cmake -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
    if (Test-Path -LiteralPath $vswhere) {
        $installation = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if ($installation) {
            $candidate = Join-Path $installation 'Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/cmake.exe'
            if (Test-Path -LiteralPath $candidate) { return $candidate }
        }
    }
    throw 'Install Visual Studio 2022 C++ Build Tools with the Windows SDK and CMake component.'
}

function Configure-Project {
    Invoke-Checked $cmake @(
        '-S', $repo, '-B', $build, '-G', 'Visual Studio 17 2022', '-A', 'x64', '-T', 'v143',
        '-DDINGOSDK_VERSION=2.0.7-dev', '-DDINGOSDK_LAUNCHER_AUTO_UPDATE=OFF',
        '-DDINGOSDK_BUILD_PARK_EDITOR_TESTS=ON',
        '-DDINGOSDK_BUILD_BOARD_BREAK_TESTS=ON', '-DDINGOSDK_BUILD_ROAD_RASH_TESTS=ON',
        '-DDINGOSDK_TEST_GAME_ROOT='
    )
}

function Test-Project {
    Invoke-Checked $ctest @('--test-dir', $build, '-C', 'Release', '--output-on-failure', '--no-tests=error')
}

Push-Location $repo
$previousVcpkg = $env:VCLibPackagePath
try {
    if ($Action -eq 'Status') {
        Invoke-Checked 'git' @('status', '--short', '--branch')
        Invoke-Checked 'git' @('remote', '-v')
        Invoke-Checked 'git' @('log', '-1', '--format=%h %cs %s')
        return
    }
    $cmake = Find-CMake
    $ctest = Join-Path (Split-Path $cmake) 'ctest.exe'
    $env:VCLibPackagePath = Join-Path $repo 'build/no-vcpkg/vcpkg.user'
    if ($Action -eq 'Doctor') {
        Invoke-Checked 'git' @('--version')
        Invoke-Checked $cmake @('--version')
        Invoke-Checked $ctest @('--version')
        Write-Host "Source: $repo"
        Write-Host 'Baseline: ReSkate v2.0.7; configuration: Release x64'
        Write-Host 'Check runs fixture-based tests without starting the game.'
        return
    }
    switch ($Action) {
        'Configure' { Configure-Project }
        'Build' {
            Configure-Project
            Invoke-Checked $cmake @('--build', $build, '--config', 'Release', '--parallel', "$Jobs")
        }
        'Check' {
            Configure-Project
            $targets = @(
                'dingosdk_park_randomization_tests', 'dingosdk_park_editor_tests',
                'dingosdk_park_editor_ui_tests', 'dingosdk_park_editor_transaction_tests',
                'dingosdk_profile_migration_tests', 'dingosdk_profile_change_tests',
                'dingosdk_music_favorites_tests', 'dingosdk_object_categories_tests',
                'dingosdk_board_break_tests', 'dingosdk_road_rash_tests'
            )
            Invoke-Checked $cmake (@('--build', $build, '--config', 'Release', '--parallel', "$Jobs", '--target') + $targets)
            Test-Project
        }
        'Test' { Test-Project }
    }
} finally {
    $env:VCLibPackagePath = $previousVcpkg
    Pop-Location
}
