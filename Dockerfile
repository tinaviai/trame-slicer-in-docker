# Build stage.
ARG BASE_IMAGE=kitware/trame:py3.10-glvnd-2025-05
FROM ${BASE_IMAGE}

# Define arguments.
ARG PYTHON_VERSION=3.10.18

# Set environment variables.
ENV TZ=Asia/Shanghai \
  PYTHONUNBUFFERED=1

# Make the `workspace` folder the current working directory.
WORKDIR /workspace/

# Copy project files and folders to the current working directory (i.e. `workspace` folder).
COPY --chown=trame-user:trame-user ./ ./

# Build shared python.
RUN echo 'START.' \
  && bash /workspace/workers/build-shared-python.sh "${PYTHON_VERSION}" \
  && echo 'END.'
ENV PATH="/workspace/runtime/Python-${PYTHON_VERSION}/MyPython/bin:${PATH}" \
  LD_LIBRARY_PATH="/workspace/runtime/Python-${PYTHON_VERSION}:${LD_LIBRARY_PATH}"

# Build trame slicer.
ENV TRAME_CLIENT_TYPE=vue3
RUN echo 'START.' \
  && bash /workspace/workers/build-trame-slicer.sh \
  && echo 'END.'

# The container listens on the specified network ports at runtime.
EXPOSE 80

# Run entrypoint in foreground.
ENTRYPOINT ["/opt/trame/entrypoint.sh"]
