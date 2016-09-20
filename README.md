# Comchap
Commercial detection script and add chapters original file

## Usage
comchap inputfile [outputfile]

### Remarks
Comchap will read the input file specified to generate chapter information marking where commercials are located.

Comchap uses Comskip to do the detection of commercials if no EDL file is found.  The EDL file must be the same name as the input file, but with a .edl file extension.  If no EDL file is found Comskip will be used to generate an EDL file.

When generating an EDL file Comchap will specify Comskip to use an ini file located at ~/.comskip.ini.  If this file is not found, or it does not contain output_edl=1 then the script will make sure it does.  This ensures Comskip to generate the needed EDL file.



