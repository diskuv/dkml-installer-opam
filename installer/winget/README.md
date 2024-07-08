# winget

The files in the `manifest/` directory are published to Microsoft. See
[Authoring a Manifest](https://github.com/microsoft/winget-pkgs/blob/master/doc/README.md#authoring-a-manifest)
for more details.

## Upgrading

Follow the [Testing](#testing) section first.

Then search for `# BUMP` in the `.yaml` files and edit each line.

## Submitting

FIRST, in PowerShell upgrade and update the files in [manifest](manifest/) using the `wingetcreate` tool:

```powershell
winget install wingetcreate

# (version 2.2.0~beta2~20240409) in dune-project converts to:
#   2.2.0-beta2-20240409
#   2.2.0-beta2
$SemVer = $(Select-String -Path dune-project -Pattern "(version " -SimpleMatch | Select-Object -First 1).Line -replace "\(","" -replace "\)","" -replace "~","-" -split " " | Select-Object -Index 1
$ARPVer = ($SemVer -split "-" | Select-Object -First 2) -Join "-"

wingetcreate.exe update --urls "https://github.com/diskuv/dkml-installer-opam/releases/download/$SemVer/unsigned-opam-windows_x86-i-$SemVer.exe|x86|user" "https://github.com/diskuv/dkml-installer-opam/releases/download/$SemVer/unsigned-opam-windows_x86_64-i-$SemVer.exe|x64|user" --version "$ARPVer" --out installer/winget Diskuv.opam

foreach ($yamlfile in "Diskuv.opam.yaml","Diskuv.opam.locale.en-US.yaml","Diskuv.opam.installer.yaml")
{
  Copy-Item "installer\winget\manifests\d\Diskuv\opam\$ARPVer\$yamlfile" "installer\winget\manifest\$yamlfile"
}

Remove-Item -Force -Recurse installer\winget\manifests
```

SECOND, do the [Windows Sandbox testing](#windows-sandbox-testing).

THIRD, do the [Actual Testing](#actual-testing).

FOURTH, review the changes with `git diff` and then do a `git commit`. *If you need modifications, you'll have to use the [manual submission](#alternate---manual-submission) method.*

FIFTH, do the submission:

```powershell
wingetcreate.exe update --urls "https://github.com/diskuv/dkml-installer-opam/releases/download/$SemVer/unsigned-opam-windows_x86-i-$SemVer.exe|x86|user" "https://github.com/diskuv/dkml-installer-opam/releases/download/$SemVer/unsigned-opam-windows_x86_64-i-$SemVer.exe|x64|user" --version "$ARPVer" --submit Diskuv.opam
```

## Alternate - Manual Submission

FIRST, go to <https://github.com/microsoft/winget-pkgs> and press the Fork
button. You will create a fork in your personal GitHub account.

SECOND, in the `dkml-installer-opam` directory use PowerShell to run:

```powershell
# Set this to your personal GitHub account name because we'll need to do a
# GitHub PR. Example: jonahbeckford
$PERSONAL="todo-what-is-your-personal-github-account-name"

if (Test-Path ..\winget-pkgs) {
    git -C ..\winget-pkgs fetch
    git -C ..\winget-pkgs switch master --discard-changes
    git -C ..\winget-pkgs branch --set-upstream-to=origin/master
    git -C ..\winget-pkgs reset --hard origin/master
} else {
    git -C .. clone https://github.com/microsoft/winget-pkgs
}
if (-not (Test-Path ..\winget-pkgs\.git\refs\remotes\personal\HEAD)) {
    git -C ..\winget-pkgs remote add personal "https://github.com/$PERSONAL/winget-pkgs.git"
}
$PKGSEARCH = Get-Content .\installer\winget\manifest\Diskuv.opam.yaml | Select-String -Pattern "^PackageVersion: *([0-9a-z.-]+)" -CaseSensitive
$PKGVER = $PKGSEARCH.Matches.Groups[1].Value
if (Test-Path "..\winget-pkgs\.git\refs\heads\opam-$PKGVER" ) {
    git -C ..\winget-pkgs switch "opam-$PKGVER"
} else {
    git -C ..\winget-pkgs switch -c "opam-$PKGVER"
}
$MANIFESTDIR = "..\winget-pkgs\manifests\d\Diskuv\opam\$PKGVER"
if (-not (Test-Path $MANIFESTDIR)) { New-Item -Type Directory $MANIFESTDIR }
Copy-Item -Path ".\installer\winget\manifest\*.yaml" -Destination $MANIFESTDIR
git -C ..\winget-pkgs add "manifests\d\Diskuv\opam\$PKGVER"

git -C ..\winget-pkgs commit "manifests\d\Diskuv\opam\$PKGVER" -m "opam $PKGVER"

# Add the -f option to force push onto an existing PR
git -C ..\winget-pkgs push --set-upstream personal "opam-$PKGVER"
```

After that you can go to your personal GitHub project and do a PR.

## Testing

### Prerequisites

You will need *once* as Administrator to run the following:

```powershell
winget settings --enable LocalManifestFiles

Enable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM'
```

to avoid the errors:

> This feature needs to be enabled by administrators. To enable it, run 'winget settings --enable LocalManifestFiles' as administrator
>
> Windows Sandbox does not seem to be available.

### Windows Sandbox Testing

> Never use Windows Sandbox as your final test before releasing to end-users.
> Instead run the installer on your own machine.
>
> And if you don't want to install it on your local machine:
> why would you be comfortable asking other Windows users to install it?

The instructions below are from <https://github.com/microsoft/winget-pkgs> and
include some suggestions from <https://github.com/microsoft/winget-pkgs/pull/69112>:

FIRST clone the `winget-pkgs` repository alongside the `dkml-installer-opam`
directory with:

```powershell
cd dkml-installer-opam
cd ..
git clone https://github.com/microsoft/winget-pkgs.git
```

SECOND, run the manifest in the sandbox:

```powershell
.\Tools\SandboxTest.ps1 ..\dkml-installer-opam\installer\winget\manifest
```

If the installer fails with:

![Search for app in the Store](https://user-images.githubusercontent.com/71855677/184410812-08ba2ab8-8c3d-490d-8c38-b6b3a6df41a4.png)

then you will need to do the following inside the Windows Sandbox:

```powershell
# Disable the Smart Screen especially on Windows 11
if (($env:USERNAME -eq "WDAGUtilityAccount") -or ($PWD.Path -eq "C:\Users\WDAGUtilityAccount\Desktop\winget-pkgs")) {
    foreach ($drive in @("HKLM", "HKCU")) {
        $path = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
        $key = Get-Item -LiteralPath ${drive}:\${path}
        if (($key.GetValue("SmartScreenEnabled", $null) -eq $null) -or
            -not(Get-ItemProperty -Path ${drive}:\${path} -Name SmartScreenEnabled))
        {
            Set-ItemProperty -Path ${drive}:\${path} -Name SmartScreenEnabled -Value Off -Force
            Write-Host "${drive}:\${path} SmartScreenEnabled=Off"
        }
    }
}

# Rerun the installer; if you are prompted for security now you'll be able to click through it
winget install --manifest ..\SandboxTest\manifest
```

### Actual Testing

Validate any changes with:

```powershell
winget validate --manifest installer/winget/manifest
```

Test a change with:

```powershell
winget install --manifest installer/winget/manifest
```

and to ensure `Microsoft Defender SmartScreen` gets its first look at the 32-bit installer test the 32-bit installer with:

```powershell
winget install --manifest installer/winget/manifest --architecture X86
```

You can uninstall it after testing with:

```powershell
winget uninstall opam
```
