#! @Chapter Examples and Tests

#! @Section Basic Commands

LoadPackage( "NemoLinearAlgebraForCAP" );;

#! @Example
R := Julia.Nemo.QQ;
#! <Julia: Rational Field>
vec := NemoMatrixCategory( R );
#! Category of Nemo vector spaces
V := NemoVectorSpaceObject( 1, vec );
#! <An object in Category of Nemo vector spaces>
W := NemoVectorSpaceObject( 2, vec );
#! <An object in Category of Nemo vector spaces>
start := IdentityMorphism( W );
#! <An identity morphism in Category of Nemo vector spaces>
alpha := start + start;
#! <A morphism in Category of Nemo vector spaces>
beta := PreCompose( alpha, alpha );
#! <A morphism in Category of Nemo vector spaces>
zero := ZeroMorphism( W, W );
#! <A zero morphism in Category of Nemo vector spaces>
IsCongruentForMorphisms( beta - beta, zero );
#! true
u_into := UniversalMorphismIntoZeroObject( W );
#! <A zero, split epimorphism in Category of Nemo vector spaces>
u_from := UniversalMorphismFromZeroObject( W );
#! <A zero, split monomorphism in Category of Nemo vector spaces>
U := DirectSum( [ W, W, W ]);
#! <An object in Category of Nemo vector spaces>
pi1 := ProjectionInFactorOfDirectSum( [ W, U, W ], 1 );
#! <A morphism in Category of Nemo vector spaces>
pi2 := ProjectionInFactorOfDirectSum( [ W, U, W ], 2 );
#! <A morphism in Category of Nemo vector spaces>
pi3 := ProjectionInFactorOfDirectSum( [ W, U, W ], 3 );
#! <A morphism in Category of Nemo vector spaces>
univ := UniversalMorphismIntoDirectSum( [ beta, beta ] );
#! <A morphism in Category of Nemo vector spaces>
iota1 := InjectionOfCofactorOfDirectSum( [ W, U, W ], 1 );
#! <A morphism in Category of Nemo vector spaces>
iota2 := InjectionOfCofactorOfDirectSum( [ W, U, W ], 2 );
#! <A morphism in Category of Nemo vector spaces>
iota3 := InjectionOfCofactorOfDirectSum( [ W, U, W ], 3 );
#! <A morphism in Category of Nemo vector spaces>
IsCongruentForMorphisms( 
     PreCompose( pi1, iota1 ) + PreCompose( pi2, iota2 ) + PreCompose( pi3, iota3 ),
     IdentityMorphism( DirectSum( [ W, U, W ] ) )
);
#! true
IsCongruentForMorphisms( 
     PreCompose( KernelLift( pi2, iota3 ), KernelEmbedding( pi2 ) ),
     iota3
);
#! true

IsCongruentForMorphisms(
     PreCompose( CokernelProjection( iota3 ), CokernelColift( iota3, pi2 ) ),
     pi2 
);
#! true
unit := TensorUnit( vec );
#! <An object in Category of Nemo vector spaces>
#! @EndExample

#! The following construction is based on constructors provided by Thomas Breuer
#! that can currently be found in the JuliaExperimental 0.1 package (as of 05/22/18)
#! @Example
x:= X( Rationals );;
F:= AlgebraicExtension( Rationals, x^2+1 );;
z:= Zero( F );;  o:= One( F );;  a:= RootOfDefiningPolynomial( F );;
FF:= ContextGAPNemo( F );;
vec := NemoMatrixCategory( FF!.JuliaDomainPointer );
#! Category of Nemo vector spaces
W := NemoVectorSpaceObject( 2, vec );
#! <An object in Category of Nemo vector spaces>
mat:= [ [ o, a/2 ], [ z, o ] ];
#! [ [ !1, 1/2*a ], [ !0, !1 ] ]
nmat:= GAPToNemo( FF, mat );
#! <<Julia: [1 1//2*a]
#! [0 1]>>
start := NemoVectorSpaceMorphism( W, nmat, W );
#! <A morphism in Category of Nemo vector spaces>
alpha := start + start;
#! <A morphism in Category of Nemo vector spaces>
beta := PreCompose( alpha, alpha );
#! <A morphism in Category of Nemo vector spaces>
zero := ZeroMorphism( W, W );
#! <A zero morphism in Category of Nemo vector spaces>
IsCongruentForMorphisms( beta - beta, zero );
#! true
u_into := UniversalMorphismIntoZeroObject( W );
#! <A zero, split epimorphism in Category of Nemo vector spaces>
u_from := UniversalMorphismFromZeroObject( W );
#! <A zero, split monomorphism in Category of Nemo vector spaces>
U := DirectSum( [ W, W, W ]);
#! <An object in Category of Nemo vector spaces>
pi1 := ProjectionInFactorOfDirectSum( [ W, U, W ], 1 );
#! <A morphism in Category of Nemo vector spaces>
pi2 := ProjectionInFactorOfDirectSum( [ W, U, W ], 2 );
#! <A morphism in Category of Nemo vector spaces>
pi3 := ProjectionInFactorOfDirectSum( [ W, U, W ], 3 );
#! <A morphism in Category of Nemo vector spaces>
univ := UniversalMorphismIntoDirectSum( [ beta, beta ] );
#! <A morphism in Category of Nemo vector spaces>
iota1 := InjectionOfCofactorOfDirectSum( [ W, U, W ], 1 );
#! <A morphism in Category of Nemo vector spaces>
iota2 := InjectionOfCofactorOfDirectSum( [ W, U, W ], 2 );
#! <A morphism in Category of Nemo vector spaces>
iota3 := InjectionOfCofactorOfDirectSum( [ W, U, W ], 3 );
#! <A morphism in Category of Nemo vector spaces>
IsCongruentForMorphisms( 
     PreCompose( pi1, iota1 ) + PreCompose( pi2, iota2 ) + PreCompose( pi3, iota3 ),
     IdentityMorphism( DirectSum( [ W, U, W ] ) )
 );
#! true
IsCongruentForMorphisms( 
     PreCompose( KernelLift( pi2, iota3 ), KernelEmbedding( pi2 ) ),
     iota3
 );
#! true
IsCongruentForMorphisms(
     PreCompose( CokernelProjection( iota3 ), CokernelColift( iota3, pi2 ) ),
     pi2 
 );
#! true
#! @EndExample