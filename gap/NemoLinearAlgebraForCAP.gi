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
        
        matrix := Julia.Nemo.identity_matrix( nemo_field, Dimension( object ) );

        return NemoVectorSpaceMorphism( object, matrix, object );
        
    end );

    ##
    AddPreCompose( category,
      
      function( alpha, beta )

        return NemoVectorSpaceMorphism(
                Source( alpha ),
                Julia.Nemo.("*")(UnderlyingMatrix( alpha ), UnderlyingMatrix( beta ) ),
                Range( beta )
        );

    end );

    ##
    AddAdditionForMorphisms( category,
      function( alpha, beta )
        
        return NemoVectorSpaceMorphism( 
                Source( alpha ),
                Julia.Nemo.("+")( UnderlyingMatrix( alpha ), UnderlyingMatrix( beta ) ),
                Range( beta ) 
        );
        
    end );

    ##
    AddAdditiveInverseForMorphisms( category,
      function( alpha )
        
        return NemoVectorSpaceMorphism( 
                Source( alpha ),
                Julia.Nemo.("-")( UnderlyingMatrix( alpha ) ),
                Range( alpha ) 
        );
        
    end );

    ##
    AddZeroMorphism( category,
      function( source, range )
        
        return NemoVectorSpaceMorphism( 
                source,
                Julia.Nemo.zero_matrix( nemo_field, Dimension( source ), Dimension( range ) ),
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
                        Julia.Nemo.zero_matrix( nemo_field, Dimension( sink ), 0 ), 
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
                        Julia.Nemo.zero_matrix( nemo_field, 0, Dimension( source ) ), 
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
            Julia.Nemo.vcat( Julia.Nemo.zero_matrix( nemo_field, dim_pre, dim_factor ), 
                             Julia.Nemo.identity_matrix( nemo_field, dim_factor ),
                             Julia.Nemo.zero_matrix( nemo_field, dim_post, dim_factor ) );
        
        return NemoVectorSpaceMorphism( direct_sum_object, projection_in_factor, object_list[ projection_number ] );
        
    end );

    ##
    AddUniversalMorphismIntoDirectSumWithGivenDirectSum( category,
      function( diagram, sink, direct_sum )
        local underlying_matrix_of_universal_morphism, morphism;
        
        underlying_matrix_of_universal_morphism := CallFuncList( Julia.Nemo.hcat, List( sink, s -> UnderlyingMatrix( s ) ) );
        
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
        
        injection_of_cofactor := 
            Julia.Nemo.hcat( Julia.Nemo.zero_matrix( nemo_field, dim_cofactor, dim_pre ), 
                             Julia.Nemo.identity_matrix( nemo_field, dim_cofactor ),
                             Julia.Nemo.zero_matrix( nemo_field, dim_cofactor, dim_post ) );
        
        return NemoVectorSpaceMorphism( object_list[ injection_number ], injection_of_cofactor, coproduct );

    end );
    
    ##
    AddUniversalMorphismFromDirectSumWithGivenDirectSum( category,
      function( diagram, sink, coproduct )
        local underlying_matrix_of_universal_morphism, morphism;
        
        underlying_matrix_of_universal_morphism := CallFuncList( Julia.Nemo.vcat, List( sink, s -> UnderlyingMatrix( s ) ) );
        
        return NemoVectorSpaceMorphism( coproduct, underlying_matrix_of_universal_morphism, Range( sink[1] ) );
        
    end );

    ##
    AddKernelEmbedding( category,
      function( morphism )
        local kernel_emb_pair, kernel_object, kernel_emb;
        
        kernel_emb_pair := Julia.Nemo.nullspace( 
                        Julia.Nemo.transpose( UnderlyingMatrix( morphism ) )
                      );

        kernel_object :=
            NemoVectorSpaceObject( 
                Julia.Base.getindex( kernel_emb_pair, 1 ),
                category
            );

        kernel_emb := 
            Julia.Nemo.transpose(
                Julia.Base.getindex( kernel_emb_pair, 2 )
            );
        
        return NemoVectorSpaceMorphism( kernel_object, kernel_emb, Source( morphism ) );
        
    end );

    ##
    AddLift( category,
      function( alpha, beta )
        local right_divide_pair, right_divide;
        
        right_divide_pair := 
              Julia.Hecke.can_solve(
                Julia.Nemo.transpose( UnderlyingMatrix( beta ) ), Julia.Nemo.transpose( UnderlyingMatrix( alpha ) )
              );
        

        ## tests if there is no solution
        if Julia.Base.getindex( right_divide_pair, 1 ) = false then
          
          return fail;
          
        fi;
        
        right_divide := Julia.Nemo.transpose( Julia.Base.getindex( right_divide_pair, 2 ) );
        
        return NemoVectorSpaceMorphism( Source( alpha ),
                                    right_divide,
                                    Source( beta ) );
        
    end );

    ##
    AddCokernelProjection( category,
      function( morphism )
        local cokernel_proj_pair, cokernel_obj, cokernel_proj;
        
        cokernel_proj_pair := Julia.Nemo.nullspace( UnderlyingMatrix( morphism ) );
        
        cokernel_obj := NemoVectorSpaceObject( Julia.Base.getindex( cokernel_proj_pair, 1 ),
                                               category 
                        );
        
        cokernel_proj := Julia.Base.getindex( cokernel_proj_pair, 2 );
        
        return NemoVectorSpaceMorphism( Range( morphism ), cokernel_proj, cokernel_obj );
        
    end );

    ##
    AddColift( category,
      function( alpha, beta )
        local left_divide_pair, left_divide;
        
        left_divide_pair := Julia.Hecke.can_solve( UnderlyingMatrix( alpha ), UnderlyingMatrix( beta ) );
        
        ## tests if there is no solution
        if Julia.Base.getindex( left_divide_pair, 1 ) = false then
          
          return fail;
          
        fi;
        
        left_divide := Julia.Base.getindex( left_divide_pair, 2 );
        
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
                                        Julia.Hecke.kronecker_product( UnderlyingMatrix( morphism_1 ), UnderlyingMatrix( morphism_2 ) ),
                                        new_range );
        
    end );
    

end );


##
InstallMethodWithCache( NemoVectorSpaceObject,
                        [ IsInt, IsCapCategory ],
               
  function( dimension, category )
    local vector_space_object;

    if dimension < 0 then
        
        Error( "first argument must be a non-negative integer" );
        
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
        
        Error( "source and range are not defined over identical categories" );
        
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
