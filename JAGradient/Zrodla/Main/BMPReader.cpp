// JADLLC.cpp : Defines the exported functions for the DLL application.
//

#include "pch.h"

BMPReader::BMPReader()
{

}

BMPReader::~BMPReader()
{
	this->memory ? delete memory EIF
}

int BMPReader::SetRgb(int R, int G, int B)
{
	r = R;
	g = G;
	b = B;
	return 0;
}

int BMPReader::ReadBMP(std::string path,ParamReader* paramReader)
{
	std::fstream File;
	File.open(path, std::fstream::in | std::fstream::binary);
	File.seekg(0, std::ios::end);
	bmp_size = File.tellg();
	File.close();

	const int x64_pixels_at_once = 5;
	const int pixelBytes = 3;
	int bytesToAlloc=0;
	bytesToAlloc = bmp_size;
	FILE*file;
	file = fopen(path.c_str(), "rb");
	this->memory = new char[bytesToAlloc];
	fread(memory, 1, bmp_size, file);
	fclose(file);


	this->bfh = (BMPFileHeader*)(this->memory);
	this->bih = (BMPInfoHeader*)((char*)this->memory + sizeof(BMPFileHeader));
	this->bch = (BMPColorHeader*)((char*)this->bih + sizeof(BMPInfoHeader));
	this->data = (unsigned char*)this->memory + bfh->offset_data-6;

	this->width = this->bih->width;
	this->height = this->bih->height;

	return 0;
}

int BMPReader::WriteBMP(std::string path)
{
	FILE*file;
	file = fopen(path.c_str(), "wb");
	fwrite(memory, 1, bmp_size, file);
	fclose(file);
	return 0;
}

int BMPReader::BMPTransform(unsigned char r, unsigned char g, unsigned char b)
{
	unsigned char*temp = data;
	unsigned char CDR = r;
	unsigned char CDG = g;
	unsigned char CDB = b;
	int divisor = 0;
	for (int i = 0; i < (this->width)*this->height * 3; i += 3)
	{
		CDR = 200 * (this->width - divisor) / this->width;
		CDG = 0 * (this->width - divisor) / this->width;
		CDB = 0 * (this->width - divisor) / this->width;

		temp[i] += (CDG*(255 - temp[i])) / 255;
		temp[i + 1] += (CDR*(255 - temp[i + 1])) / 255;
		temp[i + 2] += (CDB*(255 - temp[i + 2])) / 255;

		divisor == width ? std::cout << divisor << std::endl, divisor = 0 EIF;
		divisor += 1;
	}
	return 0;
}
