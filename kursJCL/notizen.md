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
![image](./image.png)
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
*Bei Produktionsabläufen: jeder Step ein eigener Job
* Abhängigkeiten werden in TWS definieren.
### IF/ELSE/ENDIF Steuerung
if/else/endif dürfen nicht direkt hinter // stehen. Nach // sollten IF/ELSE/ENDIF einen Name als Stepname haben, wie bei //[JobName] JOB
Die Namen müssen nicht unbedingt wie bei IF-Step gleiche Namen haben.
** Beispiel 1 **
//[namefuerIF] IF STEP1.RC=0 THEN
//STEP2 EXEC ...
....
//[namefuerELSE]
//STEP3 EXEC ...
....
//[namefuerENDIF] ENDIF
||-------                                                                     
||* prüft ob der Step gestartet wurde:                          
||StepName.Run                                                    
||StepName.Run=True                                             
||* prüft ob irgendeiner Vor-Step abnormal beendet wurde:       
||Abend                                                             
||Abend=True                                                    
||-------                                                                       
||* prüft ob im Step abnormaler Stop vorgekommen ist:                   
||StepName.Abend                                                                             
||StepName.Abend=True                                            
||-------                                                   
||* reagiert nur bei bestimmten AbendsCodes                                     
||AbendCC=abendcode                                                     
||stepname.Abendcc=abendcode                                            
||-------                                                                   
** Beispiel 2 **                                                  
// IF RC NE 0 OR ABEND THEN 
//STEP4 EXEC ...
// ENDIF     
// IF ABEND=TRUE THEN
//STEP5 EXEC ...
....
// ENDIF                                       

** Beispiel 3 **
//STEP0 EXEC PGM=PGM1
//iftest1   if (rc<8>) then
//step1 exec pgm=iefbr14
//report exec pgm=reptpgm
//elsetest   else
//errorstp  exec pgm=errpgm
//endif1     endif
//nextstep  exec pgm=pgm2

** Beispiel 4 **
//step1 exec pgm=...
//iftest1  if abend   then
//step2 exec pgm=...
//step3 exec pgm=...
//else1    else
//step4 exec pgm=...
//endif1  endif

### COND = Negativsteuerung (Skip):
Wenn COND-Bedingung wahr ist -> Step wird nicht ausgeführt.

Syntax:
COND=(code,op[,stepname])
oder
COND=((code,op[,stepname]),(code,op[,stepname]),...,EVEN|ONLY)
Operatoren: EQ, NE, LT, LE, GT, GE

(8,LE) <= less equal
(0,NE) >= not equal
(0,EQ) == equal
LT less than
GT greater than

[,EVEN] - auch wenn es davor einen Abend gegeben hat.
[,ONLY] - nur RC(step)=Abend und nur dann führe den Step aus.

** Beispiel **
//Step4 exec cond=((0,NE),EVEN)     //* führe den Step aus auch wenn ein Abend vorkommt.
....
//Step5 exec cond=only          //* führe den Step aus nur wenn ein Abend vorkommt.
....

