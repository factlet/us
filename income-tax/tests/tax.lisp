; Tax: the Tax Table, the Tax Computation Worksheet and the Qualified
; Dividends and Capital Gain Tax Worksheet.

(test "the Tax Table taxes the middle of the row"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $58,000))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  ; row $42,250–$42,300: $1,192.50 + 12% × ($42,275 − $11,925)
  (expect f1040/line15 $42,250
          f1040/line16 $4,835))

; The tax needs only wages, so withholding can stay unanswered.
(test "the Tax Table's rows are irregular at the bottom, then $25, then $50"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $15,750))             ; exactly the deduction
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (member w2s a (given wages $4))
  (expect f1040/line15 $4 f1040/line16 $0)            ; row $0–$5
  (member w2s b (given wages $6))
  (expect f1040/line15 $10 f1040/line16 $1)           ; row $5–$15
  (member w2s c (given wages $27.50))
  (expect f1040/line15 $37.50 f1040/line16 $4)        ; row $25–$50: 10% × $37.50
  (member w2s d (given wages $2,962.49))
  (expect f1040/line15 $2,999.99 f1040/line16 $299)   ; row $2,975–$3,000
  (member w2s e (given wages $0.01))
  (expect f1040/line15 $3,000 f1040/line16 $303       ; row $3,000–$3,050
          f1040/line34 ?))

(test "from $100,000, the Tax Computation Worksheet is exact"
  (given filing-status 'married-joint
         you/birth-date 1980-01-01 spouse/birth-date 1982-01-01)
  (member w2s acme (given wages $131,500))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  ; $2,385 + 12% × $73,100 + 22% × ($100,000 − $96,950)
  (expect f1040/line15 $100,000
          f1040/line16 $11,828))

(test "qualified dividends straddling the 0% and 15% rates"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $60,000 withheld $7,000))
  (member f1099-divs fund (given ordinary $10,000 qualified $10,000))
  (empty f1099-ints f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line15 $54,250
          f1040-qdcg/line5 $44,250
          f1040-qdcg/line9 $4,100                    ; up to $48,350 at 0%
          f1040-qdcg/line17 $5,900                   ; the rest at 15%
          f1040-qdcg/line20 $0
          ; row $44,250–$44,300: $1,192.50 + 12% × ($44,275 − $11,925)
          f1040-qdcg/line22 $5,075
          f1040-qdcg/line23 $5,960
          f1040-qdcg/line24 $6,855
          f1040/line16 $5,960
          f1040/line34 $1,040))

(test "capital gain distributions are all taxed at 0% below the threshold"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $40,000 withheld $0))
  (member f1099-divs fund (given ordinary $10,000 qualified $8,000 cap-gain $2,000))
  (empty f1099-ints f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line9 $52,000
          f1040/line15 $36,250
          f1040-qdcg/line9 $10,000
          ; tax on the $26,250 of ordinary income: row middle $26,275
          f1040/line16 $2,915
          f1040/line37 $2,915))
