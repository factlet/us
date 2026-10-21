; Itemized deductions: Schedule A.

(test "itemized deductions instead of the standard deduction when larger"
  (given you/birth-date 1990-05-01
         f1040sa/medical $9,000 f1040sa/income-taxes $6,000 f1040sa/real-estate-taxes $5,000
         f1040sa/mortgage-interest $12,000 f1040sa/cash-gifts $2,000)
  (member w2s acme (given wages $100,000 medicare-wages $100,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040sa/line4 $1,500                       ; past 7.5% × $100,000
          f1040sa/line5e $11,000
          f1040sa/line17 $26,500
          f1040/itemizes true
          f1040/line12e $26,500
          f1040/line15 $73,500
          ; row middle $73,525: $5,578.50 + 22% × ($73,525 − $48,475)
          f1040/line16 $11,090))

(test "the standard deduction when larger, unless you choose to itemize"
  (given you/birth-date 1990-05-01 f1040sa/cash-gifts $3,000)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040/itemizes false f1040/line12e $15,750)
  (given f1040sa/elect-itemize true)
  (expect f1040/line12e $3,000))

(test "state and local taxes up to $40,000, or $20,000 on a separate return"
  (given you/birth-date 1990-05-01
         f1040sa/income-taxes $30,000 f1040sa/real-estate-taxes $15,000)
  (member w2s acme (given wages $200,000 medicare-wages $200,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040sa/line5d $45,000 f1040sa/line5e $40,000)
  (given married true files-separately true)
  (expect f1040sa/line5e $20,000))

(test "past $500,000 of AGI the limit comes down by 30% of the excess, to $10,000"
  (given you/birth-date 1990-05-01
         f1040sa/income-taxes $30,000 f1040sa/real-estate-taxes $15,000)
  (member w2s acme (given wages $200,000 medicare-wages $200,000 withheld $0))
  (member f1099-ints bank (given interest $350,000))
  (empty f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040sa-salt/line7 $15,000                 ; 30% × ($550,000 − $500,000)
          f1040sa/line5e $25,000)
  (member f1099-ints cd (given interest $50,000))
  (expect f1040sa-salt/line8 $10,000
          f1040sa/line5e $10,000)
  ; Separately, from $250,000, and half: $40,000 − 30% × $350,000 is
  ; below the $10,000 floor, so $5,000.
  (given married true files-separately true)
  (expect f1040sa-salt/line9 $10,000
          f1040sa/line5e $5,000))

(test "when a spouse filing separately itemizes, there's no standard deduction"
  (given married true files-separately true you/birth-date 1990-05-01 f1040sa/cash-gifts $1,000)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040/line12e $15,750)
  (given spouse-itemizes true)
  (expect f1040/standard-deduction $0
          f1040/line12e $1,000))
