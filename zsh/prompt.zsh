# User customizable options
# PR_ARROW_CHAR="[some character]"
# PR_SHOW_USER=(true, false) - show username in rhs prompt
# PR_SHOW_HOST=(true, false) - show host in rhs prompt
# RPR_SHOW_GIT=(true, false) - show git status in rhs prompt
# PR_EXTRA="[stuff]" - extra content to add to prompt
# RPR_EXTRA="[stuff]" - extra content to add to rhs prompt

# Set custom prompt

# Allow for variable/function substitution in prompt
setopt prompt_subst

# Load color variables to make it easier to color things
autoload -U colors && colors

# Make using 256 colors easier
if [[ "$(tput colors)" == "256" ]]; then
    source ~/.zsh/plugins/spectrum.zsh
    # change default colors
    fg[red]=$FG[160]
    fg[green]=$FG[064]
    fg[yellow]=$FG[136]
    fg[blue]=$FG[033]
    fg[magenta]=$FG[125]
    fg[cyan]=$FG[037]

    fg[teal]=$FG[041]
    fg[orange]=$FG[166]
    fg[violet]=$FG[061]
    fg[neon]=$FG[112]
    fg[pink]=$FG[183]
else
    fg[teal]=$fg[blue]
    fg[orange]=$fg[yellow]
    fg[violet]=$fg[magenta]
    fg[neon]=$fg[green]
    fg[pink]=$fg[magenta]
fi

