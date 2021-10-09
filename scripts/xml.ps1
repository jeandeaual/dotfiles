function Read-FileFromStdin {
    $lines = @()

    while ($line = ([System.Console]::In).ReadLine()) {
        $lines += $line
    }

    if (-not $lines) {
        return $null
    }

    return $lines -join [System.Environment]::NewLine
}

function Format-XML {
    param (
        # Number of spaces to indent each level
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]
        $Indent = 4,
        # Whether to use CRLF or LF as line endings
        [Parameter(Mandatory = $false)]
        [bool]
        $CRLF = $true
    )

    $StringWriter = New-Object System.IO.StringWriter
    if ($crlf) {
        $StringWriter.NewLine = "`r`n"
    } else {
        $StringWriter.NewLine = "`n"
    }
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
    $XmlWriter.Formatting = "indented"
    $XmlWriter.Indentation = $Indent

    $global:XmlDoc.WriteContentTo($XmlWriter)

    $XmlWriter.Flush()
    $StringWriter.Flush()

    Write-Output $StringWriter.ToString()
}

function Update-Node {
    param (
        # XPath used to select the node to update
        [Parameter(Mandatory = $true)]
        [string]
        $XPath,
        # Value to update the node with
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Text
    )

    $Node = $global:XmlDoc.SelectSingleNode($XPath)
    if ($Node) {
        $Node.InnerText = $Text
        $Node.IsEmpty = [string]::IsNullOrEmpty($Text)
    } else {
        # Create a new text node
        $Elements = $XPath.Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)
        $LastElement = $global:XmlDoc
        $NewDoc = !$global:XmlDoc.DocumentElement

        foreach ($Element in $Elements) {
            if ($Element -eq $Elements[-1]) {
                $NewNode = $global:XmlDoc.CreateElement($Element)
                $NewNode.InnerText = $Text
                $NewNode.IsEmpty = [string]::IsNullOrEmpty($Text)
                $LastElement.AppendChild($NewNode) | Out-Null
                break
            }

            $Found = $LastElement.SelectSingleNode("/${Element}")
            if (!$Found) {
                $NewNode = $global:XmlDoc.CreateElement($Element)
                $LastElement.AppendChild($NewNode) | Out-Null
                $LastElement = $NewNode
            } else {
                $LastElement = $Found
            }
        }

        if ($NewDoc) {
            # Prepend the XML declaration
            $global:XmlDoc.InsertBefore(
                $global:XmlDoc.CreateXmlDeclaration("1.0", $null, $null),
                $global:XmlDoc.DocumentElement
            ) | Out-Null
        }
    }
}

[xml]$global:XmlDoc = Read-FileFromStdin

if ($null -eq $global:XmlDoc) {
    [xml]$global:XmlDoc = ''
}
