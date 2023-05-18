-- 微博数据表 --
CREATE TABLE  IF NOT EXISTS "T_Status" (
  "statusid" INTEGER NOT NULL,
  "status" TEXT,
  "userid" INTEGER,
  "createTime" TEXT DEFAULT (datetime('now','localtime')),
  PRIMARY KEY ("statusid")
);
