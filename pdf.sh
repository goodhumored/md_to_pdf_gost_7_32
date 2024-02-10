#!/bin/bash

template="/home/goodhumored/Documents/vuz/md_pdf/g3_72.latex"
filename_a=$1
shift

# Function to display script usage
usage() {
 echo "Usage: $0 MARKDOWN_FILE [OPTIONS]"
 echo "Options:"
 echo " -h, --help      Display this help message"
 echo " --title         FILE Specify a title pdf file"
 echo " --template      FILE Specify a latex template file (Default: $template)"
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

# Function to handle options and arguments
handle_options() {
  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      --template*)
        if ! has_argument $@; then
          echo "File not specified." >&2
          usage
          exit 1
        fi

        template=$(extract_argument $@)

        shift
        ;;
			--title*)
				if ! has_argument $@; then
					echo "File not specified." >&2
					usage
					exit 1
				fi

				title=$(extract_argument $@)

				shift
				;;
      *)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Main script execution
handle_options "$@"

if [ -z ${title+x} ]; then title_path="---"; else title_path="$(realpath -- $title)"; fi

template_path="$(realpath -- $template)"
path="$(realpath -- $filename_a)"
basename="$(basename -- $filename_a)"
filename="${filename_a%.*}"
output="$PWD/$filename.pdf"
dirname="$(dirname -- $output)"
cd "$dirname"

echo "Compiling $path to $output using template $template_path with title $title_path"

pandoc -s $path -o $output --pdf-engine=xelatex --template=$template_path -f markdown+implicit_figures
