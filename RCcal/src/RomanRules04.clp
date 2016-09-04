;####################################################################################
;;;;;; To print out the facts, use: (printout t (facts) crlf) .
;;;    To save facts to a file, use: (save-facts "harry.clp") .
;;;     (do-for-all-facts ((?m RCcalThisYear)) (neq ?m:Date_this_year nil) (printout t (unmakeDate ?m:Date_this_year) " : " ?m:TypeIndex crlf))

;;; These rules come from the GIRM and GILH. They presume that the rules from earlier phases have fired
;;;  and have created the necessary facts.

;;; *** May be better to do this reading, by reading,
;;;        or to write a function to find the correct reading, when the proper is not available.
(defrule pMassSolemnityTexts
    (declare (salience ?*high-priority*))
    (phase-04-officeTexts)
    ?f1 <- (RCcalThisYear (Date_this_year ?f1Date_this_year&~nil)
                    (TypeIndex ?f1TypeIndex)
                    (CurrentCycle ?f1CurrentCycle&nil)
                    (TableLitDayRank ?f1TableLitDayRank&:(<= ?f1TableLitDayRank 1400))
                    (R1 ?f1R1&nil)
                    (SundayMassReadingsCycle ?f1SundayMassReadingsCycle)
                    (WeekdayMassReadingsCycle ?f1WeekdayMassReadingsCycle)
           )
    ?f2 <- (CalendarFact (Date_this_year ?f2Date_this_year&~nil)
                    (TypeIndex ?f2TypeIndex&:(eq ?f2TypeIndex ?f1TypeIndex))
                    (Rank ?f2Rank)
                    (Lit_rank ?f2Lit_rank)
                    (R1YA ?f2R1YA)
                    (R1YB ?f2R1YB)
                    (R1YC ?f2R1YC)
                    (R2YA ?f2R2YA)
                    (R2YB ?f2R2YB)
                    (R2YC ?f2R2YC)
                    (RespPsYA ?f2RespPsYA)
                    (RespPsYB ?f2RespPsYB)
                    (RespPsYC ?f2RespPsYC)
                    (GospelA ?f2GospelA)
                    (GospelB ?f2GospelB)
                    (GospelC ?f2GospelC)
                    (GosAcclA ?f2GosAcclA)
                    (GosAcclB ?f2GosAcclB)
                    (GosAcclC ?f2GosAcclC)
            )
    =>
    ;Current cycle will be nil for Solemnities, Feasts, and celebrations of greater solemnity.
    ;All of these celebrations should have proper readings.
    ;We cannot use the (eval) command here, as the symbolic references for variables have been stripped by CLIPS.
    (if (eq ?f1SundayMassReadingsCycle "A") then
        (bind ?sTempR1 ?f2R1YA)
        (bind ?sTempR2 ?f2R2YA)
        (bind ?sTempRespPs ?f2RespPsYA)
        (bind ?sTempGospel ?f2GospelA)
        (bind ?sTempGosAccl ?f2GosAcclA)
    else
        (if (eq ?f1SundayMassReadingsCycle "B") then
            (bind ?sTempR1 ?f2R1YB)
            (bind ?sTempR2 ?f2R2YB)
            (bind ?sTempRespPs ?f2RespPsYB)
            (bind ?sTempGospel ?f2GospelB)
            (bind ?sTempGosAccl ?f2GosAcclB)
        else
            (if (eq ?f1SundayMassReadingsCycle "C") then
                (bind ?sTempR1 ?f2R1YC)
                (bind ?sTempR2 ?f2R2YC)
                (bind ?sTempRespPs ?f2RespPsYC)
                (bind ?sTempGospel ?f2GospelC)
                (bind ?sTempGosAccl ?f2GosAcclC)
            )
        )
    )
    ;;;*** Check to prevent rule continually firing.
    (if (eq ?sTempR1 nil) then
        (bind ?sTempR1 ?*DATA_NOT_FOUND*)
    )
    (modify ?f1 (R1 ?sTempR1) (R2 ?sTempR2) (RespPs ?sTempRespPs) (Gospel ?sTempGospel) (GosAccl ?sTempGosAccl))
    (printout t (unmakeDate ?f1Date_this_year) " : " ?sTempR1 crlf)
)

;;;*** Create a rule to capture all reading slots that are either nil or ?*DATA_NOT_FOUND*, which
;;;       will then check the appropriate Common for that particular reading.
;;;    For Optional Memorials, it should just add the readings from the appropriate cycle.
