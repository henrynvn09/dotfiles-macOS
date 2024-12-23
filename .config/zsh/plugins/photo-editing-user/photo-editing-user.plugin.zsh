photo_downscale_to_4k() {
    # Initialize default variables
    local OUTPUT_DIR="_OUTPUT"
    local INPUT_FILES=()

    # Function to display help message
    local show_help() {
        echo "Usage: photo_downscale_to_4k [options] <image_file(s)>"
        echo
        echo "Description:"
        echo "  Resizes one or more images to a maximum dimension of 4000 pixels (4K) using ImageMagick."
        echo
        echo "Options:"
        echo "  -o, --output <directory>   Specify the output directory for resized images."
        echo "                             Defaults to '_OUTPUT'."
        echo "  -h, --help                 Display this help message and exit."
        echo
        echo "Examples:"
        echo "  photo_downscale_to_4k image1.jpg image2.png"
        echo "  photo_downscale_to_4k *.jpg -o resized_images"
        echo "  photo_downscale_to_4k -o output_dir *.png"
    }

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    OUTPUT_DIR="$2"
                    shift 2
                else
                    echo "Error: --output requires a directory name."
                    echo "Use 'photo_downscale_to_4k --help' for more information."
                    return 1
                fi
                ;;
            -h|--help)
                show_help
                return 0
                ;;
            -*)
                echo "Error: Unknown option '$1'"
                echo "Use 'photo_downscale_to_4k --help' for usage information."
                return 1
                ;;
            *)
                INPUT_FILES+=("$1")
                shift
                ;;
        esac
    done

    # Check if ImageMagick is installed
    if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
        echo "Error: ImageMagick's 'magick' or 'convert' command is not installed."
        echo "Please install ImageMagick and try again."
        return 1
    fi

    # Determine which ImageMagick command to use
    if command -v magick &> /dev/null; then
        IM_CMD="magick"
    else
        IM_CMD="convert"
    fi

    # Check if any input files were provided
    if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
        echo "Error: No input files provided."
        echo "Use 'photo_downscale_to_4k --help' for more information."
        return 1
    fi

    # Create the output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Process each input file
    for INPUT_PATTERN in "${INPUT_FILES[@]}"; do
        # Expand wildcards
        for INPUT_FILE in $INPUT_PATTERN; do
            # Check if the file exists
            if [[ ! -f "$INPUT_FILE" ]]; then
                echo "Warning: File not found: $INPUT_FILE"
                continue
            fi

            # Generate the output file path
            local BASENAME=$(basename "$INPUT_FILE")
            local OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME}"

            # Resize the image using ImageMagick
            # The '\>' flag ensures that images are only resized if they are larger than the specified dimensions
            "$IM_CMD" "$INPUT_FILE" -resize "4000x4000>" "$OUTPUT_FILE"

            # Check if the resize was successful
            if [[ $? -eq 0 ]]; then
                echo "Image resized to a maximum of 4000px and saved to: $OUTPUT_FILE"
            else
                echo "Error: Failed to resize '$INPUT_FILE'."
            fi
        done
    done
}


# {{{1

