#pragma once


struct ParamReader
{
	int NumberOfthreads=1;
	std::string infilepath;
	std::string outfilepath;
	bool A1C0switch = 1;
	void setParam(std::string param, std::string val);
	unsigned char red=200;
	unsigned char green=0;
	unsigned char blue=0;
	ParamReader();
};
