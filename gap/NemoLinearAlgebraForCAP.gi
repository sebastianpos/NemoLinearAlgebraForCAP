#############################################################################
##
##                                NemoLinearAlgebraForCAP package
##
##  Copyright 2018, Sebastian Posur,   University of Siegen
##
##
#############################################################################

## import Base first
ImportJuliaModuleIntoGAP( "Base" );

ImportJuliaModuleIntoGAP( "Hecke" );

ImportJuliaModuleIntoGAP( "Nemo" );

####################################
##
## Implementation
##
####################################

InstallMethod( NemoMatrixCategory,
               [ IsJuliaObject ],
               
  function( nemo_field )
    local category, to_be_finalized;
    
    category := CreateCapCategory( "Category of Nemo vector spaces" );
    
    DisableAddForCategoricalOperations( category );
    
    AddObjectRepresentation( category, IsNemoVectorSpaceObject );
    
    AddMorphismRepresentation( category, IsNemoVectorSpaceMorphism );
    
    SetIsAbelianCategory( category, true );
    
    SetIsRigidSymmetricClosedMonoidalCategory( category, true );
    
    SetIsStrictMonoidalCategory( category, true );
    
    INSTALL_FUNCTIONS_FOR_NEMO_MATRIX_CATEGORY( category, nemo_field );
    
    Finalize( category );
    
    return category;
    
end );

