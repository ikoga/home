" -- ステータス行の設定 (ファイルの PATH、改行コード、ファイル形式、文字コード、カーソルの位置)
set statusline=%F%m%r%h%w\ \{%{&ff}\}\ [%Y]\ <asc=\%03.3b\ hex=\%02.2B>\ %=\ [%3l,%3v\ /\ %L\ ](%3p%%)
set laststatus=2
set guioptions+=m
":set encoding=japan
set encoding=utf-8
set fileencodings=utf-8,cp932,euc-jp,iso-2022-jp,shift-jis,utf-16,ucs-2-internal,ucs-2
set termencoding=utf-8
set fileformats=unix
set encoding=utf-8
set belloff=all

" -- インクリメンタルサーチとハイライト
set incsearch
set hlsearch
set ignorecase
set cursorline

" -- 入力モード時、ステータスラインのカラーを変更
augroup InsertHook
autocmd!
autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340
autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
augroup END

" -- highlight folded
highlight Folded     gui=none guifg=#804030 guibg=#fff0d0 ctermbg=darkgrey  ctermfg=blue  cterm=bold


" -- 全角スペースを検出
highlight JpSpace cterm=underline ctermfg=Blue guifg=Blue
au BufRead,BufNew * match JpSpace /　/

" -- タブをハイライトさせる
function! TabHilight()
        syntax match Tab "\t" display containedin=ALL
        highlight Tab term=underline ctermbg=Gray
endf

" -- :set paste/nopaste を F3 で切り替え
set pastetoggle=<F3>


" -- VIM TAB ( VIM > 7.3 )
" http://qiita.com/wadako111%40github/items/755e753677dd72d8036d
" Anywhere SID.
function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

" Set tabline.
function! s:my_tabline()  "{{{
  let s = ''
  for i in range(1, tabpagenr('$'))
    let bufnrs = tabpagebuflist(i)
    let bufnr = bufnrs[tabpagewinnr(i) - 1]  " first window, first appears
    let no = i  " display 0-origin tabpagenr.
    let mod = getbufvar(bufnr, '&modified') ? '!' : ' '
    let title = fnamemodify(bufname(bufnr), ':t')
    let title = '[' . title . ']'
    let s .= '%'.i.'T'
    let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
    let s .= no . ':' . title
    let s .= mod
    let s .= '%#TabLineFill# '
  endfor
  let s .= '%#TabLineFill#%T%=%#TabLine#'
  return s
endfunction "}}}
let &tabline = '%!'. s:SID_PREFIX() . 'my_tabline()'
set showtabline=2 " 常にタブラインを表示

" -- The prefix key.
nnoremap    [Tag]   <Nop>
nmap    t [Tag]
" -- Tab jump
for n in range(1, 9)
  execute 'nnoremap <silent> [Tag]'.n  ':<C-u>tabnext'.n.'<CR>'
endfor
" t1 で1番左のタブ、t2 で1番左から2番目のタブにジャンプ

map <silent> [Tag]c :tablast <bar> tabnew<CR>
" tc 新しいタブを一番右に作る
map <silent> [Tag]x :tabclose<CR>
" tx タブを閉じる
map <silent> [Tag]n :tabnext<CR>
" tn 次のタブ
map <silent> [Tag]p :tabprevious<CR>
" tp 前のタブ


"" -- TODO LIST
"" todoリストを簡単に入力する
"abbreviate tl - [ ]
"
"" 入れ子のリストを折りたたむ
"setlocal foldmethod=indent
"
"" 折り返された行にもjkで移動する
"nnoremap <buffer> j gj
"nnoremap <buffer> k gk
"
"" todoリストのon/offを切り替える
"nnoremap <buffer> <Leader><Leader> :call ToggleCheckbox()<CR>
"vnoremap <buffer> <Leader><Leader> :call ToggleCheckbox()<CR>
"
"" 選択行のチェックボックスを切り替える
"function! ToggleCheckbox()
"  let l:line = getline('.')
"  if l:line =~ '\-\s\[\s\]'
"    let l:result = substitute(l:line, '-\s\[\s\]', '- [x]', '')
"    call setline('.', l:result)
"  elseif l:line =~ '\-\s\[x\]'
"    let l:result = substitute(l:line, '-\s\[x\]', '- [ ]', '')
"    call setline('.', l:result)
"  end
"endfunction
