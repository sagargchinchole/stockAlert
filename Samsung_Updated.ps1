param ($productList)
################################################################################################
function sendAlert($prodTitle,$pincode,$prodUrl){
    $bot_id="1160665260:AAES1e4F8aYAfGLdBfDl4cRcr-4z0UKoBuk"
    $chat_id="fkStockAlertTest"
    $message="Samsung Store - $prodTitle in stock for $pincode $prodUrl"
    $alertResponse=Invoke-RestMethod -Uri "https://api.telegram.org/bot$bot_id/sendMessage?chat_id=@$chat_id&text=$message&disable_web_page_preview=true"
}
################################################################################################

$baseUrl="https://www.samsung.com/in/api/v4"
$pincode="422003"

$productList=$productList.ToUpper() #'SM-M336BZBP,SM-M336BZNP,sm-m325flbc'.ToUpper()


###########################################################

$url="$baseUrl/configurator/syndicated-product-linear?skus=$productList"
$url

############################################################################
[System.Collections.ArrayList]$instockIds=@()

while($true) {

    Start-Sleep -Seconds 2
    $response=Invoke-RestMethod -Uri $url
    
    $products=$response.products
    
    foreach($currProduct in $productList.Split(',').Trim())
    {
        $stockStatus = $products.$currProduct.inventory.status
        if($stockStatus -eq "InStock"){
            if(-not $instockIds.Contains($currProduct)){
                $instockIds.Add($currProduct)
    
                $productTitle=$products.$currProduct.product_display_name
    
                $uri=$products.$currProduct.urls.product_url
                $productUrl="https://www.samsung.com$uri/buy"
    
                sendAlert $productTitle $pincode $productUrl
            }
        }
        else {
            if($instockIds.Contains($currProduct)){
                $instockIds.Remove($currProduct)
            }
        }    
    }
}



#######################################################################
