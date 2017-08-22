#!/bin/bash

scriptProcessingDir="scriptProcessing"
mkdir "$scriptProcessingDir" 2> /dev/null

port=8020
uriBase="https://$castip:$port"

urlEncodedHdr="-H \"Content-Type: application/x-www-form-urlencoded\""

xmlDataPost="__Content-Type=application/xml&__Accept=*/*"
cmd="curl -skL --trace-ascii $scriptProcessingDir/trace.out --user $castuser:$castpw "

xmlSaveSourceCatalogFromArgs() {
  xmlSaveSourceCatalogFromArgsWithId "$1" "$2" "$3" "" "$4"
}

xmlSaveSourceCatalogFromArgsWithId() {
  name="$1"
  version="$2"
  desc="$3"
  if [ -z "$4" ]; then
    id=""
  else
    id="id=\"$4\""
  fi
  sources="$5"

  read -r -d '' xmlSaveSourceCatalog <<-ENDOFMESSAGE
    <saveSourceCatalog xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
      <sourceCatalog name="$name" version="$version" description="$desc" $id>
        $sources
      </sourceCatalog>
    </saveSourceCatalog>
ENDOFMESSAGE
}

getSourceCatalogsIntoFile() {
  $cmd $uriBase/sourcecatalog/requestAll -o "$1-temp"
  xmllint --format "$1-temp" > "$1"
  rm "$1-temp"
}

addSourceCatalogFromFile() {
  catalogFile="$1"
  newCatalog=$(<$catalogFile)
  $cmd -d $xmlDataPost --data-urlencode "_body=$newCatalog" $uriBase/sourcecatalog/add
}

addSourceCatalogFromArgs() {
  xmlSaveSourceCatalogFromArgs "$1" "$2" "$3" "$4"
  $cmd -d $xmlDataPost --data-urlencode "_body=$xmlSaveSourceCatalog" $uriBase/sourcecatalog/add
}

getCatalogIdByNameFromFile() {
  catalogId=`xmllint --xpath "string(//*[@name='$1']/@id)" "$2" | tr -d '[:space:]'`
}

delSourceCatalogByNameFromFile() {
  getCatalogIdByNameFromFile "$1" "$2"
  $cmd --request POST $uriBase/sourcecatalog/delete/$catalogId
}

getOneTimeToken() {
  outputFile="$scriptProcessingDir/output-tmp.xml"
  $cmd --request POST $uriBase/security/createOneTimeToken.form -o "$outputFile"
  oneTimeToken=`xmllint --xpath "string(/success/@oneTimeId)" "$outputFile" | tr -d '[:space:]'`
  rm "$outputFile"
}

getUploadUrl() {
  outputFile="$scriptProcessingDir/output-tmp.xml"
  $cmd $uriBase/sourcecatalog/getUploadUrl -o "$outputFile"
  uploadUrl=`xmllint --xpath "string(/httpUrl/@value)" "$outputFile"`
  rm "$outputFile"
}

uploadFile() {
  srcFile="$1"
  data=$(<$srcFile)

  getUploadUrl
  getOneTimeToken
  formData="--form Filename=$srcFile"
  uri="$uploadUrl?Token=$oneTimeToken"
  $cmd --form file-upload=@"$srcFile" $formData $uri -o "$2-temp"
  xmllint --format "$2-temp" > "$2"
  rm "$2-temp"
}

parseSourcesFromFileToFile() {
  formData="-d __Content-Type=application/xml -d __Accept=*/*"
  body=$(<$1)
  $cmd --data-urlencode "_body=$body" $formData $uriBase/sourcecatalog/parseSources -o "$2-temp"
  xmllint --xpath '/sources' "$2-temp" > "$2-result"
  rm "$2-temp"
  xmllint --format "$2-result" > "$2"
  rm "$2-result"
}

getSourceCatalogByNameFromFileToFile() {
  getCatalogIdByNameFromFile "$1" "$2"
  $cmd $uriBase/sourcecatalog/request/$catalogId -o "$3-temp"
  xmllint --format "$3-temp" > "$3"
  rm "$3-temp"
}

getXmlNodeIntoFile() {
  xmllint --xpath "$1" "$2" > "$3"
}

extractSourcesEntityFromFileToFile() {
  getXmlNodeIntoFile '//sources' "$1" "$2"
}

extractSourceElementsFromFileToFile() {
  getXmlNodeIntoFile '///Source' "$1" "$2"
}

