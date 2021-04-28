FROM mpromonet/webrtc-streamer:latest

WORKDIR /app

RUN apt update && apt install -y jq

COPY . .

ENTRYPOINT ["/bin/bash", "/app/entry.sh"]
