-- https://dvag.atlassian.net/wiki/spaces/VBL/pages/378773550/061.2.1+bungsaufgaben+2008-10-07+ASS

--SELECT eine Tabelle
-- 
--1. Ermitteln alle VB, die Butter heissen				+++

SELECT m.MAN_NAME_GK AS Name FROM MAN m 
WHERE m.MAN_NAME = 'Butter'
	OR m.MAN_NAME_GK = 'BUTTER'
;

--
--2. Ermitteln alle VB, die Wagner heissen 				+++

SELECT m.MAN_NAME_GK AS Name FROM MAN m 
	WHERE m.MAN_NAME = 'Wagner'
	OR m.MAN_NAME_GK  = 'WAGNER'
	;
--
--3. Ermitteln gültiger Name, Vorname etc. für alle VB zw. 8100000 und 8101000
SELECT m.MAN_NAME_GK AS MAN_NAME , m.MAN_VORNAME_GK AS MAN_NACHNAME , m.MAN_BEZUGS_NR FROM MAN m 
WHERE m.MAN_BEZUGS_NR BETWEEN 8100000 and 8101000
;

--
--4. Ermitteln alle VB der Allfinanz (KNR_GESELLTYP) deren Stellennummer schon vergeben wurde (Tabelle ST)		+++
--   Allfinanz = 3  und  Allfinanz II AG = 5
SELECT count(s.ST_NR) AS anzahl_stellennummer_frei FROM ST s 
--WHERE (KNR_GESELL_TYP = 3 OR KNR_GESELL_TYP = 5)
WHERE KNR_GESELL_TYP IN (3, 5)
AND s.ST_FREI = 'N'
;

--
--5. Häufigkeit der Geburtsdaten aus Tabelle MAN oder mit kommentare kann man je nach Gender gruppieren:			+++
SELECT m.MAN_GEBURTSDAT AS geburtsdatum , count(*) AS AnzahlderPerson 
--, (m.KNR_ANREDE) AS Herr_Frau 
FROM MAN m
--WHERE m.KNR_ANREDE = 1 OR m.KNR_ANREDE = 2
GROUP BY m.MAN_GEBURTSDAT 
--, m.KNR_ANREDE
ORDER BY ANZAHLDERPERSON DESC
;

--
--INNER-JOIN auf mehrere Tabellen
--
--6. Ermitteln alle VB der Allfinanz ab der Stufe ALD (MS_NR = 161) (Tabelle MSBZ und MS)
-- MS_NR = Mitarbeiter Stufennummer
-- MA_ST_NR = Mitarbeiter VB-Nr
SELECT m.MA_ST_NR , m.MS_NR FROM MSBZ m
INNER JOIN MS m2
ON m.MS_NR = m2.MS_NR
where m.MS_NR >= 161
GROUP BY m.MA_ST_NR , m.MS_NR 
;

--
--7. Ermitteln alle VB, die Butter heissen und die aktuell die Stufe D (MS_NR = 667) haben
SELECT m.MAN_NAME_GK AS ManName_WAGNER , m.MAN_VORNAME_GK AS Vorname , m.KTY_ANREDE AS Anrede, m2.ms_nr FROM MAN m 
INNER JOIN MSBZ m2 
ON m.MAN_BEZUGS_NR = m2.MA_ST_NR
WHERE (m2.MS_NR = 667
AND m.MAN_NAME = 'BUTTER')
;

--
--8. Ermitteln alle VB, die Wagner heissen und die aktuell die Stufe D (MS_NR = 667) haben
SELECT m.MAN_NAME_GK AS ManName_WAGNER , m.MAN_VORNAME_GK AS Vorname , m.KTY_ANREDE AS Anrede, m2.ms_nr AS Stufe FROM MAN m 
INNER JOIN MSBZ m2
ON m.MAN_BEZUGS_NR = m2.MA_ST_NR 
WHERE (m2.MS_NR = 667
AND m.MAN_NAME_GK = 'WAGNER')
;
--
--9. Anzahl tätige VB (MAT_DAT_BIS) Tabelle MAT je Vertriebsgesellschaft (KNR_GESELLTYP) Tabelle ST				+++
SELECT count(m.MA_ST_NR) AS Anzahl_taetigeVB , KNR_GESELL_TYP AS Gesellschaft FROM ST s 
INNER JOIN MAT m 
ON s.ST_NR = m.MA_ST_NR 
WHERE m.MAT_DAT_BIS = '31.12.9999'
GROUP BY s.KNR_GESELL_TYP 
;

--
--10. Anzahl gekündigte VB (nur Kündigung in die Zukunft) je Vertriebsgesellschaft (KNR_GESELLTYP)				+++
SELECT count(m.MA_ST_NR) AS Anzahl_gekuendigteVB , s.KNR_GESELL_TYP FROM ST s 
INNER JOIN MAT m 
ON s.ST_NR = m.MA_ST_NR
WHERE m.MAT_DAT_BIS != '31.12.9999'
AND m.MAT_DAT_BIS > CURRENT DATE 
GROUP BY s.KNR_GESELL_TYP
;
--
--11. Ermittlung Anzahl gültiger Anschriften je Land (KTY=17)
SELECT COUNT(m.MAAN_ORT_GK) AS Anzahl_gueltigeAnschrift , m.MAAN_ORT_GK AS Ort FROM MAAN m
WHERE m.KTY_AUSL = 17
AND m.KNR_AUSL > 1  	-- 1 steht für DEU
GROUP BY m.MAAN_ORT_GK
;
--
-- 
--
--OUTER-JOIN
--
--12. Liste aller tätigen Mitarbeiter (MAT_DAT_BIS) der Allfinanz in der Form VB-Nr, MS-Nr, Praxisstufe (VBPZ)
SELECT count(m.MA_ST_NR) AS Anzahl_MS_Nummer , v.VBP_NR AS praxisStufe FROM VBPZ v
LEFT OUTER JOIN MAT m 
ON v.MA_ST_NR = m.MA_ST_NR
WHERE m.mat_dat_bis = '31.12.9999'
GROUP BY v.VBP_NR
;
--
-- Beispiel für mehrere Joins in einer Abfrage
SELECT m.MA_ST_NR , m2.ms_nr , v.vbp_nr FROM MAT m
JOIN vbpz v ON m.MA_ST_NR = v.MA_ST_NR 
JOIN ST s ON m.MA_ST_NR = s.ST_NR
JOIN MSBZ m2 ON m.MA_ST_NR = m2.MA_ST_NR
WHERE m.MAT_DAT_BIS = '31.12.9999'
	AND s.KNR_GESELL_TYP IN (3,5)
;
--
-- 
--
--praktische Anwendung:
--
--ad-hoc-Auswertung für Kaschade ->
--
--Database 'AS-System&uuml;bersicht', View 'Nach Kategorie (Hauptansicht)', Document 'Auswertung zu ED-Konten f&uuml;r Kaschade'