// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include "targetver.h"

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files
#include <windows.h>
#include <iostream>

// reference additional headers your program requires here
#ifndef DLLEXPORT
#define DLLEXPORT __declspec(dllexport)
#else 
#define DLLIMPORT __declspec(dllimport)
#endif // !DLLEXPORT




#include "JADLLC.h"