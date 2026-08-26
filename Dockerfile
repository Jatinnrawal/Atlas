FROM amazonlinux:2023

WORKDIR /opt/atlas

COPY app/atlas-app.sh /opt/atlas/atlas-app.sh

RUN chmod +x /opt/atlas/atlas-app.sh

CMD ["/opt/atlas/atlas-app.sh"]