viewSourceDifferencesFromBaseFileFromUploadedFileToViewFile() {
  read -r -d '' body <<-ENDOFMESSAGE
    <viewSourceDifferences xmlns="http://www.ccadllc.com/schema/SourceCatalog/1">
      <baseSources>
        $(<$1)
      </baseSources>
      <uploadedSources>
        $(<$2)
      </uploadedSources>
    </viewSourceDifferences>
ENDOFMESSAGE
  formData="-d __Content-Type=application/xml -d __Accept=*/*"
  $cmd --data-urlencode "_body=$body" $formData $uriBase/sourcecatalog/viewSourceDifferences -o "$3-temp"
  xmllint --format "$3-temp" > "$3"
  rm "$3-temp"
}

getSourceCatalogDetailsByNameFromFileContainingSources() {
  getSourceCatalogDetailsByNameFromFile "$1" "$2"
  sources=`xmllint --xpath "//*[@name='$1']/sources" "$2"`
}

getSourceCatalogDetailsByNameFromFile() {
  catalogId=`xmllint --xpath "string(//*[@name='$1']/@id)" "$2" | tr -d '[:space:]'`
  version=`xmllint --xpath "string(//*[@name='$1']/@version)" "$2" | tr -d '[:space:]'`
  description=`xmllint --xpath "string(//*[@name='$1']/@description)" "$2" | tr -d '[:space:]'`
}

updateCatalogByNameFromFileWithSourcesFile() {
  getSourceCatalogDetailsByNameFromFile "$1" "$2"
  xmlSaveSourceCatalogFromArgsWithId "$1" "$version" "$description" "$catalogId" "$(<$3)"
  $cmd -d $xmlDataPost --data-urlencode "_body=$xmlSaveSourceCatalog" $uriBase/sourcecatalog/update
}

getRepositoryToFile() {
  $cmd --data-urlencode "requestRepositories=<requestRepositories/>" $uriBase/repositories/repositoryManagement.form > $1-temp
  xmllint --format $1-temp > $1
  rm $1-temp
}

getRepositoryLocationByNameFromFile() {
  repositoryLocation=`xmllint --xpath "string(//*[@name='$1']/@location)" $2`
}

getRepositoryDescriptionByNameFromFile() {
  repositoryDescription=`xmllint --xpath "string(//*[@name='$1']/@description)" $2`
}

getProgressMonitorDetailsFromFile() {
  monitorId=`xmllint --xpath "string(//@id)" $1`
  monitorCanceled=`xmllint --xpath "string(//@canceled)" $1`
  monitorPercentDone=`xmllint --xpath "string(//@percentDone)" $1`
  monitorComplete=`xmllint --xpath "string(//@complete)" $1`
}

waitForProgressMonitorToCompleteFromFile() {
  progressFile="$scriptProcessingDir/progressFile.xml"
  getProgressMonitorDetailsFromFile "$1"
  echo "progress $monitorPercentDone"
  while [ "$monitorComplete" == "false" ]; do
    echo "progress $monitorPercentDone"
    $cmd $uriBase/repositories/repositoryProgressMonitor/$monitorId -o "$progressFile"
    getProgressMonitorDetailsFromFile "$progressFile"
  done
}

publishCatalogByIdToRepositoryByNameFromFile() {
  publishedResultFile="$scriptProcessingDir/publishedResult.xml"
  getRepositoryLocationByNameFromFile "$2" "$3"
  getRepositoryDescriptionByNameFromFile "$2" "$3"
  $cmd -d "id=$1" -d "repositoryPath=$repositoryLocation" --data-urlencode "label=$repositoryDescription" -d "providerType=com.ccadllc.firebird.cast.sourcecatalog" $uriBase/repositories/publish -o "$publishedResultFile"
  waitForProgressMonitorToCompleteFromFile "$publishedResultFile"
}

editSourceCatalogByNameFromFileToFileWithNewVersion() {
  sourceCatalogFile="$scriptProcessingDir/sourceCatalog.xml"
  getSourceCatalogByNameFromFileToFile "$1" "$2" "$sourceCatalogFile"
  getSourceCatalogDetailsByNameFromFileContainingSources "$1" "$sourceCatalogFile"
  xmlSaveSourceCatalogFromArgsWithId "$1" "$3" "$description" "$catalogId" "$sources"
  $cmd -d $xmlDataPost --data-urlencode "_body=$xmlSaveSourceCatalog" $uriBase/sourcecatalog/update
}
