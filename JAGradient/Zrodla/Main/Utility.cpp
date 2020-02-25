#include "pch.h"

namespace utility
{

	void print(const std::string &str)
	{
		std::cout << str << std::endl;
	}


	void print(char* str)
	{
		std::cout << str << std::endl;
	}

	void log(const std::string &str)
	{
		std::cout << str << std::endl;//TODO to file
	}


	void log(char* str)
	{
		std::cout << str << std::endl;//TODO to file
	}

}
