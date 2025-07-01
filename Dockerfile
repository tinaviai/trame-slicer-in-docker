# Build stage.
FROM kitware/trame:py3.10-glvnd-2025-05

# Set environment variables.
ENV TZ=Asia/Shanghai

# Make the `workspace` folder the current working directory.
WORKDIR /workspace/

# Copy project files and folders to the current working directory (i.e. `workspace` folder).
COPY ./workers/. ./workers

# Install project dependencies.
RUN echo 'START.' \
  && cp /workspace/workers/sources.tuna.list /etc/apt/sources.list \
  && apt update && apt install --yes vim git wget && apt clean \
  && bash /workspace/workers/build-shared-python.sh \
  && bash /workspace/workers/build-trame-slicer.sh \
  && echo 'END.'

# The container listens on the specified network ports at runtime.
EXPOSE 8888

# Run entrypoint in foreground.
ENTRYPOINT ["/workspace/trame-slicer/.venv/bin/python", "/workspace/trame-slicer/examples/medical_viewer_app.py"]

# Provide defaults for entrypoint.
CMD ["--host", "0.0.0.0", "--port", "8888", "--server"]
