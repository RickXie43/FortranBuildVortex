!============================================================
!Version:
!  Date            Author              Description
!  ========     ========            ===================
!  10/11/23     Rick            Initialize
!
!============================================================
Program buildvortexmain
        Use build_vortex
        Implicit None
        Character(len=300)::inputdir
        Character(len=300)::outputdir
        Character(len=100)::outputnameshort
        Type(vortexptr), Dimension(1000000, 2)::seriesdata
        Integer::begini,endi
        !Read Commend Argument through String 1 to Argu inputdir
        Call GET_COMMAND_ARGUMENT(1,inputdir)
        !Read Commend Argument through String 2 to Argu outputres
        Call GET_COMMAND_ARGUMENT(2,outputdir)

        !compute outputnameshort
        begini=index(inputdir,'/',Back=.True.)+11
        endi=len(trim(inputdir))
        outputnameshort="VortexSeries"//inputdir(begini:endi)

        Call buildvortex(trim(inputdir), seriesdata, &
                outputdataname=trim(outputdir)//'/'//trim(outputnameshort),outputfiletype=1)
End Program buildvortexmain
