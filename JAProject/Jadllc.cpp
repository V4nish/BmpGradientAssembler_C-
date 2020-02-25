#include "Jdllc.h"

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

int BMPReader::ReadBMP(std::string path)
{
	std::fstream File;
	File.open(path, std::fstream::in | std::fstream::binary);
	File.seekg(0, std::ios::end);
	bmp_size = File.tellg();
	File.close();


	FILE*file;
	file = fopen(path.c_str(), "rb");
	this->memory = new char[bmp_size];
	fread(memory, 1, bmp_size, file);
	fclose(file);


	this->bfh = (BMPFileHeader*)(this->memory);
	this->bih = (BMPInfoHeader*)((char*)this->memory + sizeof(BMPFileHeader));
	this->bch = (BMPColorHeader*)((char*)this->bih + sizeof(BMPInfoHeader));
	this->data = (char*)this->memory + (sizeof(BMPColorHeader)) + 36;

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

int BMPReader::BMPTransform()
{

	char*temp = data;
	unsigned char CDR = RGradient;
	unsigned char CDG = GGradient;
	unsigned char CDB = BGradient;
	int divisor = 0;
	for (int i = 0; i < (this->width)*this->height * 3; i += 3)
	{
		CDR = RGradient * (this->width - divisor) / this->width;
		CDG = GGradient * (this->width - divisor) / this->width;
		CDB = BGradient * (this->width - divisor) / this->width;

		divisor == width ? std::cout << divisor << std::endl, divisor = 0 EIF;
		divisor += 1;
		temp[i] += (CDG*(255 - temp[i])) / 255;
		temp[i + 1] += (CDR*(255 - temp[i + 1])) / 255;
		temp[i + 2] += (CDB*(255 - temp[i + 2])) / 255;
	}
	return 0;
}