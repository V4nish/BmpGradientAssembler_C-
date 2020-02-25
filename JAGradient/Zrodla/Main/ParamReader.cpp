#include "pch.h"

void ParamReader::setParam(std::string param, std::string val)
{
	if (param=="-r")
	{
		this->red = stoi(val);
	}
	if (param == "-g")
	{
		this->green = stoi(val);
	}
	if (param == "-b")
	{
		this->blue = stoi(val);
	}
	if (param=="-i")
	{
		this->infilepath = val;
	}
	if (param=="-o")
	{
		this->outfilepath = val;
	}
	if (param=="-A1C0")
	{
		this->A1C0switch = atoi(val.c_str());
	}
	if (param == "-t")
	{
		this->NumberOfthreads = atoi(val.c_str());
		this->NumberOfthreads > 64 ? this->NumberOfthreads = 64:false;
	}
}

ParamReader::ParamReader()
{
	this->NumberOfthreads = std::thread::hardware_concurrency();
	return;
}