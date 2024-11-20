# DockerImageBox 

This script allows you to save Docker images to your local storage with a real-time progress bar and user-friendly options. You can save all Docker images or only specific ones, with visual feedback during the save process.

## Features:
1. **Real-time progress bar**: Tracks the progress of saving Docker images.
2. **Save all Docker images**: Option to save all images from your local Docker registry.
3. **Save specific Docker images**: The user can select specific images to save.
4. **Customizable save path**: You can specify the directory where Docker images will be saved.
5. **Image name display in progress**: The progress bar shows the name of the image currently being saved.

## Prerequisites:
Before using this script, ensure you have the following installed:
- **Docker**: The script uses `docker images` and `docker save` commands to list and save Docker images.
- **bash**: The script is written for bash, so it should work on Linux or macOS.
- **bc**: This is used for arithmetic operations, such as calculating progress percentages.

## Setup

### Step 1: Clone or Copy the Script
Copy the script to your local machine. You can clone the repository or manually copy the code into a file.

```bash
$ git clone https://github.com/alilotfi23/DockerImageBox.git
$ cd DockerImageBox
$ chmod +x dockerimagebox.sh
```

### Step 2: Run the Script
You can run the script directly from the command line.

```bash
$ ./dockerimagebox.sh
```

### Step 3: Follow the Prompts
The script will prompt you with options:
1. Save **all Docker images**.
2. Save **specific Docker images** by selecting their numbers.

#### Example Interaction

```plaintext
Do you want to save all Docker images or specific ones?
1. Save all Docker images
2. Save specific Docker images
Enter your choice (1 or 2): 2

Available Docker images:
1. nginx:latest
2. tomcat:latest
3. ubuntu:latest
4. redis:latest
5. traefik:v3.1.2
6. postgres:latest

Enter the numbers of the images to save (space-separated): 4 6 

Saving Docker images to /home/ali/images...
Progress postgres:latest : [###############-------------------------] 38.00%
Progress redis:latest : [#######################################] 100.00%
DONE

Selected Docker images saved successfully: redis:latest postgres:latest
```

## How It Works

1. **Display Options**: The script asks the user whether they want to save all images or select specific ones.
   
2. **Saving All Docker Images**: If the user selects to save all images, the script uses `docker images` to list all images and then proceeds to save each one using `docker save`.

3. **Saving Specific Docker Images**: If the user opts to select specific images, the script displays the available images with numbers. The user enters the numbers corresponding to the images they want to save. The script then saves those images one by one.

4. **Progress Bar**: For each image being saved, the script estimates the size of the image, monitors the progress and displays a real-time progress bar. The progress bar is updated every 0.5 seconds.

    Example of the progress bar output:
    ```plaintext
    Progress redis:latest : [###############-------------------------] 38.00%
    ```

5. **Save Path**: The images are saved as `.tar` files in the directory specified in the `IMAGE_SAVE_PATH` variable (`/home/ali/images` by default). The image filename is derived from the image name by replacing special characters like `:` and `/` with underscores.

6. **Completion**: Once all images are saved, the script displays a success message and lists the saved images.

## Script Details

### Variables:
- **`bar_size`**: The total length of the progress bar (default: 40).
- **`bar_char_done`**: Character used to represent the completed portion of the progress bar (default: `#`).
- **`bar_char_todo`**: Character used to represent the remaining portion of the progress bar (default: `-`).
- **`bar_percentage_scale`**: Decimal places for the percentage calculation (default: 2).
- **`IMAGE_SAVE_PATH`**: The directory where Docker images will be saved (default: `/home/ali/images`).

### Functions:
- **`show_progress`**: This function calculates the progress percentage based on the current and total size, and updates the progress bar in real-time. It takes the image name, current size, and total size as arguments.
  
- **`save_with_progress`**: This function handles the saving of each Docker image with progress tracking. It estimates the size of the image using `docker inspect` and then uses `docker save` to save the image to a `.tar` file.
  
- **`save_images`**: This function iterates over the list of images (either all or specific ones) and calls `save_with_progress` for each image.

## Customization

You can modify the following settings to suit your needs:
1. **`IMAGE_SAVE_PATH`**: Change the path where Docker images will be saved. For example, change it to `/mnt/backup` if you want to save the images on a different drive.
2. **Progress Bar Size**: Adjust `bar_size` if you want a larger or smaller progress bar.
3. **Character Choices**: Modify `bar_char_done` and `bar_char_todo` to use different characters for the progress bar.

## Troubleshooting

### Common Issues:
- **Insufficient Disk Space**: If you don't have enough disk space to save the Docker images, the script will fail. Ensure you have enough space on the target drive.

### Docker Errors:
- **"Unable to estimate size"**: If the script cannot fetch the image size, it will still attempt to save the image without progress tracking.
- **Permission Errors**: Ensure you have appropriate permissions to save images to the target directory.

## License

This script is open source and can be freely modified and distributed under the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

- Thanks to [Docker Documentation](https://docs.docker.com/) for providing useful references on `docker save`, `docker images`, and `docker inspect`.
