photo_downscale_to_4k() {
    # Initialize default variables
    local OUTPUT_DIR="_OUTPUT"
    local INPUT_FILES=()

    # Function to display help message
    local show_help() {
        echo "Usage: photo_downscale_to_4k [options] <image_file(s)>"
        echo
        echo "Description:"
        echo "  Resizes one or more images to a maximum dimension of 4096 pixels (4K) using ImageMagick."
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
    if ! command -v magick &> /dev/null; then
        echo "Error: ImageMagick's 'magick' command is not installed."
        echo "Please install ImageMagick and try again."
        return 1
    fi

    # Determine which ImageMagick command to use
    if command -v magick &> /dev/null; then
        IM_CMD="magick"
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
            "$IM_CMD" "$INPUT_FILE" -resize "4096x4096>" "$OUTPUT_FILE"

            # Check if the resize was successful
            if [[ $? -eq 0 ]]; then
                echo "Image resized to a maximum of 4096px and saved to: $OUTPUT_FILE"
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
        echo "  Resizes one or more images to a maximum dimension of 4096 pixels (4K) and adds geotags."
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
photo_padding_square() {
    # Initialize default variables
    local OUTPUT_DIR="_PADDED_PHOTOS"
    local SCALE_FACTOR="1:0.9"
    local INPUT_FILES=()

    # Function to display help message
    local show_help() {
        echo "Usage: photo_padding_scaled [options] <image_file(s)>"
        echo
        echo "Description:"
        echo "  Adds black padding to images to match the specified aspect ratio."
        echo "  Default aspect ratio is 1:0.9."
        echo
        echo "Options:"
        echo "  -o, --output <directory>   Specify the output directory for processed images."
        echo "                             Defaults to '_PADDED_PHOTOS'."
        echo "  -s, --scale <ratio>        Specify the aspect ratio as 'width:height'."
        echo "                             Defaults to '1:0.9'."
        echo "  -h, --help                 Display this help message and exit."
        echo
        echo "Examples:"
        echo "  photo_padding_scaled image1.jpg image2.png"
        echo "  photo_padding_scaled *.jpg -o scaled_images"
        echo "  photo_padding_scaled -s 1:1.5 image1.jpg"
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
            -s|--scale)
                if [[ -n "$2" && "$2" =~ ^[0-9]+:[0-9]+$ ]]; then
                    SCALE_FACTOR="$2"
                    shift 2
                else
                    echo "Error: --scale requires a valid ratio (e.g., 1:0.9)."
                    return 1
                fi
                ;;
            -h|--help)
                show_help
                return 0
                ;;
            -*)
                echo "Error: Unknown option '$1'"
                echo "Use 'photo_padding_scaled --help' for usage information."
                return 1
                ;;
            *)
                INPUT_FILES+=("$1")
                shift
                ;;
        esac
    done

    # Check if ImageMagick is installed
    if ! command -v magick &> /dev/null; then
        echo "Error: ImageMagick's command is not installed."
        echo "Please install ImageMagick and try again."
        return 1
    fi

    # Check if any input files were provided
    if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
        echo "Error: No input files provided."
        echo "Use 'photo_padding_scaled --help' for more information."
        return 1
    fi

    # Parse scale factor into width and height
    local SCALE_WIDTH=$(echo "$SCALE_FACTOR" | cut -d':' -f1)
    local SCALE_HEIGHT=$(echo "$SCALE_FACTOR" | cut -d':' -f2)

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

            # Calculate target dimensions based on scale factor
            TARGET_HEIGHT=$(echo "scale=0; $WIDTH * $SCALE_HEIGHT / $SCALE_WIDTH" | bc)

            # Calculate padding needed
            local PADDING=$(( (TARGET_HEIGHT - HEIGHT) / 2 ))

            # If the difference is odd, add the extra pixel to the bottom
            local PADDING_TOP=$PADDING
            local PADDING_BOTTOM=$PADDING
            if (( (TARGET_HEIGHT - HEIGHT) % 2 != 0 )); then
                PADDING_BOTTOM=$((PADDING_BOTTOM + 1))
            fi

            # Define output file path
            local BASENAME=$(basename "$FILE")
            local OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME%.*}_scaled.${BASENAME##*.}"

            # Add padding using ImageMagick
            magick "$FILE" -background black -gravity center -extent "${WIDTH}x${TARGET_HEIGHT}" "$OUTPUT_FILE"

            # Verify if the output was created
            if [[ -f "$OUTPUT_FILE" ]]; then
                echo "Processed '$FILE' -> '$OUTPUT_FILE'"
            else
                echo "Error processing '$FILE'."
            fi
        done
    done
}
# {{1

