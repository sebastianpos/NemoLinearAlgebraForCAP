#############################################################################
##
##                                NemoLinearAlgebraForCAP package
##
##  Copyright 2018, Sebastian Posur,   University of Siegen
##
#! @Chapter Category of Nemo-Matrices
##
#############################################################################

####################################
##
#! @Section GAP Categories
##
####################################

#!
DeclareCategory( "IsNemoVectorSpaceObject",
                 IsCapCategoryObject and IsCellOfSkeletalCategory );

#!
DeclareCategory( "IsNemoVectorSpaceMorphism",
                 IsCapCategoryMorphism and IsCellOfSkeletalCategory );

####################################
##
#! @Section Constructors
##
####################################

#!
DeclareOperation( "NemoMatrixCategory",
                  [ IsJuliaObject ] );

#!
DeclareOperation( "NemoVectorSpaceObject",
                  [ IsInt, IsCapCategory ] );

#!
DeclareOperation( "NemoVectorSpaceMorphism",
                  [ IsNemoVectorSpaceObject, IsJuliaObject, IsNemoVectorSpaceObject ] );

#!
DeclareOperation( "NemoVectorSpaceMorphism",
                  [ IsNemoVectorSpaceObject, IsNemoMatrixObj, IsNemoVectorSpaceObject ] );

#!
DeclareGlobalFunction( "INSTALL_FUNCTIONS_FOR_NEMO_MATRIX_CATEGORY" );

####################################
##
#! @Section Attributes
##
####################################

#!
DeclareAttribute( "Dimension",
                  IsNemoVectorSpaceObject );

#!
DeclareAttribute( "UnderlyingMatrix",
                  IsNemoVectorSpaceMorphism );




