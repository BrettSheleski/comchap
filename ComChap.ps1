param(
    [string]$infile,
    [string]$outfile,
    [switch]$keepEdl,
    [switch]$keepMeta,
    [string]$ffmpegPath = ".\ffmpeg.exe",
    [string]$comskipPath = ".\comskip.exe",
    [string]$comskipini = "$env:USERPROFILE\.comskip.ini",
    [string]$lockfile,
    [string]$workdir
)
if (-not $infile) {
    $exename = Split-Path -Leaf $MyInvocation.MyCommand.Path
    Write-Host "Add chapters to video file using EDL file"
    Write-Host "     (If no EDL file is found, comskip will be used to generate one)"
    Write-Host ""
    Write-Host "Usage: $exename infile [outfile]"
    exit 1
}
[bool]$deleteedl = !$keepEdl
[bool]$deletemeta = !$keepMeta
$deletelog = $true
$deletelogo = $true
$deletetxt = $true
$tempfiles = @()
$totalcutduration = 0
If ($lockfile) {
    if (Test-Path $lockfile) {
        Write-Host "lockfile: $lockfile"
        Write-Host "Waiting" -ForegroundColor Yellow
        while (Test-Path $lockfile) {
            sleep 5
            Write-Host "." -NoNewLine -ForegroundColor Yellow
        }
  }
  New-Item $lockfile
}
if (-not $outfile) {
    $outfile = $infile
}
$outdir = Split-Path $outfile -Parent
$outextension = $outfile -split "\." | Select-Object -Last 1
$comskipoutput = ""
if ($workdir) {
    if (!($workdir.EndsWith("\"))) {
       $workdir += "\"
    }
    $comskipoutput = "$workdir"
    $infileb = Split-Path $infile -Leaf
    $edlfile = "${workdir}$($infileb -replace '\.[^.]+$').edl"
    $metafile = "${workdir}$($infileb -replace '\.[^.]+$').ffmeta"
    $logfile = "${workdir}$($infileb -replace '\.[^.]+$').log"
    $logofile = "${workdir}$($infileb -replace '\.[^.]+$').logo.txt"
    $txtfile = "${workdir}$($infileb -replace '\.[^.]+$').txt"
}
else {
    $edlfile = "$($infile -replace '\.[^.]+$').edl"
    $metafile = "$($infile -replace '\.[^.]+$').ffmeta"
    $logfile = "$($infile -replace '\.[^.]+$').log"
    $logofile = "$($infile -replace '\.[^.]+$').logo.txt"
    $txtfile = "$($infile -replace '\.[^.]+$').txt"
}
if (-not (Test-Path $comskipIni)) {
    "output_edl=1" | Out-File -Encoding utf8 $comskipIni
}
elseif ((Get-Content $comskipIni) -notcontains "output_edl=1") {
    "output_edl=1" | Add-Content -Encoding utf8 $comskipIni
}
if (-not (Test-Path $edlfile)) {
    & "$comskipPath" $comskipoutput --ini="$comskipIni" "$infile"
}
$start = 0
$i = 0
$hascommercials = $false
$concat = ""
$lines = Get-Content $edlfile
foreach ($line in $lines) {
    $fields = $line -split "`t"
    $end = [float]$fields[0]
    $startnext = [float]$fields[1]
    if ([double]$end * 1000 -gt [double]$start * 1000) {
        $i++
        $hascommercials = $true
        Add-Content -Path $metafile ";FFMETADATA1"
        Add-Content -Path $metafile "[CHAPTER]"
        Add-Content -Path $metafile "TIMEBASE=1/1000"
        Add-Content -Path $metafile "START=$([int]($start * 1000 - $totalcutduration * 1000))"
        Add-Content -Path $metafile "END=$([int]($end * 1000 - $totalcutduration * 1000))"
        Add-Content -Path $metafile "title=Chapter $i"
        $chapterfile = "$($infile -replace '\.[^.]+$').part-$i.ts"
        if ($workdir) {
            $chapterfile = Split-Path $chapterfile -Leaf
            $chapterfile = "$workdir$chapterfile"
        }
        $tempfiles += $chapterfile
        $concat += "|$chapterfile"
        $duration = [double]$end - [double]$start
        & $ffmpegPath -hide_banner -loglevel error -nostdin -i $infile -ss $start -t $duration -c copy -y $chapterfile
        $totalcutduration += $startnext - $end
    }
    $start = $startnext
}
if ($hascommercials) {
    $endstring = & $ffmpegPath -hide_banner -nostdin -i $infile 2>&1 | Select-String -Pattern "Duration" | ForEach-Object { $_ -replace '\D+(\d+:\d+:\d+.\d+),.*', '$1' }
    $end=([TimeSpan]::Parse($endstring)).TotalSeconds
    if ([double]$end * 1000 -gt [double]$start * 1000) {
        $i++
        Add-Content -Path $metafile "[CHAPTER]"
        Add-Content -Path $metafile "TIMEBASE=1/1000"
        Add-Content -Path $metafile "START=$([int]($start * 1000))"
        Add-Content -Path $metafile "END=$([int]($end * 1000))"
        Add-Content -Path $metafile "title=Chapter $i"
    }
    try {& $ffmpegPath -hide_banner -loglevel error -nostdin -i $infile -i $metafile -c copy -map_metadata 1 -y $outfile}
    catch {Write-Host "Error running ffmpeg: $infile"}
}
If (!(Test-Path $outfile)) {
    Write-Error "Error, $outfile does not exist."
    Exit 1
}
foreach ($tempfile in $tempfiles) {
    Remove-Item -Path $tempfile
}
if ($deleteedl) {
     Remove-Item -Path $edlfile
}
if ($deletemeta) {
     Remove-Item -Path $metafile
}
if ($deletelog) {
     Remove-Item -Path $logfile
}
if ($deletelogo) {
     Remove-Item -Path $logofile
}
if ($deletetxt) {
     Remove-Item -Path $txtfile
}
if ($ldPath) {
    $env:LD_LIBRARY_PATH = $ldPath
}
if ($lockfile) {
    Remove-Item -Path $lockfile
}