_______
Aufgabe:
_______
//STEP1    EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  SET MAXCC = 0
/*

//* Step2 nur wenn bisher RC=0
//STEP2    EXEC PGM=IDCAMS,COND=(0,NE)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  SET MAXCC = 0
/*

//* Step3 nur wenn STEP2 RC=0
//STEP3IF  IF (STEP2.RC = 0) THEN
//STEP3    EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  SET MAXCC = 0
/*
//STEP3IF  ENDIF

//* Step4 nur wenn STEP2 RC<>0
//STEP4    EXEC PGM=IDCAMS,COND=(0,EQ,STEP2)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  SET MAXCC = 0
/*                                          
        
## Utilities
- https://it-wiki.generali-gruppe.de/spaces/B0845/pages/577672556/JCL+Job-Aids+-+Beispiele
### IEFBR14: 
*Branch14, dh, ein Pgm was nichts tut, sondern direkt zurückspringt
*praktisch zB. wenn man in einem Setup nur Dateien anlegen und löschen will.

### IEBGENER:
*Schreiben oder Kopieren auf ein sequentielles Dataset
*praktisch zB. zum Drucken. (=Copy auf ein File im Spool)
** Beispiel **
//step1     exec pgm=IEBGENER
//sysprint  dd sysout=*             //*meist für die Protokollmessages
//sysin     dd dummy                // dd dummy oder Steuerkarten
//sysut1    dd dsn=alt.data,disp=shr        //*eingegebene Datei/Member/Instream-Daten
//sysut2    dd dsn=neu.data,disp=old        //*ausgegebene Datei/Member/Instream-Daten

### IEBCOPY:
*Kopieren vin PDS-Membern
*PDS-Datei komprimieren durch Copy ins gleiche File
** Beispiel **
//COPMEMB JOB (ACCOUNTING),CLASS=Z,MSGCLASS=0                         
//COPMEMB1 EXEC PGM=IEBCOPY    //*UM VSAM-DATEI/DS ZU KOPIEREN.       
//SYSPRINT DD SYSOUT=*                                                
//SYSUT1    DD DSN=I003427.JCL101.CNTL,DISP=SHR                       
//*                          DATEI/MEMBER ZU KOPIEREN                 
//SYSUT2    DD DSN=I003427.MEMB.COPY,DISP=SHR                                                                 
//*                          ERSTELLUNG DER HINKOPIERTE DATEI/MEMBER                 
//SYSIN DD *                                                          
--------------------------------------------
** falls die hinkopierte DS noch nicht existiert, sollte dann JCL bisschen anders aussehen zwar;
//COPMEMB JOB (ACCOUNTING),CLASS=Z,MSGCLASS=0                          
//COPMEMB1 EXEC PGM=IEBCOPY    //*UM VSAM-DATEI/DS ZU KOPIEREN.        
//SYSPRINT DD SYSOUT=*                                                 
//SYSUT1    DD DSN=I003427.JCL101.CNTL,DISP=SHR                        
//*                          DATEI/MEMBER ZU KOPIEREN                  
//SYSUT2    DD DSN=I003427.MEMB.COPY,DISP=OLD                          
//             (OLD,KEEP),                                             
//*                          ERSTELLUNG DER HINKOPIERTE DATEI/MEMBER   
//             SPACE=(TRK,(1,1)),RECFM=FB,LRECL=80                     
//SYSIN DD *                                                           

sysut1/sysut2 oder beliebige Namen.

### SORT:
*auch Syncsort genannt, möchtiges, extrem schnlles Sortierprogramm
*beliebt zur Datenaufbereitung
*sortieren,mergen,summieren, uvm.

### IDCAMS:
*Anlage/Verwaltung von VSAM Dateien: KSDS(Key sequential Dataset), ESDS(Entry sequential Dataset), RRDS(Relative Record Dataset), LDS(Linear Dataset), GDG(Generation Data Group)
*Verwaltung von Datei-Aliasen
*Löschung von jeder Art von Datei oder Member
*Änderung einiger Dateiattribute, wie zB. der Managementsklasse
*Ziehen von Dateilisten aus dem Catalog.
** Beispiel **
//DELMEM exec pgm=idcams
//sysprint dd sysout=*
//sysin dd *
    delete 'userid.MEIN.PSDS(*)'
//

### Datenaufbereiten mit SyncSort
- Sort
- Join/Merge
- Omit
- Split Up
- Format
- Count / Add Up

## Prodezuren verstehen
Prozedur=JCL mit Variablen
ein JCL-Prozedur sieht ungefähr so aus:
//MYPROC    PROC VAR1=XXXXX,VAR3=,
//               VAR2=BBBB
//....   exec .... &var1 ....
//....   dd   .... &var2 ....
//....   dd   ...............
//&var4 exec  ...............
//....   dd   ... &var2......
//....   dd   ...............
//       PEND

PROC-Nutzung:
//.... JOB  .........
//.... exec myproc,var2=YYYYY,
//          var3=zzz,var4=aaa

### Standard-Prozeduren für Programme
1. GOBTCH : für einfache Pgms ohne DB2 und ohne IMS
2. DB2BTCH : für Pgms mit DB2
3. DLIUBAT : für Programme mit IMS ohne DB2
4. DLIUDB2 : für Programme mit IMS und DB2

### Parameter aller Standard-Procs
//gobtch    proc mbr=tempname,
//          syskz='1',
//          swstand='0',
//          sim='nein',
//          sout='*',
//          ldsn1='p770001.b0dummy.load',       //*zusätliche Dateien werden
//          ldsn2='p770001.b0dummy.load',       //*in diese Steplibverkettung
//          ldsn3='p770001.b0dummy.load',       //* eingefügt.
//          ldsn4='p770001.b0dummy.load',
...

## Produktions-JCL, eine andere Welt ?
Test-JCL
Job
Step1
temp. Dateien
Step2
Spooloutput
Prüfung unter IOF

-----------------
Prod-JCL
Job1
persistente DSe
Job2
persistente DSe
Prüfung unter IOF + Beta

Größter Unterschied zw. Test und Prod-JCL:
falls ein Vorstep ausfällt/abgebrochen, wird der Job sich nicht komplett von vornbeginnen sondern wird nur fehlgeschlagener Step wiederholt.

## XINFO
mit xinfo command kann man in tws/jcl Welt einsteigen =)


##### Deepnote:
Die Lernnotizen stammen vom e-Kurs: 
https://de0a000085dde.de.top.com/training/elearning/MARPLE%20JCL%20101%20-%20Storyline%20output/story.html