-- CreateTable
CREATE TABLE "Blacklist" (
    "token" TEXT NOT NULL,
    "expiration" INTEGER NOT NULL,

    CONSTRAINT "Blacklist_pkey" PRIMARY KEY ("token")
);

-- CreateIndex
CREATE INDEX "black_expiration" ON "Blacklist"("expiration");
