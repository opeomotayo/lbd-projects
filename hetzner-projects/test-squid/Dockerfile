# Use the Ubuntu base image
FROM ubuntu:latest

# Install Squid and necessary packages
RUN apt-get update && apt-get install -y squid

# Create a non-root user and group for Squid
RUN groupadd -r squid && useradd -r -g squid -M -d /var/spool/squid -s /usr/sbin/nologin squid

RUN mkdir -p /var/run/squid
RUN chown -R squid:squid /var/run/squid

# Copy your Squid configuration file to the container
COPY squid.conf /etc/squid/squid.conf

# Ensure the Squid configuration directory is owned by the non-root user
RUN chown -R squid:squid /etc/squid

# Create cache and log directories and set permissions
RUN mkdir -p /var/spool/squid /var/log/squid && chown -R squid:squid /var/spool/squid /var/log/squid

# Expose the Squid proxy port
EXPOSE 3128

# Switch to the non-root user before running Squid
USER squid

# Start Squid when the container is run
CMD ["squid", "-NYCd", "1"]

