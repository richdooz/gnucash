;; Preferences
;;
;; This program is free software; you can redistribute it and/or    
;; modify it under the terms of the GNU General Public License as   
;; published by the Free Software Foundation; either version 2 of   
;; the License, or (at your option) any later version.              
;;                                                                  
;; This program is distributed in the hope that it will be useful,  
;; but WITHOUT ANY WARRANTY; without even the implied warranty of   
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    
;; GNU General Public License for more details.                     
;;                                                                  
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, contact:
;;
;; Free Software Foundation           Voice:  +1-617-542-5942
;; 59 Temple Place - Suite 330        Fax:    +1-617-542-2652
;; Boston, MA  02111-1307,  USA       gnu@gnu.org

(require 'sort)
(require 'hash-table)

;; (define gnc:*double-entry-restriction*
;;   (gnc:make-config-var
;;    "Determines how the splits in a transaction will be balanced. 
;;  The following values have significance:
;; 
;;    #f        anything goes
;; 
;;    'force    The sum of all splits in a transaction will be
;;              forced to be zero, even if this requires the
;;              creation of additional splits.  Note that a split
;;              whose value is zero (e.g. a stock price) can exist
;;              by itself. Otherwise, all splits must come in at 
;;              least pairs.
;; 
;;    'collect  splits without parents will be forced into a
;;              lost & found account.  (Not implemented)"
;;    (lambda (var value)
;;      (cond
;;       ((eq? value #f)
;;        (_gnc_set_force_double_entry_ 0)
;;        (list value))
;;       ((eq? value 'force)
;;        (_gnc_set_force_double_entry_ 1)
;;        (list value))
;;       ((eq? value 'collect)
;;        (gnc:warn
;;         "gnc:*double-entry-restriction* -- 'collect not supported yet.  "
;;         "Ignoring.")
;;        #f)
;;       (else
;;        (gnc:warn
;;         "gnc:*double-entry-restriction* -- " value " not supported.  Ignoring.")
;;        #f)))
;;    eq?
;;    #f))

(define gnc:*options-entries* (gnc:new-options))

(define (gnc:register-configuration-option new-option)
  (gnc:register-option gnc:*options-entries* new-option))

(define (gnc:lookup-global-option section name)
  (gnc:lookup-option gnc:*options-entries* section name))

(define (gnc:send-global-options) gnc:*options-entries*)

(define (gnc:global-options-clear-changes)
  (gnc:options-clear-changes gnc:*options-entries*))

(define gnc:*save-options-hook*
  (gnc:hook-define 
   'save-options-hook
   "Functions to run when saving options.  Hook args: ()"))

;; save-all-options: this is the actual hook that gets called at
;; shutdown.  right now, we put all the options in the same file so
;; it's important to make sure it happens in this order.  later the
;; hook should probably revert back to just save-global-options.
(define (gnc:save-all-options)
  (gnc:save-global-options)
  (gnc:hook-run-danglers gnc:*save-options-hook*))

(define (gnc:save-global-options)
  (gnc:make-home-dir)
  (gnc:save-options gnc:*options-entries*
                    (symbol->string 'gnc:*options-entries*)
                    gnc:current-config-auto
                    (string-append
                     "(gnc:config-file-format-version 1)\n\n"
                     ";"
                     (_ "GnuCash Configuration Options")
                     "\n")
                    #t))

(define (gnc:config-file-format-version version) #t)


;;;;;; Create default options and config vars

(define gnc:*debit-strings*
  (list (cons 'NO_TYPE   (N_ "Funds In"))
        (cons 'BANK      (N_ "Deposit"))
        (cons 'CASH      (N_ "Receive"))
        (cons 'CREDIT    (N_ "Payment"))
        (cons 'ASSET     (N_ "Increase"))
        (cons 'LIABILITY (N_ "Decrease"))
        (cons 'STOCK     (N_ "Buy"))
        (cons 'MUTUAL    (N_ "Buy"))
        (cons 'CURRENCY  (N_ "Buy"))
        (cons 'INCOME    (N_ "Charge"))
        (cons 'EXPENSE   (N_ "Expense"))
	(cons 'PAYABLE   (N_ "Payment"))
	(cons 'RECEIVABLE (N_ "Invoice"))
        (cons 'EQUITY    (N_ "Decrease"))))

(define gnc:*credit-strings*
  (list (cons 'NO_TYPE   (N_ "Funds Out"))
        (cons 'BANK      (N_ "Withdrawal"))
        (cons 'CASH      (N_ "Spend"))
        (cons 'CREDIT    (N_ "Charge"))
        (cons 'ASSET     (N_ "Decrease"))
        (cons 'LIABILITY (N_ "Increase"))
        (cons 'STOCK     (N_ "Sell"))
        (cons 'MUTUAL    (N_ "Sell"))
        (cons 'CURRENCY  (N_ "Sell"))
        (cons 'INCOME    (N_ "Income"))
        (cons 'EXPENSE   (N_ "Rebate"))
	(cons 'PAYABLE   (N_ "Bill"))
	(cons 'RECEIVABLE (N_ "Payment"))
        (cons 'EQUITY    (N_ "Increase"))))

(define (gnc:get-debit-string type)
  (_ (assoc-ref gnc:*debit-strings* type)))

(define (gnc:get-credit-string type)
  (_ (assoc-ref gnc:*credit-strings* type)))

;; International options
(gnc:register-configuration-option
 (gnc:make-multichoice-option
  (N_ "International") (N_ "Date Format")
  "a" (N_ "Date Format Display") 'locale
  (list (list->vector (list 'us
                            (N_ "US (12/31/2001)")
                            (N_ "US-style: mm/dd/yyyy")))
        (list->vector (list 'uk
                            (N_ "UK (31/12/2001)")
                            (N_ "UK-style dd/mm/yyyy")))
        (list->vector (list 'ce
                            (N_ "Europe (31.12.2001)")
                            (N_ "Continental Europe: dd.mm.yyyy")))
        (list->vector (list 'iso
                            (N_ "ISO (2001-12-31)")
                            (N_ "ISO Standard: yyyy-mm-dd")))
        (list->vector (list 'locale
                            (N_ "Locale")
                            (N_ "Default system locale format"))))))

(gnc:register-configuration-option
 (gnc:make-currency-option
  (N_ "International") (N_ "New Account Default Currency")
  "b1" (N_ "Default currency for new accounts")
  (gnc:locale-default-iso-currency-code)))

(gnc:register-configuration-option
 (gnc:make-currency-option
  (N_ "International") (N_ "Default Report Currency")
  "b2" (N_ "Default currency for reports")
  (gnc:locale-default-iso-currency-code)))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "International") (N_ "Use 24-hour time format")
  "c" (N_ "Use a 24 hour (instead of a 12 hour) time format.") #f))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "International") (N_ "Enable EURO support")
  "d" (N_ "Enables support for the European Union EURO currency") 
  (gnc:is-euro-currency-code (gnc:locale-default-iso-currency-code))))


;;; Register options

(gnc:register-configuration-option
 (gnc:make-multichoice-option
  (N_ "Register") (N_ "Default Register Style")
  "a" (N_ "Default style for register windows")
  'ledger
  (list (list->vector
         (list 'ledger
               (N_ "Basic Ledger")
               (N_ "Show transactions on one or two lines")))
        (list->vector
         (list 'auto_ledger
               (N_ "Auto-Split Ledger")
               (N_ "Show transactions on one or two lines \
and expand the current transaction")))
        (list->vector
         (list 'journal
               (N_ "Transaction Journal")
               (N_ "Show expanded transactions with all splits"))))))

(gnc:register-configuration-option     
 (gnc:make-simple-boolean-option
  (N_ "Register") (N_ "Double Line Mode")
  "aa" (N_ "Show two lines of information for each transaction") #f))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Register") (N_ "'Enter' moves to blank transaction")
  "g" (N_ "If selected, move to the blank transaction after the user presses \
'Enter'. Otherwise, move down one row.") #f))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Register") (N_ "Confirm before changing reconciled")
  "h" (N_ "If selected, use a dialog to confirm a change to a reconciled \
transaction.") #t))

(define (string-take-n string n)
  (substring string n (string-length string)))

(gnc:register-configuration-option
 (gnc:make-font-option
  (N_ "Register") (N_ "Register font")
  "i" (N_ "The font to use in the register")
  (string-take-n (_ "register-default-font:-adobe-helvetica-medium-r-normal--*-120-*-*-*-*-*-*") 22)))

(gnc:register-configuration-option
 (gnc:make-font-option
  (N_ "Register") (N_ "Register hint font")
  "j" (N_ "The font used to show hints in the register")
  (string-take-n (_ "register-hint-font:-adobe-helvetica-medium-o-normal--*-120-*-*-*-*-*-*") 19)))


;; Register Color options

(gnc:register-configuration-option
 (gnc:make-color-option
  (N_ "Register Colors") (N_ "Header color")
  "a" (N_ "The header background color")
  (list #x96 #xb2 #x84 0)
  255
  #f))

(gnc:register-configuration-option
 (gnc:make-color-option
  (N_ "Register Colors") (N_ "Primary color")
  "b" (N_ "The default background color for register rows")
  (list #xbf #xde #xba 0)
  255
  #f))

(gnc:register-configuration-option
 (gnc:make-color-option
  (N_ "Register Colors") (N_ "Secondary color")
  "c" (N_ "The default secondary background color for register rows")
  (list #xf6 #xff #xdb 0)
  255
  #f))

(gnc:register-configuration-option
 (gnc:make-color-option
  (N_ "Register Colors") (N_ "Primary active color")
  "d" (N_ "The background color for the current register row")
  (list #xff #xf0 #x99 0)
  255
  #f))

(gnc:register-configuration-option
 (gnc:make-color-option
  (N_ "Register Colors") (N_ "Secondary active color")
  "e" (N_ "The secondary background color for the current register row")
  (list #xff #xf0 #x99 0)
  255
  #f))

(gnc:register-configuration-option
 (gnc:make-color-option
  (N_ "Register Colors") (N_ "Split color")
  "f" (N_ "The default background color for split rows in the register")
  (list #xed #xe8 #xd4 0)
  255
  #f))

(gnc:register-configuration-option
 (gnc:make-color-option
  (N_ "Register Colors") (N_ "Split active color")
  "g" (N_ "The background color for the current split row in the register")
  (list #xff #xf0 #x99 0)
  255
  #f))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Register Colors") (N_ "Double mode colors alternate with transactions")
  "h" (N_ "Alternate the primary and secondary colors with each transaction, \
not each row")
  #f))


;;; Reconcile Options

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Reconcile") (N_ "Automatic interest transfer")
  "a" (N_ "Prior to reconciling an account which charges or pays interest, \
prompt the user to enter a transaction for the interest charge or payment.
Currently only enabled for Bank, Credit, Mutual, Asset, Receivable, Payable, and Liability accounts.")
  #f))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Reconcile") (N_ "Automatic credit card payments")
  "b" (N_ "After reconciling a credit card statement, prompt the user \
to enter a credit card payment")
  #t))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Reconcile") (N_ "Check off cleared transactions")
  "c" (N_ "Automatically check off cleared transactions when reconciling")
  #t))


;;; User Info Options

;(gnc:register-configuration-option
; (gnc:make-string-option
;  (N_ "User Info") (N_ "User Name")
;  "b" (N_ "The name of the user. This is used in some reports.") ""))

;(gnc:register-configuration-option
; (gnc:make-text-option
;  (N_ "User Info") (N_ "User Address")
;  "c" (N_ "The address of the user. This is used in some reports.") ""))


;;; General Options

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "General") (N_ "Show Advanced Settings")
  "a" (N_ "Allow modification of less commonly used settings.") #f))

(gnc:register-configuration-option
 (gnc:make-multichoice-option
  (N_ "General") (N_ "Toolbar Buttons")
  "b" (N_ "Choose whether to display icons, text, or both for toolbar buttons")
  'icons_and_text
  (list (list->vector
         (list 'icons_and_text
               (N_ "Icons and Text")
               (N_ "Show both icons and text")))
        (list->vector
         (list 'icons_only
               (N_ "Icons only")
               (N_ "Show icons only")))
        (list->vector
         (list 'text_only
               (N_ "Text only")
               (N_ "Show text only"))))))

(gnc:register-configuration-option
 (gnc:make-radiobutton-option
  (N_ "Accounts") (N_ "Account Separator")
  "c" (N_ "The character used to separate fully-qualified account names")
  'colon
  (list (list->vector
         (list 'colon
               (N_ ": (Colon)")
               (N_ "Income:Salary:Taxable")))
        (list->vector
         (list 'slash
               (N_ "/ (Slash)")
               (N_ "Income/Salary/Taxable")))
        (list->vector
         (list 'backslash
               (N_ "\\ (Backslash)")
               (N_ "Income\\Salary\\Taxable")))
        (list->vector
         (list 'dash
               (N_ "- (Dash)")
               (N_ "Income-Salary-Taxable")))
        (list->vector
         (list 'period
               (N_ ". (Period)")
               (N_ "Income.Salary.Taxable"))))))

(gnc:register-configuration-option
 (gnc:make-multichoice-option
  (N_ "Accounts") (N_ "Reversed-balance account types")
  "d" (N_ "The types of accounts for which balances are sign-reversed")
 'credit
  (list (list->vector
         (list 'income-expense
               (N_ "Income & Expense")
               (N_ "Reverse Income and Expense Accounts")))
        (list->vector
         (list 'credit
               (N_ "Credit Accounts")
               (N_ "Reverse Credit Card, Payable, Liability, Equity, and Income \
Accounts")))
        (list->vector
         (list 'none
               (N_ "None")
               (N_ "Don't reverse any accounts"))))))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Accounts") (N_ "Use accounting labels")
  "e" (N_ "Only use 'debit' and 'credit' instead of informal synonyms") #f))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "General") (N_ "Display \"Tip of the Day\"")
  "f" (N_ "Display hints for using GnuCash at startup") #t))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "General") (N_ "Display negative amounts in red")
  "g" (N_ "Display negative amounts in red") #t))

; this option also changes the next option so that its
; selectability matches the state of this option.
(gnc:register-configuration-option
 (gnc:make-complex-boolean-option
  (N_ "General") (N_ "Automatic Decimal Point")
  "h" 
  (N_ "Automatically insert a decimal point into values that are entered \
without one.") 
  #f #f
  (lambda (x) (gnc:set-option-selectable-by-name "General"
                                                 "Auto Decimal Places"
                                                 x))))

(gnc:register-configuration-option
 (gnc:make-number-range-option
  (N_ "General") (N_ "Auto Decimal Places")
  "i" (N_ "How many automatic decimal places will be filled in.")
    ;; current range is 1-8 with default from the locale
    (gnc:locale-decimal-places) ;; default
    1.0 ;; lower bound
    8.0 ;; upper bound
    0.0 ;; number of decimals used for this range calculation
    1.0 ;; step size
  ))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "General") (N_ "No account list setup on new file")
  "j" (N_ "Don't popup the new account list dialog when you choose \"New File\" from the \"File\" menu") #f))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "General") (N_ "Use file compression")
  "k" (N_ "Compress the data file.")
  #f))

(gnc:register-configuration-option
 (gnc:make-number-range-option
  (N_ "General") (N_ "Days to retain log files")
  "k" (N_ "Delete old log/backup files after this many days (0 = never).")
    30.0 ;; default
    0.0 ;; lower bound
    99999.0 ;; upper bound
    0.0 ;; number of decimals used for this range calculation
    1.0 ;; step size
  ))

;; QIF Import options. 

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Online Banking & Importing") (N_ "QIF Verbose documentation")
  "a" (N_ "Show some documentation-only pages in QIF Import druid")
  #t))


;; Network/security options 
;;(gnc:register-configuration-option
;; (gnc:make-simple-boolean-option
;;  (N_ "Network") (N_ "Allow http network access")
;;  "a" (N_ "Enable GnuCash's HTTP client support.")
;;  #t))
;;
;;(gnc:register-configuration-option
;; (gnc:make-simple-boolean-option
;;  (N_ "Network") (N_ "Allow https connections using OpenSSL")
;;  "b" (N_ "Enable secure HTTP connections using OpenSSL")
;;  #t))
;;
;;(gnc:register-configuration-option
;; (gnc:make-simple-boolean-option
;;  (N_ "Network") (N_ "Enable GnuCash Network")
;;  "c" (N_ "The GnuCash Network server provides support and other services")
;;  #t))
;;
;;(gnc:register-configuration-option 
;; (gnc:make-string-option
;;  (N_ "Network") (N_ "GnuCash Network server") 
;;  "d" (N_ "Host to connect to for user registration and support services")
;;  "www.gnucash.org"))


;; Scheduled|Recurring Transactions

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Scheduled Transactions")
  (N_ "Run on GnuCash start")
  "a" (N_ "Should the Since-Last-Run window appear on GnuCash startup?")
  #t ))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Scheduled Transactions")
  (N_ "Auto-Create new Scheduled Transactions by default")
  "b" (N_ "Should new Scheduled Transactions have the 'Auto Create' flag set by default?")
  #f ))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "Scheduled Transactions")
  (N_ "Notify on new, auto-created Scheduled Transactions")
  "c" (N_ "Should new Scheduled Transactions with the 'AutoCreate' flag set also be set to notify?")
  #t ))

(gnc:register-configuration-option
 (gnc:make-number-range-option
  (N_ "Scheduled Transactions")
  (N_ "Default number of days in advance to create")
  "d" (N_ "Default number of days in advance to create new Scheduled Transactions.")
  0 ; default
  0 ; min
  99999 ; max
  0 ; num decimals
  1 ; step size
  ))

(gnc:register-configuration-option
 (gnc:make-number-range-option
  (N_ "Scheduled Transactions")
  (N_ "Default number of days in advance to remind")
  "e" (N_ "Default number of days in advance to remind on new Scheduled Transactions.")
  0 ; default
  0 ; min
  99999 ; max
  0 ; num-decimals
  1 ; step size
  ))

(gnc:register-configuration-option
 (gnc:make-number-range-option
  (N_ "Scheduled Transactions")
  (N_ "Template Register Lines")
  "f" (N_ "How many lines in the template register?")
  6  ; default
  1  ; min
  50 ; max
  0  ; num-decimals
  1  ; step size
  ))


;;; Advanced Options

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "_+Advanced") (N_ "Save Window Geometry")
  "a" (N_ "Save window sizes and positions.") #t))

(gnc:register-configuration-option
 (gnc:make-multichoice-option
  (N_ "_+Advanced") (N_ "Application MDI mode")
  "ba" (N_ "Choose how new windows are created for reports and account trees.")
  'mdi-notebook
  (list (list->vector
         (list 'mdi-notebook
               (N_ "Notebook")
               (N_ "New windows are created as notebook tabs in the \
current top-level window")))
        (list->vector
         (list 'mdi-toplevel
               (N_ "Top-level")
               (N_ "Create a new top-level window for each report \
or account tree")))
        (list->vector
         (list 'mdi-modal
               (N_ "Single window")
               (N_ "One window is used for all displays (select contents \
through Window menu)")))
        (list->vector
         (list 'mdi-default
               (N_ "Use GNOME default")
               (N_ "Default MDI mode can be set in the GNOME \
Control Center"))))))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "_+Advanced") (N_ "Show Vertical Borders")
  "c" (N_ "By default, show vertical borders on the cells.") #f))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "_+Advanced") (N_ "Show Horizontal Borders")
  "d" (N_ "By default, show horizontal borders on the cells.") #f))

(gnc:register-configuration-option     
 (gnc:make-simple-boolean-option
  (N_ "_+Advanced") (N_ "Auto-Raise Lists")
  "e" (N_ "Automatically raise the list of accounts or actions during input.")
  #t))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  (N_ "_+Advanced") (N_ "Show All Transactions")
  "f" (N_ "By default, show every transaction in an account.") #t))

(gnc:register-configuration-option
 (gnc:make-number-range-option
  (N_ "_+Advanced") (N_ "Number of Rows")
  "g" (N_ "Default number of register rows to display.")
   20.0 ;; default
    1.0 ;; lower bound
  200.0 ;; upper bound
    0.0 ;; number of decimals
    1.0 ;; step size
  ))

(gnc:register-configuration-option
 (gnc:make-number-range-option
  (N_ "_+Advanced") (N_ "New Search Limit")
  "j" (N_ "Default to 'new search' if fewer than this number of items is returned.")
    1.0 ;; default
    1.0 ;; lower bound
  100.0 ;; upper bound
    0.0 ;; number of decimals
    1.0 ;; step size
  ))


;;; Internal options -- Section names that start with "__" are not
;;; displayed in option dialogs.

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "account_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "account_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "commodities_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "commodities_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "help_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "help_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "main_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "main_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "prices_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "prices_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "reg_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "reg_stock_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "reg_column_widths" '()))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "report_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "report_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "tax_info_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "tax_info_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "sx_list_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "sx_list_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "sx_editor_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "sx_editor_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "sx_sincelast_win_width" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "sx_sincelast_win_height" 0))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__exp_parser" "defined_variables" '()))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__new_user" "first_startup" #t))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gnc_network" "uid" ""))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__paths"  "Export Accounts" #f))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__paths"  "Import QIF" #f))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__paths"  "Import OFX" #f))

(gnc:register-configuration-option
 (gnc:make-simple-boolean-option
  "__gui" "search_for_active_only"
  "" ""
  #t))

(gnc:register-configuration-option
 (gnc:make-internal-option
  "__gui" "commodity_include_iso" 0))