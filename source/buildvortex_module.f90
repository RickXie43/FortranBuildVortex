!============================================================
!Version:
!  Date            Author              Description
!  ========        ========            ===================
!  27/02/23        Rick                Initialize
!  03/04/23        Rick                fix bug: recursive subroutine xc canbe 0, using vorticity to determine the vortex number in a
!  03/04/23        Rick                add Lc as a critical threshold
!  08/04/23        Rick                ficbug of Lc is invalid
!  14/04/23        Rick                use linked list
!  08/05/23        Rick                debug: there is no vortex in someframe because of fail in piv and velocitydata
!  10/08/23        Rick                add cmd parameter inputdir and outputres name
!  17/08/23        Rick                improve the comments of this package
!  17/08/23        Rick                add subroutine buildvortex_vortexvelocity to calculate velocity of each vortex
!  18/08/23        Rick                add subroutine buildvortex_writefielddata to write vortexvelocity
!  13/11/23        Rick                use parameters.f90 to set parameters
!
!============================================================
! Usage:
!               1. set two threshold: Lc, mininterval
!               2. Call subroutine buildvortex
!                       Type(vortexptr), Dimension(1000000, 2)::vortextimeseries
!                       Integer::outputfiletype !outputfiletype=1 to choose timeseries, 2 to choose vector field(default=1)
!                       Call buildvortex(trim(inputdir), vortextimeseries, outputdataname=trim(outputres), outputfiletype)

#include "parameters.f90"

Module build_vortex
        Implicit None
        Save
        Private
        !Lc is the threshold: displacement < Lc * nearest distance
        Real, Parameter::Lc = LC_DEF
        !mininterval is the threshold of minimum vortex lifetime
        Integer, Parameter::mininterval = MININTERVAL_DEF

        Type::vortex
                Real::xc = 0.
                Real::yc = 0.
                Real::vorticity = 0.
                Real::velocity_x = 0.
                Real::velocity_y = 0.
                Real::neardistance = 0.
                Integer::direction = 0
                Integer::time = 0
                Real::maximumvorticity = 0.
                Real::area = 0.
                Type(vortex), Pointer::previous_vortex => Null()
                Type(vortex), Pointer::next_vortex => Null()
                Integer::beginmarker = 1
        End Type vortex

        Type::vortexptr
                Type(vortex), Pointer::p => Null()
        End Type vortexptr

        !Set Public Variable and Routine that canbe used in Program
        Public::buildvortex, vortex, vortexptr

