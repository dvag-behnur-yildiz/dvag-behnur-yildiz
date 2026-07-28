SET CURRENT PATH = 'T13VB';

SET CURRENT SCHEMA = 'T13VB';


SELECT SUBSTR(COALESCE(FNDB0001(MAN_VORNAME),''), 1, 40) 
from vivbb014 man                                        
where 1=1                                                
and man_vorname like 'KLAUS%'                            
;     

SELECT SUBSTR(COALESCE(FNDB0001(MAN_VORNAME),''), 1, 40)   
       , man_vorname                                       
       ,man_vorname_gk                                     
from vivbb014 man                                          
where 1=1                                                  
and man_bezugs_nr = 2010257                                
;                                               