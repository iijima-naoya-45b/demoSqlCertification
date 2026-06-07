-- ============================================================
-- 人事ドメイン (HR)
-- テーブル数: 12
-- ============================================================

CREATE TABLE departments (
    departmentId       SERIAL PRIMARY KEY,
    departmentName     VARCHAR(100) NOT NULL UNIQUE,
    location           VARCHAR(100),
    budgetAmount       NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (budgetAmount >= 0),
    divisionCode       VARCHAR(20),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE departments IS '部署マスタ（人事ドメイン・予算管理）';
COMMENT ON COLUMN departments.budgetAmount IS '年間予算（実行計画: 集計・フィルタ演習用）';

CREATE TABLE employees (
    employeeId         SERIAL PRIMARY KEY,
    departmentId       INTEGER NOT NULL REFERENCES departments(departmentId),
    employeeCode       VARCHAR(20) UNIQUE,
    employeeName       VARCHAR(100) NOT NULL,
    email              VARCHAR(255) NOT NULL UNIQUE,
    jobTitle           VARCHAR(100) NOT NULL,
    employmentTypeId   INTEGER REFERENCES employmentTypeMaster(employmentTypeId),
    jobGradeId         INTEGER REFERENCES jobGradeMaster(jobGradeId),
    salary             NUMERIC(10, 2) NOT NULL CHECK (salary > 0),
    hireDate           DATE NOT NULL,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    managerId          INTEGER REFERENCES employees(employeeId),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE employees IS '従業員マスタ（自己参照: managerId・雇用形態・職級）';

CREATE TABLE salaryHistory (
    historyId          SERIAL PRIMARY KEY,
    employeeId         INTEGER NOT NULL REFERENCES employees(employeeId),
    oldSalary          NUMERIC(10, 2) NOT NULL,
    newSalary          NUMERIC(10, 2) NOT NULL,
    changedAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason             VARCHAR(200)
);

COMMENT ON TABLE salaryHistory IS '給与改定履歴（時系列・ウィンドウ関数演習用）';

CREATE TABLE employeePositions (
    employeePositionId SERIAL PRIMARY KEY,
    employeeId         INTEGER NOT NULL REFERENCES employees(employeeId),
    positionId         INTEGER NOT NULL REFERENCES positionMaster(positionId),
    startDate          DATE NOT NULL,
    endDate            DATE,
    isPrimary          BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (endDate IS NULL OR endDate >= startDate)
);

COMMENT ON TABLE employeePositions IS '従業員役職履歴（positionMaster との紐付け）';

CREATE TABLE employeeSkills (
    employeeSkillId    SERIAL PRIMARY KEY,
    employeeId         INTEGER NOT NULL REFERENCES employees(employeeId),
    skillId            INTEGER NOT NULL REFERENCES skillMaster(skillId),
    proficiencyLevel   SMALLINT NOT NULL CHECK (proficiencyLevel >= 1 AND proficiencyLevel <= 10),
    acquiredDate       DATE,
    certifiedAt        TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (employeeId, skillId)
);

COMMENT ON TABLE employeeSkills IS '従業員スキル（習熟度・資格取得日）';

CREATE TABLE leaveRequests (
    leaveRequestId     SERIAL PRIMARY KEY,
    employeeId         INTEGER NOT NULL REFERENCES employees(employeeId),
    leaveTypeId        INTEGER NOT NULL REFERENCES leaveTypeMaster(leaveTypeId),
    startDate          DATE NOT NULL,
    endDate            DATE NOT NULL,
    totalDays          NUMERIC(4, 1) NOT NULL CHECK (totalDays > 0),
    requestStatus      VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (requestStatus IN ('pending', 'approved', 'rejected', 'cancelled')),
    approvedByEmployeeId INTEGER REFERENCES employees(employeeId),
    reason             TEXT,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (endDate >= startDate)
);

COMMENT ON TABLE leaveRequests IS '休暇申請（休暇種別マスタ・承認フロー）';

CREATE TABLE attendanceRecords (
    attendanceRecordId SERIAL PRIMARY KEY,
    employeeId         INTEGER NOT NULL REFERENCES employees(employeeId),
    workDate           DATE NOT NULL,
    clockInTime        TIME,
    clockOutTime       TIME,
    workHours          NUMERIC(5, 2) CHECK (workHours IS NULL OR workHours >= 0),
    attendanceStatus   VARCHAR(20) NOT NULL DEFAULT 'present'
        CHECK (attendanceStatus IN ('present', 'absent', 'late', 'early_leave', 'holiday')),
    notes              VARCHAR(200),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (employeeId, workDate)
);

COMMENT ON TABLE attendanceRecords IS '勤怠記録（出退勤・勤務時間）';

CREATE TABLE performanceReviews (
    performanceReviewId SERIAL PRIMARY KEY,
    employeeId         INTEGER NOT NULL REFERENCES employees(employeeId),
    reviewerEmployeeId INTEGER NOT NULL REFERENCES employees(employeeId),
    reviewPeriodStart  DATE NOT NULL,
    reviewPeriodEnd    DATE NOT NULL,
    overallRating      SMALLINT NOT NULL CHECK (overallRating BETWEEN 1 AND 5),
    reviewStatus       VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (reviewStatus IN ('draft', 'submitted', 'approved', 'archived')),
    comments           TEXT,
    reviewedAt         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (reviewPeriodEnd >= reviewPeriodStart)
);

COMMENT ON TABLE performanceReviews IS '人事評価（評価期間・総合評点）';

CREATE TABLE trainingCourses (
    trainingCourseId   SERIAL PRIMARY KEY,
    courseCode         VARCHAR(20) NOT NULL UNIQUE,
    courseName         VARCHAR(200) NOT NULL,
    courseType         VARCHAR(30) NOT NULL DEFAULT 'internal',
    durationHours      NUMERIC(5, 1) NOT NULL CHECK (durationHours > 0),
    isMandatory        BOOLEAN NOT NULL DEFAULT FALSE,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE trainingCourses IS '研修コースマスタ（社内・外部研修）';

CREATE TABLE employeeTrainings (
    employeeTrainingId SERIAL PRIMARY KEY,
    employeeId         INTEGER NOT NULL REFERENCES employees(employeeId),
    trainingCourseId   INTEGER NOT NULL REFERENCES trainingCourses(trainingCourseId),
    enrollmentDate     DATE NOT NULL DEFAULT CURRENT_DATE,
    completionDate     DATE,
    trainingStatus     VARCHAR(20) NOT NULL DEFAULT 'enrolled'
        CHECK (trainingStatus IN ('enrolled', 'in_progress', 'completed', 'cancelled')),
    score              NUMERIC(5, 2) CHECK (score IS NULL OR (score >= 0 AND score <= 100)),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (completionDate IS NULL OR completionDate >= enrollmentDate)
);

COMMENT ON TABLE employeeTrainings IS '従業員研修受講履歴（進捗・スコア）';

CREATE TABLE payrollRuns (
    payrollRunId       SERIAL PRIMARY KEY,
    fiscalYearId       INTEGER REFERENCES fiscalYears(fiscalYearId),
    payPeriodStart     DATE NOT NULL,
    payPeriodEnd       DATE NOT NULL,
    paymentDate        DATE NOT NULL,
    runStatus          VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (runStatus IN ('draft', 'processing', 'completed', 'cancelled')),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (payPeriodEnd >= payPeriodStart),
    CHECK (paymentDate >= payPeriodEnd)
);

COMMENT ON TABLE payrollRuns IS '給与計算バッチ（支給期間・支払日）';

CREATE TABLE payrollDetails (
    payrollDetailId    SERIAL PRIMARY KEY,
    payrollRunId       INTEGER NOT NULL REFERENCES payrollRuns(payrollRunId) ON DELETE CASCADE,
    employeeId         INTEGER NOT NULL REFERENCES employees(employeeId),
    baseSalary         NUMERIC(10, 2) NOT NULL CHECK (baseSalary >= 0),
    overtimePay        NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (overtimePay >= 0),
    deductionAmount    NUMERIC(10, 2) NOT NULL DEFAULT 0 CHECK (deductionAmount >= 0),
    netPay             NUMERIC(10, 2) NOT NULL CHECK (netPay >= 0),
    currencyId         INTEGER NOT NULL REFERENCES currencies(currencyId),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (payrollRunId, employeeId)
);

COMMENT ON TABLE payrollDetails IS '給与明細（基本給・残業・控除・手取り）';
