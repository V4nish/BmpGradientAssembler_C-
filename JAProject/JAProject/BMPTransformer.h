#pragma once

int CallMyDLL(unsigned char rg, unsigned char gg, unsigned char bg, int width, int height, void* data);
int CallMyDLLC(unsigned char rg, unsigned char gg, unsigned char bg, int width, int height, void* data);

struct BMPReader;
struct ParamReader;

struct BMPTransformer
{
	BMPReader* bmp;
	ParamReader* paramReader;
	char**argv;
	int argc;
	int*heightsarray;
	int height;
	int iterator;
	std::vector<std::thread*>threads;
public:
	BMPTransformer(char*_argv[], int _argc);
	~BMPTransformer();
	void ReadFromFile();
	void ValidateParams();
	void CalculateHeights();
	void SaveBMP();
	void Transform();
	void Cleanup();
private:

};

