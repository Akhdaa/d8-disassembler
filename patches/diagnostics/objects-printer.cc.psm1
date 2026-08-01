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
  os << "\nStart ScopeInfoChain\n";
  Tagged<ScopeInfo> s = this->scope_info();
  for (int d = 0; d < 4 && s.ptr() != kNullAddress; ++d) {
    os << "\nStart ScopeInfo depth " << d << "\n";
    s->ScopeInfoPrint(os);
    if (!s->HasOuterScopeInfo()) break;
    s = s->OuterScopeInfo();
    if (s.ptr() == kNullAddress || s.ptr() == s.ptr()) break;
  }
  os << "\nEnd ScopeInfoChain\n";
"@
        return $Body
    }
    return $Content
}
