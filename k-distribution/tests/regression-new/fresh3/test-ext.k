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
      </kevm>
endmodule

module ETHEREUM-SIMULATION
    imports EVM
    imports K-REFLECTION

    syntax EthereumSimulation ::= ".EthereumSimulation"
                                | EthereumCommand EthereumSimulation
 // ----------------------------------------------------------------

    syntax EthereumCommand ::= "load" JSON
                             | "mkTX" Int
 // -------------------------------------
    rule <k> load "transaction" : [ REST ] => mkTX !ID:Int ... </k>
endmodule

module TEST-EXT
    imports EVM
    imports ETHEREUM-SIMULATION

    syntax KItem ::= "#next" "[" "PUSH" "(" Int "," Int ")" "]"

    rule <k> #next [ PUSH( N , M ) ] => . ... </k>
endmodule
