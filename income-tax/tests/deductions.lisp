; Deductions: the standard deduction and Schedule 1-A.

(test "joint seniors, one blind, in the senior deduction's phaseout"
  (given filing-status 'married-joint
         you/birth-date 1955-03-01 you/blind true you/tin 'ssn
         spouse/birth-date 1958-07-04 spouse/tin 'ssn)
  (member w2s acme (given wages $160,000 withheld $20,000))
  (member f1099-ints bank (given interest $10,000))
  (empty f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line11a $170,000
          f1040/line12d 3
          f1040/line12e $36,300                      ; $31,500 + 3 × $1,600
          f1040s1a/line33 $20,000
          f1040s1a/line35 $4,800                     ; $6,000 − 6% × $20,000
          f1040s1a/line37 $9,600
          f1040/line15 $124,100
          ; $2,385 + $8,772 + 22% × ($124,100 − $96,950)
          f1040/line16 $17,130
          f1040/line34 $2,870))

(test "turning 65: born on 1961-01-01 counts for 2025, a day later doesn't"
  (given filing-status 'single you/tin 'ssn)
  (member w2s acme (given wages $50,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (given you/birth-date 1961-01-01)
  (expect you/aged true
          f1040/line12e $17,750                      ; $15,750 + $2,000
          f1040s1a/line37 $6,000)
  (given you/birth-date 1961-01-02)
  (expect you/aged false
          f1040/line12e $15,750
          f1040s1a/line37 $0))

(test "the senior deduction asks for an SSN only of seniors"
  (given filing-status 'single you/birth-date 1950-01-01)
  (member w2s acme (given wages $30,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040s1a/line37 ? f1040/line37 ?)
  (given you/tin 'itin)
  (expect f1040s1a/line37 $0 f1040/line12e $17,750))

(test "married filing separately gets no senior deduction"
  (given filing-status 'married-separate you/birth-date 1950-01-01 you/tin 'ssn)
  (member w2s acme (given wages $30,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line12e $17,350                      ; $15,750 + $1,600
          f1040s1a/line37 $0))

(test "a dependent's standard deduction is earned income plus $450"
  (given filing-status 'single you/birth-date 2000-09-01 claimed-as-dependent true)
  (member w2s cafe (given wages $14,000 withheld $100))
  (member f1099-ints bank (given interest $5,000))
  (empty f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line12e $14,450
          f1040/line15 $4,550
          f1040/line16 $458                          ; row middle $4,575
          f1040/line37 $358))

(test "a dependent's standard deduction is at least $1,350"
  (given filing-status 'single you/birth-date 2000-09-01 claimed-as-dependent true)
  (empty w2s f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (member f1099-ints bank (given interest $3,000))
  (expect f1040/line12e $1,350
          f1040/line15 $1,650))
