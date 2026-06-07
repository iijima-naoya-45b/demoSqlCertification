import type { GuideArticle, LearnSection, SkillLevel } from './types'

const startGuides: GuideArticle[] = [
  {
    articleId: 'welcome',
    title: 'DemoShop SQL演習へようこそ',
    summary: 'このアプリの目的と学習の進め方を説明します。',
    readTimeMinutes: 3,
    isRequired: true,
    blocks: [
      { type: 'paragraph', text: 'DemoShop は、実務に近い PostgreSQL データベース（105テーブル）を使って SQL を学ぶための演習環境です。通販サイトの管理画面と SQL サンドボックスが一体になっています。' },
      { type: 'heading', text: '推奨する学習の流れ', level: 2 },
      { type: 'list', items: [
        '① この「はじめに」セクションを読む',
        '② 初級の解説 → 演習01 をサンドボックスで実行',
        '③ 中級（JOIN・集計・サブクエリ）へ進む',
        '④ 上級（ウィンドウ関数・EXPLAIN・関数）に挑戦',
      ], ordered: true },
      { type: 'tip', title: '初心者の方へ', text: 'いきなり全問解こうとせず、解説を読んでからサンプル SQL を1本実行してみてください。' },
    ],
  },
  {
    articleId: 'database-overview',
    title: 'データベース構成の概要',
    summary: 'customers / orders / products など主要テーブルを把握します。',
    readTimeMinutes: 5,
    isRequired: true,
    blocks: [
      { type: 'paragraph', text: 'デモDBは EC + 人事をテーマにした大規模スキーマです。演習では主に以下のテーブルを使います。' },
      { type: 'list', items: [
        'customers — 顧客（会員ランク・都道府県）',
        'orders / orderItems — 注文ヘッダ・明細',
        'products / categories — 商品・カテゴリ',
        'employees / departments — 従業員・部署',
        'productReviews — 商品レビュー',
      ] },
      { type: 'code', language: 'sql', code: "-- テーブル一覧の確認（サンドボックスで実行可）\nSELECT table_name\nFROM information_schema.tables\nWHERE table_schema = 'public'\nORDER BY table_name\nLIMIT 20;" },
      { type: 'tip', title: 'データ件数', text: 'customers 約1万件、orders 約5万件など、実行計画の演習にも十分なデータ量があります。' },
    ],
  },
  {
    articleId: 'sandbox-rules',
    title: 'SQLサンドボックスのルール',
    summary: '実行できる SQL とブロックされる操作を理解します。',
    readTimeMinutes: 4,
    isRequired: true,
    relatedExerciseIds: ['01'],
    blocks: [
      { type: 'paragraph', text: 'サンドボックスでは安全のため、読み取り専用の SQL のみ実行できます。危険な操作は監査（auditLogs）に記録されたうえで拒否されます。' },
      { type: 'heading', text: '実行できるもの', level: 3 },
      { type: 'list', items: ['SELECT', 'WITH（CTE）', 'EXPLAIN / EXPLAIN ANALYZE', 'SHOW'] },
      { type: 'heading', text: 'ブロックされるもの', level: 3 },
      { type: 'list', items: ['DELETE / DROP / TRUNCATE', 'UPDATE / INSERT', 'CALL（ストアドプロシージャ）', '複数 SQL の同時実行'] },
      { type: 'warning', text: 'DELETE などを試すと 403 エラーとともに auditStatus: BLOCKED が返ります。意図的なセキュリティ演習にも使えます。' },
    ],
  },
  {
    articleId: 'learning-path',
    title: 'レベル別カリキュラムマップ',
    summary: '初級〜上級までの到達目標と演習番号の対応表です。',
    readTimeMinutes: 3,
    isRequired: true,
    blocks: [
      { type: 'list', items: [
        '初級 ★☆☆ — 演習01: SELECT / WHERE / ORDER BY',
        '中級 ★★☆ — 演習02〜04: JOIN / 集計 / サブクエリ',
        '上級 ★★★ — 演習05〜08: ウィンドウ関数 / CTE / EXPLAIN / 関数',
      ] },
      { type: 'tip', title: '上級者の方へ', text: '演習07（EXPLAIN）と08（関数・トリガー）は、DBA・パフォーマンスチューニング寄りの内容です。' },
    ],
  },
]

