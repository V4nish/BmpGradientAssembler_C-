# BmpGradientAssemblerAndC++
This project was created for Assembly Languages at Silesian University of Technology. </br>
## What does it do?
This application puts a gradient on a .bmp file. </br>
It was implemented in 2 languages:
* C/C++
* Assembly
Idea was to compare if time gained by vector instructions usage in assembly language may improve performance of C/C++ language. </br>
In this particular case it turned out it may not. </br>

Documentation (only PL version) and charts generated during analisys are at /JAGradient/Dokumentacja </br>
Pure sources can be found at /JAGradient/Zrodla%202.0 </br>
Working visual studio project 2017 is at /JAProject </br>

### Manual
To run the project one must specify all parameters followed by values in command line:
* -r [Red color from 0:255]
* -g [Green color from 0:255]
* -b [Blue color from 0:255]
* -i [path to input file]
* -o [path to output file]
* -A1C0 [1 for assembly execution or 0 for C execution]

