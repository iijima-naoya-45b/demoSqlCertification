-- ============================================================
-- 経理・財務ドメイン (Finance)
-- テーブル数: 7
-- ============================================================

CREATE TABLE chartOfAccounts (
    accountId          SERIAL PRIMARY KEY,
    accountCode        VARCHAR(20) NOT NULL UNIQUE,
    accountName        VARCHAR(100) NOT NULL,
    accountTypeId      INTEGER NOT NULL REFERENCES accountTypeMaster(accountTypeId),
    parentAccountId    INTEGER REFERENCES chartOfAccounts(accountId),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE chartOfAccounts IS '勘定科目マスタ（階層構造・科目区分）';

CREATE TABLE journalEntries (
    journalEntryId     SERIAL PRIMARY KEY,
    fiscalYearId       INTEGER NOT NULL REFERENCES fiscalYears(fiscalYearId),
    entryNumber        VARCHAR(30) NOT NULL UNIQUE,
    entryDate          DATE NOT NULL,
    description        VARCHAR(200),
    entryStatus        VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (entryStatus IN ('draft', 'posted', 'reversed')),
    postedAt           TIMESTAMP,
    createdByEmployeeId INTEGER REFERENCES employees(employeeId),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE journalEntries IS '仕訳ヘッダ（会計年度・転記ステータス）';

CREATE TABLE journalLines (
    journalLineId      SERIAL PRIMARY KEY,
    journalEntryId     INTEGER NOT NULL REFERENCES journalEntries(journalEntryId) ON DELETE CASCADE,
    accountId          INTEGER NOT NULL REFERENCES chartOfAccounts(accountId),
    transactionTypeId  INTEGER REFERENCES transactionTypeMaster(transactionTypeId),
    debitAmount        NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (debitAmount >= 0),
    creditAmount       NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (creditAmount >= 0),
    lineDescription    VARCHAR(200),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (debitAmount > 0 OR creditAmount > 0),
    CHECK (NOT (debitAmount > 0 AND creditAmount > 0))
);

COMMENT ON TABLE journalLines IS '仕訳明細（借方・貸方・取引種別）';

CREATE TABLE departmentalBudgets (
    departmentalBudgetId SERIAL PRIMARY KEY,
    departmentId       INTEGER NOT NULL REFERENCES departments(departmentId),
    fiscalYearId       INTEGER NOT NULL REFERENCES fiscalYears(fiscalYearId),
    budgetName         VARCHAR(100) NOT NULL,
    totalAmount        NUMERIC(14, 2) NOT NULL CHECK (totalAmount >= 0),
    budgetStatus       VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (budgetStatus IN ('draft', 'approved', 'active', 'closed')),
    approvedAt         TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (departmentId, fiscalYearId, budgetName)
);

COMMENT ON TABLE departmentalBudgets IS '部門別予算（会計年度・承認ステータス）';

CREATE TABLE budgetLines (
    budgetLineId       SERIAL PRIMARY KEY,
    departmentalBudgetId INTEGER NOT NULL REFERENCES departmentalBudgets(departmentalBudgetId) ON DELETE CASCADE,
    accountId          INTEGER NOT NULL REFERENCES chartOfAccounts(accountId),
    expenseCategoryId  INTEGER REFERENCES expenseCategoryMaster(expenseCategoryId),
    plannedAmount      NUMERIC(14, 2) NOT NULL CHECK (plannedAmount >= 0),
    actualAmount       NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (actualAmount >= 0),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (departmentalBudgetId, accountId)
);

COMMENT ON TABLE budgetLines IS '予算明細（勘定科目・経費カテゴリ別）';

CREATE TABLE expenseReports (
    expenseReportId    SERIAL PRIMARY KEY,
    employeeId         INTEGER NOT NULL REFERENCES employees(employeeId),
    departmentId       INTEGER NOT NULL REFERENCES departments(departmentId),
    fiscalYearId       INTEGER REFERENCES fiscalYears(fiscalYearId),
    reportTitle        VARCHAR(200) NOT NULL,
    reportStatus       VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (reportStatus IN ('draft', 'submitted', 'approved', 'rejected', 'paid')),
    totalAmount        NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (totalAmount >= 0),
    submittedAt        TIMESTAMP,
    approvedByEmployeeId INTEGER REFERENCES employees(employeeId),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE expenseReports IS '経費精算ヘッダ（申請・承認フロー）';

CREATE TABLE expenseLines (
    expenseLineId      SERIAL PRIMARY KEY,
    expenseReportId    INTEGER NOT NULL REFERENCES expenseReports(expenseReportId) ON DELETE CASCADE,
    expenseCategoryId  INTEGER NOT NULL REFERENCES expenseCategoryMaster(expenseCategoryId),
    expenseDate        DATE NOT NULL,
    description        VARCHAR(200) NOT NULL,
    amount             NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    currencyId         INTEGER NOT NULL REFERENCES currencies(currencyId),
    receiptUrl         VARCHAR(500),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE expenseLines IS '経費精算明細（カテゴリ・領収書）';
