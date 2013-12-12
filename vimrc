" Match Vim 5.0 and better ====================================================
if version >= 500
" =============================================================================

"------ Meta ------"

" clear all autocommands! (this comment must be on its own line)
autocmd!
set nocompatible		" break away from old vi compatibility
"set fileformats=unix,dos,mac	" support all three newline formats
"set viminfo=			" don't use or save viminfo files

"------ Console UI & Text display ------"

" Syntax Highlighting3
syntax on

set showmode			" If in Insert, Replace or Visual mode put a message on the last line.
set cmdheight=1			" explicitly set the height of the command line
set showcmd			" Show (partial) command in status line
set number			" show line numbers
set ruler			" show current position at bottom
set tabstop=8			"
set scrolloff=7			" keep at least "x" lines around the cursor
"set wrap			" soft wrap long lines
set nowrap			" no wrap long lines
set showbreak=\|		" Mark too long lines
set whichwrap=<,>		" Cursor key move the cursor to the next/previous line if pressed at the end/beginning of a line
set list			" show invisible characters
"set listchars=tab:¯˙,trail:˙	" but only show tabs and trailing whitespace
set listchars=tab:¯˙,trail:×	" but only show tabs and trailing whitespace
set wildmenu			" turn on wild menu :e <Tab>
set wildmode=list:longest	" set wildmenu to list choice

set sidescroll=0		" scroll X columns to the side instead of centering the cursor on another screen

" Cool status line
set statusline=%<%1*===\ %5*%f%1*%(\ ===\ %4*%h%1*%)%(\ ===\ %4*%m%1*%)%(\ ===\ %4*%r%1*%)\ ===%====\ %2*%b(0x%B)%1*\ ===\ %3*%l,%c%V%1*\ ===\ %5*%P%1*\ ===%0* laststatus=2

"------ Text editing and searching behavior ------"

set hlsearch			" turn off highlighting for searched expressions
set hl=l:Visual			" use Visual mode's highlighting scheme --much better
set incsearch			" highlight as we search however
set matchtime=5			" blink matching chars for .x seconds
"set mouse=a			" try to use a mouse in the console (wimp!)
set ignorecase			" set case insensitivity
set smartcase			" unless there's a capital letter
set completeopt=menu,longest,preview	" more autocomplete <Ctrl>-P options
set nostartofline		" leave my cursor position alone!
set backspace=2			" equiv to :set backspace=indent,eol,start
set showmatch			" show matching brackets
"set formatoptions=tcrql		" t - autowrap to textwidth
"				" c - autowrap comments to textwidth
"				" r - autoinsert comment leader with <Enter>
"				" q - allow formatting of comments with :gq
"				" l - don't format already long lines
set cursorline			" highlight current line as:
"highlight CursorLine guibg=lightblue guifg=white ctermbg=blue ctermfg=white

"set textwidth=80		" we like 80 columns



" Map key to toggle opt
function MapToggle(key, opt)
	let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
	exec 'nnoremap '.a:key.' '.cmd
	exec 'inoremap '.a:key." \<C-O>".cmd
endfunction
command -nargs=+ MapToggle call MapToggle(<f-args>)

MapToggle <F8> wrap

map <S-F8> :set textwidth=80 <CR> gq <CR>

map <F2> :set number! wrap! list! cursorline!<CR>
map <F3> :if exists("syntax_on") <Bar> syntax off <Bar> else <Bar> syntax on <Bar> endif <CR>




" Definimos el modo de color y se lo aplicamos al carácter que esté en la posición 81
highlight OverLength cterm=reverse
match OverLength /\%81v/
"match OverLength /\%81v.*/






"------ Filetypes (exmaples) ------"

" Shell
"autocmd FileType sh setlocal tabstop=8

" ------------------------------------------------------------------------------

" automatically give executable permissions if file begins with #! and contains '/bin/' in the path
"au BufWritePost * if getline(1) =~ "^#!" | if getline(1) =~ "/bin/" | silent !chmod a+x <afile> | endif | endif

" Use F4 to switch between hex and ASCII editing
"function Fxxd()
"	let c=getline(".")
"	if c =~ '^[0-9a-f]\{7}:'
"		:%!xxd -r
"	else
"		:%!xxd -g4
"	endif
"endfunction
"map <F4> :call Fxxd()




" END VIM-500 ==================================================================
endif
" ==============================================================================
