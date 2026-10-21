; Schedule C (2025), Profit or Loss From Business: one for each business,
; yours or, on a joint return, your spouse's. IRC §§61(a)(2), 162.

(collection f1040scs :label "Businesses, a Schedule C for each"
  (input spouses : bool :default false :label "Your spouse's business, on a joint return")
  ; Its profit is income, but not self-employment income.
  (input statutory-employee : bool :default false
    :label "Income reported on Form W-2 with the statutory employee box checked" :line 1)

  ; ---- Part I: Income ----

  (input receipts : usd :label "Gross receipts or sales" :line 1)
  (input returns : usd :default $0 :label "Returns and allowances" :line 2)
  (def line3 (- receipts returns))
  (def line5 :label "Gross profit" (- line3 line42))
  (input other-income : usd :default $0
    :label "Other income, including fuel tax credits or refunds" :line 6)
  (def line7 :label "Gross income" (+ line5 other-income))

  ; ---- Part II: Expenses ----

  (input advertising : usd :default $0 :label "Advertising" :line 8)
  (input car : usd :default $0 :label "Car and truck expenses" :line 9)
  (input commissions : usd :default $0 :label "Commissions and fees" :line 10)
  (input contract-labor : usd :default $0 :label "Contract labor" :line 11)
  (input depletion : usd :default $0 :label "Depletion" :line 12)
  (input depreciation : usd :default $0
    :label "Depreciation and section 179 expense deduction" :line 13)
  (input employee-benefits : usd :default $0 :label "Employee benefit programs" :line 14)
  (input insurance : usd :default $0 :label "Insurance (other than health)" :line 15)
  (input mortgage-interest : usd :default $0 :label "Mortgage interest paid to banks" :line 16a)
  (input other-interest : usd :default $0 :label "Other interest" :line 16b)
  (input professional : usd :default $0 :label "Legal and professional services" :line 17)
  (input office : usd :default $0 :label "Office expense" :line 18)
  (input pension : usd :default $0 :label "Pension and profit-sharing plans" :line 19)
  (input rent-equipment : usd :default $0
    :label "Rent or lease of vehicles, machinery and equipment" :line 20a)
  (input rent-property : usd :default $0 :label "Rent or lease of other business property" :line 20b)
  (input repairs : usd :default $0 :label "Repairs and maintenance" :line 21)
  (input supplies : usd :default $0 :label "Supplies" :line 22)
  (input taxes : usd :default $0 :label "Taxes and licenses" :line 23)
  (input travel : usd :default $0 :label "Travel" :line 24a)
  ; Usually half of what the meals cost.
  (input meals : usd :default $0 :label "Deductible meals" :line 24b :cite "IRC §274(n)")
  (input utilities : usd :default $0 :label "Utilities" :line 25)
  (input wages : usd :default $0 :label "Wages, less employment credits" :line 26)
  (input energy-efficient : usd :default $0
    :label "Energy efficient commercial buildings deduction (Form 7205)" :line 27a)
  (input other-expenses : usd :default $0 :label "Other expenses (Part V)" :line 27b)
  (def line28 :label "Total expenses before business use of home"
    (+ advertising car commissions contract-labor depletion depreciation
       employee-benefits insurance mortgage-interest other-interest professional
       office pension rent-equipment rent-property repairs supplies taxes travel
       meals utilities wages energy-efficient other-expenses))
  (def line29 :label "Tentative profit or loss" (- line7 line28))
  ; By the simplified method, $5 a square foot of up to 300, no more than
  ; the profit when the home is where all the business's income comes from.
  (input home-office : number :default 0
    :label "Square feet of your home used regularly and only for the business, averaged over the months"
    :line 30 :cite "IRC §280A(c); Rev. Proc. 2013-13")
  (def line30 :label "Business use of your home"
    (max $0 (min line29 (* (min home-office law/home-office-area) law/home-office-rate))))
  ; A loss is taken as all at risk (line 32a).
  (def line31 :label "Net profit or loss" (- line29 line30))
  ; For Schedule 1-A: tips customers paid by choice, included in receipts
  ; reported on Forms 1099-NEC, 1099-MISC or 1099-K.
  (input qualified-tips : usd :default $0
    :label "Of the receipts, tips received in an occupation listed at IRS.gov/TippedOccupations"
    :cite "IRC §224(c), (d)")

  ; ---- Part III: Cost of goods sold ----

  (input opening-inventory : usd :default $0 :label "Inventory at beginning of year" :line 35)
  (input purchases : usd :default $0
    :label "Purchases less cost of items withdrawn for personal use" :line 36)
  (input labor : usd :default $0 :label "Cost of labor" :line 37)
  (input materials : usd :default $0 :label "Materials and supplies" :line 38)
  (input other-costs : usd :default $0 :label "Other costs" :line 39)
  (def line40 (+ opening-inventory purchases labor materials other-costs))
  (input closing-inventory : usd :default $0 :label "Inventory at end of year" :line 41)
  (def line42 :label "Cost of goods sold" (- line40 closing-inventory)))
