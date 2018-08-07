#Deletes old files
del '\\DISKSTATION\Feeds\Ordering\Orders\*'
del '\\DISKSTATION\Feeds\Ordering\Uploads\*'
del '\\DISKSTATION\Feeds\Ordering\Errors.txt' -ErrorAction SilentlyContinue

#Gets Export Data
"Fetching files"
$dir = "\\DISKSTATION\AP Production\AIMCO EXPRESS\*"
Get-ChildItem -Path $dir -file | ? {$_.Name -like "fps-export*"} | % {
    move $_.Fullname '\\DISKSTATION\Feeds\Ordering\Orders'
}

#Turns export data into a folder full of baskets
"Creating basket files"
Get-ChildItem '\\DISKSTATION\Feeds\Ordering\Orders' | % {
    . \\DISKSTATION\Feeds\Ordering\Scripts\ExportToBasket.ps1 $_.Fullname
}

Write-Host (Get-ChildItem '\\DISKSTATION\Feeds\Ordering\Uploads' | Measure-Object ).Count "files found"
If (!(Test-Path -Path '\\DISKSTATION\Feeds\Ordering\Uploads\*')) {sleep 3; EXIT}

#Goes through the checkout process with each basket
"Ordering"
Get-ChildItem '\\DISKSTATION\Feeds\Ordering\Uploads' | % {
    $_.Name
    . \\DISKSTATION\Feeds\Ordering\Scripts\FPS_Upload.ps1 $_.FullName
}