photo_geotag() {
    # Initialize variables
    local LATITUDE=""
    local LONGITUDE=""
    local INPUT_FILES=()

    # Help message
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: add_geotag_to_images [-lat <latitude> -lon <longitude>] [-coord <latitude,longitude> | -c <latitude,longitude>] <image_file(s)>"
        echo
        echo "Description:"
        echo "  Adds geotags (latitude and longitude) to one or more images."
        echo
        echo "Arguments:"
        echo "  -lat <latitude>          The latitude to add to the images."
        echo "  -lon <longitude>         The longitude to add to the images."
        echo "  -coord <latitude,longitude> | -c <latitude,longitude>"
        echo "                           Specify the coordinates in Google Maps format."
        echo "  <image_file(s)>          One or more input image files (supports wildcards)."
        echo
        echo "Examples:"
        echo "  add_geotag_to_images -lat 40.7128 -lon -74.0060 photo.jpg"
        echo "  add_geotag_to_images -coord 34.2800487,-118.0921749 *.jpg"
        echo "  add_geotag_to_images -c 37.7749,-122.4194 photo.jpg"
        return 0
    fi

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -lat)
                LATITUDE="$2"
                shift 2
                ;;
            -lon)
                LONGITUDE="$2"
                shift 2
                ;;
            -coord|-c)
                # Correctly parse lat,lon with negative values
                LATITUDE=$(echo "$2" | cut -d',' -f1)
                LONGITUDE=$(echo "$2" | cut -d',' -f2)
                shift 2
                ;;
            *)
                # Add the argument to the input files array
                INPUT_FILES+=("$1")
                shift
                ;;
        esac
    done

    # Validate latitude and longitude
    if [[ -z "$LATITUDE" || -z "$LONGITUDE" ]]; then
        echo "Error: Latitude and longitude are required."
        echo "Use 'add_geotag_to_images --help' for more information."
        return 1
    fi

    # Check if any input files were provided
    if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
        echo "Error: No input files provided."
        echo "Use 'add_geotag_to_images --help' for more information."
        return 1
    fi

    # Create geotags for each input file
    for INPUT_FILE in "${INPUT_FILES[@]}"; do
        # Skip if the file doesn't exist
        if [[ ! -f "$INPUT_FILE" ]]; then
            echo "Warning: File not found: $INPUT_FILE"
            continue
        fi

        # Add geotag to the image using exiftool without creating backups
        exiftool -GPSLatitude="$LATITUDE" -GPSLongitude="$LONGITUDE" -GPSLatitudeRef="North" -GPSLongitudeRef="West" -overwrite_original "$INPUT_FILE"

        # Notify the user
        echo "Geotags added to: $INPUT_FILE (Latitude: $LATITUDE, Longitude: $LONGITUDE)"
    done
}

# {{{1 Combined
photo_downscale_and_geotag() {
    # Initialize variables
    local OUTPUT_DIR="_OUTPUT"
    local LATITUDE=""
    local LONGITUDE=""
    local INPUT_FILES=()

    # Help message
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: photo_resize_and_geotag [-o <output_folder>] [-lat <latitude> -lon <longitude>] [-coord <latitude,longitude> | -c <latitude,longitude>] <image_file(s)>"
        echo
        echo "Description:"
        echo "  Resizes one or more images to a maximum dimension of 4000 pixels (4K) and adds geotags."
        echo
        echo "Arguments:"
        echo "  -o, --output             Optional. Specify the folder to save the output files."
        echo "                           Defaults to '_OUTPUT'."
        echo "  -lat <latitude>          The latitude to add to the images."
        echo "  -lon <longitude>         The longitude to add to the images."
        echo "  -coord <latitude,longitude> | -c <latitude,longitude>"
        echo "                           Specify the coordinates in Google Maps format."
        echo "  <image_file(s)>          One or more input image files (supports wildcards)."
        echo
        echo "Examples:"
        echo "  photo_resize_and_geotag -lat 40.7128 -lon -74.0060 photo.jpg"
        echo "  photo_resize_and_geotag -coord 34.2800487,-118.0921749 *.jpg -o resized_geotagged"
        echo "  photo_resize_and_geotag -c 37.7749,-122.4194 photo.jpg"
        return 0
    fi

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -lat)
                LATITUDE="$2"
                shift 2
                ;;
            -lon)
                LONGITUDE="$2"
                shift 2
                ;;
            -coord|-c)
                LATITUDE=$(echo "$2" | cut -d',' -f1)
                LONGITUDE=$(echo "$2" | cut -d',' -f2)
                shift 2
                ;;
            *)
                INPUT_FILES+=("$1")
                shift
                ;;
        esac
    done

    # Validate latitude and longitude
    if [[ -z "$LATITUDE" || -z "$LONGITUDE" ]]; then
        echo "Error: Latitude and longitude are required."
        echo "Use 'photo_resize_and_geotag --help' for more information."
        return 1
    fi

    # Check if any input files were provided
    if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
        echo "Error: No input files provided."
        echo "Use 'photo_resize_and_geotag --help' for more information."
        return 1
    fi

    # Resize images first (using the photo_resize_to_4k function)
    photo_resize_to_4k -o "$OUTPUT_DIR" "${INPUT_FILES[@]}"

    # Get the list of resized files from the output directory
    RESIZED_FILES=()
    find "$OUTPUT_DIR" -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' resized_file; do
        RESIZED_FILES+=("$resized_file")
    done

    # Geotag the resized images (using the photo_geotag function)
    photo_geotag -lat "$LATITUDE" -lon "$LONGITUDE" "${RESIZED_FILES[@]}"

    # Notify the user
    echo "Images resized and geotagged successfully!"
}

