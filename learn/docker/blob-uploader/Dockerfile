FROM mcr.microsoft.com/azure-cli:alpine

WORKDIR /app

# Copy the upload execution script and the local PDF directory
COPY upload.sh .
COPY ./pdfs ./pdfs

RUN chmod +x upload.sh

ENTRYPOINT ["./upload.sh"]