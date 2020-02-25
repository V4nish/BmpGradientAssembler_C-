;-------------------------------------------------------------------------
.DATA

.CODE
DllEntry PROC hInstDLL:DWORD, reason:DWORD, reserved1:DWORD
mov rax, 1
ret
DllEntry ENDP

;Leave byte index 0h-Fh and the byte value from xmm0 will be put to al
GetByte proc byteIndex:qword;no touch magic happens
mov rbx,00FFh;make mask
mov rax, byteIndex
mov rdx,08h
sub rax,rdx
mov byteIndex,rax
jnb highbyte
add rax,rdx
mov rdx,8h
mul rdx
mov rcx,rax
mov byteIndex, rbx
shl rbx,cl
movq xmm15,xmm0
movd rax,xmm15
and rax, rbx
shr rax, cl
mov rbx,0h
movq xmm15,rbx
ret
highbyte: 
movhlps xmm15,xmm0
mov rdx,8h
mul rdx
mov rcx,rax
mov byteIndex, rbx
shl rbx,cl
movd rax,xmm15
and rax, rbx
shr rax, cl
mov rbx,0h
movq xmm15,rbx
ret
GetByte endp

;Leave byte index 0h-Fh and the byte value, the value will replace current value in xmm1 on byteindex-th position
SetByte proc byteIndex:qword, value:qword;no touch magic happens
mov rbx,00FFh;make mask
mov rax, byteIndex
mov rdx,08h
sub rax,rdx
mov byteIndex,rax
jnb highbyte
add rax,rdx
mov rdx,8h
mul rdx
mov rcx,rax
mov byteIndex, rbx
shl rbx,cl
movq xmm15,xmm1
movd rax,xmm15
and rax, rbx
mov rbx,0h
movq xmm14,rax
xorps xmm15,xmm14
mov rax,0h
movq xmm14,rbx
movq xmm14,rax
xorps xmm15,xmm14
mov rax,value
shl rax,cl
movq xmm14,rax
orps xmm15,xmm14
movq xmm1,xmm15
mov rbx,0h
movq xmm15,rbx
ret
highbyte: 
movhlps xmm15,xmm1
mov rdx,8h
mul rdx
mov rcx,rax
mov byteIndex, rbx
shl rbx,cl
movd rax,xmm15
and rax, rbx
mov rbx,0h
movq xmm14,rax
xorps xmm15,xmm14
mov rax,0h
movq xmm14,rbx
movq xmm14,rax
xorps xmm15,xmm14
mov rax,value
shl rax,cl
movq xmm14,rax
orps xmm15,xmm14
movlhps xmm1,xmm15
mov rbx,0h
movq xmm15,rbx
ret
SetByte endp

;calculate new value of a pixel
;value to be returned is stored int rax
GetColorValue proc _width:qword,_divisor:qword,color:qword,currentVal:qword
local outValue:qword
mov rax,0h
mov outValue,rax
mov rbx,0h
mov rdx,0h
mov outValue,rax
;CDR = 200 * (this->width - divisor) / this->width; below
mov rax,_width
mov rbx,_divisor
sub rax,rbx
mov rbx,0h
mov rbx,color
mul rbx
mov rbx,0h
mov rbx,_width
mov rdx,0h
div rbx
mov outValue,rax
;temp[i]=(CDR*(256 - temp[i])) / 256;
mov rax,100h
mov rbx,currentVal
sub rax,rbx
mov rbx,outValue
mul rbx
mov rbx,100h
div rbx
mov rbx,0h
mov rbx,currentVal
add rax,rbx
ret
;value to be returned is stored int rax
GetColorValue endp

TransformBMP proc RGradient:byte,GGradient:byte,BGradient:byte,_width:dword,_height:dword,data:qword
local returnptr: qword 
local cdr:byte;current red factor
local cdg:byte;current green factor
local cdb:byte;current blue factor
local counter: qword;counter for loop
local remainder: qword;allignment remainder for read offset
local divisor: qword;algorithm divisor
local pixelsLeft: qword;pixels left in a row
local rowLoopsCount: qword;contains how many rowloops should be done, which equals to how many rows are in the data block
local registerTempPtr: qword;contains pointer to last read bytes to register
local maxChar: byte
;initialize locals

mov counter, 0h
mov remainder, 0h
mov divisor,0h
mov rowLoopsCount,0h
mov registerTempPtr,0h
mov maxChar,00FFh
vzeroall

