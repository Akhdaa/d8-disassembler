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
  Tagged<ScopeInfo> current_scope_info = this->scope_info();
  for (int scope_depth = 0; scope_depth < 4; ++scope_depth) {
    if (current_scope_info.ptr() == kNullAddress) break;
    os << "\nStart ScopeInfo depth " << scope_depth << "\n";
    current_scope_info->ScopeInfoPrint(os);
    os << "End ScopeInfo depth " << scope_depth << "\n";
    if (!current_scope_info->HasOuterScopeInfo()) break;
    Tagged<ScopeInfo> outer = current_scope_info->OuterScopeInfo();
    if (outer.ptr() == current_scope_info.ptr()) break;
    if (outer.ptr() == kNullAddress) break;
    current_scope_info = outer;
  }
  os << "\nEnd ScopeInfoChain\n";
  os << "\nStart BytecodeArray\n";
  if (isolate != nullptr && this->HasBytecodeArray()) {
    this->GetActiveBytecodeArray(isolate)->Disassemble(os);
  } else {
    os << "<none>\n";
  }
  os << "\nEnd BytecodeArray\n";
  os << std::flush;
"@
        return $Body
    }

    return $Content
}