# Function to add padding to an image and display help message
photo_padder() {
    local padding="100"  # Default padding set to 100 pixels
    local output_dir="_PADDED_PHOTOS"
    local input_files=()

    # Function to display help message (inner function)
    local show_help() {
        echo "Usage: photo_padder [options] [<padding>] <image_file(s)>"
        echo
        echo "Description:"
        echo "  Adds padding to the borders of images. Padding color (black or white)"
        echo "  is chosen based on the dominant color of the image."
        echo
        echo "Options:"
        echo "  -o, --output <directory>   Specify the output directory for processed images."
        echo "                             Defaults to '_PADDED_PHOTOS'."
        echo "  -h, --help                 Display this help message and exit."
        echo
        echo "Arguments:"
        echo "  <padding>                  The amount of padding to add (in pixels)."
        echo "                             Defaults to 100 if not specified."
        echo "  <image_file(s)>            The image file(s) to process."
        echo
        echo "Examples:"
        echo "  photo_padder image1.jpg image2.png"
        echo "  photo_padder 50 *.jpg"
        echo "  photo_padder -o my_padded_images image.png"
        echo "  photo_padder 200 -o outputs *.gif"
    }

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            -o|--output)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    output_dir="$2"
                    shift 2
                else
                    echo "Error: --output requires a directory name."
                    return 1
                fi
                ;;
            -*)
                echo "Error: Unknown option '$1'"
                echo "Use 'photo_padder --help' for usage information."
                return 1
                ;;
            *)
                # If it's not an option, check if it's a number (padding)
                if [[ "$1" =~ ^[0-9]+$ ]]; then
                    # If padding is already set, it must be a file
                    if [[ -n "$padding" && "$padding" != "100" ]]; then
                        input_files+=("$1")
                    else
                        padding="$1"
                    fi
                else
                    input_files+=("$1")
                fi
                shift
                ;;
        esac
    done

    # Check if any input files were provided
    if [[ ${#input_files[@]} -eq 0 ]]; then
        echo "Error: No input files provided."
        echo "Use 'photo_padder --help' for more information."
        return 1
    fi

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Check if ImageMagick is installed
    if ! command -v convert &> /dev/null; then
        echo "Error: ImageMagick's 'convert' command is not installed."
        echo "Please install ImageMagick and try again."
        return 1
    fi

    # Process each input file
    for input_file in "${input_files[@]}"; do
        # Handle wildcard expansion
        for file in "$input_file"; do
            # Check if the file exists
            if [[ ! -f "$file" ]]; then
                echo "Warning: File not found: $file"
                continue
            fi

            # Get image dimensions
            read width height <<< $(identify -format "%w %h" "$file")

            # Determine dominant color (simplified approach)
            dominant_color=$(magick "$file" -scale 1x1\! -format "%[pixel:u]" info:-)
            brightness=$(magick xc:"$dominant_color" -colorspace Gray -format "%[fx:int(255*r)]" info:-)

            # Choose padding color
            if (( brightness > 128 )); then
                padding_color="black"
            else
                padding_color="white"
            fi

            # Calculate new dimensions
            new_width=$((width + 2 * padding))
            new_height=$((height + 2 * padding))

            # Define output file path (keep original filename)
            local basename=$(basename "$file")
            output_file="${output_dir}/${basename}"

            # Add padding using ImageMagick
            magick "$file" \
                -background "$padding_color" \
                -gravity center \
                -extent "${new_width}x${new_height}" \
                "$output_file"

            # Verify if the output was created
            if [[ -f "$output_file" ]]; then
                echo "Processed '$file' -> '$output_file'"
            else
                echo "Error processing '$file'."
            fi
        done
    done
}

# {{{1
# Function to crop images to a specified or automatically determined aspect ratio
photo_cropper() {
    local output_dir="_CROPPED_PHOTOS"
    local crop_ratio=""  # Default is to auto-determine
    local input_files=()

    # Function to display help message (inner function)
    local show_help() {
        echo "Usage: photo_cropper [options] <image_file(s)>"
        echo
        echo "Description:"
        echo "  Crops images to a specified aspect ratio (width:height) or automatically"
        echo "  determines the aspect ratio (4:5 or 5:4) based on the image's dimensions."
        echo
        echo "Options:"
        echo "  -o, --output <directory>      Specify the output directory for processed images."
        echo "                                Defaults to '_CROPPED_PHOTOS'."
        echo "  -r, --ratio <width:height>    Specify the desired cropping ratio (e.g., 16:9, 1:1)."
        echo "                                If not provided, defaults to 4:5 or 5:4."
        echo "  -h, --help                    Display this help message and exit."
        echo
        echo "Arguments:"
        echo "  <image_file(s)>               The image file(s) to process."
        echo
        echo "Examples:"
        echo "  photo_cropper image1.jpg image2.png"
        echo "  photo_cropper *.jpg -o cropped_images"
        echo "  photo_cropper -r 16:9 video_frame.png"
        echo "  photo_cropper -r 1:1 square_image.jpg -o squares"
    }

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            -o|--output)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    output_dir="$2"
                    shift 2
                else
                    echo "Error: --output requires a directory name."
                    return 1
                fi
                ;;
            -r|--ratio)
                if [[ -n "$2" && "$2" =~ ^[0-9]+:[0-9]+$ ]]; then
                    crop_ratio="$2"
                    shift 2
                else
                    echo "Error: --ratio requires a valid ratio (e.g., 16:9)."
                    return 1
                fi
                ;;
            -*)
                echo "Error: Unknown option '$1'"
                echo "Use 'photo_cropper --help' for usage information."
                return 1
                ;;
            *)
                input_files+=("$1")
                shift
                ;;
        esac
    done

    # Check if any input files were provided
    if [[ ${#input_files[@]} -eq 0 ]]; then
        echo "Error: No input files provided."
        echo "Use 'photo_cropper --help' for more information."
        return 1
    fi

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Check if ImageMagick is installed
    if ! command -v magick &> /dev/null; then
        echo "Error: ImageMagick's 'magick' command is not installed."
        echo "Please install ImageMagick and try again."
        return 1
    fi

    # Process each input file
    for input_file in "${input_files[@]}"; do
        # Handle wildcard expansion
        for file in $input_file; do
            # Check if the file exists
            if [[ ! -f "$file" ]]; then
                echo "Warning: File not found: $file"
                continue
            fi

            # Get image dimensions
            read width height <<< $(magick identify -format "%w %h" "$file")

            # Determine aspect ratio and calculate cropping parameters
            if [[ -z "$crop_ratio" ]]; then
                # Auto-determine aspect ratio (4:5 or 5:4)
                if (( $(echo "$width / $height > 1.0" | bc -l) )); then
                    target_aspect_ratio=$(echo "scale=4; 5/4" | bc)
                else
                    target_aspect_ratio=$(echo "scale=4; 4/5" | bc)
                fi
            else
                # Use specified aspect ratio
                ratio_w=$(echo "$crop_ratio" | cut -d':' -f1)
                ratio_h=$(echo "$crop_ratio" | cut -d':' -f2)
                target_aspect_ratio=$(echo "scale=4; $ratio_w / $ratio_h" | bc)
            fi

            if (( $(echo "$width / $height > $target_aspect_ratio" | bc -l) )); then
                # Image is wider than the target aspect ratio
                target_width=$(echo "$height * $target_aspect_ratio" | bc | awk '{printf "%.0f", $0}')
                target_height=$height
                x_offset=$(( (width - target_width) / 2 ))
                y_offset=0
            else
                # Image is taller than the target aspect ratio
                target_width=$width
                target_height=$(echo "$width / $target_aspect_ratio" | bc | awk '{printf "%.0f", $0}')
                x_offset=0
                y_offset=$(( (height - target_height) / 2 ))
            fi

            # Define output file path
            output_file="$output_dir/$(basename "$file")"

            # Crop using ImageMagick
            magick "$file" -crop "${target_width}x${target_height}+${x_offset}+${y_offset}" +repage "$output_file"

            # Verify if the output was created
            if [[ -f "$output_file" ]]; then
                actual_aspect_ratio=$(echo "scale=2; $target_width / $target_height" | bc -l)
                echo "Processed '$file' -> '$output_file' (Cropped to ${actual_aspect_ratio} aspect ratio)"
            else
                echo "Error processing '$file'."
            fi
        done
    done
}

