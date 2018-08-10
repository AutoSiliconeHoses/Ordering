#Deletes old files
del '\\DISKSTATION\Feeds\Ordering\Suppliers\FPS\Orders\*'
del '\\DISKSTATION\Feeds\Ordering\Suppliers\FPS\Uploads\*'
del '\\DISKSTATION\Feeds\Ordering\Errors\FPSerrors.txt' -ErrorAction SilentlyContinue

#Gets Export Data
"Fetching files"
$dir = "\\DISKSTATION\AP Production\AIMCO EXPRESS\*"
Get-ChildItem -Path $dir -file | ? {$_.Name -like "fps-export*"} | % {
    move $_.Fullname '\\DISKSTATION\Feeds\Ordering\Suppliers\FPS\Orders'
}

#Turns export data into a folder full of baskets
"Creating basket files"
Get-ChildItem '\\DISKSTATION\Feeds\Ordering\Suppliers\FPS\Orders' | % {
    . \\DISKSTATION\Feeds\Ordering\Suppliers\FPS\Scripts\ExportToBasket.ps1 $_.Fullname
}
$orderCount = (Get-ChildItem '\\DISKSTATION\Feeds\Ordering\Suppliers\FPS\Uploads' | Measure-Object ).Count
"$orderCount files found"
If (!(Test-Path -Path '\\DISKSTATION\Feeds\Ordering\Suppliers\FPS\Uploads\*')) {sleep 3; EXIT}

#Goes through the checkout process with each basket
"Ordering"
Get-ChildItem '\\DISKSTATION\Feeds\Ordering\Suppliers\FPS\Uploads' | % {$counter = 0}{
    Write-Progress -Activity "Processing Orders" -status "Orders complete: $counter/$orderCount. Currently running $_" -percentComplete (($count/$orderCount)*100)
    $_.Name
    . \\DISKSTATION\Feeds\Ordering\Suppliers\FPS\Scripts\FPS_Upload.ps1 $_.FullName
    $counter++
}