InstallGlobalFunction( INSTALL_FUNCTIONS_FOR_NEMO_MATRIX_CATEGORY,
  
  function( category, nemo_field )
    local julia_transpose,
          julia_getindex,
          julia_nullspace,
          julia_cansolve,
          julia_identity_matrix,
          julia_zero_matrix,
          julia_vcat,
          julia_hcat,
          julia_kronecker_product;

    julia_getindex := Julia.Base.getindex;

    julia_transpose := Julia.Nemo.transpose;

    julia_nullspace := Julia.Nemo.nullspace;

    julia_cansolve := Julia.Hecke.can_solve;

    julia_identity_matrix := Julia.Nemo.identity_matrix;

    julia_zero_matrix := Julia.Nemo.zero_matrix;

    julia_vcat := Julia.Nemo.vcat;

    julia_hcat := Julia.Nemo.hcat;

    julia_kronecker_product := Julia.Hecke.kronecker_product;

    ##
    AddIsEqualForCacheForObjects( category,
      IsIdenticalObj );
    
    ##
    AddIsEqualForCacheForMorphisms( category,
      IsIdenticalObj );

    ##
    AddIsEqualForObjects( category,
      function( object_1, object_2 )
      
        return Dimension( object_1 ) = Dimension( object_2 );
      
    end );
    
    ##
    AddIsCongruentForMorphisms( category,
      function( alpha, beta )
        
        return Julia.Nemo.("==")( UnderlyingMatrix( alpha ), UnderlyingMatrix( beta ) );
        
    end );

    ##
    AddIdentityMorphism( category,
      
      function( object )
        local matrix;
        
        matrix := julia_identity_matrix( nemo_field, Dimension( object ) );

        return NemoVectorSpaceMorphism( object, matrix, object );
        
    end );

    ##
    AddPreCompose( category,
      
      function( alpha, beta )

        return NemoVectorSpaceMorphism(
                Source( alpha ),
                Julia.Nemo.("\*")(UnderlyingMatrix( alpha ), UnderlyingMatrix( beta ) ),
                Range( beta )
        );

    end );

    ##
    AddAdditionForMorphisms( category,
      function( alpha, beta )
        
        return NemoVectorSpaceMorphism( 
                Source( alpha ),
                Julia.Nemo.("\+")( UnderlyingMatrix( alpha ), UnderlyingMatrix( beta ) ),
                Range( beta ) 
        );
        
    end );

    ##
    AddAdditiveInverseForMorphisms( category,
      function( alpha )
        
        return NemoVectorSpaceMorphism( 
                Source( alpha ),
                Julia.Nemo.("\-")( UnderlyingMatrix( alpha ) ),
                Range( alpha ) 
        );
        
    end );

    ##
    AddZeroMorphism( category,
      function( source, range )
        
        return NemoVectorSpaceMorphism( 
                source,
                julia_zero_matrix( nemo_field, Dimension( source ), Dimension( range ) ),
                range 
        );
        
    end );

    ##
    AddZeroObject( category,
      function( )
        
        return NemoVectorSpaceObject( 0, category );
        
    end );

    ##
    AddUniversalMorphismIntoZeroObjectWithGivenZeroObject( category,
      function( sink, zero_object )
        local morphism;
        
        morphism := NemoVectorSpaceMorphism( 
                        sink, 
                        julia_zero_matrix( nemo_field, Dimension( sink ), 0 ), 
                        zero_object 
        );
        
        return morphism;
        
    end );

    ##
    AddUniversalMorphismFromZeroObjectWithGivenZeroObject( category,
      function( source, zero_object )
        local morphism;
        
        morphism := NemoVectorSpaceMorphism( 
                        zero_object, 
                        julia_zero_matrix( nemo_field, 0, Dimension( source ) ), 
                        source 
        );
        
        return morphism;
        
    end );

    ##
    AddDirectSum( category,
      function( object_list )
      local dimension;
      
      dimension := Sum( List( object_list, object -> Dimension( object ) ) );
      
      return NemoVectorSpaceObject( dimension, category );
      
    end );

    ##
    AddProjectionInFactorOfDirectSumWithGivenDirectSum( category,
      function( object_list, projection_number, direct_sum_object )
        local dim_pre, dim_post, dim_factor, number_of_objects, projection_in_factor;
        
        number_of_objects := Length( object_list );
        
        dim_pre := Sum( object_list{ [ 1 .. projection_number - 1 ] }, c -> Dimension( c ) );
        
        dim_post := Sum( object_list{ [ projection_number + 1 .. number_of_objects ] }, c -> Dimension( c ) );
        
        dim_factor := Dimension( object_list[ projection_number ] );
        
        projection_in_factor := 
            julia_zero_matrix( nemo_field, dim_pre, dim_factor );
        
        projection_in_factor := 
            julia_vcat( projection_in_factor, 
                             julia_identity_matrix( nemo_field, dim_factor ) );
        
        projection_in_factor := 
            julia_vcat( projection_in_factor, 
                             julia_zero_matrix( nemo_field, dim_post, dim_factor ) );
        
        return NemoVectorSpaceMorphism( direct_sum_object, projection_in_factor, object_list[ projection_number ] );
        
    end );

    ##
    AddUniversalMorphismIntoDirectSumWithGivenDirectSum( category,
      function( diagram, sink, direct_sum )
        local underlying_matrix_of_universal_morphism, morphism;
        
        underlying_matrix_of_universal_morphism := UnderlyingMatrix( sink[1] );
        
        for morphism in sink{ [ 2 .. Length( sink ) ] } do
          
          underlying_matrix_of_universal_morphism := 
            Julia.Nemo.hcat( underlying_matrix_of_universal_morphism, UnderlyingMatrix( morphism ) );
          
        od;
        
        return NemoVectorSpaceMorphism( Source( sink[1] ), underlying_matrix_of_universal_morphism, direct_sum );
      
    end );

    ##
    AddInjectionOfCofactorOfDirectSumWithGivenDirectSum( category,
      function( object_list, injection_number, coproduct )
        local dim_pre, dim_post, dim_cofactor, number_of_objects, injection_of_cofactor;
        
        number_of_objects := Length( object_list );
        
        dim_pre := Sum( object_list{ [ 1 .. injection_number - 1 ] }, c -> Dimension( c ) );
        
        dim_post := Sum( object_list{ [ injection_number + 1 .. number_of_objects ] }, c -> Dimension( c ) );
        
        dim_cofactor := Dimension( object_list[ injection_number ] );
        
        injection_of_cofactor := julia_zero_matrix( nemo_field, dim_cofactor, dim_pre );
        
        injection_of_cofactor := 
            julia_hcat( injection_of_cofactor, 
                             julia_identity_matrix( nemo_field, dim_cofactor ) );
        
        injection_of_cofactor := 
            julia_hcat( injection_of_cofactor, 
                             julia_zero_matrix( nemo_field, dim_cofactor, dim_post ) );
        
        return NemoVectorSpaceMorphism( object_list[ injection_number ], injection_of_cofactor, coproduct );

    end );
    
    ##
    AddUniversalMorphismFromDirectSumWithGivenDirectSum( category,
      function( diagram, sink, coproduct )
        local underlying_matrix_of_universal_morphism, morphism;
        
        underlying_matrix_of_universal_morphism := UnderlyingMatrix( sink[1] );
        
        for morphism in sink{ [ 2 .. Length( sink ) ] } do
          
          underlying_matrix_of_universal_morphism := 
            julia_vcat( underlying_matrix_of_universal_morphism, UnderlyingMatrix( morphism ) );
          
        od;
        
        return NemoVectorSpaceMorphism( coproduct, underlying_matrix_of_universal_morphism, Range( sink[1] ) );
        
    end );

    ##
    AddKernelEmbedding( category,
      function( morphism )
        local kernel_emb, kernel_object;
        
        kernel_emb := julia_nullspace( 
                        julia_transpose( UnderlyingMatrix( morphism ) )
                      );

        kernel_object :=
            NemoVectorSpaceObject( 
                julia_getindex( kernel_emb, 1 ),
                category
            );

        kernel_emb := 
            julia_transpose(
                julia_getindex( kernel_emb, 2 )
            );
        
        return NemoVectorSpaceMorphism( kernel_object, kernel_emb, Source( morphism ) );
        
    end );

    ##
    AddLift( category,
      function( alpha, beta )
        local right_divide, sol_exists;
        
        right_divide := 
              julia_cansolve(
                julia_transpose( UnderlyingMatrix( beta ) ), julia_transpose( UnderlyingMatrix( alpha ) )
              );
        

        ## tests if there is no solution
        if julia_getindex( right_divide, 1 ) = false then
          
          return fail;
          
        fi;
        
        right_divide := julia_transpose( julia_getindex( right_divide, 2 ) );
        
        return NemoVectorSpaceMorphism( Source( alpha ),
                                    right_divide,
                                    Source( beta ) );
        
    end );

    ##
    AddCokernelProjection( category,
      function( morphism )
        local cokernel_proj, cokernel_obj;
        
        cokernel_proj := julia_nullspace( UnderlyingMatrix( morphism ) );
        
        cokernel_obj := NemoVectorSpaceObject( julia_getindex( cokernel_proj, 1 ),
                                               category 
                        );
        
        cokernel_proj := julia_getindex( cokernel_proj, 2 );
        
        return NemoVectorSpaceMorphism( Range( morphism ), cokernel_proj, cokernel_obj );
        
    end );

    ##
    AddColift( category,
      function( alpha, beta )
        local left_divide;
        
        left_divide := julia_cansolve( UnderlyingMatrix( alpha ), UnderlyingMatrix( beta ) );
        
        ## tests if there is no solution
        if julia_getindex( left_divide, 1 ) = false then
          
          return fail;
          
        fi;
        
        left_divide := julia_getindex( left_divide, 2 );
        
        return NemoVectorSpaceMorphism( Range( alpha ),
                                        left_divide,
                                        Range( beta ) );
        
    end );

    ##
    AddTensorUnit( category,
      
      function( )
        
        return NemoVectorSpaceObject( 1, category );
        
    end );

    ## Basic Operations for Monoidal Categories
    ##
    AddTensorProductOnObjects( category,
      
      function( object_1, object_2 )
              
        return NemoVectorSpaceObject( Dimension( object_1 ) * Dimension( object_2 ), category );
            
    end );

    ##
    AddTensorProductOnMorphismsWithGivenTensorProducts( category,
      
      function( new_source, morphism_1, morphism_2, new_range )
        
        return NemoVectorSpaceMorphism( new_source,
                                        julia_kronecker_product( UnderlyingMatrix( morphism_1 ), UnderlyingMatrix( morphism_2 ) ),
                                        new_range );
        
    end );
    

end );


