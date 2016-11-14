# Comchap
Commercial detection script and add chapters original file
Note: Comskip must be installed and working in order for Comchap to work.  See: https://github.com/erikkaashoek/Comskip

## Usage
`comchap [OPTIONS] inputfile [OUTPUTFILE]`

### Remarks
Comchap will read the input file specified to generate chapter information marking where commercials are located.

Comchap uses Comskip to do the detection of commercials if no EDL file is found.  The EDL file must be the same name as the input file, but with a .edl file extension.  If no EDL file is found Comskip will be used to generate an EDL file.

When generating an EDL file Comchap will specify Comskip to use an ini file located at ~/.comskip.ini.  If this file is not found, or it does not contain output_edl=1 then the script will make sure it does.  This ensures Comskip to generate the needed EDL file.

If OUTPUTFILE is not specified then comchap will overwrite inputfile.

### Command Line Arguments
-  `--keep-edl`           Keep the generated EDL file (do not delete when done)
-  `--keep-meta`          Keep the generated ffmeta file used to tell ffmpeg where the chapters are located
-  `--ffmpeg=PATH`        Use PATH as the path to ffmpeg binary
-  `--comskip=PATH`       Use PATH as the path to comskip binary
-  `--comskip-ini=PATH`   Use PATH as the path to the comskip.ini file used by Comskip
-  `--lockfile=PATH`      Use PATH as a lockfile to prevent multiple instances of the script from running simultaneously.
                           Comchap will wait until PATH does not exist before doing any processing.

# Comcut
Commercial detection and removal script

## Usage
`comcut [OPTIONS] inputfile [OUTPUTFILE]`

### Remarks
Comcut will read the input file specified and remove detected commercials.  It no output file is specified, it will overwrite the input file, otherwise it will write to the output file.

Comcut is very similar to Comchap, however the detected commercials are removed from the resulting file.  Chapters are still added to the resulting file.

### Command Line Arguments
-  `--keep-edl`           Keep the generated EDL file (do not delete when done)
-  `--keep-meta`          Keep the generated ffmeta file used to tell ffmpeg where the chapters are located
-  `--ffmpeg=PATH`        Use PATH as the path to ffmpeg binary
-  `--comskip=PATH`       Use PATH as the path to comskip binary
-  `--comskip-ini=PATH`   Use PATH as the path to the comskip.ini file used by Comskip
-  `--lockfile=PATH`      Use PATH as a lockfile to prevent multiple instances of the script from running simultaneously.  Comchap will wait until PATH does not exist before doing any processing.
-  `--work-dir=PATH`      Use PATH as a directory to create any temporary files needed by Comskip and/or Comcut.  If not specified it will use the current directory.