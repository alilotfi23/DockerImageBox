#!/bin/bash

# Define initial image save path
IMAGE_SAVE_PATH="path/to/docker_image"

# Progress bar settings
bar_size=40
bar_char_done="#"
bar_char_todo="-"
bar_percentage_scale=2

# Progress bar function
function show_progress {
    image_name="$1"
    current="$2"
    total="$3"

    # Calculate progress in percentage
    percent=$(bc <<< "scale=$bar_percentage_scale; 100 * $current / $total")
    # Calculate the number of done and todo characters
    done=$(bc <<< "scale=0; $bar_size * $percent / 100")
    todo=$(bc <<< "scale=0; $bar_size - $done")

    # Build the done and todo sub-bars
    done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
    todo_sub_bar=$(printf "%${todo}s" | tr " " "${bar_char_todo}")

    # Output the progress bar with image name
    echo -ne "\rProgress $image_name : [${done_sub_bar}${todo_sub_bar}] ${percent}%"

    if [ $total -eq $current ]; then
        echo -e "\nDONE"
    fi
}

# Function to save Docker image with progress tracking
save_with_progress() {
    image_name="$1"
    output_path="$2"

    # Estimate the size of the image in bytes
    estimated_size=$(docker inspect "$image_name" --format '{{.Size}}')

    if [[ -z "$estimated_size" || "$estimated_size" -eq 0 ]]; then
        echo "Unable to estimate size for $image_name. Skipping progress tracking."
        docker save -o "$output_path" "$image_name"
        return
    fi

    # Start the docker save process in the background
    docker save -o "$output_path" "$image_name" &
    save_pid=$!

    # Monitor the file size and update the progress bar
    while kill -0 "$save_pid" 2>/dev/null; do
        if [[ -f "$output_path" ]]; then
            current_size=$(stat --printf="%s" "$output_path")
            show_progress "$image_name" "$current_size" "$estimated_size"
        else
            show_progress "$image_name" 0 "$estimated_size"
        fi
        sleep 0.5  # Update progress every 0.5 seconds
    done

    # Wait for the save process to finish
    wait "$save_pid" 2>/dev/null

    # Ensure the progress bar reaches 100%
    show_progress "$image_name" "$estimated_size" "$estimated_size"
    echo -e "\nDONE"
}

# Function to save selected Docker images
save_images() {
    local images_list=("$@")
    echo "Saving Docker images to $IMAGE_SAVE_PATH..."

    for image in "${images_list[@]}"; do
        image_filename="${image//[:\/]/_}.tar"
        save_with_progress "$image" "$IMAGE_SAVE_PATH/$image_filename"
    done

    echo -e "\n"
}

# Main script starts here
echo "Do you want to save all Docker images or specific ones?"
echo "1. Save all Docker images"
echo "2. Save specific Docker images"
read -p "Enter your choice (1 or 2): " user_choice

if [[ "$user_choice" == "1" ]]; then
    # Save all images
    images=($(docker images --format '{{.Repository}}:{{.Tag}}'))
    save_images "${images[@]}"
    echo "All Docker images saved successfully."
elif [[ "$user_choice" == "2" ]]; then
    # Prompt user for specific images
    echo "Available Docker images:"
    images_list=($(docker images --format '{{.Repository}}:{{.Tag}}'))  # Get image names as an array
    for i in "${!images_list[@]}"; do
        echo "$((i + 1)). ${images_list[$i]}"  # Display images with numbers
    done

    read -p "Enter the numbers of the images to save (space-separated): " selected_numbers

    # Convert selected numbers into image names
    selected_images=()
    for number in $selected_numbers; do
        index=$((number - 1))
        if [[ $index -ge 0 && $index -lt ${#images_list[@]} ]]; then
            selected_images+=("${images_list[$index]}")
        else
            echo "Invalid selection: $number"
        fi
    done

    if [[ ${#selected_images[@]} -eq 0 ]]; then
        echo "No valid images selected. Exiting."
        exit 1
    fi

    save_images "${selected_images[@]}"
    echo "Selected Docker images saved successfully: ${selected_images[*]}"
else
    echo "Invalid choice. Exiting."
    exit 1
fi