mov RGradient,cl
mov GGradient,dl
mov BGradient,r8b
mov _width,r9d

;int remainder = (width * 3) % 4;
mov rax,0h
mov rbx,0h
mov rcx,0h
mov rdx,0h
mov eax,_width
mov rbx,3h
mul rbx
mov rbx,4h
div rbx
mov remainder,rdx
mov rax,0h
mov rbx,0h
mov rcx,0h
mov rdx,0h

;unsigned char CDR = RGradient;
mov al,Rgradient
mov cdr,al

;unsigned char CDG = GGradient;
mov al,GGradient
mov cdg,al

;unsigned char CDB = BGradient;
mov al,BGradient
mov cdb,al

;algorithm
 
;for each row
mov rax,0h
mov eax, _height
mov rowLoopsCount, rax
	rowsloop:
	vzeroall
	mov rax,0h
	mov rbx,0h
	;do stuff with those rows
	mov rax, 0h
	mov eax, _width
	mov pixelsLeft, rax
		registerloop:

			;calculate pointer offset from original data // ptr=data+(3*divisor)+3*((height-rowloopscount)*width+remainder)
			mov rax,divisor
			mov rbx,3h
			mul rbx
			mov rcx,0h
			mov rcx,rax;3*divisor to rcx
			mov rax,0h
			mov eax,_height
			mov rbx,rowLoopsCount
			sub rax,rbx
			mov rbx,0h
			mov ebx,_width
			mul rbx;now (height-rlc)*width in rax
			mov rbx,remainder
			add rax,rbx
			mov rbx,3h
			mul rbx
			add rax,rcx
			mov rbx,rax;mov rax to rbx
			mov rax,data
			add rbx,rax;rbx contains pointer to current block of data to be put into xmm0
			mov rax,0h ;late 3->0
			add rbx,rax
			movdqu xmm0, xmmword ptr [rbx]
			mov registerTempPtr,rbx
			;here is hardcoded algorithm for one vector analysis && edit
			
			mov rax,pixelsLeft
			sub rax,5h
			jb special
			
			;save last pixel
			mov rax,0FH
			push rax
			call GetByte
			pop rbx
			mov r8b,al;LAST BYTE IN r8b
			movdqu xmm13,xmm1;Gradients to xmm13
			
			xorps xmm1,xmm1
			;prepare xmm register with: RG*(width-divisor)*/width 
			;px1
			mov rax,0h
			mov eax,_width
			mov rbx,divisor
			sub rax,rbx
			mov r9,rax;save (width-divisor)
			mov rbx,0h
			mov bl,RGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,0h
			push rbx
			call SetByte
			pop rbx
			pop rbx
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,GGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,1h
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,BGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,2h
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			;take care of divisor
			mov rax,divisor;increment divisor
			inc rax;increment divisor
			mov divisor,rax;increment divisor
			
			;px2
			mov rax,0h
			mov eax,_width
			mov rbx,divisor
			sub rax,rbx
			mov r9,rax;save (width-divisor)
			mov rbx,0h
			mov bl,RGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,3h
			push rbx
			call SetByte
			pop rbx
			pop rbx
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,GGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,4h
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,BGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,5h
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			;take care of divisor
			mov rax,divisor;increment divisor
			inc rax;increment divisor
			mov divisor,rax;increment divisor

			;px3
			mov rax,0h
			mov eax,_width
			mov rbx,divisor
			sub rax,rbx
			mov r9,rax;save (width-divisor)
			mov rbx,0h
			mov bl,RGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,6h
			push rbx
			call SetByte
			pop rbx
			pop rbx
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,GGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,7h
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,BGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,8h
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			;take care of divisor
			mov rax,divisor;increment divisor
			inc rax;increment divisor
			mov divisor,rax;increment divisor
			
			;px4
			mov rax,0h
			mov eax,_width
			mov rbx,divisor
			sub rax,rbx
			mov r9,rax;save (width-divisor)
			mov rbx,0h
			mov bl,RGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,9h
			push rbx
			call SetByte
			pop rbx
			pop rbx
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,GGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,0Ah
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,BGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,0Bh
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			;take care of divisor
			mov rax,divisor;increment divisor
			inc rax;increment divisor
			mov divisor,rax;increment divisor

			;px5
			mov rax,0h
			mov eax,_width
			mov rbx,divisor
			sub rax,rbx
			mov r9,rax;save (width-divisor)
			mov rbx,0h
			mov bl,RGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,0Ch
			push rbx
			call SetByte
			pop rbx
			pop rbx
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,GGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,0Dh
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			mov rax,r9;restore (width-divisor)
			mov rbx,0h
			mov bl,BGradient
			mul rbx
			mov rbx,0h
			mov ebx,_width
			div rbx
			push rax ;RG*(push width-divisor)/width
			;setbyte push value, then push index	
			mov rbx,0Eh
			push rbx
			call SetByte
			pop rbx
			pop rbx	
			;take care of divisor
			mov rax,divisor;increment divisor
			inc rax;increment divisor
			mov divisor,rax;increment divisor

			movdqu xmm12,xmm1 ;(width-height)/width to xmm12
			xorps xmm1,xmm1

			;prepare xmm register with (256-temp[i])
			VPBROADCASTB xmm1,maxChar
			vpsubb xmm2,xmm1,xmm0
			movdqu xmm11,xmm2
			xorps xmm2,xmm2
			xorps xmm1,xmm1
			;256-temp[i] in xmm11
			;1st 4 bytes
			vpmovzxbd xmm1,xmm11
			vpmovzxbd xmm2,xmm12
			vpmulld xmm2,xmm1,xmm2;in xmm2 there is (RG*(width-divisor)/width)*(256-temp[i]) for 1st 4 bytes
			VPBROADCASTB xmm9,maxChar
			vpmovzxbd xmm1,xmm9
			VCVTDQ2PS xmm3,xmm1;to single precision
			VCVTDQ2PS xmm4,xmm2
			vdivps xmm4,xmm4,xmm3;divide all stuff by 256
			VCVTPS2DQ xmm5,xmm4;back to integer
			;convert dwords to bytes
			movq xmm6,xmm5
			psrldq xmm6,1h
			pslldq xmm6,1h
			pxor xmm5,xmm6
			psrldq xmm6,3h
			por xmm5,xmm6
			movhlps xmm6,xmm5
			movq xmm7,xmm6
			pslldq xmm6,0Ch
			psrldq xmm6,0Ch
			pxor xmm7,xmm6
			pslldq xmm6,2h
			por xmm5,xmm6
			psrldq xmm7,1h
			por xmm5,xmm7
			movq xmm10,xmm5;move 1st 4 bytes to xmm10
			pxor xmm1,xmm1
			pxor xmm2,xmm2
			pxor xmm3,xmm3
			pxor xmm4,xmm4
			pxor xmm5,xmm5
			pxor xmm6,xmm6
			pxor xmm7,xmm7
			pxor xmm9,xmm9
			
			;2nd 4 bytes
			psrldq xmm11,4h
			psrldq xmm12,4h
			psrldq xmm13,4h
			vpmovzxbd xmm1,xmm11
			vpmovzxbd xmm2,xmm12
			vpmulld xmm2,xmm1,xmm2;in xmm2 there is (RG*(width-divisor)/width)*(256-temp[i]) for 1st 4 bytes
			VPBROADCASTB xmm9,maxChar
			vpmovzxbd xmm1,xmm9
			VCVTDQ2PS xmm3,xmm1;to single precision
			VCVTDQ2PS xmm4,xmm2
			vdivps xmm4,xmm4,xmm3;divide all stuff by 256
			VCVTPS2DQ xmm5,xmm4;back to integer
			;convert dwords to bytes
			movq xmm6,xmm5
			psrldq xmm6,1h
			pslldq xmm6,1h
			pxor xmm5,xmm6
			psrldq xmm6,3h
			por xmm5,xmm6
			movhlps xmm6,xmm5
			movq xmm7,xmm6
			pslldq xmm6,0Ch
			psrldq xmm6,0Ch
			pxor xmm7,xmm6
			pslldq xmm6,2h
			por xmm5,xmm6
			psrldq xmm7,1h
			por xmm5,xmm7
			pslldq xmm5,4h
			pslldq xmm5,8h
			psrldq xmm5,8h
			por xmm10,xmm5;move 1st 4 bytes to xmm10
			pxor xmm1,xmm1
			pxor xmm2,xmm2
			pxor xmm3,xmm3
			pxor xmm4,xmm4
			pxor xmm5,xmm5
			pxor xmm6,xmm6
			pxor xmm7,xmm7
			pxor xmm9,xmm9

			;3rd 4 bytes
			psrldq xmm11,4h
			psrldq xmm12,4h
			psrldq xmm13,4h
			vpmovzxbd xmm1,xmm11
			vpmovzxbd xmm2,xmm12
			vpmulld xmm2,xmm1,xmm2;in xmm2 there is (RG*(width-divisor)/width)*(256-temp[i]) for 1st 4 bytes
			VPBROADCASTB xmm9,maxChar
			vpmovzxbd xmm1,xmm9
			VCVTDQ2PS xmm3,xmm1;to single precision
			VCVTDQ2PS xmm4,xmm2
			vdivps xmm4,xmm4,xmm3;divide all stuff by 256
			VCVTPS2DQ xmm5,xmm4;back to integer
			;convert dwords to bytes
			movq xmm6,xmm5
			psrldq xmm6,1h
			pslldq xmm6,1h
			pxor xmm5,xmm6
			psrldq xmm6,3h
			por xmm5,xmm6
			movhlps xmm6,xmm5
			movq xmm7,xmm6
			pslldq xmm6,0Ch
			psrldq xmm6,0Ch
			pxor xmm7,xmm6
			pslldq xmm6,2h
			por xmm5,xmm6
			psrldq xmm7,1h
			por xmm5,xmm7
			pslldq xmm5,4h
			pslldq xmm5,8h
			psrldq xmm5,4h
			por xmm10,xmm5;move 1st 4 bytes to xmm10
			pxor xmm1,xmm1
			pxor xmm2,xmm2
			pxor xmm3,xmm3
			pxor xmm4,xmm4
			pxor xmm5,xmm5
			pxor xmm6,xmm6
			pxor xmm7,xmm7
			pxor xmm9,xmm9	

			;4th 4 bytes
			psrldq xmm11,4h
			psrldq xmm12,4h
			psrldq xmm13,4h
			vpmovzxbd xmm1,xmm11
			vpmovzxbd xmm2,xmm12
			vpmulld xmm2,xmm1,xmm2;in xmm2 there is (RG*(width-divisor)/width)*(256-temp[i]) for 1st 4 bytes
			VPBROADCASTB xmm9,maxChar
			vpmovzxbd xmm1,xmm9
			VCVTDQ2PS xmm3,xmm1;to single precision
			VCVTDQ2PS xmm4,xmm2
			vdivps xmm4,xmm4,xmm3;divide all stuff by 256
			VCVTPS2DQ xmm5,xmm4;back to integer
			;convert dwords to bytes
			movq xmm6,xmm5
			psrldq xmm6,1h
			pslldq xmm6,1h
			pxor xmm5,xmm6
			psrldq xmm6,3h
			por xmm5,xmm6
			movhlps xmm6,xmm5
			movq xmm7,xmm6
			pslldq xmm6,0Ch
			psrldq xmm6,0Ch
			pxor xmm7,xmm6
			pslldq xmm6,2h
			por xmm5,xmm6
			psrldq xmm7,1h
			por xmm5,xmm7
			pslldq xmm5,4h
			pslldq xmm5,8h
			por xmm10,xmm5;move 1st 4 bytes to xmm10
			pxor xmm1,xmm1
			pxor xmm2,xmm2
			pxor xmm3,xmm3
			pxor xmm4,xmm4
			pxor xmm5,xmm5
			pxor xmm6,xmm6
			pxor xmm7,xmm7
			pxor xmm9,xmm9	
			
			vpaddb xmm1,xmm10,xmm0
			mov rax,0h
			mov al,r8b
			push rax
			mov rax,0Fh
			push rax
			call SetByte
			pop rbx
			pop rbx

			pxor xmm10,xmm10
			pxor xmm11,xmm11
			pxor xmm12,xmm12
			pxor xmm13,xmm13
			
			;on register loop end
			;sub 5 pixels from pixels left
			mov rax,0h
			mov rax, pixelsLeft
			mov rbx,5h
			sub rax,rbx
			mov pixelsLeft,rax
			
			;check if there are more pixels in this row?	
			cmp rax,0h
			jna rowended ;if no more pixels in this row jump to next row
			;divisor == width ?  divisor = 0 :false;
			mov rax,0h
			mov rbx,0h
			mov rax,divisor
			mov rbx,0h
			mov ebx,_width
			sub rax,rbx
			cmp rax,0h
			jnz noDivisorReset;pixel n at the end of etiquete
			mov rax,0h
			mov divisor,rax
			noDivisorReset:;pixel n at the end of etiquete
			

		mov rbx,registerTempPtr
		movdqu xmmword ptr [rbx],xmm1
		
	jmp registerloop

	special:
	;------------------------0THPIXEL--------------------------------------
	;--------------------------GREEN0----------------------------------------
		;0th byte
		mov rax,0h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,GGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,0h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------GREEN0-END-------------------------------------
	;--------------------------RED1----------------------------------------
		;1th byte
		mov rax,1h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,RGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,1h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------RED1-END------------------------------------
	;--------------------------BLUE2----------------------------------------
		;2th byte
		mov rax,2h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,BGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,2h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------BLUE2-END------------------------------------	
		;sub 1 from pixelsleft
		mov rax,pixelsLeft
		mov rbx,1h
		sub rax,rbx
		mov pixelsLeft,rax
		;check if there are more pixels in this row?	
		cmp rax,0h
		jz rowended ;if no more pixels in this row jump to next row
		;divisor == width ?  divisor = 0 :false;
		mov rax,0h
		mov rbx,0h
		mov rax,divisor
		mov rbx,0h
		mov ebx,_width
		sub rax,rbx
		cmp rax,0h
		jnz noDivisorReset0;pixel n at the end of etiquete
		mov rax,0h
		mov divisor,rax

		noDivisorReset0:;pixel n at the end of etiquete
		;divisor += 1;
		mov rax,divisor
		mov rbx,1h
		add rax,rbx
		mov divisor,rax
