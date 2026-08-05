JCL ist kein Hexenwerk! x)

# ETAPPEN --
## Wie organisiert der Mainframe Prozesse
Mainframe ist Überfluss von Resourcen == gteilter Reichtum = viel Arbeitsspeicher, viel Rechnenpower, viele Schnittstellen
CPU == Rechnenwerk
CPU kann zw. 0-15 Register halten.
CPU besitzt einen temporären Speicher (Arbeitsspeicher), der nur beschränkt groß ist.
### Computer mit mehreren CPUs
CPUs werden so gestalltet damit sie beim Arbeiten einanderen gegenseitig nicht behindern.   
Viele User, aber nur 1 Rechner == Batch geboren ; Paketverarbeitungen können von Batch automatisch nacheinander abgearbeitet werden.
Damit die User nicht in der Schlange stehen müssen, geben sie sie dem Operator, um ihre Jobs beim Teil des Betriebssystem zu serialisieren.
Viele Jobs sollen regelmäßig laufen. Dafür gibt es Planung. Planung wird per WorkloadScheduler (alias IWS, TWS, OPC) eingestellt. In der Planung stehen die Jobbeschreibungen und auch Plandaten wie an welchen Tagen sollen die Jobs laufen, oder ob sie Abhängigkeiten haben usw.

#Batch/Online-Prozesse == Zugangsrechte (UserID + Passwort) - Abrechnung (Accounting Angaben) - Hardware (Welcher Rechner soll genutzt werden?)

JCL(Job Control Language) beschreibt dem Mainframe das Arbeitspaket.

### Time-Sharing
Der Computer bearbeitet mehrere Tasks, zaischen denen er hin und her schaltet.
Damit nehme Prozesse, die zB. auf Resourcen oder Usereingaben warten, keine Rechnerkapazitäten weg.
Beim Swapping wird der Speicherinhalt von solchen temporär unterbrochenen Prozessen auf sehr schnelle Speicher ausgelagert bzw. von dort wieder geladen.

weitere Begriffe:
-LPAR - logical partition
-CPU - central processing unit : Kernbestandteil eines modernen Computers
-CPU-Zeit :  misst nur die Momente, in denen der Prozessor rechnet.
-Sysplex/Plex : IBM-Großrechner-Cluster, das mehrere z/OS Systeme verbindet.
-swapping
## Warum ist JCL so, wie sie ist?
### JCL - wie ein Spiel mit 3 Karten
1. Job-Statement
    a. Zugangsdaten
    b. gewünschter Rechner
    c. Accounting
2. EXEC-Statement
    a. Initialprogramm
    b. Rssourcen
    c. evtl. Parameter
3. DD-Statement
    a. Dateihandling

### Job-Start (Job-Statement)
JCL --------------------------------------------------> JES (Job Entry-Subsystem)
      via
        * Submit aus ISPF
        * Netwerk (Marple/CCM, FTP)
        * Pgm, das JCL auf den Internal Reader schreibt

        ** hinter dem JES verbirgt sich der Job Manager -
            1. JCL Syntax geprüft
            2. die Credentials ok ?
            3. gültige Accounting Angaben vorliegen ?
            4. Job in der Warteschlange ordentlich läuft.
        ** Spool Management - temporäre Protokoll halterung, Datei Einschreibung vom gelaufenen Job.
### Programm-Start (EXEC Statement)        
        ** Task-Manager -
            1. Pgm
            - wo die Dateien und die Pgms sich befinden, kümmert sich drum der Datei-Manager
            - DD(Data definition)-Namen Statement stehen für die Dateien welche für Output genutzt werden sollen und wird vom Task-Manager benutzt. Manche Steps haben mit DD-Namen nichts zu tun wie zB. Steplib Karte.       
            - Steplib Karte beinhaltet die Pgms Namen welche Datei Manager beim Finden der Datei/ des Pgms benutzt. Falls im Job kein Steplib Karte bestimmt ist, nimmt Datei-Manager Default Wert was als Entwickler so sinnvoll ist.
               
            2. virtueller Speicher
### Statement Reihenfolge
1. Job Manager (Job Statement) 
    -- ruft -->
2. Task Manager (Exec Statement)
    -- ruft -->
3. Datei Manager (DD-Statements)
### Syntax REGELN
//SCHRITT1 EXEC PGM=PGCE4711,REGION=4M
//* Kommentare

