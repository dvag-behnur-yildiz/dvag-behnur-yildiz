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
JCL - wie ein Spiel mit 3 Karten
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


## Ein Pgm im Batch ausführen
## Einführung in Dateiarten
## Dateien anlegen/löschen
## Conditionscode-Steuerung
## Utuilities
## Spezielle Pgms => spezielle Bedürfnisse
## Prodezuren verstehen
## Produktions-JCL, eine andere Welt ?