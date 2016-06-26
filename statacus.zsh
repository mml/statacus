#!/bin/zsh -f

zmodload zsh/terminfo

typeset -a name_stack
typeset -a level_stack
typeset -a string_stack

stInit() {
  name_stack=()
  level_stack=()
  string_stack=()
}

# replace current line
stReplace() {
  printf '\r'
  echoti hpa $level_stack[-1]
  echoti el
  printf "$@"
}

stPush() {
  st_push "$@"
  printf '\n%*s%s' $level_stack[-1] '' $string_stack[-1]
}

stPopTo() {
  local name="$1"

  until [[ "$name_stack[-1]" == "$name" ]] {
    stPop
    sleep .1
  }
}

stPopAll() {
  local name="$1"

  until [[ "$name_stack[-1]" != "$name" ]] {
    stPop
    sleep .1
  }
}

stPop() {
  printf '\r'
  echoti el
  echoti cuu1
  shift -p name_stack
  shift -p level_stack
  shift -p string_stack
}

stUpdate() {
  typeset -a ent
  local name="$1"
  shift
  echoti sc
  for (( i = 0; i < $#name_stack; i++ )) {
    j=$(( $#name_stack - i ))
    if [[ "$name_stack[$j]" == "$name" ]] {
      printf '\r'
      echoti hpa "$level_stack[$j]"
      echoti el
      printf "%s -- " $string_stack[$j]
      printf "$@"
      break
    }
    echoti cuu1
  }
  echoti rc
}

st_push() {
  name_stack+=($1)
  level_stack+=($2)
  string_stack+=($3)
}
