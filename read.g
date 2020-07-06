#
# NemoLinearAlgebraForCAP: Category of Matrices over a Nemo-Field for CAP
#
# Reading the implementation part of the package.
#
ReadPackage( "NemoLinearAlgebraForCAP", "gap/NemoLinearAlgebraForCAP.gi" );

if IsPackageMarkedForLoading( "CompilerForCAP", ">= 2020.07.06" ) then
    
    ReadPackage( "NemoLinearAlgebraForCAP", "gap/CompilerLogic.gi" );
    
fi;
