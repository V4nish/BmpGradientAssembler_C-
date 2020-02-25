#include "pch.h"

int CallMyDLL(unsigned char rg, unsigned char gg, unsigned char bg, int width, int height, void* data)
{
	HINSTANCE hGetProcIDDLL = LoadLibrary("JADLL.dll");
	FARPROC lpfnGetProcessID = GetProcAddress(HMODULE(hGetProcIDDLL), "TransformBMP");
	typedef int(__stdcall * pICFUNC)(unsigned char, unsigned char, unsigned char, int, int, void*);
	pICFUNC Algorithm;
	Algorithm = pICFUNC(lpfnGetProcessID);

	Algorithm(gg, bg, rg, width, height, data);

	FreeLibrary(hGetProcIDDLL);
	return 0;
}

int CallMyDLLC(unsigned char rg, unsigned char gg, unsigned char bg, int width, int height, void* data)
{
	HINSTANCE hGetProcIDDLL = LoadLibrary("JADLLC.dll");
	FARPROC lpfnGetProcessID = GetProcAddress(HMODULE(hGetProcIDDLL), "TransformBMP");
	typedef void(__cdecl * pICFUNC)(unsigned char, unsigned char, unsigned char, int, int, void*);
	pICFUNC Algorithm;
	Algorithm = pICFUNC(lpfnGetProcessID);

	Algorithm(rg, bg, gg, width, height, data);

	FreeLibrary(hGetProcIDDLL);
	return 0;
}

BMPTransformer::BMPTransformer(char*_argv[],int _argc)
{
	bmp = new BMPReader();
	paramReader = new ParamReader();
	argv = _argv;
	argc = _argc;
}

BMPTransformer::~BMPTransformer()
{
}

void BMPTransformer::ReadFromFile()
{
	//read stuff from file
	
	std::vector<std::thread*>threads;
	for (int i = 1; i < argc; i += 2)
	{
		paramReader->setParam(argv[i], argv[i + 1]);
	}
}

void BMPTransformer::ValidateParams()
{
	//validate params
	if (paramReader->NumberOfthreads > std::thread::hardware_concurrency())
	{
		std::cout << "More threads than possible in this pc, you may use:" << std::thread::hardware_concurrency() << "threads" << std::endl;
		throw 1;
	}
	bmp->ReadBMP(paramReader->infilepath, paramReader);
	if (bmp->height < paramReader->NumberOfthreads)
	{
		std::cout << "Height of bmp is lower than threads count you want to use" << std::endl;
		throw 1;
	}
	if (bmp->height < paramReader->NumberOfthreads)
	{
		std::cout << "You wanted to use" << paramReader->NumberOfthreads << " on "
			<< bmp->height << "rows the app will decrease threads to " << bmp->height << std::endl;
		throw 1;
	}
}

void BMPTransformer::CalculateHeights()
{
	//calculate heights for threads
	heightsarray = new int[paramReader->NumberOfthreads];
	height = bmp->height;
	iterator = 0;
	for (int i = 0; i < paramReader->NumberOfthreads; i++)
	{
		heightsarray[i] = 0;
	}
	while (height)
	{
		height--;
		heightsarray[iterator]++;
		iterator == paramReader->NumberOfthreads - 1 ? iterator = 0 : iterator++;
	}
}

void BMPTransformer::Transform()
{
	//run threads
	std::vector<int> offsets;
	for (int i = 0; i < paramReader->NumberOfthreads; i++)
	{
		int sums = 0;
		for (int j = 0; j < i; j++)
		{
			sums += heightsarray[j];
		}
		offsets.push_back(((3 * bmp->width) + ((bmp->width * 3) % 4))*sums);
	}
	for (int i = 0; i < paramReader->NumberOfthreads; i++)
	{
		threads.push_back(new std::thread([=] {!paramReader->A1C0switch ?
			CallMyDLLC(paramReader->red, paramReader->green, paramReader->blue,
				bmp->width, heightsarray[i],
				(void*)((byte*)bmp->data + offsets[i]))
			: CallMyDLL(paramReader->red, paramReader->green, paramReader->blue, bmp->width,
				heightsarray[i], (void*)((unsigned char*)bmp->data + offsets[i]));//switch here in condition
			}));
	}
	//join and delete 
	for (int i = 0; i < paramReader->NumberOfthreads; i++)
	{
		threads[i]->join();
		threads[i] ? delete threads[i] EIF;
		threads[i] = nullptr;
	}
	
}

void BMPTransformer::SaveBMP()
{
	bmp->WriteBMP(paramReader->outfilepath);
}

void BMPTransformer::Cleanup()
{
	bmp->WriteBMP(paramReader->outfilepath);
	//cleanup
	
	for (int i = 0; i < paramReader->NumberOfthreads; i++)
	{
		threads.pop_back();
	}
	bmp ? delete bmp EIF
	paramReader ? delete paramReader EIF
}
