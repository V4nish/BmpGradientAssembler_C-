// JAApp.cpp : Defines the entry point for the console application.
//
#include "pch.h"


int main(int argc, char* argv[])
{
	if (std::string(argv[1])=="-act")
	{
		BMPTransformer* bmpt = new BMPTransformer(argv, argc);
		bmpt->ReadFromFile();
		bmpt->ValidateParams();
		///--------------------------------
		//override params if necessary here
		///--------------------------------
		bmpt->CalculateHeights();
		///--------------------------------
		bmpt->Transform();
		bmpt->SaveBMP();
		bmpt->Cleanup();
		return 0;
	}
	//test DLL in C with increasing number of threads
	std::vector<std::string>DLLCstrs;
	
	for (int i = 1; i <= 64; i++)
	{
		BMPTransformer* bmpt = new BMPTransformer(argv, argc);
		bmpt->ReadFromFile();
		bmpt->ValidateParams();
		///--------------------------------
		//override params if necessary here
		bmpt->paramReader->A1C0switch = 0;
		bmpt->paramReader->NumberOfthreads = i;

		///--------------------------------
		bmpt->CalculateHeights();
		///--------------------------------
		//time testing area
		auto start = std::chrono::high_resolution_clock::now();

		bmpt->Transform();

		auto finish = std::chrono::high_resolution_clock::now();
		std::chrono::duration<double> elapsed = finish - start;
		double seconds = elapsed.count();
		DLLCstrs.push_back(std::string(/*"Elapsed time: "+*/std::to_string(seconds)/*+"s with: "+std::to_string(i)+" threads\n"*/));

		///--------------------------------
		bmpt->SaveBMP();
		bmpt->Cleanup();
	}
	///----------------------------------
	//send test results out to file
		
	std::ofstream outfile;
	outfile.open("DLLC_results.txt");
	for (int i = 0; i < DLLCstrs.size(); i++)
	{
		outfile << DLLCstrs[i]<<std::endl;
	}
	outfile.close();
	while (DLLCstrs.size())
	{
		DLLCstrs.pop_back();
	}
	///----------------------------------

	std::vector<std::string>DLLAstrs;

	for (int i = 1; i <= 64; i++)
	{
		BMPTransformer* bmpt = new BMPTransformer(argv, argc);
		bmpt->ReadFromFile();
		bmpt->ValidateParams();
		///--------------------------------
		//override params if necessary here
		bmpt->paramReader->A1C0switch = 1;
		bmpt->paramReader->NumberOfthreads = i;

		///--------------------------------
		bmpt->CalculateHeights();
		///--------------------------------
		//time testing area
		auto start = std::chrono::high_resolution_clock::now();

		bmpt->Transform();

		auto finish = std::chrono::high_resolution_clock::now();
		std::chrono::duration<double> elapsed = finish - start;
		double seconds = elapsed.count();
		DLLAstrs.push_back(std::string(/*"Elapsed time: "+*/std::to_string(seconds)/*+"s with: "+std::to_string(i)+" threads\n"*/));

		///--------------------------------
		bmpt->SaveBMP();
		bmpt->Cleanup();

	}
	///----------------------------------
	//send test results out to file

	outfile.open("DLLA_results.txt");
	for (int i = 0; i < DLLAstrs.size(); i++)
	{
		outfile << DLLAstrs[i]<<std::endl;
	}
	outfile.close();
	while (DLLAstrs.size())
	{
		DLLAstrs.pop_back();
	}
	///----------------------------------
	return 0;
}