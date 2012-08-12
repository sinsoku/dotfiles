set formatoptions-=r " 挿入モードで改行した時に # を自動挿入しない
set formatoptions-=o " ノーマルモードで o や O をした時に # を自動挿入しない

" RSpec syntac
function! RSpecSyntax()
  hi def link rubyRailsTestMethod Function
  syn keyword rubyRailsTestMethod describe context it its specify shared_examples_for it_should_behave_like before after around subject fixtures controller_name helper_name
  syn match rubyRailsTestMethod '\<let\>!\='
  syn keyword rubyRailsTestMethod violated pending expect double mock mock_model stub_model
  syn match rubyRailsTestMethod '\.\@<!\<stub\>!\@!'
endfunction
autocmd BufReadPost *_spec.rb call RSpecSyntax()
