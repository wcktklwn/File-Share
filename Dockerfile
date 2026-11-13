FROM httpd:2.4-alpine

COPY apache/fileshare.conf /usr/local/apache2/conf/extra/fileshare.conf
COPY theme/ /usr/local/apache2/theme/
COPY share/ /srv/share/

# The stock image serves /usr/local/apache2/htdocs and leaves autoindex plain.
# Point the document root at the share and append the themed index config.
RUN printf '\nInclude conf/extra/fileshare.conf\n' >> /usr/local/apache2/conf/httpd.conf \
    && sed -i \
        -e 's|^DocumentRoot ".*"|DocumentRoot "/srv/share"|' \
        -e 's|^#ServerName .*|ServerName localhost|' \
        /usr/local/apache2/conf/httpd.conf \
    && grep -q '^DocumentRoot "/srv/share"' /usr/local/apache2/conf/httpd.conf \
    && grep -q '^ServerName localhost' /usr/local/apache2/conf/httpd.conf \
    && chown -R www-data:www-data /srv/share \
    && httpd -t

EXPOSE 80
