@echo off
setlocal enabledelayedexpansion
set SRCFILE=S6313.CAL.TXTd
set OUTPUTFILE=Calendar.ini
set CALENDAR=CALEXPL
set CALENDAR2=%~4
set CALENDAR3=%~5
set CALENDAR4=%~6
set CALENDAR5=%~7
set CALENDAR6=%~8
set CALENDAR7=%~9
set ENDCALENDAR=-
set FLAG=
set NUMLINE=0
set ERRFLAG=0
set WORDSVALUE=false
set SKIPLINE=false
set CHKCALENDAR=false
set TMPFILE=%OUTPUTFILE%.tmp

:Sub_Main
    if not DEFINED SRCFILE (
        echo Erreur : Le chemin du fichier Source n'est pas definie.
        goto :eof
    )
    if not DEFINED OUTPUTFILE (
        echo Erreur : Le chemin du fichier de sortie n'est pas definie.
        goto :eof
    )
    if not DEFINED CALENDAR (
        echo Erreur : Aucun Calendrier n'a ete definie.
        goto :eof
    )
    if not exist %SRCFILE% (
        echo Erreur : Le fichier Source %SRCFILE% est introuvable.
        goto :eof
    )
    if exist %SRCFILE% (
        call :Sub_ChkCalendars 
        call :Sub_Trt_1
        call :Sub_DelTmpFile
    )
goto :eof

:Sub_Trt_1
    for /f "tokens=*" %%a in (%SRCFILE%) do (
        set /a NUMLINE+=1
        set line=%%a
        call :Sub_Calendars
        if DEFINED FLAG (
            set "line=%%a"
            set "line=!line:> =!"
            if exist %TMPFILE% echo !line!>>%TMPFILE%
            if "!line:HIPC=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else if "!line:Modif=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else if "!line:SUNDAY=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else if "!line:SATURDAY=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else if "!line:FRIDAY=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else if "!line:THURSDAY=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else if "!line:WEDNESDA=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else if "!line:TUESDAY=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else if "!line:MONDAY=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else if "!line:-=!" NEQ "!line!" (
                set SKIPLINE=true
            ) else (
                call :Sub_ChkDateFormat
                call :Sub_ChkHolidayWords
            )
            set WORDSVALUE=
        )
        
        if "!line:%ENDCALENDAR%=!" NEQ "!line!" set FLAG=
        if not DEFINED SKIPLINE (
            set SKIPLINE=false
        )
    )
    if %ERRFLAG% EQU 0 (
        if exist %TMPFILE% copy %TMPFILE% %OUTPUTFILE%
        echo Fichier de sortie des calendriers cree avec success.
    )
    if %ERRFLAG% EQU 1 (
        echo %ERRMSG%
    )
goto :eof

