# Build multi-stage oficial para Dart Shelf API
FROM dart:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Imagem final mínima com runtime Dart
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

EXPOSE 8080
CMD ["/app/bin/server"]