const beginnerGuides: GuideArticle[] = [
  {
    articleId: 'select-basics',
    title: 'SELECT の基本',
    summary: '列の指定、別名、LIMIT の使い方を学びます。',
    readTimeMinutes: 6,
    relatedExerciseIds: ['01'],
    blocks: [
      { type: 'paragraph', text: 'SELECT はテーブルからデータを取得する最も基本的な文です。' },
      { type: 'code', language: 'sql', code: 'SELECT productId, productName, unitPrice\nFROM products\nORDER BY unitPrice DESC\nLIMIT 10;' },
      { type: 'heading', text: 'ポイント', level: 3 },
      { type: 'list', items: [
        '必要な列だけ指定すると結果が読みやすくなります',
        'ORDER BY で並べ替え、LIMIT で件数を制限できます',
        'PostgreSQL では未引用の識別子は小文字に正規化されます',
      ] },
    ],
  },
  {
    articleId: 'where-filter',
    title: 'WHERE による絞り込み',
    summary: '条件式と比較演算子を使ったフィルタリング。',
    readTimeMinutes: 5,
    relatedExerciseIds: ['01'],
    blocks: [
      { type: 'code', language: 'sql', code: "SELECT customerName, prefecture\nFROM customers\nWHERE prefecture = '東京都';" },
      { type: 'list', items: [
        '=, <>, <, >, <=, >= で比較',
        'AND / OR で条件を組み合わせ',
        'IS NULL / IS NOT NULL で NULL 判定',
        'IN, BETWEEN, LIKE もよく使います',
      ] },
    ],
  },
]

const intermediateGuides: GuideArticle[] = [
  {
    articleId: 'join-guide',
    title: 'JOIN の考え方',
    summary: 'INNER JOIN と LEFT JOIN の違いを理解します。',
    readTimeMinutes: 8,
    relatedExerciseIds: ['02'],
    blocks: [
      { type: 'paragraph', text: '複数テーブルを関連付けて1つの結果セットにまとめるのが JOIN です。' },
      { type: 'code', language: 'sql', code: 'SELECT o.orderId, c.customerName, o.orderDate\nFROM orders o\nJOIN customers c ON c.customerId = o.customerId\nLIMIT 20;' },
      { type: 'tip', title: 'LEFT JOIN', text: '左表の全行を残し、右表に一致がなければ NULL になります。存在しない顧客の注文などを探すときに使います。' },
    ],
  },
  {
    articleId: 'aggregation-guide',
    title: 'GROUP BY と集計関数',
    summary: 'COUNT / SUM / AVG と HAVING の使い分け。',
    readTimeMinutes: 8,
    relatedExerciseIds: ['03'],
    blocks: [
      { type: 'code', language: 'sql', code: 'SELECT membershipTier, COUNT(*) AS customerCount\nFROM customers\nGROUP BY membershipTier\nORDER BY customerCount DESC;' },
      { type: 'paragraph', text: 'GROUP BY でグループ化したあと、HAVING でグループ単位の条件を指定できます（WHERE は行単位）。' },
    ],
  },
  {
    articleId: 'subquery-guide',
    title: 'サブクエリ入門',
    summary: 'スカラ・相関・EXISTS のパターンを整理します。',
    readTimeMinutes: 10,
    relatedExerciseIds: ['04'],
    blocks: [
      { type: 'code', language: 'sql', code: 'SELECT productName\nFROM products p\nWHERE NOT EXISTS (\n  SELECT 1 FROM productReviews r WHERE r.productId = p.productId\n);' },
      { type: 'tip', title: 'EXISTS', text: '行の存在チェックに使い、NOT EXISTS は「1件もない」条件に向いています。' },
    ],
  },
]

