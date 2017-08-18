#!/bin/bash

# User specified shell exports
#castuser
#castpw
#castip

source cast-source-catalog.sh

catalogsFile="$scriptProcessingDir/catalogsOutput.xml"
catalogsFileAfterAdd="$scriptProcessingDir/catalogsAfterAdd.xml"
catalogsFileAfterDel="$scriptProcessingDir/catalogsAfterDel.xml"

loginGettingSecurityContext $castuser $castpw $castip

echo
echo "#####################################"
echo "add empty catalog"
getSourceCatalogsIntoFile "$catalogsFile"
addSourceCatalogFromFile "resources/empty-catalog.xml"
getSourceCatalogsIntoFile "$catalogsFileAfterAdd"
diff "$catalogsFile" "$catalogsFileAfterAdd"

echo
echo "#####################################"
echo "delete empty catalog"
delSourceCatalogByNameFromFile "emptyCatalogFromFile" "$catalogsFileAfterAdd"
getSourceCatalogsIntoFile "$catalogsFileAfterDel"
diff "$catalogsFileAfterAdd" "$catalogsFileAfterDel"

echo
echo "#####################################"
echo "re-add empty catalog"
addSourceCatalogFromFile "resources/empty-catalog.xml"
getSourceCatalogsIntoFile "$catalogsFileAfterAdd"
diff "$catalogsFileAfterDel" "$catalogsFileAfterAdd"

echo
echo "#####################################"
echo "import a catalog"
parsedSourcesFile="$scriptProcessingDir/parsedSources.xml"
uploadedResultsFile="$scriptProcessingDir/uploadedResult.xml"
sourcesFile="$scriptProcessingDir/sources.xml"

uploadFile "resources/importCatalog.csv" "$uploadedResultsFile"
parseSourcesFromFileToFile "$uploadedResultsFile" "$parsedSourcesFile"
extractSourcesEntityFromFileToFile "$parsedSourcesFile" "$sourcesFile"
addSourceCatalogFromArgs "fromArgs1" "1.0.0" "desc fromArgs" "$(<$sourcesFile)"

echo
echo "#####################################"
echo "import the same catalog again - no upload/parse needed"
#import the same catalog - no need to procees an upload/parse as data is already in correct format
addSourceCatalogFromArgs "fromArgs2" "1.0.0" "desc fromArgs" "$(<$sourcesFile)"
getSourceCatalogsIntoFile "$catalogsFile"

