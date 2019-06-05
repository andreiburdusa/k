// Copyright (c) 2019 K Team. All Rights Reserved.

module EVM-DATA
    imports STRING-BUFFER
    imports MAP-SYMBOLIC
    imports COLLECTIONS

    syntax KResult ::= Int

    syntax JSONList ::= List{JSON,","}
    syntax JSONKey  ::= String | Int
    syntax JSON     ::= String
                      | JSONKey ":" JSON
                      | "{" JSONList "}"
                      | "[" JSONList "]"
 // ------------------------------------

    syntax WordStack [flatPredicate]
    syntax WordStack ::= ".WordStack"      [smtlib(_dotWS)]
                       | Int ":" WordStack [klabel(_:_WS), smtlib(_WS_)]
 // --------------------------------------------------------------------

    syntax Int ::= #sizeWordStack ( WordStack , Int )
 // -------------------------------------------------
endmodule

module EVM
    imports STRING
    imports EVM-DATA

    syntax Schedule ::= "DEFAULT"
    syntax EthereumSimulation ::= ".EthereumSimulation"
    syntax StatusCode ::= ".StatusCode"

    configuration
      <kevm>
        <k> $PGM:EthereumSimulation </k>
        <schedule> $SCHEDULE:Schedule </schedule>

        <ethereum>

          // EVM Specific
          // ============

          <evm>

            // Mutable during a single transaction
            // -----------------------------------

            <statusCode>      .StatusCode </statusCode>

            <callState>

              // \mu_*
              <wordStack>   .WordStack </wordStack>           // \mu_s
              <pc>          0          </pc>                  // \mu_pc
              <gas>         0          </gas>                 // \mu_g
            </callState>

          </evm>

          // Ethereum Network
          // ================

        </ethereum>
      </kevm>
endmodule

module ETHEREUM-SIMULATION
    imports EVM
    imports K-REFLECTION

    syntax EthereumSimulation ::= ".EthereumSimulation"
                                | EthereumCommand EthereumSimulation
 // ----------------------------------------------------------------

    syntax EthereumCommand ::= "load" JSON
 // --------------------------------------

    syntax EthereumCommand ::= "mkTX" Int
 // -------------------------------------
    rule <k> load "transaction" : [ [ TN , TP , TG , TT , TV , TI , TW , TR , TS ] , REST ]
          => mkTX !ID:Int
          ~> load "transaction" : { !ID : { "data"  : TI   ,   "gasLimit" : TG   ,   "gasPrice" : TP
                                          , "nonce" : TN   ,   "r"        : TR   ,   "s"        : TS
                                          , "to"    : TT   ,   "v"        : TW   ,   "value"    : TV
                                          , .JSONList
                                          }
                                  }
          ~> load "transaction" : [ REST ]
          ...
          </k>
endmodule

module TEST-EXT
    imports EVM
    imports ETHEREUM-SIMULATION

    syntax Int ::= "Gverylow" "<" Schedule ">"
    syntax KItem ::= "#next" "[" "PUSH" "(" Int "," Int ")" "]"

    rule <kevm>
           <k>
             #next [ PUSH( N , M ) ] => . ...
           </k>
           <schedule>
             SCHEDULE
           </schedule>
           <ethereum>
             <evm>
               <callState>
                 <wordStack>
                   WS => M : WS
                 </wordStack>
                 <pc>
                   PCOUNT => ( PCOUNT +Int ( 1 +Int N ) )
                 </pc>
                 <gas>
                   G => ( G -Int Gverylow < SCHEDULE > )
                 </gas>
                 ...
               </callState>
               ...
             </evm>
             ...
           </ethereum>
           ...
         </kevm>
      requires G >=Int Gverylow < SCHEDULE >
       andBool notBool ( #sizeWordStack( WS , 0 ) <Int 0 orBool ( #sizeWordStack( WS , 0 ) +Int 1 ) >Int 1024 )
      [priority(25), trusted]
endmodule
