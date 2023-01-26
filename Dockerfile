FROM docker.io/openjdk as builder 
RUN echo Running this build file accepts the minecraft EULA
RUN mkdir -p /Minecraft/server
WORKDIR /Minecraft
ADD https://maven.quiltmc.org/repository/release/org/quiltmc/quilt-installer/latest/quilt-installer-latest.jar /Minecraft
ADD https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar /Minecraft/server
RUN echo "eula=true" > server/eula.txt
RUN java -jar quilt-installer-*.jar install server 1.19.3 0.18.1-beta.59 --download-server
RUN rm quilt-installer-*.jar
WORKDIR /Minecraft/server
COPY . /Minecraft/server
RUN java -jar packwiz-installer-bootstrap.jar -g -s server file:///Minecraft/server/pack.toml
RUN rm -r mods/*.toml
RUN rm index.toml pack.toml packwiz-installer-bootstrap.jar packwiz-installer.jar packwiz.json
RUN mkdir world

FROM docker.io/alpine
RUN apk add openjdk17-jre-headless --no-cache
COPY --from=builder /Minecraft /Minecraft
WORKDIR /Minecraft/server
ENV RAM 4G
CMD ["sh", "-c", "java -Xmx$RAM -jar quilt-server-launch.jar nogui"]