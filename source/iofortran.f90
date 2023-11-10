!============================================================
!Version:
!  Date            Author              Description
!  ========        ========            ===================
!  27/02/23        Rick                Initialize
!
!============================================================
Module iofortran
        Implicit None
        Save
        Private
        !Set Public Variable and Routine that canbe used in Program
        Public::iofortran_files, iofortran_filelines
Contains
        !The subroutine iofortran_files can read filenames and fileamount of a specific directory!
        Subroutine iofortran_files(dir, filenames, fileamount)
                Implicit None
                Character(len=*), Intent(In)::dir
                Character(len=*), Intent(Out), Dimension(:)::filenames
                Integer, Intent(Out)::fileamount
                Integer::ierror, i
                Call system('(ls '//trim(dir)//' | wc -l) > dirfiles')
                Call system('ls '//dir//' >> dirfiles')
                Open (Unit=8, File='dirfiles', Status='Old', Iostat=ierror)
                Read (8, *) fileamount
                readfilename: Do i = 1, fileamount
                        Read (8, *) filenames(i)
                End Do readfilename
                Close (8)
                Call system('rm -f dirfiles')
        End Subroutine iofortran_files

        Subroutine iofortran_filelines(filename, lines)
                Implicit None
                Character(len=*), Intent(In)::filename
                Integer, Intent(Out)::lines
                Integer::ierror
                lines = 0
                Open (Unit=8, File=filename, Status='Old', Iostat=ierror)
                Do While (.Not. eof(8))
                        Read (8, *)
                        lines = lines + 1
                End do
                Close (8)
        End Subroutine iofortran_filelines

End Module iofortran

!Program testmain
!        Use iofortran
!        Implicit None
!        Character(len=10), Dimension(100)::filenames
!        Integer::num, i
!        Call iofortran_files('/', filenames, num)
!        Write (*, *) num
!        readfileame: Do i = 1, num
!                write (*, *) filenames(i)
!        End Do readfileame
!        Integer::n
!        Call iofortran_filelines('iofortran.f90', n)
!        Write (*, *) n
!End Program testmain