# {{1
photo_padding_1_1() {
    # Initialize default variables
    local OUTPUT_DIR="_SQUARE_PADDED_PHOTOS"
    local INPUT_FILES=()
    
    # Function to display help message
    local show_help() {
        echo "Usage: photo_make_square [options] <image_file(s)>"
        echo
        echo "Description:"
        echo "  Adds equal black padding to the top and bottom of landscape images to make them square (1:1 aspect ratio)."
        echo
        echo "Options:"
        echo "  -o, --output <directory>   Specify the output directory for processed images."
        echo "                             Defaults to '_SQUARE_PADDED_PHOTOS'."
        echo "  -h, --help                 Display this help message and exit."
        echo
        echo "Examples:"
        echo "  photo_make_square image1.jpg image2.png"
        echo "  photo_make_square *.jpg -o square_images"
        echo "  photo_make_square -o output_dir *.png"
    }

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    OUTPUT_DIR="$2"
                    shift 2
                else
                    echo "Error: --output requires a directory name."
                    return 1
                fi
                ;;
            -h|--help)
                show_help
                return 0
                ;;
            -*)
                echo "Error: Unknown option '$1'"
                echo "Use 'photo_make_square --help' for usage information."
                return 1
                ;;
            *)
                INPUT_FILES+=("$1")
                shift
                ;;
        esac
    done

    # Check if ImageMagick is installed
    if ! command -v convert &> /dev/null; then
        echo "Error: ImageMagick's 'convert' command is not installed."
        echo "Please install ImageMagick and try again."
        return 1
    fi

    # Check if any input files were provided
    if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
        echo "Error: No input files provided."
        echo "Use 'photo_make_square --help' for more information."
        return 1
    fi

    # Create the output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Process each input file
    for INPUT_FILE in "${INPUT_FILES[@]}"; do
        # Handle wildcard expansion
        for FILE in $INPUT_FILE; do
            # Check if the file exists
            if [[ ! -f "$FILE" ]]; then
                echo "Warning: File not found: $FILE"
                continue
            fi

            # Get image dimensions
            read WIDTH HEIGHT <<< $(identify -format "%w %h" "$FILE")
            
            # Check if the image is landscape This doesn't work for fujifilm
            if (( WIDTH <= HEIGHT )); then
                echo "Skipping '$FILE': Not a landscape image."
                continue
            fi

            # fujifilm photos need to be checked with image orientation property
            # Extract the Orientation value using exiftool
            orientation=$(exiftool "$FILE" | grep "Orientation" | awk -F ': ' '{print $2}')

            # Check if the Orientation matches Rotate 270 CW or Rotate 90 CW
            if [[ "$orientation" == "Rotate 270 CW" || "$orientation" == "Rotate 90 CW" ]]; then
                echo "Skipping '$FILE': Not a landscape image."
                continue
            fi

            # Calculate padding needed
            local PADDING=$(( (WIDTH - HEIGHT) / 2 ))
            # If the difference is odd, add the extra pixel to the bottom
            local PADDING_TOP=$PADDING
            local PADDING_BOTTOM=$PADDING
            if (( (WIDTH - HEIGHT) % 2 != 0 )); then
                PADDING_BOTTOM=$((PADDING_BOTTOM + 1))
            fi

            # Define output file path
            local BASENAME=$(basename "$FILE")
            local OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME%.*}_square.${BASENAME##*.}"

            # Add padding using ImageMagick
            magick "$FILE" -background black -gravity center -extent "${WIDTH}x${WIDTH}" "$OUTPUT_FILE"

            # Verify if the output was created
            if [[ -f "$OUTPUT_FILE" ]]; then
                echo "Processed '$FILE' -> '$OUTPUT_FILE'"
            else
                echo "Error processing '$FILE'."
            fi
        done
    done
}

