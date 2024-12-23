photo_downscale_to_4k() {
    # Initialize variables
    local OUTPUT_DIR="_OUTPUT"
    local INPUT_FILES=() # Properly initialize the array

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: resize_to_4k <image_file(s)> [-o <output_folder>]"
                echo
                echo "Description:"
                echo "  Resizes one or more images to a maximum dimension of 4000 pixels (4K)."
                echo
                echo "Arguments:"
                echo "  <image_file(s)>  One or more input image files (supports wildcards)."
                echo "  -o, --output     Optional. Specify the folder to save the output files."
                echo "                   Defaults to '_OUTPUT'."
                echo
                echo "Examples:"
                echo "  resize_to_4k photo.jpg"
                echo "  resize_to_4k DSCF00* -o custom_folder"
                return 0
                ;;
            *)
                # Add the argument to the input files array
                INPUT_FILES+=("$1")
                shift
                ;;
        esac
    done

    # Check if any input files were provided
    if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
        echo "Error: No input files provided."
        echo "Use 'resize_to_4k --help' for more information."
        return 1
    fi

    # Create the output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Process each input file
    for INPUT_FILE in "${INPUT_FILES[@]}"; do
        # Skip if the file doesn't exist
        if [[ ! -f "$INPUT_FILE" ]]; then
            echo "Warning: File not found: $INPUT_FILE"
            continue
        fi

        # Generate the default output file name
        # local OUTPUT_FILE="${OUTPUT_DIR}/${INPUT_FILE%.*}_4k.${INPUT_FILE##*.}"
        local OUTPUT_FILE="${OUTPUT_DIR}/${INPUT_FILE%.*}.${INPUT_FILE##*.}"

        # Resize the image
        sips -Z 4000 "$INPUT_FILE" --out "$OUTPUT_FILE"

        # Notify the user
        echo "Image resized to 4000px (maximum dimension) and saved in: $OUTPUT_FILE"
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