;------------------------0THPIXEL-END----------------------------------

;------------------------1THPIXEL--------------------------------------
	;--------------------------GREEN3----------------------------------------
		;3th byte
		mov rax,3h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,GGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,3h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------GREEN3-END-------------------------------------
	;--------------------------RED4----------------------------------------
		;4th byte
		mov rax,4h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,RGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,4h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------RED4-END------------------------------------
	;--------------------------BLUE5----------------------------------------
		;5th byte
		mov rax,5h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,BGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,5h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------BLUE5-END------------------------------------	
		;sub 1 from pixelsleft
		mov rax,pixelsLeft
		mov rbx,1h
		sub rax,rbx
		mov pixelsLeft,rax
		;check if there are more pixels in this row?	
		cmp rax,0h
		jz rowended ;if no more pixels in this row jump to next row
		;divisor == width ?  divisor = 0 :false;
		mov rax,0h
		mov rbx,0h
		mov rax,divisor
		mov rbx,0h
		mov ebx,_width
		sub rax,rbx
		cmp rax,0h
		jnz noDivisorReset1;pixel n at the end of etiquete
		mov rax,0h
		mov divisor,rax

		noDivisorReset1:;pixel n at the end of etiquete
		;divisor += 1;
		mov rax,divisor
		mov rbx,1h
		add rax,rbx
		mov divisor,rax
