#include "stdafx.h"


DLLEXPORT void TransformBMP(unsigned char RGradient, unsigned char GGradient, unsigned char BGradient, int width, int height, void* data)
{
	int remainder = (width * 3) % 4;
	unsigned char * temp = (unsigned char*)data;
	unsigned char CDR = RGradient;
	unsigned char CDG = GGradient;
	unsigned char CDB = BGradient;
	int divisor = 0;
	int max = ((width*3)+remainder)*height;
	int row = 1;
	int counter=0;
	for (int i = 0; i < max; i += 3)
	{
		
		CDR = RGradient * (width - divisor) / width;
		CDG = GGradient * (width - divisor) / width;
		CDB = BGradient * (width - divisor) / width;

		divisor == width ?  divisor = 0 : 0;
		divisor += 1;
		temp[i] = (temp[i]+(CDB*(256 - temp[i])) / 256);
		temp[i + 1] = (temp[i+1]+(CDG*(256 - temp[i + 1])) / 256);
		temp[i + 2] = (temp[i + 2]+(CDR*(256 - temp[i + 2])) / 256);
		counter++;
		if (counter == width)//at each row end, i+=remainder
		{
			counter = 0;
			i += remainder;
		}
	}
	return;
}