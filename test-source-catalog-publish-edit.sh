#!/bin/bash

# User specified shell exports
#castuser
#castpw
#castip

source cast-source-catalog.sh

catalogsFile="$scriptProcessingDir/catalogsOutput.xml"
availableReposFile="$scriptProcessingDir/availableRepos.xml"
catalogsAfterPublishFile="$scriptProcessingDir/catalogsOutputAfterPublish.xml"
catalogsAfterEditFile="$scriptProcessingDir/catalogsOutputAfterEdit.xml"

echo
echo "#####################################"
echo "publish source catalog"
getSourceCatalogsIntoFile "$catalogsFile"
getRepositoryToFile "$availableReposFile"
publishCatalogByNameFromFileToRepositoryByNameFromFile "fromArgs2" "$catalogsFile" "Sources" "$availableReposFile"
getSourceCatalogsIntoFile "$catalogsAfterPublishFile"
diff "$catalogsFile" "$catalogsAfterPublishFile"

echo
echo "#####################################"
echo "editing source catalog to next version"

editSourceCatalogByNameFromFileWithNewVersion "fromArgs2" "$catalogsAfterPublishFile" "1.0.4"
getSourceCatalogsIntoFile "$catalogsAfterEditFile"
diff "$catalogsAfterPublishFile" "$catalogsAfterEditFile"

