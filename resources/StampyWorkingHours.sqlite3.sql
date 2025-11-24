BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Options" (
	"Key"	TEXT NOT NULL UNIQUE,
	"Value"	TEXT,
	PRIMARY KEY("Key")
);
CREATE TABLE IF NOT EXISTS "Hours" (
	"Day"	INTEGER NOT NULL,
	"TimeStamp"	REAL NOT NULL,
	"FirstOfDay"	INTEGER NOT NULL,
	"Type"	INTEGER NOT NULL,
	"Note"	TEXT
);
CREATE INDEX IF NOT EXISTS "Hours_Day_FirstOfDay" ON "Hours" (
	"Day",
	"FirstOfDay"
);
CREATE INDEX IF NOT EXISTS "Hours_Day" ON "Hours" (
	"Day"
);
CREATE INDEX IF NOT EXISTS "Hours_TimeStamp" ON "Hours" (
	"TimeStamp"
);
COMMIT;
