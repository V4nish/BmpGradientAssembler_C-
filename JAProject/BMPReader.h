#pragma once
#include <string>

#define RGradient 200
#define GGradient 0
#define BGradient 0

//https://solarianprogrammer.com/2018/11/19/cpp-reading-writing-bmp-images/
#pragma pack(push,1)
struct BMPFileHeader {
        uint16_t file_type{ 0 };
	    uint32_t file_size{ 0 };               
	    uint16_t reserved1{ 0 };               
	    uint16_t reserved2{ 0 };               
	    uint32_t offset_data{ 0 };
};
#pragma pack(pop)

#pragma pack(push,1)
struct BMPInfoHeader {
	     uint32_t size{ 0 };                      
	     int32_t width{ 0 };                      
	     int32_t height{ 0 };                      
	     uint16_t planes{ 1 };                   
	     uint16_t bit_count{ 0 };                 
	     uint32_t compression{ 0 };               
	     uint32_t size_image{ 0 };               
	     int32_t x_pixels_per_meter{ 0 };
	     int32_t y_pixels_per_meter{ 0 };
	     uint32_t colors_used{ 0 };               
	     uint32_t colors_important{ 0 };          
};
#pragma pack(pop)

#pragma pack(push,1)
struct BMPColorHeader {
	     uint32_t red_mask{ 0x00ff0000 };         // Bit mask for the red channel
	     uint32_t green_mask{ 0x0000ff00 };       // Bit mask for the green channel
	     uint32_t blue_mask{ 0x000000ff };        // Bit mask for the blue channel
	     uint32_t alpha_mask{ 0xff000000 };       // Bit mask for the alpha channel
	     uint32_t color_space_type{ 0x73524742 }; // Default "sRGB" (0x73524742)
	     uint32_t unused[16]{ 0 };                // Unused data for sRGB color space
};
#pragma pack(pop)

class BMPReader
{
public:
	BMPFileHeader* bfh;
	BMPInfoHeader* bih;
	BMPColorHeader* bch;
	char*data;
	int width;
	int height;
	BMPReader();
	~BMPReader();
	int ReadBMP(std::string path);
	int WriteBMP(std::string path);
	int BMPTransform();
private:
	void* memory;
	int bmp_size;
};




