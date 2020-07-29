if !exists('s:coscupJobId')
	let s:coscupJobId = 0
endif

" Constants for RPC messages.
let s:COSCUP = 'Coscup'

" Change this to your binary
let s:bin = '/home/yanganto/.config/nvim/plugged/coscup/target/debug/coscup'

" Entry point. Initialize RPC. If it succeeds, then attach commands to the `rpcnotify` invocations.
function! s:connect()
  let id = s:initRpc()
  
  if 0 == id
    echoerr "coscup: cannot start rpc process"
  elseif -1 == id
    echoerr "coscup: rpc process is not executable"
  else
    " Mutate our jobId variable to hold the channel ID
    let s:coscupJobId = id 
    
    call s:configureCommands()
  endif
endfunction

function! s:configureCommands()
  command! Coscup :call s:coscup()
endfunction

function! s:coscup()
  if mode()=="v"
    let [line_start, column_start] = getpos("v")[1:2]
    let [line_end, column_end] = getpos(".")[1:2]
  else
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
  end

  if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
    let [line_start, column_start, line_end, column_end] =
    \ [line_end, column_end, line_start, column_start]
  end
  if line_start == line_end
    call rpcnotify(s:coscupJobId, s:COSCUP, getline("."))
  else
    call rpcnotify(s:coscupJobId, s:COSCUP, join(getline(line_start, line_end), '\n'))
  end
endfunction

function! s:initRpc()
  if s:coscupJobId == 0
    let jobid = jobstart([s:bin], { 'rpc': v:true })
    return jobid
  else
    return s:coscupJobId 
  endif
endfunction

call s:connect()