Contains
        Subroutine buildvortex(datadir, vortextimeseries, outputdataname, outputfiletype)
                Implicit None
                !Output parameter
                Character(len=*), Intent(In), Optional::outputdataname
                Integer, Intent(In), Optional::outputfiletype
                !Input parameter
                Character(len=*), Intent(In)::datadir
                !The Beginning Vortex and the ending Vortex in each frame, size(framenumber,2)
                Type(vortex), Dimension(:, :), Allocatable::vortexframeseries
                !The Beginning Vortex Pointer and the ending Vortex Pointer in for each vortex entity
                Type(vortexptr), Dimension(:, :), Intent(InOut)::vortextimeseries
                Integer::vortexamount

                !1.Import all vortex in each frame from files in datadir
                Call buildvortex_readdata(datadir, vortexframeseries)
                !                testtestetes: If (.Not. Associated(vortexframeseries(251, 1)%next_vortex)) Then
                !                        Write (*, *) 'yep!!!!!!!!!!'
                !                Else
                !                        Write (*, *) 'not!!!!!!!!!!'
                !                End If testtestetes

                !2.Build Vortex
                Call buildvortex_build(vortexframeseries, vortextimeseries)

                !3.Delete invalid Vortex series
                Call buildvortex_deletevortex(vortextimeseries, vortexamount)
                Write (*, *) "Vortexamount=", vortexamount

                !4.Calculate vortex velocity, the timeinterval are set to be 1 second, the first and last frame no velocitydata
                Call buildvortex_vortexvelocity(vortextimeseries, vortexamount)

                !5.Writedata to file/vortex linklist
                ifoutputdataname: If (Present(outputdataname)) Then
                        iffiletype: If (Present(outputfiletype)) Then
                                filetypeselect: If (outputfiletype == 1) Then
                                        Call buildvortex_writedatatofile(vortextimeseries, outputdataname, vortexamount)
                                Else if (outputfiletype == 2) Then
                                        Call buildvortex_writefielddata(vortextimeseries, outputdataname, vortexamount)
                                End If filetypeselect
                        Else
                                Call buildvortex_writedatatofile(vortextimeseries, outputdataname, vortexamount)
                        End If iffiletype
                End If ifoutputdataname

        End Subroutine buildvortex

        Subroutine buildvortex_readdata(datadir, vortexframeseries)
                Use Iofortran
                Implicit None
                Character(len=*), Intent(In)::datadir
                Type(vortex), Intent(Out), Dimension(:, :), Allocatable, Target::vortexframeseries
                Integer::filenumbers, i, ierror, j, lines
                Character(len=70), Dimension(10000)::files
                Type(vortex), Pointer::head_vortex => Null()
                Type(vortex), Pointer::tail_vortex => Null()

                !get filenumbers and files
                filenumbers = 0
                lines = 0
                Call iofortran_files(trim(datadir), files, filenumbers)
                Allocate (vortexframeseries(filenumbers, 2))

                inputdata: Do i = 1, filenumbers
                        Open (Unit=78, File=trim(datadir//'/'//files(i)), Status='Old', Iostat=ierror)
                        Call iofortran_filelines(trim(datadir//'/'//files(i)), lines)
                        !read the inconsiquential part of vortexdata
                        Read (78, *)
                        Read (78, *)
                        readfiles: Do j = 1, lines - 2
                        ifnotheadortail: If (j == 1) Then
                                head_vortex => vortexframeseries(i, 1)
                                tail_vortex => vortexframeseries(i, 1)
                                Read (78, *) tail_vortex%xc, tail_vortex%yc,&
                                        &tail_vortex%vorticity, tail_vortex%direction,&
                                        &tail_vortex%time, tail_vortex%neardistance,&
                                        &tail_vortex%maximumvorticity, tail_vortex%area
                                Nullify (tail_vortex%previous_vortex)
                                Nullify (tail_vortex%next_vortex)
                        Else If (j /= lines - 2) Then
                                Allocate (tail_vortex%next_vortex)
                                head_vortex => tail_vortex
                                tail_vortex => tail_vortex%next_vortex
                                Read (78, *) tail_vortex%xc, tail_vortex%yc,&
                                        &tail_vortex%vorticity, tail_vortex%direction,&
                                        &tail_vortex%time, tail_vortex%neardistance,&
                                        &tail_vortex%maximumvorticity, tail_vortex%area
                                tail_vortex%previous_vortex => head_vortex
                                Nullify (tail_vortex%next_vortex)
                        Else
                                Allocate (tail_vortex%next_vortex)
                                head_vortex => tail_vortex
                                tail_vortex => tail_vortex%next_vortex
                                Read (78, *) tail_vortex%xc, tail_vortex%yc,&
                                        &tail_vortex%vorticity, tail_vortex%direction,&
                                        &tail_vortex%time, tail_vortex%neardistance,&
                                        &tail_vortex%maximumvorticity, tail_vortex%area
                                tail_vortex%previous_vortex => head_vortex
                                Nullify (tail_vortex%next_vortex)
                                vortexframeseries(i, 2) = tail_vortex
                        End If ifnotheadortail
                        End Do readfiles
                        Close (Unit=78)
                End Do inputdata
        End Subroutine buildvortex_readdata

        Subroutine buildvortex_build(vortexframeseries, vortextimeseries)
                Implicit None
                Type(vortex), Dimension(:, :), Intent(In), Target::vortexframeseries
                Type(vortexptr), Dimension(:, :), Intent(InOut), Target::vortextimeseries
                Integer::i, seriesnumber
                Type(vortex)::temp
                seriesnumber = 0
                loopforallframe: Do i = 1, size(vortexframeseries(:, 1))
                        temp = vortexframeseries(i, 1)
                        loopinaframe: Do
                        ifnotlastinframe: If (.Not. Associated(temp%next_vortex)) Then
                                Exit loopinaframe
                        End If ifnotlastinframe
                        ifnotbeenset: If (temp%beginmarker == 1) Then
                                seriesnumber = seriesnumber + 1
                                Call findfromvortex(temp, seriesnumber, vortexframeseries, vortextimeseries)
                        End If ifnotbeenset
                        temp = temp%next_vortex
                        !                                IFNAME: If (i == 67 .And. (Abs(temp%xc - 0.0109974) < 0.000001)) Then
                        !                                        Write (*, *) temp%xc
                        !                                End If IFNAME
                        End Do loopinaframe
                        Write (*, *) "Frame", i
                        Write (*, *) "Vortex", seriesnumber
                End Do loopforallframe
        End Subroutine buildvortex_build

        Recursive Subroutine findfromvortex(vortexvalue, seriesnumber, vortexframeseries, vortextimeseries)
                Implicit None
                Type(vortex), Intent(In)::vortexvalue
                Integer, Intent(In)::seriesnumber
                Type(vortex), Dimension(:, :), Intent(In)::vortexframeseries
                Type(vortexptr), Dimension(:, :), Intent(InOut)::vortextimeseries
                Type(vortex)::temp, near_temp
                Real::distance, nearestdistance

                !                IFNAME: If (vortexvalue%time == 67 .And. (Abs(vortexvalue%xc - 0.0109974) < 0.000001)) Then
                !                        Write (*, *) vortexvalue%xc
                !                End If IFNAME

                !Set beginmarker
                ifnotlast: If (Associated(vortexvalue%next_vortex)) Then
                        vortexvalue%next_vortex%previous_vortex%beginmarker = 0
                End If ifnotlast

                !add node to new linked chain
                ifnewseries: If (.Not. Associated(vortextimeseries(seriesnumber, 1)%p)) Then
                        Allocate (vortextimeseries(seriesnumber, 1)%p)
                        vortextimeseries(seriesnumber, 1)%p = vortexvalue
                        vortextimeseries(seriesnumber, 2)%p => vortextimeseries(seriesnumber, 1)%p
                        vortextimeseries(seriesnumber, 1)%p%previous_vortex => Null()
                        vortextimeseries(seriesnumber, 1)%p%next_vortex => Null()
                Else
                        Allocate (vortextimeseries(seriesnumber, 2)%p%next_vortex)
                        !Set new node value
                        vortextimeseries(seriesnumber, 2)%p%next_vortex = vortexvalue
                        vortextimeseries(seriesnumber, 2)%p%next_vortex%previous_vortex => vortextimeseries(seriesnumber, 2)%p
                        vortextimeseries(seriesnumber, 2)%p%next_vortex%next_vortex => Null()
                        !Set new ending
                        vortextimeseries(seriesnumber, 2)%p => vortextimeseries(seriesnumber, 2)%p%next_vortex
                End If ifnewseries

                !if is last frame
                lastframe: If (vortexvalue%time == size(vortexframeseries(:, 1))) Then
                        Return
                End If lastframe

                !if there is no vortex in next time step
                failframe: If (.Not. Associated(vortexframeseries(vortexvalue%time + 1, 1)%next_vortex)) Then
                        Return
                End If failframe

                !do recursive process if find next vortex
                !Find nearest vortex in next frame
                temp = vortexframeseries(vortexvalue%time + 1, 1)
                near_temp = vortexframeseries(vortexvalue%time + 1, 1)
                nearestdistance = 100000
                findnesrestnextvortex: Do
                        temp = temp%next_vortex
                        distance = ((temp%xc - vortexvalue%xc)**2 + (temp%yc - vortexvalue%yc)**2)**0.5
                        nearthan: If (distance < nearestdistance) Then
                                nearestdistance = distance
                                near_temp = temp
                        End If nearthan
                        ifending: If (.Not. Associated(temp%next_vortex)) Then
                                Exit findnesrestnextvortex
                        End If ifending
                End Do findnesrestnextvortex

                !                IFNAME: If (vortexvalue%time == 67 .And. (Abs(vortexvalue%xc - 0.0109974) < 0.000001)) Then
                !                        Write (*, *) nearestdistance
                !                        Write (*, *) vortexvalue%neardistance
                !                        Write (*, *) vortexvalue%direction
                !                        Write (*, *) near_temp%direction
                !                End If IFNAME

                !Judge next vortex, and recursive
                iffoundnewvortexinnextframe: If (nearestdistance < Lc*vortexvalue%neardistance .And.&
                        &vortexvalue%direction == near_temp%direction) Then
                        Call findfromvortex(near_temp, seriesnumber, vortexframeseries, vortextimeseries)
                        !                        IFNAME: If (vortexvalue%time == 67 .And. (Abs(vortexvalue%xc - 0.0109974) < 0.000001)) Then
                        !                                Write (*, *) nearestdistance
                        !                                Write (*, *) vortexvalue%neardistance
                        !                                Write (*, *) vortexvalue%direction
                        !                                Write (*, *) near_temp%direction
                        !                        End If IFNAME
                End If iffoundnewvortexinnextframe
        End Subroutine findfromvortex

        Subroutine buildvortex_deletevortex(vortextimeseries, vortexamount)
                Implicit None
                Type(vortexptr), Dimension(:, :), Intent(InOut)::vortextimeseries
                Integer, Intent(Out)::vortexamount
                Type(vortex), Pointer::temp => Null()

                Integer::i, j
                vortexamount = 0
                i = 1
                looptimeseries: Do
                iflastseries: If (.Not. Associated(vortextimeseries(i, 1)%p)) Then
                        Exit looptimeseries
                End If iflastseries
                temp => vortextimeseries(i, 1)%p
                j = 1
                ifnotlastvortexinaseries: Do
                ifnotlastvise: If (.Not. Associated(temp%next_vortex)) Then
                        longer: If (j >= mininterval) Then
                                vortexamount = vortexamount + 1
                                vortextimeseries(vortexamount, 1)%p => vortextimeseries(i, 1)%p
                                vortextimeseries(vortexamount, 2)%p => vortextimeseries(i, 2)%p
                        End If longer
                        Exit ifnotlastvortexinaseries
                Else
                        j = j + 1
                        temp => temp%next_vortex
                End If ifnotlastvise
                End Do ifnotlastvortexinaseries
                i = i + 1
                End Do looptimeseries
        End Subroutine buildvortex_deletevortex

        !Calculate vortex velocitydata
        Subroutine buildvortex_vortexvelocity(vortextimeseries, vortexamount)
                Implicit None
                Type(vortexptr), Dimension(:, :), Intent(In)::vortextimeseries
                Integer, Intent(In)::vortexamount
                Type(vortex), Pointer::temp => Null()
                Integer::i
                loop1: Do i = 1, vortexamount
                        temp => vortextimeseries(i, 1)%p
                        temp => temp%next_vortex
                        loopinseries: Do
                        ifnotlastvortexi: If (Associated(temp%next_vortex)) Then
                                temp%velocity_x = (temp%next_vortex%xc - temp%previous_vortex%xc)/2
                                temp%velocity_y = (temp%next_vortex%yc - temp%previous_vortex%yc)/2
                        Else
                                Exit loopinseries
                        End If ifnotlastvortexi
                        temp => temp%next_vortex
                        End Do loopinseries
                End Do loop1
        End Subroutine buildvortex_vortexvelocity

        Subroutine buildvortex_writedatatofile(vortextimeseries, outputdataname, vortexamount)
                Implicit None
                Type(vortexptr), Dimension(:, :), Intent(In)::vortextimeseries
                Character(len=*), Intent(In)::outputdataname
                Integer, Intent(In)::vortexamount
                Type(vortex), Pointer::temp => Null()

                Integer::ierror, i, j
                Open (Unit=43, File=outputdataname, Status='New', Iostat=ierror)
                writevortex: Do i = 1, vortexamount
                        Write (43, *) "Vortex No.", i
                        !write vortex begin at vortextimeseries(i, 1)%p
                        temp => vortextimeseries(i, 1)%p
                        writeavortexserie: Do
                                Write (43, "(2F14.7,F20.8,I7,F14.7,F20.8,F20.10)") &
                                        &temp%xc, temp%yc, temp%vorticity, temp%time,&
                                        &temp%neardistance, temp%maximumvorticity, temp%area
                                iflastterm: If (.Not. Associated(temp%next_vortex)) Then
                                        Exit writeavortexserie
                                End If iflastterm
                                temp => temp%next_vortex
                        End Do writeavortexserie
                End Do writevortex
                Close (Unit=43)
        End Subroutine buildvortex_writedatatofile

        !Subroutine to calculate vortex velocitydata and write to dir=outputdataname
        Subroutine buildvortex_writefielddata(vortextimeseries, outputdataname, vortexamount)
                Implicit None
                Type(vortexptr), Dimension(:, :), Intent(In)::vortextimeseries
                Character(len=*), Intent(In)::outputdataname
                Integer, Intent(In)::vortexamount
                Integer::i, frameamount, ierror, j
                Type(vortex), Pointer::temp => Null()
                Character(len=5)::middlestring
                Character(len=80)::fordataname
                !1.mkdir for the result
                Call system('mkdir '//outputdataname)
                !2.loop for all frame to record vortexdata
                !findvortexframenumber
                frameamount = 0
                findframeamount: Do i = 1, Size(vortextimeseries(:, 1))
                        temp => vortextimeseries(i, 1)%p
                        lololo: Do
                        ifexitlololo: If (.Not. Associated(temp)) Then
                                Exit lololo
                        Else
                                iflargeramount: If (temp%time > frameamount) Then
                                        frameamount = temp%time
                                End If iflargeramount
                                temp => temp%next_vortex
                        End If ifexitlololo
                        End Do lololo
                End Do findframeamount

                fordifferentfile: Do i = 1, frameamount
                        Write (middlestring, 100) i
100                     Format(I5.5)
                        fordataname = 'VortexFieldData_'//'B'//middlestring//'.txt'
                        Open (Unit=24, File=outputdataname//'/'//trim(fordataname), Status='New', Iostat=ierror)
                        Write (24, "(A27,100a)") 'The data of Vortex of file ', trim(fordataname)
                        Write (24, "(150a)") 'xc(m) yc(m) vorticity(m*s) direction time(frame) nearest distance(m) maximumvorticity(1/s) &
        &                        velocity_x(m/frame) velocity_y(m/frame)'
                        !3.for each frame, loop for all series and find correspond vortex
                        aaallseries: Do j = 1, vortexamount
                                temp => vortextimeseries(j, 1)%p
                                loopforallseries1: Do
                                ifnotlastvortex2: If (.Not. Associated(temp)) Then
                                        Exit loopforallseries1
                                Else
                                        ifisintheframetime: If (i == temp%time) Then
                                                Write (24, "(2F14.7,F20.8,2I7,F14.7,3F20.8, F20.10)") temp%xc, temp%yc,&
                                                        &temp%vorticity, temp%direction,&
                                                        &temp%time, temp%neardistance,&
                                                        &temp%maximumvorticity, temp%velocity_x, temp%velocity_y,&
                                                        &temp%area
                                                Exit loopforallseries1
                                        End If ifisintheframetime
                                        temp => temp%next_vortex
                                End If ifnotlastvortex2
                                End Do loopforallseries1
                        End Do aaallseries

                        Close (Unit=24)
                End Do fordifferentfile
        End Subroutine buildvortex_writefielddata
End Module build_vortex

!Program testmain
!        Use build_vortex
!        Implicit None
!        Character(len=300)::inputdir
!        Character(len=300)::outputres
!        Type(vortexptr), Dimension(1000000, 2)::or
!        !Read Commend Argument through String 1 to Argu Argu_Name
!        Call GET_COMMAND_ARGUMENT(1,inputdir)
!        !Read Commend Argument through String 2 to Argu
!        Call GET_COMMAND_ARGUMENT(2,outputres)
!        Call buildvortex(trim(inputdir), or, outputdataname=trim(outputres),outputfiletype=1)
!End Program testmain
