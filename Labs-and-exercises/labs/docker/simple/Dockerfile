# pretend to install some packages
FROM alpine:3.13 AS base
RUN echo 'Adding deps...' > /deps.txt

# pretend build
FROM base AS build
RUN echo 'Building...' > /build.txt

# pretend test suite
FROM base AS test
COPY --from=build /build.txt /build.txt
RUN echo 'Testing...' >> /build.txt

# final app image
FROM base
COPY --from=build /build.txt /build.txt
CMD cat /deps.txt && cat /build.txt