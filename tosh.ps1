param([string]$inputDir='.', [string]$outputDir='.', [switch]$replace=$false, [switch]$print=$false)

$inputDir  = get-item $inputDir
$outputDir = get-item $outputDir

$vlc = ${env:ProgramFiles} + "\VideoLAN\VLC\vlc.exe"
$outputFiles = get-childitem -File -Path $outputDir | select -expandproperty basename

function transcode
{
  param([string]$inputFile, [string]$outputFile)
  $vlcArgs = "-vvv `"$($inputFile)`" --sout=#transcode{vcodec=`"h264`",acodec=`"mpga`",ab=`"128`",channels=`"2`",samplerate=`"44100`"}:std{access=`"file`",mux=`"mp4`",dst=`"$($outputFile)`"} vlc://quit"
  if(!$print)
  {
    write-output "$vlc $vlcArgs"
    $p = start-process $vlc $vlcArgs -wait -passthru
    if(!$p.exitcode -and $replace)
    {
      remove-item $inputFile
    }
  }
}

foreach($inputFile in get-childitem -File -Path $inputDir -recurse -Filter *.avi)
{
  $outputFile = [System.IO.Path]::GetFileNameWithoutExtension($inputFile.FullName) + ".mp4"
  if($replace)
  {
    $outputFile = [System.IO.Path]::Combine($inputFile.directoryname, $outputFile)
    if(!(test-path $outputFile))
    {
      transcode $inputFile.fullname $outputFile
    }
  }
  elseif($outputFiles -notcontains $inputFile.basename)
  {
    $outputFile = [System.IO.Path]::Combine($outputDir, $outputFile)
    transcode $inputFile.fullname $outputFile
  }
  if($print)
  {
    write-output "$($inputFile.fullname) => $outputFile"
  }
}
