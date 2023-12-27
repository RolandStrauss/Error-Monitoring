**free

Ctl-Opt main(KSS0630) ;

ctl-opt Copyright('(C) Roland Strauss | 2023 | KSS0630.SQLRPGLE') ;
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
DCL-F badfile DISK(10) USROPN;
// ___ Copy member include of declaratives ____________________________________
// /INCLUDE qrpglesrc,genpssrcb
// /INCLUDE qrpglesrc,genpssrpr
// ___ Procedure Interface ____________________________________________________
dcl-pr SysCmd           uns(10) extproc(*cwiden:'system') ;
   *n                   pointer value options(*string) ;
end-pr ;
// ___ Data Structures ________________________________________________________
dcl-ds CUSMSTDS         extname('CUSMST') qualified ;
end-ds ;
// ___ Stand Alone Variables __________________________________________________
dcl-s DspMsg            varchar(52) inz(*Blank) ;
dcl-s ErrMsg            char(7) import('_EXCP_MSGID') ;
DCL-S status            PACKED(5);
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
   dcl-s PointerVar     char(10) based(Ptr) ;
   dcl-s dummyVar       char(10) ;
   dcl-s switch         ind inz(*Off) ;
   dcl-s SomeNum        packed(2) ;
   dcl-s ZeroNum        packed(2) inz(*Zero) ;
   dcl-s rc             int(10) ;
   // ___ Constants ___

   // ___ Set SQL Options ___
   Exec Sql
     Set Option DatFmt = *Iso,
     Commit = *None,
     CloSqlCsr = *EndMod ;

   Monitor ;
      // Code that may cause the error
      If (switch) ;
         Ptr = *NULL ; // Setting the pointer to null
         PointerVar = 'Roland' ;
      else ;
         Ptr = %addr(dummyVar) ;
         PointerVar = 'Roland' ;
      endif ;
      
      If (switch) ;
         SomeNum = 100 * 10 ;
      endif ;

      If (switch) ;
         SomeNum = 100 / ZeroNum ;
      endif ;

      If (switch) ;
         OPEN badfile;
      endif ;

      If (switch) ;
         rc = SysCmd('DSPOBJD OBJ(ROLAND1/BLAH) OBJTYPE(*FILE)') ;
         if (rc <> 0) ;
            DspMsg = 'Execution of the command failed ' + %trim(ErrMsg) ;
            snd-msg %trim(DspMsg) ;
            return ;
         EndIf;
      endif ;

      CustomerLastName = KSS0630_Proc1(CustomerNumber) ;

   on-excp 'RNX0103' ;  // Result to Big
      DspMsg = 'Message RNX0103, status ' + %char(%status()) ;
      snd-msg %trim(DspMsg) ;
   on-excp 'CPF2105' ; // File not Found
      DspMsg = 'Message CPF2105, status ' + %char(%status()) ;
      snd-msg %trim(DspMsg) ;
   on-excp 'CPF4101' ; // File not Found
      DspMsg = 'Message CPF4101, status ' + %char(%status()) ;
      snd-msg %trim(DspMsg) ;
   on-excp 'CPF9897' ;
      DspMsg = 'Message from KSS0630_Proc1()' ;
      snd-msg %trim(DspMsg) ;
   on-excp(c) 'CPF9898' ;
      DspMsg = 'KSS0630_Proc1() Just broke with an Escape message' ;
      snd-msg %trim(DspMsg) ;
   on-excp 'MCH3601' ; // Pointer not set for location referenced
      DspMsg = 'Pointer not set for location referenced ' ;
      snd-msg %trim(DspMsg) ;
   on-error 102 ;
      status =  %status() ;
      DspMsg = 'Devide by 0 ' + %char(%status()) ;
      snd-msg %trim(DspMsg) ;
   on-error 103 ;
      status =  %status() ;
      DspMsg = 'Receiver too small ' + %char(status) ;
      snd-msg %trim(DspMsg) ;
   on-error 222 ; // Pointer or parameter error
      DspMsg = 'Handling pointer-not-set: ' + %trim(ErrMsg) ;
      snd-msg %trim(DspMsg) ;
   on-error ;
      status =  %status() ;
      DspMsg = 'Alert the troops, the program went BOOM!!! ' + %char(status) ;
      snd-msg *escape %trim(DspMsg) ;
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
                        // rename(CUSMST:cusrec)
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
            snd-msg *escape %msg('CPF9897' :'QCPFMSG' : DspMsg) ;
            // Return ;
         endIf ;
      endIf ;
      // ____________________________________
      chain CUSNUM CUSMST dsCUSMST ;
      // ____________________________________
      if (not %found(CUSMST)) ;
         DspMsg = 'Customer number not found' ;
         snd-msg *escape %msg('CPF9897' :'QCPFMSG' : DspMsg) ; // CPF9898 is default for *escape
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