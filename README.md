# FortranBuildVortex
## Method
前一帧的漩涡可以和这一帧的漩涡对应上：
	1. 离得足够近：两个漩涡的距离displacement小于这一帧离该漩涡最近的漩涡的距离mindistance*Lc(0~1)+第二个漩涡是displacement最小的一个
	2. 漩涡涡量变化不大：漩涡涡量的相对变化不超过vorlimit(0~1)

因此出现了两帧之间的映射：映射是上一帧的每个涡最多映射到下一帧的一个涡上；但是下一帧的一个涡有可能被两个涡映射上，随便选一个！！！？？。

输入：Vortexdata\_dataname文件夹
输出：矩阵vortextimeseries(vortexi,vortexframe, vortexinfor)
vortexi 表示第i个漩涡
vortexframe 是第i个漩涡出现的帧数，time随着vortexframe变化变化，漩涡随vortexframe变化移动
vortexinfor 由1~4分别为[xc, yc, vorticity, time]
矩阵默认值为0。

步骤：
1. 导入文件夹中文件到矩阵vortexdata有一项是是否被遍历过的标记0/1
2. 从第一帧的第一个涡开始遍历，遍历使用函数connectvortex，把输入的涡记录在输出文件vortextimeseries里，并且标记原始数据为1
3. 直到遍历完最后一帧的最后一个涡结束

## Usage
First, set parameters in *source/parameters.f90*.

To compile buildvortex program, run in FortranBuildVortex directory

```
#!/bin/bash
make clean
make
```
or 
```
#!/bin/bash
make clean
make field
```
if you want to export data in each frame instead of vortex series.

Then, run
```
INPUTDIR=/you_data_dir
OUTPUTDIR=/your_result_dir
./buildvortex_series $INPUTDIR $OUTPUTDIR
```
or
```
INPUTDIR=
OUTPUTDIR=
./buildvortex_field $INPUTDIR $OUTPUTDIR
```
in terminal

## Batch Process
You can also run the program according to *process_example.sh*.