;------------------------1THPIXEL-END----------------------------------

;------------------------2THPIXEL--------------------------------------
	;--------------------------GREEN6----------------------------------------
		;6th byte
		mov rax,6h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,GGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,6h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------GREEN6-END-------------------------------------
	;--------------------------RED7----------------------------------------
		;7th byte
		mov rax,7h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,RGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,7h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------RED7-END------------------------------------
	;--------------------------BLUE8----------------------------------------
		;8th byte
		mov rax,8h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,BGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,8h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------BLUE8-END------------------------------------	
		;sub 1 from pixelsleft
		mov rax,pixelsLeft
		mov rbx,1h
		sub rax,rbx
		mov pixelsLeft,rax
		;check if there are more pixels in this row?	
		cmp rax,0h
		jz rowended ;if no more pixels in this row jump to next row
		;divisor == width ?  divisor = 0 :false;
		mov rax,0h
		mov rbx,0h
		mov rax,divisor
		mov rbx,0h
		mov ebx,_width
		sub rax,rbx
		cmp rax,0h
		jnz noDivisorReset2;pixel n at the end of etiquete
		mov rax,0h
		mov divisor,rax

		noDivisorReset2:;pixel n at the end of etiquete
		;divisor += 1;
		mov rax,divisor
		mov rbx,1h
		add rax,rbx
		mov divisor,rax
