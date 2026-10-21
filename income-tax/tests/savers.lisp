; The saver's credit: Form 8880.

(test "50% of up to $2,000 of IRA contributions and deferrals, up to the tax"
  (given you/birth-date 1990-05-01 you/roth-contributions $1,000)
  (member w2s acme (given wages $22,000 medicare-wages $22,000 withheld $0 deferrals $1,500))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8880/line3a $2,500
          f8880/line6a $2,000
          f8880/line9 50%
          f8880/line10 $1,000
          ; row middle $6,275: tax $628
          f8880/line12 $628
          f1040s3/line4 $628))

(test "20%, then 10%, then none as AGI passes each top"
  (given you/birth-date 1990-05-01 you/ira-contributions $2,000)
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  ; Deducted, the contributions lower AGI by $2,000.
  (member w2s acme (given wages $27,000 medicare-wages $27,000 withheld $0))
  (expect f8880/line8 $25,000 f8880/line9 20% f8880/line12 $400)
  (member w2s b (given wages $5,000 medicare-wages $5,000 withheld $0))
  (expect f8880/line9 10% f8880/line12 $200)
  (member w2s c (given wages $10,000 medicare-wages $10,000 withheld $0))
  (expect f8880/line9 0% f8880/line12 $0))

(test "on a joint return each spouse's own, less both spouses' distributions"
  (given married true
         you/birth-date 1985-01-01 you/tin 'ssn you/retirement-distributions $500
         spouse/birth-date 1985-01-01 spouse/tin 'ssn)
  (member w2s yours (given wages $30,000 medicare-wages $30,000 withheld $0 deferrals $3,000))
  (member w2s theirs
    (given wages $20,000 medicare-wages $20,000 withheld $0 deferrals $1,000 spouses true))
  (member people kid (given birth-date 2020-01-01 relationship 'child tin 'ssn))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f8880/line5a $2,500
          f8880/line5b $500
          f8880/line7 $2,500
          f8880/line9 20%                            ; $50,000 joint
          f8880/line12 $500
          ; and the child tax credit takes what's left of the $1,853 tax
          f1040s8/line13 $1,353))

(test "not for a full-time student, someone claimed as a dependent, or anyone under 18"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $20,000 medicare-wages $20,000 withheld $0 deferrals $2,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8880/line6a $2,000)
  (given you/full-time-student true)
  (expect f8880/line6a $0)
  (given you/full-time-student false claimed-as-dependent true)
  (expect f8880/line6a $0)
  (given claimed-as-dependent false you/birth-date 2008-01-02)
  (expect f8880/line6a $0)
  ; 18 by the end of the year, as a birthday counts the day before.
  (given you/birth-date 2008-01-01)
  (expect f8880/line6a $2,000))
