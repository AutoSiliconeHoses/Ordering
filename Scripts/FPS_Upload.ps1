$Host.Ui.RawUI.WindowTitle = "FPS Ordering"
$filepath = $args[0]
$customerRef = $filepath.Replace('\\DISKSTATION\Feeds\Ordering\Uploads\','').Replace('.csv','')
#$filepath = '\\DISKSTATION\Feeds\Ordering\Uploads\Test.csv'
#$customerRef = 'YEET'

$WatinPath = '\\DISKSTATION\Feeds\Ordering\Scripts\WatiN\bin\net40\WatiN.Core.dll'
$watin = [Reflection.Assembly]::LoadFrom( $WatinPath )
$ie = new-object WatiN.Core.IE("https://fdrive.fpsdistribution.co.uk/savedbasket/upload")

#Login
$ie.WaitForComplete()
If ($ie.Uri.AbsoluteUri -eq "https://fdrive.fpsdistribution.co.uk/user/login") {
    "Login Page"
    gc "\\DISKSTATION\Feeds\Ordering\Scripts\login.txt" | % {Invoke-Expression $_}

    $ie.TextField({param($fu) $fu.GetAttributeValue("name") -eq 'Username' }).Value = $username
    $ie.TextField({param($fu) $fu.GetAttributeValue("name") -eq 'Password' }).Value = $password
    $ie.Button({param($fu) $fu.GetAttributeValue("ClassName") -eq 'sign-in' }).ClickNoWait()
}

#Upload File
$ie.WaitForComplete()
If ($ie.Uri.AbsoluteUri -eq "https://fdrive.fpsdistribution.co.uk/savedbasket/upload") {
    "Logged In"
    Try {$ie.FileUpload({param($fu) $fu.GetAttributeValue("name") -eq 'file' }).set($filepath)}
    Catch {"File not found"; $ie.Close(); Exit}
    $ie.Button({param($fu) $fu.GetAttributeValue("ClassName") -eq 'btn btn-primary btn-block filepicker-load' }).Click()
    "File Uploaded"
}

#Preview
$ie.WaitForComplete()
If ($ie.Uri.AbsoluteUri -eq "https://fdrive.fpsdistribution.co.uk/savedbasket/preview") {
    "Preview Page"
		$errorBool = $false
    $ie.TableRows | % {
        If ($_.ClassName -eq 'danger') {
			$errorBool = $true
			$errorMessage = $customerRef + " - " + $_.Text
			$errorMessage
			$error | Add-Content '\\DISKSTATION\Feeds\Ordering\Errors.txt'
        }
    }
		If ($errorBool) {
            $ie.Close()
			Exit
		}
    $ie.Link({param($fu) $fu.GetAttributeValue("ClassName") -eq 'btn btn-primary purchaseorder-continue' }).Click()
    $ie.Div({param($fu) $fu.GetAttributeValue("ClassName") -eq 'alert alert-info'}).InnerHtml
    If ($ie.Div({param($fu) $fu.GetAttributeValue("ClassName") -eq 'alert alert-info'}).InnerHtml -like 'Your basket is currently empty') {$ie.Close(); EXIT}
    "Continuing"
}

#Basket
$ie.WaitForComplete()
If ($ie.Uri.AbsoluteUri -eq "https://fdrive.fpsdistribution.co.uk/basket") {
    "Proceeding with order"
    $ie.Link({param($fu) $fu.GetAttributeValue("ClassName") -eq 'btn btn-primary btn-block' }).Click()
}

#Checkout
$ie.WaitForComplete()
If ($ie.Uri.AbsoluteUri -eq "https://fdrive.fpsdistribution.co.uk/order/details") {
    "Filling in checkout form"
    $ie.TextField({param($fu) $fu.GetAttributeValue("name") -eq 'customerref' }).Value = $customerRef
    $ie.Button({param($fu) $fu.GetAttributeValue("ClassName") -eq 'btn btn-primary btn-block' }).Click()
    "Form complete"
}

<#
UNKNOWN TERRITORY
REQUIRES AN ORDER TO BE MADE

#Order Confirmation
$ie.WaitForComplete()
If ($ie.Uri.AbsoluteUri -eq <PUT URL HERE>) {
    $ie.Button({param($fu) $fu.GetAttributeValue("ClassName") -eq <PUT BUTTON NAME HERE> }).Click()
}

#Print
$ie.WaitForComplete()
If ($ie.Uri.AbsoluteUri -eq <PUT URL HERE>) {
    $ie.InternetExplorer.ExecWB(6,2,1)
    $ie.Close()
}

#>