const advancedGuides: GuideArticle[] = [
  {
    articleId: 'window-functions',
    title: 'ウィンドウ関数',
    summary: 'RANK / ROW_NUMBER / SUM() OVER の基本。',
    readTimeMinutes: 12,
    relatedExerciseIds: ['05'],
    blocks: [
      { type: 'code', language: 'sql', code: 'SELECT employeeName, salary,\n  RANK() OVER (PARTITION BY departmentId ORDER BY salary DESC) AS deptRank\nFROM employees\nLIMIT 20;' },
      { type: 'paragraph', text: 'PARTITION BY でグループを分け、ORDER BY で並べたうえでランクや累計を計算します。' },
    ],
  },
  {
    articleId: 'cte-case',
    title: 'CTE と CASE 式',
    summary: '可読性の高いクエリを書くテクニック。',
    readTimeMinutes: 10,
    relatedExerciseIds: ['06'],
    blocks: [
      { type: 'code', language: 'sql', code: 'WITH monthly AS (\n  SELECT DATE_TRUNC(\'month\', orderDate) AS m, COUNT(*) AS cnt\n  FROM orders GROUP BY 1\n)\nSELECT * FROM monthly ORDER BY m;' },
    ],
  },
  {
    articleId: 'explain-guide',
    title: 'EXPLAIN で実行計画を読む',
    summary: 'Seq Scan / Index Scan / Join 方式の見方。',
    readTimeMinutes: 12,
    relatedExerciseIds: ['07'],
    blocks: [
      { type: 'code', language: 'sql', code: "EXPLAIN ANALYZE\nSELECT * FROM customers WHERE prefecture = '東京都';" },
      { type: 'list', items: [
        'Seq Scan — 全表スキャン（インデックス未使用）',
        'Index Scan — インデックスを利用',
        'cost / rows / actual time を比較してチューニング判断',
      ] },
    ],
  },
  {
    articleId: 'routines-guide',
    title: '関数・プロシージャ・トリガー',
    summary: 'DB に登録されたルーチンの呼び出し方。',
    readTimeMinutes: 8,
    relatedExerciseIds: ['08'],
    blocks: [
      { type: 'code', language: 'sql', code: 'SELECT fn_calcOrderTotal(1);' },
      { type: 'warning', text: 'CALL によるプロシージャ実行はサンドボックスではブロックされます。psql や DBeaver で確認してください。' },
    ],
  },
]

export const learnSections: LearnSection[] = [
  {
    sectionId: 'start',
    title: 'はじめに',
    subtitle: '最初に読むべき内容',
    difficultyLabel: '必読',
    description: 'アプリの使い方・DB概要・サンドボックスルールを確認してから演習に進みましょう。',
    order: 0,
    colorClass: 'border-emerald-200 bg-emerald-50',
    guides: startGuides,
    exerciseIds: [],
  },
  {
    sectionId: 'beginner',
    title: '初級',
    subtitle: 'SQL の基礎',
    difficultyLabel: '★☆☆',
    description: 'SELECT / WHERE / ORDER BY をマスターします。SQL を初めて学ぶ方はここから。',
    order: 1,
    colorClass: 'border-sky-200 bg-sky-50',
    guides: beginnerGuides,
    exerciseIds: ['01'],
  },
  {
    sectionId: 'intermediate',
    title: '中級',
    subtitle: '結合と集計',
    difficultyLabel: '★★☆',
    description: 'JOIN・GROUP BY・サブクエリで複数テーブルを扱います。',
    order: 2,
    colorClass: 'border-amber-200 bg-amber-50',
    guides: intermediateGuides,
    exerciseIds: ['02', '03', '04'],
  },
  {
    sectionId: 'advanced',
    title: '上級',
    subtitle: '分析・チューニング',
    difficultyLabel: '★★★',
    description: 'ウィンドウ関数、CTE、実行計画、DB ルーチンまで扱います。',
    order: 3,
    colorClass: 'border-rose-200 bg-rose-50',
    guides: advancedGuides,
    exerciseIds: ['05', '06', '07', '08'],
  },
]

export function getSectionById(sectionId: SkillLevel): LearnSection | undefined {
  return learnSections.find((section) => section.sectionId === sectionId)
}

export function getArticle(sectionId: SkillLevel, articleId: string): GuideArticle | undefined {
  const section = getSectionById(sectionId)
  return section?.guides.find((guide) => guide.articleId === articleId)
}

export function getRequiredGuides(): GuideArticle[] {
  return learnSections.flatMap((section) =>
    section.guides.filter((guide) => guide.isRequired),
  )
}
