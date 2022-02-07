#
# NemoLinearAlgebraForCAP: Category of Matrices over a Nemo-Field for CAP
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "NemoLinearAlgebraForCAP",
Subtitle := "Category of Matrices over a Nemo-Field for CAP",
Version := "0.2",
Date := "08/08/2019", # dd/mm/yyyy format

Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Sebastian",
    LastName := "Posur",
    WWWHome := "https://sebastianpos.github.io",
    Email := "sebastian.posur@uni-siegen.de",
    PostalAddress := Concatenation(
               "Department Mathematik\n",
               "Universität Siegen\n",
               "Walter-Flex-Straße 3\n",
               "57068 Siegen\n",
               "Germany" ),
    Place := "Siegen",
    Institution := "University of Siegen",
  ),
],

#SourceRepository := rec( Type := "TODO", URL := "URL" ),
#IssueTrackerURL := "TODO",
#SupportEmail := "TODO",

PackageWWWHome := "http://TODO/",

PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL     := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL     := Concatenation( ~.PackageWWWHome,
                                 "/", ~.PackageName, "-", ~.Version ),

ArchiveFormats := ".tar.gz",

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "dev",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "NemoLinearAlgebraForCAP",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Category of Matrices over a Nemo-Field for CAP",
),

Dependencies := rec(
  GAP := ">= 4.9.1",
  NeededOtherPackages := [ [ "JuliaExperimental", ">= 0.1" ],
                           [ "GAPDoc", ">= 1.5" ],
                           [ "ToolsForHomalg", ">=2015.09.18" ],
                           [ "MatricesForHomalg", ">= 2018.02.04" ],
                           [ "CAP", ">= 2019.01.16" ],
                           [ "MonoidalCategories", ">= 2019.01.16" ],
                           ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [
                            [ "CompilerForCAP", ">= 2020.07.06" ],
                        ],
),

AvailabilityTest := function()
        return true;
    end,

TestFile := "tst/testall.g",

#Keywords := [ "TODO" ],

));


