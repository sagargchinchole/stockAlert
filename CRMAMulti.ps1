param ($itemIds=@(),$pincode)
################################################################################################
function sendAlert($prodTitle,$pincode,$prodUrl){
    $bot_id="1160665260:AAES1e4F8aYAfGLdBfDl4cRcr-4z0UKoBuk"
    $chat_id="fkStockAlertTest"
    $message="Croma Store-$prodTitle in stock for $pincode $prodUrl"
    $alertResponse=Invoke-RestMethod -Uri "https://api.telegram.org/bot$bot_id/sendMessage?chat_id=@$chat_id&text=$message&disable_web_page_preview=true"
}
################################################################################################
$url="https://api.croma.com/inventory/oms/v2/details-pwa"
#$pincode="462030"
#$itemIds=@("249123","251802", "251803") #("233961","233966", "233967", "230113", "249123","243463","243462", "243461", "243460")#"233960","233961","233962","233966","233967","231515", "231514", "231527","249664","249665", "249666", "249667", "256466", "256467")#,"251802","251803"-> nord ce2 lite# redmi 10,"251039","251040","251041" ) #"244936"#"233961"
############################################################################
[System.Collections.ArrayList]$promilinesPayload=@()
foreach($item in $itemIds)
{
    if($item.Equals("249664") -or $item.Equals("249665"))
    {
        $pincode="422003"
    }
    $currItem=@{
                "fulfillmentType"= "HDEL"
                "itemID"= $item
                "lineId"= "1"
                "requiredQty"= "1"
                shipToAddress=@{
                    "zipCode"= $pincode
                }
    }
    $index = $promilinesPayload.Add($currItem)
}
$payload=@{
    promise=@{
    "allocationRuleID"="SYSTEM"
    "checkInventory"= "Y"
    "organizationCode"= "CROMA"
    "sourcingClassification"= "EC"
    promiseLines=@{
        promiseLine=$promilinesPayload
        }
    }
} | ConvertTo-Json -Depth 15
##############################################################################

$headers = @{
 'Content-Type'='application/json'
 'sec-ch-ua-platform'="Windows"
 'oms-apim-subscription-key'='1131858141634e2abe2efb2b3a2a2a5d'
 }
 ################################################################
[System.Collections.ArrayList]$instockIds=@()

while($true) 
{
Start-Sleep -Seconds 2
$response=Invoke-RestMethod -Uri $url -Method Post -Body $payload -Headers $headers 

$promiseLine=$response.promise.suggestedOption.option.promiseLines.promiseLine
foreach($itemLine in $promiseLine) {
    $currItemId = $itemLine.itemID
    if(-not $instockIds.Contains($currItemId.toString()))
    {
    $instockIds.Add($currItemId)
    $dataUrl="https://api.tatadigital.com/api/v1.1/msd/data"
$dataHeaders = @{
 'Content-Type'='application/json'
 'sec-ch-ua-platform'="Windows"
 'client_id'='CROMA-WEB-APP'
 'Program-Id'='01eae2ec-0576-1000-bbea-86e16dcb4b79'
 }

 $dataPayload=@{
    "correlation_id"= "sssaasss"
    "client"= "CROMA"
    "mad_uuid" = "GdQVym2aQ2ZGe74U"
    "catalog" ="croma_products"
    fields=@("product_title",
        "product_price",
        "product_detail_page_url"
        "product_image_url"
    )
    data_params=@{
    "catalog_item_id"=$currItemId
    }
 } | ConvertTo-Json -Depth 15

$dataResponse=Invoke-RestMethod -Uri $dataUrl -Method Post -Body $dataPayload -Headers $dataHeaders
$prodTitle = $dataResponse.results.Get(0).data.Get(0).product_title
$imgUrl= $dataResponse.results.Get(0).data.Get(0).product_image_url
$prodUrl= "https://www.croma.com"+$dataResponse.results.Get(0).data.Get(0).product_detail_page_url

sendAlert $prodTitle $pincode $prodUrl
}
}

###################################################################################
$unavailableLines=$response.promise.suggestedOption.unavailableLines.unavailableLine
foreach($unavailableItem in $unavailableLines){
    $unItemId=$unavailableItem.itemID
   # echo "$unItemId not available"
    if($instockIds.Contains($unItemId.toString())){
        $instockIds.Remove($unItemId.toString())
    }
}

}
############################################################################


