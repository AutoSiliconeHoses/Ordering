$file = $args[0]
$pipe = [RegEx]::Escape("|")
$badIds = Import-CSV $file | Select 'SaleID' | ? {$_.SaleId | Select-String $pipe}
$export = Import-CSV $file | Select 'SaleID', 'SellerID','Item SKU','Item Qty' | ? {!($_.SaleId | Select-String $pipe)}

$badIds | % {
    $badid = "Bad OrderId: " + $_.SaleId
    $badid | Add-Content '\\DISKSTATION\Feeds\Ordering\Errors.txt'
}

$export | % {
    $orderId = $_.SaleId
    If ($orderId -match '\d\d\d-\d\d\d\d\d\d\d-\d\d\d\d\d\d\d') {
        $amazon = $true
    }
    If (!($orderId -match '\d\d\d-\d\d\d\d\d\d\d-\d\d\d\d\d\d\d')) {
        $ebay = $true
        $sellerId = $_.SellerId
        Switch ($sellerId) {
            'autoperformanceonline' {$seller = 'APO'}
            'ultimatecareparts' {$seller = 'UCP'}
            'performanceraceparts' {$seller = 'PRP'}
            'aptoolstore' {$seller = 'APT'}
            'mrsilicone' {$seller = 'MRS'}
            'autosiliconehoses_outlet' {$seller = 'ASHO'}
            'apmotorstoreoutlet' {$seller = 'APM'}
            'apautomotive509-1' {$seller = 'AUT'}
            'AP Motor Store' {$seller = 'AMZ'}
        }
        $orderId = $orderId + $seller
    }

    $orderId
    $orderPath = "\\DISKSTATION\Feeds\Ordering\Uploads\$orderId`.csv"
    $sku = $_."Item SKU" -replace '(-...-FPS).*', ''
    $qty = $_."Item Qty"
    $order = "$sku,$qty"
    $order | Add-Content $orderPath
}