;------------------------2THPIXEL-END----------------------------------

;------------------------3THPIXEL--------------------------------------
	;--------------------------GREEN9----------------------------------------
		;9th byte
		mov rax,9h;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,GGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,9h;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------GREEN9-END-------------------------------------
	;--------------------------RED10----------------------------------------
		;10th byte
		mov rax,0Ah;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,RGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,0Ah;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------RED10-END------------------------------------
	;--------------------------BLUE11----------------------------------------
		;11th byte
		mov rax,0Bh;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,BGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,0Bh;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------BLUE11-END------------------------------------	
		;sub 1 from pixelsleft
		mov rax,pixelsLeft
		mov rbx,1h
		sub rax,rbx
		mov pixelsLeft,rax
		;check if there are more pixels in this row?	
		cmp rax,0h
		jz rowended ;if no more pixels in this row jump to next row
		;divisor == width ?  divisor = 0 :false;
		mov rax,0h
		mov rbx,0h
		mov rax,divisor
		mov rbx,0h
		mov ebx,_width
		sub rax,rbx
		cmp rax,0h
		jnz noDivisorReset3;pixel n at the end of etiquete
		mov rax,0h
		mov divisor,rax

		noDivisorReset3:;pixel n at the end of etiquete
		;divisor += 1;
		mov rax,divisor
		mov rbx,1h
		add rax,rbx
		mov divisor,rax
