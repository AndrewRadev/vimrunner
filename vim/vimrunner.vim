let has_error_handling_bugfix =
      \ v:version > 703 ||
      \ v:version == 703 && has('patch860')

if has_error_handling_bugfix
  function! VimrunnerEvaluateCommandOutput(command)
    let output = ''

    try
      redir => output
      silent exe a:command
      redir END

      let output = s:StripSilencedErrors(output)
    catch
      let output = v:exception
    endtry

    return output
  endfunction
else
  " Use some fake error handling to provide at least rudimentary errors for
  " missing commands.
  function! VimrunnerEvaluateCommandOutput(command)
    let base_command = split(a:command, '\s\+')[0]
    let base_command = substitute(base_command, '!$', '', '')
    let base_command = substitute(base_command, '^\d\+', '', '')

    if !exists(':'.base_command)
      let output = 'Vim:E492: Not an editor command: '.base_command
    else
      redir => output
      silent exe a:command
      redir END
    endif

    return output
  endfunction
endif

" Remove errors from the output that have been silenced by :silent!. These are
" visible in the captured output since all messages are captured by :redir.
function! s:StripSilencedErrors(output)
  let processed_output = []

  for line in reverse(split(a:output, "\n"))
    if line =~ '^E\d\+:'
      break
    endif

    call add(processed_output, line)
  endfor

  return join(reverse(processed_output), "\n")
endfunction

" vim: set ft=vim
