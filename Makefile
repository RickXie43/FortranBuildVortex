#源文件所在目录
SOURCE:=source

buildvortex_series : iofortran.o buildvortex_module.o main_buildvortex.o
	ifort iofortran.o buildvortex_module.o main_buildvortex.o -o buildvortex_series

iofortran.o : $(SOURCE)/iofortran.f90
	ifort -c $(SOURCE)/iofortran.f90 -o iofortran.o

buildvortex_module.o : $(SOURCE)/buildvortex_module.f90
	ifort -fpp -c $(SOURCE)/buildvortex_module.f90 -o buildvortex_module.o

main_buildvortex.o : $(SOURCE)/main_buildvortex.f90
	ifort -c $(SOURCE)/main_buildvortex.f90 -o main_buildvortex.o

clean :
	rm -f *.o *.mod buildvortex_series buildvortex_field

field : iofortran.o buildvortex_module.o main_buildvortex_field.o
	ifort iofortran.o buildvortex_module.o main_buildvortex_field.o -o buildvortex_field

main_buildvortex_field.o : $(SOURCE)/main_buildvortex_field.f90
	ifort -c $(SOURCE)/main_buildvortex_field.f90 -o main_buildvortex_field.o