;------------------------3THPIXEL-END----------------------------------

;------------------------4THPIXEL--------------------------------------
	;--------------------------GREEN12----------------------------------------
		;12th byte
		mov rax,0Ch;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,GGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,0Ch;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------GREEN12-END-------------------------------------
	;--------------------------RED13----------------------------------------
		;13th byte
		mov rax,0Dh;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,RGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,0Dh;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------RED13-END------------------------------------
	;--------------------------BLUE14----------------------------------------
		;14th byte
		mov rax,0Eh;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		mov rbx,0h
		;get pixel.color value
		mov rbx,rax;hide currentValue in rbx
		;push needed stuff onto stack
		push rax;currentVal got from getByte
		mov rax,0h
		mov al,BGradient;color factor now
		push rax;color
		mov rax,divisor
		push rax;divisor
		mov rax,0h
		mov eax,_width
		push rax;_width
		;get new value
		call GetColorValue;proc _width:qword,_divisor:qword,color:qword,currentVal:qword
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
		push rax;value
		mov rax,0Eh;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;--------------------------BLUE14-END------------------------------------	
		;sub 1 from pixelsleft
		mov rax,pixelsLeft
		mov rbx,1h
		sub rax,rbx
		mov pixelsLeft,rax
		;check if there are more pixels in this row?	
		cmp rax,0h
		jz rowended ;if no more pixels in this row jump to next row
		;divisor == width ?  divisor = 0 :false;
		mov rax,0h
		mov rbx,0h
		mov rax,divisor
		mov rbx,0h
		mov ebx,_width
		sub rax,rbx
		cmp rax,0h
		jnz noDivisorReset4;pixel n at the end of etiquete
		mov rax,0h
		mov divisor,rax

		noDivisorReset4:;pixel n at the end of etiquete
		;divisor += 1;
		mov rax,divisor
		mov rbx,1h
		add rax,rbx
		mov divisor,rax
;------------------------4THPIXEL-END----------------------------------
	
	;-----------------RESTORE-15th-byte----------------------------
		;15th byte
		mov rax,0Fh;nth byte
		push rax
		call GetByte;proc byteIndex:qword
		pop rbx;cleanup
		push rax;value
		mov rax,0Fh;nth byte
		push rax
		call SetByte;byteIndex:qword, value:qword
		pop rbx;cleanup
		pop rbx;cleanup
		mov rbx,0h
	;-----------------BYTE-15-RESTORED-NOW--------------------------

		mov rbx,registerTempPtr
		movdqu xmmword ptr [rbx],xmm1


	rowended:
;move data a little bit so it fits remainder 
mov rax,data
mov rbx,remainder
add rax,rbx
mov data,rax
;
mov rax,0h;zero the divisor
mov divisor,rax
mov rax,rowLoopsCount
mov rbx,1h
sub rax,rbx
mov rowLoopsCount,rax
cmp rax,0h
jnz rowsloop


;end of algorithm
ENDapp:
ret
TransformBMP endp

END
;-------------------------------------------------------------------------