##
InstallMethodWithCache( NemoVectorSpaceObject,
                        [ IsInt, IsCapCategory ],
               
  function( dimension, category )
    local vector_space_object;

    if dimension < 0 then
      
      return Error( "first argument must be a non-negative integer" );
      
    fi;
    
    vector_space_object := rec( );
    
    ObjectifyObjectForCAPWithAttributes( vector_space_object, category,
                                         Dimension, dimension );
    
    return vector_space_object;
    
end );

##
InstallMethod( NemoVectorSpaceMorphism,
               [ IsNemoVectorSpaceObject, IsNemoMatrixObj, IsNemoVectorSpaceObject ],
  function( source, matrix, range )

    return NemoVectorSpaceMorphism( source, JuliaPointer( matrix ), range );
    
end );

##
InstallMethod( NemoVectorSpaceMorphism,
               [ IsNemoVectorSpaceObject, IsJuliaObject, IsNemoVectorSpaceObject ],
               
  function( source, matrix, range )
    local vector_space_morphism, homalg_field, category;
    
    category := CapCategory( source );
    
    if not IsIdenticalObj( category, CapCategory( range ) ) then
      
      return Error( "source and range are not defined over identical categories" );
      
    fi;
    
    vector_space_morphism := rec( );
    
    ObjectifyMorphismForCAPWithAttributes( vector_space_morphism, category,
                                           Source, source,
                                           Range, range,
                                           UnderlyingMatrix, matrix
    );
    
    return vector_space_morphism;
    
end );

####################################
##
## Display
##
####################################

##
InstallMethod( Display,
               [ IsNemoVectorSpaceMorphism ],
               
  function( morphism )
    
    Display( UnderlyingMatrix( morphism ) );
    
end );