:Sub_ChkDateFormat
    set "YEAR=!line:~0,2!"
    set "YYYY=%DATE:~6,2%%YEAR%"
    set /a FEV4=%YEAR% %% 4
    set /a FEV100=%YEAR% %% 100
    set /a FEV400=%YEAR% %% 400
    echo !line! | findstr /r /c:"[0-9][0-9][0-9][0-9][0-9][0-9]" > nul || (
        set ERRFLAG=1
        set ERRMSG=Erreur a la line !NUMLINE!: La ligne ne contient pas une date valide a 6 chiffres. Le fichier n'a pas ete remplace. - !line!
        goto :eof
    )
    if "!line:~4,2!" GTR "31" (
        set ERRFLAG=1
        set ERRMSG=Erreur a la line !NUMLINE!: Les jours du mois ne peuvent pas etre superieur a 31. Le fichier n'a pas ete remplace. - !line!
        goto :eof
    )
    if "!line:~2,2!" GTR "12" (
        set ERRFLAG=1
        set ERRMSG=Erreur a la line !NUMLINE!: Les mois de l'annee ne peuvent pas etre superieur a 12. Le fichier n'a pas ete remplace. - !line!
        goto :eof
    ) else if "!line:~2,2!" EQU "04" (
        if "!line:~4,2!" GTR "30" (
            set ERRFLAG=1
            set ERRMSG=Erreur a la line !NUMLINE!: Le mois d'Avril comporte 30 Jours maximum. Le fichier n'a pas ete remplace. - !line!
            goto :eof
        )
    ) else if "!line:~2,2!" EQU "06" (
        if "!line:~4,2!" GTR "30" (
            set ERRFLAG=1
            set ERRMSG=Erreur a la line !NUMLINE!: Le mois de Juin comporte 30 Jours maximum. Le fichier n'a pas ete remplace. - !line!
            goto :eof
        )
    ) else if "!line:~2,2!" EQU "09" (
        if "!line:~4,2!" GTR "30" (
            set ERRFLAG=1
            set ERRMSG=Erreur a la line !NUMLINE!: Le mois de Septembre comporte 30 Jours maximum. Le fichier n'a pas ete remplace. - !line!
            goto :eof
        )
    ) else if "!line:~2,2!" EQU "11" (
        if "!line:~4,2!" GTR "30" (
            set ERRFLAG=1
            set ERRMSG=Erreur a la line !NUMLINE!: Le mois de Novembre comporte 30 Jours maximum. Le fichier n'a pas ete remplace. - !line!
            goto :eof
        )
    ) else if "!line:~2,2!" EQU "00" (
            set ERRFLAG=1
            set ERRMSG=Erreur a la line !NUMLINE!: Les mois ne peuvent pas avoir une valeur de 00. Le fichier n'a pas ete remplace. - !line!
            goto :eof
    ) else if "!line:~4,2!" EQU "00" (
            set ERRFLAG=1
            set ERRMSG=Erreur a la line !NUMLINE!: Les jours ne peuvent pas avoir une valeur de 00. Le fichier n'a pas ete remplace. - !line!
            goto :eof
    )
    if %FEV4% EQU 0 (
    if %FEV100% NEQ 0 (
        if "!line:~2,2!" EQU "02" (
        if "!line:~4,2!" GTR "29" (
            set ERRFLAG=1
            set ERRMSG=Erreur a la line !NUMLINE! : Le mois de fevrier sur cette annee de %YYYY% comporte 29 Jours maximum. Le fichier n'a pas ete remplace. - !line!
            goto :eof
            )
        )
    ) else (
        if %FEV400% EQU 0 (
        if "!line:~2,2!" EQU "02" (
        if "!line:~4,2!" GTR "29" (
                set ERRFLAG=1
                set ERRMSG=Erreur a la line !NUMLINE! : Le mois de fevrier sur cette annee de %YYYY% comporte 29 Jours maximum. Le fichier n'a pas ete remplace. - !line!
                goto :eof
                )
            )
        ) else (
            if "!line:~2,2!" EQU "02" (
            if "!line:~4,2!" GTR "28" (
                set ERRFLAG=1
                set ERRMSG=Erreur a la line !NUMLINE! : Le mois de fevrier sur cette annee de %YYYY% comporte 28 Jours maximum. Le fichier n'a pas ete remplace. - !line!
                goto :eof
                )
            )
        )
    )
    ) else (
        if "!line:~2,2!" EQU "02" (
        if "!line:~4,2!" GTR "28" (
            set ERRFLAG=1
            set ERRMSG=Erreur a la line !NUMLINE! : Le mois de fevrier sur cette annee de %YYYY% comporte 28 Jours maximum. Le fichier n'a pas ete remplace. - !line!
            goto :eof
            )
        )
    )
goto :eof

:Sub_ChkHolidayWords
    if "!line:FREE=!" NEQ "!line!" set WORDSVALUE=true
    if "!line:WORK=!" NEQ "!line!" set WORDSVALUE=true
    if not DEFINED WORDSVALUE (
        set ERRFLAG=1
        set ERRMSG=Erreur a la line !NUMLINE!: La ligne ne contient pas la valeur FREE ou WORK. Le fichier n'a pas ete remplace.
        goto :eof
    )
