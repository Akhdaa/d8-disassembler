Import-Module (Join-Path $PSScriptRoot "..\utils.psm1")
function Patch {
    param([string]$Content)
    $Content = Edit-FunctionBody -Content $Content `
        -FunctionName "void SharedFunctionInfo::SharedFunctionInfoPrint" `
        -Converter {
        param($Body)
        $Body = Set-CommentLine -Content $Body -Pattern "\s*PrintSourceCode\(os\);"
        $Body += "`n"
        $Body += @"
  os << "\nStart BytecodeArray\n";
  if (isolate != nullptr && this->HasBytecodeArray()) {
    this->GetActiveBytecodeArray(isolate)->Disassemble(os);
  } else { os << "<none>\n"; }
  os << "\nEnd BytecodeArray\n";
"@
        return $Body
    }
    return $Content
}