# Current directory, truncated to 3 path elements (or 4 when one of them is "~")
# The number of elements to keep can be specified as ${1}
function PR_DIR() {
    local sub=${1}
    if [[ "${sub}" == "" ]]; then
        sub=3
    fi
    local len="$(expr ${sub} + 1)"
    local full="$(print -P "%d")"
    local relfull="$(print -P "%~")"
    local shorter="$(print -P "%${len}~")"
    local current="$(print -P "%${len}(~:.../:)%${sub}~")"
    local last="$(print -P "%1~")"

    # Longer path for '~/...'
    if [[ "${shorter}" == \~/* ]]; then
        current=${shorter}
    fi

    local truncated="$(echo "${current%/*}/")"

    # Handle special case of directory '/' or '~something'
    if [[ "${truncated}" == "/" || "${relfull[1,-2]}" != */* ]]; then
        truncated=""
    fi

    # Handle special case of last being '/...' one directory down
    if [[ "${full[2,-1]}" != "" && "${full[2,-1]}" != */* ]]; then
        truncated="/"
        last=${last[2,-1]} # take substring
    fi

    echo "${truncated}%{$fg[blue]%}%B${last}%b%{$reset_color%}"
}

# An exclamation point if the previous command did not complete successfully
function PR_ERROR() {
    echo "%(?..%(!.%{$fg[violet]%}.%{$fg[red]%})%B!%b%{$reset_color%} )"
}

# The arrow symbol that is used in the prompt
PR_ARROW_CHAR=">"

# The arrow in red (for root) or violet (for regular user)
function PR_ARROW() {
    echo "${PR_ARROW_CHAR}%{$reset_color%}"
}

# Set custom rhs prompt
# User in red (for root) or violet (for regular user)
PR_SHOW_USER=true # Set to false to disable user in rhs prompt
function PR_USER() {
    if [[ "${PR_SHOW_USER}" == "true" ]]; then
        echo "%(!.%{$fg[red]%}.)%n%{$reset_color%}"
    fi
}

function machine_name() {
    if [[ -f $HOME/.name ]]; then
        cat $HOME/.name
    else
        hostname
    fi
}

# Host in a deterministically chosen color
PR_SHOW_HOST=true # Set to false to disable host in rhs prompt
function PR_HOST() {
    local colors
    colors=(cyan green yellow red pink)
    local index=1
    local color=$colors[index]
    if [[ "${PR_SHOW_HOST}" == "true" ]]; then
        echo "%{$fg[$color]%}$(machine_name)%{$reset_color%}:"
    fi
}

# ' at ' in orange outputted only if both user and host enabled
function PR_AT() {
    if [[ "${PR_SHOW_USER}" == "true" ]] && [[ "${PR_SHOW_HOST}" == "true" ]]; then
        echo "@%{$reset_color%}"
    fi
}

# Build the rhs prompt
function PR_INFO() {
    echo "$(PR_USER)$(PR_AT)$(PR_HOST)"
}

# Set RHS prompt for git repositories
DIFF_SYMBOL="-"
GIT_PROMPT_SYMBOL=""
GIT_PROMPT_PREFIX="("
GIT_PROMPT_SUFFIX=")"
GIT_PROMPT_AHEAD="%{$fg[teal]%}%B+NUM%b%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[orange]%}%B-NUM%b%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg[cyan]%}%Bx%b%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg[red]%}%B$DIFF_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[yellow]%}%B$DIFF_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[green]%}%B$DIFF_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_DETACHED="%{$fg[neon]%}%B!%b%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
function parse_git_branch() {
    (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# If inside a Git repository, print its branch and state
RPR_SHOW_GIT=true # Set to false to disable git status in rhs prompt
function git_prompt_string() {
    if [[ "${RPR_SHOW_GIT}" == "true" ]]; then
        local git_where="$(parse_git_branch)"
        [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$GIT_PROMPT_PREFIX%{$fg[orange]%}${git_where#(refs/heads/|tags/)}%{$reset_color%}$GIT_PROMPT_SUFFIX"
    fi
}

PROMPT_MODE=0
PROMPT_MODES=4

# Function to toggle between prompt modes
function tog() {
    PROMPT_MODE=$(( (PROMPT_MODE + 1) % PROMPT_MODES))
}

function PR_EXTRA() {
    echo $(PR_INFO)
}

# Prompt
function PCMD() {
    if (( PROMPT_MODE == 0 )); then
        echo "$(PR_EXTRA)$(PR_DIR) $(PR_ARROW) " # space at the end
    elif (( PROMPT_MODE == 1 )); then
        echo "$(PR_EXTRA)$(PR_DIR 1) $(PR_ERROR)$(PR_ARROW) " # space at the end
    else
        echo "$(PR_EXTRA)$(PR_ERROR)$(PR_ARROW) " # space at the end
    fi
}

PROMPT='$(PCMD)' # single quotes to prevent immediate execution
RPROMPT='' # set asynchronously and dynamically

function RPR_EXTRA() {
    echo $(prompt_k8s)
}

# Right-hand prompt
function RCMD() {
    if (( PROMPT_MODE == 0 )); then
        echo "$(git_prompt_string)$(RPR_EXTRA)"
    elif (( PROMPT_MODE <= 2 )); then
        echo "$(git_prompt_string)$(RPR_EXTRA)"
    else
        echo "$(RPR_EXTRA)"
    fi
}

ASYNC_PROC=0
function precmd() {
    function async() {
        # save to temp file
        printf "%s" "$(RCMD)" > "/tmp/zsh_prompt_$$"

        # signal parent
        kill -s USR1 $$
    }

    # do not clear RPROMPT, let it persist

    # kill child if necessary
    if [[ "${ASYNC_PROC}" != 0 ]]; then
        kill -s HUP $ASYNC_PROC >/dev/null 2>&1 || :
    fi

    # start background computation
    async &!
    ASYNC_PROC=$!
}

function TRAPUSR1() {
    # read from temp file
    RPROMPT="$(cat /tmp/zsh_prompt_$$)"

    # reset proc number
    ASYNC_PROC=0

    # redisplay
    zle && zle reset-prompt
}

# Display Kubectl Context
RPR_SHOW_K8S_CONTEXT=true # Set to false to disable git status in rhs prompt
function prompt_k8s(){
    if [[ "${RPR_SHOW_K8S_CONTEXT}" == "true" ]]; then
        echo "($(kubectl config current-context 2> /dev/null))"
    fi
}
