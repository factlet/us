; Credits: Schedule 8812.

(test "joint filers with two young children"
  (given filing-status 'married-joint
         you/birth-date 1985-01-01 you/tin 'ssn
         spouse/birth-date 1987-01-01 spouse/tin 'ssn)
  (member w2s acme (given wages $70,000 medicare-wages $70,000 withheld $4,000))
  (member w2s globex (given wages $50,000 medicare-wages $50,000 withheld $2,000))
  (member f1099-ints bank (given interest $500))
  (empty f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents ada (given birth-date 2020-04-01 qualifying-child true tin 'ssn))
  (member dependents bo (given birth-date 2015-09-15 qualifying-child true tin 'ssn))
  (expect f1040/line15 $89,000
          ; row middle $89,025: $2,385 + 12% × $65,175
          f1040/line16 $10,206
          f1040s8/line4 2
          f1040/line19 $4,400
          f1040/line24 $5,806
          f1040/line28 $0
          f1040/line34 $194))

(test "a child under 17 at year end is born after 2008-12-31"
  (given filing-status 'single you/tin 'ssn)
  (member dependents a
    (given birth-date 2009-01-01 qualifying-child true tin 'ssn)
    (expect ctc-child true))
  (member dependents b
    (given birth-date 2008-12-31 qualifying-child true tin 'ssn)
    (expect ctc-child false odc-dependent true))
  (expect f1040s8/line4 1 f1040s8/line6 1 f1040s8/line8 $2,700))

(test "a child without a valid SSN gets the $500 credit if they have a number"
  (given filing-status 'single you/tin 'ssn)
  (member dependents itin (given birth-date 2015-01-01 qualifying-child true tin 'itin))
  (member dependents nonwork (given birth-date 2016-01-01 qualifying-child true tin 'nonwork-ssn))
  (member dependents adopted (given birth-date 2017-01-01 qualifying-child true tin 'atin))
  (member dependents none (given birth-date 2018-01-01 qualifying-child true tin 'no-tin)
    (expect ctc-child false odc-dependent false))
  (expect f1040s8/line4 0 f1040s8/line6 3 f1040s8/line8 $1,500))

(test "a filer without a valid SSN gets $500 per child instead of $2,200"
  (given filing-status 'head-of-household you/birth-date 1990-01-01)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $3,000))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2020-01-01 qualifying-child true tin 'ssn))
  (expect f1040s8/line4 ?)                           ; waits on your number
  (given you/tin 'itin)
  (expect f1040s8/line4 0
          f1040s8/line6 1
          f1040s8/line8 $500
          f1040/line15 $16,375
          f1040/line16 $1,638                        ; 10% of row middle $16,375
          f1040/line19 $500
          f1040/line28 $0
          f1040/line24 $1,138
          f1040/line34 $1,862))

(test "on a joint return, one spouse's SSN is enough"
  (given filing-status 'married-joint
         you/birth-date 1990-01-01 you/tin 'itin
         spouse/birth-date 1990-01-01 spouse/tin 'ssn)
  (member dependents kid (given birth-date 2020-01-01 qualifying-child true tin 'ssn))
  (expect f1040s8/line4 1 f1040s8/line5 $2,200 f1040s8/line8 $2,200))

(test "no credit for dependents if a filer's number came after the due date"
  (given filing-status 'married-joint
         you/birth-date 1990-01-01 you/tin 'ssn
         spouse/birth-date 1990-01-01 spouse/tin 'no-tin)
  (member dependents kid (given birth-date 2020-01-01 qualifying-child true tin 'ssn))
  (member dependents parent (given birth-date 1950-01-01 qualifying-child false tin 'ssn))
  (expect f1040s8/line4 0 f1040s8/line6 0 f1040s8/line8 $0))

(test "a dependent who isn't a U.S. citizen, national or resident alien gets no credit"
  ; The instructions' example: a sibling's 10-year-old who lives in Mexico.
  (given filing-status 'single you/tin 'ssn)
  (member dependents niece
    (given birth-date 2015-01-01 qualifying-child false tin 'itin nonresident-alien true)
    (expect odc-dependent false))
  (member dependents nephew (given birth-date 2015-01-01 qualifying-child false tin 'itin)
    (expect odc-dependent true))
  (member dependents daughter
    (given birth-date 2016-01-01 qualifying-child true tin 'ssn nonresident-alien true)
    (expect ctc-child false odc-dependent false))
  (expect f1040s8/line4 0 f1040s8/line6 1 f1040s8/line8 $500))

(test "the credit phases out by $50 per $1,000 or part of it"
  (given filing-status 'married-joint
         you/birth-date 1980-01-01 you/tin 'ssn
         spouse/birth-date 1980-01-01 spouse/tin 'ssn)
  (member w2s acme (given wages $410,500 medicare-wages $410,500 withheld $80,000))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2015-03-01 qualifying-child true tin 'ssn))
  (member dependents teen (given birth-date 2008-06-15 qualifying-child true tin 'ssn))
  (expect f1040s8/line8 $2,700                       ; $2,200 + $500
          f1040s8/line10 $11,000                     ; $10,500, rounded up
          f1040s8/line14 $2,150
          f1040/line15 $379,000
          ; $2,385 + $8,772 + $24,145 + 24% × ($379,000 − $206,700)
          f1040/line16 $76,654
          f1040/line22 $74,504
          ; and 0.9% Additional Medicare Tax on $410,500 − $250,000
          f1040/line24 $75,948.50))

(test "the additional child tax credit refunds what the tax can't absorb"
  (given filing-status 'head-of-household you/birth-date 1995-01-01 you/tin 'ssn)
  (member w2s acme (given wages $25,000 medicare-wages $25,000 withheld $500))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2022-05-01 qualifying-child true tin 'ssn))
  (expect f1040/line15 $1,375
          f1040/line16 $139                          ; row middle $1,387.50
          f1040s8/line14 $139
          f1040s8/line16a $2,061
          f1040s8/line17 $1,700
          f1040s8/line20 $3,375                      ; 15% × ($25,000 − $2,500)
          f1040/line28 $1,700
          f1040/line24 $0
          ; $4,328 − 15.98% × ($25,025 − $23,350)
          f1040/line27a $4,060
          f1040/line34 $6,260))                      ; $500 + $4,060 + $1,700

(test "the additional child tax credit is 15% of earned income over $2,500"
  (given filing-status 'single you/birth-date 1995-01-01 you/tin 'ssn)
  (member w2s acme (given wages $10,000 medicare-wages $10,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2022-05-01 qualifying-child true tin 'ssn))
  (expect f1040/line16 $0
          f1040s8/line17 $1,700
          f1040s8/line20 $1,125                      ; 15% × ($10,000 − $2,500)
          f1040/line28 $1,125
          f1040/line27a $3,409                       ; 34% × $10,025
          f1040/line34 $4,534))                      ; $1,125 + $3,409

(test "with three children, Part II-B refunds payroll taxes the EIC doesn't"
  (given filing-status 'married-joint
         you/birth-date 1990-01-01 you/tin 'ssn
         spouse/birth-date 1990-01-01 spouse/tin 'itin)
  (member w2s acme
    (given wages $4,000 medicare-wages $4,000 withheld $0 ss-withheld $248 medicare-withheld $58))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents a (given birth-date 2015-03-01 qualifying-child true tin 'ssn))
  (member dependents b (given birth-date 2017-07-01 qualifying-child true tin 'ssn))
  (member dependents c (given birth-date 2020-01-01 qualifying-child true tin 'ssn))
  ; No EIC without the spouse's SSN, so all the payroll taxes count.
  (expect f1040s8/line4 3
          f1040s8/line17 $5,100                      ; 3 × $1,700
          f1040s8/line20 $225                        ; 15% × ($4,000 − $2,500)
          f1040s8/line21 $306
          f1040/line27a $0
          f1040s8/line25 $306
          f1040s8/line27 $306)
  (given spouse/tin 'ssn)
  (expect f1040/line27a $1,811                       ; 45% × $4,025
          f1040s8/line25 $0
          f1040s8/line27 $225
          f1040/line34 $2,036))                      ; $1,811 + $225
