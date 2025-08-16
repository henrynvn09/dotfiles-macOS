# q - Quick LLM queries with LLM CLIs
# Inspired by https://entropicthoughts.com/q
# Converted from Nushell to Zsh by an AI assistant.

# To use this plugin, add 'q' to the plugins array in your .zshrc file:
# plugins=(... q)

# Ensure the 'opencode' command is available in your PATH.


# Main q function
q() {
    # Predefined system prompts
    typeset -A system_prompts
    system_prompts=(
        [brief]="Answer in as few words as possible. Use a brief style with short replies."
        [detailed]="Provide a thorough explanation with examples and technical details."
        [commit]="Generate a concise commit message based on the jj diff. Sample the jj log for conventional format used in the current project. If there isn't any, fallback to conventional commit message. Then use that message to jj describe automatically without asking for user confirmation because the user can then redescribe it later if needed.
    
        Rules:
        - **IMPORTANT:** Try to limit the first line message length of 72 characters unless necessary.
        - Only let the command output to stdout, DO NOT redirect it to any file.
    
        For acquiring the diff, use \`jj diff --no-pager --config ui.diff.tool='[\"git\", \"--no-pager\", \"diff\", \"--no-color\", \"-U64\", \"\$left\", \"\$right\"]'\` to get the machine readable diff.
    
        For sampling the commit message, use \`jj log -n20 -r ::@ --color=never -T builtin_log_oneline --no-pager\`.
    
        In the end, do not provide any additional text or explanation, since the UI already shows which command you have run.
        "
    )



    local recipe="brief"
    local context=""
    local user_prompt=""
    local piped_input=""
    local opt

    # Parse options using getopts
    # The leading colon in ":r:c:" enables silent error handling
    # and allows us to handle arguments for options.
    while getopts ":r:c:" opt; do
        case ${opt} in
            r)
                recipe=$OPTARG
                ;;
            c)
                context=$OPTARG
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                return 1
                ;;
        esac
    done
    # Shift the parsed options and their arguments off the argument list
    shift $((OPTIND -1))

    # The rest of the arguments form the user prompt
    user_prompt="$*"

    # Check if there is piped input
    if [ ! -t 0 ]; then
        piped_input=$(cat)
    fi

    # Validate the recipe
    if [[ -z "${system_prompts[$recipe]}" ]]; then
        echo "Error: Invalid recipe '$recipe'" >&2
        echo "Valid options: ${(k)system_prompts}" >&2
        return 1
    fi

    # Build the full system prompt
    local final_system_prompts
    final_system_prompts="You are a helpful AI assistant. Your task is to assist the user with
their queries based on the provided system prompt.

This chat is oneshot, meaning the user won't be able to ask follow-up
questions, and you should not ask for any clarifications or additional
information. Provide a complete answer based on the provided context
and perform any necessary actions without further interaction.

${system_prompts[$recipe]}
"

    if [[ -n "$context" ]]; then
        final_system_prompts+="\nCONTEXT:\n$context\n\n"
    fi

    if [[ -n "$piped_input" ]]; then
        final_system_prompts+="\nINPUT:\n$piped_input\n\n"
    fi
    
    # Check if any input was provided
    if [[ -z "$user_prompt" && -z "$piped_input" && -z "$context" ]]; then
        echo "Error: No input provided. Please provide a prompt, pipe data, or specify context." >&2
        echo "Usage: q [-r recipe] [-c context] <prompt>" >&2
        echo "   or: <some_command> | q [-r recipe] [-c context]" >&2
        return 1
    fi

    # Ensure opencode command exists
    if ! command -v opencode &> /dev/null; then
        echo "Error: 'opencode' command not found." >&2
        echo "Please ensure the opencode CLI is installed and in your PATH." >&2
        return 1
    fi

    # Run the opencode command
    opencode run --model github-copilot/claude-sonnet-4 "$final_system_prompts" "$user_prompt"
}

