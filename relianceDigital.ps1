param ($productCodes=@())
##############################################################################################################
function sendAlert($productTitle, $productUrl,$pincode){
    $bot_id="1160665260:AAES1e4F8aYAfGLdBfDl4cRcr-4z0UKoBuk"
    $chat_id="fkStockAlertTest"
    $message="Reliance Store - $productTitle now for $pincode. $productUrl"
    $alertResponse=Invoke-RestMethod -Uri "https://api.telegram.org/bot$bot_id/sendMessage?chat_id=@$chat_id&text=$message&disable_web_page_preview=true"
}
######################################################################################################################################################

#$productCodes=@("492850038", "492850035") #, "493177765")
$pincode="462030"
$url="https://www.reliancedigital.in/rildigitalws/v2/rrldigital/productavailability/serviceabilitylist"

###################################################################################################

[System.Collections.ArrayList]$productListPayload=@()

foreach($product in $productCodes)
{
    $currItem=@{
                "productcode"=$product
                "toPincode"=$pincode
    }
    $index = $productListPayload.Add($currItem)
}

$payload = ConvertTo-Json -InputObject $productListPayload

#####################################################################################################

$headers = @{
 'Content-Type'='application/json'
 }
#####################################################################################################
[System.Collections.ArrayList]$instockIds=@()

while($instockIds.Count -ne $productCodes)
{
    Start-Sleep -Seconds 2
    $response=Invoke-RestMethod -Uri $url -Method Post -Body $payload -Headers $headers 
    foreach($product in $productCodes)
    {
        $isAvailable = $response.data.$product.serviceable
        if($isAvailable)
        {
            if(-not $instockIds.Contains($product))
            {
                $instockIds.Add($product)

                $productUrl = "https://www.reliancedigital.in/p/p/$product"
                $productUrlResponse = Invoke-WebRequest -Uri $productUrl

                $productTitle = $productUrlResponse.ParsedHtml.title
                sendAlert $productTitle $productUrl $pincode
            }
        }
        else
        {
              if($instockIds.Contains($product))
            {
                $instockIds.Remove($product)
            }
        }
    }
}



