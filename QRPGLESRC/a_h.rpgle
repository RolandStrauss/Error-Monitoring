dcl-s shared_variable varchar(1000000)
     /if defined(do_export)
         export
     /else
         import
     /endif
   ;