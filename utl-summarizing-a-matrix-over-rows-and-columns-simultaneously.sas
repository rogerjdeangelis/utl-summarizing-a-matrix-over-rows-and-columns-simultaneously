                                                                                                           
Summarizing a matrix over rows and columns simultaneously                                                   
                                                                                                            
  Two Solutions                                                                                             
                                                                                                            
     1. Transpose then proc summary (tanspose can be slow see transpose macro)                              
                                                                                                            
     2. Fast elegant HASH by                                                                                
           Bartosz Jablonski                                                                                
           yabwon@gmail.com                                                                                 
                                                                                                            
                                                                                                            
github                                                                                                      
http://tinyurl.com/y4w6cgkn                                                                                 
https://github.com/rogerjdeangelis/utl-summarizing-a-matrix-over-rows-and-columns-simultaneously            
                                                                                                            
SAS Forum                                                                                                   
https://communities.sas.com/t5/SAS-Procedures/Column-was-summary/m-p/545570                                 
                                                                                                            
                                                                                                            
*_                   _                                                                                      
(_)_ __  _ __  _   _| |_                                                                                    
| | '_ \| '_ \| | | | __|                                                                                   
| | | | | |_) | |_| | |_                                                                                    
|_|_| |_| .__/ \__,_|\__|                                                                                   
        |_|                                                                                                 
;                                                                                                           
                                                                                                            
data have;                                                                                                  
 input id p1$ p2$ p3$ p4$;                                                                                  
cards4;                                                                                                     
1234 R1 R3 R4 R5                                                                                            
5678 R3 R4 R5 .                                                                                             
9101 R3 R4 R5 .                                                                                             
1112 R2 R3 R4 R5                                                                                            
;;;;                                                                                                        
run;quit;                                                                                                   
                                                                                                            
WORK.HAVE total obs=4                                                                                       
                                                                                                            
  ID     P1    P2    P3    P4                                                                               
                                                                                                            
 1234    R1    R3    R4    R5                                                                               
 5678    R3    R4    R5                                                                                     
 9101    R3    R4    R5                                                                                     
 1112    R2    R3    R4    R5                                                                               
                                                                                                            
                                                                                                            
RULES                                                                                                       
=====                                                                                                       
                                                                                                            
Count the number od occurances of R1 over all column and rows                                               
                                                                                                            
              Cnt                                                                                           
    R1         1  only occurs once                                                                          
    R2         1  only occurs once                                                                          
    R3         4  four occurances                                                                           
                                                                                                            
                                                                                                            
*            _               _                                                                              
  ___  _   _| |_ _ __  _   _| |_                                                                            
 / _ \| | | | __| '_ \| | | | __|                                                                           
| (_) | |_| | |_| |_) | |_| | |_                                                                            
 \___/ \__,_|\__| .__/ \__,_|\__|                                                                           
                |_|                                                                                         
;                                                                                                           
                                                                                                            
Up to 40 obs WORK.WANT total obs=5                                                                          
                                                                                                            
Obs    SUMMARY    COUNT                                                                                     
                                                                                                            
 1       R1         1                                                                                       
 2       R2         1                                                                                       
 3       R3         4                                                                                       
 4       R4         4                                                                                       
 5       R5         4                                                                                       
                                                                                                            
*          _       _   _                                                                                    
 ___  ___ | |_   _| |_(_) ___  _ __                                                                         
/ __|/ _ \| | | | | __| |/ _ \| '_ \                                                                        
\__ \ (_) | | |_| | |_| | (_) | | | |                                                                       
|___/\___/|_|\__,_|\__|_|\___/|_| |_|                                                                       
                                                                                                            
;                                                                                                           
                                                                                                            
------------------------------                                                                              
1. Transpose then proc summary                                                                              
------------------------------                                                                              
                                                                                                            
proc transpose data=have                                                                                    
                out=havXpo(                                                                                 
                drop=id _name_ rename=col1=summary);                                                        
  by id notsorted;                                                                                          
  var p1-p4;                                                                                                
run;quit;                                                                                                   
                                                                                                            
proc summary data=havXpo nway;                                                                              
  class summary;                                                                                            
  output out=want(drop=_type_ rename=_freq_=count);                                                         
run;quit;                                                                                                   
                                                                                                            
                                                                                                            
-----------------------                                                                                     
2. Fast elegant HASH by                                                                                     
-----------------------                                                                                     
                                                                                                            
data _null_;                                                                                                
                                                                                                            
  length summary $ 8 count 8;                                                                               
  declare hash H(ordered:"A");                                                                              
  H.defineKey("summary");                                                                                   
  H.defineData("summary", "count");                                                                         
  H.defineDone();                                                                                           
  call missing(summary, count);                                                                             
                                                                                                            
  do until(eof);                                                                                            
    set have end = eof;                                                                                     
    array A p1-p4;                                                                                          
                                                                                                            
    do over A;                                                                                              
      summary = a;                                                                                          
      if H.find() then                                                                                      
        do;                                                                                                 
          count = 1;                                                                                        
          _iorc_ = H.add();                                                                                 
        end;                                                                                                
      else                                                                                                  
        do;                                                                                                 
          count + 1;                                                                                        
          _iorc_ = H.replace();                                                                             
        end;                                                                                                
    end;                                                                                                    
  end;                                                                                                      
                                                                                                            
  _iorc_ = H.output(dataset:"want_B(where=(summary is not null))");                                         
  stop;                                                                                                     
run;                                                                                                        
                                                                                                            
                                                                                                            
                                                              
                                                                                                           
                                                                                                           
