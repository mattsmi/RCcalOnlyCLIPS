;####################################################################################
;;;;;; To print out the facts, use: (printout t (facts) crlf) .
;;;    To save facts to a file, use: (save-facts "harry.clp") .
;;;     (do-for-all-facts ((?m RCcalThisYear)) (neq ?m:Date_this_year nil) (printout t (unmakeDate ?m:Date_this_year) " : " ?m:TypeIndex crlf))

;;; These rules are from the second section of the Table of Liturgical Days
;;; These must all fire after earlier, higher-ranking feasts have been given a date.
(defrule p250aFeastBaptismOfTheLord
    (declare (salience ?*highest-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&~nil)
                         (TypeIndex ?fTypeIndex&:(eq ?fTypeIndex "VAR034")))
    ?f2 <- (CalendarFact (Date_this_year ?f2Date_this_year&nil)
                         (TypeIndex ?f2TypeIndex&:(eq ?f2TypeIndex "VAR001")))
    ?f3 <- (CalendarFact (Date_this_year ?f3Date_this_year&nil)
                         (TypeIndex ?f3TypeIndex&:(eq ?f3TypeIndex "ORW01D2")))
    =>
    ;Usually the Sunday after the Epiphany or 6 January, unless the Epiphany is on Sunday 7 or 8 January,
    ;   then it falls on the following Monday (cf. Calendarium Romanum (Libreria Editrice Vaticana 1969), pp. 61 and 112).
    (if (or (eq ?fDate_this_year (mkDate ?*yearSought* 1 7)) (eq ?fDate_this_year (mkDate ?*yearSought* 1 8))) then
        (bind ?iTemp (daysAdd ?fDate_this_year 1))
        ;Now remove the Monday of the first week of Ordinary Time
        (retract ?f3)
    else
        (if (eq (DoW ?fDate_this_year) 7) then
            (bind ?iTemp (clFindSun (daysAdd ?fDate_this_year 1) (daysAdd ?fDate_this_year 8)))
        else
            (bind ?iTemp (clFindSun ?fDate_this_year (daysAdd ?fDate_this_year 7)))
        )
    )
    (modify ?f2 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex "VAR001") (TableLitDayRank 2500)))
)
(defrule p250bFeastHolyFamily
    (declare (salience ?*highest-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (TypeIndex ?fTypeIndex&:(eq ?fTypeIndex "VAR025")))
    =>
    ;This feast is celebrated on the Sunday within the Octave of Christmas, if one exists;
    ;   otherwise on 30 December.

    ;Check whether a Sunday exists
    (bind ?iTemp (clFindSun (mkDate ?*yearSought* 12 26) (mkDate ?*yearSought* 12 31)))
    (if (eq ?iTemp nil) then
        (bind ?iTemp (mkDate ?*yearSought* 12 30))
    )

    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 2500)))
)
(defrule p250FeastsOfTheLordGeneral
    (declare (salience ?*higher-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (CalType ?fCalType&:(eq ?fCalType ?*GENERAL_ROMAN_CALENDAR*))
                         (Rank ?fRank&:(eq ?fRank "Feast"))
                         (Lit_rank ?fLit_rank&:(eq ?fLit_rank 5))
                         (Day ?fDay)
                         (Month ?fMonth)
                         (DaysFromEaster ?fDaysFromEaster)
                         (TypeIndex ?fTypeIndex))
    =>
    (if (neq ?fDaysFromEaster nil) then
        (if (not (integerp ?fDaysFromEaster)) then
            (bind ?iDays (string-to-integer ?fDaysFromEaster))
        else
            (bind ?iDays ?fDaysFromEaster)
        )
        (bind ?iTemp (daysAdd ?*easter* ?iDays))
    else
        (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
    )
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 2500)))
)
(defrule p261SundaysOfChristmasTide
    (declare (salience ?*higher-priority*))
    (phase-03-minorFeasts)
    ?f0 <- (CalendarFact (Date_this_year ?f0Date_this_year&~nil)
                         (TypeIndex ?f0TypeIndex&:(eq ?f0TypeIndex "VAR034")))
    ?f1 <- (CalendarFact (Date_this_year ?f1Date_this_year&nil)
                         (TypeIndex ?f1TypeIndex&:(eq ?f1TypeIndex "VAR027"))
           )
    =>
    ;;This is for the Second Sunday of Christmas, occuring between 2 and 5 January.
    ;;The other Sundays of Christmastide have already been set.
    ;Check whether a Sunday exists
    (bind ?iTemp (clFindSun (mkDate ?*yearSought* 1 2) (mkDate ?*yearSought* 1 5)))
    (if (eq ?iTemp nil) then
        ;The Second Sunday of Christmas does not occur this year
        (retract ?f1)
    else
        (modify ?f1 (Date_this_year ?iTemp))
        (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?f1TypeIndex) (TableLitDayRank 2610)))
    )
)
(defrule p262aSecondSundayOfOrdinaryTime
    (declare (salience ?*highest-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (TypeIndex ?fTypeIndex&:(eq ?fTypeIndex "ORW02D1")))
    ?f2 <- (CalendarFact (Date_this_year ?f2Date_this_year&~nil)
                         (TypeIndex ?f2TypeIndex&:(eq ?f2TypeIndex "VAR001")))
    =>
    ;As the Baptism of the Lord may be a Monday, we need to find the next Sunday after it,
    ;  not just add seven days, assuming the Feast of the Baptism of the Lord occurs on a Sunday.
    (bind ?iTemp (clFindSun (daysAdd ?f2Date_this_year 1) (daysAdd ?f2Date_this_year 7)))
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 2620)))

    ;Create global for the nominal first Sunday of Ordinary Time, although this Sunday does not in fact exist.
    ;(undefglobal FirstSunOrdinaryTime)
    (bind ?sTemp "(defglobal ?*FirstSunOrdinaryTime* = ")
    (bind ?sTemp (str-cat ?sTemp (daysAdd ?iTemp -7) ")"))
    (eval (build ?sTemp))
)
(defrule p262bFirstOrdinarySundayOfTheYear
    (declare (salience ?*highest-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
            (TypeIndex ?f1TypeIndex&:(eq ?f1TypeIndex "ORW01D1"))
           )
    =>
    ;The first Sunday of the year is either the Baptism of the Lord, or the Epiphany, if that is
    ;   celebrated on the Sunday between 2 and 8 Jan.
    (retract ?f1)
)
(defrule p262cLastOrdinarySundayOfTheYear
    (declare (salience ?*highest-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
            (TypeIndex ?f1TypeIndex&:(eq ?f1TypeIndex "ORW34D1"))
           )
    =>
    ;The last Sunday of the year is now known as Christ the King.
    (retract ?f1)
)
(defrule p262eOrdinarySundays
    (declare (salience ?*higher-priority*))
    (phase-03-minorFeasts)
    ?f0 <- (CalendarFact (Date_this_year ?f0Date_this_year&~nil)
                         (TypeIndex ?f0TypeIndex&:(eq ?f0TypeIndex "ORW02D1")))
    ?f2 <- (CalendarFact (Date_this_year ?f2Date_this_year&~nil)
                         (TypeIndex ?f2TypeIndex&:(eq ?f2TypeIndex "VAR002")))
    ?f3 <- (CalendarFact (Date_this_year ?f3Date_this_year&~nil)
                         (TypeIndex ?f3TypeIndex&:(eq ?f3TypeIndex "MOV001")))
    ?f4 <- (CalendarFact (Date_this_year ?f4Date_this_year&~nil)
                         (TypeIndex ?f4TypeIndex&:(eq ?f4TypeIndex "MOV096")))
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (TypeIndex ?fTypeIndex&:(and (eq (sub-string 1 3 ?fTypeIndex) "ORW") (eq (sub-string 6 7 ?fTypeIndex) "D1"))))
    =>
    ;ORW02D1 = 2nd Sun of Ordinary Time. VAR002 = Christ the King. MOV001 = Ash Wednesday
    (bind ?iTemp (sub-string 4 5 ?fTypeIndex))
    (if (not (integerp ?iTemp)) then
        ;Get the integer value of the digits found in the TypeIndex string.
        (bind ?iTemp (string-to-integer ?iTemp))
    )
    ;Determine date using multiplier
    (bind ?iDate (daysAdd ?f0Date_this_year (* (- ?iTemp 2) 7)))

    (if (< ?iDate ?f3Date_this_year) then
        ;Date before Ash Wednesday
        (modify ?f1 (Date_this_year ?iDate))
        (assert (RCcalThisYear (Date_this_year ?iDate) (TypeIndex ?fTypeIndex) (TableLitDayRank 2620)))
    else
        ;Work backwards from the end of the year
        (bind ?iTemp (sub-string 4 5 ?fTypeIndex))
        (if (not (integerp ?iTemp)) then
            ;Get the integer value of the digits found in the TypeIndex string.
            (bind ?iTemp (string-to-integer ?iTemp))
        )
        ;Determine date using multiplier
        (bind ?iDate (daysAdd ?f2Date_this_year (* (- 34 ?iTemp) -7)))
        (if (> ?iDate ?f4Date_this_year) then
            (modify ?f1 (Date_this_year ?iDate))
            (assert (RCcalThisYear (Date_this_year ?iDate) (TypeIndex ?fTypeIndex) (TableLitDayRank 2620)))
        else
            ;The Sunday is not in use this year
            (retract ?f1)
        )
    )

)
(defrule p270OtherFeastsGeneral
    (declare (salience ?*high-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (CalType ?fCalType&:(eq ?fCalType ?*GENERAL_ROMAN_CALENDAR*))
                         (Rank ?fRank&:(eq ?fRank "Feast"))
                         (Lit_rank ?fLit_rank&:(neq ?fLit_rank 5))
                         (Day ?fDay)
                         (Month ?fMonth)
                         (DaysFromEaster ?fDaysFromEaster)
                         (TypeIndex ?fTypeIndex))
    =>
    (if (neq ?fDaysFromEaster nil) then
        (if (not (integerp ?fDaysFromEaster)) then
            (bind ?iDays (string-to-integer ?fDaysFromEaster))
        else
            (bind ?iDays ?fDaysFromEaster)
        )
        (bind ?iTemp (daysAdd ?*easter* ?iDays))
    else
        (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
    )
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 2700)))
)
(defrule p280OtherFeastsLocal
    (declare (salience ?*high-priority*))
    (phase-03-minorFeasts)
    (test (member$ calendarInUse (get-defglobal-list)))
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (CalType ?fCalType&:(eq ?fCalType ?*calendarInUse*))
                         (Rank ?fRank&:(eq ?fRank "Feast"))
                         (Lit_rank ?fLit_rank&:(neq ?fLit_rank 5))
                         (Day ?fDay)
                         (Month ?fMonth)
                         (DaysFromEaster ?fDaysFromEaster)
                         (TypeIndex ?fTypeIndex))
    =>
    (if (neq ?fDaysFromEaster nil) then
        (if (not (integerp ?fDaysFromEaster)) then
            (bind ?iDays (string-to-integer ?fDaysFromEaster))
        else
            (bind ?iDays ?fDaysFromEaster)
        )
        (bind ?iTemp (daysAdd ?*easter* ?iDays))
    else
        (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
    )
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 2800)))
)
(defrule p291WeekdaysOfLateAdvent
    (declare (salience ?*med-high-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                (Day ?fDay&~nil)
                (Month ?fMonth&~nil)
               (TypeIndex ?fTypeIndex&:(>= (str-compare ?fTypeIndex "ENSUS32") 0)&:(<= (str-compare ?fTypeIndex "ENSUS39") 0)))
    =>
    (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
    (if (< (DoW ?iTemp) 7) then
        (modify ?f1 (Date_this_year ?iTemp))
        (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 2910)))
    )
)
(defrule p292DaysWithinOctaveOfChristmas
    (declare (salience ?*med-high-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                (Day ?fDay)
                (Month ?fMonth)
               (TypeIndex ?fTypeIndex&:(>= (str-compare ?fTypeIndex "FIX361") 0)&:(<= (str-compare ?fTypeIndex "FIX366") 0)))
    =>
    (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
    (if (< (DoW ?iTemp) 7) then
        (modify ?f1 (Date_this_year ?iTemp))
        (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 2920)))
    else
        ;This Sunday is already present in the Sundays of Advent
        (retract ?f1)
    )
)
(defrule p293WeekdaysOfLent
    (declare (salience ?*med-high-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
            (DaysFromEaster ?fDaysFromEaster)
            (TypeIndex ?fTypeIndex&:(>= (str-compare ?fTypeIndex "MOV002") 0)&:(<= (str-compare ?fTypeIndex "MOV039") 0)))
    =>
    (if (not (integerp ?fDaysFromEaster)) then
        (bind ?iDays (string-to-integer ?fDaysFromEaster))
    else
        (bind ?iDays ?fDaysFromEaster)
    )
    (bind ?iTemp (daysAdd ?*easter* ?iDays))
    ;Sundays have already been treated, so their Date_this_year will not be nil.
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 2930)))
)
(defrule p3A0ObligatoryMemorias
    (declare (salience ?*medium-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (CalType ?fCalType&:(eq ?fCalType ?*GENERAL_ROMAN_CALENDAR*))
                         (Rank ?fRank&:(eq ?fRank "Memoria"))
                         (Day ?fDay)
                         (Month ?fMonth)
                         (DaysFromEaster ?fDaysFromEaster)
                         (TypeIndex ?fTypeIndex))
    =>
    (if (neq ?fDaysFromEaster nil) then
        (if (not (integerp ?fDaysFromEaster)) then
            (bind ?iDays (string-to-integer ?fDaysFromEaster))
        else
            (bind ?iDays ?fDaysFromEaster)
        )
        (bind ?iTemp (daysAdd ?*easter* ?iDays))
    else
        (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
    )
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 3100)))
)
(defrule p3B0ObligatoryMemoriasLocal
    (declare (salience ?*normal-priority*))
    (phase-03-minorFeasts)
    (test (member$ calendarInUse (get-defglobal-list)))
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (CalType ?fCalType&:(eq ?fCalType ?*calendarInUse*))
                         (Rank ?fRank&:(eq ?fRank "Memoria"))
                         (Day ?fDay)
                         (Month ?fMonth)
                         (DaysFromEaster ?fDaysFromEaster)
                         (TypeIndex ?fTypeIndex))
    =>
    (if (neq ?fDaysFromEaster nil) then
        (if (not (integerp ?fDaysFromEaster)) then
            (bind ?iDays (string-to-integer ?fDaysFromEaster))
        else
            (bind ?iDays ?fDaysFromEaster)
        )
        (bind ?iTemp (daysAdd ?*easter* ?iDays))
    else
        (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
    )
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 3110)))
)
(defrule p3C0OOptionalMemorias
    (declare (salience ?*medium-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (CalType ?fCalType&:(eq ?fCalType ?*GENERAL_ROMAN_CALENDAR*))
                         (Rank ?fRank&:(eq ?fRank "Optional Memoria"))
                         (Day ?fDay)
                         (Month ?fMonth)
                         (DaysFromEaster ?fDaysFromEaster)
                         (TypeIndex ?fTypeIndex))
    =>
    (if (neq ?fTypeIndex "MOV116") then
        ;Special later rule for "MOV116"
        (if (neq ?fDaysFromEaster nil) then
            (if (not (integerp ?fDaysFromEaster)) then
                (bind ?iDays (string-to-integer ?fDaysFromEaster))
            else
                (bind ?iDays ?fDaysFromEaster)
            )
            (bind ?iTemp (daysAdd ?*easter* ?iDays))
        else
            (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
        )
        (modify ?f1 (Date_this_year ?iTemp))
        (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 3120)))
    )
)
(defrule p3C0OptionalMemoriasLocal
    (declare (salience ?*normal-priority*))
    (phase-03-minorFeasts)
    (test (member$ calendarInUse (get-defglobal-list)))
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                         (CalType ?fCalType&:(eq ?fCalType ?*calendarInUse*))
                         (Rank ?fRank&:(eq ?fRank "Optional Memoria"))
                         (Day ?fDay)
                         (Month ?fMonth)
                         (DaysFromEaster ?fDaysFromEaster)
                         (TypeIndex ?fTypeIndex))
    =>
    (if (neq ?fDaysFromEaster nil) then
        (if (not (integerp ?fDaysFromEaster)) then
            (bind ?iDays (string-to-integer ?fDaysFromEaster))
        else
            (bind ?iDays ?fDaysFromEaster)
        )
        (bind ?iTemp (daysAdd ?*easter* ?iDays))
    else
        (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
    )
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 3120)))
    ;Same TableLitDayRank for General and Local Optional Memorias. cf. UNLY&GRC, n. 12.
)
(defrule p3D0WeekdaysOfAdvent
    (declare (salience ?*lowish-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                (TypeIndex ?fTypeIndex&:(> (str-compare ?fTypeIndex "VAR003") 0)&:(< (str-compare ?fTypeIndex "VAR024") 0))
           )
    =>
    ;For weekdays of Advent until 16 December inclusive.
    ;  Sundays and those days from 17 December onwards have already been declared, so their dates will not be nil.
    (bind ?iDays (sub-string 4 6 ?fTypeIndex))
    (if (not (integerp ?iDays)) then
        (bind ?iDays (string-to-integer ?iDays))
    )
    (bind ?iDays (- ?iDays 3))
    (bind ?iTemp (daysAdd ?*firstSundayAdvent* ?iDays))
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 3131)))
)
(defrule p3D1WeekdaysOfChristmastide
    (declare (salience ?*med-low-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                (TypeIndex ?fTypeIndex&:(> (str-compare ?fTypeIndex "FIX001") 0)&:(< (str-compare ?fTypeIndex "FIX015") 0))
                (Day ?fDay)
                (Month ?fMonth)
           )
    ?f2 <- (CalendarFact (Date_this_year ?f2Date_this_year&~nil)
                    (TypeIndex ?f2TypeIndex&:(eq ?f2TypeIndex "VAR034"))
           )
    ?f3 <- (CalendarFact (Date_this_year ?f3Date_this_year&~nil)
                    (TypeIndex ?f3TypeIndex&:(eq ?f3TypeIndex "VAR001"))
           )
    =>
    (bind ?iTemp (mkDate ?*yearSought* ?fMonth ?fDay))
    (if (< ?iTemp ?f3Date_this_year) then
        (modify ?f1 (Date_this_year ?iTemp))
        (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 3132)))
    )
)
(defrule p3D2WeekdaysOfEastertide
    (declare (salience ?*med-low-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                (TypeIndex ?fTypeIndex&:(> (str-compare ?fTypeIndex "MOV054") 0)&:(< (str-compare ?fTypeIndex "MOV096") 0))
                (DaysFromEaster ?fDaysFromEaster)
           )
    =>
    (bind ?iTemp (daysAdd ?*easter* ?fDaysFromEaster))
    (modify ?f1 (Date_this_year ?iTemp))
    (assert (RCcalThisYear (Date_this_year ?iTemp) (TypeIndex ?fTypeIndex) (TableLitDayRank 3133)))
)
(defrule p3D3OrdinaryWeekdays
    (declare (salience ?*low-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (CalendarFact (Date_this_year ?fDate_this_year&nil)
                (TypeIndex ?fTypeIndex&:(> (str-compare ?fTypeIndex "ORW01D1") 0)&:(<= (str-compare ?fTypeIndex "ORW34D7") 0))
                (Day ?fDay)
                (Month ?fMonth)
           )
    ?f2 <- (CalendarFact (Date_this_year ?f2Date_this_year&~nil)
                         (TypeIndex ?f2TypeIndex&:(eq ?f2TypeIndex "VAR001")))
    ?f3 <- (CalendarFact (Date_this_year ?f3Date_this_year&~nil)
                         (TypeIndex ?f3TypeIndex&:(eq ?f3TypeIndex "MOV001")))
    ?f4 <- (CalendarFact (Date_this_year ?f4Date_this_year&~nil)
                         (TypeIndex ?f4TypeIndex&:(eq ?f4TypeIndex "MOV096")))
    =>
    ;Determine the week
    (bind ?iTemp (sub-string 4 5 ?fTypeIndex))
    (if (not (integerp ?iTemp)) then
        ;Get the integer value of the digits found in the TypeIndex string.
        (bind ?iTemp (string-to-integer ?iTemp))
    )
    ;Determine date using multiplier for the week
    (bind ?iDate (daysAdd ?f2Date_this_year (* (- ?iTemp 1) 7)))
    ;Determine the day of week of the Baptism of the Lord
    (bind ?iDoWbaptism (DoW ?f2Date_this_year))
    (if (= ?iDoWbaptism 1) then
        ;Baptism can only be a Sunday (7), or a Monday (1)
        (bind ?iDate (daysAdd ?iDate -1))
    )

    ;Day of week of day sought
    (bind ?iDoW (sub-string 7 7 ?fTypeIndex))
    (if (not (integerp ?iDoW)) then
        ;Get the integer value of the digits found in the TypeIndex string.
        (bind ?iDoW (string-to-integer ?iDoW))
    )
    ;Convert Roman day of the week (Sunday = 1) to computer dates (Sunday = 7)
    (bind ?iDoW (+ ?iDoW 6))
    (if (> ?iDoW 7) then
        (bind ?iDoW (- ?iDoW 7))
    )
    ;Calculate the date
    (bind ?iDate (daysAdd ?iDate ?iDoW))
    ;In the case of the Baptism of the Lord being a Monday, remove that Ordinary day of the week
    (if (= ?iDate ?f2Date_this_year) then
        (retract ?f1)
    )

    (if (< ?iDate ?f3Date_this_year) then
        ;Dates before Ash Wednesday
        (modify ?f1 (Date_this_year ?iDate))
        (assert (RCcalThisYear (Date_this_year ?iDate) (TypeIndex ?fTypeIndex) (TableLitDayRank 3134)))
    else
        ;Work backwards from the end of the year
        ;Determine date using multiplier
        (bind ?iDate (daysAdd ?*firstSundayAdvent* (* (- 35 ?iTemp) -7)))
        ;Calculate the date
        (bind ?iDate (daysAdd ?iDate ?iDoW))
        (if (> ?iDate ?f4Date_this_year) then
            (modify ?f1 (Date_this_year ?iDate))
            (assert (RCcalThisYear (Date_this_year ?iDate) (TypeIndex ?fTypeIndex) (TableLitDayRank 3134)))
        else
            ;The weekday is not in use this year
            (retract ?f1)
        )
    )
)
;;;Tidy-up rules
(defrule pSaturdayOptionalMemoriaBVM
    (declare (salience ?*lower-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (RCcalThisYear (Date_this_year ?f1Date_this_year&~nil)
                    (TypeIndex ?f1TypeIndex)
                    (OptMemBVM ?f1OptMemBVM&nil)
           )
    ?f2 <- (CalendarFact (Date_this_year ?f2Date_this_year&~nil)
                    (TypeIndex ?f2TypeIndex&:(eq ?f2TypeIndex ?f1TypeIndex))
                    (Rank ?f2Rank)
                    (Lit_rank ?f2Lit_rank)
            )
    ?f3 <- (CalendarFact (Date_this_year ?f3Date_this_year&~nil)
                    (TypeIndex ?f3TypeIndex&:(eq ?f3TypeIndex "VAR001"))
           )
    ?f4 <- (CalendarFact (Date_this_year ?f4Date_this_year&~nil)
                    (TypeIndex ?f4TypeIndex&:(eq ?f4TypeIndex "MOV001"))
           )
    ?f5 <- (CalendarFact (Date_this_year ?f5Date_this_year&~nil)
                    (TypeIndex ?f5TypeIndex&:(eq ?f5TypeIndex "MOV096"))
           )
    ?f6 <- (CalendarFact (Date_this_year ?f6Date_this_year&~nil)
                    (TypeIndex ?f6TypeIndex&:(eq ?f6TypeIndex "VAR003"))
           )
    =>
    ;Cf. GNLY, n. 15. Ordinary Saturdays otherwise unencumbered by anything greater than an Optional Memorial.
    (if (eq ?f2Lit_rank nil) then
        (bind ?iLit_rank 14)
    else
        (bind ?iLit_rank ?f2Lit_rank)
        (if (not (integerp ?iLit_rank)) then
            (bind ?iLit_rank (string-to-integer ?iLit_rank))
        )
     )

    (if (= (DoW ?f1Date_this_year) 6) then
        (if (> ?iLit_rank 11) then
            ;Optional Memoria or weekday of Advent I, Christmastide, Eastertide, or Ordinary Time
            (if (or (and (> ?f1Date_this_year ?f3Date_this_year) (< ?f1Date_this_year ?f4Date_this_year)) (and (> ?f1Date_this_year ?f5Date_this_year) (< ?f1Date_this_year ?f6Date_this_year))) then
                ;If within the first or second period of Ordinary Time.
                ;We now have a Saturday in ordinary time with now occurring feast, other than a possible Optional Memoria
                (modify ?f1 (OptMemBVM TRUE))
            else
                (modify ?f1 (OptMemBVM FALSE))
             )
        else
            (modify ?f1 (OptMemBVM FALSE))
         )
    else
        (modify ?f1 (OptMemBVM FALSE))
    )
)
(defrule pDoCurrentCycle
    (declare (salience ?*lower-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (RCcalThisYear (Date_this_year ?f1Date_this_year&~nil)
                    (TypeIndex ?f1TypeIndex)
                    (CurrentCycle ?f1CurrentCycle&nil)
                    (TableLitDayRank ?f1TableLitDayRank)
           )
    ?f2 <- (CalendarFact (Date_this_year ?f2Date_this_year&~nil)
                    (TypeIndex ?f2TypeIndex&:(eq ?f2TypeIndex ?f1TypeIndex))
                    (Rank ?f2Rank)
                    (Lit_rank ?f2Lit_rank)
            )
    ?f3 <- (CalendarFact (Date_this_year ?f3Date_this_year&~nil&:(= ?f3Date_this_year ?f1Date_this_year))
                    (TypeIndex ?f3TypeIndex&:(neq ?f3TypeIndex ?f1TypeIndex)&:(or (eq (sub-string 1 3 ?f3TypeIndex) "MOV") (eq (sub-string 1 3 ?f3TypeIndex) "ORW")))
                    (Rank ?f3Rank)
                    (Lit_rank ?f3Lit_rank)
            )
    =>
    (if (eq ?f2Lit_rank nil) then
        (bind ?iLit_rank 14)
    else
        (bind ?iLit_rank ?f2Lit_rank)
        (if (not (integerp ?iLit_rank)) then
            (bind ?iLit_rank (string-to-integer ?iLit_rank))
        )
    )

    ;Quick check for MOV116
    (if (and (= ?f1Date_this_year (daysAdd ?*easter* 69)) (= ?f1TableLitDayRank 3100) (neq ?f1TypeIndex "MOV116")) then
        ;We have a Memoria on the same date as MOV116
        (printout t "HIIII: " ?f1TypeIndex crlf)
        (if (neq (sub-string 1 3 ?f1TypeIndex) "ORW") then
            ;If the main TypeIndex is "ORW*", then we already know the cycle.
            (modify ?f1 (TypeIndex ?f3TypeIndex) (Optional1 ?f1TypeIndex) (Optional2 "MOV116") (CurrentCycle ?f3TypeIndex))
        else
            (modify ?f1 (TypeIndex ?f1TypeIndex) (Optional1 ?f3TypeIndex) (Optional2 "MOV116") (CurrentCycle ?f1TypeIndex))
        )
    else
        ;(if (= ?f1Date_this_year (daysAdd ?*easter* 69)) then
        ;    ;MOV116 not classing with another Memoria, so assert it and let the rules work it out.
        ;    (assert (RCcalThisYear (Date_this_year ?f1Date_this_year) (TypeIndex "MOV116") (TableLitDayRank 3120)))
        ;else
            ;Memorias and Optional Memorias use readings from the weekday, unless proper readings exist (GIRM, n. 357).
            (if (and (>= ?iLit_rank 10) (<= ?iLit_rank 12)) then
                (if (neq (sub-string 1 3 ?f1TypeIndex) "ORW") then
                    ;If the main TypeIndex is "ORW*", then we already know the cycle.
                    (modify ?f1 (CurrentCycle ?f3TypeIndex))
                else
                    (modify ?f1 (CurrentCycle ?f1TypeIndex))
                )
            )
        ;)
    )


)
(defrule pDoYearlyReadingsCycle
    (declare (salience ?*lower-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (RCcalThisYear (Date_this_year ?f1Date_this_year&~nil)
                        (SundayMassReadingsCycle ?f1SundayMassReadingsCycle&nil)
                        (WeekdayMassReadingsCycle ?f1WeekdayMassReadingsCycle&nil)
            )
    =>

    ;Find First Sunday of Advent for Previous Year.
    (bind ?iTempStart (daysAdd (clFindSun (mkDate (- ?*yearSought* 1) 12 18) (mkDate (- ?*yearSought* 1) 12 24)) -21))
    ;Weekday cycle
    (bind ?iTempWeekday (mod ?*yearSought* 2))
    (if (= ?iTempWeekday 0) then
        (bind ?iTempWeekday 2)
    )
    ;Sunday Cycle
    (bind ?iTempSunday (mod ?*yearSought* 3))
    (if (= ?iTempSunday 0) then
        (bind ?iTempSunday 3)
    )
    (if (= ?iTempSunday 1) then
        (bind ?sTempSunday "A")
    else
        (if (= ?iTempSunday 2) then
            (bind ?sTempSunday "B")
        else
            (bind ?sTempSunday "C")
        )
    )

    ;We set these values for each day of the year. This will cover any situation,
    ;   where a celebration is raised locally to the level of Solemnity, for example, and
    ;   and thus may need to know the Sunday cycle. Sundays and festive days have a three-year cycle.
    ;  From GIRM, n. 357: For Memorials of Saints, unless proper readings are given, the
    ;  readings assigned for the weekday are normally used
    (if (and (> ?f1Date_this_year ?iTempStart) (< ?f1Date_this_year ?*firstSundayAdvent*)) then
        ;For those dates before the First Sunday of Advent towards the end of the current calendar year.
        (modify ?f1 (SundayMassReadingsCycle ?sTempSunday) (WeekdayMassReadingsCycle ?iTempWeekday))
        ;Assert a Yearly Cycle fact for later use. Do this just once for the calendar year
        (if (= ?f1Date_this_year (mkDate ?*yearSought* 1 1)) then
            (assert (YearlyCycle (Year ?*yearSought*) (CycleStarts ?iTempStart) (SundayCycle ?sTempSunday) (WeekdayCycle ?iTempWeekday)))
        )
    else
        ;For those dates at the end of the year, after the First Sunday of Advent (inclusive).
        (bind ?iTempWeekday (+ ?iTempWeekday 1))
        (if (= ?iTempWeekday 3) then
            (bind ?iTempWeekday 1)
        )
        (bind ?iTempSunday (+ ?iTempSunday 1))
        (if (= ?iTempSunday 4) then
            (bind ?iTempSunday 1)
        )
        (if (= ?iTempSunday 1) then
            (bind ?sTempSunday "A")
        else
            (if (= ?iTempSunday 2) then
                (bind ?sTempSunday "B")
            else
                (bind ?sTempSunday "C")
            )
        )
        (modify ?f1 (SundayMassReadingsCycle ?sTempSunday) (WeekdayMassReadingsCycle ?iTempWeekday))
        ;Assert a Yearly Cycle fact for later use. Do this just once for the calendar year
        (if (= ?f1Date_this_year ?*firstSundayAdvent*) then
            (assert (YearlyCycle (Year (+ ?*yearSought* 1)) (CycleStarts ?*firstSundayAdvent*) (SundayCycle ?sTempSunday) (WeekdayCycle ?iTempWeekday)))
        )
    )

)
(defrule convertDatesToTextAndEDM
    (declare (salience ?*lower-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (RCcalThisYear (Date_this_year ?f1Date_this_year&~nil)
                    (Date_ISO8601 ?f1Date_ISO8601&nil)
           )
    =>
    ;This is only required for readability.
    ; Delete rule, if not required.
    (modify ?f1 (Date_ISO8601 (unmakeDate ?f1Date_this_year)) (EDM ?*requestedEDM*))
)
(defrule rLocalCalendarChosenForInterpretingTheYear
    (declare (salience ?*lower-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (RCcalThisYear (Date_this_year ?f1Date_this_year&~nil)
                    (ForWhichCal ?f1ForWhichCal&nil)
           )
    =>
    ;Notes the Local calendar used to interpret the entire year.
    (if (eq ?*calendarInUse* nil) then
        (modify ?f1 (ForWhichCal ?*GENERAL_ROMAN_CALENDAR*))
    else
        (modify ?f1 (ForWhichCal ?*calendarInUse*))
    )
)
(defrule rPsalterCycleForLotH
    (declare (salience ?*lower-priority*))
    (phase-03-minorFeasts)
    (test (member$ easter (get-defglobal-list)))
    (test (member$ FirstSunOrdinaryTime (get-defglobal-list)))
    ?f1 <- (RCcalThisYear (Date_this_year ?f1Date_this_year&~nil)
                    (TypeIndex ?f1TypeIndex)
                    (CurrentCycle ?f1CurrentCycle)
                    (PsalterWeek ?f1PsalterWeek&nil)
                    (PrintOnCal ?f1PrintOnCal)
           )
    =>
    ;;;From the General Instruction on the Liturgy of the Hours, n. 133
    ;The psalter’s four-week cycle is joined to the liturgical year in such a way that the First
    ; Sunday of Advent, the First Ordinary Sunday of the year, the First Sunday of Lent and
    ; Easter Sunday begin the first week of the cycle. Remaining weeks of the cycle before
    ; these Sundays are omitted.
    ;After Pentecost, since the cycle of the psalter follows the sequence of weeks, it is taken up
    ; from that week of the psalter which is indicated at the beginning of the respective week
    ; in the Proper of the Season.

    ;We shall set this value for every day of the year, although it is expected that it should be displayed
    ; on a calendar only for Sundays and Mondays (where a Sunday is not of the current cycle).
    ;Updated 2016-05-27 to use CJDN not the UNIX timestamp.
    (if (or (= ?f1Date_this_year ?*firstSundayAdvent*) (= ?f1Date_this_year ?*FirstSunOrdinaryTime*) (= ?f1Date_this_year (daysAdd ?*easter* -42)) (= ?f1Date_this_year ?*easter*)) then
        (modify ?f1 (PsalterWeek 1))
    else
        ;step backwards through the Liturgical Year. We shall treat the weeks at the beginning of the year last.
        (if (> ?f1Date_this_year ?*firstSundayAdvent*) then
            ;Date is between the First Sunday of Advent and 31 Dec, inclusive of the latter.
            (bind ?iDaysDiff (- ?f1Date_this_year ?*firstSundayAdvent*))
            (bind ?iNumWeeks (div ?iDaysDiff 7))
            (bind ?iPsalterCycle (+ (mod ?iNumWeeks 4) 1))
            (modify ?f1 (PsalterWeek ?iPsalterCycle))
        else
            (if (and (> ?f1Date_this_year ?*easter*) (<= ?f1Date_this_year (daysAdd ?*easter* 49))) then
                ;Date is between Easter and Pentecost, inclusive of the latter.
                (bind ?iDaysDiff (- ?f1Date_this_year ?*easter*))
                (bind ?iNumWeeks (div ?iDaysDiff 7))
                (bind ?iPsalterCycle (+ (mod ?iNumWeeks 4) 1))
                (modify ?f1 (PsalterWeek ?iPsalterCycle))
            else
                (if (and (> ?f1Date_this_year (daysAdd ?*easter* -42)) (< ?f1Date_this_year ?*easter*)) then
                    ;Date is in Lent, but not earlier than the first Sunday of Lent.
                    (bind ?iDaysDiff (- ?f1Date_this_year (daysAdd ?*easter* -42) ))
                    (bind ?iNumWeeks (div ?iDaysDiff 7))
                    (bind ?iPsalterCycle (+ (mod ?iNumWeeks 4) 1))
                    (modify ?f1 (PsalterWeek ?iPsalterCycle))
                else
                    (if (and (> ?f1Date_this_year ?*FirstSunOrdinaryTime*) (< ?f1Date_this_year (daysAdd ?*easter* -46))) then
                        ;Date is in the first part of Ordinary Time — i.e. before Lent.
                        (bind ?iDaysDiff (- ?f1Date_this_year ?*FirstSunOrdinaryTime* ))
                        (bind ?iNumWeeks (div ?iDaysDiff 7))
                        (bind ?iPsalterCycle (+ (mod ?iNumWeeks 4) 1))
                        (modify ?f1 (PsalterWeek ?iPsalterCycle))
                    else
                        (if (and (> ?f1Date_this_year (daysAdd ?*easter* 49)) (< ?f1Date_this_year ?*firstSundayAdvent*)) then
                            ;Date is in the latter part of Ordinary Time — i.e. after Pentecost.
                            ;In this instance, we work back from the end of the period
                            (bind ?iDaysDiff (- ?*firstSundayAdvent* ?f1Date_this_year ))
                            (bind ?iNumWeeks (div ?iDaysDiff 7))
                            (if (= (DoW ?f1Date_this_year) 7) then
                                (bind ?iNumWeeks (- ?iNumWeeks 1))
                            )
                            (bind ?iNumWeeks (- 33 ?iNumWeeks))
                            (bind ?iPsalterCycle (+ (mod ?iNumWeeks 4) 1))
                            ;check whether it is the first week of resumption, if so set it to printable
                            (bind ?sPrintOnCal ?f1PrintOnCal)
                            (if (< ?f1Date_this_year (daysAdd ?*easter* 56)) then
                                (bind ?sPrintOnCal 1)
                            )
                            (modify ?f1 (PsalterWeek ?iPsalterCycle) (PrintOnCal ?sPrintOnCal))
                        else
                            ;Final part: caters for the weeks between Christmas last year and the beginning of Ordinary Time
                            (if (< ?f1Date_this_year ?*FirstSunOrdinaryTime*) then
                                ;Date is before the first Ordinary Sunday of the year.
                                ; We need to find the First Sunday of Advent from the preceding year
                                (bind ?dTemp (daysAdd (clFindSun (mkDate (- ?*yearSought* 1) 12 18) (mkDate (- ?*yearSought* 1) 12 24)) -21))
                                (bind ?iDaysDiff (- ?f1Date_this_year ?dTemp ))
                                (bind ?iNumWeeks (div ?iDaysDiff 7))
                                (bind ?iPsalterCycle (+ (mod ?iNumWeeks 4) 1))
                                (modify ?f1 (PsalterWeek ?iPsalterCycle))
                            )
                        )
                    )
                )
            )
        )
    )

    ;Final tidy-up for the exception of the days of Lent before the First Sunday of Lent.
    ;   These days from Ash Wednesday up to and including the Saturday before the First Sunday of Lent,
    ;   are taken from Week 4 of the four-week cycle.
    (if (or (eq ?f1TypeIndex "MOV001") (eq ?f1TypeIndex "MOV002") (eq ?f1TypeIndex "MOV003") (eq ?f1TypeIndex "MOV004")) then
        (modify ?f1 (PsalterWeek 4))
    )
)
(defrule rFastingAndAbstinence
    (declare (salience ?*lower-priority*))
    (phase-03-minorFeasts)
    ?f1 <- (RCcalThisYear (Date_this_year ?f1Date_this_year&~nil)
                    (FastingToday ?f1FastingToday&nil)
                    (TypeIndex ?f1TypeIndex)
                    (AbstinenceToday ?f1AbstinenceToday)
                    (TableLitDayRank ?f1TableLitDayRank)
           )
    =>
    ;According to the Code of Canon Law,  (Canons 1250-1252),
    ;   Can. 1250: The penitential days and times in the universal Church
    ;      are every Friday of the whole year and the season of Lent.
    ;   Can. 1251: Abstinence from meat, or from some other food as determined by the Episcopal Conference,
    ;      is to be observed on all Fridays, unless a solemnity should fall on a Friday.
    ;      Abstinence and fasting are to be observed on Ash Wednesday and Good Friday.

    (bind ?bFasting 0)
    (bind ?bAbstinence 0)
    ;Look for days in Lent first
    (if (and (>= ?f1Date_this_year (daysAdd ?*easter* -46)) (< ?f1Date_this_year ?*easter*)) then
        ;Check whether the day is a solemnity
        (if (> ?f1TableLitDayRank 1400) then
            (bind ?bAbstinence 1)
        )
        ;Include Holy Week in the fasting time, although it ranks higher than a solemnity
        (if (and (> ?f1Date_this_year (daysAdd ?*easter* -7)) (< ?f1Date_this_year ?*easter*)) then
            (bind ?bAbstinence 1)
        )
        ;Check for days of Fast
        (if (or (eq ?f1TypeIndex "MOV001") (eq ?f1TypeIndex "MOV045")) then
            (bind ?bFasting 1)
            (bind ?bAbstinence 1)
        )
    else
        ;Otherwise outside Lent, check for Fridays
        (if (= (DoW ?f1Date_this_year) 5) then
            ;Check whether the day is a solemnity
            (if (> ?f1TableLitDayRank 1400) then
                (bind ?bAbstinence 1)
            )
        )
    )

    ;Check for Australian Ember Days
    (if (or (eq ?f1TypeIndex "CAL_AU015") (eq ?f1TypeIndex "CAL_AU016")) then
        (bind ?bFasting 0)
        (bind ?bAbstinence 1)
    )

    (modify ?f1 (FastingToday ?bFasting) (AbstinenceToday ?bAbstinence))
)
(defrule beginPhaseFour
    (declare (salience ?*lowest-priority*))
    ?f1 <- (phase-03-minorFeasts)
    =>
    ;Due to salience, this should run after all the Phase 03 rules have fired.
    (assert (phase-04-officeTexts))
    (retract ?f1)
)