goto :eof

:Sub_ChkCalendars
    if DEFINED CALENDAR (
        findstr /C:"%CALENDAR%" "%SRCFILE%" >nul
    )
    if %ERRORLEVEL% NEQ 0 (
        set ERRFLAG=1
        set ERRMSG=Erreur: Le Calendrier %CALENDAR% introuvable dans le fichier %SRCFILE%
        goto :eof
    )
    if DEFINED CALENDAR2 (
        findstr /C:"%CALENDAR2%" "%SRCFILE%" >nul
    )
    if %ERRORLEVEL% NEQ 0 (
        set ERRFLAG=1
        set ERRMSG=Erreur: Le Calendrier %CALENDAR2% introuvable dans le fichier %SRCFILE%
        goto :eof
    )
    if DEFINED CALENDAR3 (
        findstr /C:"%CALENDAR3%" "%SRCFILE%" >nul
    )
    if %ERRORLEVEL% NEQ 0 (
        set ERRFLAG=1
        set ERRMSG=Erreur: Le Calendrier %CALENDAR3% introuvable dans le fichier %SRCFILE%
        goto :eof
    )
    if DEFINED CALENDAR4 (
        findstr /C:"%CALENDAR4%" "%SRCFILE%" >nul
    )
    if %ERRORLEVEL% NEQ 0 (
        set ERRFLAG=1
        set ERRMSG=Erreur: Le Calendrier %CALENDAR4% introuvable dans le fichier %SRCFILE%
        goto :eof
    )
    if DEFINED CALENDAR5 (
        findstr /C:"%CALENDAR5%" "%SRCFILE%" >nul
    )
    if %ERRORLEVEL% NEQ 0 (
        set ERRFLAG=1
        set ERRMSG=Erreur: Le Calendrier %CALENDAR5% introuvable dans le fichier %SRCFILE%
        goto :eof
    )
    if DEFINED CALENDAR6 (
        findstr /C:"%CALENDAR6%" "%SRCFILE%" >nul
    )
    if %ERRORLEVEL% NEQ 0 (
        set ERRFLAG=1
        set ERRMSG=Erreur: Le Calendrier %CALENDAR6% introuvable dans le fichier %SRCFILE%
        goto :eof
    )
    if DEFINED CALENDAR7 (
        findstr /C:"%CALENDAR7%" "%SRCFILE%" >nul
    )
    if %ERRORLEVEL% NEQ 0 (
        set ERRFLAG=1
        set ERRMSG=Erreur: Le Calendrier %CALENDAR7% introuvable dans le fichier %SRCFILE%
        goto :eof
    )
goto :eof

:Sub_Calendars
    if DEFINED CALENDAR (
        if "!line:%CALENDAR%=!" NEQ "!line!" set FLAG=true
    )
    if DEFINED CALENDAR2 (
        if "!line:%CALENDAR2%=!" NEQ "!line!" set FLAG=true
    )
    if DEFINED CALENDAR3 (
        if "!line:%CALENDAR3%=!" NEQ "!line!" set FLAG=true
    )
    if DEFINED CALENDAR4 (
        if "!line:%CALENDAR4%=!" NEQ "!line!" set FLAG=true
    )
    if DEFINED CALENDAR5 (
        if "!line:%CALENDAR5%=!" NEQ "!line!" set FLAG=true
    )
    if DEFINED CALENDAR6 (
        if "!line:%CALENDAR6%=!" NEQ "!line!" set FLAG=true
    )
    if DEFINED CALENDAR7 (
        if "!line:%CALENDAR7%=!" NEQ "!line!" set FLAG=true
    )
goto :eof

:Sub_DelTmpFile
    if exist %TMPFILE% del %TMPFILE% /q
goto :eof