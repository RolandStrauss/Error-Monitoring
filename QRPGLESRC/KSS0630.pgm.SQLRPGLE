**free
Ctl-Opt main(KSS0630) ;

ctl-opt Copyright('(C) MMerge DevOps | 2023 | KSS0630.SQLRPGLE') ;
ctl-opt aut( *exclude ) ;
ctl-opt datfmt( *iso ) timfmt( *iso ) ;
ctl-opt option( *srcstmt : *nodebugio : *noshowcpy : *nounref : *noexpdds ) ;
ctl-opt ccsid( *char: *jobrun ) ;
ctl-opt expropts( *resdecpos ) ;
ctl-opt extbinint( *yes ) ;
ctl-opt text( *srcmbrtxt ) ;
ctl-opt CCSIDCVT( *EXCP ) ;
ctl-opt decedit( *jobrun ) ;
ctl-opt ALWNULL(*USRCTL) ;
ctl-opt debug(*constants) ;

/IF defined(*CRTBNDRPG)
ctl-opt dftactgrp(*no) actgrp(*NEW) ;
/ENDIF

// Ctl-Opt bnddir ('GENPSSRBD') ;

// ___ Files __________________________________________________________________
// ___ Copy member include of declaratives ____________________________________
// /INCLUDE qrpglesrc,genpssrcb
// /INCLUDE qrpglesrc,genpssrpr
// ___ Procedure Interface ____________________________________________________
dcl-pr SysCmd           uns(10) extproc(*cwiden:'system') ;
   *n                   pointer value ;
end-pr ;
// ___ Data Structures ________________________________________________________
dcl-ds CUSMSTDS extname('CUSMST') qualified ;
end-ds ;
// ___ Stand Alone Variables __________________________________________________
dcl-s DspMsg varchar(52) inz(*Blank) ;
dcl-s ErrMsg            char(7) import('_EXCP_MSGID') ;
// ___ Constants ______________________________________________________________

Dcl-Proc KSS0630 ;
   Dcl-Pi *n ;
   End-Pi ;

   // ___ Files ___
   // ___ Copy member include of declaratives ___
   // ___ Procedure Interface ___
   // ___ Data Structures ___
   
   // ___ Stand Alone Variables ___
   dcl-s CustomerNumber       like(CUSMSTDS.CUSNUM) ;
   dcl-s CustomerLastName       like(CUSMSTDS.lstnam) ;
   // Declare the pointer variable
   dcl-s Ptr            pointer ;
   dcl-s PointerVar     char(1) based(Ptr) ;
   dcl-s switch         ind inz(*On) ;
   // ___ Constants ___
   // dcl-c ERROROPENINGTABLE    'Error opening table: ' ;


   // ___ Set SQL Options ___
   Exec Sql
     Set Option DatFmt = *Iso,
     Commit = *None,
     CloSqlCsr = *EndMod ;

   Monitor ;
      // Code that may cause the error
      If (not switch) ;
         Ptr = *NULL ; // Setting the pointer to null
         PointerVar = 'Roland' ;
      else ;
         Ptr = %addr(PointerVar) ;
         PointerVar = 'Roland' ;
      endif ;

      CustomerLastName = KSS0630_Proc1(CustomerNumber) ;

      on-excp 'RNX0103' ;  // Result to Big
      DspMsg = 'Message RNX0103, status ' + %char(%status()) ;
      dsply %trim(DspMsg) ;
      on-excp 'CPF4101' ; // File not Found
      DspMsg = 'Message CPF4101, status ' + %char(%status()) ;
      dsply %trim(DspMsg) ;
      on-excp 'CPF9897' ;
      DspMsg = 'Message from KSS0630_Proc1()' ;
      dsply %trim(DspMsg) ;
      on-excp(c) 'CPF9898' ;
      DspMsg = 'KSS0630_Proc1() Just broke with an Escape message' ;
      dsply %trim(DspMsg) ;
      on-excp 'MCH3601' ; // Pointer not set for location referenced
      DspMsg = 'Pointer not set for location referenced: ' + %trim(ErrMsg) ;
      dsply %trim(DspMsg) ;
   on-error 222 ; // Pointer or parameter error
      DspMsg = 'Handling pointer-not-set: ' + %trim(ErrMsg) ;
      dsply %trim(DspMsg) ;
   on-error ;
      // pssr_prcID = %proc() ;
      // pssr_dtaID = 'XX' + %char(000000000) ;
      // PSSR_processError(pssr_prcID:pssr_dtaID) ;
      snd-msg *escape 'Alert the troops, the program went BOOM!!!' ;
   endmon ;
   // ____________________________________
   return ;
   // ____________________________________
   on-exit ;

End-Proc KSS0630 ;

Dcl-Proc KSS0630_Proc1 ;
   Dcl-Pi *n            varchar(15) ;
      CUSNUM                like(CUSMSTDS.CUSNUM) ;
   End-Pi ;

   // ___ Files ___
   dcl-f  CUSMST        disk usage(*input) keyed
                        usropn ;

   // ___ Copy member include of declaratives ___
   // ___ Procedure Interface ___
   // ___ Data Structures ___
   dcl-ds dsCUSMST likerec(CUSREC:*input) ;
   // ___ Stand Alone Variables ___
   // dcl-s ExternalTable varchar(10) inz('CUSMST') ;
   // ___ Constants ___

   Monitor ;
      // ____________________________________
      If (not %open(CUSMST )) ;
         open(e) CUSMST ;
         If (%error) ;
            DspMsg = 'Failed to open CUSMST table' ;
            snd-msg *escape  DspMsg ;
            // Return ;
         endIf ;
      endIf ;
      // ____________________________________
      chain CUSNUM CUSMST dsCUSMST ;
      // ____________________________________
      if (not %found(CUSMST)) ;
         DspMsg = 'Customer number not found' ;
         snd-msg *escape DspMsg ; // CPF9898 is default for *escape
      else ;
         return %trim(dsCUSMST.lstnam) ;
      endif ;
      // ____________________________________
      on-excp 'RNX0103' ; // Result to Big
      DspMsg = 'Message RNX0103, status ' + %char(%status()) ;
      snd-msg *escape DspMsg ;
      on-excp 'CPF4101' ; // File not Found
      DspMsg = 'Message CPF4101, status ' + %char(%status()) ;
      snd-msg *escape DspMsg ;
   on-error ;
      // pssr_prcID = %proc() ;
      // pssr_dtaID = 'XX' + %char(000000000) ;
      // PSSR_processError(pssr_prcID:pssr_dtaID) ;
      snd-msg *escape 'Alert the troops, the program went BOOM!!!' ;
   endmon ;
   // ____________________________________
   return *Blank ;
   // ____________________________________
   on-exit ;
      // ____________________________________
      If (%open(CUSMST  )) ;
         close(e) CUSMST ;
         If (%error) ;
            DspMsg = 'Failed to close CUSMST table' ;
            snd-msg *escape  DspMsg ;
            // Return ;
         endIf ;
      endIf ;

End-Proc KSS0630_Proc1 ;


