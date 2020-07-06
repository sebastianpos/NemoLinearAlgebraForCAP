BindGlobal( "CAP_JIT_INTERNAL_GET_JULIA_MODULE_AND_OPERATION_OF_FUNCCALL", function( tree )
    
    if tree.type = "EXPR_FUNCCALL" then
        
        if tree.funcref.type = "EXPR_ELM_REC_EXPR" then
            
            if tree.funcref.expression.type = "EXPR_STRING" and tree.funcref.record.type = "EXPR_ELM_REC_NAME" then
                
                if tree.funcref.record.record.type = "EXPR_REF_GVAR" and tree.funcref.record.record.gvar = "Julia" then
                    
                    return [ tree.funcref.record.name, tree.funcref.expression.value ];
                    
                fi;
                
            fi;
            
        fi;
        
        if tree.funcref.type = "EXPR_ELM_REC_NAME" then
            
            if tree.funcref.record.type = "EXPR_ELM_REC_NAME" then
                
                if tree.funcref.record.record.type = "EXPR_REF_GVAR" and tree.funcref.record.record.gvar = "Julia" then
                    
                    return [ tree.funcref.record.name, tree.funcref.name ];
                    
                fi;
                
            fi;
            
        fi;
        
    fi;
    
    return fail;
    
end );

BindGlobal( "CAP_JIT_GLOBAL_JULIA_VARIABLE_COUNTER", 1 );
MakeReadWriteGlobal( "CAP_JIT_GLOBAL_JULIA_VARIABLE_COUNTER" );

# composes Julia function calls in Julia instead of GAP
CapJitAddLogicFunction( function( tree, jit_args )
  local result_func;
    
    Info( InfoCapJit, 1, "####" );
    Info( InfoCapJit, 1, "Apply logic for Julia function calls." );
    
    result_func := function( tree, result, additional_arguments )
      local julia_data, julia_module, julia_operation, arguments_julia_data, gap_call_args, julia_call_args, inner_julia_module, inner_julia_operation, inner_julia_call_args, julia_gvar, julia_function_args, julia_string, key, i;
        
        if IsList( result ) then
            
            return result;
            
        elif IsRecord( result ) then
            
            tree := ShallowCopy( tree );
            
            for key in RecNames( result ) do
                
                tree.(key) := result.(key);
                
            od;
            
            julia_data := CAP_JIT_INTERNAL_GET_JULIA_MODULE_AND_OPERATION_OF_FUNCCALL( tree );
            
            if julia_data <> fail then
                
                julia_module := julia_data[1];
                julia_operation := julia_data[2];
                
                arguments_julia_data := List( tree.args, a -> CAP_JIT_INTERNAL_GET_JULIA_MODULE_AND_OPERATION_OF_FUNCCALL( a ) );
                
                if ForAny( arguments_julia_data, a -> a <> fail ) then
                    
                    gap_call_args := [];
                    julia_call_args := [];
                    
                    for i in [ 1 .. Length( tree.args ) ] do
                        
                        if arguments_julia_data[i] = fail then
                            
                            Add( julia_call_args, Concatenation( "arg", String( Length( gap_call_args ) + 1 ) ) );
                            
                            Add( gap_call_args, tree.args[i] );
                            
                        else
                            
                            inner_julia_module := arguments_julia_data[i][1];
                            inner_julia_operation := arguments_julia_data[i][2];
                            
                            inner_julia_call_args := List( [ 1 .. Length( tree.args[i].args ) ], j -> Concatenation( "arg", String( Length( gap_call_args ) + j ) ) );
                            
                            Add( julia_call_args, Concatenation(
                                inner_julia_module, ".:(", inner_julia_operation, ")(",
                                    JoinStringsWithSeparator( inner_julia_call_args, ", " ),
                                ")"
                            ) );
                            
                            gap_call_args := Concatenation( gap_call_args, tree.args[i].args );
                            
                        fi;
                        
                    od;
                    
                    julia_gvar := Concatenation( "CAP_JIT_GLOBAL_JULIA_VARIABLE_", String( CAP_JIT_GLOBAL_JULIA_VARIABLE_COUNTER ) );
                    CAP_JIT_GLOBAL_JULIA_VARIABLE_COUNTER := CAP_JIT_GLOBAL_JULIA_VARIABLE_COUNTER + 1;
                    
                    julia_function_args := List( [ 1 .. Length( gap_call_args ) ], i -> Concatenation( "arg", String( i ) ) );
                    
                    julia_string := Concatenation(
                        "@inline function ", julia_gvar,"(",
                            JoinStringsWithSeparator( julia_function_args, ", " ),
                        ")\n",
                        "    return ", julia_module, ".:(", julia_operation, ")(",
                                JoinStringsWithSeparator( julia_call_args, ", " ),
                            ");\n",
                        "end;"
                    );
                    
                    JuliaEvalString( julia_string );
                    
                    return rec(
                        type := "EXPR_FUNCCALL",
                        funcref := rec(
                            type := "EXPR_ELM_REC_NAME",
                            name := julia_gvar,
                            record := rec(
                                type := "EXPR_ELM_REC_NAME",
                                name := "Main",
                                record := rec(
                                    type := "EXPR_REF_GVAR",
                                    gvar := "Julia",
                                ),
                            ),
                        ),
                        args := gap_call_args,
                    );
                    
                fi;
                
            fi;
            
            return tree;
            
        else
            
            Error( "this should never happen" );
            
        fi;
        
    end;
    
    return CapJitIterateOverTree( tree, ReturnFirst, result_func, ReturnTrue, true );
    
end );