ODER
//[JCL-Indikator][Job/Step/DD-Name]Blanks[Statement-Schlüsselwert]Blanks[Statement-Parameter]

// : markiert ein JCL Statement
SCHRITT1 : Name(von Job/Step/DD-Name) / JCL Indikator
Stelle von EXEC für Schlüsselwort des Stmts
PGM=XXX : Parameter des Stmts ohne trennende Blanks.
//* : Kommentare

** nur Stellen 1-72 werden beachtet!
** Stellen 73-80 sind Kommentar
## Der kleinstmögliche Job
### JCL-Syntax : (JCL Syntax Check : jck)
//name JOB (accounting),username,CLASS=class,MSGCLASS=outclass BlaBla
Identifier : // Jcl statements
             //* kommentare
             /*  Daten, die zu einem DD-Statement gehören 
name : alphanumerisch (Länge 1-8) auch mit Sonderzeichen
JOB : Operation Field
(accounting) : Parameter/Operand, können mehrere hintereinander mit Komma geschrieben werden.
CLASS : Job Klasse
BlaBla : Comment
ab CLASS bis Kommentara - Field : Keyword Parameters
### JOB KARTEN BEISPIELE : 
1. //ALPHA JOB 843,LINLEE,CLASS=F,MSGCLASS=A,MSGLEVEL=(1,1)
2. //LOS JOB 1863 THIS IS THE THIRD JOB STATEMENT. << weil Jobname numerisch ist, brauchen wir hier keine Hochkommas >>
3. //RACF1 JOB 'D83,123',USER=RAC01,PASSWORD=XYY
### EXEC-Karte mit Minimal Parametern
//SCHRITT1 EXEC PGM=IEFBR14
Stepname: Schritt1
Schlüsselwort: EXEC
auszuführendes Pgm IEFBR14 = 2. zeiliges Assembler Pgm das returns nur RC 0.
+ ohne Pgm-Aufruf kein Zugang zum Datei-Manager
+ IEFBR14 wird verwendet wenn man nur Dateien anlegen/löschen möchte.
+ wenn man neue JCL erstellt wird, sollte per jem die Snytax geprüft werden.
+ JCL submitten : in Editor per sub Command
Jobskontrolle: per SDSF
### Job-Mini Aufgabe I003427.JCL101.CNTL(AUFGB1) 
    und Lösung liegen in Lib: I003427.JCL101.CNTL(JBMINI)
## Ein Pgm im Batch ausführen
//Schritt1 EXEC PGM=pgmName,PARM='pgmparameter'
PGM= Programm das ausgeführt werden soll
### EXEC-Karte mit Anwendungsprogramm
* COND=     >> unter welcher Bedingung der Step nicht ausgeführt werden soll
* REGION=   >> Mindest-Speicheranforderung des Steps
* TIME=     >> maximale CPU-Zeit des Steps
### STEPLIB-DD-Karte
Dateimanager will wissen wo er das Pgm finden soll.
//DD-Name DD DISP='parallele Laufen der Prozesse erlaubt',DSN='Path des PGMs'
//STEPLIB DD DISP=SHR,DSN=TANJAS.TEST.PGMS
-- Aber auch existieren JOBLIB-DD-Karte --> Suchdefault für den ganzen Job
### Concatenation: 1 DD-Name mehrere DSNs
-- Limits: bei PO-Dateien (wie Lademodul-Bibliotheken) 16Dateien
--          bei PS-Dateien (wie Datenfiles) 256Dateien
//STEPLIB DD DISP=SHR,DSN=USERID.TEST.PGMS
//        DD DISP=SHR,DSN=USERID2.TEST.PGMS
### Programm-Test-Jobs
//* ------------------- Batch-Programm ausfuehren ----------
//PGTQ0012 EXEC GOBTCH,MBR=PGTQ0012,SYSKZ='1'
//GO.MANDANT DD DISP=SHR,DSN=P110003.CGMAND.VK(CGMAND00)
![Pgm-Test-Jobs_beiuns](image.png)
## Einführung in Dateiarten
1. DSORG : Physical Sequential (PS) : eine Zeile nach anderer.
2. DSORG: Partitioned Dataset (PDS/PDSE) : 
    a. Datei (Bibliothek): enthält viele Sequentiale Datei die sich Member nennt.(Einzel-PS-Files)
        DSN=MY.PDS.DATASET
        DSN=MY.PDS.DATASET(BIRNE)
    ** Benennung der DSN ** 
    * klein-groß schreiben spielt keine Rolle.
    * jeder qualifier dürfen max. 8-stellig sein. (alphanumerisch + Sonderzeichen($,#,§))
    * max. 44 stellig inkl. Punkten
    * Klammern und Stellen des Membernamens zählen dabei nicht mit.
        DSN=quali1.quali2.quali3(&mydata1)
LRECL: Satzfomrate : feste Satzlänge, variable Satzlänge     
BLKSIZE: Lesen/Schreiben in Portionen: hat die Auswirkung auf die Geschwindigkeit.
    Device
    Track
    BLKSIZE=O  >> fürs Device optimierte Blockgröße
SPACE: Primary, Secondary(bildet extend dazu, wenn die Datei größer als vorreservierter Platz ist, max 16mals (PDSE 128) möglich)
### VSAM(Virtual Storage Access Method)
    GDG(Generation Data Group):
    a. KSDK - Key sequential Dataset
    b. ESDS - Enrty sequential Dataset
    c. RRDS - Relative Record Dataset
    d. LDS - Linear Dataset
## Dateien anlegen/löschen
DD-Karte Minimum zur Dateianlage
//ddname DD DSN=...,
//          DISP=...,RECFM=...,LRECL=...,BLKSIZE=0,
//          SPACE=...,MGMTCLAS=...

### DSN: Dateinamen
### DISP; Basis-Disposition: sollte nebenbei Prozesse laufen dürfen, Modis bei normalem oder abnormalem Beenden
    ** JCL erlaubt 3 aufeinmal.
    DISP=([status][,normal-termination-disp][,abnormal-termination-disp(beim Abend)])
#### Status
    a. NEW ***(Default)*** : Neuanlage, DS noch nicht vorhanden. Solange dieser Job läuft, kann kein anderer Prozess das DS zugreifen.
    b. OLD : exlusive Zuordnung zum aktuellen Prozess. DS vorhanden, kein anderer Prozess lesen/schreiben soll. >> typisch bei Schreibvorgänge
    c. SHR : alle Prozesse, die das DS mit sHR ansprechen, dürfen sie nutzen. DS vorhanden, alle dürfen die Datei nutzen >> typisch wenn nur gelesen wird.
    d. MOD : Bei Schreibvorgängen wird hinten an die Datei geschrieben. DS vorhanden, exkl. Zugriff. >> typisch wenn Dateien (zB. Log Dateien) fortgeschrieben werden.
#### Normal-Termination-Disposition            
    a. DELETE ***(Default)*** : Datei wird gelöscht; Empfohlen wenn Datei entfallen kann
    b. KEEP ***(Default)*** : eine neue Datei wird auf einem Volume angelegt und im Catalog eingetragen; Empfohlen neues DS nach Jobende noch bleiben soll
    c. PASS : eine neue Datei wird angelegt und bleibt für den Folgestep erhalten; Empfohlen neues DS beim nächsten Step noch da sein soll
    d. CATLG : eine neue Datei bleibt erhalten nund wird im Catalog eingetragen; Empfohlen neues DS und man sicherstellen will, dass es im Catalog eingetragen ist.
    e. UNCATLG : Dateieintrag wird nr aus dem Catalog entfernt; Empfohlen : in der GDIS nicht möglich da alle Dataset im Catalog sein müssen.
#### Abnormal-Termination-Disposition
    a. DELETE
    b. KEEP
    c. CATLG
    d. UNCATLG
    ***(Default)*** : entsprechend dem 2. Parameter
    bei PASS: DELETE für neues, KEEP für bestehendes DS
### RECFM: fest/variable Satzlänge, geblock/ungeblock
#### RECFM Syntax
RECHFM={U     }  [A]        >> undefinierte Satzlänge  A >> Sätze enthalten ISO/ANSI control characters
       {V     }  [M]        >> variable Satzlänge   M >> Sätze enthalten machine code control characters
       {VB    }             B >> Datei soll geblockt sein
       {VS    }             S >> Dataset darf über mehrere Volumes laufen
       {VBS   }             
       {F     }             >> feste Satzlänge
       {FB    }
* Beispiele:
//DD1B DD DSNAME=EVER,DISP=(NEW,KEEP),UNIT=3380,
//        RECFM=FB,LRECL=326,SPACE=(23472,(200,40))

//DD2  DD  DSNAME=FIX,UNIT3420-1,VOLUME=SER=44889,
//         DISP=(OLD,,DELETE)
### LRECL: Satzlänge
in BYTES eingegeben.
LRECL=(nnnnnK)      >> Anzahl der Bytes pro Satz
Beispiel:
//DS1 DD DISP=(NEW,CATLG),RECFM=FBA,LRECL=133,...
###  BLKSIZE=0 : Device abgestimmte Blockgröße
Falls RECFM als Blocked eingegeben, sollte default Wert für BLKSIZE=0 sein.
###  SPACE: primary/secondary Größenangaben
wie viel Speichergröße wollen wir für die Datei im Mainframe beansprechen möchten? 
###  MGMTCLAS; Management Class: Sicherung, Lebenszeit...
Verlagerung der Dateien nach bestimmten Kriterien. Automatische Löschung von Dateien nach bestimmten Kriterien(Alter, mangelnde Nutzung), automatische Freigabe von ungenutzen Platz von Dateien. Beispiel MGMTCLAS=MCS30010,...
### UNIT Syntax
UNIT=WORK : Workplattenpool, nach einer Weile werden die Dateien automatisch gelöscht.
     SYSDA : normaler Plattenpool 
     VIO : Virtuelle IO, direkt in Speicher gehalten werden
     TAPE : Kasetten.
### Temporäre Dateien / Work Dateien
//DS1 DD DISP=NEW,RECFM=FBA,LRECL=133,UNIT=WORK,
//       SPACE=(CYL,(1,1))
** unbenannte Datei: DSN= wird weggelasen, weil nur dieser Step auf diese Datei zugreift.

//DS1 DD DISP=(NEW,PASS), RECFM=FBA,LRECL=133,UNIT=WORK,
//       DSN=&&TEMP1,SPACE=(CYL,(1,1))
** Datei für Folgestep wird am Ende des Jobs die Datei gelöscht.

//DS1 DD DISP=(NEW,PASS),RECFM=FBA,LRECL=133,UNIT=WORK,
//       DSN=MY.WORK.DATEI,SPACE=(CYL,(1,1))
** PASS sichert die Datei für Folgestep aber nicht über das Jobende hinweg. 

//DS1 DD DISP=(NEW,KEEP),RECFM=FBA,LRECL=133,UNIT=WORK,
//       DSN=MY.WORK.DATEI,SPACE=(CYL,(1,1))
** KEEP sorgt für die Kategorisierung und damit dem dauerhaften Erhalt der Datei auch nach Ende des Jobs. Die Datei verschwindet also erst bei Aufräumarbeiten im Work-Pool oder wenn man zusätliche Angaben macht wie: RETPD=10 (retain period 10days.), oder eine entsprechende Managementsklasse(MGMTCLAS).
### LIKE Syntax
übernimmt die Vorlage-Datei.
1. Dataset Organization
    a. Record organization (RECORG)
        OR
    b. Record Format (RECFM)
2. Record Length (LRECL)
3. Key Length (KEYLEN)
4. Key Offset (KEYOFF)
5. Type (DSNTYPE)
6. Space allocation (AVGREC and SPACE)

//SMSDS6 DD DSNAME=MYDS6.PGM,LIKE=MYDSCAT.PGM,DISP=(NEW,KEEP)

//DD1 DD DSN=MY.PDSE.DATEI,DISP=(,CATLG),
//       LIKE=MY.PDS.DATEI,
//       DSORG=PO,DSNTYPE=LIBRARY,
//       MGMTCLAS=MCS19999
! BLKSIZE und MGMTCLAS werden nicht übernommen !
### VOL Syntax : 
auf welches Device sollte die Datei angelegt werden soll.
heutzutage spielt fast gar keine Rolle mehr, solange man nicht auf bestimmte/s Kassette/Device zugreifen will.
## Conditionscode-Steuerung
## Utuilities
## Spezielle Pgms => spezielle Bedürfnisse
## Prodezuren verstehen
## Produktions-JCL, eine andere Welt ?

##### Deepnote:
Die Lernnotizen stammen vom Kurs: 
https://de0a000085dde.de.top.com/training/elearning/MARPLE%20JCL%20101%20-%20Storyline%20output/story.html