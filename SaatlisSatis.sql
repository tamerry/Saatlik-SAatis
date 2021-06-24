DECLARE @TARIH SMALLDATETIME;
DECLARE @DAKIKA INT;
DECLARE @GUNILK SMALLDATETIME;
DECLARE @GUNSON SMALLDATETIME;
DECLARE @SAAT INT;
DECLARE @SAYAC TINYINT;
SET @TARIH = GETDATE();
SET @SAAT = DATEPART(HOUR, GETDATE());
SET @DAKIKA = DATEPART(MINUTE, @TARIH);
SET @GUNILK = DATEADD(MINUTE, -@DAKIKA, DATEADD(HOUR, -@SAAT, @TARIH));
SET @SAYAC = 1;
WHILE @SAYAC <= 24
BEGIN
    SET @GUNSON = DATEADD(HOUR, @SAYAC, @GUNILK);
    SELECT
		
        CONVERT(NVARCHAR(30), DATEPART(HOUR, DATEADD(HOUR, -1, @GUNSON))) + '-'
        + CONVERT(NVARCHAR(10), DATEPART(HOUR, @GUNSON)) 'SAAT',
        COUNT(TH.ID) 'BELGE ADEDİ',
        ISNULL(SUM(ISNULL(   CASE PTYPE
                                 WHEN 2 THEN
                                     - (GROSS_TOTAL)
                                 WHEN 1 THEN
                                     GROSS_TOTAL - (TH.DISCOUNT_ON_LINES + TH.DISCOUNT_ON_TOTAL)
                                 WHEN 0 THEN
                                     GROSS_TOTAL - (TH.DISCOUNT_ON_LINES + TH.DISCOUNT_ON_TOTAL)
                                 ELSE
                                     0
                             END,
                             0
                         )
                  ),
               0
              ) 'SATIŞ',
        ISNULL(SUM(ISNULL(   CASE PTYPE
                                 WHEN 2 THEN
                             (GROSS_TOTAL)
                             END,
                             0
                         )
                  ),
               0
              ) 'İADE'
			   
    FROM GENIUS3.TRANSACTION_HEADER TH WITH (NOLOCK)
        JOIN GENIUS3.STORE ST
            ON ST.ID = TH.FK_STORE
    ------------
    WHERE DATEPART(HOUR, TH.TRANS_DATE) > DATEPART(HOUR, (DATEADD(HOUR, -1, @GUNSON)))
          AND DATEPART(HOUR, TH.TRANS_DATE) < DATEPART(HOUR, DATEADD(HOUR, 1, @GUNSON))
          --AND TH.FK_STORE = 10038
          AND TH.TRANS_DATE >= @GUNSON
          AND TH.STATUS = 0
	
    ORDER BY 2 ASC;
    SET @SAYAC = @SAYAC + 1;
END;
