# Trame Slicer in Docker

## Quickstart

1. Build image

    ```bash
    docker image build --tag=trame-slicer-in-docker ./
    ```

2. Run container

    ```bash
    docker container run --publish=8888:8888 --rm trame-slicer-in-docker
    ```

3. Open browser

    ```bash
    google-chrome http://localhost:8888
    ```